CREATE OR REPLACE PACKAGE CECRED.INSS0001 AS

  /*---------------------------------------------------------------------------------------------------------------

   Programa : INSS0001                       Antiga: generico/procedures/b1wgen0091.p
   Autor   : Andre - DB1
   Data    : 16/05/2011                        Ultima atualizacao: 13/02/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : BO - Alteracao de Domicilio Bancario

   Alteracoes:  13/09/2011 - Adicionadas procedures para processamento de
                             arquivos e informacoes para Previdencia
                             (GATI - Eder).

                30/09/2011 - N?o carregar cooperativa 3 na gera_arquivos_inss
                             (GATI - Vitor).

                04/10/2011 - Na verifica_arquivos_demonstrativo_inss buscar no
                             diret?rio fixo da CECRED
                             Na processa_arquivos_demonstrativo salvar tamb?m
                             no diret?rio fixo da CECRED
                05/10/2011 - Na valida??o do diret?rio verificar apenas 1
                             arquivo e n?o todos (Vitor - GATI)

                24/10/2011 - Adicionado a include b1cabrelvar.i para ser usada
                             pela b1cabrel080.i ( Rogerius Milit?o - DB1 )

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

                29/01/2013 - Altera??es nos campos do Rel.473 (Lucas).

                25/03/2013 - Ajustes realizados:
                             - Na procedure pi_grava_registros_inss para
                               que, no momento da atualizacao "buffer-copy" da
                               crapcbi, nao atualizar os campos dtenvipv,
                               dtcompvi, indresvi;
                             - Na funcao verificacao_bloqueio para que, quando
                               haja mais de um beneficio com bloqueio, seja
                               retornado o tpbloque corretamente (Adriano).

                17/05/2013 - Criado a procedure busca-benefic-compvi (Adriano).

                27/08/2013 - Conversao Progress para oracle (Odirlei - AMcom)
                
                26/11/2013 - Conversao Progress para Oracle da procedure 
                             beneficios-inss da b1wgen0045.p (Douglas Pagel).
                             
                19/02/2015 - Adicionadas as tabelas de memoria typ_tab_benefic e 
                             typ_tab_titulares (Alisson - AMcom)
                             
                22/09/2015 - Adicionado validação no valor dos campos das procedures:
                                 - pc_solic_troca_domicilio
                                 - pc_solic_comprovacao_vida
                                 - pc_solic_troca_op_cc_coop
                                 - pc_solic_troca_op_cc
                                 - pc_solic_alt_cad_benef                                
                           - Alterado nomenclatura dos arquivos das procedures:
                                 - pc_solic_troca_domicilio
                                 - pc_solicita_demonstrativo
                                 - pc_solic_comprovacao_vida
                                 - pc_solic_troca_op_cc_coop
                                 - pc_solic_troca_op_cc
                                 - pc_solic_alt_cad_benef
                                 - pc_solic_consulta_benef
                            (Douglas - Chamado 314031)
                            
                07/10/2015 - Ajustado as procedures para reaproveitar os tratamentos das informações
                             do pagamento de beneficio do INSS quando executado pelo CRPS ou pela TELA
                             (Douglas - Chamado 314031)
                
                24/11/2015 - Criadas procedures pc_verifica_situacao_senha 
                             e pc_consulta_log. Projeto 255 INSS (Lombardi)

                31/05/2016 - Ajuste na pc_busca_demonst_sicredi para não gravar dados do XML que não são
                             referentes ao mês da consulta
                             Retirar o TO_DATE no insert da "DCB" (Guilherme/SUPERO)

               19/05/2017 - Incluido nome do módulo logado em todas procedures
                            Eliminada a rotina pc_popula_dcb_inss                             
                            Incluido tipo de falha variavel na Procedure pc_retorna_linha_log implica em alterar 10 procedures que a disparam
                            Colocado no padrão todas chamadas pc_gera_log_batch em torno de 60 chamadas
                            (Belli - Envolti - Chamado 660327 e 664301)              
                            
  --------------------------------------------------------------------------------------------------------------- */

   --Tipo de Tabela Com inicial dos meses do ano
   TYPE typ_tab_dsdmeses IS VARRAY (12) OF VARCHAR2(1);
   vr_tab_dsdmeses typ_tab_dsdmeses:= typ_tab_dsdmeses('1','2','3','4','5','6',
                                                       '7','8','9','O','N','D');
   
   -- Tipo de registro para PlTable de tela-inss
   TYPE typ_reg_tela_inss IS
     RECORD (cdcooper craplbi.cdcooper%type
            ,cdagenci craplbi.cdagenci%type
            ,nmagenci crapage.nmresage%type
            ,dtdpagto craplbi.dtdpagto%TYPE
            ,nrbenefi craplbi.nrbenefi%TYPE
            ,nrrecben craplbi.nrrecben%TYPE
            ,nrdconta craplbi.nrdconta%TYPE
            ,nmrecben crapcbi.nmrecben%TYPE
            ,tpmepgto VARCHAR2(4000)
            ,vllanmto craplbi.vllanmto%TYPE
            ,vlliqcre craplbi.vlliqcre%TYPE
            ,vldoipmf NUMBER(28,2));
            
   -- Tipo de tabela para PlTable de tela-inss
   TYPE typ_tab_tela_inss IS
     TABLE OF typ_reg_tela_inss
     INDEX BY VARCHAR2(20);
     
   -- Tipo de registro para PlTable de result-inss
   TYPE typ_reg_result_inss IS
     RECORD (cdcooper craplbi.cdcooper%TYPE
            ,cdagenci craplbi.cdagenci%TYPE
            ,totalcre NUMBER(25,2)       
            ,quantida PLS_INTEGER        
            ,totaldcc NUMBER(25,2)       
            ,quantid2 PLS_INTEGER        
            ,totalpac NUMBER(25,2)       
            ,quantpac PLS_INTEGER);      
            
   -- Tipo de tabela para PlTable de result-inss
   TYPE typ_tab_result_inss IS
     TABLE OF typ_reg_result_inss
     INDEX BY VARCHAR2(20);

    --Tipo de Registro de Arquivos
    TYPE typ_reg_arquivos IS RECORD --(b1wgen0091tt.i/tt-arquivos) 
      (cdcooper crapcop.cdcooper%type
      ,nmrescop crapcop.nmrescop%type
      ,cdagenci crapage.cdagenci%type
      ,nmarquiv VARCHAR2(100)
      ,qtnaopag INTEGER
      ,vlnaopag NUMBER
      ,qtbloque INTEGER
      ,vlbloque NUMBER
      ,dsstatus VARCHAR2(100));
    --Tipo de tabela de Arquivos
    TYPE typ_tab_arquivos IS TABLE OF typ_reg_arquivos INDEX BY PLS_INTEGER;
    
    --Tipo de Registros de Rejeicoes
    TYPE typ_reg_rejeicoes IS RECORD --(b1wgen0091tt.i/tt-rejeicoes)
      (tpmepgto craplbi.tpmepgto%type
      ,cdoperac INTEGER
      ,cdagenci craplbi.cdagenci%type
      ,nrrecben craplbi.nrrecben%type
      ,nrbenefi craplbi.nrbenefi%type
      ,nmrecben crapcbi.nmrecben%type
      ,dtinipag craplbi.dtinipag%type
      ,dtfimpag craplbi.dtfimpag%type
      ,vllanmto craplbi.vllanmto%type
      ,dscritic VARCHAR2(1000)
      ,cdcooper crapcop.cdcooper%type
      ,cdbloque craplbi.cdbloque%type
      ,nrdconta craplbi.nrdconta%type);
    --Tipo de Tabela de Rejeicoes
    TYPE typ_tab_rejeicoes IS TABLE OF typ_reg_rejeicoes INDEX BY PLS_INTEGER;  
      
    --Tipo de Registros de Creditos
    TYPE typ_reg_creditos IS RECORD --(b1wgen0091tt.i/tt-creditos) 
      (cdcooper INTEGER
      ,cdagenci INTEGER
      ,cdagesic INTEGER
      ,cdagepac INTEGER
      ,dtdpagto DATE
      ,natdocre VARCHAR2(100)
      ,vldescto NUMBER
      ,vlrbruto NUMBER
      ,postoorg VARCHAR2(100)
      ,cdorgblq VARCHAR2(100)
      ,dtdcadas DATE
      ,nmbenefi VARCHAR2(100)
      ,dtdnasci DATE
      ,nrrecben NUMBER
      ,tpnrbene VARCHAR2(100)
      ,cdorgpag INTEGER
      ,cdorgins INTEGER
      /* Beneficio */
      ,cdbenefi NUMBER
      ,dtinicio DATE
      ,datfinal DATE
      ,sitbenef VARCHAR2(100)
      ,dscespec VARCHAR2(100)
      ,tpdpagto VARCHAR2(100)
      ,dtvalini DATE
      ,dtvalfin DATE
      ,vlrbenef NUMBER
      /* Dados Conta Corrente Ass*/
      ,dscsitua VARCHAR2(100)
      ,nrdconta INTEGER
      ,nrcpfcgc NUMBER
      ,idbenefi NUMBER
      ,cddigver VARCHAR2(100)
      ,geracred BOOLEAN
      ,inpessoa INTEGER);
    --Tipo de Tabela de Creditos
    TYPE typ_tab_creditos IS TABLE OF typ_reg_creditos INDEX BY PLS_INTEGER;
     
    --Tipo de Registros de Beneficiarios
    TYPE typ_reg_benefic IS RECORD --(b1wgen0091tt.i/tt-benefic) 
      (nmrecben crapcbi.nmrecben%type
      ,nrcpfcgc crapcbi.nrcpfcgc%type
      ,nrbenefi crapcbi.nrbenefi%type
      ,nrrecben crapcbi.nrrecben%type
      ,cdaginss crapcbi.cdaginss%type
      ,dtatucad crapcbi.dtatucad%type 
      ,cdaltcad crapcbi.cdaltcad%type
      ,dtdenvio crapcbi.dtdenvio%type
      ,tpmepgto crapcbi.tpmepgto%type
      ,nrdconta crapcbi.nrdconta%type
      ,dtnasben crapcbi.dtnasben%type
      ,nmmaeben crapcbi.nmmaeben%type
      ,dsendben crapcbi.dsendben%type
      ,nmbairro crapcbi.nmbairro%type
      ,nrcepend crapcbi.nrcepend%type
      ,dtatuend crapcbi.dtatuend%type
      ,cdagenci crapcbi.cdagenci%type
      ,nmresage crapage.nmresage%type
      ,indresvi crapcbi.indresvi%type
      ,dscresvi VARCHAR2(1000)
      ,dtcompvi crapcbi.dtcompvi%type
      ,dtprcomp crapcbi.dtcompvi%type);

    --Tipo de Tabela de Beneficiarios
    TYPE typ_tab_benefic IS TABLE OF typ_reg_benefic INDEX BY VARCHAR2(50);

    --Tipo de Registros de Titulares
    TYPE typ_reg_titulares IS RECORD --(b1wgen0091tt.i/tt-titulares) 
      (cdcooper crapcop.cdcooper%type
      ,nrdconta crapttl.nrdconta%type
      ,nrcpfcgc crapttl.nrcpfcgc%type
      ,idseqttl crapttl.idseqttl%type
      ,nmextttl crapttl.nmextttl%type
      ,nmbairro crapenc.nmbairro%type
      ,nmcidade crapenc.nmcidade%type
      ,nrcepend crapenc.nrcepend%type
      ,cdufdttl crapttl.cdufdttl%type
      ,dsendres crapenc.dsendere%type
      ,nrendere crapenc.nrendere%type
      ,cdorgins crapage.cdorgins%type
      ,cdagepac crapage.cdagenci%type
      ,cdagesic crapcop.cdagesic%type
      ,nmresage crapage.nmresage%type
      ,nrdddtfc craptfc.nrdddtfc%type
      ,nrtelefo craptfc.nrtelefo%type
      ,nmmaettl crapttl.nmmaettl%type
      ,cdsexotl crapttl.cdsexotl%type
      ,dtnasttl crapttl.dtnasttl%type);
    
    --Tipo de Tabela de Titulares
    TYPE typ_tab_titulares IS TABLE OF typ_reg_titulares INDEX BY PLS_INTEGER;
    

    --Tipo de Registros de Rubricas
    TYPE typ_reg_rubrica IS RECORD --(b1wgen0091tt.i/tt-rubrica) 
      (nrbenefi NUMBER
      ,nrrecben NUMBER
      ,cdrubric VARCHAR2(3)
      ,vlrubric NUMBER
      ,nmrubric VARCHAR2(100)
      ,tpnature VARCHAR2(100));    
          
    --Tipo de Tabela de Rubricas
    TYPE typ_tab_rubrica IS TABLE OF typ_reg_rubrica INDEX BY PLS_INTEGER;

    --Tipo de Registros de Demonstrativos
    TYPE typ_reg_demonstrativos IS RECORD --(b1wgen0091tt.i/tt-demonstrativos) 
      (cnpjemis VARCHAR2(30)
      ,nomeemis VARCHAR2(100)
      ,cdorgins INTEGER
      ,nrbenefi NUMBER
      ,nrrecben NUMBER
      ,dtdcompe VARCHAR2(100)
      ,nmbenefi VARCHAR2(100)
      ,dtiniprd DATE
      ,dtfinprd DATE
      ,vlrbruto NUMBER
      ,vldescto NUMBER
      ,vlliquid NUMBER
      ,dscdamsg VARCHAR2(1000));

    --Tipo de Tabela de Rubricas
    TYPE typ_tab_demonstrativos IS TABLE OF typ_reg_demonstrativos INDEX BY PLS_INTEGER;

    --Tipo de Registros de beneficiario
    TYPE typ_reg_beneficiario IS RECORD --(b1wgen0091tt.i/tt-beneficiario) 
      (idbenefi INTEGER
      ,dtdcadas DATE                                    
      ,nmbenefi VARCHAR2(100)
      ,dtdnasci DATE
      ,tpdosexo VARCHAR2(100)
      ,dtutirec INTEGER
      ,dscsitua VARCHAR2(100)
      ,dtdvenci DATE
      ,dtcompvi DATE
      ,tpdpagto VARCHAR2(100)
      ,cdorgins INTEGER
      ,nomdamae VARCHAR2(100)
      ,nrdddtfc INTEGER
      ,nrtelefo INTEGER
      ,nrrecben NUMBER
      ,tpnrbene VARCHAR2(100)
      ,cdcooper INTEGER
      ,cdcopsic INTEGER
      ,nruniate INTEGER
      ,nrcepend INTEGER
      ,dsendere VARCHAR2(100)
      ,nrendere INTEGER
      ,nmbairro VARCHAR2(100)
      ,nmcidade VARCHAR2(100)
      ,cdufende VARCHAR2(100)
      ,nrcpfcgc VARCHAR2(100)
      ,resdesde DATE
      ,dscespec VARCHAR2(100)
      ,nrdconta VARCHAR2(100)
      ,digdacta VARCHAR2(100)
      ,nmprocur VARCHAR2(100)
      ,cdagesic INTEGER
      ,cdagepac INTEGER
      ,nrdocpro VARCHAR2(100)
      ,nmresage VARCHAR2(100)
      ,razaosoc VARCHAR2(100)
      ,nmextttl VARCHAR2(100)
      ,idseqttl INTEGER
      ,copvalid INTEGER
      ,nrcpfttl NUMBER
      ,dsendttl VARCHAR2(100)
      ,nrendttl INTEGER
      ,nrcepttl INTEGER
      ,nmbaittl VARCHAR2(100)
      ,nmcidttl VARCHAR2(100)
      ,ufendttl VARCHAR2(100)
      ,nrdddttl INTEGER
      ,nrtelttl INTEGER
      ,stacadas VARCHAR2(100));
    
    --Tipo de Registros para Log
    TYPE typ_reg_log IS RECORD
      (dtmvtolt VARCHAR2(10)
      ,hrmvtolt VARCHAR2(10)
      ,nrdconta VARCHAR2(10)
      ,nmdconta VARCHAR2(100)
      ,nrrecben VARCHAR2(20)
      ,historic VARCHAR2(200)
      ,operador VARCHAR2(20));
    
    --Tipo de Tabela de Beneficiario
    TYPE typ_tab_beneficiario IS TABLE OF typ_reg_beneficiario INDEX BY PLS_INTEGER;
    
    -- Tipos para registro de Agencia
    TYPE typ_cdagenci IS TABLE OF crapage.cdagenci%type INDEX BY PLS_INTEGER;

    TYPE typ_reg_crapage IS RECORD (tab_agenc typ_cdagenci);

    TYPE typ_tab_crapage IS TABLE OF typ_reg_crapage INDEX BY PLS_INTEGER;
        
    --Tipo de Tabela para Diretorio Salvar
    TYPE typ_tab_salvar IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
        
    --Tipo de Tabela de Agencias Sicredi
    TYPE typ_tab_cdagesic IS TABLE OF crapcop.cdcooper%type INDEX BY PLS_INTEGER;
        
    --Tipo de Tabela de Datas
    TYPE typ_tab_crapdat IS TABLE OF DATE INDEX BY PLS_INTEGER;
      
    --Tipo de Tabela de Log
    TYPE typ_tab_log IS TABLE OF typ_reg_log INDEX BY PLS_INTEGER;
      
	  TYPE typ_reg_dcb IS RECORD
		  (nmemissor      tbinss_dcb.nmemissor%TYPE
			,nrcnpj_emissor tbinss_dcb.nrcnpj_emissor%TYPE
			,nmbenefi       tbinss_dcb.nmbenefi%TYPE
			,dtcompet       tbinss_dcb.dtcompet%TYPE
			,nrrecben       tbinss_dcb.nrrecben%TYPE
			,nrnitins       tbinss_dcb.nrnitins%TYPE
			,cdorgins       tbinss_dcb.cdorgins%TYPE
			,vlliquido      tbinss_dcb.vlliquido%TYPE
			,nmrescop       crapcop.nmrescop%TYPE
			,cdrubric       tbinss_rubrica.cdrubric%TYPE
			,dsrubric       tbinss_rubrica.dsrubric%TYPE
			,vlrubric       tbinss_landcb.vlrubric%TYPE
			,dsnatureza     tbinss_rubrica.dsnatureza%TYPE);
			
    --Tipo de Tabela de Beneficiario
    TYPE typ_tab_dcb IS TABLE OF typ_reg_dcb INDEX BY PLS_INTEGER;

   /*Procedimento para gerar lote e lancamento, para gerar credito em conta*/
   procedure pc_gera_credito_em_conta ( pr_cdcooper in number,   -- Codigo Cooperativa
                                        pr_cdoperad in varchar2, -- Codigo do operador
                                        pr_cdprogra in varchar2, -- Codigo do programa que esta chamando o procedimento
                                        pr_dtmvtolt in date,     -- Data do movimento
                                        pr_dtdehoje in date,     -- Data atual
                                        pr_nrdrowid in rowid,    -- Numero do rowid do  Lancamento de credito de beneficios do INSS
                                        pr_cdcritic out number,  -- Retorno do codigo da critica
                                        pr_dscritic out varchar2 -- Retorno da descricao da critica
                                      );

   /*Procedimento para gerar lote e lancamento, para gerar transferencia de beneficio*/
   procedure pc_transfere_beneficio ( pr_cdcooper in number,    -- Codigo Cooperativa
                                      pr_cdoperad in varchar2,  -- Codigo do operador
                                      pr_cdprogra in varchar2,  -- Codigo do programa que esta chamando o procedimento
                                      pr_nrdconta in crapass.nrdconta%type, -- Numero da conta para a geracao do lancamento de transferencia
                                      pr_cdhistor in craplcm.cdhistor%type, -- Codigo do historico para o lancamento de transferencia
                                      pr_nrdolote in craplot.nrdolote%type, -- Numero do lote para o lancamento de transferencia
                                      pr_dtmvtolt in date,      -- Data do movimento
                                      pr_dtdehoje in date,      -- Data atual
                                      pr_nrdrowid in rowid,     -- Numero do rowid do  Lancamento de credito de beneficios do INSS
                                      pr_cdcritic out number,   -- Retorno do codigo da critica
                                      pr_dscritic out varchar2  -- Retorno da descricao da critica
                                     );
  
  /* Procedimento para retornar os beneficios do inss */ 
  PROCEDURE pc_beneficios_inss (pr_cdcooper IN crapcop.cdcooper %type --> Cooperativa desejada
                               ,pr_cdageini IN PLS_INTEGER            --> Agência inicial
                               ,pr_cdagefim IN PLS_INTEGER            --> Agência final
                               ,pr_dataini  IN DATE                   --> Data base inicial
                               ,pr_datafim  IN DATE                   --> Data base final
                               ,pr_geralcre OUT NUMBER                --> Qtde geral credito disponibilizado Não Cooperado
                               ,pr_quantger OUT PLS_INTEGER           --> Qtde geral registros Não Cooperados
                               ,pr_geraldcc OUT NUMBER                --> Qtde geral credito disponibilizado Cooperados
                               ,pr_quantge2 OUT PLS_INTEGER           --> Qtde geral registros Cooperados
                               ,pr_valorger OUT NUMBER                --> Total credito disponibilizado
                               ,pr_geralpa  OUT PLS_INTEGER           --> Total registros
                               ,pr_arqvazio OUT PLS_INTEGER           --> Indicador arquivo vazio
                               ,pr_tab_result_inss OUT typ_tab_result_inss --> PLTable com os registros de retorno
                               ,pr_cdcritic OUT PLS_INTEGER                --> Código retorno erro
                               ,pr_dscritic OUT VARCHAR2);                 --> Descrição retorno erro
                                         
                                    
  --Procedimento que envia solicitacao ao SICREDI para mandar os creditos a serem efetuados                                               
  PROCEDURE pc_benef_inss_solic_cred(pr_cdcooper IN crapcop.cdcooper%type   --Cooperativa
                                    ,pr_idorigem IN INTEGER                 --Origem Processamento
                                    ,pr_cdoperad IN VARCHAR2                --Operador
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%type   --Data Movimento
                                    ,pr_nmdatela IN VARCHAR2                --Nome da tela
                                    ,pr_cdprogra IN crapprg.cdprogra%type   --Nome Programa 
                                    ,pr_des_reto OUT VARCHAR2               --Saida OK/NOK
                                    ,pr_cdcritic OUT INTEGER                --Codigo do Erro
                                    ,pr_dscritic OUT VARCHAR2);             --Descricao do Erro
                                       

  --Processar pagamentos beneficios do INSS
  PROCEDURE pc_benef_inss_proces_pagto (pr_cdcooper IN crapcop.cdcooper%type      --Cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%type      --Codigo Agencia
                                       ,pr_nrdcaixa IN INTEGER                    --Numero Caixa
                                       ,pr_idorigem IN INTEGER                    --Origem Processamento
                                       ,pr_cdoperad IN VARCHAR2                   --Operador
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%type      --Data Movimento
                                       ,pr_nmdatela IN VARCHAR2                   --Nome da tela
                                       ,pr_cdprogra IN crapprg.cdprogra%type      --Nome Programa 
                                       ,pr_des_reto OUT VARCHAR2                  --Saida OK/NOK
                                       ,pr_tab_erro OUT gene0001.typ_tab_erro);   --Tabela Erros
  
  /* Procedure para Eliminar  de Requisicao SOAP */
  PROCEDURE pc_elimina_arquivos_requis (pr_cdcooper IN crapcop.cdcooper%type --Codigo Cooperativa
                                       ,pr_cdprogra IN VARCHAR2              --Codigo Programa
                                       ,pr_msgenvio IN VARCHAR2              --Mensagem Envio
                                       ,pr_msgreceb IN VARCHAR2              --Mensagem Recebimento
                                       ,pr_movarqto IN VARCHAR2              --Nome Arquivo mover
                                       ,pr_nmarqlog IN VARCHAR2              --Nome Arquivo Log
                                       ,pr_des_reto OUT VARCHAR2             --Saida OK/NOK
                                       ,pr_dscritic OUT VARCHAR2);           --Descricao do Erro
  
  /* Procedure para gerar o cabecalho Soap */
  PROCEDURE pc_gera_cabecalho_soap (pr_idservic IN INTEGER             --Tipo do Servico
                                   ,pr_nmmetodo IN VARCHAR2            --Nome do Método
                                   ,pr_username IN VARCHAR2            --Username
                                   ,pr_password IN VARCHAR2            --Senha
                                   ,pr_dstexto  IN OUT NOCOPY VARCHAR2 --Arquivo Dados
                                   ,pr_des_reto OUT VARCHAR2           --Retorno OK/NOK
                                   ,pr_dscritic OUT VARCHAR2);         --Descricao da Critica
  
  /* Procedure para Solicitar Requisicao SOAP */
  PROCEDURE pc_efetua_requisicao_soap  (pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                       ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                       ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                       ,pr_idservic IN INTEGER                 --Identificador Servico
                                       ,pr_dsservic IN VARCHAR2                --Descricao Servico
                                       ,pr_nmmetodo IN VARCHAR2                --Nome Método
                                       ,pr_dstexto  IN VARCHAR2                --Texto com a msg XML
                                       ,pr_msgenvio IN VARCHAR2                --Mensagem Envio
                                       ,pr_msgreceb IN VARCHAR2                --Mensagem Recebimento
                                       ,pr_movarqto IN VARCHAR2                --Nome Arquivo mover
                                       ,pr_nmarqlog IN VARCHAR2                --Nome Arquivo LOG
                                       ,pr_nmdatela IN VARCHAR2                --Nome da Tela
                                       ,pr_des_reto OUT VARCHAR2               --Saida OK/NOK
                                       ,pr_dscritic OUT VARCHAR2);             --Descrição Erro
                                       
  /* Procedure para Solicitar Requisicao SOAP */
  PROCEDURE pc_obtem_fault_packet  (pr_cdcooper IN crapcop.cdcooper%type --Codigo Cooperativa 
                                   ,pr_nmdatela IN VARCHAR2              --Nome da Tela
                                   ,pr_cdagenci IN crapage.cdagenci%type --Codigo Agencia
                                   ,pr_nrdcaixa IN INTEGER               --Numero Caixa
                                   ,pr_dsderror IN VARCHAR2              --Descricao Erro
                                   ,pr_msgenvio IN VARCHAR2              --Mensagem Envio
                                   ,pr_msgreceb IN VARCHAR2              --Mensagem Recebimento
                                   ,pr_movarqto IN VARCHAR2              --Nome Arquivo mover
                                   ,pr_nmarqlog IN VARCHAR2              --Nome Arquivo LOG
                                   ,pr_des_reto OUT VARCHAR2             --Saida OK/NOK
                                   ,pr_dscritic OUT VARCHAR2);           --Descricao Erro
  
  --Funcao para Substituir Caracteres Especiais do XML
  FUNCTION fn_substitui_caracter (pr_string IN VARCHAR2) RETURN VARCHAR2;                                         

  /* Procedure para Solicitar Relatorio Beneficios a Pagar ou Pagos */
  PROCEDURE pc_solic_rel_benef_web  (pr_dtmvtolt IN VARCHAR2                --Data Movimento DD/MM/YYYY
                                    ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                    ,pr_cdagesel IN INTEGER                 --Codigo Agencia Selecionada
                                    ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                    ,pr_tpnrbene IN VARCHAR2                --Tipo Numero Beneficiario
                                    ,pr_dtinirec IN VARCHAR2                --Data Inicio Recebimento DD/MM/YYYY
                                    ,pr_dtfinrec IN VARCHAR2                --Data Final Recebimento DD/MM/YYYY
                                    ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                    ,pr_tpconrel IN VARCHAR2                --Tipo Relatorio
                                    ,pr_idtiprel IN VARCHAR2                --PAGOS/PAGAR
                                    ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                    ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2);             --Saida OK/NOK


  /* Procedure para Solicitar Relatorio Historico cadastral */
  PROCEDURE pc_solic_rel_hist_cadastral (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                        ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                        ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                        ,pr_tpnrbene IN VARCHAR2                --Tipo Numero Beneficiario                                       
                                        ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                        ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                        ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                        ,pr_des_reto OUT VARCHAR2);             --Saida OK/NOK

                                       
  --Buscar Beneficiarios do INSS
  PROCEDURE pc_busca_crapdbi (pr_nrcpfcgc IN crapttl.nrcpfcgc%type      --Numero CPF ou CGC
                             ,pr_nrregist IN INTEGER                    --Numero Registros
                             ,pr_nriniseq IN INTEGER                    --Numero Sequencia Inicial
                             ,pr_xmllog   IN VARCHAR2                   --XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER               --Código da crítica
                             ,pr_dscritic OUT VARCHAR2                  --Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType         --Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                  --Nome do Campo
                             ,pr_des_erro OUT VARCHAR2);                --Saida OK/NOK

  --Buscar Codigo Identificador Orgao Pagador junto ao INSS
  PROCEDURE pc_busca_cdorgins (pr_dtmvtolt IN VARCHAR2                   --Data do Movimento
                              ,pr_nrdconta IN INTEGER                    --Numero da Conta
                              ,pr_xmllog   IN VARCHAR2                   --XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER               --Código da crítica
                              ,pr_dscritic OUT VARCHAR2                  --Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType         --Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                  --Nome do campo com erro                      
                              ,pr_des_erro OUT VARCHAR2);                --Identificar de Erro OK/NOK

  --Buscar Informações dos titulares
  PROCEDURE pc_busca_crapttl (pr_nrdconta IN crapass.nrdconta%type      --Numero da Conta
                             ,pr_nrregist IN INTEGER                    --Numero Registros
                             ,pr_nriniseq IN INTEGER                    --Numero Sequencia Inicial
                             ,pr_xmllog   IN VARCHAR2                   --XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER               --Código da crítica
                             ,pr_dscritic OUT VARCHAR2                  --Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType         --Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                  --Nome do Campo
                             ,pr_des_erro OUT VARCHAR2);                --Saida OK/NOK

  /* Procedure para Solicitar Troca de Domicilio */
  PROCEDURE pc_solic_troca_domicilio  (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                      ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                      ,pr_cdorgins IN INTEGER                 --Codigo Orgao Pagador
                                      ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                      ,pr_tpbenefi IN VARCHAR2                --Tipo Beneficio
                                      ,pr_tpdpagto IN VARCHAR2                --Tipo de Pagamento
                                      ,pr_nrdconta IN INTEGER                 --Numero da Conta
                                      ,pr_cdagepac IN INTEGER                 --Codigo Agencia 
                                      ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                      ,pr_idseqttl IN INTEGER                 --Sequencial Titular
                                      ,pr_nmbairro IN VARCHAR2                --Nome do Bairro
                                      ,pr_nrcepend IN INTEGER                 --Numero CEP
                                      ,pr_dsendres IN VARCHAR2                --Descricao Endereco Residencial
                                      ,pr_nrendere IN INTEGER                 --Numero Endereco
                                      ,pr_nmcidade IN VARCHAR2                --Nome Cidade
                                      ,pr_cdufdttl IN VARCHAR2                --Codigo UF Titular
                                      ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                      ,pr_nmextttl IN VARCHAR2                --Nome Extrato Titular
                                      ,pr_nmmaettl IN VARCHAR2                --Nome Mae Titular
                                      ,pr_nrdddtfc IN INTEGER                 --Numero DDD
                                      ,pr_nrtelefo IN INTEGER                 --Numero Telefone
                                      ,pr_cdsexotl IN INTEGER                 --Sexo
                                      ,pr_dtnasttl IN VARCHAR2                --Data nascimento
                                      ,pr_dscsitua IN VARCHAR2                --Descricao Situacao
                                      ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                      ,pr_flgerlog IN INTEGER                 --Escrever Erro no Log (0=nao, 1=sim)
                                      ,pr_temsenha IN VARCHAR                 --Verifica se tem senha da internet ativa
                                      ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                      ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2);             --Saida OK/NOK

  /* Procedure para Solicitar Demonstrativo de beneficio */
  PROCEDURE pc_solicita_demonstrativo  (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                       ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                       ,pr_nrdconta IN INTEGER                 --Numero da Conta
                                       ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                       ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio                                                                            
                                       ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                       ,pr_dtvalida IN VARCHAR2                --Data Validade
                                       ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                       ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);             --Saida OK/NOK

  /* Procedure para Solicitar Comprovacao de Vida */
  PROCEDURE pc_solic_comprovacao_vida  (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                       ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                       ,pr_nrdconta IN INTEGER                 --Numero da Conta
                                       ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                       ,pr_nmextttl IN VARCHAR2                --Nome Titular
                                       ,pr_idseqttl IN INTEGER                 --Sequencial do Titular
                                       ,pr_cdorgins IN INTEGER                 --Codigo Orgao Pagamento
                                       ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio                                                                            
                                       ,pr_tpnrbene IN VARCHAR2                --Tipo Beneficio
                                       ,pr_cdagepac IN INTEGER                 --Codigo Agencia 
                                       ,pr_idbenefi IN INTEGER                 --Identificador Beneficio
                                       ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                       ,pr_respreno IN VARCHAR2                --Responsavel Renovacao
                                       ,pr_nmprocur IN VARCHAR2                --Nome Procurador
                                       ,pr_nrdocpro IN VARCHAR2                --Numero Documento Procurador
                                       ,pr_dtvalprc IN VARCHAR2                --Data Validade Procurador
                                       ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                       ,pr_flgerlog IN INTEGER                 --Escrever Erro no Log
                                       ,pr_temsenha IN VARCHAR                 --Verifica se tem senha da internet ativa
                                       ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);             --Saida OK/NOK

  /* Procedure para Solicitar Relatorio beneficios Rejeitados */
  PROCEDURE pc_relat_benef_rejeitados  (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                       ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                       ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);             --Saida OK/NOK

  /* Procedure para Solicitar Troca orgao Pagador e/ou Conta Corrente entre Cooperativas */
  PROCEDURE pc_solic_troca_op_cc_coop (pr_dtmvtolt IN VARCHAR2               --Data Movimento
                                      ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                      ,pr_cdcopant IN INTEGER                 --Codigo Cooperativa Anterior
                                      ,pr_cdorgins IN INTEGER                 --Codigo Orgao Pagador
                                      ,pr_orgpgant IN INTEGER                 --Codigo Orgao Pagador Anterior
                                      ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                      ,pr_tpnrbene IN VARCHAR2                --Tipo Beneficio
                                      ,pr_tpdpagto IN VARCHAR2                --Tipo de Pagamento
                                      ,pr_dscsitua IN VARCHAR2                --Descricao da Situacao
                                      ,pr_nrdconta IN INTEGER                 --Numero da Conta
                                      ,pr_nrctaant IN INTEGER                 --Numero da Conta Anterior                                      
                                      ,pr_cdagepac IN INTEGER                 --Codigo Agencia 
                                      ,pr_idbenefi IN INTEGER                 --Identificador do Beneficio
                                      ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                      ,pr_nrcpfant IN NUMBER                  --Numero CPF/CNPJ Anterior
                                      ,pr_idseqttl IN INTEGER                 --Sequencial Titular
                                      ,pr_nmbairro IN VARCHAR2                --Nome do Bairro
                                      ,pr_nrcepend IN INTEGER                 --Numero CEP
                                      ,pr_dsendere IN VARCHAR2                --Descricao Endereco Residencial
                                      ,pr_nrendere IN INTEGER                 --Numero Endereco
                                      ,pr_nmcidade IN VARCHAR2                --Nome Cidade
                                      ,pr_cdufende IN VARCHAR2                --Codigo UF Titular
                                      ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                      ,pr_nmbenefi IN VARCHAR2                --Nome Beneficiario
                                      ,pr_dtcompvi IN VARCHAR2                --Data Comprovacao Vida
                                      ,pr_nrdddtfc IN INTEGER                 --Numero DDD
                                      ,pr_nrtelefo IN INTEGER                 --Numero Telefone
                                      ,pr_cdsexotl IN INTEGER                 --Sexo
                                      ,pr_nomdamae IN VARCHAR2                --Nome Da Mae
                                      ,pr_flgerlog IN INTEGER                 --Escrever Erro no Log (0=nao, 1=sim)
                                      ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                      ,pr_temsenha IN VARCHAR                 --Verifica se tem senha da internet ativa
                                      ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                      ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2);             --Saida OK/NOK

  /* Procedure para Solicitar Troca orgao Pagador e/ou Conta Corrente - Modo Caracter */
  PROCEDURE pc_solic_troca_op_cc_car (pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                     ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                     ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                     ,pr_idorigem IN INTEGER                 --Origem Processamentopr_dtmvtolt IN VARCHAR2                --Data Movimento
                                     ,pr_nmdatela IN VARCHAR2                --Nome da tela
                                     ,pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                     ,pr_cdoperad IN VARCHAR2                --Operador
                                     ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                     ,pr_cdorgins IN INTEGER                 --Codigo Orgao Pagador
                                     ,pr_orgpgant IN INTEGER                 --Codigo Orgao Pagador Anterior
                                     ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                     ,pr_tpnrbene IN VARCHAR2                --Tipo Beneficio
                                     ,pr_tpdpagto IN VARCHAR2                --Tipo de Pagamento
                                     ,pr_dscsitua IN VARCHAR2                --Descricao da Situacao
                                     ,pr_nrdconta IN INTEGER                 --Numero da Conta
                                     ,pr_nrctaant IN INTEGER                 --Numero da Conta Anterior                                      
                                     ,pr_cdagepac IN INTEGER                 --Codigo Agencia 
                                     ,pr_idbenefi IN INTEGER                 --Identificador do Beneficio
                                     ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                     ,pr_nrcpfant IN NUMBER                  --Numero CPF/CNPJ Anterior
                                     ,pr_idseqttl IN INTEGER                 --Sequencial Titular
                                     ,pr_nmbairro IN VARCHAR2                --Nome do Bairro
                                     ,pr_nrcepend IN INTEGER                 --Numero CEP
                                     ,pr_dsendere IN VARCHAR2                --Descricao Endereco Residencial
                                     ,pr_nrendere IN INTEGER                 --Numero Endereco
                                     ,pr_nmcidade IN VARCHAR2                --Nome Cidade
                                     ,pr_cdufende IN VARCHAR2                --Codigo UF Titular
                                     ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                     ,pr_nmbenefi IN VARCHAR2                --Nome Beneficiario
                                     ,pr_dtcompvi IN VARCHAR2                    --Data Comprovacao Vida
                                     ,pr_nrdddtfc IN INTEGER                 --Numero DDD
                                     ,pr_nrtelefo IN INTEGER                 --Numero Telefone
                                     ,pr_cdsexotl IN INTEGER                 --Sexo
                                     ,pr_nomdamae IN VARCHAR2                --Nome Da Mae
                                     ,pr_flgerlog IN INTEGER                 --Escrever Erro no Log (0=nao, 1=sim)
                                     ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                     ,pr_nmarqimp OUT VARCHAR2               --Nome Arquivo Impressao
                                     ,pr_nmarqpdf OUT VARCHAR2               --Nome Arquivo pdf
                                     ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                     ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                     ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);             --Saida OK/NOK

  /* Procedure para Solicitar Troca orgao Pagador e/ou Conta Corrente */
  PROCEDURE pc_solic_troca_op_cc_web (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                     ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                     ,pr_cdorgins IN INTEGER                 --Codigo Orgao Pagador
                                     ,pr_orgpgant IN INTEGER                 --Codigo Orgao Pagador Anterior
                                     ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                     ,pr_tpnrbene IN VARCHAR2                --Tipo Beneficio
                                     ,pr_tpdpagto IN VARCHAR2                --Tipo de Pagamento
                                     ,pr_dscsitua IN VARCHAR2                --Descricao da Situacao
                                     ,pr_nrdconta IN INTEGER                 --Numero da Conta
                                     ,pr_nrctaant IN INTEGER                 --Numero da Conta Anterior                                      
                                     ,pr_cdagepac IN INTEGER                 --Codigo Agencia 
                                     ,pr_idbenefi IN INTEGER                 --Identificador do Beneficio
                                     ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                     ,pr_nrcpfant IN NUMBER                  --Numero CPF/CNPJ Anterior
                                     ,pr_idseqttl IN INTEGER                 --Sequencial Titular
                                     ,pr_nmbairro IN VARCHAR2                --Nome do Bairro
                                     ,pr_nrcepend IN INTEGER                 --Numero CEP
                                     ,pr_dsendere IN VARCHAR2                --Descricao Endereco Residencial
                                     ,pr_nrendere IN INTEGER                 --Numero Endereco
                                     ,pr_nmcidade IN VARCHAR2                --Nome Cidade
                                     ,pr_cdufende IN VARCHAR2                --Codigo UF Titular
                                     ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                     ,pr_nmbenefi IN VARCHAR2                --Nome Beneficiario
                                     ,pr_dtcompvi IN VARCHAR2                    --Data Comprovacao Vida
                                     ,pr_nrdddtfc IN INTEGER                 --Numero DDD
                                     ,pr_nrtelefo IN INTEGER                 --Numero Telefone
                                     ,pr_cdsexotl IN INTEGER                 --Sexo
                                     ,pr_nomdamae IN VARCHAR2                --Nome Da Mae
                                     ,pr_flgerlog IN INTEGER                 --Escrever Erro no Log (0=nao, 1=sim)
                                     ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                     ,pr_temsenha IN VARCHAR                 --Verifica se tem senha da internet ativa
                                     ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                     ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);             --Saida OK/NOK

/* Procedure para Solicitar Alteracao Cadastral do beneficiario Modo WEB */
  PROCEDURE pc_solic_alt_cad_benef (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                   ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                   ,pr_cdorgins IN INTEGER                 --Codigo Orgao Pagador
                                   ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                   ,pr_tpnrbene IN VARCHAR2                --Tipo Beneficio
                                   ,pr_tpdpagto IN VARCHAR2                --Tipo de Pagamento
                                   ,pr_dscsitua IN VARCHAR2                --Descricao da Situacao
                                   ,pr_nrdconta IN INTEGER                 --Numero da Conta
                                   ,pr_cdagepac IN INTEGER                 --Codigo Agencia 
                                   ,pr_idbenefi IN INTEGER                 --Identificador do Beneficio
                                   ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                   ,pr_idseqttl IN INTEGER                 --Sequencial Titular
                                   ,pr_nmbairro IN VARCHAR2                --Nome do Bairro
                                   ,pr_nrcepend IN INTEGER                 --Numero CEP
                                   ,pr_dsendere IN VARCHAR2                --Descricao Endereco Residencial
                                   ,pr_nrendere IN INTEGER                 --Numero Endereco
                                   ,pr_nmcidade IN VARCHAR2                --Nome Cidade
                                   ,pr_cdufende IN VARCHAR2                --Codigo UF Titular
                                   ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                   ,pr_nmbenefi IN VARCHAR2                --Nome Beneficiario
                                   ,pr_dtcompvi IN VARCHAR2                --Data Comprovacao Vida
                                   ,pr_nrdddtfc IN INTEGER                 --Numero DDD
                                   ,pr_nrtelefo IN INTEGER                 --Numero Telefone
                                   ,pr_tpdosexo IN VARCHAR2                --Sexo
                                   ,pr_nomdamae IN VARCHAR2                --Nome Da Mae
                                   ,pr_flgerlog IN INTEGER                 --Escrever Erro no Log (0=nao, 1=sim)
                                   ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                   ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER            --Codigo Erro
                                   ,pr_dscritic OUT VARCHAR2               --Descricao Erro
                                   ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2);             --Saida OK/NOK
                                   

  /* Procedure para Solicitar Consulta dos Dados do beneficiario Modo Caracter */
  PROCEDURE pc_solic_consulta_benef_car (pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                        ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                        ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                        ,pr_idorigem IN INTEGER                 --Origem Processamento
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%type   --Data Movimento
                                        ,pr_nmdatela IN VARCHAR2                --Nome da tela
                                        ,pr_cdoperad IN VARCHAR2                --Operador
                                        ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                        ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                        ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                        ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2               --Saida OK/NOK
                                        ,pr_clob_ret OUT CLOB                   --Tabela Beneficiarios
                                        ,pr_cdcritic OUT PLS_INTEGER            --Codigo Erro
                                        ,pr_dscritic OUT VARCHAR2);             --Descricao Erro

  /* Procedure para Solicitar Consulta dos Dados do beneficiario Modo Web */
  PROCEDURE pc_solic_consulta_benef_web (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                        ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                        ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                        ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                        ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                        ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2);             --Saida OK/NOK

  /* Procedure para Solicitar Relatorio Beneficios Pagos */
  PROCEDURE pc_solic_rel_benef_pagos  (pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                      ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                      ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                      ,pr_idorigem IN INTEGER                 --Origem Processamento
                                      ,pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                      ,pr_nmdatela IN VARCHAR2                --Nome da tela
                                      ,pr_cdoperad IN VARCHAR2                --Operador
                                      ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                      ,pr_cdagesel IN INTEGER                 --Codigo Agencia Selecionada
                                      ,pr_cdorgins IN INTEGER                 --Codigo do orgão pagador INSS-SICREDI
                                      ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                      ,pr_tpnrbene IN VARCHAR2                --Tipo Numero Beneficiario
                                      ,pr_dtinirec IN VARCHAR2                --Data Inicio Recebimento
                                      ,pr_dtfinrec IN VARCHAR2                --Data Final Recebimento
                                      ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                      ,pr_tpconrel IN VARCHAR2                --Tipo Relatorio
                                      ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                      ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                      ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2);             --Saida OK/NOK

  /* Procedure para Solicitar Relatorio Beneficios a Pagar */
  PROCEDURE pc_solic_rel_benef_pagar  (pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                      ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                      ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                      ,pr_idorigem IN INTEGER                 --Origem Processamento
                                      ,pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                      ,pr_dtinirec IN VARCHAR2                --Data Inicio Recebimento
                                      ,pr_dtfinrec IN VARCHAR2                --Data Final Recebimento
                                      ,pr_nmdatela IN VARCHAR2                --Nome da tela
                                      ,pr_cdoperad IN VARCHAR2                --Operador
                                      ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                      ,pr_cdagesel IN INTEGER                 --Codigo Agencia Selecionada
                                      ,pr_cdorgins IN INTEGER                 --Codigo orgao pagador INSS-SICREDI
                                      ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                      ,pr_tpnrbene IN VARCHAR2                --Tipo Numero Beneficiario
                                      ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                      ,pr_tpconrel IN VARCHAR2                --Tipo Relatorio
                                      ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                      ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                      ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2);             --Saida OK/NOK

  --Procedure para enviar requisicao beneficios ao MQSeries
  PROCEDURE pc_submete_requis_mq_batch  (pr_cdcooper IN crapcop.cdcooper%type    --Codigo Cooperativa
                                        ,pr_cdprogra IN VARCHAR2                 --Nome Programa
                                        ,pr_dstexto  IN VARCHAR2                 --Texto do arquivo 
                                        ,pr_pathcoop IN VARCHAR2                 --Diretorio Padrao da Cooperativa
                                        ,pr_arqenvio IN VARCHAR2                 --Nome Arquivo Envio
                                        ,pr_dsmensag IN VARCHAR2                 --Descricao Mensagem
                                        ,pr_nmarqlog IN VARCHAR2);               --Nome Arquivo Log


  --Buscar relatorios solicitados
  PROCEDURE pc_busca_rel_solicitados (pr_dsiduser IN VARCHAR2            --Id do usuario
                                     ,pr_nrregist IN INTEGER             --Numero Registros
                                     ,pr_nriniseq IN INTEGER             --Numero Sequencia Inicial
                                     ,pr_idtiprel IN VARCHAR2            --Tipo do Relatorio PAGOS/PAGAR
                                     ,pr_xmllog   IN VARCHAR2            --XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER        --Código da crítica
                                     ,pr_dscritic OUT VARCHAR2           --Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType  --Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2           --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);         --Saida OK/NOK
                                     
  -- Verifica se beneficiario esta com a prova de vida vencida
	FUNCTION fn_verifica_renovacao_vida(pr_cdcooper IN tbinss_dcb.cdcooper%TYPE -- Cooperativa
																		 ,pr_dtmvtolt IN tbinss_dcb.dtvencpv%TYPE -- Data de movimento
																		 ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE DEFAULT 0 -- Nr. da Conta
																		 ,pr_nrrecben IN tbinss_dcb.nrrecben%TYPE DEFAULT 0 -- NB
																		 ) RETURN INTEGER;
																		 
                                     
  --Processar a planilha de pagamentos do INSS 
  PROCEDURE pc_exec_pagto_benef_plani (pr_cdcooper  IN INTEGER    -- Codigo da Cooperativa
                                      ,pr_nmarquiv  IN VARCHAR2   -- Nome do Arquivo
                                      ,pr_nrdcaixa  IN INTEGER    -- Numero do Caixa
                                      ,pr_cdprogra  IN VARCHAR2   -- Codigo do programa que esta chamando o procedimento
                                      ,pr_qtplanil OUT INTEGER    -- Quantidade de registros na planilha
                                      ,pr_vltotpla OUT NUMBER     -- Valor Total Planilha
                                      ,pr_qtproces OUT INTEGER    -- Quantidade processada
                                      ,pr_vltotpro OUT NUMBER     -- Valor Total Processado
                                      ,pr_qtderros OUT INTEGER    -- Quantidade de Erros
                                      ,pr_vlderros OUT NUMBER     -- Valor total de erros
                                      ,pr_nmarqerr OUT VARCHAR2   -- Nome do arquivo de erros
                                      ,pr_dscritic OUT VARCHAR2); -- Descricao do Erro
  
  /* Procedure para Solicitar Consulta dos Dados do beneficiario */
  PROCEDURE pc_solic_consulta_benef (pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                    ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                    ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                    ,pr_idorigem IN INTEGER                 --Origem Processamento
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%type   --Data Movimento
                                    ,pr_nmdatela IN VARCHAR2                --Nome da tela
                                    ,pr_cdoperad IN VARCHAR2                --Operador
                                    ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                    ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                    ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                    ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2               --Saida OK/NOK
                                    ,pr_tab_beneficiario OUT inss0001.typ_tab_beneficiario --Tabela Beneficiarios
                                    ,pr_tab_erro  OUT gene0001.typ_tab_erro); --Tabela Erros
                                    
  /*****************************************************************************/
  /**  funcao para encontrar alguma restricao referente a comprovacao de vida **/ 
  /*****************************************************************************/
  FUNCTION fn_bloqueio_inss ( pr_cdcopben IN craplbi.cdcooper%TYPE  --> Codigo do operador
                             ,pr_nrrecben IN craplbi.nrrecben%TYPE  --> Numero de identificacao do recebedor do beneficio.(ID-NIT)
                             ,pr_nrbenefi IN craplbi.nrbenefi%TYPE  --> Numero identificador do beneficio.(NU-NB)
                             ,pr_dtcompvi IN craplbi.dtfimpag%TYPE  --> Data de comprovacao
                             ,pr_dtdmovto IN craplbi.dtfimpag%TYPE  --> Cdate de movimento
                            )RETURN INTEGER; --> Retorna tipo de bloquei (tpbloque)
  
  /*****************************************************************************/
  /**                 funcao verificar bloquieo INSS                          **/ 
  /*****************************************************************************/
  FUNCTION fn_verifica_bloqueio_inss ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nmdatela IN VARCHAR2               --> Nome da tela
                                      ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                      ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE  --> CPF/CNPJ do cooperado
                                      ,pr_nrprocur IN crapcbi.nrbenefi%TYPE  --> Numero do beneficio a ser procurado
                                      ,pr_tpdconsu IN INTEGER                --> Tipo de consulta
                            )RETURN INTEGER;   --> Retorna tipo de bloqueio (tpbloque)                                                                 
                                
  -- Obtem situacao da senha do Tele-Atendimento
  PROCEDURE pc_verifica_situacao_senha (pr_nrdconta IN crapass.nrdconta%TYPE --Numero da conta do beneficiario
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE --Numero do beneficiario
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
 
  -- Consultar log de INSS
  PROCEDURE pc_consulta_log (pr_dtmvtlog IN VARCHAR2            --Data dos registros no log
                            ,pr_nrdnblog IN VARCHAR2            --Numero do beneficiario
                            ,pr_nrdctlog IN VARCHAR2            --Numero da conta do beneficiario
                            ,pr_nriniseq IN VARCHAR2            --Numero do primeiro registro a ser retornado
                            ,pr_qtregist IN VARCHAR2            --Numero de registros a serem retornados
                            ,pr_xmllog   IN VARCHAR2            --XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER        --Código da crítica
                            ,pr_dscritic OUT VARCHAR2           --Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType  --Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2           --Nome do Campo
                            ,pr_des_erro OUT VARCHAR2);         --Saida OK/NOK
  
  PROCEDURE pc_envia_msg_venc_pv (pr_cdcritic OUT PLS_INTEGER --Código da crítica
                                 ,pr_dscritic OUT VARCHAR2);  --Descrição da crítica           
  
  --Funcao para buscar senha da sicredi
  FUNCTION fn_senha_sicredi RETURN VARCHAR2;
  
	-- Procedure para alimentar a tabela de beneficiarios do inss
  -- Belli 12/06/2017 Chamado 660327 eliminada a rotina pc_popula_dcb_inss
	
		-- Buscar dados do beneficiário													
  PROCEDURE pc_carrega_dados_beneficio(pr_cdcooper IN tbinss_dcb.cdcooper%TYPE            --> Cooperativa
		                                  ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE DEFAULT 0  --> Nr. da Conta
																			,pr_nrrecben IN tbinss_dcb.nrrecben%TYPE DEFAULT 0  --> Nr. beneficiario
																			,pr_dtmescom IN VARCHAR DEFAULT ' '                 --> Mês de competência
																			,pr_tab_dcb  OUT typ_tab_dcb                        --> Pltable com dados do beneficiario
																			,pr_cdcritic OUT INTEGER                            --> Cód. da crítica
																			,pr_dscritic OUT VARCHAR2);                         --> Desc. da crític														
																			
  -- Buscar dados do beneficiário  caracter
	PROCEDURE pc_carrega_dados_beneficio_car (pr_cdcooper IN tbinss_dcb.cdcooper%TYPE            --> Cooperativa
																					 ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE DEFAULT 0  --> Nr. da Conta
																					 ,pr_nrrecben IN tbinss_dcb.nrrecben%TYPE DEFAULT 0  --> Nr. beneficiario
																			     ,pr_dtmescom IN VARCHAR DEFAULT ' '                 --> Mês de competência
																					 ,pr_clobxmlc OUT CLOB                               --> Clob com dados do beneficiario
																					 ,pr_cdcritic OUT INTEGER                            --> Cód. da crítica
																					 ,pr_dscritic OUT VARCHAR2);                         --> Desc. da crítica																			

  PROCEDURE pc_busca_demonst_sicredi (pr_cdcooper IN crapcop.cdcooper%TYPE
                                     ,pr_nrdconta IN crapcop.nrdconta%TYPE
                                     ,pr_cdagesic IN crapcop.cdagesic%TYPE
                                     ,pr_dtextrat IN DATE
                                     ,pr_cdcritic OUT INTEGER                            --> Cód. da crítica
                                     ,pr_dscritic OUT VARCHAR2);

  -- Buscar demonstrativo do beneficiario
	PROCEDURE pc_carrega_demonst_benef(pr_cdcooper IN tbinss_dcb.cdcooper%TYPE            --> Cooperativa
		                                ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE DEFAULT 0  --> Nr. da Conta
																		,pr_nrrecben IN tbinss_dcb.nrrecben%TYPE DEFAULT 0  --> Nr. beneficiario
																		,pr_dtmescom IN VARCHAR2 DEFAULT ' '                --> Mês de competência
                                    ,pr_clobxmlc OUT CLOB                               --> Clob com dados do beneficiario
																		,pr_cdcritic OUT INTEGER                            --> Cód. da crítica
																		,pr_dscritic OUT VARCHAR2);                         --> Desc. da crítica
	
end INSS0001;
/
create or replace package body cecred.INSS0001 as

  /*---------------------------------------------------------------------------------------------------------------
   Programa: INSS0001
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Odirlei Busana(AMcom)
   Data    : 27/08/2013                        Ultima atualizacao: 07/08/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : BO - Alteracao de Domicilio Bancario

   Alteracoes: 04/02/2013 - Conversao Progress >> Oracle (PLSQL) (Odirlei-AMcom)
   
               22/09/2015 - Adicionado validação no valor dos campos das procedures:
                                - pc_solic_troca_domicilio
                                - pc_solic_comprovacao_vida
                                - pc_solic_troca_op_cc_coop
                                - pc_solic_troca_op_cc
                                - pc_solic_alt_cad_benef
                          - Alterado nomenclatura dos arquivos das procedures:
                                - pc_solic_troca_domicilio
                                - pc_solicita_demonstrativo
                                - pc_solic_comprovacao_vida
                                - pc_solic_troca_op_cc_coop
                                - pc_solic_troca_op_cc
                                - pc_solic_alt_cad_benef
                                - pc_solic_consulta_benef
                           (Douglas - Chamado 314031)
               15/10/2015 - Alterado forma de leitura do xml SD313261 (Odirlei-AMcom):
                               - pc_benef_inss_proces_pagto 
                               - pc_solic_consulta_benef           
                               
               13/11/2015 - Adicionado o comando UPPER na comparacao do 'cdoperad' nos
                            cursores da tabela 'crapope' (Tiago SD339476)
                            
               10/02/2016 - Realizado ajuste para pegar o código da cooperativa correto quando
                            não for encontrado o OP do beneficio em questão
                            (Adriano - SD 398214).   
                            
               10/02/2016 - Ajuste para que, quando for realizado a troca de domicilio para um 
                            cooperado que esteja demitido por demissao, não seja permitido
                            realizar a troca
                            (Adriano - SD 398671).
                            
               16/02/2016  - Ajuste na rotina pc_benef_inss_ret_webservc para tratar corretamente
                             o retorno enviado pelo SICREDI
                             (Adriano - SD 402006).              
               
               24/02/2016 - Ajustes realizados:
                            -> Mover os arquivos de request/response para o diretório salvar
                               em caso de algum erro na rotina
                            -> Pegar senha parametrizada no sistema 
                            (Adriano).    
               
               29/02/2016 - Ajuste para passar o pr_nmdatela no lugar do pr_cdprogra
                            ao chamar a rotina que trata o retorno do web service, para
                            gravar no log o nome da tela corretamente
                            (Adriano - SD 409943).  
                            
               09/03/2016 - feita a troca na geração do log que gerava no batch para o message conforme 
                            solicitado no chamado 396313. (Kelvin)                      
                             
			   10/03/2016 - Ajuste para pegar o código da agencia corretamente
                           (Adriano).				            

               12/05/2016 - Ajustado fn_verifica_renovacao_vida para remover o OR do numero da conta
                            do cursor cr_verifica. Todas as chamadas para essa procedure passam o
                            numero da conta (Douglas - Chamado 451221)
               
			   07/06/2016 - Melhoria 195 folha de pagamento (Tiago/Thiago)             
                            
               21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                           (Adriano - SD 473539).             
                            
               22/12/2016 - Ajuste para gerar relatório com data de movimento da cooperativa
                            em questão e para postar na intranet no dia correto
                            (Adriano - SD 567303).
                              
               13/02/2017 - #605926 Retirado o parametro pr_dsmailcop (pc_solicita_relato em 
                            pc_gera_relatorio_rejeic) pois o mesmo estava cadastrando o diretório 
                            rlnsv da cooperativa no lugar do e-mail, ocasionando erros nas tentativas
                            de envio do mesmo (Carlos)
               17/03/2017 - Ajuste para buscar na craplcm atraves do NB do beneficiario no 
                            campo cdpesqbb, também ajustado cursor cr_tbinss_dcb para listarmos
                            somente o registro mais antigo da tabela junto com o NB
                            na fn_verifica_renovacao_vida (Lucas Ranghetti #626129)
                            
               19/05/2017 - Incluido nome do módulo logado em todas procedures
                            Eliminada a rotina pc_popula_dcb_inss                             
                            Incluido tipo de falha variavel na Procedure pc_retorna_linha_log implica em alterar 10 procedures que a disparam
                            Colocado no padrão todas chamadas pc_gera_log_batch em torno de 60 chamadas
                            (Belli - Envolti - Chamado 660327 e 664301)              
                            
               16/06/2017 - No retorno das procedures pc_efetua_requisicao_soap e pc_elimina_arquivos_requis
                            Codigo 1 onde na rotina final faz de para gerar 4 alerta - (Belli Envolti) Ch 664301

               23/06/2017 - Retirada da rotina pc_set_module da rotina pc_retorna_linha_log, pois para esta pck,
                            deve registrar a rotina que gerou o erro (a que chamou a pc_retorna_linha_log)
                            (Ana - Envolti - Chamado 664301)
                                                                

			   07/08/2017 - Ajuste para efetuar log (temporário) de pontos criticos da rotina de pagamentos para tentarmos
				            identificar lentidões que estão ocorrendo
							(Adriano).
  ---------------------------------------------------------------------------------------------------------------*/

  /*Procedimento para gerar lote e lancamento, para gerar credito em conta*/
  procedure pc_gera_credito_em_conta (pr_cdcooper in number,   -- Codigo Cooperativa
                                      pr_cdoperad in varchar2, -- Codigo do operador
                                      pr_cdprogra in varchar2, -- Codigo do programa que esta chamando o procedimento
                                      pr_dtmvtolt in date,     -- Data do movimento
                                      pr_dtdehoje in date,     -- Data atual
                                      pr_nrdrowid in rowid,    -- Numero do rowid do  Lancamento de credito de beneficios do INSS
                                      pr_cdcritic out number,  -- Retorno do codigo da critica
                                      pr_dscritic out varchar2 -- Retorno da descricao da critica
                                   ) IS
    /*---------------------------------------------------------------------------------------------------------------
       Programa: pc_gera_credito_em_conta       Antiga: b1wgen0091.p/gera_credito_em_conta
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED

       Autor   : Odirlei Busana(AMcom)
       Data    : 27/08/2013                        Ultima atualizacao: 27/08/2013

       Dados referentes ao programa:

       Frequencia: Diario (on-line)
       Objetivo  : Procedimento para gerar lote e lancamento, para gerar credito em conta

       Alteracoes: 04/02/2013 - Conversao Progress >> Oracle (PLSQL) (Odirlei-AMcom)
      ---------------------------------------------------------------------------------------------------------------*/
    -- Tratamento de erros
    vr_exc_erro exception;

    -- Buscar Lancamento de credito de beneficios do INSS
    cursor cr_craplbi is
      select cdagenci,
             vlliqcre,
             nrdconta,
             cdcooper
        from craplbi
       where rowid = pr_nrdrowid;
    rw_craplbi cr_craplbi%rowtype;

    -- Buscar lote
    cursor cr_craplot (pr_cdagenci craplbi.cdagenci%type) is
      select l.rowid,
             cdcooper,
             dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             tplotmov,
             nrseqdig,
             qtcompln,
             qtinfoln,
             vlcompcr,
             vlinfocr
        from craplot l
       where cdcooper = pr_cdcooper
         and dtmvtolt = pr_dtmvtolt
         and cdagenci = pr_cdagenci
         and cdbccxlt = 100
         and nrdolote = 10114;

    rw_craplot cr_craplot%rowtype;
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 664301
		GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0001.pc_gera_credito_em_conta');
      
    -- Buscar Lancamento de credito de beneficios do INSS
    open cr_craplbi;
    fetch cr_craplbi
     INTO rw_craplbi;
    -- Se n?o encontrar
    IF cr_craplbi%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_craplbi;
      -- Montar mensagem de critica
      pr_dscritic := 'Registro nao localizado no buffer de lancamentos de creditos de beneficios do INSS';
      RAISE vr_exc_erro;
    else
      -- Apenas fechar o cursor
      close cr_craplbi;
    end if;

    -- Buscar lote
    OPEN cr_craplot(rw_craplbi.cdagenci);
    FETCH cr_craplot
     INTO rw_craplot;
    -- Se n?o encontrar
    if cr_craplot%notfound then
      -- Caso ainda nao exista o lote, deve cria-lo
      begin
        insert into craplot
                 (cdcooper,
                  dtmvtolt,
                  cdagenci,
                  cdbccxlt,
                  nrdolote,
                  tplotmov)
               values
                 (pr_cdcooper,
                  pr_dtmvtolt,
                  rw_craplbi.cdagenci,
                  100,   -- cdbccxlt
                  10114, -- nrdolote
                  1      -- tplotmov
                 ) returning rowid,
                             cdcooper,
                             dtmvtolt,
                             cdagenci,
                             cdbccxlt,
                             nrdolote,
                             tplotmov
                        into rw_craplot.rowid,
                             rw_craplot.cdcooper,
                             rw_craplot.dtmvtolt,
                             rw_craplot.cdagenci,
                             rw_craplot.cdbccxlt,
                             rw_craplot.nrdolote,
                             rw_craplot.tplotmov;
      exception
        when others then
          pr_dscritic := 'Erro ao inserir lote(craplot): '||sqlerrm;
          close cr_craplot;
          RAISE vr_exc_erro;
      end;
    end if;
    close cr_craplot;

    --alterar lote
    begin
      update craplot
         set craplot.nrseqdig = nvl(rw_craplot.nrseqdig,0) + 1,
             craplot.qtcompln = nvl(rw_craplot.qtcompln,0) + 1,
             craplot.qtinfoln = nvl(rw_craplot.qtinfoln,0) + 1,
             craplot.vlcompcr = nvl(rw_craplot.vlcompcr,0) + nvl(rw_craplbi.vlliqcre,0),
             craplot.vlinfocr = nvl(rw_craplot.vlinfocr,0) + nvl(rw_craplbi.vlliqcre,0)
       where rowid = rw_craplot.rowid
        returning rowid,
                 nrseqdig,
                 qtcompln,
                 qtinfoln,
                 vlcompcr,
                 vlinfocr
            into rw_craplot.rowid,
                 rw_craplot.nrseqdig,
                 rw_craplot.qtcompln,
                 rw_craplot.qtinfoln,
                 rw_craplot.vlcompcr,
                 rw_craplot.vlinfocr;
    exception
      when others then
        pr_dscritic := 'Erro ao alterar lote(craplot): '||sqlerrm;
        RAISE vr_exc_erro;
    end;

    -- Inserir Lancamento em deposito a vista
    begin
      insert into craplcm
              (cdcooper,
               dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrdolote,
               nrdconta,
               nrdctabb,
               nrdctitg,
               nrdocmto,
               cdhistor,
               vllanmto,
               nrseqdig)
             values
              (pr_cdcooper,            -- cdcooper
               rw_craplot.dtmvtolt,    -- dtmvtolt
               rw_craplot.cdagenci,    -- cdagenci
               rw_craplot.cdbccxlt,    -- cdbccxlt
               rw_craplot.nrdolote,    -- nrdolote
               rw_craplbi.nrdconta,    -- nrdconta
               rw_craplbi.nrdconta,    -- nrdctabb
               gene0002.fn_mask(rw_craplbi.nrdconta,'99999999'), -- nrdctitg
               rw_craplot.nrseqdig,    -- nrdocmto
               581,                    -- cdhistor
               rw_craplbi.vlliqcre,    -- vllanmto
               rw_craplot.nrseqdig     -- nrseqdig
              );
    exception
      when others then
        pr_dscritic := 'Erro ao inserir Lancamento em deposito a vista(craplcm): '||sqlerrm;
        RAISE vr_exc_erro;
    end;

    --Atualizar Lancamento de credito de beneficios do INSS
    begin
      update craplbi
        set dtdpagto = pr_dtmvtolt,
            dtdenvio = pr_dtmvtolt
      where rowid = pr_nrdrowid;
    exception
      when others then
        pr_dscritic := 'Erro ao atualizar Lancamento credito de beneficios do INSS(craplbi): '||sqlerrm;
        RAISE vr_exc_erro;
    end;

    IF UPPER(pr_cdprogra) = 'PRPREV' THEN
      -- Envio centralizado de log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1, -- somente mensagem
                                 pr_nmarqlog     => 'prprev', --gerar log no prprev,
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || pr_cdprogra || ' --> ' || 
                                                    'ALERTA: ' || pr_dscritic ||
                                                    ' ,ope: '  || pr_cdoperad  || ' - ' ||
                                                    'Realizou o credito em conta para a ' ||
                                                   'Conta: '  || gene0002.fn_mask_conta(rw_craplbi.nrdconta)||
                                                   ', Coop.: '|| to_char(rw_craplbi.cdcooper) ||
                                                   ', PA : '  || to_char(rw_craplbi.cdagenci) ||
                                                    ', Valor: '|| to_char(rw_craplbi.vlliqcre) ||'.'
                                ,pr_cdprograma   => pr_cdprogra
                                                   );
    ELSE
      -- Envio centralizado de log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1, -- somente mensagem
                                 pr_nmarqlog     => 'prprev', --gerar log no prprev,
                                 pr_des_log      =>  to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || pr_cdprogra || ' --> ' || 
                                                    'ALERTA: ' || pr_dscritic ||
                                                   'Realizado o credito em conta para a '||
                                                   'Conta: '  || gene0002.fn_mask_conta(rw_craplbi.nrdconta)||
                                                   ', Coop.: '|| to_char(rw_craplbi.cdcooper) ||
                                                   ', PA : '  || to_char(rw_craplbi.cdagenci) ||
                                                   ', Valor: '|| to_char(rw_craplbi.vlliqcre) ||'.'
                                ,pr_cdprograma   => pr_cdprogra
                                                   );

    end if;

  exception
    when vr_exc_erro then
      -- Retornar critica para o programa que chamou a pck
      IF pr_cdcritic IS NULL THEN
        -- Utilizaremos codigo zero, pois foi erro n?o cadastrado
        pr_cdcritic := 0;
      END IF;

    WHEN OTHERS THEN
      -- Efetuar retorno do erro n?o tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

  end pc_gera_credito_em_conta;

  /*Procedimento para gerar lote e lancamento, para gerar transferencia de beneficio*/
  procedure pc_transfere_beneficio (pr_cdcooper in number,    -- Codigo Cooperativa
                                    pr_cdoperad in varchar2,  -- Codigo do operador
                                    pr_cdprogra in varchar2,  -- Codigo do programa que esta chamando o procedimento
                                    pr_nrdconta in crapass.nrdconta%type, -- Numero da conta para a geracao do lancamento de transferencia
                                    pr_cdhistor in craplcm.cdhistor%type, -- Codigo do historico para o lancamento de transferencia
                                    pr_nrdolote in craplot.nrdolote%type, -- Numero do lote para o lancamento de transferencia
                                    pr_dtmvtolt in date,      -- Data do movimento
                                    pr_dtdehoje in date,      -- Data atual
                                    pr_nrdrowid in rowid,     -- Numero do rowid do  Lancamento de credito de beneficios do INSS
                                    pr_cdcritic out number,   -- Retorno do codigo da critica
                                    pr_dscritic out varchar2  -- Retorno da descricao da critica
                                   ) IS
    /*---------------------------------------------------------------------------------------------------------------
       Programa: pc_transfere_beneficio       Antiga: b1wgen0091.p/transfere_beneficio
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED

       Autor   : Odirlei Busana(AMcom)
       Data    : 27/08/2013                        Ultima atualizacao: 27/08/2013

       Dados referentes ao programa:

       Frequencia: Diario (on-line)
       Objetivo  : Procedimento para gerar lote e lancamento, para gerar transferencia de beneficio

       Alteracoes: 04/02/2013 - Conversao Progress >> Oracle (PLSQL) (Odirlei-AMcom)

      ---------------------------------------------------------------------------------------------------------------*/
    -- Tratamento de erros
    vr_exc_erro exception;

    -- Buscar Lancamento de credito de beneficios do INSS
    cursor cr_craplbi is
      select cdagenci,
             vlliqcre,
             nrdconta,
             cdcooper
        from craplbi
       where rowid = pr_nrdrowid;
    rw_craplbi cr_craplbi%rowtype;

    -- Buscar lote
    cursor cr_craplot is
      select l.rowid,
             cdcooper,
             dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             tplotmov,
             nrseqdig,
             qtcompln,
             qtinfoln,
             vlcompcr,
             vlinfocr,
             vlcompdb,
             vlinfodb
        from craplot l
       where cdcooper = pr_cdcooper
         and dtmvtolt = pr_dtmvtolt
         and cdagenci = 1
         and cdbccxlt = 100
         and nrdolote = pr_nrdolote;

    rw_craplot cr_craplot%rowtype;

    -- Buscar cadastro de historicos de lancamento
    cursor cr_craphis is
      select indebcre
        from craphis
       where cdcooper = pr_cdcooper
         and cdhistor = pr_cdhistor;

    rw_craphis cr_craphis%rowtype;
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 664301
	  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0001.pc_transfere_beneficio');
      
    -- Buscar Lancamento de credito de beneficios do INSS
    open cr_craplbi;
    fetch cr_craplbi
     INTO rw_craplbi;
    -- Se n?o encontrar
    IF cr_craplbi%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_craplbi;
      -- Montar mensagem de critica
      pr_dscritic := 'Registro n?o localizado no buffer de lancamentos de creditos de beneficios do INSS';
      RAISE vr_exc_erro;
    else
      -- Apenas fechar o cursor
      close cr_craplbi;
    end if;

    -- Buscar lote
    OPEN cr_craplot;
    FETCH cr_craplot
     INTO rw_craplot;
    -- Se n?o encontrar
    if cr_craplot%notfound then
      -- Caso ainda n?o exista o lote, deve cria-lo
      begin
        insert into craplot
                 (cdcooper,
                  dtmvtolt,
                  cdagenci,
                  cdbccxlt,
                  nrdolote,
                  tplotmov)
               values
                 (pr_cdcooper,
                  pr_dtmvtolt,
                  1,           -- cdagenci
                  100,         -- cdbccxlt
                  pr_nrdolote, -- nrdolote
                  1            -- tplotmov
                 ) returning rowid,
                             cdcooper,
                             dtmvtolt,
                             cdagenci,
                             cdbccxlt,
                             nrdolote,
                             tplotmov,
                             nrseqdig
                        into rw_craplot.rowid,
                             rw_craplot.cdcooper,
                             rw_craplot.dtmvtolt,
                             rw_craplot.cdagenci,
                             rw_craplot.cdbccxlt,
                             rw_craplot.nrdolote,
                             rw_craplot.tplotmov,
                             rw_craplot.nrseqdig;
      exception
        when others then
          pr_dscritic := 'Erro ao inserir lote(craplot): '||sqlerrm;
          close cr_craplot;
          RAISE vr_exc_erro;
      end;
    end if;
    close cr_craplot;

    -- Inserir Lancamento em deposito a vista
    begin
      insert into craplcm
              (
               dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrdolote,
               nrdconta,
               nrdctabb,
               nrdctitg,
               vllanmto,
               cdhistor,
               nrseqdig,
               nrdocmto,
               cdcooper
               )
             values
              (
               rw_craplot.dtmvtolt,    -- dtmvtolt
               rw_craplot.cdagenci,    -- cdagenci
               rw_craplot.cdbccxlt,    -- cdbccxlt
               rw_craplot.nrdolote,    -- nrdolote
               pr_nrdconta,            -- nrdconta
               pr_nrdconta,            -- nrdctabb
               gene0002.fn_mask(pr_nrdconta,'99999999'), -- nrdctitg
               rw_craplbi.vlliqcre,    -- vllanmto
               pr_cdhistor,            -- cdhistor
               nvl(rw_craplot.nrseqdig,0) + 1,-- nrseqdig
               nvl(rw_craplot.nrseqdig,0) + 1,-- nrdocmto
               pr_cdcooper             -- cdcooper
              );
    exception
      when others then
        pr_dscritic := 'Erro ao inserir Lancamento em deposito a vista(craplcm): '||sqlerrm;
        RAISE vr_exc_erro;
    end;

    -- Buscar historico do lancamento
    OPEN cr_craphis;
    FETCH cr_craphis
     INTO rw_craphis;
    -- Se n?o encontrar
    if cr_craphis%notfound then
      close cr_craphis;
    else
      -- Atualizar informacoes nos lotes de acordo com o indicador de debido ou credito
      IF rw_craphis.indebcre = 'D' THEN
        BEGIN
          UPDATE craplot
             SET vlcompdb = nvl(rw_craplot.vlcompdb,0) + nvl(rw_craplbi.vlliqcre,0),
                 vlinfodb = nvl(rw_craplot.vlcompdb,0) + nvl(rw_craplbi.vlliqcre,0)
           WHERE rowid = rw_craplot.rowid
           returning vlcompdb,
                     vlinfodb
                into rw_craplot.vlcompdb,
                     rw_craplot.vlinfodb;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao atualizar lote(craplot - Debito): '||sqlerrm;
            RAISE vr_exc_erro;
        END;

      ELSIF rw_craphis.indebcre = 'C' THEN
        BEGIN
          UPDATE craplot
             SET vlcompcr = nvl(rw_craplot.vlcompcr,0) + nvl(rw_craplbi.vlliqcre,0),
                 vlinfocr = nvl(rw_craplot.vlcompcr,0) + nvl(rw_craplbi.vlliqcre,0)
           WHERE rowid = rw_craplot.rowid
           returning vlcompcr,
                     vlinfocr
                into rw_craplot.vlcompcr,
                     rw_craplot.vlinfocr;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao atualizar lote(craplot - Credito): '||sqlerrm;
            RAISE vr_exc_erro;
        END;
      END IF;
      close cr_craphis;
    end if;

    --incrementar sequenciais e contador no lote
    BEGIN
      UPDATE craplot
         SET nrseqdig = nvl(rw_craplot.nrseqdig,0) + 1,
             qtcompln = nvl(rw_craplot.qtcompln,0) + 1,
             qtinfoln = nvl(rw_craplot.qtcompln,0) + 1
       WHERE rw_craplot.rowid = rowid
       returning nrseqdig,
                 qtcompln,
                 qtinfoln
            into rw_craplot.nrseqdig,
                 rw_craplot.qtcompln,
                 rw_craplot.qtinfoln;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao atualizar lote(craplot - Incrementar seq): '||sqlerrm;
        RAISE vr_exc_erro;
    END;

    --Atualizar Lancamento de credito de beneficios do INSS
    begin
      update craplbi
         set dtdpagto = pr_dtmvtolt,
             dtdenvio = pr_dtmvtolt
       where rowid = pr_nrdrowid;
    exception
      when others then
        pr_dscritic := 'Erro ao atualizar Lancamento credito de beneficios do INSS(craplbi): '||sqlerrm;
        RAISE vr_exc_erro;
    end;

    --Gravar Log
    IF UPPER(pr_cdprogra) = 'PRPREV' THEN
      -- Envio centralizado de log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1, -- somente mensagem
                                 pr_nmarqlog     => 'prprev',--gerar log no prprev
                                 pr_des_log      =>  to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || pr_cdprogra || ' --> ' || 
                                                    'ALERTA: ' || pr_dscritic ||
                                                   ' ,ope: ' || pr_cdoperad  || ' - '||
                                                   'Realizou o credito em conta para a '||
                                                   'Conta: '  || gene0002.fn_mask_conta(rw_craplbi.nrdconta)||
                                                   ', Coop.: '|| to_char(rw_craplbi.cdcooper) ||
                                                   ', PA : '  || to_char(rw_craplbi.cdagenci) ||
                                                   ', Valor: '|| to_char(rw_craplbi.vlliqcre) ||'.'
                                ,pr_cdprograma   => pr_cdprogra
                                                   );
    ELSE
      -- Envio centralizado de log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1, -- somente mensagem
                                 pr_nmarqlog     => 'prprev', --gerar log no prprev
                                 pr_des_log      =>  to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || pr_cdprogra || ' --> ' || 
                                                    'ALERTA: ' || pr_dscritic ||
                                                   'Realizado o credito em conta para a '||
                                                   'Conta: '  || gene0002.fn_mask_conta(rw_craplbi.nrdconta)||
                                                   ', Coop.: '|| to_char(rw_craplbi.cdcooper) ||
                                                   ', PA : '  || to_char(rw_craplbi.cdagenci) ||
                                                   ', Valor: '|| to_char(rw_craplbi.vlliqcre) ||'.'
                                ,pr_cdprograma   => pr_cdprogra
                                                   );

    end if;

  exception
    when vr_exc_erro then
      -- Retornar critica para o programa que chamou a pck
      IF pr_cdcritic IS NULL THEN
        -- Utilizaremos codigo zero, pois foi erro n?o cadastrado
        pr_cdcritic := 0;
      END IF;

    WHEN OTHERS THEN
      -- Efetuar retorno do erro n?o tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

  end pc_transfere_beneficio;
  
  /* Procedimento para retornar os beneficios do inss */ 
  PROCEDURE pc_beneficios_inss (pr_cdcooper IN crapcop.cdcooper %type --> Cooperativa desejada
                               ,pr_cdageini IN PLS_INTEGER            --> Agência inicial
                               ,pr_cdagefim IN PLS_INTEGER            --> Agência final
                               ,pr_dataini  IN DATE                   --> Data base inicial
                               ,pr_datafim  IN DATE                   --> Data base final
                               ,pr_geralcre OUT NUMBER                --> Qtde geral credito disponibilizado Não Cooperado
                               ,pr_quantger OUT PLS_INTEGER           --> Qtde geral registros Não Cooperados
                               ,pr_geraldcc OUT NUMBER                --> Qtde geral credito disponibilizado Cooperados
                               ,pr_quantge2 OUT PLS_INTEGER           --> Qtde geral registros Cooperados
                               ,pr_valorger OUT NUMBER                --> Total credito disponibilizado
                               ,pr_geralpa  OUT PLS_INTEGER           --> Total registros
                               ,pr_arqvazio OUT PLS_INTEGER           --> Indicador arquivo vazio
                               ,pr_tab_result_inss OUT typ_tab_result_inss --> PLTable com os registros de retorno
                               ,pr_cdcritic OUT PLS_INTEGER                --> Código retorno erro
                               ,pr_dscritic OUT VARCHAR2) IS               --> Descrição retorno erro
  /*------------------------------------------------------------------------------
   Programa: pc_beneficios_inss       Antiga: b1wgen0045.p/beneficios-inss
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Douglas Pagel
   Data    : 27/11/2013                        Ultima atualizacao: 27/11/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Procedimento para retornar os beneficios do inss

   Alteracoes: 27/11/2013 - Conversao Progress >> Oracle (PLSQL) (Douglas Pagel)
  -------------------------------------------------------------------------------*/ 
  -- CURSOR para Lancamentos de creditos de beneficios do INSS
  CURSOR cr_craplbi IS
    SELECT craplbi.cdcooper,
           craplbi.cdagenci,
           craplbi.vlliqcre,
           craplbi.tpmepgto,
           craplbi.nrrecben,
           craplbi.nrbenefi
      FROM craplbi
     WHERE craplbi.cdcooper = pr_cdcooper
       AND craplbi.cdagenci >= pr_cdageini
       AND craplbi.cdagenci <= pr_cdagefim
       AND craplbi.dtdpagto >= pr_dataini
       AND craplbi.dtdpagto <= pr_datafim
     ORDER BY craplbi.cdagenci,
              craplbi.dtdpagto;
  rw_craplbi cr_craplbi%rowtype;              

  -- Chave para a pltable vr_tab_result_inss
  vr_chave_result varchar2(6);
            
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 664301
	  GENE0001.pc_set_modulo(pr_module => 'INSS0001', pr_action => 'INSS0001.pc_beneficios_inss');
      
    -- Lista os lancamentos de creditos de beneficios
    OPEN cr_craplbi;
    LOOP
      FETCH cr_craplbi INTO rw_craplbi;
      EXIT WHEN cr_craplbi%NOTFOUND;
      pr_arqvazio := 0;
      -- Monta chave para inserir na pltable vr_tab_result_inss
      vr_chave_result := LPAD(rw_craplbi.cdcooper, 3, '0') || LPAD(rw_craplbi.cdagenci, 3, '0');
      
      -- Monta totais por PA
      
      IF NOT pr_tab_result_inss.EXISTS(vr_chave_result) THEN
        pr_tab_result_inss(vr_chave_result).cdcooper := rw_craplbi.cdcooper;
        pr_tab_result_inss(vr_chave_result).cdagenci := rw_craplbi.cdagenci;
      END IF;        
      
      IF rw_craplbi.tpmepgto = 1 THEN -- Nao cooperado
        pr_tab_result_inss(vr_chave_result).totalcre  := nvl(pr_tab_result_inss(vr_chave_result).totalcre, 0) + rw_craplbi.vlliqcre;
        pr_tab_result_inss(vr_chave_result).quantida  := nvl(pr_tab_result_inss(vr_chave_result).quantida,0) + 1;
        pr_geralcre  := pr_geralcre + rw_craplbi.vlliqcre;
        pr_quantger  := pr_quantger + 1;
      ELSE
        IF rw_craplbi.tpmepgto = 2 THEN -- Cooperado
          pr_tab_result_inss(vr_chave_result).totaldcc :=  nvl(pr_tab_result_inss(vr_chave_result).totaldcc,0) + rw_craplbi.vlliqcre;
          pr_tab_result_inss(vr_chave_result).quantid2 :=  nvl(pr_tab_result_inss(vr_chave_result).quantid2,0) + 1;
          pr_geraldcc := pr_geraldcc + rw_craplbi.vlliqcre;
          pr_quantge2 := pr_quantge2 + 1;
        END IF;
      END IF;
     
      -- Monta total geral
      pr_tab_result_inss(vr_chave_result).totalpac := nvl(pr_tab_result_inss(vr_chave_result).totalcre,0) + nvl(pr_tab_result_inss(vr_chave_result).totaldcc,0);
      pr_tab_result_inss(vr_chave_result).quantpac := nvl(pr_tab_result_inss(vr_chave_result).quantida,0) + nvl(pr_tab_result_inss(vr_chave_result).quantid2,0);
      pr_valorger  := pr_geralcre + pr_geraldcc;
      pr_geralpa  := pr_quantger + pr_quantge2;          
            
    END LOOP; -- FIM cr_craplbi
    CLOSE cr_craplbi;
    
  EXCEPTION
    WHEN OTHERS THEN
      -- Efetuar retorno do erro n?o tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na inss0001.pc_beneficios_inss: '|| sqlerrm;
       
  END; -- pc_beneficios_inss                              

  --Gerar cabecalho arquivo XML beneficios INSS
  PROCEDURE pc_gera_cabecalho_xml(pr_idservic IN INTEGER             --Tipo do Servico
                                 ,pr_nmmetodo IN VARCHAR2            --Nome do Método
                                 ,pr_dstexto  IN OUT NOCOPY VARCHAR2 --Arquivo Dados
                                 ,pr_des_reto OUT VARCHAR2           --Retorno OK/NOK
                                 ,pr_dscritic OUT VARCHAR2) IS       --Descricao da Critica
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_gera_cabecalho_xml             Antigo: procedures/b1wgen0091.p/gera_cabecalho_xml
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - Amcom
    Data     : Agosto/2014                           Ultima atualizacao: 07/08/2014
  
    Dados referentes ao programa:
  
    Frequencia: -----
    Objetivo   : Procedure para gerar o cabecalho do arquivo XML  
  
    Alterações : 07/08/2014 Conversao Progress -> Oracle (Alisson-AMcom)
                 
  ---------------------------------------------------------------------------------------------------------------*/
    BEGIN
	  -- Incluir nome do módulo logado - Chamado 664301
			GENE0001.pc_set_modulo(pr_module => 'INSS0001', pr_action => 'INSS0001.pc_gera_cabecalho_xml');      
      
      pr_dstexto := '<?xml version="1.0" ?>';
    
      --Tipo de Servico
      IF pr_idservic = 1 THEN /* Solicita BeneficioINSS*/ 
        pr_dstexto:=  pr_dstexto||
                      '<soapenv:Envelope xmlns:ben="http://sicredi.com.br/convenios/pagamento/BeneficioINSS"'||
                      ' xmlns:dad="http://sicredi.com.br/convenios/pagamento/DadosBeneficioINSS"'||
                      ' xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'||
                      ' xmlns:v1="http://sicredi.com.br/cadastro/entidade/cmodel/v1/"'|| 
                      ' xmlns:v11="http://sicredi.com.br/cadastro/pessoa/cmodel/v1/"'||
                      ' xmlns:v12="http://sicredi.com.br/cadastro/localidade/cmodel/v1/"'||
                      ' xmlns:v13="http://sicredi.com.br/cadastro/bens/cmodel/v1/"'||
                      ' xmlns:v14="http://sicredi.com.br/cadastro/contato/cmodel/v1/"'||
                      ' xmlns:v15="http://sicredi.com.br/convenios/cadastro/cmodel/v1/">'||
                      '<soapenv:Header>'||
                        '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" soapenv:mustUnderstand="1">'||
                          '<wsse:UsernameToken xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" wsu:Id="UsernameToken-4">'||
                            '<wsse:Username>app_cecred_client</wsse:Username>'||                     
                            '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' || fn_senha_sicredi ||'</wsse:Password>'||
                          '</wsse:UsernameToken>'||
                        '</wsse:Security>'||
                      '</soapenv:Header><soapenv:Body><'||pr_nmmetodo||'>';
      ELSIF pr_idservic IN (2,3) THEN /* XML REJEITAR e XML PAGAMENTO */
        --Montar XML
        pr_dstexto:=  pr_dstexto||
                      '<'||pr_nmmetodo||
                      ' xmlns="http://sicredi.com.br/convenios/pagamento/BeneficioINSS"'||
                      ' xmlns:v1="http://sicredi.com.br/convenios/pagamento/cmodel/v1/"'||
                      ' xmlns:v11="http://sicredi.com.br/cadastro/pessoa/cmodel/v1/"'||
                      ' xmlns:v12="http://sicredi.com.br/cadastro/localidade/cmodel/v1/"'||
                      ' xmlns:v13="http://sicredi.com.br/cadastro/bens/cmodel/v1/"'||
                      ' xmlns:v14="http://sicredi.com.br/cadastro/contato/cmodel/v1/"'||
                      ' xmlns:v15="http://sicredi.com.br/cadastro/entidade/cmodel/v1/">';
      ELSIF pr_idservic = 4 THEN /* FAZER QUANDO EXISTIR */
        pr_dstexto:=  pr_dstexto||
                      '<soapenv:Envelope xmlns:ben="http://sicredi.com.br/convenios/cadastro/BeneficiarioINSS"'||
                      ' xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'||
                      ' xmlns:v1="http://sicredi.com.br/cadastro/pessoa/cmodel/v1/"'|| 
                      ' xmlns:v11="http://sicredi.com.br/cadastro/bens/cmodel/v1/"'||
                      ' xmlns:v12="http://sicredi.com.br/cadastro/localidade/cmodel/v1/"'||
                      ' xmlns:v13="http://sicredi.com.br/cadastro/contato/cmodel/v1/"'||
                      ' xmlns:v14="http://sicredi.com.br/convenios/cadastro/cmodel/v1/"'||
                      ' xmlns:v15="http://sicredi.com.br/cadastro/entidade/cmodel/v1/"'||
                      ' xmlns:v16="http://sicredi.com.br/convenios/pagamento/cmodel/v1/"'||
                      ' xmlns:v17="http://sicredi.com.br/contas/conta/cmodel/v1/"'||'>'||
                      '<soapenv:Header><soapenv:Body><'||pr_nmmetodo||'>';
      END IF;              
      --Retornar OK
      pr_des_reto:= 'OK';
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        pr_dscritic:= 'Erro na pc_gera_cabecalho_xml --> '|| SQLERRM;
        
  END pc_gera_cabecalho_xml;

  --Procedure para criptografar e mover arquivos do INSS   
  PROCEDURE pc_criptografa_move_arquiv(pr_cdcooper IN crapcop.cdcooper%type --Codigo Cooperativa
                                      ,pr_cdprogra IN crapprg.cdprogra%type --Nome Programa
                                      ,pr_nmarquiv IN VARCHAR2              --Nome Arquivo Origem
                                      ,pr_arqdesti IN VARCHAR2              --Nome Arquivo Destino
                                      ,pr_dsmensag IN VARCHAR2              --Descricao da Mensagem
                                      ,pr_nmarqlog IN VARCHAR2              --Nome Arquivo Log
                                      ,pr_dscritic OUT VARCHAR2) IS         --Mensagem Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_criptografa_move_arquiv      Antigo: procedures/b1wgen0091.p/criptografa_move_arquivo
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - Amcom
    Data     : Agosto/2014                           Ultima atualizacao: 26/03/2015
  
    Dados referentes ao programa:
  
    Frequencia: -----
    Objetivo   : Procedure para criptografar e mover arquivos 
  
    Alterações : 11/08/2014 Conversao Progress -> Oracle (Alisson-AMcom)
    
                 25/09/2014 - Ajustes para liberação (Adriano).
                 
                 30/01/2015 - Correção no tamanho das variaveis de mensagem 
                           (Marcos-Supero) 
                           
                 09/02/2015 - Ajuste no nome de destino do arquivo criptografado. 
                           (Alisson - AMcom)          
                           
                 26/03/2015 - Ajuste na organização e identação da escrita
                              (Adriano).          
                           
  ---------------------------------------------------------------------------------------------------------------*/
    --Varaiveis Locais
    vr_nmarqcri  VARCHAR2(1000);
    vr_comando   VARCHAR2(32767);
    vr_typ_saida VARCHAR2(3);
    vr_dscomora  VARCHAR2(1000); 
    vr_dsdirbin  VARCHAR2(1000); 
    
    --Variaveis Erro
    vr_dscritic  VARCHAR2(4000);
    
    --Excecoes
    vr_exc_erro  EXCEPTION;
    
    vr_cdprogra  VARCHAR2(1000);
    
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
			GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0001.pc_criptografa_move_arquiv');
      
      --Limpar variavel retorno                                         
      pr_dscritic:= NULL;

      --Buscar parametros 
      vr_dscomora:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_EXEC_SHELL');
      vr_dsdirbin:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_CECRED_BIN');
      
      --se nao encontrou
      IF vr_dscomora IS NULL OR 
         vr_dsdirbin IS NULL THEN
        
        --Montar mensagem erro        
        vr_dscritic:= 'Nao foi possivel selecionar parametros.';
        
        --Gera exceção
        RAISE vr_exc_erro;
        
      END IF;
      
      -- Comando para criptografar o arquivo 
      vr_comando:= vr_dscomora||' perl_remoto ' ||vr_dsdirbin||
                   'mqcecred_criptografa.pl --criptografa='||
                   chr(39)|| pr_nmarquiv ||chr(39);
                   
      --Executar o comando no unix
      GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => vr_comando
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_nmarqcri);
                            
      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        
        vr_dscritic:= 'Nao foi possivel executar comando unix: '||
        vr_comando||' - '||vr_nmarqcri;
        
        -- retornando ao programa chamador
        RAISE vr_exc_erro;
        
      END IF;

      --Retirar sujeira do final do nome do arquivo
      vr_nmarqcri:= replace(replace(vr_nmarqcri,chr(10),''),chr(13),'');
      
      /* Obtem arquivo temporario criptografado / com .crypto no fim */
      IF TRIM(vr_nmarqcri) IS NULL THEN
        
        --Mensagem Erro
        vr_dscritic:= 'Erro ao criptografar o arquivo: '||pr_nmarquiv;
        
        vr_cdprogra := pr_cdprogra;
        
        --Escrever no Log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => pr_nmarqlog
                                  ,pr_des_log      =>  to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra || ' --> ' || 
                                                    'ERRO: ' || vr_dscritic 
                                  ,pr_cdprograma   => vr_cdprogra
                                                    );
                                                    
        /** MOVE SEM CRIPTOGRAFAR **/
        -- Comando para mover arquivo
        vr_comando:= 'mv '||pr_nmarquiv||' '||pr_arqdesti||' 2> /dev/null';
                     
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
                              
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          
          --Monta mensagem de critica
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando||' - '||vr_dscritic;
          
          -- retornando ao programa chamador
          RAISE vr_exc_erro;
          
        END IF;
      ELSE
        /** MOVE ARQ CRIPTOGRAFADO **/
        -- Comando para mover arquivo
        vr_comando:= 'mv '||vr_nmarqcri||' '||pr_arqdesti||'.crypto 2> /dev/null';
                     
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
                              
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          
          --Monta mensagem de critica
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando||' - '||vr_dscritic;
          
          -- retornando ao programa chamador
          RAISE vr_exc_erro;
          
        END IF;
        
        /** REMOVE ARQUIVO SEM CRIPTOGRAFIA - ORIGEM **/
        -- Comando para mover arquivo
        vr_comando:= 'rm '||pr_nmarquiv||' 2> /dev/null';
        
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
                              
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          
          --Monta mensagem de critica
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando||' - '||vr_dscritic;
          
          -- retornando ao programa chamador
          RAISE vr_exc_erro;
          
        END IF;
        
      END IF;  
        
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_dscritic:= 'Erro na rotina pc_criptografa_move_arquiv. '||SQLERRM;
        
    	  -- Incluir nome do módulo logado - Chamado 664301
			  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'Saiu de INSS0001.pc_criptografa_move_arquiv');
      
        
  END pc_criptografa_move_arquiv;                                 

  --Procedure para enviar requisicao beneficios ao MQSeries
  PROCEDURE pc_submete_requis_mq_batch  (pr_cdcooper IN crapcop.cdcooper%type    --Codigo Cooperativa
                                        ,pr_cdprogra IN VARCHAR2                 --Nome Programa
                                        ,pr_dstexto  IN VARCHAR2                 --Texto do arquivo 
                                        ,pr_pathcoop IN VARCHAR2                 --Diretorio Padrao da Cooperativa
                                        ,pr_arqenvio IN VARCHAR2                 --Nome Arquivo Envio
                                        ,pr_dsmensag IN VARCHAR2                 --Descricao Mensagem
                                        ,pr_nmarqlog IN VARCHAR2) IS             --Nome Arquivo Log
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_submete_requis_mq_batch             
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - Amcom
    Data     : Marco/2015                           Ultima atualizacao: 21/06/2016
  
    Dados referentes ao programa:
  
    Frequencia: -----
    Objetivo   : Procedure para enviar requisicao beneficio ao MQ
                 
  
    Alterações : 12/03/2015 - Desenvolvimento - (Alisson - AMcom)   
    
                 26/03/2015 - Ajuste na organização e identação da escrita e passado o parâmetro
                              correto para a rotia que cria o arquivo fisico
                              (Adriano).         
                
                 21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                              (Adriano - SD 473539).
  ---------------------------------------------------------------------------------------------------------------*/
    --Variaveis Locais
    vr_dscomora VARCHAR2(1000);
    vr_nmdireto_arq VARCHAR2(1000);
    vr_nmdireto_salvar VARCHAR2(1000);
    vr_comando   VARCHAR2(32767);
    vr_dstexto   VARCHAR2(32700);
    vr_typ_saida VARCHAR2(3);
    vr_clob      CLOB;
    
    --Variaveis de Criticas
    vr_dscritic VARCHAR2(4000); 
                                          
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;  
                                         
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
			GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0001.pc_submete_requis_mq_batch'); 

      --Diretorio Envio arquivo
      vr_nmdireto_arq:= pr_pathcoop||'/arq';
      
      --Diretorio Salvar
      vr_nmdireto_salvar:= pr_pathcoop||'/salvar/inss';

      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.OPEN(vr_clob, dbms_lob.lob_readwrite);

      --Escrever texto no Clob
      gene0002.pc_escreve_xml(vr_clob,vr_dstexto,pr_dstexto,TRUE);
        
      --Criar Arquivo Fisico para MQ
      gene0002.pc_clob_para_arquivo (pr_clob     => vr_clob
                                    ,pr_caminho  => vr_nmdireto_arq
                                    ,pr_arquivo  => pr_arqenvio
                                    ,pr_des_erro => vr_dscritic);
                                    
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;             
      
      --Fechar Clob e Liberar Memoria	
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob); 
      
      --Buscar parametros 
      vr_dscomora:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_EXEC_SHELL');
            
      --se nao encontrou
      IF vr_dscomora IS NULL THEN
        
        --Montar mensagem erro        
        vr_dscritic:= 'Nao foi possivel selecionar parametros.';
        
        RAISE vr_exc_erro;
        
      END IF;
      
      --Montar comando 
      vr_comando:= vr_dscomora || ' mqcecred_envia_sicredi '||
                   chr(39)||pr_dstexto||chr(39);
                     
      --Executar Comando Unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
                           
      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
               
        --Monta mensagem de erro 
        vr_dscritic:= 'Nao foi possivel executar comando unix: '||
                       vr_comando||' - '||vr_dscritic;
                       
        --Gera exceção               
        RAISE vr_exc_erro;
        
      END IF;
      
      /* Move Arquivo Envio */
      inss0001.pc_criptografa_move_arquiv (pr_cdcooper => pr_cdcooper        --Codigo Cooperativa
                                          ,pr_cdprogra => pr_cdprogra        --Codigo Programa
                                          ,pr_nmarquiv => vr_nmdireto_arq||'/'||pr_arqenvio     /* Arquivo Orig  */
                                          ,pr_arqdesti => vr_nmdireto_salvar||'/'||pr_arqenvio  /* Nome arq Destino */
                                          ,pr_dsmensag => pr_dsmensag                           /* Mensagem Log (se erro) */  
                                          ,pr_nmarqlog => pr_nmarqlog        --Nome Arquivo Log
                                          ,pr_dscritic => vr_dscritic);      --Mensagem Erro
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        --Retorno NOK
        RAISE vr_exc_erro;
      END IF;  
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        
        --Contatenar o nome do arquivo no log
        vr_dscritic:= vr_dscritic||' Arquivo: '||pr_arqenvio;
        
        --Escrever no Log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => pr_nmarqlog
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || pr_cdprogra || ' --> ' || 
                                                    'ERRO: ' || vr_dscritic 
                                  ,pr_cdprograma   => pr_cdprogra
                                                    );
      WHEN OTHERS THEN
        
        -- Retorno não OK
        vr_dscritic:= 'Erro na inss0001.pc_submete_requis_mq_batch. '||SQLERRM;
        
        --Contatenar o nome do arquivo no log
        vr_dscritic:= vr_dscritic||' Arquivo: '||pr_arqenvio;        
        
        --Escrever no Log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => pr_nmarqlog
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || pr_cdprogra || ' --> ' || 
                                                    'ERRO: ' || vr_dscritic
                                  ,pr_cdprograma   => pr_cdprogra
                                                    );        
        
  END pc_submete_requis_mq_batch;

  --Procedure para enviar requisicao beneficios ao MQSeries
  PROCEDURE pc_benef_inss_envia_req_mq(pr_cdcooper IN crapcop.cdcooper%type    --Codigo Cooperativa
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%type    --Data movimento
                                      ,pr_cdoperad IN VARCHAR2                 --Codigo operador
                                      ,pr_cdprogra IN VARCHAR2                 --Nome Programa
                                      ,pr_idservic IN INTEGER                  --Identificador Servico
                                      ,pr_dstexto  IN VARCHAR2                 --Texto do arquivo 
                                      ,pr_nrrecben IN NUMBER                   --Numero Recebimento Benficiario (NB)
                                      ,pr_pathcoop IN VARCHAR2                 --Diretorio Padrao da Cooperativa
                                      ,pr_nmarqlog IN VARCHAR2                 --Nome Arquivo Log
                                      ,pr_dscritic OUT VARCHAR2) IS            --Descricao Erro                      
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_benef_inss_envia_req_mq             Antigo: procedures/b1wgen0091.p/beneficios_inss_envia_req_via_mq                
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - Amcom
    Data     : Agosto/2014                           Ultima atualizacao: 26/03/2015
  
    Dados referentes ao programa:
  
    Frequencia: -----
    Objetivo   : Procedure para enviar requisicao beneficio ao MQ
                 Via MQ Salva o XML e efetua o envio do arquivo ao SICREDI via SCRIPT .pl  
  
    Alterações : 13/08/2014 Conversao Progress -> Oracle (Alisson-AMcom)
    
                 25/09/2014 - Ajustes para liberação (Adriano).
                 
                 28/05/2015 - Ajuste para utilizar o script exec_comando_oracle
                              (Adriano).
                              
                 30/01/2015 - Correção no tamanho das variaveis de mensagem 
                             (Marcos-Supero)
                             
                 09/02/2015 - Ajuste no nome dos arquivos gerados. Foi adicionado
                             o numero do beneficiario e retirada a data.
                             (Alisson - AMcom)
                             
                 12/03/2015 - Chamada da rotina pc_submete_requis_mq_batch. 
                              Essa rotina foi criada para agilizar o processamento da interface.
                              A solucao submete via dbms_scheduler o envio do retorno ao Sicredi. 
                              (Alisson - Amcom)  
                              
                 26/03/2015 - Ajuste na organização e identação da escrita e retirado variáveis
                              não utilizadas
                              (Adriano).                                   
                
  ---------------------------------------------------------------------------------------------------------------*/
    --Variaveis Locais
    vr_dsmensag VARCHAR2(1000);
    vr_dsplsql  VARCHAR2(32767);
    vr_arqenvio VARCHAR2(1000);
    vr_dshorari  VARCHAR2(100);
    vr_jobname   VARCHAR2(100);
    vr_dstime    VARCHAR2(100);
    
    --Variaveis de Criticas
    vr_dscritic VARCHAR2(4000); 
                                          
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;  
                                         
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
			GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0001.pc_benef_inss_envia_req_mq');      

      --limpar tabela erros
      pr_dscritic:= NULL;

      --Buscar o Time
      vr_dstime:=  lpad(gene0002.fn_busca_time,5,'0');
      
      --Buscar Random
      vr_dstime:= vr_dstime||lpad(Trunc(DBMS_RANDOM.Value(0,9999)),4,'0'); 
      
      --Buscar Horario
      vr_dshorari:= lpad(pr_nrrecben,11,'0')||'.'||vr_dstime;
                                          
      --Tipo de Servico
      CASE pr_idservic
        WHEN 2 THEN
          --Arquivo Envio
          vr_arqenvio:= 'INSS.MQ.EREJ.'||vr_dshorari||'.xml';
          --Mensagem
          vr_dsmensag:= 'INSS MQ DIVERGENCIA';
        WHEN 3 THEN    
          --Arquivo Envio
          vr_arqenvio:= 'INSS.MQ.EPAG.'||vr_dshorari||'.xml';
          --Mensagem
          vr_dsmensag:= 'INSS MQ PAGAMENTO';
        ELSE 
          pr_dscritic:= NULL;
          RETURN;
      END CASE;   
      
      -- Montar o bloco PLSQL que será executado
      vr_dsplsql:= 'DECLARE'||chr(13)
                   || '  vr_cdcritic NUMBER;'||chr(13)
                   || '  vr_dscritic VARCHAR2(4000);'||chr(13)
                   || 'BEGIN'||chr(13)
                   || '  inss0001.pc_submete_requis_mq_batch' 
                   || '  (pr_cdcooper => '||pr_cdcooper
                   || '  ,pr_cdprogra => '||chr(39)||pr_cdprogra||chr(39)
                   || '  ,pr_dstexto  => '||chr(39)||pr_dstexto ||chr(39)
                   || '  ,pr_pathcoop => '||chr(39)||pr_pathcoop||chr(39)
                   || '  ,pr_arqenvio => '||chr(39)||vr_arqenvio||chr(39)
                   || '  ,pr_dsmensag => '||chr(39)||vr_dsmensag||chr(39)
                   || '  ,pr_nmarqlog => '||chr(39)||pr_nmarqlog||chr(39)||');'||chr(13)
                   || 'END;';
                   
      -- Montar o prefixo do código do programa para o jobname
      vr_jobname := 'MQ_'||lpad(pr_nrrecben,11,'0')||'$';
      
      -- Faz a chamada ao programa paralelo atraves de JOB
      gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper  --> Código da cooperativa
                            ,pr_cdprogra  => 'INSS'       --> Código do programa
                            ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                            ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                            ,pr_interva   => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                            ,pr_jobname   => vr_jobname   --> Nome randomico criado
                            ,pr_des_erro  => vr_dscritic);
                            
      -- Testar saida com erro
      IF vr_dscritic IS NOT NULL THEN
        -- Levantar exceçao
        RAISE vr_exc_erro;
      END IF;  
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_dscritic:= 'Erro na inss0001.pc_benef_inss_envia_req_mq. '||SQLERRM;
        
  END pc_benef_inss_envia_req_mq;


  /* Procedure para Verificar Divergencias de Pagamento */
  PROCEDURE pc_benef_inss_xml_div_pgto(pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%type   --Data Movimento
                                      ,pr_tpdiverg IN INTEGER                 --Tipo Divergencia
                                      ,pr_dscritic IN VARCHAR2                --Descricao da Critica
                                      ,pr_nrcpfcgc IN crapass.nrcpfcgc%type   --Numero Cpf CGC
                                      ,pr_nrdconta IN crapass.nrdconta%type   --Numero da Conta 
                                      ,pr_cdbenefi IN NUMBER                  --Codigo beneficio
                                      ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                      ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                      ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                      ,pr_nmbenefi IN VARCHAR2                --Nome Beneficiario
                                      ,pr_dtdpagto IN crapdat.dtmvtolt%type   --Data pagamento
                                      ,pr_vlrbenef IN NUMBER                  --Valor Beneficio
                                      ,pr_nmarquiv IN VARCHAR2                --Nome Arquivo 
                                      ,pr_ercadttl IN BOOLEAN                 --Cadastro Titular
                                      ,pr_ercadcop IN BOOLEAN                 --Cadastro Cooperativa
                                      ,pr_tab_arquivos IN OUT NOCOPY inss0001.typ_tab_arquivos   --Tabela Arquivos
                                      ,pr_tab_rejeicoes IN OUT NOCOPY inss0001.typ_tab_rejeicoes --Tabela Rejeicoes
                                      ,pr_cdprogra IN crapprg.cdprogra%type   --Nome Programa
                                      ,pr_pathcoop IN VARCHAR2                --Diretorio Padrao da Cooperativa
                                      ,pr_proc_aut IN INTEGER                 --Identifica se o processo está sendo executado de forma automatica(1) ou manual(0)
                                      ,pr_des_reto OUT VARCHAR2               --Saida OK/NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --Tabela Erros
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_benef_inss_xml_div_pgto             Antigo: procedures/b1wgen0091.p/beneficios_inss_xml_divergencias_pagto
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Agosto/2014                           Ultima atualizacao: 27/07/2015
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para enviar solicitacao ao SICREDI para mandar os creditos a serem efetuados 
                 Executado em cada cada cooperativa  
  
    Alterações : 13/08/2014 Conversao Progress -> Oracle (Alisson-AMcom)
    
                 25/09/2014 - Ajustes para liberação (Adriano).
                 
                 28/01/2015 - Ajuste para enviar o codigo da ocorrencia no xml
                              de retorno (Adriano).
                              
                 30/01/2015 - Efetuar substr ao gravar o pr_nmbenefi que pode vir
                              com 30 posições e na pltable só suporta 28 (Marcos-Supero)  
                              
                 26/03/2015 - Ajuste na organização e identação da escrita
                             (Adriano).        
                             
                 27/07/2015 - Ajuste para efetuar o log no arquivo proc_message.log
                              (Adriano).                            
                
  ---------------------------------------------------------------------------------------------------------------*/
    --Variaveis de Indices
    vr_cdagenci CONSTANT NUMBER := 2; -- Será sempre enviado o PA fixo como 2 para contornar o problema 
                                      -- de PAs com mais de dois dígitos
    
    vr_index   PLS_INTEGER;
    vr_dstexto VARCHAR2(32700);
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
    
    vr_cdocorr1 VARCHAR2(4000);
    vr_cdocorr2 VARCHAR2(4000);
    vr_des_reto VARCHAR2(3);           
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;                                       
    
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
			GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0001.pc_benef_inss_xml_div_pgto');
      
      --limpar tabela erros
      pr_tab_erro.DELETE;
      
      /* Atualiza cdcooper */
      vr_cdocorr1:= NULL;
      vr_cdocorr2:= NULL;

      --Tipo de Divergencia
      CASE pr_tpdiverg
        WHEN 1 THEN
          vr_cdocorr1:= 'CPF_INVALIDO';
          vr_cdocorr2:= 'CPF/CNPJ INVALIDO -> '||pr_nrcpfcgc;
        WHEN 2 THEN  
          vr_cdocorr1:= 'CC_POUPANCA_INVALIDO';
          vr_cdocorr2:= 'NR C/C - CONTA ENCERRADA -> '||pr_nrdconta;
        WHEN 3 THEN  
          vr_cdocorr1:= 'FALTA_DADOS_CADASTRAIS';
          vr_cdocorr2:= 'ERRO DADOS CADASTRAIS [AGESIC:'||CASE pr_ercadcop WHEN TRUE THEN 'yes' ELSE 'no' END||
                                              '][TTL:'||CASE pr_ercadttl WHEN TRUE THEN 'yes' ELSE 'no' END||']';
        ELSE NULL;
      END CASE; 
      
      --Se nao tiver conciliacao
      IF upper(pr_dscritic) = 'SEM CONCILIACAO' THEN
        vr_cdocorr2:= 'PAGAMENTO JA EFETUADO';
      END IF; 
      
      --Bloco Divergencia
      IF pr_proc_aut = 1 THEN
        BEGIN
          --Gerar cabecalho XML
          inss0001.pc_gera_cabecalho_xml (pr_idservic => 2   /* Rejeitar */
                                         ,pr_nmmetodo => 'InRejeitarBeneficioINSS'
                                         ,pr_dstexto  => vr_dstexto     --Texto do Arquivo de Dados
                                         ,pr_des_reto => vr_des_reto    --Retorno OK/NOK
                                         ,pr_dscritic => vr_dscritic);  --Descricao da Critica
                                         
          --Se ocorreu erro
          IF vr_des_reto = 'NOK' THEN
            RAISE vr_exc_erro;
          END IF;

          /*Criar demais tags Unidade Atendimento*/  
          vr_dstexto:= vr_dstexto||
                       '<Beneficio v1:ID="'||pr_cdbenefi||'"/>'||
                          '<UnidadeAtendimento NumeroDocumento="01" v11:TipoPessoa="PESSOA_FISICA" v1:ID="0">'||
                             '<v15:Cooperativa>'||
                                 '<v15:CodigoCooperativa>'||pr_cdagesic||'</v15:CodigoCooperativa>'||
                                    '<v15:UnidadesAtendimento><v15:UnidadeAtendimento/></v15:UnidadesAtendimento>'||
                                 '</v15:Cooperativa>'||
                                 '<v15:NumeroUnidadeAtendimento>'||vr_cdagenci||'</v15:NumeroUnidadeAtendimento>'||
                          '</UnidadeAtendimento>'||
                          '<CodigoOcorrencia>'||vr_cdocorr1||'</CodigoOcorrencia>'||
                       '</InRejeitarBeneficioINSS>' ;
     
          --Envia Requisicao Via MQ
          inss0001.pc_benef_inss_envia_req_mq (pr_cdcooper => pr_cdcooper    --Codigo Cooperativa
                                              ,pr_dtmvtolt => pr_dtmvtolt    --Data movimento
                                              ,pr_cdoperad => NULL           --Codigo operador
                                              ,pr_cdprogra => pr_cdprogra    --Nome Programa
                                              ,pr_idservic => 2 /* Divergencias */ --Identificador Servico
                                              ,pr_dstexto  => vr_dstexto     --Texto do arquivo
                                              ,pr_nrrecben => pr_nrrecben    --Numero Recebimento Benficiario (NB)
                                              ,pr_pathcoop => pr_pathcoop    --Diretorio Padrao da Cooperativa
                                              ,pr_nmarqlog => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE') --Nome Arquivo Log
                                              ,pr_dscritic => vr_dscritic);  --Descricao Erro   
          --Se ocorreu erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN NULL;
        END;  
      END IF;
           
      /* Cria temp-tables para processamento do relatorio de divergencias    
         Parte 1 do relatorio de Rejeicoes [Sintetico] */         
      --Criar indice para arquivos e rejeicoes
      vr_index:= pr_tab_arquivos.COUNT + 1;
      pr_tab_arquivos(vr_index).cdcooper:= pr_cdcooper;
      pr_tab_arquivos(vr_index).cdagenci:= pr_cdagenci;
      pr_tab_arquivos(vr_index).nmarquiv:= pr_nmarquiv;
      pr_tab_arquivos(vr_index).dsstatus:= pr_dscritic;
       
      /* Parte 2 do relatorio de Rejeicoes [Analitico] */
      pr_tab_rejeicoes(vr_index).cdcooper:= pr_cdcooper;
      pr_tab_rejeicoes(vr_index).cdagenci:= pr_cdagenci;
      pr_tab_rejeicoes(vr_index).nrdconta:= pr_nrdconta;
      pr_tab_rejeicoes(vr_index).nrrecben:= pr_nrrecben;
      pr_tab_rejeicoes(vr_index).nmrecben:= substr(pr_nmbenefi,1,28);
      pr_tab_rejeicoes(vr_index).dtinipag:= pr_dtdpagto;
      pr_tab_rejeicoes(vr_index).vllanmto:= pr_vlrbenef;
      pr_tab_rejeicoes(vr_index).dscritic:= vr_cdocorr2;
      
      --Return OK
      pr_des_reto:= 'OK';   
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_reto:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                             
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        vr_dscritic := 'Erro na pc_benef_inss_xml_div_pgto --> '|| SQLERRM;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      
  END pc_benef_inss_xml_div_pgto;

  /* Procedimento para retorno do webservice  */                              
  PROCEDURE pc_benef_inss_ret_webservc(pr_cdcooper IN crapcop.cdcooper%type   --Cooperativa
                                      ,pr_idorigem IN INTEGER                 --Origem Processamento
                                      ,pr_cdoperad IN VARCHAR2                --Operador
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%type   --Data Movimento
                                      ,pr_nmdatela IN VARCHAR2                --Nome da tela
                                      ,pr_cdprogra IN crapprg.cdprogra%type   --Nome Programa
                                      ,pr_arqenvio IN VARCHAR2                --Nome Arquivo Envio
                                      ,pr_movarqto IN VARCHAR2                --Nome Arquivo Copia
                                      ,pr_arqreceb IN VARCHAR2                --Nome Arquivo Recebimento 
                                      ,pr_nmarqlog IN VARCHAR2                --Nome Arquivo Log
                                      ,pr_des_reto OUT VARCHAR2               --Saida OK/NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --Tabela Erros
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_benef_inss_ret_webservc      Antigo: procedures/b1wgen0091.p/beneficios_inss_verifica_retorno_webservice
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - Amcom
    Data     : Agosto/2014                           Ultima atualizacao: 24/02/2016
  
    Dados referentes ao programa:
  
    Frequencia: -----
    Objetivo   : WebService - Verifica retorno do WebService  
  
    Alterações : 08/08/2014 Conversao Progress -> Oracle (Alisson-AMcom)
                 
                 25/09/2014 - Ajustes para liberação (Adriano).
                 
                 15/06/2015 - Ajuste para mover os arquivos de envio/recebimento do diretório
                              arq para o salvar sem que sejam sobreescritos
                             (Adriano).
                
                 16/02/2016 - Ajuste na rotina pc_benef_inss_ret_webservc para tratar corretamente
                              o retorno enviado pelo SICREDI
                              (Adriano - SD 402006). 
                               
                 24/02/2016 - Ajuste para mover os arquivos de request/response para o diretório salvar
                              em caso de algum erro na rotina
                              (Adriano).             
                              
                              
  ---------------------------------------------------------------------------------------------------------------*/
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.nmrescop
          ,crapcop.nmextcop
          ,crapcop.dsdircop
          ,crapcop.cdagesic
      FROM crapcop crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
     
    rw_crapcop cr_crapcop%ROWTYPE;
    
    --Tabela para receber arquivos lidos no unix
    vr_tab_arquivo  gene0002.typ_split;  
    
    --Variaveis Locais
    vr_dsdlinha VARCHAR2(100);
    vr_dsdircop VARCHAR2(100);
    vr_nmnewarq VARCHAR2(100);
    vr_cdmsgarq INTEGER;
    vr_listadir VARCHAR2(32700);
    vr_returnvl VARCHAR(3) := 'NOK';
    
    --Varaiveis para Arquivos
    vr_nmdireto VARCHAR2(100);
    vr_nmarquiv VARCHAR2(100);
    vr_comando  VARCHAR2(400);
    vr_typ_saida VARCHAR2(3);
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);  
    vr_dscritic2 VARCHAR2(400); 
                                         
    --Variaveis de Excecoes
    vr_exc_erro     EXCEPTION;
    vr_exc_controla EXCEPTION;    
    vr_exc_saida    EXCEPTION;
                                      
    BEGIN
      
      --Limpar tabela memoria
      pr_tab_erro.DELETE;
      
      --Inicializar variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      vr_dsdlinha:= NULL;
      vr_dsdircop:= NULL;
      vr_nmnewarq:= NULL;
      vr_cdmsgarq:= 0;
      
      BEGIN
    	  -- Incluir nome do módulo logado - Chamado 664301
		  	GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_benef_inss_ret_webservc');
      
        -- Verifica se a cooperativa esta cadastrada
        OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
        
        FETCH cr_crapcop INTO rw_crapcop;
        
        -- Se não encontrar
        IF cr_crapcop%NOTFOUND THEN          
                
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapcop;          
               
          -- Montar mensagem de critica
          vr_cdcritic := 651;
          
          -- Busca critica
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
          
          RAISE vr_exc_controla;    
                
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_crapcop;
        END IF;
        
        --Separar arquivo do path
        gene0001.pc_separa_arquivo_path(pr_caminho => pr_arqreceb --Arquivo Recebimento
                                       ,pr_direto  => vr_nmdireto --Nome Diretorio
                                       ,pr_arquivo => vr_nmarquiv); --Nome Arquivo
                                  
        --Buscar a lista de arquivos do diretorio
        gene0001.pc_lista_arquivos(pr_path     => vr_nmdireto   --Nome Diretorio
                                  ,pr_pesq     => vr_nmarquiv   --Nome Arquivo
                                  ,pr_listarq  => vr_listadir   --Lista de Arquivos
                                  ,pr_des_erro => vr_dscritic); --Mensagem Erro
      
        -- se ocorrer erro ao recuperar lista de arquivos registra no log
        IF trim(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_controla;
        ELSE
          --Carregar a lista de arquivos na temp table
          vr_tab_arquivo:= gene0002.fn_quebra_string(pr_string => vr_listadir);
        END IF;

        /* Nao existem arquivos para serem importados */
        IF vr_tab_arquivo.COUNT = 0 THEN
          --Mensagem Critica
          vr_dscritic:= 'Arquivo de retorno do webservice nao encontrado.';
          
          --Levantar Excecao
          RAISE vr_exc_controla;
        END IF;          

        /* Define Nome do Novo Arquivo */
        vr_dsdircop:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'log');
        --Nome Arquivo Novo                                    
        vr_nmnewarq:= vr_dsdircop||'/'||'inss-webservice.txt';
        
        -- Comando para extrair informacoes do arquivo recebido
        vr_comando:= 'grep -Eiq "OutEnqueueBeneficioINSS" '||pr_arqreceb||
                     ' ; echo $? > '||vr_nmnewarq||' 2> /dev/null';

        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
                              
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
          
          -- retornando ao programa chamador
          RAISE vr_exc_controla;
          
        END IF;
      
        /* Importa primeira linha do novo arquivo para validacao */
        vr_comando:= 'head -1 '||vr_nmnewarq;
        
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dsdlinha);
                              
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
          
          -- retornando ao programa chamador
          RAISE vr_exc_controla;
          
        END IF;
            
        BEGIN  
          --É realizado o replace do chr(10), pois ele é inserido no vr_dsdlinha quando
          --a rotina pc_OScommand pega o conteúdo do arquivo, para ser possível pegar a informação
          --correta e coloca-la na vr_cdmsgarq sem que gere problema.            
          vr_cdmsgarq:= TO_NUMBER(trim(SUBSTR(replace(vr_dsdlinha,CHR(10),''),1,3)));         
          
        EXCEPTION
          WHEN OTHERS THEN

            --monta mensagem de critica            
            vr_dscritic:= 'Erro ao verificar conteudo do arquivo de retorno. ' || sqlerrm;
            
            --Sair Bloco
            RAISE vr_exc_controla;  
        END;      
            
        /* Ocorreu Erro, Gera Log */
        IF NVL(vr_cdmsgarq,0) <> 0 THEN
          
          --monta mensagem de critica
          vr_dscritic:= 'Retorno invalido enviado pelo SICREDI.';
          
          --Sair Bloco
          RAISE vr_exc_controla;                                          
        END IF;  
        
        --Gera exceção
        RAISE vr_exc_saida;
        
      EXCEPTION
        WHEN vr_exc_controla THEN
          
          --Com problemas
          vr_returnvl := 'NOK';
                                                    
        WHEN vr_exc_saida THEN
          
          --Sem problemas
          vr_returnvl := 'OK'; 
                                
        WHEN OTHERS THEN
                                  
          --Sem problemas
          vr_returnvl := 'NOK';
          
      END;
            
      --Remover Arquivos 
      vr_comando:= 'rm '||vr_nmnewarq||' 2> /dev/null';
      
          --Executar o comando no unix
          GENE0001.pc_OScommand (pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_dsdlinha);
                                
          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            
        --Monta mensagem de critica
        vr_dscritic2:= 'Nao foi possivel executar comando unix: '||vr_comando;            
            -- retornando ao programa chamador
            RAISE vr_exc_erro;
            
          END IF;                                         

      --Separar arquivo do path
      gene0001.pc_separa_arquivo_path(pr_caminho => pr_arqenvio --Arquivo Envio
                                     ,pr_direto  => vr_nmdireto --Nome Diretorio
                                     ,pr_arquivo => vr_nmarquiv); --Nome Arquivo
                                     
      /* Criptografa e Move Arquivo Envio */
      inss0001.pc_criptografa_move_arquiv (pr_cdcooper => pr_cdcooper
                                          ,pr_cdprogra => pr_cdprogra
                                          ,pr_nmarquiv => pr_arqenvio --Arquivo Orig
                                          ,pr_arqdesti => pr_movarqto||'/'||vr_nmarquiv --Nome arq Destino
                                          ,pr_dsmensag => 'INSS SOLICITA BENEFICIOS - CRIPTO' --Mensagem Log (se erro)
                                          ,pr_nmarqlog => pr_nmarqlog              --Nome Arquivo Log
                                          ,pr_dscritic => vr_dscritic2);
                                          
      --Se ocorreu erro
      IF vr_dscritic2 IS NOT NULL THEN
        --Retorno NOK
        RAISE vr_exc_erro;
      END IF;  
      
      --Separar arquivo do path
      gene0001.pc_separa_arquivo_path(pr_caminho => pr_arqreceb --Arquivo Recebimento
                                     ,pr_direto  => vr_nmdireto --Nome Diretorio
                                     ,pr_arquivo => vr_nmarquiv); --Nome Arquivo
                                     
      /* Criptografa e Move Arquivo Retorno */
      inss0001.pc_criptografa_move_arquiv (pr_cdcooper => pr_cdcooper
                                          ,pr_cdprogra => pr_cdprogra
                                          ,pr_nmarquiv => pr_arqreceb -- Arquivo Orig  
                                          ,pr_arqdesti => pr_movarqto||'/'||vr_nmarquiv --Nome arq Destino 
                                          ,pr_dsmensag => 'INSS SOLICITA BENEFICIOS - CRIPTO' --Mensagem Log (se erro) 
                                          ,pr_nmarqlog => pr_nmarqlog --Nome Arquivo Log
                                          ,pr_dscritic => vr_dscritic2);
                                          
      --Se ocorreu erro
      IF vr_dscritic2 IS NOT NULL THEN
        --Retorno NOK
        RAISE vr_exc_erro;
      END IF;  

      --Se ocorreu erro
      IF vr_returnvl <> 'OK' OR vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        --Retorno NOK
        RAISE vr_exc_erro;
      END IF;
        
      --Retorno OK
      pr_des_reto:= 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        
        IF vr_dscritic2 IS NOT NULL THEN
          
          -- Escrever no log qual arquivo processou com erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato                                   
                                    ,pr_nmarqlog     => pr_nmarqlog
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || pr_cdprogra || ' --> ' || 
                                                    'ERRO: ' || vr_dscritic2
                                    ,pr_cdprograma   => pr_cdprogra
                                                        );

        END IF;
        
        IF vr_cdcritic = 0 AND vr_dscritic IS NULL THEN
        
          --Monta mensagem de erro
          vr_dscritic := 'Erro na pc_benef_inss_ret_webservc.';
          
        END IF;
        
        -- Retorno não OK
        pr_des_reto:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                             
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        vr_dscritic := 'Erro na pc_benef_inss_ret_webservc --> '|| SQLERRM;
        
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                             
  END pc_benef_inss_ret_webservc;                                 

  --Procedimento que envia solicitacao ao SICREDI para mandar os creditos a serem efetuados                                               
  PROCEDURE pc_benef_inss_solic_cred(pr_cdcooper IN crapcop.cdcooper%type   --Cooperativa
                                    ,pr_idorigem IN INTEGER                 --Origem Processamento
                                    ,pr_cdoperad IN VARCHAR2                --Operador
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%type   --Data Movimento
                                    ,pr_nmdatela IN VARCHAR2                --Nome da tela
                                    ,pr_cdprogra IN crapprg.cdprogra%type   --Nome Programa 
                                    ,pr_des_reto OUT VARCHAR2               --Saida OK/NOK
                                    ,pr_cdcritic OUT INTEGER                --Codigo do Erro
                                    ,pr_dscritic OUT VARCHAR2) IS           --Descricao do Erro
  /*---------------------------------------------------------------------------------------------------------------
   
      Programa : pc_benef_inss_solic_cred             Antigo: procedures/b1wgen0091.p/beneficios_inss_solicitacao_creditos
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Alisson C. Berrido - Amcom
      Data     : Agosto/2014                           Ultima atualizacao: 21/06/2016
  
     Dados referentes ao programa:
  
     Frequencia: -----
     Objetivo   : Procedure para enviar solicitacao ao SICREDI para mandar os creditos a serem efetuados 
                  Executado em cada cada cooperativa  
  
     Alterações : 07/08/2014 - Conversao Progress -> Oracle (Alisson-AMcom)
  
                  17/09/2014 - Ajuste para considerar o sysdate no envio do xml
                               (Adriano)
                               
                  25/09/2014 - Ajustes para liberação (Adriano).
                  
                  22/10/2014 - Ajuste para passar os parametros corretos a procedure pc_XML_para_arquivo
                               (Adriano).
                               
                  30/01/2015 - Correção no tamanho das variaveis de mensagem 
                               (Marcos-Supero)   
                               
                  30/03/2015 - Retirado do proc_batch.log o envio da mensagem que
                               foi solicitado os créditos com sucesso
                               (Adriano)         
                               
                  15/06/2015 - Alterado nomenclatura dos arquivos request/response 
                              (Adriano).
                                                           
                  29/02/2016 - Ajuste para passar o pr_nmdatela no lugar do pr_cdprogra
                               ao chamar a rotina que trata o retorno do web service, para
                               gravar no log o nome da tela corretamente
                               (Adriano - SD 409943).
                
                  09/03/2016 - feita a troca na geração do log que gerava no batch para o message conforme 
                             solicitado no chamado 396313. (Kelvin)                              
                               
                  21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                              (Adriano - SD 473539).
                                        
  ---------------------------------------------------------------------------------------------------------------*/
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.nmrescop
          ,crapcop.nmextcop
          ,crapcop.dsdircop
          ,crapcop.cdagesic
      FROM crapcop crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
     
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Cursor para busca a agencia
    CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE) IS
    SELECT crapage.cdorgins
      FROM crapage crapage
     WHERE crapage.cdcooper = pr_cdcooper 
       AND crapage.cdorgins <> 0;
    rw_crapage cr_crapage%ROWTYPE;
    
    --tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Variaveis Locais
    vr_dthrrefe  VARCHAR2(100);
    
    --Variaveis Arquivo
    vr_typ_saida VARCHAR2(3);
    vr_arqenvio  VARCHAR2(100);
    vr_arqreceb  VARCHAR2(100);
    vr_nmarqtmp  VARCHAR2(100);
    vr_dstexto   VARCHAR2(32600);
    vr_comando   VARCHAR2(32767);
    vr_nmdireto  VARCHAR2(100);
    vr_dshorari  VARCHAR2(10);
    vr_dscomora  VARCHAR2(1000); 
    vr_dsdirbin  VARCHAR2(1000); 
    vr_nmdireto_arq VARCHAR2(100);
    vr_nmdireto_salvar VARCHAR2(100);
    vr_index           NUMBER;
    
    --Variaveis XML
    vr_clob CLOB;
    
    --Tabela de Memoria de agencias pagadoras
    TYPE typ_tab_crapage IS TABLE OF crapage.cdorgins%TYPE INDEX BY PLS_INTEGER;
    vr_tab_crapage typ_tab_crapage;
    
    --Variaveis de Criticas
    vr_cdcritic  INTEGER;
    vr_dscritic  VARCHAR2(4000);
    vr_des_reto  VARCHAR2(3);    
                                       
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;
    vr_exc_orgao EXCEPTION;     
                                       
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_benef_inss_solic_cred');      
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      vr_arqenvio:= NULL;
      vr_arqreceb:= NULL;
      vr_dthrrefe:= to_char(SYSDATE,'YYYY-MM-DD');
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise        
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic:= 651;
        vr_dscritic:= NULL;
        
        --Levantar Excecao
        RAISE vr_exc_erro; 
        
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      --Limpar tabela memoria orgaos pagadores
      vr_tab_crapage.DELETE;
      
      --Carregar tabela orgaos Pagadores
      FOR rw_crapage IN cr_crapage (pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapage(rw_crapage.cdorgins):= rw_crapage.cdorgins;
      END LOOP;
 
      /* SE A COOPERATIVA NAO TIVER ORGAOS PAGADORES, RETORNA */
      IF vr_tab_crapage.COUNT = 0 THEN 
        
        -- Montar mensagem de critica
        vr_cdcritic:= 0;
        vr_dscritic:= 'Cooperativa sem Orgao Pagador cadastrado.';
        
        --Levantar Excecao
        RAISE vr_exc_orgao;
        
      END IF;  

      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.OPEN(vr_clob, dbms_lob.lob_readwrite);
      
      --Gerar cabecalho XML
      inss0001.pc_gera_cabecalho_xml (pr_idservic => 1              /* Solicita Pagamentos */
                                     ,pr_nmmetodo => 'ben:InEnqueueBeneficioINSS'
                                     ,pr_dstexto  => vr_dstexto     --Arquivo Dados
                                     ,pr_des_reto => vr_des_reto    --Retorno OK/NOK
                                     ,pr_dscritic => vr_dscritic);  --Descricao da Critica
                                     
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
      
      /*Criar demais tags Unidade Atendimento*/  
      vr_dstexto:= vr_dstexto||
                   '<v1:UnidadeAtendimento NumeroDocumento="01" v11:TipoPessoa="PESSOA_FISICA" v1:ID="0">'||
                     '<v1:Cooperativa>'||
                        '<v1:CodigoCooperativa>'||rw_crapcop.cdagesic||'</v1:CodigoCooperativa>'||
                        '<v1:UnidadesAtendimento>'||
                           '<v1:UnidadeAtendimento/>'||
                        '</v1:UnidadesAtendimento>'||
                     '</v1:Cooperativa>'||
                     '<v1:NumeroUnidadeAtendimento/>'||
                   '</v1:UnidadeAtendimento>'||
                   '<ben:DataReferencia>'||vr_dthrrefe||'</ben:DataReferencia>'||
                   '<ben:OrgaosPagadores>';
      
      --Percorrer todas as agencias pagadoras
      vr_index := vr_tab_crapage.FIRST;
      
      WHILE vr_index IS NOT NULL LOOP
      
        /*Criar tag Orgao Pagador*/                      
        vr_dstexto:= vr_dstexto||'<dad:OrgaoPagador><v15:NumeroOrgaoPagador>'||
                                 vr_tab_crapage(vr_index)||                   
                                 '</v15:NumeroOrgaoPagador></dad:OrgaoPagador>';
        
        -- Buscar o próximo
        vr_index := vr_tab_crapage.NEXT(vr_index);
        
      END LOOP;  
      
      --Finalizar tag OrgaosPagadores/beneficio/SoapEnv e Envelope
      vr_dstexto:= vr_dstexto||'</ben:OrgaosPagadores></ben:InEnqueueBeneficioINSS>'||
                               '</soapenv:Body></soapenv:Envelope>';

      -- Atribuir texto (string) ao CLOB
      gene0002.pc_escreve_xml(vr_clob,vr_dstexto,' ',TRUE);     
      
      -- Busca do diretório base da cooperativa para a geração de arquivos
      vr_nmdireto:= gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
				    			     	 	 		   	       ,pr_cdcooper => pr_cdcooper   --> Cooperativa
				  	   			    				         ,pr_nmsubdir => NULL);        --> Raiz
                                         
      --Montar Diretorios de Arquivos e Salvar
      vr_nmdireto_arq:= vr_nmdireto||'/arq';
      vr_nmdireto_salvar:= vr_nmdireto||'/salvar/inss';

      --Buscar Time
      vr_dshorari:= gene0002.fn_busca_time;  
                                             
      --Diretorio Arquivos Recebidos                                        
      vr_arqreceb:= vr_nmdireto_arq||'/'||'INSS.SOAP.RSOLBEN'||'.'||
                    to_char(pr_dtmvtolt,'DDMMYYYY')||'.'||vr_dshorari;
                    
      --Diretorio Arquivos Envio 
      vr_nmarqtmp:= 'INSS.SOAP.ESOLBEN'||'.'||to_char(pr_dtmvtolt,'DDMMYYYY')||
                    '.'||vr_dshorari;
                    
      --Arquivo de Envio com path                   
      vr_arqenvio:= vr_nmdireto_arq||'/'||vr_nmarqtmp;

      --Gerar Arquivo XML Fisico
      gene0002.pc_XML_para_arquivo(pr_XML      => vr_clob             --> Instância do XML Type
                                  ,pr_caminho  => vr_nmdireto_arq     --> Diretório para saída
                                  ,pr_arquivo  => vr_nmarqtmp         --> Nome do arquivo de saída
                                  ,pr_des_erro => vr_dscritic);       --> Retorno de erro, caso ocorra
      
      
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        
        --Fechar Clob e Liberar Memoria	
        dbms_lob.close(vr_clob);
        dbms_lob.freetemporary(vr_clob); 
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF; 

      --Fechar Clob e Liberar Memoria	
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob); 
      
      --Buscar parametros 
      vr_dscomora:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_EXEC_SHELL');
      vr_dsdirbin:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_CECRED_BIN');
      
      --se nao encontrou
      IF vr_dscomora IS NULL OR 
         vr_dsdirbin IS NULL THEN
        
        --Montar mensagem erro        
        vr_dscritic:= 'Nao foi possivel selecionar parametros.';
        
        --Gera exceção
        RAISE vr_exc_erro;
        
      END IF;
                    
      --Copiar Arquivo
      vr_comando:=  vr_dscomora||' perl_remoto '|| vr_dsdirbin || 'SendSoapSICREDI.pl --servico='||
                    chr(39)||'6'||chr(39)||' < '|| vr_arqenvio ||' > '|| vr_arqreceb;

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
                           
      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        
        --Monta mensagem de critica
        vr_dscritic:= 'Não foi possível executar comando unix: '||
                      vr_comando||' - '||vr_dscritic;
                      
        --Gera exceção
        RAISE vr_exc_erro;
        
      END IF;
      
      --Retorno do WebService
      inss0001.pc_benef_inss_ret_webservc (pr_cdcooper => pr_cdcooper   --Cooperativa
                                          ,pr_idorigem => pr_idorigem   --Origem Processamento
                                          ,pr_cdoperad => pr_cdoperad   --Operador
                                          ,pr_dtmvtolt => pr_dtmvtolt   --Data Movimento
                                          ,pr_nmdatela => pr_nmdatela   --Nome da tela
                                          ,pr_cdprogra => pr_nmdatela   --Nome Programa
                                          ,pr_arqenvio => vr_arqenvio   --Nome Arquivo Envio
                                          ,pr_movarqto => vr_nmdireto_salvar   --Nome Arquivo Copia
                                          ,pr_arqreceb => vr_arqreceb   --Nome Arquivo Recebimento
                                          ,pr_nmarqlog => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')          --Nome Arquivo Log
                                          ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                          ,pr_tab_erro => vr_tab_erro); --Tabela Erros
                                          
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT = 0 THEN
          --Montar Mensagem
          vr_dscritic:= 'Nao foi possivel verificar o retorno do webservice.';
        ELSE
          --Primeiro erro da tabela
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        END IF; 
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF; 

      --Retornar OK
      pr_des_reto:= 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto:= 'NOK';
        
        --Retornar Codigo e Mensagem Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic; 
        
      WHEN vr_exc_orgao THEN
        -- Retorno não OK
        pr_des_reto:= 'NOK';
        
        --Retornar Codigo e Mensagem Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic; 
        
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto:= 'NOK';
        
        --Monta mensagem de erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na pc_benef_inss_solic_cred --> '|| sqlerrm;
        
  END pc_benef_inss_solic_cred;
    
  --Procedure para Confirmar Pagamento beneficio INSS
  PROCEDURE pc_benef_inss_confir_pagto(pr_cdcooper IN crapcop.cdcooper%type --Codigo Cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%type --Codigo Agencia
                                      ,pr_cdbenefi IN NUMBER                --Codigo Beneficio
                                      ,pr_cdagesic IN INTEGER               --Agencia Sicredi
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%type --Data movimento
                                      ,pr_cdprogra IN crapprg.cdprogra%type --Codigo Programa
                                      ,pr_nrrecben IN NUMBER                --Numero Recebimento Benficiario (NB)
                                      ,pr_pathcoop IN VARCHAR2              --Diretorio Padrao da Cooperativa
                                      ,pr_dscritic OUT VARCHAR2) IS         --Saida Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_benef_inss_confir_pagto             Antigo: procedures/b1wgen0091.p/beneficios_inss_xml_confirma_pagamento 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - Amcom
    Data     : Agosto/2014                           Ultima atualizacao: 27/07/2015
  
    Dados referentes ao programa:
  
    Frequencia: -----
    Objetivo   : Procedure para Confirmar Pagamento beneficio INSS
                 Via MQ Gera XML para confirmacao do Pagamento Beneficio 
                  
  
    Alterações : 14/08/2014 Conversao Progress -> Oracle (Alisson-AMcom)
    
                 25/09/2014 - Ajustes para liberação (Adriano).
                 
                 26/03/2015 - Ajuste na organização e identação da escrita
                              (Adriano).
                              
                 27/07/2015 - Ajuste para efetuar o log no arquivo proc_message.log
                             (Adriano).             
                
  ---------------------------------------------------------------------------------------------------------------*/
      --Variaveis Locais
      vr_cdagenci CONSTANT NUMBER := 2; -- Será sempre enviado o PA fixo como 2 para contornar o problema 
                                        -- de PAs com mais de dois dígitos
      
      vr_dstexto VARCHAR2(32000);
      
      --Variaveis de Criticas
      vr_dscritic VARCHAR2(4000); 
      vr_des_reto VARCHAR2(3);      
           
      --Variaveis de Excecoes
      vr_exc_erro EXCEPTION;    
                                         
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0001.pc_benef_inss_confir_pagto');      
      
      --Inicializar saida erro
      pr_dscritic:= NULL;

      --Gerar cabecalho XML
      inss0001.pc_gera_cabecalho_xml (pr_idservic => 3   /* Confirma Pagamento */
                                     ,pr_nmmetodo => 'InPagarBeneficioINSS'
                                     ,pr_dstexto  => vr_dstexto     --Texto do Arquivo de Dados
                                     ,pr_des_reto => vr_des_reto    --Retorno OK/NOK
                                     ,pr_dscritic => vr_dscritic);  --Descricao da Critica
      
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      /*Criar demais tags Unidade Atendimento*/  
      vr_dstexto:= vr_dstexto||
                     '<Beneficio v1:ID="'||pr_cdbenefi||'"/>'||
                        '<UnidadeAtendimento NumeroDocumento="01" v11:TipoPessoa="PESSOA_FISICA" v1:ID="0">'||
                           '<v15:Cooperativa>'||
                              '<v15:CodigoCooperativa>'||pr_cdagesic||'</v15:CodigoCooperativa>'||
                              '<v15:UnidadesAtendimento><v15:UnidadeAtendimento/></v15:UnidadesAtendimento>'||
                           '</v15:Cooperativa>'||
                           '<v15:NumeroUnidadeAtendimento>'||vr_cdagenci||'</v15:NumeroUnidadeAtendimento>'||
                        '</UnidadeAtendimento>'||
                     '</InPagarBeneficioINSS>' ;
     
      --Envia Requisicao Via MQ
      inss0001.pc_benef_inss_envia_req_mq (pr_cdcooper => pr_cdcooper    --Codigo Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt    --Data movimento
                                          ,pr_cdoperad => NULL           --Codigo operador
                                          ,pr_cdprogra => pr_cdprogra    --Nome Programa
                                          ,pr_idservic => 3 /* Pagamento Beneficio */ --Identificador Servico
                                          ,pr_dstexto  => vr_dstexto     --Texto do arquivo
                                          ,pr_nrrecben => pr_nrrecben    --Numero Recebimento Benficiario (NB)
                                          ,pr_pathcoop => pr_pathcoop    --Diretorio Padrao da Cooperativa
                                          ,pr_nmarqlog => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE') --Nome para arquivo Log
                                          ,pr_dscritic => vr_dscritic);  --Descricao Erro      
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;                                   
 
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_dscritic:= vr_dscritic;
        
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_dscritic:= 'Erro na pc_benef_inss_confir_pagto --> '|| SQLERRM;
        
  END pc_benef_inss_confir_pagto;

  --Procedure para gerar credito beneficio INSS
  PROCEDURE pc_benef_inss_gera_credito(pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                      ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                      ,pr_nrcpfcgc IN crapass.nrcpfcgc%type   --Numero Cpf CGC
                                      ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                      ,pr_nrdocmto IN NUMBER                  --Numero do Documento
                                      ,pr_nrdconta IN crapass.nrdconta%type   --Numero da Conta 
                                      ,pr_vllanmto IN NUMBER                  --Valor Beneficio
                                      ,pr_tpbenefi IN VARCHAR2                --Tipo beneficio
                                      ,pr_cdbenefi IN NUMBER                  --Codigo beneficio
                                      ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%type   --Data Movimento
                                      ,pr_dtdpagto IN crapdat.dtmvtolt%type   --Data pagamento
                                      ,pr_dtcompet IN crapdat.dtmvtolt%type   --Data de Competencia do Pagamento
                                      ,pr_nmbenefi IN VARCHAR2                --Nome Beneficiario
                                      ,pr_nmarquiv IN VARCHAR2                --Nome Arquivo 
                                      ,pr_ercadttl IN BOOLEAN                 --Cadastro Titular
                                      ,pr_ercadcop IN BOOLEAN                 --Cadastro Cooperativa
                                      ,pr_cdprogra IN crapprg.cdprogra%type   --Codigo programa
                                      ,pr_pathcoop IN VARCHAR2                --Diretorio Padrao da Cooperativa
                                      ,pr_proc_aut IN INTEGER                 --Identifica se o processo está sendo executado de forma automatica(1) ou manual(0)
                                      ,pr_tab_arquivos  IN OUT NOCOPY inss0001.typ_tab_arquivos  --Tabela de Arquivos
                                      ,pr_tab_rejeicoes IN OUT NOCOPY inss0001.typ_tab_rejeicoes --Tabela de Rejeicoes
                                      ,pr_des_reto OUT VARCHAR2               --Saida OK/NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --Tabela Erros
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_benef_inss_gera_credito             Antigo: procedures/b1wgen0091.p/beneficios_inss_gera_credito 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - Amcom
    Data     : Agosto/2014                           Ultima atualizacao: 07/10/2015
  
    Dados referentes ao programa:
  
    Frequencia: -----
    Objetivo   : Procedure para gerar credito beneficio INSS 
                  
  
    Alterações : 13/08/2014 - Conversao Progress -> Oracle (Alisson-AMcom)
    
                 25/09/2014 - Ajustes para liberação (Adriano)
                 
                 30/01/2015 - Efetuar substr ao gravar o pr_nmbenefi que pode vir
                              com 30 posições e na pltable só suporta 28 (Marcos-Supero)             
                              
                 06/02/2015 - Adicionado o campo pesqbb no insert da craplcm para indicar o 
                              numero do beneficiario e a data de competencia no formado 
                              nrrecben + ";" + YYYYMM             

                 07/10/2015 - Adicionado parametro pr_proc_aut para identificar se o processo
                              esta sendo executado automaticamento pelo CRPS648 ou de forma 
                              manual pela tela PRCINS, para que seja enviado a mensagem de 
                              confirmação do pagamento apenas quando estiver rodando pelo
                              processo (Douglas - Chamado 314031)
                
   ---------------------------------------------------------------------------------------------------------------*/
      --Registro do tipo tabela craplot
      rw_craplot craplot%ROWTYPE;
      
      --Variaveis Locais
      vr_index PLS_INTEGER;
      
      --Variaveis de Criticas
      vr_dscritic VARCHAR2(4000);   
                                          
      --Variaveis de Excecoes
      vr_exc_erro EXCEPTION;                                       
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0001.pc_benef_inss_gera_credito');
      
      --limpar tabela erros
      pr_tab_erro.DELETE;
      
      --Criar Savepoint
      SAVEPOINT save_trans;
      
      --Atualizar Lote retornando informacoes para uso posterior
      BEGIN
        UPDATE craplot SET craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
                          ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                          ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                          ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + pr_vllanmto
                          ,craplot.vlinfocr = nvl(craplot.vlinfocr,0) + pr_vllanmto
         WHERE craplot.cdcooper = pr_cdcooper
           AND craplot.dtmvtolt = pr_dtmvtolt
           AND craplot.cdagenci = pr_cdagenci
           AND craplot.cdbccxlt = 100
           AND craplot.nrdolote = 10132          
         RETURNING craplot.cdcooper
                  ,craplot.dtmvtolt
                  ,craplot.cdagenci
                  ,craplot.cdbccxlt
                  ,craplot.nrdolote
                  ,craplot.tplotmov
                  ,craplot.nrseqdig
              INTO rw_craplot.cdcooper
                  ,rw_craplot.dtmvtolt
                  ,rw_craplot.cdagenci
                  ,rw_craplot.cdbccxlt
                  ,rw_craplot.nrdolote
                  ,rw_craplot.tplotmov
                  ,rw_craplot.nrseqdig;
                  
        --Se nao atualizou nenhum registro, cria o lote
        IF SQL%ROWCOUNT = 0 THEN
          
          BEGIN
            --Inserir a capa do lote retornando informacoes para uso posterior
            INSERT INTO craplot(craplot.cdcooper
                               ,craplot.dtmvtolt
                               ,craplot.cdagenci
                               ,craplot.cdbccxlt
                               ,craplot.nrdolote
                               ,craplot.tplotmov
                               ,craplot.nrseqdig
                               ,craplot.qtcompln
                               ,craplot.qtinfoln
                               ,craplot.vlcompcr
                               ,craplot.vlinfocr)
                         VALUES(pr_cdcooper
                               ,pr_dtmvtolt
                               ,pr_cdagenci
                               ,100
                               ,10132
                               ,1
                               ,1
                               ,1
                               ,1
                               ,pr_vllanmto
                               ,pr_vllanmto)
                      RETURNING craplot.cdcooper
                               ,craplot.dtmvtolt
                               ,craplot.cdagenci
                               ,craplot.cdbccxlt
                               ,craplot.nrdolote
                               ,craplot.tplotmov
                               ,craplot.nrseqdig
                           INTO rw_craplot.cdcooper
                               ,rw_craplot.dtmvtolt
                               ,rw_craplot.cdagenci
                               ,rw_craplot.cdbccxlt
                               ,rw_craplot.nrdolote
                               ,rw_craplot.tplotmov
                               ,rw_craplot.nrseqdig;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic:= 'Erro ao inserir na tabela craplot. '||SQLERRM;
              --Sair do programa
              RAISE vr_exc_erro;
          END;
        END IF;  
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao atualizar tabela craplot. '||SQLERRM;
          --Sair do programa
          RAISE vr_exc_erro;
      END;   
        
      --Inserir lancamento de Credito
      BEGIN
        INSERT INTO craplcm(craplcm.cdcooper
                           ,craplcm.dtmvtolt
                           ,craplcm.cdagenci
                           ,craplcm.cdbccxlt
                           ,craplcm.nrdolote
                           ,craplcm.nrdctabb
                           ,craplcm.nrdocmto
                           ,craplcm.nrdconta
                           ,craplcm.nrdctitg
                           ,craplcm.cdhistor
                           ,craplcm.vllanmto
                           ,craplcm.nrseqdig
                           ,craplcm.hrtransa
                           ,craplcm.cdpesqbb)
                    VALUES (pr_cdcooper
                           ,rw_craplot.dtmvtolt
                           ,rw_craplot.cdagenci
                           ,rw_craplot.cdbccxlt
                           ,rw_craplot.nrdolote
                           ,pr_nrdconta
                           ,rw_craplot.nrseqdig
                           ,pr_nrdconta
                           ,to_char(pr_nrdconta,'fm00000000')
                           ,1399
                           ,pr_vllanmto
                           ,rw_craplot.nrseqdig
                           ,gene0002.fn_busca_time 
                           ,pr_nrrecben||';'||to_char(pr_dtcompet,'YYYYMM'));
         
        
        /*M195 verificar na lista de parametros de historicos pemitidos
          e inserir tbfolha_lanaut*/
        folh0001.pc_inserir_lanaut(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                  ,pr_cdhistor => 1399
                                  ,pr_vlrenda =>  pr_vllanmto
                                  ,pr_cdagenci => rw_craplot.cdagenci
                                  ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                  ,pr_nrdolote => rw_craplot.nrdolote
                                  ,pr_nrseqdig => rw_craplot.nrseqdig
                                  ,pr_dscritic => vr_dscritic);
                                  
        IF vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_erro;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao inserir na tabela craplcm. '|| SQLERRM;          
          --Sair do programa
          RAISE vr_exc_erro;
      END;

      --Inserir Beneficio para CPF
      BEGIN
        INSERT INTO crapdbi(crapdbi.nrcpfcgc
                           ,crapdbi.dtmvtolt
                           ,crapdbi.nrrecben)
                    VALUES(pr_nrcpfcgc
                          ,pr_dtmvtolt
                          ,pr_nrrecben);   
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          --Se registro ja existir nao precisa fazer nada.
          NULL;
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao inserir na tabela crapdbi. '|| SQLERRM;
          --Sair do programa
          RAISE vr_exc_erro;
      END; 
      
      -- Verificar se o processo automatico está rodando
      -- Apenas para o automático será enviado mensagem de confirmação para o INSS
      -- Quando a execução for manual é aberto um incidente para o SICREDI atualizar os benefícios
      IF pr_proc_aut = 1 THEN
        --Confirmar Pagamento beneficio INSS
        inss0001.pc_benef_inss_confir_pagto (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa Associado
                                            ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                            ,pr_cdbenefi => pr_cdbenefi   --Codigo Beneficio
                                            ,pr_cdagesic => pr_cdagesic   --Agencia Sicredi
                                            ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                            ,pr_cdprogra => pr_cdprogra   --Codigo Programa
                                            ,pr_nrrecben => pr_nrrecben   --Numero Recebimento Benficiario (NB)
                                            ,pr_pathcoop => pr_pathcoop   --Diretorio Padrao da Cooperativa
                                            ,pr_dscritic => vr_dscritic); --Saida Erro
                                      
        --Se ocorreu erro   
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;  
      END IF;
      
      --Retorno OK
      pr_des_reto:= 'OK';       
                             
    EXCEPTION
      WHEN vr_exc_erro THEN
        
        -- Retorno não OK
        pr_des_reto:= 'NOK';
        
        -- Desfazer transacoes desse bloco
        ROLLBACK to save_trans;
        
        /* Cria temp-tables para processamento do relatorio de divergencias    
         Parte 1 do relatorio de Rejeicoes [Sintetico] */
        vr_index:= pr_tab_arquivos.COUNT + 1;
        pr_tab_arquivos(vr_index).cdcooper:= pr_cdcooper;
        pr_tab_arquivos(vr_index).cdagenci:= pr_cdagenci;
        pr_tab_arquivos(vr_index).nmarquiv:= pr_nmarquiv;
        pr_tab_arquivos(vr_index).dsstatus:= 'Erro ao gerar lancamento.'; 
        /* Parte 2 do relatorio de Rejeicoes [Analitico] */
        pr_tab_rejeicoes(vr_index).cdcooper:= pr_cdcooper;
        pr_tab_rejeicoes(vr_index).cdagenci:= pr_cdagenci;
        pr_tab_rejeicoes(vr_index).nrdconta:= pr_nrdconta;
        pr_tab_rejeicoes(vr_index).nrrecben:= pr_nrrecben;
        pr_tab_rejeicoes(vr_index).nmrecben:= substr(pr_nmbenefi,1,28);
        pr_tab_rejeicoes(vr_index).dtinipag:= pr_dtdpagto;
        pr_tab_rejeicoes(vr_index).vllanmto:= pr_vllanmto;
        pr_tab_rejeicoes(vr_index).dscritic:= 'Nao foi possivel realizar o credito.'; 
        
      WHEN OTHERS THEN
        
        -- Retorno não OK
        pr_des_reto:= 'NOK';
        
        -- Desfazer transacoes desse bloco
        ROLLBACK to save_trans;
        
        /* Cria temp-tables para processamento do relatorio de divergencias    
         Parte 1 do relatorio de Rejeicoes [Sintetico] */
        vr_index:= pr_tab_arquivos.COUNT + 1;
        pr_tab_arquivos(vr_index).cdcooper:= pr_cdcooper;
        pr_tab_arquivos(vr_index).cdagenci:= pr_cdagenci;
        pr_tab_arquivos(vr_index).nmarquiv:= pr_nmarquiv;
        pr_tab_arquivos(vr_index).dsstatus:= 'Erro ao gerar lancamento.'; 
        /* Parte 2 do relatorio de Rejeicoes [Analitico] */
        pr_tab_rejeicoes(vr_index).cdcooper:= pr_cdcooper;
        pr_tab_rejeicoes(vr_index).cdagenci:= pr_cdagenci;
        pr_tab_rejeicoes(vr_index).nrdconta:= pr_nrdconta;
        pr_tab_rejeicoes(vr_index).nrrecben:= pr_nrrecben;
        pr_tab_rejeicoes(vr_index).nmrecben:= substr(pr_nmbenefi,1,28);
        pr_tab_rejeicoes(vr_index).dtinipag:= pr_dtdpagto;
        pr_tab_rejeicoes(vr_index).vllanmto:= pr_vllanmto;
        pr_tab_rejeicoes(vr_index).dscritic:= 'Nao foi possivel realizar o credito.'; 
        
  END pc_benef_inss_gera_credito;

  --Procedure para Gerar relatorio Rejeicoes
  PROCEDURE pc_gera_relatorio_rejeic(pr_cdcooper      IN crapcop.cdcooper%type       --Codigo Cooperativa
                                    ,pr_dtmvtolt      IN crapdat.dtmvtolt%type       --Data movimento
                                    ,pr_cdprogra      IN crapprg.cdprogra%type       --Codigo Programa
                                    ,pr_tab_arquivos  IN inss0001.typ_tab_arquivos   --Tabela de Arquivos
                                    ,pr_tab_rejeicoes IN inss0001.typ_tab_rejeicoes  --Tabela de Rejeicoes
                                    ,pr_dscritic      OUT VARCHAR2) IS               --Descricao Erro                      
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_gera_relatorio_rejeic             Antigo: procedures/b1wgen0091.p/gera_relatorio_rejeicoes                
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - Amcom
    Data     : Agosto/2014                           Ultima atualizacao: 22/12/2016
  
    Dados referentes ao programa:
  
    Frequencia: -----
    Objetivo   : Procedure para gerar relatorio rejeicoes dos beneficios INSS 
                  
  
    Alterações : 13/08/2014 Conversao Progress -> Oracle (Alisson-AMcom)
  
                 28/01/2015 - Ajuste para enviar 'S' no parametro pr_flg_impri (Adriano).
                 
                 26/03/2015 - Ajuste na organização e identação da escrita
                             (Adriano).
                 
                 11/11/2015 - Ajuste para retornar corretamente a critica ao validar
                              a cooperaditva
                              (Adriano).
                 
                 22/12/2016 - Ajuste para gerar relatório com data de movimento da cooperativa
                              em questão e para postar na intranet no dia correto
                              (Adriano - SD 567303).
                 
  ---------------------------------------------------------------------------------------------------------------*/
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
     
    rw_crapcop cr_crapcop%ROWTYPE;
    
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    --Tipo de tabela para ordenar arquivos e rejeitados
    TYPE typ_tab_arq2 IS TABLE OF inss0001.typ_reg_arquivos INDEX BY VARCHAR2(200);
    TYPE typ_tab_rej2 IS TABLE OF inss0001.typ_reg_rejeicoes INDEX BY VARCHAR2(200);
    
    --Tabela Nova de Arquivos e Rejeitados
    vr_tab_arq2 typ_tab_arq2;
    vr_tab_rej2 typ_tab_rej2;
    
    --Tabela de Memoria de erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    --indices para tabelas memoria
    vr_index_arq1 PLS_INTEGER;
    vr_index_arq2 VARCHAR2(200);
    vr_index_rej1 PLS_INTEGER;
    vr_index_rej2 VARCHAR2(200);
    
    --Variaveis Locais
    vr_nmdireto  VARCHAR2(100);
    vr_nmdireto_rl VARCHAR2(100);
    vr_nmdireto_rlnsv VARCHAR2(100);
    vr_nmarqimp VARCHAR2(20):= 'crrl657.lst';
    vr_dstexto  VARCHAR2(32700);
    vr_dstxtaux VARCHAR2(32700);
    vr_clobxml  CLOB;            
                               
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;  
                                         
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0001.pc_gera_relatorio_rejeic');                  
      
      --limpar tabela erros
      pr_dscritic:= NULL;
      
      --Limpar tabela nova
      vr_tab_arq2.DELETE;
      
      --Montar tabela memoria ordenada por cooperativa/agencia/arquivos
      vr_index_arq1:= pr_tab_arquivos.FIRST;
      
      WHILE vr_index_arq1 IS NOT NULL LOOP
        
        --Novo Indice
        vr_index_arq2:= lpad(pr_tab_arquivos(vr_index_arq1).cdcooper,10,'0')||
                        lpad(pr_tab_arquivos(vr_index_arq1).cdagenci,10,'0')||
                        rpad(pr_tab_arquivos(vr_index_arq1).nmarquiv,100,'#');
                        
        --Copiar dados de uma tabela para outra
        vr_tab_arq2(vr_index_arq2):= pr_tab_arquivos(vr_index_arq1);    
                    
        --Proximo Registro
        vr_index_arq1:= pr_tab_arquivos.NEXT(vr_index_arq1);
        
      END LOOP;
        
      --Percorrer todos os arquivos da tabela nova
      vr_index_arq2:= vr_tab_arq2.FIRST;
      
      WHILE vr_index_arq2 IS NOT NULL LOOP
        
        --Se for o primeiro registro da cooperativa
        IF vr_index_arq2 = vr_tab_arq2.FIRST OR
           vr_tab_arq2(vr_index_arq2).cdcooper <> vr_tab_arq2(vr_tab_arq2.PRIOR(vr_index_arq2)).cdcooper THEN
           
          -- Verifica se a cooperativa esta cadastrada
          OPEN cr_crapcop (pr_cdcooper => vr_tab_arq2(vr_index_arq2).cdcooper);
          
          FETCH cr_crapcop INTO rw_crapcop;
          
          -- Se não encontrar
          IF cr_crapcop%NOTFOUND THEN
            -- Fechar o cursor pois haverá raise
            CLOSE cr_crapcop;
            
            -- Montar mensagem de critica
            vr_cdcritic := 651;
            
            -- Busca critica
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
            
            RAISE vr_exc_erro;
            
          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_crapcop;
          END IF;

          -- Leitura do calendário da cooperativa
					OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
          
					FETCH btch0001.cr_crapdat INTO rw_crapdat;
          
					-- Se não encontrar
					IF btch0001.cr_crapdat%NOTFOUND THEN
            
						-- Fechar o cursor pois efetuaremos raise
						CLOSE btch0001.cr_crapdat;
            
						-- Montar mensagem de critica
						vr_cdcritic := 1;
            
            -- Busca critica
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
            
						RAISE vr_exc_erro;
            
					ELSE
						-- Apenas fechar o cursor
						CLOSE btch0001.cr_crapdat;
					END IF;

          --Buscar Diretorio da Cooperativa
          vr_nmdireto:= gene0001.fn_diretorio(pr_tpdireto => 'C'
                                             ,pr_cdcooper => rw_crapcop.cdcooper
                                             ,pr_nmsubdir => NULL);
          
          --Buscar Diretorio da Cooperativa
          vr_nmdireto_rl:= vr_nmdireto||'/rl';
          vr_nmdireto_rlnsv:= vr_nmdireto||'/rlnsv';
                                 
          -- Inicializar as informações do XML de dados para o relatório
          dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
          dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
          
          --Informacoes do cabecalho
          vr_dstxtaux:= 'data="'||to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||
                        '" time="'||to_char(sysdate,'HH24:MI:SS')||'">';
                        
          --Escrever no arquivo XML
          gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                                 '<?xml version="1.0" encoding="UTF-8"?><crrl657><arquivos '||vr_dstxtaux);
                                 
        END IF; --Primeiro Registro

        --Escrever no XML
        gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                               '<arq>'||
                                  '<cdcooper>'||rw_crapcop.cdcooper||'</cdcooper>'||
                                  '<cdagenci>'||vr_tab_arq2(vr_index_arq2).cdagenci||'</cdagenci>'||
                                  '<nmarquiv>'||vr_tab_arq2(vr_index_arq2).nmarquiv||'</nmarquiv>'||
                                  '<dsstatus>'||vr_tab_arq2(vr_index_arq2).dsstatus||'</dsstatus>'||
                               '</arq>'); 
                               
        --Se for o ultimo registro da cooperativa
        IF vr_index_arq2 = vr_tab_arq2.LAST OR
           vr_tab_arq2(vr_index_arq2).cdcooper <> vr_tab_arq2(vr_tab_arq2.NEXT(vr_index_arq2)).cdcooper THEN
          
          --Limpar tabela nova rejeicoes
          vr_tab_rej2.DELETE;
          
          --Preparar nova tabela ordenada por cdcooper,cdagenci,nrbenefi,nrrecben,nmrecben,dtinipag,vllanmto 
          vr_index_rej1:= pr_tab_rejeicoes.FIRST;
          
          WHILE vr_index_rej1 IS NOT NULL LOOP
            
            --Se for mesma cooperativa  
            IF pr_tab_rejeicoes(vr_index_rej1).cdcooper = rw_crapcop.cdcooper THEN
              
              --Novo Indice
              vr_index_rej2:= lpad(pr_tab_rejeicoes(vr_index_rej1).cdcooper,10,'0')||
                              lpad(pr_tab_rejeicoes(vr_index_rej1).cdagenci,10,'0')||
                              lpad(pr_tab_rejeicoes(vr_index_rej1).nrbenefi,20,'0')||
                              lpad(pr_tab_rejeicoes(vr_index_rej1).nrrecben,20,'0')||
                              rpad(pr_tab_rejeicoes(vr_index_rej1).nmrecben,100,'#')||
                              to_char(pr_tab_rejeicoes(vr_index_rej1).dtinipag,'YYYYMMDD')||                            
                              lpad(pr_tab_rejeicoes(vr_index_rej1).vllanmto*100,30,'0'); 
                                                                                     
              --Copiar dados de uma tabela para outra
              vr_tab_rej2(vr_index_rej2):= pr_tab_rejeicoes(vr_index_rej1); 
                             
            END IF;  
            
            --Proximo Registro
            vr_index_rej1:= pr_tab_rejeicoes.NEXT(vr_index_rej1);
            
          END LOOP;

          --Finaliza TAG Arquivos e inicia creditos rejeitados
          gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</arquivos><rejeicoes>');
      
          --Escrever os pagamentos rejeitados no XML
          vr_index_rej2:= vr_tab_rej2.FIRST;
          
          WHILE vr_index_rej2 IS NOT NULL LOOP
            
            --Escrever no XML
            gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                               '<rej>'||
                                  '<cdcooper>'||vr_tab_rej2(vr_index_rej2).cdcooper||'</cdcooper>'||
                                  '<cdagenci>'||vr_tab_rej2(vr_index_rej2).cdagenci||'</cdagenci>'||
                                  '<nrdconta>'||to_char(vr_tab_rej2(vr_index_rej2).nrdconta,'fm9999g999g9')||'</nrdconta>'||
                                  '<nrrecben>'||vr_tab_rej2(vr_index_rej2).nrrecben||'</nrrecben>'||
                                  '<nmrecben>'||vr_tab_rej2(vr_index_rej2).nmrecben||'</nmrecben>'||
                                  '<dtinipag>'||to_char(vr_tab_rej2(vr_index_rej2).dtinipag,'DD/MM/YYYY')||'</dtinipag>'||
                                  '<vllanmto>'||to_char(vr_tab_rej2(vr_index_rej2).vllanmto,'fm9g999g999g990d00')||'</vllanmto>'||
                                  '<dscritic>'||substr(vr_tab_rej2(vr_index_rej2).dscritic,1,45)||'</dscritic>'||
                               '</rej>'); 
                               
            --Proximo Registro
            vr_index_rej2:= vr_tab_rej2.NEXT(vr_index_rej2);
            
          END LOOP;
          
          --Finaliza TAG Rejeitados e Relatorio
          gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</rejeicoes></crrl657>',TRUE);

          -- Gera relatório crrl657
	      gene0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop.cdcooper --> Cooperativa conectada
                                     ,pr_cdprogra  => pr_cdprogra         --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dsxml     => vr_clobxml          --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl657'          --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl657.jasper'    --> Arquivo de layout do iReport
                                     ,pr_dsparams  => NULL                --> Sem parâmetros
                                     ,pr_dsarqsaid => vr_nmdireto_rl||'/'||vr_nmarqimp  --> Arquivo final com o path
                                     ,pr_qtcoluna  => 132                 --> Colunas do relatorio
                                     ,pr_flg_gerar => 'S'                 --> Geraçao na hora
                                     ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p) 
                                     ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 1                   --> Número de cópias
                                     ,pr_sqcabrel  => 1                   --> Qual a seq do cabrel
                                     ,pr_flappend  => 'S'                 --> Ira incrementar o relatorio se ja existir 
                                     ,pr_des_erro  => vr_dscritic);       --> Saída com erro
          
          --Se ocorreu erro no relatorio
          IF vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF; 
          
          --Fechar Clob e Liberar Memoria	
          dbms_lob.close(vr_clobxml);
          dbms_lob.freetemporary(vr_clobxml); 

          --Enviar arquivo para Intranet          
          GENE0002.pc_gera_arquivo_intranet (pr_cdcooper => rw_crapcop.cdcooper --Codigo Cooperativa
                                            ,pr_cdagenci => 0                    --Codigo Agencia
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --Data movimento
                                            ,pr_nmarqimp => vr_nmdireto_rl||'/'|| vr_nmarqimp   --Nome Arquivo Impressao
                                            ,pr_nmformul => '132col'             --Nome Formulario
                                            ,pr_dscritic => vr_dscritic          --Descricao Erro
                                            ,pr_tab_erro => vr_tab_erro          --Tabela Erros
                                            ,pr_des_erro => vr_des_reto);        --Retorno OK/NOK
          
          --Se ocorreu erro
          IF vr_des_reto = 'NOK' THEN
            
            vr_dscritic:= 'inss0001.pc_gera_relatorio_rejeic --> ';
            
            --Se tem erro na tabela 
            IF vr_tab_erro.COUNT > 0 THEN
              vr_dscritic:= vr_dscritic||
                            vr_tab_erro(vr_tab_erro.FIRST).dscritic||' - '||
                            rw_crapcop.nmrescop;  
            ELSE
              vr_dscritic:= vr_dscritic||
                            'Nao foi possivel gerar o arquivo para a intranet - '||
                            rw_crapcop.nmrescop;  
            END IF; 
            
            --Levantar Excecao
            RAISE vr_exc_erro;
                        
          END IF; 
          
        END IF; --ultimo registro
        
        --Proximo Registro
        vr_index_arq2:= vr_tab_arq2.NEXT(vr_index_arq2);       
          
      END LOOP; --arquivos
        
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_dscritic:= 'Erro ao gerar relatorio de rejeicoes. '||SQLERRM;
        
  END pc_gera_relatorio_rejeic;

  --Funcao para Substituir Caracteres Especiais do XML
  FUNCTION fn_substitui_caracter (pr_string IN VARCHAR2) RETURN VARCHAR2 IS
  /*............................................................................

   Programa: fn_substitui_caracter               Antigo: Fontes/substitui_caracter.p 
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Julho/2009                          Ultima atualizacao: 27/08/2014

   Dados referentes ao programa:
   
   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Substituir caracter acentuados pelos nao acentuados, usado
               para converter strings do progrid para o ayllos.
               
   Alteracoes: 31/05/2010 - Substituir caracteres "/" e "'" por " "
               (Fernando).
               
               03/03/2011 - Deixar um espaco em branco quando aspas simples
                            (Gabriel).
                            
               05/04/2011 - Modificar o keyfunction pelo caracter 
                            correspondente.
                            Substituir o caracter '`' por branco. (Gabriel).
                            
               09/08/2013 - Adicionado replace para 'ý' e 'Ý'. (Fabricio)
               
               27/08/2014 - Conversao Progress --> Oracle (Alisson-AMcom)
               
  .............................................................................*/  
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => 'INSS0001', pr_action => 'INSS0001.fn_substitui_caracter');    
      
    DECLARE
      vr_string VARCHAR2(32767):= pr_string;
    BEGIN
      RETURN(TRANSLATE(vr_string,'áàãâäèéêëìíîïòóôõöúùûüÿñçÁÀÃÂÄÈÉÊËÌÍÎÏÒÓÔÕÖÚÙÛÜÑÇýÝ'||chr(39)||chr(96),
                                 'aaaaaeeeeiiiiooooouuuuyncAAAAAEEEEIIIIOOOOOUUUUNC'));
    EXCEPTION
      WHEN OTHERS THEN
        RETURN(NULL);
    END;
  END fn_substitui_caracter;       

  /*Função para receber um conteudo pdf criptografado na base64 e retorna-lo decodificado*/
  FUNCTION fn_base64DecodeClobAsBlob(i_data_cl CLOB) RETURN BLOB IS
    
    v_out_bl      BLOB;
    clob_size     NUMBER;
    pos           NUMBER;
    charBuff      VARCHAR2(32767);
    dBuffer       RAW(32767);
    v_readSize_nr NUMBER;
    v_line_nr     NUMBER;
    
  BEGIN
 	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => 'INSS0001', pr_action => 'INSS0001.fn_base64DecodeClobAsBlob');    
    
    --Inicializa CLOB
    dbms_lob.createTemporary (v_out_bl, TRUE, dbms_lob.call);
    
    /*Pega a posição da primeira ocorrencia encontrada no conteudo do CLOB
      dos caraceters "CHR(10) e CHR(13)" e retorna o maior valor entre 
      os 3 valores parametrizados na função GREATEST (65,chr(10),chr(13)).
      Por padrão, se o valor do caracters "CHR(10) e CHR(13)" for menor
      que 65 então, 65 será o valor utilizado.  */
    v_line_nr:=greatest(65,instr(i_data_cl,chr(10)),instr(i_data_cl,chr(13)));
    
    /*Realiza o calculo para delimitar o tamanho da leitura e não pode ultrassar 
      o tamanho de 32k (tamanho máximo do tipo VARCHAR2)*/
    v_readSize_nr:= floor(32767/v_line_nr)*v_line_nr;
    
    --Armazena o tamanho do CLOB
    clob_size := dbms_lob.getLength(i_data_cl);
    
    --Inicializa a variável de controle de posicionamento
    pos := 1; 

    WHILE (pos < clob_size) LOOP
      
      --Faz aleitura do CLOB com abse no tamanho calculo anteriormente 
      dbms_lob.read (i_data_cl, v_readSize_nr, pos, charBuff);
      
      --Armazena o conteudo lido do CLOB decriptografado
      dBuffer := UTL_ENCODE.base64_decode(utl_raw.cast_to_raw(charBuff));
      
      --Escreve no BLOB o conteúdo decriptografado
      dbms_lob.writeAppend(v_out_bl,utl_raw.length(dBuffer),dBuffer);
      
      --Pega a próxima posição (Faixa de tamanho)
      pos := pos + v_readSize_nr;
      
    END LOOP;
    
    --Retorna o BLOB decriptografado
    RETURN v_out_bl;
      
  END fn_base64DecodeClobAsBlob;

  /* Procedure para Eliminar  de Requisicao SOAP */
  PROCEDURE pc_elimina_arquivos_requis (pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa
                                       ,pr_cdprogra IN VARCHAR2                --Codigo Programa
                                       ,pr_msgenvio IN VARCHAR2                --Mensagem Envio
                                       ,pr_msgreceb IN VARCHAR2                --Mensagem Recebimento
                                       ,pr_movarqto IN VARCHAR2                --Nome Arquivo mover
                                       ,pr_nmarqlog IN VARCHAR2                --Nome Arquivo Log
                                       ,pr_des_reto OUT VARCHAR2               --Saida OK/NOK
                                       ,pr_dscritic OUT VARCHAR2) IS           --Descricao do Erro 
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_elimina_arquivos_requis             Antigo: procedures/b1wgen0091.p/elimina_arquivos_requisicao       
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Fevereiro/2015                           Ultima atualizacao: 10/02/2015
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para eliminar arquivos de requisicao soap
  
    Alterações : 10/02/2015 Conversao Progress -> Oracle (Alisson-AMcom)
    
                
  ---------------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
    
      vr_arqdesti VARCHAR2(1000);
      vr_exc_erro EXCEPTION;
    
    BEGIN
      -- Incluir nome do módulo logado
		  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0001.pc_elimina_arquivos_requis');                  	  
      
      --Inicializar Mensagem erro
      pr_des_reto:= 'OK';
      pr_dscritic:= NULL;
      
      /*Criptografa e move o arquivo de envio*/
      IF gene0001.fn_exis_arquivo(pr_caminho => pr_msgenvio) THEN   
             
        --Montar Arquivo Destino
        vr_arqdesti:= pr_movarqto||substr(pr_msgenvio,instr(pr_msgenvio,'/',-1));    
            
        /* Move Arquivo Envio */
        inss0001.pc_criptografa_move_arquiv (pr_cdcooper => pr_cdcooper     /* Codigo Cooperativa */
                                            ,pr_cdprogra => pr_cdprogra     /* Codigo Programa */
                                            ,pr_nmarquiv => pr_msgenvio     /* Arquivo Orig  */
                                            ,pr_arqdesti => vr_arqdesti     /* Nome arq Destino */
                                            ,pr_dsmensag => 'INSS - Gestao de beneficios'           
                                            ,pr_nmarqlog => pr_nmarqlog     /* Nome arq LOG */
                                            ,pr_dscritic => pr_dscritic);  /* Mensagem Log (se erro) */
        --Se ocorreu erro
        IF pr_dscritic IS NOT NULL THEN
          --Retorno NOK
          RAISE vr_exc_erro;
        END IF;
      END IF;
        
      /*Criptografa e move o arquivo de recebimento*/
      IF gene0001.fn_exis_arquivo(pr_caminho => pr_msgreceb) THEN       
         
        --Montar Arquivo Destino
        vr_arqdesti:= pr_movarqto||substr(pr_msgreceb,instr(pr_msgreceb,'/',-1));  
              
        /* Move Arquivo Envio */
        inss0001.pc_criptografa_move_arquiv (pr_cdcooper => pr_cdcooper     /* Codigo Cooperativa */
                                            ,pr_cdprogra => pr_cdprogra     /* Codigo Programa */
                                            ,pr_nmarquiv => pr_msgreceb     /* Arquivo Orig  */
                                            ,pr_arqdesti => vr_arqdesti     /* Nome arq Destino */
                                            ,pr_dsmensag => 'INSS - Gestao de beneficios'           
                                            ,pr_nmarqlog => pr_nmarqlog     /* Nome arq LOG */
                                            ,pr_dscritic => pr_dscritic);  /* Mensagem Log (se erro) */
        --Se ocorreu erro
        IF pr_dscritic IS NOT NULL THEN
          --Retorno NOK
          RAISE vr_exc_erro;
        END IF;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_reto:= 'NOK';
        pr_dscritic:= 'Erro na inss0001.pc_elimina_arquivos_requis. '||pr_dscritic;
      
      WHEN OTHERS THEN
        pr_des_reto:= 'NOK';
        pr_dscritic:= 'Erro na inss0001.pc_elimina_arquivos_requis. '||sqlerrm;
    END;        
  END pc_elimina_arquivos_requis;

  --Processar pagamentos beneficios do INSS
  PROCEDURE pc_proces_pagto_benef_inss (pr_cdcooper         IN INTEGER                    -- Codigo da Cooperativa
                                       ,pr_cdprogra         IN crapprg.cdprogra%type      -- Nome Programa 
                                       ,pr_nrdcaixa         IN INTEGER                    -- Numero Caixa
                                       ,pr_index_creditos   IN INTEGER                    -- Variavel para Indices de credito que esta sendo processado
                                       ,pr_tab_creditos     IN OUT INSS0001.typ_tab_creditos  -- Tabela de Memoria de Creditos
                                       -- Tabelas com as informações carregadas
                                       ,pr_tab_arquivos     IN OUT NOCOPY INSS0001.typ_tab_arquivos  -- Tabela de Memoria de Arquivos 
                                       ,pr_tab_crapage      IN INSS0001.typ_tab_crapage   -- Tabela de Agencias
                                       ,pr_tab_salvar       IN INSS0001.typ_tab_salvar    -- Tabela de Diretorios
                                       ,pr_tab_dircoop      IN INSS0001.typ_tab_salvar    -- Tabela de Diretorios
                                       ,pr_tab_cdagesic     IN INSS0001.typ_tab_cdagesic  -- Tabela de Agencias Sicredi
                                       ,pr_tab_crapdat      IN OUT INSS0001.typ_tab_crapdat   -- Tabela de Datas por Cooperativa
                                       ,pr_tab_rejeicoes    IN OUT NOCOPY INSS0001.typ_tab_rejeicoes -- Tabela de Rejeicoes
                                       -- Identificacao de Processo Automatico
                                       ,pr_proc_aut         IN INTEGER                    -- Identifica se esta rodando o processo automatico (0-Nao/1-Sim)
                                       -- Arquivo e Diretorio
                                       ,pr_nmarquiv         IN VARCHAR2                   -- Nome do arquivo
                                       ,pr_nmdireto_integra IN VARCHAR2                   -- Diretorio Integra
                                       -- Erros
                                       ,pr_tpdiverg        OUT INTEGER                    -- Tipo da Divergencia
                                       ,pr_cod_reto        OUT INTEGER                    -- Retorno (0-OK/1-Divergencia/2-Ignorar Registro)
                                       ,pr_tab_erro        OUT GENE0001.typ_tab_erro) IS  -- Tabela Erros
    /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_proces_pagto_benef_inss
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Douglas Quisinski
    Data     : Outubro/2015                          Ultima atualizacao: 07/08/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para realizar as validacoes e creditos para o pagamento dos beneficios
    
    Alterações : 11/11/2015 - Ajuste para apresentar no relatório os beneficios que forem rejeitados
                              devido ao processo das cooperativas ainda estar executando
                              (Adriano).
                              
                 10/02/2016 - Realizado ajuste para pegar o código da cooperativa correto quando
                              não for encontrado o OP do beneficio em questão
                              (Adriano - SD 398214).
                              
                 05/12/2016 - Ajustes Incorporação Transulcred -> Transpocred.
                              PRJ342 (Odirlei-AMcom)         
                              
                 03/01/2017 - Ajustes Incorporação Transulcred -> Transpocred.
                              Alterar o numero da conta antiga para a nova. (Aline) 
                              
                 31/01/2017 - Ajuste ref Incorporação Transulcred -> Transpocred (Aline)                                 

				 07/08/2017 - Ajuste para efetuar log (temporário) de pontos criticos da rotina para tentarmos
				              identificar lentidões que estão ocorrendo na rotina
							 (Adriano).
    -------------------------------------------------------------------------------------------------------------*/

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.cdcooper
            ,cop.dsdircop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop  cr_crapcop%ROWTYPE;
      rw_crapcop1 cr_crapcop%ROWTYPE;
      
      -- Buscar Titular
      CURSOR cr_crapttl1 (pr_cdcooper IN crapttl.cdcooper%type
                         ,pr_nrcpfcgc IN crapttl.nrcpfcgc%type) IS
      SELECT /*+ INDEX (crapttl crapttl##crapttl6) */
             crapttl.cdcooper
            ,crapttl.nrdconta 
        FROM crapttl crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrcpfcgc = pr_nrcpfcgc;
      rw_crapttl cr_crapttl1%ROWTYPE;  
      
      --Selecionar cadastro titulares
      CURSOR cr_crapttl2 (pr_cdcooper IN crapttl.cdcooper%type
                         ,pr_nrdconta IN crapttl.nrdconta%type
                         ,pr_nrcpfcgc IN crapttl.nrcpfcgc%type) IS
      SELECT /*+ INDEX (crapttl crapttl##crapttl6) */
             crapttl.cdcooper
            ,crapttl.nrdconta
        FROM crapttl crapttl
       WHERE crapttl.cdcooper = pr_cdcooper 
         AND crapttl.nrcpfcgc = pr_nrcpfcgc         
         AND crapttl.nrdconta = pr_nrdconta; 

      -- Busca dos dados do associado
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta
            ,crapass.nmprimtl
            ,crapass.vllimcre
            ,crapass.nrcpfcgc
            ,crapass.inpessoa
            ,crapass.cdcooper
            ,crapass.cdagenci
       FROM crapass crapass
      WHERE crapass.cdcooper = pr_cdcooper
        AND crapass.nrdconta = pr_nrdconta
        AND crapass.dtelimin IS NULL;
      rw_crapass cr_crapass%ROWTYPE;
      
      --Selecionar Contas Migradas
      CURSOR cr_craptco (pr_cdcooper IN craptco.cdcopant%TYPE
                        ,pr_cdcopant IN craptco.cdcopant%TYPE
                        ,pr_nrctaant IN craptco.nrctaant%TYPE) IS
        SELECT craptco.cdcooper
             , craptco.cdagenci
             , craptco.nrdconta
          FROM craptco craptco
         WHERE craptco.cdcopant = pr_cdcopant  
           AND craptco.nrctaant = pr_nrctaant
           AND  craptco.tpctatrf = 1                  
           AND  craptco.cdcooper = pr_cdcooper                  
           AND  craptco.flgativo = 1 -- TRUE 
        UNION
        SELECT craptco.cdcooper
             , craptco.cdagenci
             , craptco.nrdconta
          FROM craptco craptco
         WHERE craptco.cdcopant = pr_cdcopant  
           AND  craptco.nrdconta = pr_nrctaant
           AND  craptco.tpctatrf = 1 
           AND  craptco.cdcooper = pr_cdcooper                  
           AND  craptco.flgativo = 1; -- TRUE    
      rw_craptco cr_craptco%ROWTYPE;

      --Variaveis Locais
      vr_crapttl   BOOLEAN:= FALSE;
      vr_crapcop   BOOLEAN:= FALSE;
      vr_crapass   BOOLEAN:= FALSE;
      vr_craptco   BOOLEAN:= FALSE;
      vr_cdcooper  INTEGER;
      vr_cdcooper_aux INTEGER;
      vr_cdagenci  NUMBER;
      vr_nrdconta  crapass.nrdconta%TYPE;
      vr_cdorgins  crapage.cdorgins%TYPE;
      vr_index     PLS_INTEGER;
    
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
      --Variaveis de Criticas
      vr_cdcritic  INTEGER;
      vr_des_reto  VARCHAR2(3);
      vr_dscritic  VARCHAR2(4000);    
      vr_comando   VARCHAR2(32767);
      vr_typ_saida VARCHAR2(3);
      
      -- Diretorios                              
      vr_nmdireto_salvar  VARCHAR2(100);
      vr_nmarqcri  VARCHAR2(1000);
         
      --Variaveis de Excecoes
      vr_exc_proximo EXCEPTION;
      vr_exc_diverg  EXCEPTION;
      vr_exc_erro    EXCEPTION; 
      
      vr_idprglog NUMBER;
      
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0001.pc_proces_pagto_benef_inss');
      
      --Inicializar variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      pr_cod_reto:= 0; -- Sem erros
      
      -- Enviar detalhamento do erro ao LOG (Temporario)
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                     , pr_cdprograma => pr_cdprogra
                     , pr_cdcooper => pr_cdcooper
                     , pr_tpexecucao => 0
                     , pr_tpocorrencia => 4
                     , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                          pr_cdprogra || ' --> '||
                                                   'Identificando cooperativa do beneficio, conta: '||
                                                    pr_tab_creditos(pr_index_creditos).nrdconta || 
                                                    ', NB: ' || 
                                                    pr_tab_creditos(pr_index_creditos).nrrecben)
                     , pr_idprglog => vr_idprglog);
                             
                                                      
      /* Localiza a cooperativa do beneficiario do XML pela Agencia SICREDI */
      -- Verifica se a cooperativa esta cadastrada
      vr_crapcop:= pr_tab_cdagesic.EXISTS(pr_tab_creditos(pr_index_creditos).cdagesic);
      -- Se não encontrar
      IF NOT vr_crapcop THEN
            
        /* Atualiza cdcooper */
        pr_tab_creditos(pr_index_creditos).cdcooper:= pr_cdcooper;              
        pr_tab_creditos(pr_index_creditos).cdagenci:= CASE pr_cdcooper WHEN 3 THEN 1 
                                                        ELSE pr_tab_creditos(pr_index_creditos).cdagenci 
                                                      END; 
        --Determinar Código da Divergencia  
        pr_tpdiverg:= 3; /*Dados Cadastrais*/                                                
              
        --Divergencia e Proximo Arquivo
        RAISE vr_exc_diverg;   
            
      ELSE
        --Atribuir o codigo da cooperativa
        rw_crapcop.cdcooper:= pr_tab_cdagesic(pr_tab_creditos(pr_index_creditos).cdagesic);
              
        /*Verifica se o beneficiario eh um cooperado com conta migrada.*/
        IF TO_NUMBER(pr_tab_creditos(pr_index_creditos).cdorgins) IN (801241, 787028) THEN --> Transulcred
              
          IF rw_crapcop.cdcooper IN (9,17) THEN
                          
            IF pr_tab_creditos(pr_index_creditos).nrdconta IN (11240,620,5525,329,345) THEN  
						vr_cdcooper_aux := 9;
            rw_crapcop.cdcooper := 17;
          /* Verifica se o beneficiario eh um cooperado com conta migrada. */
          OPEN cr_craptco (pr_cdcooper => vr_cdcooper_aux
                          ,pr_cdcopant => rw_crapcop.cdcooper
                          ,pr_nrctaant => pr_tab_creditos(pr_index_creditos).nrdconta);
                              
          FETCH cr_craptco INTO rw_craptco;
              
          -- Verificar se encontrou transferencia
          vr_craptco:= cr_craptco%FOUND;
              
          --Fechar Cursor
          CLOSE cr_craptco;
             END IF; 
          END IF;    
          --Se encontrou conta migrada
          IF vr_craptco THEN
            
            -- Verifica se a cooperativa esta cadastrada
            OPEN cr_crapcop (pr_cdcooper => rw_craptco.cdcooper);
                
            FETCH cr_crapcop INTO rw_crapcop1;
                
            -- Se não encontrar
            IF cr_crapcop%NOTFOUND THEN
                    
              -- Fechar o cursor 
              CLOSE cr_crapcop;
                    
              /* Atualiza cdcooper */
              pr_tab_creditos(pr_index_creditos).cdcooper:= rw_crapcop.cdcooper;              
              pr_tab_creditos(pr_index_creditos).cdagenci:= CASE rw_crapcop.cdcooper WHEN 3 THEN 1 
                                                              ELSE pr_tab_creditos(pr_index_creditos).cdagenci 
                                                            END; 

              --Determinar Código da Divergencia  
              pr_tpdiverg:= 3; /*Dados Cadastrais*/
              vr_crapcop:= FALSE; 
                  
              --Proximo Arquivo
              RAISE vr_exc_diverg; 
                  
            ELSE
              -- Apenas fechar o cursor
              CLOSE cr_crapcop;
                  
              -- Guardar valores
              vr_cdcooper := rw_craptco.cdcooper;
              vr_cdagenci := rw_craptco.cdagenci;
              vr_nrdconta := rw_craptco.nrdconta;
                    
              --Buscar novamente o diretorio da cooperativa
              vr_nmdireto_salvar:= pr_tab_salvar(vr_cdcooper);
            END IF;
          ELSE   
                  
            -- Guardar informações               
            vr_cdcooper := rw_crapcop.cdcooper;
            vr_nrdconta := pr_tab_creditos(pr_index_creditos).nrdconta;
            vr_cdorgins := pr_tab_creditos(pr_index_creditos).cdorgins;
                
            --Buscar novamente o diretorio da cooperativa
            vr_nmdireto_salvar:= pr_tab_salvar(vr_cdcooper);
                  
            -- Buscar informações da agencia
            IF NOT pr_tab_crapage.exists(vr_cdcooper) OR 
               NOT pr_tab_crapage(vr_cdcooper).tab_agenc.exists(vr_cdorgins) THEN
                   
              --Determinar Código da Divergencia  
              pr_tpdiverg:= 3; /*Dados Cadastrais*/
              vr_crapcop:= FALSE; 
                  
              --Divergencia e Proximo Arquivo
              RAISE vr_exc_diverg; 
                  
            ELSE
              -- Guarda o código da agencia
              vr_cdagenci := pr_tab_crapage(vr_cdcooper).tab_agenc(vr_cdorgins);
            END IF;
          END IF;  
              
        ELSE
          /*
          O SICREDI nao permite PA com mais de 2 digitos, desta
          forma, todos os beneficiarios do sistema CECRED que
          recebem em PAs que não atendem esta premissa, são 
          cadastrados na base do SICREDI com um PA escolhido por
          eles mesmos. Assim, o cadastro entre SICREDI - CECRED
          fica divergente gerando complicacoes para receber o 
          credito e para utilizar os servicos de gestao de beneficio.
          Para gerar o lancamento dos creditos, quando nao for
          uma conta migrada, sera encontrado o PA atraves do OP que
          o SICREDI nos envia no xml. Com isso, sera possivel gerar
          o lote e os lancamentos para o PA correto.
                         
          PS.: Para quando o cooperado nao for de uma conta 
               migrada, nao eh necessario fazer o procedimento 
               abaixo pois utilizamos o PA da craptco. 
          */            
              
          -- Guardar informações               
          vr_cdcooper := rw_crapcop.cdcooper;
          vr_nrdconta := pr_tab_creditos(pr_index_creditos).nrdconta;
          vr_cdorgins := pr_tab_creditos(pr_index_creditos).cdorgins;
              
          /* Atualiza cdcooper */
          pr_tab_creditos(pr_index_creditos).cdcooper:= vr_cdcooper;
          
          --Buscar novamente o diretorio da cooperativa
          vr_nmdireto_salvar:= pr_tab_salvar(vr_cdcooper);
                       
          -- Buscar informações da agencia
          IF NOT pr_tab_crapage.exists(vr_cdcooper) OR 
             NOT pr_tab_crapage(vr_cdcooper).tab_agenc.exists(vr_cdorgins) THEN
                  
            --Determinar Código da Divergencia  
            pr_tpdiverg:= 3; /*Dados Cadastrais*/
            vr_crapcop:= FALSE; 
                  
            --Divergencia e Proximo Arquivo
            RAISE vr_exc_diverg; 
          ELSE
            -- Guarda o código da agencia
            vr_cdagenci:= pr_tab_crapage(vr_cdcooper).tab_agenc(vr_cdorgins);    
          END IF;
                  
        END IF;  
        
        /* Atualiza cdcooper */
        pr_tab_creditos(pr_index_creditos).cdcooper := vr_cdcooper;    
        pr_tab_creditos(pr_index_creditos).nrdconta := vr_nrdconta;    
        pr_tab_creditos(pr_index_creditos).cdagenci := CASE vr_cdcooper WHEN 3 THEN 1 
                                                          ELSE vr_cdagenci 
                                                       END; 
                                                       
        
        -- Enviar detalhamento do erro ao LOG (Temporario)
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                       , pr_cdprograma => pr_cdprogra
                       , pr_cdcooper => pr_cdcooper
                       , pr_tpexecucao => 0
                       , pr_tpocorrencia => 4
                       , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                            pr_cdprogra || ' --> '||
                                                     'Identificado a cooperativa do beneficio, conta: '||
                                                      pr_tab_creditos(pr_index_creditos).nrdconta || 
                                                      ', NB: ' || 
                                                      pr_tab_creditos(pr_index_creditos).nrrecben || 
                                                      ', Coop: ' ||
                                                      pr_tab_creditos(pr_index_creditos).cdcooper)
                       , pr_idprglog => vr_idprglog);
                     
                                                      
                                                      
        
        /*  
        O beneficio cuja cooperativa ainda nao terminou o processo
        batch, ou seja, ainda nao atualizou a data de movimento, 
        sera descartado para ser processado na proxima execucao do
        script mqcecred_processa_sicredi_648.pl. 
        */ 
        -- Leitura do calendário da cooperativa
        IF NOT pr_tab_crapdat.EXISTS(vr_cdcooper)       OR 
           pr_tab_crapdat(vr_cdcooper) < TRUNC(SYSDATE) THEN                
                 
          --Proximo Arquivo
          RAISE vr_exc_proximo;
        ELSE
          rw_crapdat.dtmvtolt:= pr_tab_crapdat(vr_cdcooper);  
        END IF;
                                                             
        /* VALIDAR CPF */
        --Selecionar Titular
        OPEN cr_crapttl1 (pr_cdcooper => pr_tab_creditos(pr_index_creditos).cdcooper
                         ,pr_nrcpfcgc => pr_tab_creditos(pr_index_creditos).nrcpfcgc);
                             
        FETCH cr_crapttl1 INTO rw_crapttl;
            
        vr_crapttl:= cr_crapttl1%FOUND;
            
        --Fechar Cursor
        CLOSE cr_crapttl1;
              
        --Se Nao Encontrou
        IF NOT vr_crapttl THEN
              
          --Determinar Código da Divergencia  
          pr_tpdiverg:= 1; /* CPF INVALIDO */
              
          --Divergencia e Proximo Arquivo
          RAISE vr_exc_diverg;   
              
        END IF;  

        /* VALIDAR NRDCONTA */
        --Selecionar associado
        OPEN cr_crapass (pr_cdcooper => pr_tab_creditos(pr_index_creditos).cdcooper
                        ,pr_nrdconta => pr_tab_creditos(pr_index_creditos).nrdconta);
                            
        --Posicionar no proximo registro
        FETCH cr_crapass INTO rw_crapass;
            
        vr_crapass:= cr_crapass%FOUND;
            
        --Fechar Cursor
        CLOSE cr_crapass;
              
        --Se nao encontrou
        IF NOT vr_crapass THEN
              
          --Determinar Código da Divergencia  
          pr_tpdiverg:= 2; /* POUPANCA_CC_INVALIDO */
              
          --Divergencia e Proximo Arquivo
          RAISE vr_exc_diverg;   
              
        END IF; 
               
        --Se achou pela cooperativa e cpf
        IF vr_crapttl THEN 
          --Se a conta encontrada for a mesma, nao faz novo select
          IF rw_crapttl.nrdconta <> pr_tab_creditos(pr_index_creditos).nrdconta THEN  
                                                                     
            /* VALIDAR NRDCONTA E NRCPFCGC */
            --Selecionar cadastro titulares
            OPEN cr_crapttl2 (pr_cdcooper => pr_tab_creditos(pr_index_creditos).cdcooper
                             ,pr_nrdconta => pr_tab_creditos(pr_index_creditos).nrdconta
                             ,pr_nrcpfcgc => pr_tab_creditos(pr_index_creditos).nrcpfcgc);
                                 
            --Posicionar no proximo registro
            FETCH cr_crapttl2 INTO rw_crapttl;
                
            vr_crapttl:= cr_crapttl2%FOUND;
                
            --Fechar Cursor
            CLOSE cr_crapttl2;
                
          END IF;    
        END IF;
              
        --Se nao encontrou titular
        IF NOT vr_crapttl THEN
                
          --indicar que nao gera creditos
          pr_tab_creditos(pr_index_creditos).geracred:= FALSE;
              
          --Determinar Código da Divergencia  
          pr_tpdiverg:= 3; /*Dados cadastrais */
              
          --Divergencia e Proximo Arquivo
          RAISE vr_exc_diverg;   
              
        ELSE  
          --indicar que gera creditos
          pr_tab_creditos(pr_index_creditos).geracred := TRUE;
          pr_tab_creditos(pr_index_creditos).cdagenci := rw_crapass.cdagenci;
                
          -- Enviar detalhamento do erro ao LOG (Temporario)
          CECRED.pc_log_programa(pr_dstiplog => 'O'
                         , pr_cdprograma => pr_cdprogra
                         , pr_cdcooper => pr_cdcooper
                         , pr_tpexecucao => 0
                         , pr_tpocorrencia => 4
                         , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                              pr_cdprogra || ' --> '||
                                                       'Chamando rotina para gerar o credito: '||
                                                        pr_tab_creditos(pr_index_creditos).nrdconta || 
                                                        ', NB: ' || 
                                                        pr_tab_creditos(pr_index_creditos).nrrecben || 
                                                        ', Coop: ' ||
                                                        pr_tab_creditos(pr_index_creditos).cdcooper)
                         , pr_idprglog => vr_idprglog);
                         
          --Gerar Credito beneficio INSS
          inss0001.pc_benef_inss_gera_credito (pr_cdcooper => pr_tab_creditos(pr_index_creditos).cdcooper --Codigo Cooperativa 
                                              ,pr_cdagenci => pr_tab_creditos(pr_index_creditos).cdagenci --Codigo Agencia
                                              ,pr_nrcpfcgc => pr_tab_creditos(pr_index_creditos).nrcpfcgc --Numero Cpf CGC
                                              ,pr_nrrecben => pr_tab_creditos(pr_index_creditos).nrrecben --Numero Recebimento Beneficio
                                              ,pr_nrdocmto => pr_tab_creditos(pr_index_creditos).idbenefi --ID Beneficiario
                                              ,pr_nrdconta => pr_tab_creditos(pr_index_creditos).nrdconta --Numero da Conta 
                                              ,pr_vllanmto => pr_tab_creditos(pr_index_creditos).vlrbenef --Valor Beneficio
                                              ,pr_tpbenefi => pr_tab_creditos(pr_index_creditos).tpnrbene --Tipo Numero beneficio
                                              ,pr_cdbenefi => pr_tab_creditos(pr_index_creditos).cdbenefi --Codigo beneficio
                                              ,pr_cdagesic => pr_tab_creditos(pr_index_creditos).cdagesic --Codigo Agencia Sicredi
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt                         --Data Movimento
                                              ,pr_dtdpagto => pr_tab_creditos(pr_index_creditos).dtdpagto --Data pagamento
                                              ,pr_dtcompet => pr_tab_creditos(pr_index_creditos).dtinicio --Data Competencia do pagamento
                                              ,pr_nmbenefi => pr_tab_creditos(pr_index_creditos).nmbenefi --Nome Beneficiario                                           
                                              ,pr_nmarquiv => pr_nmarquiv                                 --Nome Arquivo 
                                              ,pr_ercadttl => vr_crapttl                                  --Cadastro Titular
                                              ,pr_ercadcop => vr_crapcop                                  --Cadastro Cooperativa
                                              ,pr_cdprogra => pr_cdprogra                                 --Nome Programa
                                              ,pr_pathcoop => pr_tab_dircoop(pr_tab_creditos(pr_index_creditos).cdcooper) --Diretorio Padrao da Cooperativa
                                              ,pr_proc_aut => pr_proc_aut                                 --Identifica se o processo está sendo executado de forma automatica(1) ou manual(0)
                                              ,pr_tab_arquivos  => pr_tab_arquivos                        --Tabela Arquivos
                                              ,pr_tab_rejeicoes => pr_tab_rejeicoes                       --Tabela Rejeicoes
                                              ,pr_des_reto => vr_des_reto                                 --Saida OK/NOK
                                              ,pr_tab_erro => pr_tab_erro);                               --Tabela de Erros

          
          -- Enviar detalhamento do erro ao LOG (Temporario)
          CECRED.pc_log_programa(pr_dstiplog => 'O'
                         , pr_cdprograma => pr_cdprogra
                         , pr_cdcooper => pr_cdcooper
                         , pr_tpexecucao => 0
                         , pr_tpocorrencia => 4
                         , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                              pr_cdprogra || ' --> '||
                                                       'Retorno da rotina para geracao de credito: '||
                                                        pr_tab_creditos(pr_index_creditos).nrdconta || 
                                                        ', NB: ' || 
                                                        pr_tab_creditos(pr_index_creditos).nrrecben || 
                                                        ', Coop: ' ||
                                                        pr_tab_creditos(pr_index_creditos).cdcooper) ||
                                             ', Retorno: ' || vr_des_reto
                         , pr_idprglog => vr_idprglog);
                         
          --Se ocorreu erro
          IF vr_des_reto = 'NOK' THEN
            IF pr_proc_aut = 1 THEN  
              
              
              -- Enviar detalhamento do erro ao LOG (Temporario)
              CECRED.pc_log_programa(pr_dstiplog => 'O'
                             , pr_cdprograma => pr_cdprogra
                             , pr_cdcooper => pr_cdcooper
                             , pr_tpexecucao => 0
                             , pr_tpocorrencia => 4
                             , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                                 pr_cdprogra || 
                                                 '01 - Mover arquivo ' 
                                                            ||pr_nmdireto_integra||'/'||pr_nmarquiv||
                                                            ' para ' || vr_nmdireto_salvar)
                             , pr_idprglog => vr_idprglog);
                             
                                                            
              -- Comando para mover arquivo
              vr_comando:= 'mv '||pr_nmdireto_integra||'/'||pr_nmarquiv||' '||
                           vr_nmdireto_salvar||'/'||'INSS.MQ.RREJ.'||
                           LPAD(pr_tab_creditos(pr_index_creditos).nrrecben,11,'0')||'.'||
                           LPAD(gene0002.fn_busca_time,5,'0')||
                           LPAD(TRUNC(DBMS_RANDOM.Value(0,9999)),4,'0')||'.xml 2> /dev/null';
                  
              --Executar o comando no unix
              GENE0001.pc_OScommand (pr_typ_comando => 'S'
                                    ,pr_des_comando => vr_comando
                                    ,pr_typ_saida   => vr_typ_saida
                                    ,pr_des_saida   => vr_dscritic);
                                        
              --Se ocorreu erro dar RAISE
              IF vr_typ_saida = 'ERR' THEN
                  
                --Monta mensagem de critica
                vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
                  
                -- retornando ao programa chamador
                RAISE vr_exc_erro;
                  
              END IF; 
              
              -- Enviar detalhamento do erro ao LOG (Temporario)
              CECRED.pc_log_programa(pr_dstiplog => 'O'
                             , pr_cdprograma => pr_cdprogra
                             , pr_cdcooper => pr_cdcooper
                             , pr_tpexecucao => 0
                             , pr_tpocorrencia => 4
                             , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                                 pr_cdprogra || 
                                                 '01 - Arquivo ' 
                                                            ||pr_nmdireto_integra||'/'||pr_nmarquiv||
                                                            ' movido para ' || vr_nmdireto_salvar
                                                            || ' com sucesso.')
                             , pr_idprglog => vr_idprglog);
                             
                                                            
                                                            
            END IF;
                
            --Se tem erro na tabela
            IF pr_tab_erro.COUNT > 0 THEN
              vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
              vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao gerar credito do beneficio. '||sqlerrm;
            END IF;    

            -- Escrever no log qual arquivo processou com erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                          ' - ' || pr_cdprogra || ' --> ' || 
                                                          'ERRO: ' || vr_dscritic ||
                                                          ' Arquivo: '||pr_nmarquiv
                                      ,pr_cdprograma   => pr_cdprogra
                                                         );

            --Proximo Arquivo e Desfazer
            RAISE vr_exc_proximo;
              
          ELSE
            IF pr_proc_aut = 1 THEN
                    
              -- Enviar detalhamento do erro ao LOG (Temporario)
              CECRED.pc_log_programa(pr_dstiplog => 'O'
                             , pr_cdprograma => pr_cdprogra
                             , pr_cdcooper => pr_cdcooper
                             , pr_tpexecucao => 0
                             , pr_tpocorrencia => 4
                             , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                                 pr_cdprogra || 
                                                 '02 - Move o arquivo  ' 
                                                            ||pr_nmdireto_integra||'/'||pr_nmarquiv||
                                                            ' para ' || vr_nmdireto_salvar)
                             , pr_idprglog => vr_idprglog);
                             
                                                                     
              -- Comando para mover arquivo
              vr_comando:= 'mv '||pr_nmdireto_integra||'/'||pr_nmarquiv||' '||
                           vr_nmdireto_salvar||'/'||'INSS.MQ.RPAG.'||
                           LPAD(pr_tab_creditos(pr_index_creditos).nrrecben,11,'0')||'.'||
                           LPAD(gene0002.fn_busca_time,5,'0')||
                           LPAD(TRUNC(DBMS_RANDOM.Value(0,9999)),4,'0')||'.xml 2> /dev/null';
                  
              --Executar o comando no unix
              GENE0001.pc_OScommand (pr_typ_comando => 'S'
                                    ,pr_des_comando => vr_comando
                                    ,pr_typ_saida   => vr_typ_saida
                                    ,pr_des_saida   => vr_dscritic);
                                        
              --Se ocorreu erro dar RAISE
              IF vr_typ_saida = 'ERR' THEN
                  
                --Mensagem de Critica
                vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
                  
                -- retornando ao programa chamador
                RAISE vr_exc_erro;
                  
              END IF;
              
              -- Enviar detalhamento do erro ao LOG (Temporario)
              CECRED.pc_log_programa(pr_dstiplog => 'O'
                             , pr_cdprograma => pr_cdprogra
                             , pr_cdcooper => pr_cdcooper
                             , pr_tpexecucao => 0
                             , pr_tpocorrencia => 4
                             , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                                 pr_cdprogra || 
                                                 '02 - Arquivo ' 
                                                            ||pr_nmdireto_integra||'/'||pr_nmarquiv||
                                                            ' movido para ' || vr_nmdireto_salvar
                                                            || ' com sucesso.')
                             , pr_idprglog => vr_idprglog);
                             
            END IF;
          END IF;          
        END IF;  --cr_crapttl2%FOUND
      END IF; --cr_crapcop
    EXCEPTION
      WHEN vr_exc_proximo THEN
        pr_cod_reto:= 3; -- Quando executar o proximo, ignorar o registro
        
        --Se for processo manual
        IF pr_proc_aut = 0 THEN
          
          /* Cria temp-tables para processamento do relatorio de divergencias    
           Parte 1 do relatorio de Rejeicoes [Sintetico] */
          vr_index:= pr_tab_arquivos.COUNT + 1;
          pr_tab_arquivos(vr_index).cdcooper:= pr_tab_creditos(pr_index_creditos).cdcooper;
          pr_tab_arquivos(vr_index).cdagenci:= pr_tab_creditos(pr_index_creditos).cdagenci;
          pr_tab_arquivos(vr_index).nmarquiv:= pr_nmarquiv;
          pr_tab_arquivos(vr_index).dsstatus:= 'Erro ao gerar lancamento.'; 
          /* Parte 2 do relatorio de Rejeicoes [Analitico] */
          pr_tab_rejeicoes(vr_index).cdcooper:= pr_tab_creditos(pr_index_creditos).cdcooper;
          pr_tab_rejeicoes(vr_index).cdagenci:= pr_tab_creditos(pr_index_creditos).cdagenci;
          pr_tab_rejeicoes(vr_index).nrdconta:= pr_tab_creditos(pr_index_creditos).nrdconta;
          pr_tab_rejeicoes(vr_index).nrrecben:= pr_tab_creditos(pr_index_creditos).nrrecben;
          pr_tab_rejeicoes(vr_index).nmrecben:= substr(pr_tab_creditos(pr_index_creditos).nmbenefi,1,28);
          pr_tab_rejeicoes(vr_index).dtinipag:= pr_tab_creditos(pr_index_creditos).dtdpagto;
          pr_tab_rejeicoes(vr_index).vllanmto:= pr_tab_creditos(pr_index_creditos).vlrbenef;
          pr_tab_rejeicoes(vr_index).dscritic:= 'Data do sistema invalida.'; 
          
        END IF;
        
      WHEN vr_exc_diverg THEN
        pr_cod_reto:= 2; -- Divergencia nas informacoes
        
        -- Enviar detalhamento do erro ao LOG (Temporario)
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                       , pr_cdprograma => pr_cdprogra
                       , pr_cdcooper => pr_cdcooper
                       , pr_tpexecucao => 0
                       , pr_tpocorrencia => 4
                       , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                            pr_cdprogra || ' --> '||
                                                     'Vai enviar arquivo de divergencia ao SICREDI: '||
                                                      pr_tab_creditos(pr_index_creditos).nrdconta || 
                                                      ', NB: ' || 
                                                      pr_tab_creditos(pr_index_creditos).nrrecben || 
                                                      ', Coop: ' ||
                                                      pr_tab_creditos(pr_index_creditos).cdcooper)
                       , pr_idprglog => vr_idprglog);
                       
        --Verificar Divergencias de Pagamento
        inss0001.pc_benef_inss_xml_div_pgto (pr_cdcooper => pr_tab_creditos(pr_index_creditos).cdcooper     --Codigo Cooperativa 
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt             --Data Movimento
                                            ,pr_tpdiverg => pr_tpdiverg             --Tipo Divergencia
                                            ,pr_dscritic => 'COM REJEITADOS'        --Descricao da Critica
                                            ,pr_nrcpfcgc => pr_tab_creditos(pr_index_creditos).nrcpfcgc --Numero Cpf CGC
                                            ,pr_nrdconta => pr_tab_creditos(pr_index_creditos).nrdconta --Numero da Conta 
                                            ,pr_cdbenefi => pr_tab_creditos(pr_index_creditos).cdbenefi --Codigo beneficio
                                            ,pr_cdagesic => pr_tab_creditos(pr_index_creditos).cdagesic --Codigo Agencia Sicredi
                                            ,pr_cdagenci => pr_tab_creditos(pr_index_creditos).cdagenci --Codigo Agencia
                                            ,pr_nrrecben => pr_tab_creditos(pr_index_creditos).nrrecben --Numero Recebimento Beneficio
                                            ,pr_nmbenefi => pr_tab_creditos(pr_index_creditos).nmbenefi --Nome Beneficiario
                                            ,pr_dtdpagto => pr_tab_creditos(pr_index_creditos).dtdpagto --Data pagamento
                                            ,pr_vlrbenef => pr_tab_creditos(pr_index_creditos).vlrbenef --Valor Beneficio
                                            ,pr_nmarquiv => pr_nmdireto_integra||'/'||pr_nmarquiv    --Nome Arquivo 
                                            ,pr_ercadttl => vr_crapttl              --Cadastro Titular
                                            ,pr_ercadcop => vr_crapcop              --Cadastro Cooperativa
                                            ,pr_tab_arquivos => pr_tab_arquivos     --Tabela de Memoria de arquivos
                                            ,pr_tab_rejeicoes => pr_tab_rejeicoes   --Tabela de Memoria de rejeicoes
                                            ,pr_cdprogra => pr_cdprogra             --Nome Programa
                                            ,pr_pathcoop => pr_tab_dircoop(pr_tab_creditos(pr_index_creditos).cdcooper) --Diretorio Padrao da Cooperativa
                                            ,pr_proc_aut => pr_proc_aut
                                            ,pr_des_reto => vr_des_reto             --Saida OK/NOK
                                            ,pr_tab_erro => pr_tab_erro);           --Tabela de Erros
                                                
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
              
          --Se tem erro na tabela
          IF pr_tab_erro.COUNT > 0 THEN
            vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao gravar divergencia pagamento. '||sqlerrm;
          END IF;    

          -- Escrever no log qual arquivo processou com erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                         ' - ' || pr_cdprogra || ' --> ' || 
                                                         'ERRO: ' || vr_dscritic ||
                                                         ' Arquivo: '||pr_nmarquiv
                                     ,pr_cdprograma   => pr_cdprogra
                                                         );
        END IF;                                 
            
        -- Enviar detalhamento do erro ao LOG (Temporario)
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                       , pr_cdprograma => pr_cdprogra
                       , pr_cdcooper => pr_cdcooper
                       , pr_tpexecucao => 0
                       , pr_tpocorrencia => 4
                       , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                            pr_cdprogra || ' --> '||
                                                     'Arquivo de divergencia enviado ao SICREDI: '||
                                                      pr_tab_creditos(pr_index_creditos).nrdconta || 
                                                      ', NB: ' || 
                                                      pr_tab_creditos(pr_index_creditos).nrrecben || 
                                                      ', Coop: ' ||
                                                      pr_tab_creditos(pr_index_creditos).cdcooper)
                       , pr_idprglog => vr_idprglog);
        
        -- Enviar detalhamento do erro ao LOG (Temporario)
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                       , pr_cdprograma => pr_cdprogra
                       , pr_cdcooper => pr_cdcooper
                       , pr_tpexecucao => 0
                       , pr_tpocorrencia => 4
                       , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                           pr_cdprogra || 
                                           '03 - Move o arquivo ' 
                                                      ||pr_nmdireto_integra||'/'||pr_nmarquiv||
                                                      ' para ' || vr_nmdireto_salvar)
                       , pr_idprglog => vr_idprglog);
                     
                     
                      
        /** 
        Ja esta criptografado, move para o salvar. 
        Esta mensagem nao deve ficar dentro do cecred/integra 
        senao, na proxima execucao do script ela sera novamente 
        enviada como rejeicao e isso ira travar a fila
        de processamento do Sicredi pois, o NB em questao ja foi tratado... 
        */
        -- Comando para mover arquivo
        vr_comando:= 'mv '||pr_nmdireto_integra||'/'||pr_nmarquiv||' '||
                     vr_nmdireto_salvar||'/'||'INSS.MQ.RREJ.'||
                     LPAD(pr_tab_creditos(pr_index_creditos).nrrecben,11,'0')||'.'||
                     LPAD(gene0002.fn_busca_time,5,'0')||
                     LPAD(TRUNC(DBMS_RANDOM.Value(0,9999)),4,'0')||'.xml 2> /dev/null';
            
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_nmarqcri);
                                  
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
              
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
              
          -- Escrever no log qual arquivo processou com erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                        ' - ' || pr_cdprogra || ' --> ' || 
                                                        'ERRO: ' || vr_dscritic
                                     ,pr_cdprograma   => pr_cdprogra
                                                         );
        END IF; 
        
        -- Enviar detalhamento do erro ao LOG (Temporario)
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                       , pr_cdprograma => pr_cdprogra
                       , pr_cdcooper => pr_cdcooper
                       , pr_tpexecucao => 0
                       , pr_tpocorrencia => 4
                       , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                           pr_cdprogra || 
                                           '03 - Arquivo ' 
                                                      ||pr_nmdireto_integra||'/'||pr_nmarquiv||
                                                      ' movido para ' || vr_nmdireto_salvar||
                                                      ' com sucesso.')
                       , pr_idprglog => vr_idprglog);
      
      
      WHEN vr_exc_erro THEN
        pr_cod_reto:= 1; -- Erro NOK
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => vr_cdcooper
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        
        
      WHEN OTHERS THEN
        pr_cod_reto:= 1; -- Erro NOK
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => vr_cdcooper
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        

  END pc_proces_pagto_benef_inss;
  
  --Processar pagamentos beneficios do INSS
  PROCEDURE pc_benef_inss_proces_pagto (pr_cdcooper IN crapcop.cdcooper%type      --Cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%type      --Codigo Agencia
                                       ,pr_nrdcaixa IN INTEGER                    --Numero Caixa
                                       ,pr_idorigem IN INTEGER                    --Origem Processamento
                                       ,pr_cdoperad IN VARCHAR2                   --Operador
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%type      --Data Movimento
                                       ,pr_nmdatela IN VARCHAR2                   --Nome da tela
                                       ,pr_cdprogra IN crapprg.cdprogra%type      --Nome Programa 
                                       ,pr_des_reto OUT VARCHAR2                  --Saida OK/NOK
                                       ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --Tabela Erros
  /*---------------------------------------------------------------------------------------------------------------
  
  Programa : pc_benef_inss_proces_pagto             Antigo: procedures/b1wgen0091.p/beneficios_inss_processa_pagamentos
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Alisson C. Berrido - Amcom
  Data     : Agosto/2014                           Ultima atualizacao: 07/08/2017
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo   : Procedure para enviar solicitacao ao SICREDI para mandar os creditos a serem efetuados 
               Executado em cada cada cooperativa  
  
  Alterações : 07/08/2014 - Conversao Progress -> Oracle (Alisson-AMcom)
            
               25/09/2014 - Ajustes para liberação (Adriano).
               
               30/01/2015 - Correção no tamanho das variaveis de mensagem 
                           (Marcos-Supero)
                           
               06/02/2015 - Foram alterados diversos pontos ref. chamado 251929: 
                           1) Diminuir a quantidade de chamadas para a rotina pc_benef_inss_xml_div_pgto
                           2) Realizar Commit e/ou Rollback a cada mensagem processada
                           3) Ler a competencia referente ao pagamento na tag XML <ns8:DataInicial> para
                              permitir popular o campo craplcm.cdpesqbb
                           4) Mostrar no log o nome do arquivo de beneficio processado com erro
                           5) Quando ocorrer erro, ignorar o arquivo e desfazer transações, 
                              porém não deve abortar o processo. (Alisson - AMcom)      
                              
               25/03/2015 - Ajuste na organização e identação da escrita e retirado variáveis
                            não utilizadas
                            (Adriano).                      
              
               27/07/2015 - Ajuste para efetuar o log no arquivo proc_message.log 
                            (Adriano). 
                            
               15/05/2015 - Alterado forma de leitura do xml, para ler as tags corretas conforme os 
                            nós pais SD313261 (Odirlei-AMcom)             
                            
               21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                           (Adriano - SD 473539).
                                         
               07/08/2017 - Ajuste para efetuar log (temporário) de pontos criticos da rotina para tentarmos
				            identificar lentidões que estão ocorrendo na rotina
							(Adriano).
                                         
  -------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Busca dos dados da cooperativa pela agencia sicredi
    CURSOR cr_crapcop2 IS
    SELECT cop.cdagesic
          ,cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
      FROM crapcop cop;
      
    --Selecionar Datas de todas as cooperativas
    CURSOR cr_crapdat_cooper IS
    SELECT crapdat.cdcooper
          ,crapdat.dtmvtolt
      FROM crapdat;  
      
    -- Selecionar dados da agencia
    CURSOR cr_crapage IS
      SELECT  crapage.cdcooper
             ,crapage.cdorgins
             ,crapage.cdagenci
        FROM crapage;
    rw_crapage    cr_crapage%ROWTYPE;
    
    --Variaveis Locais
    vr_crapcop   BOOLEAN:= FALSE;
    vr_flgproces BOOLEAN:= FALSE;
    vr_tagbenef  BOOLEAN:= FALSE;
    vr_nmarquiv  VARCHAR2(1000);
    vr_nmarqcri  VARCHAR2(1000);
    vr_typ_saida VARCHAR2(3);
    vr_comando   VARCHAR2(32767);
    
    --Variaveis para Diretorios
    vr_nmdireto         VARCHAR2(100);
    vr_nmdireto_integra VARCHAR2(100);
    vr_dscomora         VARCHAR2(1000); 
    vr_dsdirbin         VARCHAR2(1000); 
    
    --Variaveis para Indices temp-tables      
    vr_index_creditos PLS_INTEGER;
    
    --Variaveis Documentos DOM
    vr_xmldoc     xmldom.DOMDocument;
    vr_lista_nodo xmldom.DOMNodeList;
    vr_lista_nodo_2 xmldom.DOMNodeList;
    vr_lista_nodo_3 xmldom.DOMNodeList;
    vr_lista_nodo_4 xmldom.DOMNodeList;
    vr_nodo       xmldom.DOMNode;
    vr_nodo_pai   xmldom.DOMNode;
    vr_elemento   xmldom.DOMElement;
    vr_qtlinha    INTEGER;
    vr_tpdiverg   INTEGER;
    vr_qtarqdir   INTEGER;
    vr_cod_reto   INTEGER;
    vr_nm_parametro VARCHAR2(100);
    vr_nm_parametro_pai VARCHAR2(100);
    
    --Manipulacao de dados
    vr_XML  XMLType;
    
    --Tabela de Agencias
    vr_tab_crapage   INSS0001.typ_tab_crapage;
    --Tabela de Diretorios
    vr_tab_salvar    INSS0001.typ_tab_salvar;
    vr_tab_dircoop   INSS0001.typ_tab_salvar;
    --Tabela de Agencias Sicredi
    vr_tab_cdagesic  INSS0001.typ_tab_cdagesic;
    --Tabela de Datas por Cooperativa
    vr_tab_crapdat   INSS0001.typ_tab_crapdat; 
    --Tabela de Memoria de Creditos
    vr_tab_creditos  INSS0001.typ_tab_creditos;
    --Tabela de Memoria de Arquivos 
    vr_tab_arquivos  INSS0001.typ_tab_arquivos;
    --Tabela de Rejeicoes
    vr_tab_rejeicoes INSS0001.typ_tab_rejeicoes;
    --Tabela para receber arquivos lidos no unix
    vr_tab_crawarq TYP_SIMPLESTRINGARRAY:= TYP_SIMPLESTRINGARRAY();
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_des_reto VARCHAR2(3);
    vr_dscritic VARCHAR2(4000);    
                                       
    --Variaveis de Excecoes
    vr_exc_erro    EXCEPTION; 
    vr_exc_saida   EXCEPTION;
    vr_exc_proximo EXCEPTION;
    vr_exc_diverg  EXCEPTION; 
    
    vr_idprglog NUMBER;
    
    --Procedure para limpar tabelas temporarias
    PROCEDURE pc_limpa_tabela IS
    BEGIN
      vr_tab_crapdat.DELETE;
      vr_tab_salvar.DELETE;
      vr_tab_dircoop.DELETE;
      vr_tab_creditos.DELETE;
      vr_tab_arquivos.DELETE;
      vr_tab_rejeicoes.DELETE;
      vr_tab_cdagesic.DELETE;
      vr_tab_crapage.DELETE;
      vr_tab_crawarq.DELETE;
    END pc_limpa_tabela;
                                         
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 664301
		GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_benef_inss_proces_pagto');
    
    --limpar tabela erros
    pr_tab_erro.DELETE;
    
    --Limpar tabelas de memoria
    pc_limpa_tabela;      
    
    --Inicializar variaveis
    vr_cdcritic:= 0;
    vr_dscritic:= NULL;
    
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    
    FETCH cr_crapcop INTO rw_crapcop;
    
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      -- Busca critica
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      
      --Gera exceção
      RAISE vr_exc_erro;
     
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    --Carregar tabela de datas
    FOR rw_crapdat_cooper IN cr_crapdat_cooper LOOP
      vr_tab_crapdat(rw_crapdat_cooper.cdcooper):= rw_crapdat_cooper.dtmvtolt;
      
      --Montar Diretorio Padrao de cada cooperativa    
      vr_tab_dircoop(rw_crapdat_cooper.cdcooper):= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                                                         ,pr_cdcooper => rw_crapdat_cooper.cdcooper
                                                                         ,pr_nmsubdir => null);

      --Montar Diretorio Salvar de cada cooperativa
      vr_tab_salvar(rw_crapdat_cooper.cdcooper):= vr_tab_dircoop(rw_crapdat_cooper.cdcooper)||'/salvar/inss';
      
    END LOOP;
 
    --Carregar tabela agencias Sicredi
    FOR rw_cgagesic IN cr_crapcop2 LOOP
      vr_tab_cdagesic(rw_cgagesic.cdagesic):= rw_cgagesic.cdcooper;
    END LOOP;
      
    --Carregar tabela agencias 
    FOR rw_crapage IN cr_crapage LOOP
      vr_tab_crapage(rw_crapage.cdcooper).tab_agenc(rw_crapage.cdorgins):= rw_crapage.cdagenci;
    END LOOP;
    
    --Buscar Diretorio Cooperativa
    vr_nmdireto:= vr_tab_dircoop(pr_cdcooper);
    
    --Diretorio Integra
    vr_nmdireto_integra:= vr_nmdireto||'/integra';
    --Nome Arquivo filtrar
    vr_nmarquiv:= '%msgr_sicredi_cecred%.xml';
      
    /** LER A PASTA INTEGRA BUSCANDO PELOS ARQ. XML DO SICREDI */
      
    
    
    -- Enviar detalhamento do erro ao LOG (Temporario)
    CECRED.pc_log_programa(pr_dstiplog => 'O'
                   , pr_cdprograma => pr_cdprogra
                   , pr_cdcooper => pr_cdcooper
                   , pr_tpexecucao => 0
                   , pr_tpocorrencia => 4
                   , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                       pr_cdprogra || 
                                       'Buscando arquivos no diretorio para processamento: ' ||
                                                 vr_nmdireto_integra)
                   , pr_idprglog => vr_idprglog);
                              
    
    --Buscar a lista de arquivos do diretorio
    gene0001.pc_lista_arquivos(pr_lista_arquivo => vr_tab_crawarq
                              ,pr_path          => vr_nmdireto_integra
                              ,pr_pesq          => vr_nmarquiv);
                              
    --Quantidade de arquivos encontrados
    vr_qtarqdir:= vr_tab_crawarq.COUNT();  
                                
    
    -- Enviar detalhamento do erro ao LOG (Temporario)
    CECRED.pc_log_programa(pr_dstiplog => 'O'
                   , pr_cdprograma => pr_cdprogra
                   , pr_cdcooper => pr_cdcooper
                   , pr_tpexecucao => 0
                   , pr_tpocorrencia => 4
                   , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                       pr_cdprogra || 
                                       'Quantidade de arquivos encontrados: ' ||
                                                 NVL(vr_qtarqdir,0))
                   , pr_idprglog => vr_idprglog);
                   
                                                      
                                
    -- se encontrar arquivos
    IF vr_qtarqdir > 0 THEN
      --Existem arquivos para processar
      vr_flgproces:= TRUE;
    ELSE
      --Nao possui arquivos para processar
      vr_dscritic:= 'Nao existem arquivos para processamento.';
      
      --Levantar Excecao sem erros
      RAISE vr_exc_saida;          
    END IF;          
      
    --Buscar parametros 
    vr_dscomora:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_EXEC_SHELL');
    vr_dsdirbin:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_CECRED_BIN');
    
    --se nao encontrou
    IF vr_dscomora IS NULL OR vr_dsdirbin IS NULL THEN
      --Montar mensagem erro        
      vr_dscritic:= 'Nao foi possivel selecionar parametros.';
      RAISE vr_exc_erro;
    END IF;
     
    -------------------------------------------------------------------------------- 
    /* EFETUA A LEITURA DE CADA ARQUIVO DA PASTA INTEGRA */
    FOR idx IN 1..vr_qtarqdir LOOP
        
      --Criar SavePoint 
      SAVEPOINT save_trans_crawarq;
        
      --Bloco para permitir pular para proximo arquivo
      BEGIN
        /**** DESCRIPTOGRAFA O ARQUIVO ****/
        -- Comando para descriptografar arquivo
        vr_comando:= vr_dscomora || ' perl_remoto ' ||vr_dsdirbin||
                     'mqcecred_descriptografa.pl --descriptografa='||
                     chr(39)|| vr_nmdireto_integra ||'/'||vr_tab_crawarq(idx)||chr(39);
                                                                   
        -- Enviar detalhamento do erro ao LOG (Temporario)
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                       , pr_cdprograma => pr_cdprogra
                       , pr_cdcooper => pr_cdcooper
                       , pr_tpexecucao => 0
                       , pr_tpocorrencia => 4
                       , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                           pr_cdprogra || 
                                           'Vai efetuar a descriptografia do arquivo: ' ||
                                                      vr_tab_crawarq(idx))
                       , pr_idprglog => vr_idprglog);
                       
                                                                                                                    
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_nmarqcri);
         
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
            
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||
                        vr_comando||' - '||vr_nmarqcri;
                          
          -- retornando ao programa chamador
          RAISE vr_exc_erro;
        END IF;
          
        
        -- Enviar detalhamento do erro ao LOG (Temporario)
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                       , pr_cdprograma => pr_cdprogra
                       , pr_cdcooper => pr_cdcooper
                       , pr_tpexecucao => 0
                       , pr_tpocorrencia => 4
                       , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                           pr_cdprogra || 
                                           'Descriptografia efetuada: '||
                                                      vr_nmarqcri)
                       , pr_idprglog => vr_idprglog);
                       
         
                                                      
          
        --Retirar caracteres ENTER e LF do nome do arquivo
        vr_nmarqcri:= REPLACE(REPLACE(vr_nmarqcri,chr(10),''),chr(13),'');
          
        /* Obtem arquivo temporario descriptografado / com .dcrypt no fim */
        IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_nmarqcri) THEN  
            
          --Se Existir o arquivo original
          IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmdireto_integra||'/'||vr_tab_crawarq(idx)) THEN

            --Montar Mensagem
            vr_dscritic:= 'Arquivo descriptografado nao encontrado. Arquivo: '||vr_tab_crawarq(idx); 
            
            --Escrever No LOG
            btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                           ' - ' || pr_cdprogra || ' --> ' || 
                                                           'ERRO: ' || vr_dscritic
                                      ,pr_cdprograma   => pr_cdprogra
                                                          );
          END IF;          
                                                
          --Proximo Arquivo
          RAISE vr_exc_proximo;  
          
        END IF;
            
        /* Importar arquivo XML recebido no formato XMLType */
        gene0002.pc_arquivo_para_xml (pr_nmarquiv => vr_nmarqcri    --> Nome do caminho completo) 
                                     ,pr_xmltype  => vr_XML         --> Saida para o XML
                                     ,pr_des_reto => vr_des_reto    --> Descrição OK/NOK
                                     ,pr_dscritic => vr_dscritic);  --> Descricao Erro 

        --Se Ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Escrever No LOG
          btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                        ' - ' || pr_cdprogra || ' --> ' || 
                                                        'ERRO: ' || vr_dscritic ||
                                                        ' ,Erro ao processar arquivo '||vr_nmarqcri
                                    ,pr_cdprograma   => pr_cdprogra
                                                        ); 
          --Proximo Registro
          RAISE vr_exc_proximo;
          
        END IF;                               
                                    
        -- Enviar detalhamento do erro ao LOG (Temporario)
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                       , pr_cdprograma => pr_cdprogra
                       , pr_cdcooper => pr_cdcooper
                       , pr_tpexecucao => 0
                       , pr_tpocorrencia => 4
                       , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                           pr_cdprogra || 
                                           'Coletando informacoes do arquivo: '||
                                                      vr_nmarqcri)
                       , pr_idprglog => vr_idprglog);
                       
         
                                                      
                                                      
                                                                        
        /**** FIM - DESCRIPTOGRAFA O ARQUIVO ****/
                    
        /* Validacao do Cabecalho - Se eh o DadosBeneficioINSS */
          
        vr_xmldoc:= xmldom.newDOMDocument(vr_XML);
          
        --Lista de nodos
        vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'DadosBeneficioINSS');
        
        --> Para cada um dos filhos do DadosBeneficioINSS 
        FOR vr_linha IN 0..(xmldom.getLength(vr_lista_nodo)-1) LOOP
          
          --Buscar Nodo Corrente
          vr_nodo:= xmldom.item(vr_lista_nodo,vr_linha);
          vr_elemento  := xmldom.makeElement(vr_nodo);
          vr_lista_nodo_2:= xmldom.GETCHILDRENBYTAGNAME(vr_elemento,'*');  
          
          -- Definir index
          vr_index_creditos:= vr_tab_creditos.COUNT+1;
          --Nao chegou na tag Beneficiario
          vr_tagbenef:= FALSE;
            
          
          FOR vr_linha_2 IN 0..(xmldom.getLength(vr_lista_nodo_2)-1) LOOP
            --Buscar Nodo Corrente
            vr_nodo:= xmldom.item(vr_lista_nodo_2,vr_linha_2);
              
            --Nome Parametro Nodo corrente
            vr_nm_parametro:= xmldom.getNodeName(vr_nodo);
              
            --Buscar somente sufixo (o que tem apos o caracter :)
            vr_nm_parametro:= SUBSTR(vr_nm_parametro,instr(vr_nm_parametro,':')+1);  
            
            CASE vr_nm_parametro
              WHEN 'Beneficiario' THEN
                --Achou primeira linha que interessa
                vr_tagbenef:= TRUE;                
                vr_elemento    := xmldom.makeElement(vr_nodo);
                
                --Identificador beneficiario
                vr_tab_creditos(vr_index_creditos).idbenefi:= to_number(xmldom.getAttribute(vr_elemento,'ID'));
                --CPF Beneficiario
                vr_tab_creditos(vr_index_creditos).nrcpfcgc:= to_number(xmldom.getAttribute(vr_elemento,'NumeroDocumento'));  
                
                vr_lista_nodo_3:= xmldom.GETCHILDRENBYTAGNAME(vr_elemento,'*'); 
                --> buscar nós filhos do Beneficiario
                FOR vr_linha_3 IN 0..(xmldom.getLength(vr_lista_nodo_3)-1) LOOP
                  --Buscar Nodo Corrente
                  vr_nodo:= xmldom.item(vr_lista_nodo_3,vr_linha_3);
                    
                  --Nome Parametro Nodo corrente
                  vr_nm_parametro:= xmldom.getNodeName(vr_nodo);
                    
                  --Buscar somente sufixo (o que tem apos o caracter :)
                  vr_nm_parametro:= SUBSTR(vr_nm_parametro,instr(vr_nm_parametro,':')+1);    
                  
                  CASE vr_nm_parametro
                    WHEN 'Nome' THEN
                      vr_nodo:= xmldom.getFirstChild(vr_nodo);
                      vr_tab_creditos(vr_index_creditos).nmbenefi:= xmldom.getNodeValue(vr_nodo);
                      
                    WHEN 'Identificadores' THEN
                      /*Buscar nos filhos do Identificadores*/
                      vr_elemento  := xmldom.makeElement(vr_nodo);
                      vr_lista_nodo_4:= xmldom.getElementsByTagName(vr_elemento,'*');
                      
                      FOR vr_linha_4 IN 0..xmldom.getLength (vr_lista_nodo_4) - 1 LOOP
                        --Buscar Nodo filho
                        vr_nodo:= xmldom.item(vr_lista_nodo_4,vr_linha_4);                  
                        
                        --Nome Parametro Nodo corrente
                        vr_nm_parametro := xmldom.getNodeName(vr_nodo);
                        
                        --Buscar somente sufixo (o que tem apos o caracter :)
                        vr_nm_parametro := SUBSTR(vr_nm_parametro,instr(vr_nm_parametro,':')+1);  
                        vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                        
                        CASE vr_nm_parametro  
                          WHEN 'Codigo' THEN
                            --Numero beneficiario 
                            vr_tab_creditos(vr_index_creditos).nrrecben:= to_number(xmldom.getNodeValue(vr_nodo));  
                          WHEN 'TipoCodigo' THEN       
                            --Tipo beneficio
                            vr_tab_creditos(vr_index_creditos).tpnrbene:= xmldom.getNodeValue(vr_nodo); 
                          
                          ELSE NULL;
                        END CASE; 
                      END LOOP;  
                      --> FIM IDENTIFICADORES
                      
                    WHEN 'OrgaoPagador'    THEN
                      /*Buscar nos filhos do OrgaoPagador*/
                      vr_elemento  := xmldom.makeElement(vr_nodo);
                      vr_lista_nodo_4:= xmldom.getElementsByTagName(vr_elemento,'*');
                      
                      FOR vr_linha_4 IN 0..xmldom.getLength (vr_lista_nodo_4) - 1 LOOP
                        --Buscar Nodo filho
                        vr_nodo:= xmldom.item(vr_lista_nodo_4,vr_linha_4);
                        
                        --Nome Parametro Nodo corrente
                        vr_nm_parametro := xmldom.getNodeName(vr_nodo);
                        
                        --Buscar somente sufixo (o que tem apos o caracter :)
                        vr_nm_parametro := SUBSTR(vr_nm_parametro,instr(vr_nm_parametro,':')+1);  
                        vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                        
                        CASE vr_nm_parametro  
                          WHEN 'NumeroOrgaoPagador' THEN
                            --Codigo do Orgao pagador
                            vr_tab_creditos(vr_index_creditos).cdorgins:= to_number(xmldom.getNodeValue(vr_nodo)); 
                          WHEN 'CodigoCooperativa' THEN
                            --Codigo Cooperativa
                            vr_tab_creditos(vr_index_creditos).cdagesic:= to_number(xmldom.getNodeValue(vr_nodo)); 
                          WHEN 'NumeroUnidadeAtendimento' THEN
                            --Codigo Agencia
                            vr_tab_creditos(vr_index_creditos).cdagenci:= to_number(xmldom.getNodeValue(vr_nodo)); 
                           ELSE NULL;
                        END CASE; 
                      END LOOP;  
                      --> FIM ORGAOPAGADOR
                      
                    WHEN 'Beneficio'       THEN
                      --Buscar Atributos
                      vr_elemento:= xmldom.makeElement(vr_nodo);
                      --Codigo beneficio
                      vr_tab_creditos(vr_index_creditos).cdbenefi:= to_number(xmldom.getAttribute(vr_elemento,'ID'));
                     
                      vr_lista_nodo_4:= xmldom.getElementsByTagName(vr_elemento,'*');
                      
                      FOR vr_linha_4 IN 0..xmldom.getLength (vr_lista_nodo_4) - 1 LOOP
                        --Buscar Nodo filho
                        vr_nodo:= xmldom.item(vr_lista_nodo_4,vr_linha_4);
                        
                        --Nome Parametro Nodo corrente
                        vr_nm_parametro := xmldom.getNodeName(vr_nodo);
                        
                        --Buscar somente sufixo (o que tem apos o caracter :)
                        vr_nm_parametro := SUBSTR(vr_nm_parametro,instr(vr_nm_parametro,':')+1);  
                        
                        CASE vr_nm_parametro  
                          WHEN 'DataInicial' THEN                
                            -- Retorna a tag nodo pai 
                            vr_nodo_pai:= xmldom.getParentNode(vr_nodo);                          
                            --Nome Parametro Nodo Pai              
                            vr_nm_parametro_pai:= xmldom.getNodeName(vr_nodo_pai);
                            
                            -- Se nodo pai for "Competencia"
                            IF instr(vr_nm_parametro_pai,'Competencia') > 0 THEN
                              
                              vr_nodo:= xmldom.getFirstChild(vr_nodo);    
                              --Data Competencia Beneficio
                              vr_tab_creditos(vr_index_creditos).dtinicio:= to_date(xmldom.getNodeValue(vr_nodo),'YYYY-MM-DD-HH24:MI');  
                            END IF;
                                                        
                          WHEN 'Valor' THEN
                              
                            --Busca nodo
                            vr_nodo:= xmldom.getFirstChild(vr_nodo); 
                            --Valor beneficio
                            vr_tab_creditos(vr_index_creditos).vlrbenef:= to_number(replace(xmldom.getNodeValue(vr_nodo),'.',','));  
                          ELSE NULL;
                        END CASE; 
                      END LOOP;  
                      --> FIM BENEFICIO
                      
                    WHEN 'ContaCorrente'   THEN
                      /*Buscar nos filhos do ContaCorrente*/
                      vr_elemento  := xmldom.makeElement(vr_nodo);
                      vr_lista_nodo_4:= xmldom.getElementsByTagName(vr_elemento,'*');
                      
                      FOR vr_linha_4 IN 0..xmldom.getLength (vr_lista_nodo_4) - 1 LOOP
                        --Buscar Nodo filho
                        vr_nodo:= xmldom.item(vr_lista_nodo_4,vr_linha_4);
                        
                        --Nome Parametro Nodo corrente
                        vr_nm_parametro := xmldom.getNodeName(vr_nodo);
                        
                        --Buscar somente sufixo (o que tem apos o caracter :)
                        vr_nm_parametro := SUBSTR(vr_nm_parametro,instr(vr_nm_parametro,':')+1);  
                        vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                        
                        CASE vr_nm_parametro  
                          WHEN 'numero' THEN
                            --Conta Associado
                            vr_tab_creditos(vr_index_creditos).nrdconta:= to_number(xmldom.getNodeValue(vr_nodo));  
                           
                          WHEN 'digitoVerificador' THEN
                            --Digito da Conta                  
                            vr_tab_creditos(vr_index_creditos).cddigver:= xmldom.getNodeValue(vr_nodo); 
                            
                            --Concatenar Conta+Digito
                            vr_tab_creditos(vr_index_creditos).nrdconta:= to_number(vr_tab_creditos(vr_index_creditos).nrdconta||
                                                                          vr_tab_creditos(vr_index_creditos).cddigver);
                          
                          ELSE NULL;
                        END CASE; 
                      END LOOP;  
                      --> FIM CONTACORRENTE
                    
                    ELSE NULL;
                  END CASE;  
                  
                END LOOP; --> Fim Loop filhos benificiarios
              ELSE NULL;
            END CASE;  
            
          END LOOP; --> Fim Loop Beneficiario
        END LOOP; --> Fim Loop DadosBeneficioINSS
          
        /******************* VALIDACAO DOS DADOS XML *******************/


        -- Enviar detalhamento do erro ao LOG (Temporario)
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                       , pr_cdprograma => pr_cdprogra
                       , pr_cdcooper => pr_cdcooper
                       , pr_tpexecucao => 0
                       , pr_tpocorrencia => 4
                       , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                           pr_cdprogra || 
                                           'Informacoes coletadas: '||
                                                      vr_nmarqcri)
                       , pr_idprglog => vr_idprglog);
                       
         
                                                      
        
        -- Enviar detalhamento do erro ao LOG (Temporario)
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                       , pr_cdprograma => pr_cdprogra
                       , pr_cdcooper => pr_cdcooper
                       , pr_tpexecucao => 0
                       , pr_tpocorrencia => 4
                       , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                           pr_cdprogra || 
                                           'Remove arquivo descriptografado: '||
                                                      vr_nmarqcri)
                       , pr_idprglog => vr_idprglog);
                       
         
                                                                                                    
        /* Remove o arquivo descriptografado */
        vr_comando:= 'rm '||vr_nmarqcri||' 2> /dev/null';
          
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
                                
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
            
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
            
          -- retornando ao programa chamador
          RAISE vr_exc_erro;
            
        END IF;
    
        
        -- Enviar detalhamento do erro ao LOG (Temporario)
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                       , pr_cdprograma => pr_cdprogra
                       , pr_cdcooper => pr_cdcooper
                       , pr_tpexecucao => 0
                       , pr_tpocorrencia => 4
                       , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - ' || 
                                           pr_cdprogra || 
                                           'Arquivo descriptografado removido com sucesso: '||
                                                      vr_nmarqcri)
                       , pr_idprglog => vr_idprglog);
                       
                       
         
                                                      
    
        /* Realiza as validações e o pagamento do beneficio */
        --------------
        pc_proces_pagto_benef_inss (pr_cdcooper        => pr_cdcooper       -- Codigo da Cooperativa
                                   ,pr_cdprogra        => pr_cdprogra       -- Nome do Programa
                                   ,pr_nrdcaixa        => pr_nrdcaixa       -- Numero do Caixa
                                   ,pr_index_creditos  => vr_index_creditos -- Variavel para Indices de credito que esta sendo processado
                                   ,pr_tab_creditos    => vr_tab_creditos   -- Tabela de Memoria de Creditos
                                   -- Tabelas com as informações carregadas
                                   ,pr_tab_arquivos    => vr_tab_arquivos   -- Tabela de Memoria de Arquivos 
                                   ,pr_tab_crapage     => vr_tab_crapage    -- Tabela de Agencias
                                   ,pr_tab_salvar      => vr_tab_salvar     -- Tabela de Diretorios
                                   ,pr_tab_dircoop     => vr_tab_dircoop    -- Tabela de Diretorios
                                   ,pr_tab_cdagesic    => vr_tab_cdagesic   -- Tabela de Agencias Sicredi
                                   ,pr_tab_crapdat     => vr_tab_crapdat    -- Tabela de Datas por Cooperativa
                                   ,pr_tab_rejeicoes   => vr_tab_rejeicoes  -- Tabela de Rejeicoes
                                   ,pr_proc_aut        => 1                 -- Essa procedure esta apenas no CRPS, e é executado com os arquivos do MQ
                                   -- Arquivo e Diretorio
                                   ,pr_nmarquiv         => vr_tab_crawarq(idx) -- Nome do arquivo
                                   ,pr_nmdireto_integra => vr_nmdireto_integra -- Diretorio Integra
                                   -- Erros
                                   ,pr_tpdiverg        => vr_tpdiverg         -- Tipo da Divergencia
                                   ,pr_cod_reto        => vr_cod_reto         -- Retorno (0-OK/1-NOK/2-Divergencia/3-Ignorar Registro)
                                   ,pr_tab_erro        => pr_tab_erro);       -- Tabela Erros
          
        
        CASE vr_cod_reto
          WHEN 0 THEN
            -- Se não ocorreu nenhum problema, comit do pagamento
            COMMIT; 
            
          WHEN 1 THEN
            -- Quando ocorrer erro, não faz nada, pois já foi tratado
            NULL; 

          WHEN 2 THEN
            -- Com divergencia, executa o rollback
            RAISE vr_exc_diverg;
          
          WHEN 3 THEN 
            -- Se for ignorar o arquivo, ececuta rollback
            RAISE vr_exc_proximo;
        END CASE;
        ---------------

      EXCEPTION
        WHEN vr_exc_proximo THEN
          -- Desfazer transacao
          ROLLBACK to SAVEPOINT save_trans_crawarq;
        WHEN vr_exc_diverg THEN
          -- Desfazer transacao
          ROLLBACK to SAVEPOINT save_trans_crawarq;
      END; --Exception    
      
    END LOOP; --1..vr_tab_crawarq.COUNT  

    --Se nao processou nenhum arquivo
    IF NOT vr_flgproces THEN
      
      --Retornar OK
      pr_des_reto:= 'OK';
      
      --Retornar para programa chamador
      RETURN;
      
    END IF;
    
    --Se possuir arquivos processados e arquivo com erro ou rejeicoes gerar relatorio
    IF vr_flgproces AND (vr_tab_arquivos.COUNT + vr_tab_rejeicoes.COUNT) > 0 THEN
       
      --Gerar relatorio Rejeicoes
      inss0001.pc_gera_relatorio_rejeic (pr_cdcooper      => pr_cdcooper      --Codigo Cooperativa
                                        ,pr_dtmvtolt      => pr_dtmvtolt      --Data movimento
                                        ,pr_cdprogra      => pr_cdprogra      --Codigo Programa
                                        ,pr_tab_arquivos  => vr_tab_arquivos  --Tabela de Arquivos
                                        ,pr_tab_rejeicoes => vr_tab_rejeicoes --Tabela de Rejeicoes
                                        ,pr_dscritic      => vr_dscritic);    --Descricao Erro
                                        
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;  
    END IF; 
  
    --Limpar tabelas de memoria
    pc_limpa_tabela;    
                                              
    --Retornar OK
    pr_des_reto:= 'OK';  
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      --Limpar tabelas de memoria
      pc_limpa_tabela;    
      
      --Nao possui arquivos para processar. Registra no LOG e retorna OK
      pr_des_reto:= 'OK';
      
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                        ' - ' || pr_cdprogra || ' --> ' || 
                                                        'ERRO: ' || vr_dscritic
                                ,pr_cdprograma   => pr_cdprogra
                                                );
                                                
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_reto:= 'NOK';
      
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_reto:= 'NOK';
      
      -- Chamar rotina de gravação de erro
      vr_dscritic := 'Erro na pc_benef_inss_proces_pagto --> '|| SQLERRM;
      
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    
  END pc_benef_inss_proces_pagto;  
    
  /* Procedure para gerar o cabecalho Soap */
  PROCEDURE pc_gera_cabecalho_soap (pr_idservic IN INTEGER             --Tipo do Servico
                                   ,pr_nmmetodo IN VARCHAR2            --Nome do Método
                                   ,pr_username IN VARCHAR2            --Username
                                   ,pr_password IN VARCHAR2            --Senha
                                   ,pr_dstexto  IN OUT NOCOPY VARCHAR2 --Arquivo Dados
                                   ,pr_des_reto OUT VARCHAR2           --Retorno OK/NOK
                                   ,pr_dscritic OUT VARCHAR2) IS       --Descricao da Critica
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_gera_cabecalho_soap             Antigo: procedures/b1wgen0091.p/gera_cabecalho_soap
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - Amcom
    Data     : Fevereiro/2015                           Ultima atualizacao: 25/03/2015
  
    Dados referentes ao programa:
  
    Frequencia: -----
    Objetivo   : Procedure para gerar o cabecalho do arquivo XML  
  
    Alterações : 10/02/2015 Conversao Progress -> Oracle (Alisson-AMcom)
    
                 13/03/2015 - Inclusao do Tipo 6 para relatorio Historico Cadastral
                              (Alisson - AMcom)
                              
                 25/03/2015 - Ajuste na identação da escrita (Adriano).             
                 
  -----------------------------------------------------------------------------------------*/
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 664301
		GENE0001.pc_set_modulo(pr_module => 'INSS0001', pr_action => 'INSS0001.pc_gera_cabecalho_soap');
    
    DECLARE
      vr_xmlns    VARCHAR2(1000):= null;
      vr_exc_erro EXCEPTION;
    BEGIN
      
      --Montar o inicio do cabecalho  
      pr_dstexto := '<?xml version="1.0" ?><soapenv:Envelope';
    
      --Tipo de Servico
      CASE pr_idservic
        WHEN 1 THEN /*Consulta (Beneficiario e Demonstrativo)*/
          --Montar texto 
          vr_xmlns:= ' xmlns:ben="http://sicredi.com.br/convenios/cadastro/BeneficiarioINSS"'||           
                     ' xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">'; 

        WHEN 2 THEN /*Alteracao e Inclusao (Beneficiario)*/
          --Montar texto 
          vr_xmlns:= ' xmlns:ben="http://sicredi.com.br/convenios/cadastro/BeneficiarioINSS"'||           
                     ' xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'|| 
                     ' xmlns:v1="http://sicredi.com.br/cadastro/pessoa/cmodel/v1/"'|| 
                     ' xmlns:v12="http://sicredi.com.br/cadastro/localidade/cmodel/v1/"'||
                     ' xmlns:v11="http://sicredi.com.br/cadastro/bens/cmodel/v1/"'||
                     ' xmlns:v13="http://sicredi.com.br/cadastro/contato/cmodel/v1/"'||
                     ' xmlns:v14="http://sicredi.com.br/convenios/cadastro/cmodel/v1/"'||
                     ' xmlns:v15="http://sicredi.com.br/cadastro/entidade/cmodel/v1/"'||
                     ' xmlns:v16="http://sicredi.com.br/convenios/pagamento/cmodel/v1/"'||
                     ' xmlns:v17="http://sicredi.com.br/contas/conta/cmodel/v1/">';

        WHEN 3 THEN /*Efetivacao de prova de vida*/
          --Montar texto 
          vr_xmlns:= ' xmlns:prov="http://sicredi.com.br/convenios/pagamento/ProvaDeVida"'||           
                     ' xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'|| 
                     ' xmlns:rel="http://sicredi.com.br/convenios/pagamento/RelatorioBeneficioINSS"'||
                     ' xmlns:v1="http://sicredi.com.br/cadastro/pessoa/cmodel/v1/"'|| 
                     ' xmlns:v12="http://sicredi.com.br/cadastro/localidade/cmodel/v1/"'||
                     ' xmlns:v11="http://sicredi.com.br/cadastro/bens/cmodel/v1/"'||
                     ' xmlns:v13="http://sicredi.com.br/cadastro/contato/cmodel/v1/"'||
                     ' xmlns:v14="http://sicredi.com.br/convenios/cadastro/cmodel/v1/"'||
                     ' xmlns:v15="http://sicredi.com.br/cadastro/entidade/cmodel/v1/"'||
                     ' xmlns:v16="http://sicredi.com.br/convenios/pagamento/cmodel/v1/"'||
                     ' xmlns:v17="http://sicredi.com.br/contas/conta/cmodel/v1/">';

        WHEN 4 THEN /*Relatorios (Beneficios pagos/A pagar e bloqueado)*/
          --Montar texto 
          vr_xmlns:= ' xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'|| 
                     ' xmlns:rel="http://sicredi.com.br/convenios/pagamento/RelatorioBeneficioINSS"'||
                     ' xmlns:v1="http://sicredi.com.br/cadastro/pessoa/cmodel/v1/"'|| 
                     ' xmlns:v12="http://sicredi.com.br/cadastro/localidade/cmodel/v1/"'||
                     ' xmlns:v11="http://sicredi.com.br/cadastro/bens/cmodel/v1/"'||
                     ' xmlns:v13="http://sicredi.com.br/cadastro/contato/cmodel/v1/"'||
                     ' xmlns:v14="http://sicredi.com.br/cadastro/entidade/cmodel/v1/"'||
                     ' xmlns:dad="http://sicredi.com.br/convenios/pagamento/DadosBeneficioINSS"'||
                     ' xmlns:v15="http://sicredi.com.br/convenios/cadastro/cmodel/v1/"'||
                     ' xmlns:v16="http://sicredi.com.br/convenios/pagamento/cmodel/v1/"'||
                     ' xmlns:v17="http://sicredi.com.br/contas/conta/cmodel/v1/">';
        WHEN 5 THEN 
          --Montar texto 
          vr_xmlns:= ' xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'|| 
                     ' xmlns:arr="http://sicredi.com.br/convenios/pagamento/ArrecadacaoGPSINSS"'||
                     ' xmlns:v1="http://sicredi.com.br/cadastro/entidade/cmodel/v1/"'|| 
                     ' xmlns:v12="http://sicredi.com.br/cadastro/localidade/cmodel/v1/"'||
                     ' xmlns:v11="http://sicredi.com.br/cadastro/pessoa/cmodel/v1/"'||
                     ' xmlns:v13="http://sicredi.com.br/cadastro/bens/cmodel/v1/"'||
                     ' xmlns:v14="http://sicredi.com.br/cadastro/contato/cmodel/v1/"'||
                     ' xmlns:v15="http://sicredi.com.br/convenios/pagamento/cmodel/v1/"'||
                     ' xmlns:aut="http://sicredi.com.br/convenios/pagamento/Autenticacao"'||
                     ' xmlns:v16="http://sicredi.com.br/contas/conta/cmodel/v1/"'||
                     ' xmlns:v17="http://sicredi.com.br/contas/cadastro/cmodel/v1/">';

        WHEN 6 THEN --Relatorio de historico cadastral
          --Montar texto   
          vr_xmlns:= ' xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"' ||
				             ' xmlns:rel="http://sicredi.com.br/convenios/cadastro/RelatorioAlteracaoBeneficiarioINSS"' ||
                     ' xmlns:dad="http://sicredi.com.br/convenios/cadastro/DadosBeneficiarioINSS">';
                
        ELSE 
          vr_xmlns:= NULL;
      END CASE;        
      
      --Montar Header
      pr_dstexto:=  pr_dstexto||vr_xmlns||
        '<soapenv:Header>'||
           '<wsse:Security  soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'||
              '<wsse:UsernameToken wsu:Id="UsernameToken-4" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'||
                 '<wsse:Username>'||pr_username||'</wsse:Username>'||                     
                 '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'||pr_password||'</wsse:Password>'||
              '</wsse:UsernameToken>'||
           '</wsse:Security>'||
        '</soapenv:Header>'||
        '<soapenv:Body><'||pr_nmmetodo||'>';
        
      --Retornar OK
      pr_des_reto:= 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_reto:= 'NOK';
        pr_dscritic:= 'Erro na inss0001.pc_gera_cabecalho_soap. '||pr_dscritic;
      
      WHEN OTHERS THEN
        pr_des_reto:= 'NOK';
        pr_dscritic:= 'Erro na inss0001.pc_gera_cabecalho_soap. '||sqlerrm;
    END;     
  END pc_gera_cabecalho_soap;                                     

  /* Procedure para Solicitar Requisicao SOAP */
  PROCEDURE pc_efetua_requisicao_soap  (pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                       ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                       ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                       ,pr_idservic IN INTEGER                 --Identificador Servico
                                       ,pr_dsservic IN VARCHAR2                --Descricao Servico
                                       ,pr_nmmetodo IN VARCHAR2                --Nome Método
                                       ,pr_dstexto  IN VARCHAR2                --Texto com a msg XML
                                       ,pr_msgenvio IN VARCHAR2                --Mensagem Envio
                                       ,pr_msgreceb IN VARCHAR2                --Mensagem Recebimento
                                       ,pr_movarqto IN VARCHAR2                --Nome Arquivo mover
                                       ,pr_nmarqlog IN VARCHAR2                --Nome Arquivo LOG
                                       ,pr_nmdatela IN VARCHAR2                --Nome da Tela
                                       ,pr_des_reto OUT VARCHAR2               --Saida OK/NOK
                                       ,pr_dscritic OUT VARCHAR2) IS           --Descrição Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_efetua_requisicao_soap             Antigo: procedures/b1wgen0091.p/efetua_requisicao_soap
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Fevereiro/2015                           Ultima atualizacao: 30/03/2015
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para efetuar requisicao soap
  
    Alterações : 10/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
    
                 30/03/2015 - O script que recebe as mensagens xml do Web Service
                              foi alterado para que na solicitação dos relatórios
                              pagos/a pagar seja devolvido todo o xml e não somente
                              o couteúdo já decriptografado. Com isto, foi-se
                              necessário alterar esta rotina para atender esse ajuste
                              (Adriano).
                             
    
                
  ---------------------------------------------------------------------------------------------------------------*/
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 664301
		GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_efetua_requisicao_soap');    
      
    DECLARE
    
      vr_comando   VARCHAR2(32767);
      vr_dstexto   VARCHAR2(32767);
      vr_typ_saida VARCHAR2(3);
      vr_clob      CLOB;
      vr_XML       XMLType;
      vr_nmdireto  VARCHAR2(1000); 
      vr_nmarquiv  VARCHAR2(1000); 
      vr_dscomora  VARCHAR2(1000); 
      vr_dsdirbin  VARCHAR2(1000); 
      vr_dsderror  VARCHAR2(1000):= NULL;
      
      --Variaveis DOM
      vr_xmldoc     xmldom.DOMDocument;
      vr_root       DBMS_XMLDOM.DOMNode;
      vr_lista_nodo DBMS_XMLDOM.DOMNodelist;
      --Variaveis de Erro
      vr_des_reto VARCHAR2(3);      
      vr_dscritic VARCHAR2(1000);
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;

    BEGIN
      --Inicializar Variavel
      pr_des_reto:= 'OK';
      pr_dscritic:= NULL;
      
      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.OPEN(vr_clob, dbms_lob.lob_readwrite);

      --Escrever texto recebido como parametro no Clob
      gene0002.pc_escreve_xml(vr_clob,vr_dstexto,pr_dstexto,TRUE);
        
      --Separar o path do nome do arquivo de envio
      gene0001.pc_separa_arquivo_path(pr_caminho => pr_msgenvio
                                     ,pr_direto  => vr_nmdireto
                                     ,pr_arquivo => vr_nmarquiv);
                                  
      --Criar Arquivo Fisico
      gene0002.pc_clob_para_arquivo (pr_clob     => vr_clob
                                    ,pr_caminho  => vr_nmdireto
                                    ,pr_arquivo  => vr_nmarquiv
                                    ,pr_des_erro => vr_dscritic);
                                    
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;             
      
      --Fechar Clob e Liberar Memoria	
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob); 

      --Buscar parametros 
      vr_dscomora:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_EXEC_SHELL');
      vr_dsdirbin:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_CECRED_BIN');
      
      --se nao encontrou
      IF vr_dscomora IS NULL OR vr_dsdirbin IS NULL THEN
        
        --Montar mensagem erro        
        vr_dscritic:= 'Nao foi possivel selecionar parametros.';
        
        RAISE vr_exc_erro;
        
      END IF;  
      
      --Montar comando e Enviar Soap
      vr_comando:= vr_dscomora||' perl_remoto '|| vr_dsdirbin|| 'SendSoapSICREDI.pl --servico='||
                   chr(39)||pr_idservic||chr(39)||' < '|| pr_msgenvio||' > '|| pr_msgreceb;
                    
      --Executar Comando Unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
                           
      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        
        --Montar mensagem erro        
        vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_dscritic;
        
        RAISE vr_exc_erro;
      END IF;
      
      --Bloco Requisicao
      BEGIN
                
        /** Valida SOAP retornado pelo WebService **/
        gene0002.pc_arquivo_para_xml (pr_nmarquiv => pr_msgreceb    --> Nome do caminho completo) 
                                     ,pr_xmltype  => vr_XML         --> Saida para o XML
                                     ,pr_des_reto => vr_des_reto    --> Descrição OK/NOK
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_tipmodo  => 2 );  --> Descricao Erro 

        --Se Ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          
          vr_dsderror:= vr_dscritic;
          
          --Levantar Excecao
          RAISE vr_exc_saida;  
        END IF;              
        
        --Realizar o Parse do Arquivo XML
        vr_xmldoc:= xmldom.newDOMDocument(vr_XML);
          
        --Buscar tag Root no arquivo
        vr_root:= XmlDom.MakeNode(XmlDom.GetDocumentElement(vr_xmldoc));
        
        --Se nao existir a tag "Envelope" 
        IF instr(dbms_xmldom.getnodeName(vr_root),'Envelope') = 0 THEN
          
          vr_dsderror:= 'Resposta SOAP invalida (Envelope).';
          
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;  
        
        --Verificar se existe tag "Body"
        vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'Body');
        
        --Se nao existir a tag "Body" 
        IF dbms_xmldom.getlength(vr_lista_nodo) = 0 THEN
          
          vr_dsderror:= 'Resposta SOAP invalida (Body).';
          
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;  
                
      EXCEPTION
        WHEN vr_exc_saida THEN
          NULL;
      END;
      
      --Se ocorreu erro
      IF vr_dsderror IS NOT NULL THEN
        --Eliminar Arquivos Requisicoes
        inss0001.pc_elimina_arquivos_requis (pr_cdcooper => pr_cdcooper      --Codigo Cooperativa
                                            ,pr_cdprogra => pr_nmdatela      --Nome do Programa
                                            ,pr_msgenvio => pr_msgenvio      --Mensagem Envio
                                            ,pr_msgreceb => pr_msgreceb      --Mensagem Recebimento
                                            ,pr_movarqto => pr_movarqto      --Nome Arquivo mover
                                            ,pr_nmarqlog => pr_nmarqlog      --Nome Arquivo LOG
                                            ,pr_des_reto => vr_des_reto      --Retorno OK/NOK 
                                            ,pr_dscritic => vr_dscritic);    --Descricao Erro
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          RAISE vr_exc_erro;
        END IF;     
 
        --Mensagem Critica
        vr_dscritic:= 'Falha na execucao do metodo de '||pr_dsservic;
        IF vr_dsderror IS NOT NULL THEN
          vr_dscritic:= vr_dscritic||' (Erro: '|| vr_dsderror || ')';
        ELSE
          vr_dscritic:= vr_dscritic||'.';  
        END IF;  
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
        
      --Retornar OK
      pr_des_reto:= 'OK';
    EXCEPTION      
      WHEN vr_exc_erro THEN
        pr_des_reto:= 'NOK';
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_des_reto:= 'NOK';
        pr_dscritic:= 'Erro na inss0001.pc_efetua_requisicao_soap. '||sqlerrm;      
    END;    
  END pc_efetua_requisicao_soap;
  
                                            
  /* Procedure para Solicitar Requisicao SOAP */
  PROCEDURE pc_obtem_fault_packet  (pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                   ,pr_nmdatela IN VARCHAR2                --Nome da Tela
                                   ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                   ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                   ,pr_dsderror IN VARCHAR2                --Descricao Erro
                                   ,pr_msgenvio IN VARCHAR2                --Mensagem Envio
                                   ,pr_msgreceb IN VARCHAR2                --Mensagem Recebimento
                                   ,pr_movarqto IN VARCHAR2                --Nome Arquivo mover
                                   ,pr_nmarqlog IN VARCHAR2                --Nome Arquivo LOG
                                   ,pr_des_reto OUT VARCHAR2               --Saida OK/NOK
                                   ,pr_dscritic OUT VARCHAR2) IS           --Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_obtem_fault_packet             Antigo: procedures/b1wgen0091.p/obtem_fault_packet
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Fevereiro/2015                           Ultima atualizacao: 30/03/2015
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para verificar pacote de falha
  
    Alterações : 10/02/2015 Conversao Progress -> Oracle (Alisson-AMcom)
    
                 30/03/2015 - Ajuste na organização e identação da escrita (Adriano).            
    
  ---------------------------------------------------------------------------------------------------------------*/
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 664301
		GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_obtem_fault_packet');    
      
    DECLARE
    
      --Variaveis DOM
      vr_XML        XMLType;
      vr_xmldoc     xmldom.DOMDocument;
      vr_nodo       DBMS_XMLDOM.DOMNode;
      vr_lista_nodo DBMS_XMLDOM.DOMNodelist;
      
      --Variaveis Erro
      vr_des_reto VARCHAR2(3);
      vr_dscritic VARCHAR2(32767);
      vr_cdderror VARCHAR2(32767);
      vr_dsderror VARCHAR2(32767);
      
      --Variável controle do xml
      vr_xmlparser  dbms_xmlparser.Parser;
    
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
      
    BEGIN
      
      --Inicializar Variaveis
      vr_cdderror:= null;
      vr_dsderror:= null;
      
      /** Valida SOAP retornado pelo WebService **/
      gene0002.pc_arquivo_para_xml (pr_nmarquiv => pr_msgreceb    --> Nome do caminho completo) 
                                   ,pr_xmltype  => vr_XML         --> Saida para o XML
                                   ,pr_des_reto => vr_des_reto    --> Descrição OK/NOK
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tipmodo  => 2);  --> Descricao Erro 

      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        --Levantar Excecao
        RAISE vr_exc_erro;  
      END IF;              
      
      --Realizar o Parse do Arquivo XML
      vr_xmldoc:= xmldom.newDOMDocument(vr_XML);
                  
      --Lista de nodos
      vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'faultstring');
      -- Tratamento adicional para verificação se retornou falha, pois qnd retorna com sucesso
      -- o arquivo ultrapassa o limite de tamanho suportado pelo dbms_xmlparser.parse;       
      IF xmldom.getLength(vr_lista_nodo) > 0 THEN 

        /* Precisamos instanciar o Parser e efetuar a conversão do XML local para o XMLDOm usando UTF-8
           pois o SICREDI, esta nos enviando informações com acentuação em outro tipo de enconding*/
        vr_xmlparser := dbms_xmlparser.newParser;
        dbms_xmlparser.parse(vr_xmlparser,pr_msgreceb,nls_charset_id('UTF8'));
        vr_xmldoc := dbms_xmlparser.getDocument(vr_xmlparser);
        dbms_xmlparser.freeParser(vr_xmlparser);
        
        /** Verifica se foi retornado um fault packet (Erro) **/
            
        --Verificar se existe tag "Fault"
        vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'faultstring');
            
        IF dbms_xmldom.getlength(vr_lista_nodo) > 0 THEN
          
          --Buscar o item
          vr_nodo:= DBMS_XMLDOM.item(vr_lista_nodo,0);
          
          --Buscar o Filho
          vr_nodo:= xmldom.getFirstChild(vr_nodo);
          
          --Codigo do Erro
          vr_cdderror:= SUBSTR(dbms_xmldom.getnodevalue(vr_nodo),1,4);
          
          --Descricao do erro
          vr_dsderror:= dbms_xmldom.getnodevalue(vr_nodo);
          
          /* Se possui erro e foi passado parametro para ignorar ... */
          IF pr_dsderror IS NOT NULL AND 
             vr_cdderror IS NOT NULL AND
             instr(pr_dsderror,vr_cdderror) > 0 THEN
            --Retorno OK  
            pr_des_reto:= 'OK';
          ELSE
            --Se possui erro
            IF vr_dsderror IS NOT NULL THEN 
              pr_dscritic:= vr_dsderror;
            ELSE
              pr_dscritic:= NULL;
            END IF;  

            --Eliminar Arquivos de Requisicao
            inss0001.pc_elimina_arquivos_requis (pr_cdcooper => pr_cdcooper      --Codigo Cooperativa
                                                ,pr_cdprogra => pr_nmdatela      --Nome do Programa
                                                ,pr_msgenvio => pr_msgenvio      --Mensagem Envio
                                                ,pr_msgreceb => pr_msgreceb      --Mensagem Recebimento
                                                ,pr_movarqto => pr_movarqto      --Nome Arquivo mover
                                                ,pr_nmarqlog => pr_nmarqlog      --Nome Arquivo LOG
                                                ,pr_des_reto => vr_des_reto      --Retorno OK/NOK 
                                                ,pr_dscritic => vr_dscritic);    --Descricao Erro
            --Se ocorreu erro
            IF vr_des_reto = 'NOK' THEN
              RAISE vr_exc_erro;
            END IF;

            --Retorno Nao OK
            pr_des_reto:= 'NOK';

          END IF;
        ELSE
          --Retorno OK  
          pr_des_reto:= 'OK';    
        END IF;  
        
      ELSE  
        --Retorno OK  
        pr_des_reto:= 'OK';    
      END IF; 
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_reto:= 'NOK';
        pr_dscritic:= 'Erro na inss0001.pc_obtem_fault_packet. '||vr_dscritic;
      
      WHEN OTHERS THEN
        pr_des_reto:= 'NOK';
        pr_dscritic:= 'Erro na inss0001.pc_obtem_fault_packet. '||sqlerrm;          
    END;  
  END pc_obtem_fault_packet;


  /* Procedure para escrever a Linha no Log */
  PROCEDURE pc_retorna_linha_log  (pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                  ,pr_cdprogra IN VARCHAR2                --Codigo Programa
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%type   --Data Movimento
                                  ,pr_nrdconta IN crapass.nrdconta%type   --Numero da Conta
                                  ,pr_nrcpfcgc IN crapass.nrcpfcgc%type   --Numero Cpf
                                  ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                  ,pr_nmmetodo IN VARCHAR2                --Nome do metodo
                                  ,pr_cdderror IN VARCHAR2                --Codigo Erro
                                  ,pr_dsderror IN VARCHAR2                --Descricao Erro
                                  ,pr_nmarqlog IN VARCHAR2                --Nome Arquivo LOG
                                  ,pr_cdtipofalha  IN  NUMBER             --Tipo 2 abre chamado, tipo 4 não abre chamado
                                  ,pr_des_reto     OUT VARCHAR2           --Saida OK/NOK
                                  ,pr_dscritic     OUT VARCHAR2           --Descricao Erro 
                                  ) IS                      
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_retorna_linha_log             Antigo: procedures/b1wgen0091.p/retorna_linha_log
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Fevereiro/2015                           Ultima atualizacao: 10/04/2015
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para escrever a Linha no Log
  
    Alterações : 10/02/2015 Conversao Progress -> Oracle (Alisson-AMcom)
    
                 10/04/2015 - Alterado o formato da vr_nrcpfcgc (Adriano).
    
                 19/05/2017 - Belli incluido tipo de falha variavel.
                
                 23/06/2017 - Retirada da rotina pc_set_module, pois para esta pck, deve
                              registrar a rotina que gerou o erro (a que chamou a pc_retorna_linha_log)
                              (Ana - Envolti - Chamado 664301)
                                                                
  ---------------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
    
    --Selecionar cadastro titulares
    CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                      ,pr_nrdconta IN crapttl.nrdconta%type
                      ,pr_nrcpfcgc IN crapttl.nrcpfcgc%type) IS
    SELECT /*+ INDEX (crapttl crapttl##crapttl6) */
           crapttl.cdcooper
          ,crapttl.nrdconta
          ,crapttl.nmextttl
          ,crapttl.nrcpfcgc
      FROM crapttl crapttl
     WHERE crapttl.cdcooper = pr_cdcooper 
       AND crapttl.nrcpfcgc = pr_nrcpfcgc         
       AND crapttl.nrdconta = pr_nrdconta; 
    rw_crapttl cr_crapttl%rowtype;
           
    vr_nmextttl crapttl.nmextttl%type;
    vr_nrcpfcgc VARCHAR2(100);
    vr_dscritic VARCHAR2(4000);
     
    --Chamado 660327 
    vr_cdtipofalha NUMBER (2); 
    vr_dstipofalha VARCHAR2 (10); 
     
    BEGIN
      
      --Selecionar Titular
      OPEN cr_crapttl (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrcpfcgc => pr_nrcpfcgc);
                      
      FETCH cr_crapttl INTO rw_crapttl;
      
      IF cr_crapttl%FOUND THEN
        vr_nmextttl:= rw_crapttl.nmextttl;
        vr_nrcpfcgc:= gene0002.fn_mask_cpf_cnpj(rw_crapttl.nrcpfcgc,1);
      ELSE
        vr_nmextttl:= null;
        vr_nrcpfcgc:= null;
      END IF;
      
      --Fechar Cursor
      CLOSE cr_crapttl;
          
      --Montar mensagem Erro
      vr_dscritic:= to_char(pr_dtmvtolt,'DD/MM/YYYY HH24:MI:SS')|| ' --> '||
                    to_char(pr_nrdconta,'9999g999g9')|| ' | '||
                    rpad(vr_nmextttl,50,' ')|| ' | '||
                    rpad(vr_nrcpfcgc,18,' ')|| ' | '||
                    lpad(pr_nrrecben,11,0)|| ' | '||
                    rpad(pr_nmmetodo,40,' ')|| ' | '||
                    rpad(pr_cdderror,30,' ')|| ' | '||pr_dsderror;
                    
      IF pr_cdtipofalha IS NULL THEN
          vr_cdtipofalha := 3; -- Erro tratato
          vr_dstipofalha := 'ERRO: ';
      ELSE
          vr_cdtipofalha := pr_cdtipofalha;
          if pr_cdtipofalha = 1 then
              vr_dstipofalha := 'ALERTA: ';
          elsif pr_cdtipofalha = 3 then
              vr_dstipofalha := 'ERRO: ';
          else
              vr_dstipofalha := 'ERRO: ';
            end if;
      END IF;
                      
      --Escrever No LOG
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => vr_cdtipofalha
                                ,pr_nmarqlog     => pr_nmarqlog
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                        ' - ' || pr_cdprogra || ' --> ' || 
                                                        vr_dstipofalha || vr_dscritic
                                ,pr_cdprograma   => pr_cdprogra
                                                    );

    EXCEPTION
      WHEN OTHERS THEN
        pr_des_reto:= 'NOK';
        pr_dscritic:= 'Erro na inss0001.pc_retorna_linha_log. '||sqlerrm;
    END;  
  END pc_retorna_linha_log;  


  /* Procedure para Solicitar Relatorio Beneficios a Pagar ou Pagos */
  PROCEDURE pc_solic_rel_benef_web  (pr_dtmvtolt IN VARCHAR2                --Data Movimento DD/MM/YYYY
                                    ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                    ,pr_cdagesel IN INTEGER                 --Codigo Agencia Selecionada
                                    ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                    ,pr_tpnrbene IN VARCHAR2                --Tipo Numero Beneficiario
                                    ,pr_dtinirec IN VARCHAR2                --Data Inicio Recebimento DD/MM/YYYY
                                    ,pr_dtfinrec IN VARCHAR2                --Data Final Recebimento DD/MM/YYYY
                                    ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                    ,pr_tpconrel IN VARCHAR2                --Tipo Relatorio
                                    ,pr_idtiprel IN VARCHAR2                --PAGOS/PAGAR
                                    ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                    ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solic_rel_benef_web             
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Marco/2015                           Ultima atualizacao: 30/03/2015
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para solicitar ao SICREDI relatorio de beneficios a pagar/pagos 
  
    Alterações : 12/03/2015 - Desenvolvimento da Rotina (Alisson-AMcom)
               
                 30/03/2015 - Incluido as validações dos parâmetros para geração 
                              dos relatórios 
                              (Adriano).
                
  ---------------------------------------------------------------------------------------------------------------*/
    
    -- Selecionar dados da agencia
    CURSOR cr_crapage (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
    SELECT crapage.cdcooper
          ,crapage.cdorgins
          ,crapage.cdagenci
      FROM crapage
     WHERE crapage.cdcooper = pr_cdcooper
       AND crapage.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
    
    --Variaveis Locais
    vr_dsplsql  VARCHAR2(32767);
    vr_jobname  VARCHAR2(1000);
    vr_nmarqimp VARCHAR2(100);
    vr_nmarqpdf VARCHAR2(100);
    vr_auxconta PLS_INTEGER:= 0;
    vr_cdorgins INTEGER;
    vr_dtinirec DATE;
    vr_dtfinrec DATE;
            
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;                                       
    
    BEGIN
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      vr_dtinirec:= to_date(pr_dtinirec,'DD/MM/YYYY');
      vr_dtfinrec:= to_date(pr_dtfinrec,'DD/MM/YYYY');
      vr_cdorgins:= 0;
       
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
       
  	  -- Incluir nome do módulo logado - Chamado 664301
			GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_solic_rel_benef_web');      
       
      --Determinar o relatorio
      IF pr_idtiprel = 'PAGOS' THEN
        
        --Data Inicial pagamento
        IF pr_dtinirec IS NULL THEN
          
          --Monta mensagem de critica
          vr_dscritic:= 'Data inicial de pagamento nao informada.';
          pr_nmdcampo:= 'dtinirec';
          
          --Excecao
          RAISE vr_exc_erro;
          
        ELSIF pr_dtfinrec IS NULL THEN  
          
          --Monta mensagem de critica
          vr_dscritic:= 'Data final de pagamento nao informada.';
          pr_nmdcampo:= 'dtfinrec';
          
          --Excecao
          RAISE vr_exc_erro;
          
        ELSIF vr_dtinirec > vr_dtfinrec THEN  
          
          --Monta mensagem de critica          
          vr_dscritic:= 'Data final deve ser maior que a data inicial.';
          pr_nmdcampo:= 'dtfinrec';
          
          --Excecao
          RAISE vr_exc_erro;
          
        ELSIF add_months(vr_dtfinrec,-3) > vr_dtinirec THEN  
          
          --Monta mensagem de critica        
          vr_dscritic:= 'O periodo de consulta deve abranger no maximo 3 meses.';
          pr_nmdcampo:= 'dtfinrec';
          
          --Excecao
          RAISE vr_exc_erro;
          
        END IF;
          
        --Agencia Selecionada
        IF nvl(pr_cdagesel,0) > 0 THEN
          
          --Selecionar Agencia
          OPEN cr_crapage (pr_cdcooper => vr_cdcooper
                          ,pr_cdagenci => pr_cdagesel);
                          
          FETCH cr_crapage INTO rw_crapage;
          
          IF cr_crapage%NOTFOUND THEN
            
            --Fechar Cursor
            CLOSE cr_crapage;     
            
            --Monta mensagem de erro           
            vr_cdcritic:= 962;
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
            pr_nmdcampo:= 'cdagenci';
            
            --Excecao
            RAISE vr_exc_erro;
          ELSE
            --Fechar Cursor
            CLOSE cr_crapage;
            
            IF nvl(rw_crapage.cdorgins,0) = 0 THEN
              vr_dscritic:= 'Orgao pagador nao cadastrado.';
              pr_nmdcampo:= 'cdagenci';
              
              --Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdorgins:= rw_crapage.cdorgins;
              
            END IF;
            
          END IF;  
        END IF;
        
        -- Montar o bloco PLSQL que será executado
        vr_dsplsql:= 'DECLARE'||chr(13)
                   || '  vr_cdcritic PLS_INTEGER;'||chr(13)
                   || '  vr_dscritic VARCHAR2(4000);'||chr(13)
                   || '  vr_des_erro VARCHAR2(3);'||chr(13)
                   || '  vr_nmdcampo VARCHAR2(1000);'||chr(13)
                   || 'BEGIN'||chr(13)
                   || '  inss0001.pc_solic_rel_benef_pagos' 
                   || '  (pr_cdcooper => '||vr_cdcooper
                   || '  ,pr_cdagenci => '||vr_cdagenci   
                   || '  ,pr_nrdcaixa => '||vr_nrdcaixa   
                   || '  ,pr_idorigem => '||vr_idorigem   
                   || '  ,pr_dtmvtolt => '||chr(39)||pr_dtmvtolt||chr(39)
                   || '  ,pr_nmdatela => '||chr(39)||vr_nmdatela||chr(39)
                   || '  ,pr_cdoperad => '||chr(39)||vr_cdoperad||chr(39)
                   || '  ,pr_cddopcao => '||chr(39)||pr_cddopcao||chr(39)
                   || '  ,pr_cdagesel => '||nvl(pr_cdagesel,0)   
                   || '  ,pr_cdorgins => '||nvl(vr_cdorgins,0) 
                   || '  ,pr_nrrecben => '||nvl(pr_nrrecben,0)   
                   || '  ,pr_tpnrbene => '||chr(39)||pr_tpnrbene||chr(39)
                   || '  ,pr_dtinirec => '||chr(39)||pr_dtinirec||chr(39)
                   || '  ,pr_dtfinrec => '||chr(39)||pr_dtfinrec||chr(39)
                   || '  ,pr_dsiduser => '||chr(39)||pr_dsiduser||chr(39)
                   || '  ,pr_tpconrel => '||chr(39)||pr_tpconrel||chr(39)
                   || '  ,pr_cdcritic => vr_cdcritic'   
                   || '  ,pr_dscritic => vr_dscritic'   
                   || '  ,pr_nmdcampo => vr_nmdcampo'   
                   || '  ,pr_des_erro => vr_des_erro);'||chr(13)    
                   || 'END;';
        -- Montar o prefixo do código do programa para o jobname
        vr_jobname := 'RELPAGOS_'||gene0002.fn_busca_time||'$';
                
      ELSIF pr_idtiprel = 'PAGAR' THEN
        
        --Data Inicial pagamento
        IF pr_dtinirec IS NULL THEN
          IF pr_dtfinrec IS NOT NULL THEN  
            --Monta mensagem de critica
            vr_dscritic:= 'Data inicial de pagamento nao informada.';
            pr_nmdcampo:= 'dtinirec';
            
            --Excecao
            RAISE vr_exc_erro;
          END IF;
        ELSE
          IF pr_dtfinrec IS NULL THEN  
            --Monta mensagem de critica
            vr_dscritic:= 'Data final de pagamento nao informada.';
            pr_nmdcampo:= 'dtfinrec';
            
            --Excecao
            RAISE vr_exc_erro;
          END IF;
          
          IF vr_dtinirec > vr_dtfinrec THEN              
            --Monta mensagem de critica          
            vr_dscritic:= 'Data final deve ser maior que a data inicial.';
            pr_nmdcampo:= 'dtfinrec';
              
            --Excecao
            RAISE vr_exc_erro;
              
          ELSIF add_months(vr_dtfinrec,-3) > vr_dtinirec THEN              
            --Monta mensagem de critica        
            vr_dscritic:= 'O periodo de consulta deve abranger no maximo 3 meses.';
            pr_nmdcampo:= 'dtfinrec';              
            --Excecao
            RAISE vr_exc_erro;              
          END IF;          
        END IF;
        
        --Agencia Selecionada
        IF nvl(pr_cdagesel,0) > 0 THEN

          --Selecionar Agencia
          OPEN cr_crapage (pr_cdcooper => vr_cdcooper
                          ,pr_cdagenci => pr_cdagesel);
                          
          FETCH cr_crapage INTO rw_crapage;
          
          IF cr_crapage%NOTFOUND THEN
            --Fechar Cursor
            CLOSE cr_crapage;   
                         
            vr_cdcritic:= 962;
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
            pr_nmdcampo:= 'cdagenci';
                        
            --Excecao
            RAISE vr_exc_erro;
          ELSE
            --Fechar Cursor
            CLOSE cr_crapage;
            
            IF nvl(rw_crapage.cdorgins,0) = 0 THEN
              vr_dscritic:= 'Orgao pagador nao cadastrado.';
              pr_nmdcampo:= 'cdagenci';
                           
              --Excecao
              RAISE vr_exc_erro;
            ELSE 
              vr_cdorgins:= rw_crapage.cdorgins;
              
            END IF;
            
          END IF;  
          
        END IF;
        
        -- Montar o bloco PLSQL que será executado
        vr_dsplsql:= 'DECLARE'||chr(13)
                   || '  vr_cdcritic NUMBER;'||chr(13)
                   || '  vr_dscritic VARCHAR2(4000);'||chr(13)
                   || '  vr_des_erro VARCHAR2(3);'||chr(13)
                   || '  vr_nmdcampo VARCHAR2(1000);'||chr(13)
                   || 'BEGIN'||chr(13)
                   || '  inss0001.pc_solic_rel_benef_pagar'
                   || '  (pr_cdcooper => '||vr_cdcooper
                   || '  ,pr_cdagenci => '||vr_cdagenci   
                   || '  ,pr_nrdcaixa => '||vr_nrdcaixa   
                   || '  ,pr_idorigem => '||vr_idorigem   
                   || '  ,pr_dtmvtolt => '||chr(39)||pr_dtmvtolt||chr(39)   
                   || '  ,pr_dtinirec => '||chr(39)||pr_dtinirec||chr(39)
                   || '  ,pr_dtfinrec => '||chr(39)||pr_dtfinrec||chr(39)   
                   || '  ,pr_nmdatela => '||chr(39)||vr_nmdatela||chr(39)   
                   || '  ,pr_cdoperad => '||chr(39)||vr_cdoperad||chr(39)   
                   || '  ,pr_cddopcao => '||chr(39)||pr_cddopcao||chr(39)   
                   || '  ,pr_cdagesel => '||nvl(pr_cdagesel,0)   
                   || '  ,pr_cdorgins => '||nvl(vr_cdorgins,0) 
                   || '  ,pr_nrrecben => '||nvl(pr_nrrecben,0)   
                   || '  ,pr_tpnrbene => '||chr(39)||pr_tpnrbene||chr(39)   
                   || '  ,pr_dsiduser => '||chr(39)||pr_dsiduser||chr(39)   
                   || '  ,pr_tpconrel => '||chr(39)||pr_tpconrel||chr(39)   
                   || '  ,pr_cdcritic => vr_cdcritic'   
                   || '  ,pr_dscritic => vr_dscritic'   
                   || '  ,pr_nmdcampo => vr_nmdcampo'  
                   || '  ,pr_des_erro => vr_des_erro);'||chr(13)   
                   || 'END;';
        -- Montar o prefixo do código do programa para o jobname
        vr_jobname := 'RELPAGAR_'||gene0002.fn_busca_time||'$';
      END IF;

      --Se conseguiu montar o job
      IF vr_jobname IS NOT NULL THEN
        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper  => vr_cdcooper  --> Código da cooperativa
                              ,pr_cdprogra  => 'INSS'       --> Código do programa
                              ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                              ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                              ,pr_interva   => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                              ,pr_jobname   => vr_jobname   --> Nome randomico criado
                              ,pr_des_erro  => vr_dscritic);
        -- Testar saida com erro
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar exceçao
          RAISE vr_exc_erro;
        END IF;
      
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        -- Insere as tags dos campos da PLTABLE de aplicações
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqimp', pr_tag_cont => vr_nmarqimp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarqpdf, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'jobname', pr_tag_cont => vr_jobname, pr_des_erro => vr_dscritic);
        
        --Retorno OK
        pr_des_erro:= 'OK';
      ELSE
        --Mensagem Erro
        vr_dscritic:= 'Tipo de Relatorio Invalido.';  
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;  
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Desfaz alteracoes
        ROLLBACK;
        
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Monta mensagem de erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        --Desfaz alteracoes
        ROLLBACK;
        
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        --Monta mensagem de erro
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro na inss0001.pc_solic_rel_benef_web --> '|| SQLERRM;
        
         -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
                                         
  END pc_solic_rel_benef_web;

  /* Procedure para Solicitar Relatorio Beneficios a Pagar */
  PROCEDURE pc_solic_rel_benef_pagar  (pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                      ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                      ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                      ,pr_idorigem IN INTEGER                 --Origem Processamento
                                      ,pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                      ,pr_dtinirec IN VARCHAR2                --Data Inicio Recebimento
                                      ,pr_dtfinrec IN VARCHAR2                --Data Final Recebimento
                                      ,pr_nmdatela IN VARCHAR2                --Nome da tela
                                      ,pr_cdoperad IN VARCHAR2                --Operador
                                      ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                      ,pr_cdagesel IN INTEGER                 --Codigo Agencia Selecionada
                                      ,pr_cdorgins IN INTEGER                 --Codigo do orgao pagado INSS-SICREDI
                                      ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                      ,pr_tpnrbene IN VARCHAR2                --Tipo Numero Beneficiario
                                      ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                      ,pr_tpconrel IN VARCHAR2                --Tipo Relatorio
                                      ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                      ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                      ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solic_rel_benef_pagar             Antigo: procedures/b1wgen0091.p/solicita_relatorio_beneficios_pagar
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Fevereiro/2015                           Ultima atualizacao: 21/06/2016
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para solicitar ao SICREDI relatorio de beneficios a pagar 
  
    Alterações : 10/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
    
                 30/03/2015 - Retirado as validações de parâmetros e incluído o tratamento 
                              para receber o conteúdo do relatório, decriptografa-lo e grava-lo
                              em arquivo
                              (Adriano).
                
                 21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                              (Adriano - SD 473539).

                 23/06/2016 - Incluir nome do módulo logado - (Ana - Envolti - Chamado 664301)
  ---------------------------------------------------------------------------------------------------------------*/
    
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Selecionar dados da agencia
    CURSOR cr_crapage (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
    SELECT crapage.cdcooper
          ,crapage.cdorgins
          ,crapage.cdagenci
      FROM crapage
     WHERE crapage.cdcooper = pr_cdcooper
       AND crapage.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;
         
    -- Selecionar dados da agencia
    CURSOR cr_crapage_cdorgins (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapage.cdcooper
          ,crapage.cdorgins
          ,crapage.cdagenci
      FROM crapage
     WHERE crapage.cdcooper = pr_cdcooper
       AND nvl(crapage.cdorgins,0) > 0;
    
    --Tabela Erros 
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Constantes
    vr_cdagenci INTEGER:= 2;
        
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
    vr_dscritic2 VARCHAR2(4000);
    
    --Variaveis locais
    vr_blob     BLOB := EMPTY_BLOB;
    vr_clob     CLOB;
    vr_dstime   VARCHAR2(100);
    vr_nmarquiv VARCHAR2(1000);
    vr_msgenvio VARCHAR2(32767);
    vr_msgreceb VARCHAR2(32767);
    vr_movarqto VARCHAR2(32767);
    vr_nmarqlog VARCHAR2(32767);
    vr_nmdireto VARCHAR2(1000);
    vr_des_reto VARCHAR2(3);
    vr_retornvl VARCHAR2(3) := 'NOK';
    vr_dstexto  VARCHAR2(32767);
    vr_dtmvtolt DATE;
    vr_dtinirec DATE;
    vr_dtfinrec DATE;
    
    --Variaveis Documentos DOM
    vr_xmldoc     xmldom.DOMDocument;
    vr_lista_nodo xmldom.DOMNodeList;
    vr_nodo       xmldom.DOMNode;
    vr_qtlinha    INTEGER;
    vr_nmparam    VARCHAR2(1000);
    
    --Manipulacao de dados
    vr_XML  XMLType;    
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;                                       
    vr_exc_saida EXCEPTION;     
    
    vr_teste_clob clob;
    
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
			GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_solic_rel_benef_pagar');
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= NULL;
      vr_nmarquiv:= NULL;
      vr_msgenvio:= NULL;
      vr_msgreceb:= NULL;
      vr_movarqto:= NULL;
      vr_nmarqlog:= NULL;
      vr_dstime:=   NULL;
      
      BEGIN                                                  
        --Pega a data movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/YYYY'); 
        IF pr_dtinirec IS NOT NULL THEN
          vr_dtinirec := to_date(pr_dtinirec,'DD/MM/YYYY'); 
          vr_dtfinrec := to_date(pr_dtfinrec,'DD/MM/YYYY');
        END IF;
        
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
       RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
  
      --Buscar Diretorio Padrao da Cooperativa
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => null);
                                          
      --Determinar Nomes do Arquivo de Log
      vr_nmarqlog:= 'SICREDI_Soap_LogErros';

      --Buscar o Horario
      vr_dstime:= lpad(gene0002.fn_busca_time,5,'0');
      
      --Determinar Nomes do Arquivo de Envio
      vr_msgenvio:= vr_nmdireto|| '/arq/INSS.SOAP.ERELAPG'||
                    to_char(vr_dtmvtolt,'DDMMYYYY')||
                    vr_dstime||pr_cdoperad;
                    
      --Determinar Nome do Arquivo de Recebimento    
      vr_msgreceb:= vr_nmdireto||'/arq/INSS.SOAP.RRELAPG'||
                    to_char(vr_dtmvtolt,'DDMMYYYY')||
                    vr_dstime||pr_cdoperad;
                    
      --Determinar Nome Arquivo movido              
      vr_movarqto:= vr_nmdireto||'/salvar/inss';
      
      --Determinar Nome Arquivo RL                  
      vr_nmarquiv:= vr_nmdireto||'/rl/'||pr_cdoperad||'_'||vr_dstime||'_'||'PAGAR.pdf';
      
      --Bloco Pagar
      BEGIN
          
        --Gerar cabecalho XML
        inss0001.pc_gera_cabecalho_soap (pr_idservic => 4   /* idservic */ 
                                        ,pr_nmmetodo => 'rel:InGerarRelatorioAPagarBeneficioINSS' --Nome Metodo
                                        ,pr_username => 'app_cecred_client' --Username
                                        ,pr_password => fn_senha_sicredi    --Senha
                                        ,pr_dstexto  => vr_dstexto          --Texto do Arquivo de Dados
                                        ,pr_des_reto => vr_des_reto         --Retorno OK/NOK
                                        ,pr_dscritic => vr_dscritic);       --Descricao da Critica
                                       
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          RAISE vr_exc_saida;
        END IF;

        /*Monta as tags de envio
        OBS.: O valor das tags deve respeitar a formatacao presente na
              base do SICREDI do contrario, a operacao nao sera
              realizada. */
        vr_dstexto:= vr_dstexto||
            '<rel:InGerarRelatorioBeneficioINSS>'||
               '<rel:UnidadeAtendimento>'||
                  '<v14:Cooperativa>'||
                    '<v14:CodigoCooperativa>'||rw_crapcop.cdagesic||'</v14:CodigoCooperativa>'||
                       '<v14:UnidadesAtendimento>'||
                       '<v14:UnidadeAtendimento/>'||
                    '</v14:UnidadesAtendimento>'||
                 '</v14:Cooperativa>'||
                    '<v14:NumeroUnidadeAtendimento>'||vr_cdagenci||'</v14:NumeroUnidadeAtendimento>'||
               '</rel:UnidadeAtendimento>';
        IF pr_dtinirec IS NOT NULL THEN
          vr_dstexto:= vr_dstexto||
          '<rel:DataInicioValidade>'||to_char(vr_dtinirec,'YYYY-MM-DD')||'T00:00:00</rel:DataInicioValidade>'||
          '<rel:DataFimValidade>'||to_char(vr_dtfinrec,'YYYY-MM-DD')||'T00:00:00</rel:DataFimValidade>';
        ELSE
          vr_dstexto:= vr_dstexto||
               '<rel:DataInicioValidade>'||to_char(last_day(add_months(vr_dtmvtolt,1)),'YYYY-MM-DD')||'T00:00:00</rel:DataInicioValidade>'||
               '<rel:DataFimValidade>'||to_char(trunc(add_months(vr_dtmvtolt,-1),'MM'),'YYYY-MM-DD')||'T00:00:00</rel:DataFimValidade>';
        END IF;
        --Se foi passado o beneficiario
        IF NVL(pr_nrrecben,0) <> 0 THEN 
          
          vr_dstexto:= vr_dstexto||
           '<rel:Beneficiario>'||
               '<v15:Identificadores>'||
                  '<v15:IdentificadorBeneficiario>'||
                     '<v15:Codigo>'||lpad(pr_nrrecben,10,'0')||'</v15:Codigo>'||
                     '<v15:TipoCodigo>'||pr_tpnrbene||'</v15:TipoCodigo>'||
                  '</v15:IdentificadorBeneficiario>'||
               '</v15:Identificadores>'||
           '</rel:Beneficiario>';
        END IF;
         
        --Orgaos Pagadores
        IF nvl(pr_cdagesel,0) > 0 THEN
          vr_dstexto:= vr_dstexto||
            '<rel:OrgaosPagadores>'||
               '<dad:OrgaoPagador>'||
                  '<v15:NumeroOrgaoPagador>'||pr_cdorgins||'</v15:NumeroOrgaoPagador>'||
               '</dad:OrgaoPagador>'||
            '</rel:OrgaosPagadores>';
        ELSE
          vr_dstexto:= vr_dstexto||'<rel:OrgaosPagadores>';
          
          /*Busca todos os PA's para consulta*/
          FOR rw_crapage IN cr_crapage_cdorgins (pr_cdcooper => pr_cdcooper) LOOP 
            vr_dstexto:= vr_dstexto||
              '<dad:OrgaoPagador>'||
                  '<v15:NumeroOrgaoPagador>'||rw_crapage.cdorgins||'</v15:NumeroOrgaoPagador>'||
              '</dad:OrgaoPagador>';
          END LOOP;  
          
          vr_dstexto:= vr_dstexto||'</rel:OrgaosPagadores>';
          
        END IF;
           
        vr_dstexto:= vr_dstexto||
                  '</rel:InGerarRelatorioBeneficioINSS>'||
                  '<rel:StatusBeneficio>'||pr_tpconrel||'</rel:StatusBeneficio>'||
                '</rel:InGerarRelatorioAPagarBeneficioINSS>'||
             '</soapenv:Body>'||
          '</soapenv:Envelope>'; 
            
        --Efetuar Requisicao Soap
        inss0001.pc_efetua_requisicao_soap (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa 
                                           ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                           ,pr_nrdcaixa => pr_nrdcaixa   --Numero Caixa
                                           ,pr_idservic => 3             --Identificador Servico
                                           ,pr_dsservic => 'Relatorio de beneficios a pagar' --Descricao Servico
                                           ,pr_nmmetodo => 'OutGerarRelatorioAPagarBeneficioINSS' --Nome Método
                                           ,pr_dstexto  => vr_dstexto    --Texto com a msg XML
                                           ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                           ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                           ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                           ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo Log
                                           ,pr_nmdatela => pr_nmdatela   --Nome da Tela
                                           ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                           ,pr_dscritic => vr_dscritic); --Descrição Erros
                                           
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
        
        --Verifica Falha no Pacote
        inss0001.pc_obtem_fault_packet (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa 
                                       ,pr_nmdatela => pr_nmdatela   --Nome da Tela
                                       ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                       ,pr_nrdcaixa => pr_nrdcaixa   --Numero Caixa
                                       ,pr_dsderror => 'SOAP-ENV:-950' --Descricao Servico
                                       ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                       ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                       ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                       ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo log
                                       ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                       ,pr_dscritic => vr_dscritic); --Mensagem Erro
                                       
        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          pr_des_erro:= vr_des_reto;
          
          --Levnta exceção
          RAISE vr_exc_saida;
        ELSE
          /** Valida SOAP retornado pelo WebService **/
          gene0002.pc_arquivo_para_xml (pr_nmarquiv => vr_msgreceb    --> Nome do caminho completo) 
                                       ,pr_xmltype  => vr_XML         --> Saida para o XML
                                       ,pr_des_reto => vr_des_reto    --> Descrição OK/NOK
                                       ,pr_dscritic => vr_dscritic    --> Descricao Erro 
                                       ,pr_tipmodo => 2);

          --Se Ocorreu erro
          IF vr_des_reto = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_saida;  
          END IF;              
          
          --Realizar o Parse do Arquivo XML
          vr_xmldoc:= xmldom.newDOMDocument(vr_XML);
              
          --Lista de nodos
          vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'PDFFILE');
            
          --Se nao existir a tag "PDFFILE" 
          IF xmldom.getLength(vr_lista_nodo) = 0 THEN
            
            vr_dscritic:= 'Relatorio invalido.';
            
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;  
        
          /* Arquivo OK, percorrer as tags para extrair informacoes */
          
          --Lista de nodos
          vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'*');
            
          --Quantidade tags no XML
          vr_qtlinha:= xmldom.getLength(vr_lista_nodo);
            
          /* Processar as linhas do Arquivo */
          FOR vr_linha IN 1..(vr_qtlinha-1) LOOP
              
            --Buscar Nodo Corrente
            vr_nodo:= xmldom.item(vr_lista_nodo,vr_linha);
              
            --Nome Parametro Nodo corrente
            vr_nmparam:= xmldom.getNodeName(vr_nodo);
              
            --Buscar somente sufixo (o que tem apos o caracter :)
            vr_nmparam:= SUBSTR(vr_nmparam,instr(vr_nmparam,':')+1);
              
            --Tratar parametros que possuem dados  
            CASE vr_nmparam
                
              WHEN 'PDFFILE' THEN
                
                --Buscar o Nodo  
                vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                
                -- Inicializar o CLOB
                dbms_lob.createtemporary(vr_clob, TRUE);
                dbms_lob.OPEN(vr_clob, dbms_lob.lob_readwrite); 
                
                -- Inicializar o BLOB
                dbms_lob.createtemporary(vr_blob, TRUE);
                dbms_lob.OPEN(vr_blob, dbms_lob.lob_readwrite);
                
                --Converte o conteudo do nodo para o tipo CLOB
                xmldom.writeToClob(vr_nodo,vr_clob);
            
                --Recebe conteudo descriptografado
                vr_blob:= fn_base64DecodeClobAsBlob(vr_clob);

                --Fechar Clob e Liberar Memoria	
                dbms_lob.close(vr_clob);
                dbms_lob.freetemporary(vr_clob);              
                
                -- Ayllos Web           
                IF pr_idorigem = 5      AND            
                   NOT vr_blob IS NULL THEN  
                   
                  BEGIN 
                    gene0002.pc_blob_para_arquivo(pr_blob     => vr_blob   
                                                 ,pr_caminho  => vr_nmdireto || '/rl' 
                                                 ,pr_arquivo  => vr_nmarquiv
                                                 ,pr_des_erro => vr_dscritic);
                                                 
                    -- Se retornou erro, incrementar a mensagem e retornoar
                    IF vr_dscritic IS NOT NULL THEN
                    
                      --Fechar Blob e Liberar Memoria	
                      dbms_lob.freetemporary(vr_blob); 
                      
                      --Gera exceção
                      RAISE vr_exc_saida;
                      
                    END IF;
                    
                  END;
                  
                END IF; --pr_idorigem = 5
                
                --Fechar Blob e Liberar Memoria	
                dbms_lob.freetemporary(vr_blob); 
                
              ELSE NULL;
              
            END CASE;
            
          END LOOP;
                  
          --Retornar OK
          vr_retornvl:= 'OK'; 
                
        END IF;  
                                            
      EXCEPTION
        WHEN vr_exc_saida THEN 
          vr_retornvl:= 'NOK';
      END;  
      
      --Eliminar arquivos requisicao
      inss0001.pc_elimina_arquivos_requis (pr_cdcooper => pr_cdcooper      --Codigo Cooperativa
                                          ,pr_cdprogra => pr_nmdatela      --Nome do Programa
                                          ,pr_msgenvio => vr_msgenvio      --Mensagem Envio
                                          ,pr_msgreceb => vr_msgreceb      --Mensagem Recebimento
                                          ,pr_movarqto => vr_movarqto      --Nome Arquivo mover
                                          ,pr_nmarqlog => vr_nmarqlog      --Nome Arquivo LOG
                                          ,pr_des_reto => vr_des_reto      --Retorno OK/NOK 
                                          ,pr_dscritic => vr_dscritic2);    --Descricao Erro
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        vr_dscritic:= vr_dscritic2;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;     
      
		  --Incluir nome do módulo logado - Chamado 664301
      --Seta novamente esta rotina porque foi alterado dentro da pc_elimina_arquivos_requis
			GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_solic_rel_benef_pagar');            
      
      IF vr_retornvl = 'NOK' THEN
        
        --Se nao tem a descricao do erro
        IF vr_cdcritic = 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= 'Nao foi possivel gerar o relatorio de beneficios a pagar/bloqueados.';
        END IF;    
        
        -- Gravar Linha Log
        inss0001.pc_retorna_linha_log(pr_cdcooper => pr_cdcooper   --Codigo Cooperativa 
                                     ,pr_cdprogra => pr_nmdatela   --Nome do Programa
                                     ,pr_dtmvtolt => vr_dtmvtolt   --Data Movimento
                                     ,pr_nrdconta => 0             --Numero da Conta
                                     ,pr_nrcpfcgc => 0             --Numero Cpf
                                     ,pr_nrrecben => pr_nrrecben   --Numero Recebimento Beneficio
                                     ,pr_nmmetodo => 'Relatorio beneficios a pagar/bloqueados'                --Nome do metodo
                                     ,pr_cdderror => vr_cdcritic   --Codigo Erro
                                     ,pr_dsderror => vr_dscritic   --Descricao Erro
                                     ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo LOG
                                     ,pr_cdtipofalha => 1          --tipo 4 não abre chamado
                                     ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                     ,pr_dscritic => vr_dscritic2  --Descricao erro
                                     );
                                     
                                     
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          vr_dscritic:= vr_dscritic2;          
        END IF;
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF;
      
      --Retorno OK
      pr_des_erro:= vr_retornvl;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
       
        -- Retorno não OK          
        pr_des_erro:= vr_retornvl;
        
        --Mensagem de critica
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;        
                                     
      WHEN OTHERS THEN
      
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        --Monta mensagem de critica
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro na inss0001.pc_solic_rel_benef_pagar --> '|| SQLERRM;
                                     
  END pc_solic_rel_benef_pagar;
  
  /* Procedure para Solicitar Relatorio Beneficios Pagos */
  PROCEDURE pc_solic_rel_benef_pagos  (pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                      ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                      ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                      ,pr_idorigem IN INTEGER                 --Origem Processamento
                                      ,pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                      ,pr_nmdatela IN VARCHAR2                --Nome da tela
                                      ,pr_cdoperad IN VARCHAR2                --Operador
                                      ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                      ,pr_cdagesel IN INTEGER                 --Codigo Agencia Selecionada
                                      ,pr_cdorgins IN INTEGER                 --Codigo do orgão pagador INSS-SICREDI
                                      ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                      ,pr_tpnrbene IN VARCHAR2                --Tipo Numero Beneficiario
                                      ,pr_dtinirec IN VARCHAR2                --Data Inicio Recebimento
                                      ,pr_dtfinrec IN VARCHAR2                --Data Final Recebimento
                                      ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                      ,pr_tpconrel IN VARCHAR2                --Tipo Relatorio
                                      ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                      ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                      ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK
  /*--------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solic_rel_benef_pagos             Antigo: procedures/b1wgen0091.p/solicita_relatorio_beneficios_pagos
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Fevereiro/2015                           Ultima atualizacao: 21/06/2016
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para solicitar ao SICREDI relatorio de beneficios pagos 
  
    Alterações : 12/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
    
                 30/03/2015 - Retirado as validações de parâmetros e incluído o tratamento 
                              para receber o conteúdo do relatório, decriptografa-lo e grava-lo
                              em arquivo
                              (Adriano).
                              
                 16/06/2015 - Ajuste para enviar o OP corretamente quando for especificado a consulta
                              por um PA especifico 
                              (Adriano).             
                              
                 21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                              (Adriano - SD 473539).
                                         
                 23/06/2016 - Incluir nome do módulo logado - (Ana - Envolti - Chamado 664301)
  ---------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Selecionar dados da agencia
    CURSOR cr_crapage (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
    SELECT crapage.cdcooper
          ,crapage.cdorgins
          ,crapage.cdagenci
     FROM crapage
    WHERE crapage.cdcooper = pr_cdcooper
      AND crapage.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;
         
    -- Selecionar dados da agencia
    CURSOR cr_crapage_cdorgins (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapage.cdcooper
          ,crapage.cdorgins
          ,crapage.cdagenci
      FROM crapage
     WHERE crapage.cdcooper = pr_cdcooper
       AND NVL(crapage.cdorgins,0) > 0;
    
    --Tabela de Memoria de erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Constantes
    vr_cdagenci INTEGER:= 2;
       
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_dscritic2 VARCHAR2(4000); 
    
    --Variaveis locais
    vr_blob     BLOB := EMPTY_BLOB;
    vr_clob     CLOB;    
    vr_dstime   VARCHAR2(100);
    vr_nmarquiv VARCHAR2(1000);
    vr_msgenvio VARCHAR2(32767);
    vr_msgreceb VARCHAR2(32767);
    vr_movarqto VARCHAR2(32767);
    vr_nmarqlog VARCHAR2(32767);
    vr_nmdireto VARCHAR2(1000);
    vr_des_reto VARCHAR2(3);
    vr_retornvl VARCHAR2(3):= 'NOK'; 
    vr_dstexto  VARCHAR2(32767);
    vr_dtinirec DATE;
    vr_dtfinrec DATE;
    vr_dtmvtolt DATE;
    
    --Variaveis Documentos DOM
    vr_xmldoc     xmldom.DOMDocument;
    vr_lista_nodo xmldom.DOMNodeList;
    vr_nodo       xmldom.DOMNode;
    vr_qtlinha    INTEGER;
    vr_nmparam    VARCHAR2(1000);
    
    --Manipulacao de dados
    vr_XML  XMLType;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;                                       
    vr_exc_saida EXCEPTION; 
    
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
			GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_solic_rel_benef_pagos');
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= NULL;      
      vr_nmarquiv:= NULL;
      vr_msgenvio:= NULL;
      vr_msgreceb:= NULL;
      vr_movarqto:= NULL;
      vr_nmarqlog:= NULL;
      vr_dstime:=   NULL;
      
      BEGIN                                                  
        --Pega a data movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/YYYY'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      BEGIN                                                  
        --Pega o periodo incial e converte para "DATE"
        vr_dtinirec:= to_date(pr_dtinirec,'DD/MM/YYYY');
              
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Periodo incial invalido.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      BEGIN                                                  
        --Pega o periodo final e converte para "DATE"        
        vr_dtfinrec:= to_date(pr_dtfinrec,'DD/MM/YYYY');
              
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Periodo final invalido.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
       RAISE vr_exc_erro;
       
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
  
      --Buscar Diretorio Padrao da Cooperativa
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => null);
                                          
      --Determinar Nomes do Arquivo de Log
      vr_nmarqlog:= 'SICREDI_Soap_LogErros';

      --Buscar o Horario
      vr_dstime:= lpad(gene0002.fn_busca_time,5,'0');
      
      --Determinar Nomes do Arquivo de Envio
      vr_msgenvio:= vr_nmdireto|| '/arq/INSS.SOAP.ERELPAG'||
                    to_char(vr_dtmvtolt,'DDMMYYYY')||
                    vr_dstime||pr_cdoperad;
                    
      --Determinar Nome do Arquivo de Recebimento    
      vr_msgreceb:= vr_nmdireto||'/arq/INSS.SOAP.RRELPAG'||
                    to_char(vr_dtmvtolt,'DDMMYYYY')||
                    vr_dstime||pr_cdoperad;
                    
      --Determinar Nome Arquivo movido              
      vr_movarqto:= vr_nmdireto||'/salvar/inss';
      
      --Determinar Nome Arquivo RL                  
      vr_nmarquiv:= vr_nmdireto||'/rl/'||pr_cdoperad||'_'||vr_dstime||'_'||'PAGOS.pdf';
      
      --Bloco Pagos
      BEGIN
          
        --Gerar cabecalho XML
        inss0001.pc_gera_cabecalho_soap (pr_idservic => 4   /* idservic */ 
                                        ,pr_nmmetodo => 'rel:InGerarRelatorioPagosBeneficioINSS' --Nome Metodo
                                        ,pr_username => 'app_cecred_client' --Username
                                        ,pr_password => fn_senha_sicredi    --Senha
                                        ,pr_dstexto  => vr_dstexto          --Texto do Arquivo de Dados
                                        ,pr_des_reto => vr_des_reto         --Retorno OK/NOK
                                        ,pr_dscritic => vr_dscritic);       --Descricao da Critica
                                       
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          RAISE vr_exc_saida;
        END IF;

        /*Monta as tags de envio
        OBS.: O valor das tags deve respeitar a formatacao presente na
              base do SICREDI do contrario, a operacao nao sera realizada. */
        vr_dstexto:= vr_dstexto||
            '<rel:InGerarRelatorioBeneficioINSS>'||
                '<rel:UnidadeAtendimento>'||
                    '<v14:Cooperativa>'||
                        '<v14:CodigoCooperativa>'||rw_crapcop.cdagesic||'</v14:CodigoCooperativa>'||
                           '<v14:UnidadesAtendimento>'||
                           '<v14:UnidadeAtendimento/>'||
                        '</v14:UnidadesAtendimento>'||
                    '</v14:Cooperativa>'||
                    '<v14:NumeroUnidadeAtendimento>'||vr_cdagenci||'</v14:NumeroUnidadeAtendimento>'||
                '</rel:UnidadeAtendimento>'||
                '<rel:DataInicioRecebimento>'||to_char(vr_dtinirec,'YYYY-MM-DD')||'T00:00:00</rel:DataInicioRecebimento>'||
                '<rel:DataFimRecebimento>'||to_char(vr_dtfinrec,'YYYY-MM-DD')||'T00:00:00</rel:DataFimRecebimento>';

        --Se foi passado o beneficiario
        IF nvl(pr_nrrecben,0) <> 0 THEN 
          
          vr_dstexto:= vr_dstexto||
           '<rel:Beneficiario>'||
               '<v15:Identificadores>'||
                   '<v15:IdentificadorBeneficiario>'||
                      '<v15:Codigo>'||lpad(pr_nrrecben,10,'0')||'</v15:Codigo>'||
                      '<v15:TipoCodigo>'||pr_tpnrbene||'</v15:TipoCodigo>'||
                   '</v15:IdentificadorBeneficiario>'||
               '</v15:Identificadores>'||
           '</rel:Beneficiario>';
        END IF;
         
        --Orgaos Pagadores
        IF nvl(pr_cdagesel,0) > 0 THEN
          vr_dstexto:= vr_dstexto||
            '<rel:OrgaosPagadores>'||
               '<dad:OrgaoPagador>'||
                  '<v15:NumeroOrgaoPagador>'||pr_cdorgins||'</v15:NumeroOrgaoPagador>'||
               '</dad:OrgaoPagador>'||
            '</rel:OrgaosPagadores>';
        ELSE
          vr_dstexto:= vr_dstexto||'<rel:OrgaosPagadores>';
          
          /*Busca todos os PA's para consulta*/
          FOR rw_crapage IN cr_crapage_cdorgins (pr_cdcooper => pr_cdcooper) LOOP 
            vr_dstexto:= vr_dstexto||
              '<dad:OrgaoPagador>'||
                 '<v15:NumeroOrgaoPagador>'||rw_crapage.cdorgins||'</v15:NumeroOrgaoPagador>'||
              '</dad:OrgaoPagador>';
          END LOOP;  
          vr_dstexto:= vr_dstexto||'</rel:OrgaosPagadores>';
        END IF;
           
        vr_dstexto:= vr_dstexto||
                      '</rel:InGerarRelatorioBeneficioINSS>'||
                   '<rel:StatusBeneficio>'||pr_tpconrel||'</rel:StatusBeneficio>'||
                '</rel:InGerarRelatorioPagosBeneficioINSS>'||
             '</soapenv:Body>'||
          '</soapenv:Envelope>';
            
        --Efetuar Requisicao Soap
        inss0001.pc_efetua_requisicao_soap (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa 
                                           ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                           ,pr_nrdcaixa => pr_nrdcaixa   --Numero Caixa
                                           ,pr_idservic => 3             --Identificador Servico
                                           ,pr_dsservic => 'Relatorio de beneficios pagos' --Descricao Servico
                                           ,pr_nmmetodo => 'OutGerarRelatorioPagosBeneficioINSS' --Nome Método
                                           ,pr_dstexto  => vr_dstexto    --Texto com a msg XML
                                           ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                           ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                           ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                           ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo Log
                                           ,pr_nmdatela => pr_nmdatela   --Nome da Tela
                                           ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                           ,pr_dscritic => vr_dscritic); --Descrição Erros
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
                
        --Verifica Falha no Pacote
        inss0001.pc_obtem_fault_packet (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa 
                                       ,pr_nmdatela => pr_nmdatela   --Nome da Tela
                                       ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                       ,pr_nrdcaixa => pr_nrdcaixa   --Numero Caixa
                                       ,pr_dsderror => 'SOAP-ENV:-950' --Descricao Servico
                                       ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                       ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                       ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                       ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo log
                                       ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                       ,pr_dscritic => vr_dscritic); --Mensagem Erro
        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          pr_des_erro:= vr_des_reto;
          RAISE vr_exc_saida;
        ELSE
          /** Valida SOAP retornado pelo WebService **/
          gene0002.pc_arquivo_para_xml (pr_nmarquiv => vr_msgreceb    --> Nome do caminho completo) 
                                       ,pr_xmltype  => vr_XML         --> Saida para o XML
                                       ,pr_des_reto => vr_des_reto    --> Descrição OK/NOK
                                       ,pr_dscritic => vr_dscritic    --> Descricao Erro 
                                       ,pr_tipmodo  => 2);            --> Trata arquivo com tamanho maior do que o siportado

          --Se Ocorreu erro
          IF vr_des_reto = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_saida;  
          END IF;              
          
          --Realizar o Parse do Arquivo XML
          vr_xmldoc:= xmldom.newDOMDocument(vr_XML);
              
          --Lista de nodos
          vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'PDFFILE');
            
          --Se nao existir a tag "PDFFILE" 
          IF xmldom.getLength(vr_lista_nodo) = 0 THEN
            
            vr_dscritic:= 'Relatorio invalido.';
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;  
        
          /* Arquivo OK, percorrer as tags para extrair informacoes */
          
          --Lista de nodos
          vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'*');
            
          --Quantidade tags no XML
          vr_qtlinha:= xmldom.getLength(vr_lista_nodo);
            
          /* Processar as linhas do Arquivo */
          FOR vr_linha IN 1..(vr_qtlinha-1) LOOP
              
            --Buscar Nodo Corrente
            vr_nodo:= xmldom.item(vr_lista_nodo,vr_linha);
              
            --Nome Parametro Nodo corrente
            vr_nmparam:= xmldom.getNodeName(vr_nodo);
              
            --Buscar somente sufixo (o que tem apos o caracter :)
            vr_nmparam:= SUBSTR(vr_nmparam,instr(vr_nmparam,':')+1);
              
            --Tratar parametros que possuem dados  
            CASE vr_nmparam
                
              WHEN 'PDFFILE' THEN
                
                --Buscar o Nodo  
                vr_nodo:= xmldom.getFirstChild(vr_nodo);      
                
                -- Inicializar o CLOB
                dbms_lob.createtemporary(vr_clob, TRUE);
                dbms_lob.OPEN(vr_clob, dbms_lob.lob_readwrite);
                
                -- Inicializar o BLOB
                dbms_lob.createtemporary(vr_blob, TRUE);
                dbms_lob.OPEN(vr_blob, dbms_lob.lob_readwrite);

                --Converte o conteudo do nodo para CLOB
                xmldom.WRITETOCLOB(vr_nodo,vr_clob);
                
                --Recebe conteudo descriptografado
                vr_blob:= fn_base64DecodeClobAsBlob(vr_clob);

                --Fechar Clob e Liberar Memoria	
                dbms_lob.close(vr_clob);
                dbms_lob.freetemporary(vr_clob);         
                
                -- Ayllos Web           
                IF pr_idorigem = 5      AND
                   NOT vr_clob IS NULL THEN  
                   
                  BEGIN 
                    gene0002.pc_blob_para_arquivo(pr_blob     => vr_blob   
                                                 ,pr_caminho  => vr_nmdireto || '/rl' 
                                                 ,pr_arquivo  => vr_nmarquiv
                                                 ,pr_des_erro => vr_dscritic);
                                                 
                    -- Se retornou erro, incrementar a mensagem e retornoar
                    IF vr_dscritic IS NOT NULL THEN
                    
                      --Fechar Blob e Liberar Memoria	
                      dbms_lob.freetemporary(vr_blob); 
                      
                      --Gera exceção
                      RAISE vr_exc_saida;
                      
                    END IF;
                    
                  END;
                  
                END IF;--pr_idorigem = 5          
                
                --Fechar Blob e Liberar Memoria	
                dbms_lob.freetemporary(vr_blob); 
                                            
              ELSE NULL;
              
            END CASE;
            
          END LOOP;
          
          --Retorno
          vr_retornvl:= 'OK';
                  
        END IF; 
                                            
      EXCEPTION
        WHEN vr_exc_saida THEN 
          vr_retornvl:= 'NOK';
      END;  
      
      --Eliminar arquivos requisicao
      inss0001.pc_elimina_arquivos_requis (pr_cdcooper => pr_cdcooper      --Codigo Cooperativa
                                          ,pr_cdprogra => pr_nmdatela      --Nome do Programa
                                          ,pr_msgenvio => vr_msgenvio      --Mensagem Envio
                                          ,pr_msgreceb => vr_msgreceb      --Mensagem Recebimento
                                          ,pr_movarqto => vr_movarqto      --Nome Arquivo mover
                                          ,pr_nmarqlog => vr_nmarqlog      --Nome Arquivo LOG
                                          ,pr_des_reto => vr_des_reto      --Retorno OK/NOK 
                                          ,pr_dscritic => vr_dscritic2);    --Descricao Erro
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        vr_dscritic:= vr_dscritic2;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;     
      
		  --Incluir nome do módulo logado - Chamado 664301
      --Seta novamente esta rotina porque foi alterado dentro da pc_elimina_arquivos_requis
			GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_solic_rel_benef_pagos');            
      
      IF vr_retornvl = 'NOK' THEN
        
        --Se nao tem a descricao do erro
        IF vr_cdcritic = 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= 'Nao foi possivel gerar o relatorio de beneficios pagos.';
        END IF;                 
               
        -- Gravar Linha Log
        inss0001.pc_retorna_linha_log(pr_cdcooper => pr_cdcooper   --Codigo Cooperativa 
                                     ,pr_cdprogra => pr_nmdatela   --Nome do Programa
                                     ,pr_dtmvtolt => vr_dtmvtolt   --Data Movimento
                                     ,pr_nrdconta => 0             --Numero da Conta
                                     ,pr_nrcpfcgc => 0             --Numero Cpf
                                     ,pr_nrrecben => pr_nrrecben   --Numero Recebimento Beneficio
                                     ,pr_nmmetodo => 'Relatorio beneficios pagos' --Nome do metodo
                                     ,pr_cdderror => vr_cdcritic   --Codigo Erro
                                     ,pr_dsderror => vr_dscritic   --Descricao Erro
                                     ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo LOG
                                     ,pr_cdtipofalha => 1          --tipo 4 não abre chamado
                                     ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                     ,pr_dscritic => vr_dscritic2); --Descricao erro
                                     
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          vr_dscritic:= vr_dscritic2;          
        
        END IF;
        
        --Levantar Excecao
        RAISE vr_exc_erro;
                
      END IF;
         
      --Retorno OK
      pr_des_erro:= vr_retornvl;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= vr_retornvl;
        
        -- Codigos de Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
                                     
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Codigo de Erro
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro na inss0001.pc_solic_rel_benef_pagos --> '|| SQLERRM;
                                     
  END pc_solic_rel_benef_pagos;

  /* Procedure para Solicitar Relatorio Historico cadastral */
  PROCEDURE pc_solic_rel_hist_cadastral (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                        ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                        ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                        ,pr_tpnrbene IN VARCHAR2                --Tipo Numero Beneficiario                                       
                                        ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                        ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                        ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                        ,pr_des_reto OUT VARCHAR2) IS           --Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solic_rel_hist_cadastral             
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano Marchi
    Data     : Marco/2015                           Ultima atualizacao: 21/06/2016
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para solicitar ao SICREDI relatorio de historico cadastral
  
    Alterações : 30/03/2015 - Alterado nome do arquivo de envio/recebimento
                              (Adriano).
    
                 21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                              (Adriano - SD 473539).
                
                 23/06/2016 - Incluir nome do módulo logado - (Ana - Envolti - Chamado 664301)
  ---------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    --Tabela Erros 
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
    vr_dscritic2 VARCHAR2(4000); 
    
    --Variaveis Locais
    vr_dstime   VARCHAR2(100);
    vr_nmarquiv VARCHAR2(1000);    
    vr_nmarqpdf VARCHAR2(1000);
    vr_msgenvio VARCHAR2(32767);
    vr_msgreceb VARCHAR2(32767);
    vr_movarqto VARCHAR2(32767);
    vr_nmarqlog VARCHAR2(32767);
    vr_nmdireto VARCHAR2(1000);
    vr_comando  VARCHAR2(1000);
    vr_typ_saida VARCHAR2(3);
    vr_des_reto VARCHAR2(3);
    vr_retornvl VARCHAR2(3):= 'NOK';
    vr_dstexto  VARCHAR2(32767);
    vr_dtmvtolt DATE;
    vr_auxconta PLS_INTEGER:= 0;
    vr_conteudo VARCHAR2(32767);
    vr_clob     CLOB;
    vr_blob     BLOB := EMPTY_BLOB;
    
    --Manipulacao de dados
    vr_XML  XMLType;
    
    --Variaveis Documentos DOM
    vr_xmldoc     xmldom.DOMDocument;
    vr_lista_nodo xmldom.DOMNodeList;
    vr_nodo       xmldom.DOMNode;
    vr_qtlinha    INTEGER;
    vr_nmparam    VARCHAR2(1000);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;                                       
    vr_exc_saida EXCEPTION; 
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= NULL;
      vr_nmarquiv:= NULL;
      vr_msgenvio:= NULL;
      vr_msgreceb:= NULL;
      vr_movarqto:= NULL;
      vr_nmarqlog:= NULL;
      vr_dstime:=   NULL;
           
      BEGIN                                                  
        --Pega a data movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/YYYY'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
        
  	  -- Incluir nome do módulo logado - Chamado 664301
			GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_solic_rel_hist_cadastral');
              
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => vr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;       
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
  
      --Buscar Diretorio Padrao da Cooperativa
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => null);
                                          
      --Determinar Nomes do Arquivo de Log
      vr_nmarqlog:= 'SICREDI_Soap_LogErros';

      --Buscar o Horario
      vr_dstime:= lpad(gene0002.fn_busca_time,5,'0');
      
      --Determinar Nomes do Arquivo de Envio
      vr_msgenvio:= vr_nmdireto|| '/arq/INSS.SOAP.ERELHIS'||
                    to_char(vr_dtmvtolt,'DDMMYYYY')||
                    vr_dstime||vr_cdoperad;
                    
      --Determinar Nome do Arquivo de Recebimento    
      vr_msgreceb:= vr_nmdireto||'/arq/INSS.SOAP.RRELHIS'||
                    to_char(vr_dtmvtolt,'DDMMYYYY')||
                    vr_dstime||vr_cdoperad;
                    
      --Determinar Nome Arquivo movido              
      vr_movarqto:= vr_nmdireto||'/salvar/inss';
      
      --Determinar Nome Arquivo RL                  
      vr_nmarquiv:= vr_nmdireto||'/rl/'||pr_dsiduser;
      
      --Se encontrou o arquivo elimina
      IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmarquiv) THEN
        vr_comando:= 'rm '||vr_nmarquiv||'* 2>/dev/null';

        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
                                
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          
          --Monta mensagem de critica
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
                          
          -- retornando ao programa chamador
          RAISE vr_exc_erro;
          
        END IF; 
      END IF;  
      
      --Determinar nome arquivo
      vr_nmarquiv:= vr_nmarquiv ||vr_dstime||'.pdf';
            
      --Bloco Historico
      BEGIN
        
        -- Valida NB
        IF NVL(pr_nrrecben,0) =  0   OR 
           LENGTH(pr_nrrecben) > 10 THEN
          
          --Monta mensagem de critica
          vr_dscritic:= 'Beneficiario invalido.';
          pr_nmdcampo:= 'nrrecben';
          
          --Excecao
          RAISE vr_exc_saida;
        
        END IF;
          
        --Gerar cabecalho XML
        inss0001.pc_gera_cabecalho_soap (pr_idservic => 6   /* idservic */ 
                                        ,pr_nmmetodo => 'rel:InRelatorioAlteracaoBeneficiarioINSS' --Nome Metodo                                                       
                                        ,pr_username => 'app_cecred_client' --Username
                                        ,pr_password => fn_senha_sicredi    --Senha
                                        ,pr_dstexto  => vr_dstexto          --Texto do Arquivo de Dados
                                        ,pr_des_reto => vr_des_reto         --Retorno OK/NOK
                                        ,pr_dscritic => vr_dscritic);       --Descricao da Critica
                                       
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          RAISE vr_exc_saida;
        END IF;

        /*Monta as tags de envio
        OBS.: O valor das tags deve respeitar a formatacao presente na
              base do SICREDI do contrario, a operacao nao sera
              realizada. */
        vr_dstexto:= vr_dstexto || '<dad:codBeneficiario>' || lpad(pr_nrrecben,10,'0') || '</dad:codBeneficiario>' ||
                                '</rel:InRelatorioAlteracaoBeneficiarioINSS>'||
                            '</soapenv:Body>'||
                         '</soapenv:Envelope>';
 
            
        --Efetuar Requisicao Soap
        inss0001.pc_efetua_requisicao_soap (pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                           ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                           ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                           ,pr_idservic => 8             --Identificador Servico
                                           ,pr_dsservic => 'Relatorio de historico cadastral' --Descricao Servico
                                           ,pr_nmmetodo => 'OutRelatorioAlteracaoBeneficiarioINSS' --Nome Método
                                           ,pr_dstexto  => vr_dstexto    --Texto com a msg XML
                                           ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                           ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                           ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                           ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo Log
                                           ,pr_nmdatela => vr_nmdatela   --Nome da Tela
                                           ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                           ,pr_dscritic => vr_dscritic); --Descrição Erros
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        ELSE
          
          /** Valida SOAP retornado pelo WebService **/
          gene0002.pc_arquivo_para_xml (pr_nmarquiv => vr_msgreceb    --> Nome do caminho completo) 
                                       ,pr_xmltype  => vr_XML         --> Saida para o XML
                                       ,pr_des_reto => vr_des_reto    --> Descrição OK/NOK
                                       ,pr_dscritic => vr_dscritic);  --> Descricao Erro 

          --Se Ocorreu erro
          IF vr_des_reto = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_saida;  
          END IF;              
          
          --Realizar o Parse do Arquivo XML
          vr_xmldoc:= xmldom.newDOMDocument(vr_XML);
              
          --Lista de nodos
          vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'PDFFILE');
            
          --Se nao existir a tag "PDFFILE" 
          IF xmldom.getLength(vr_lista_nodo) = 0 THEN
            
            vr_dscritic:= 'Relatorio invalido.';
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;  
        
          /* Arquivo OK, percorrer as tags para extrair informacoes */
          
          --Lista de nodos
          vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'*');
            
          --Quantidade tags no XML
          vr_qtlinha:= xmldom.getLength(vr_lista_nodo);
            
          /* Processar as linhas do Arquivo */
          FOR vr_linha IN 1..(vr_qtlinha-1) LOOP
              
            --Buscar Nodo Corrente
            vr_nodo:= xmldom.item(vr_lista_nodo,vr_linha);
              
            --Nome Parametro Nodo corrente
            vr_nmparam:= xmldom.getNodeName(vr_nodo);
              
            --Buscar somente sufixo (o que tem apos o caracter :)
            vr_nmparam:= SUBSTR(vr_nmparam,instr(vr_nmparam,':')+1);
              
            --Tratar parametros que possuem dados  
            CASE vr_nmparam
                
              WHEN 'PDFFILE' THEN
                
                --Buscar o Nodo  
                vr_nodo:= xmldom.getFirstChild(vr_nodo);                
             
                vr_conteudo := xmldom.getNodeValue(vr_nodo);
                                                   
              ELSE NULL;
              
            END CASE;
            
          END LOOP;
                     
          -- Ayllos Web           
          IF vr_idorigem = 5         AND
             NOT vr_conteudo IS NULL THEN  
             
            -- Inicializar o CLOB
            dbms_lob.createtemporary(vr_clob, TRUE);
            dbms_lob.OPEN(vr_clob, dbms_lob.lob_readwrite);
            
            -- Inicializar o BLOB
            dbms_lob.createtemporary(vr_blob, TRUE);
            dbms_lob.OPEN(vr_blob, dbms_lob.lob_readwrite);

            --Escrever texto no Clob
            gene0002.pc_escreve_xml(vr_clob,vr_conteudo,'',TRUE);
            vr_blob:= fn_base64DecodeClobAsBlob(vr_clob);

            --Fechar Clob e Liberar Memoria	
            dbms_lob.close(vr_clob);
            dbms_lob.freetemporary(vr_clob); 
            
            BEGIN 
              gene0002.pc_blob_para_arquivo(pr_blob     => vr_blob   
                                           ,pr_caminho  => vr_nmdireto || '/rl' 
                                           ,pr_arquivo  => vr_nmarquiv
                                           ,pr_des_erro => vr_dscritic);
                                           
              -- Se retornou erro, incrementar a mensagem e retornoar
              IF vr_dscritic IS NOT NULL THEN
              
                --Fechar Blob e Liberar Memoria	                
                dbms_lob.freetemporary(vr_blob); 
                
                --Gera exceção
                RAISE vr_exc_saida;
                
              END IF;
              
            END;

            --Fechar Blob e Liberar Memoria	
            dbms_lob.freetemporary(vr_blob); 
           
            --Efetuar Copia do PDF
            gene0002.pc_efetua_copia_pdf (pr_cdcooper => vr_cdcooper     --> Cooperativa conectada
                                         ,pr_cdagenci => vr_cdagenci     --> Codigo da agencia para erros
                                         ,pr_nrdcaixa => vr_nrdcaixa     --> Codigo do caixa para erros
                                         ,pr_nmarqpdf => vr_nmarquiv     --> Arquivo PDF  a ser gerado                                 
                                         ,pr_des_reto => vr_des_reto     --> Saída com erro
                                         ,pr_tab_erro => vr_tab_erro);   --> tabela de erros 
            --Se ocorreu erro
            IF vr_des_reto = 'NOK' THEN
              
              pr_des_reto:= vr_des_reto;
              
              --Se possui erro
              IF vr_tab_erro.COUNT > 0 THEN
                pr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                pr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              END IF;
              
              --Levantar Excecao  
              RAISE vr_exc_saida;
            END IF; 
          
            --Eliminar arquivo impressao
            IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmarquiv) THEN 
                                                      
              --Excluir arquivo de impressao
               vr_comando:= 'rm '||vr_nmarquiv||' 2>/dev/null';

              --Executar o comando no unix
              gene0001.pc_OScommand (pr_typ_comando => 'S'
                                    ,pr_des_comando => vr_comando
                                    ,pr_typ_saida   => vr_typ_saida
                                    ,pr_des_saida   => vr_dscritic);
                                  
              --Se ocorreu erro dar RAISE
              IF vr_typ_saida = 'ERR' THEN
                vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
                            
                -- retornando ao programa chamador
                RAISE vr_exc_saida;
              END IF;
          
              --Nome Arquivo pdf
              vr_nmarqpdf:= substr(vr_nmarquiv,instr(vr_nmarquiv,'/',-1)+1);
              
            END IF;          
          
          END IF; --pr_idorigem = 5 
        
        END IF;
        
        --Retornar nome arquivo impressao e pdf
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        
        -- Insere as tags dos campos da PLTABLE de aplicações
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarqpdf, pr_des_erro => vr_dscritic);
        
        --Retorno
        vr_retornvl:= 'OK';   
                                            
      EXCEPTION
        WHEN vr_exc_saida THEN 
          vr_retornvl:= 'NOK';
      END;  
      
      --Eliminar arquivos requisicao
      inss0001.pc_elimina_arquivos_requis (pr_cdcooper => vr_cdcooper      --Codigo Cooperativa
                                          ,pr_cdprogra => vr_nmdatela      --Nome do Programa
                                          ,pr_msgenvio => vr_msgenvio      --Mensagem Envio
                                          ,pr_msgreceb => vr_msgreceb      --Mensagem Recebimento
                                          ,pr_movarqto => vr_movarqto      --Nome Arquivo mover
                                          ,pr_nmarqlog => vr_nmarqlog      --Nome Arquivo LOG
                                          ,pr_des_reto => vr_des_reto      --Retorno OK/NOK 
                                          ,pr_dscritic => vr_dscritic2);    --Descricao Erro
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        
        --Monta mensagem de erro
        vr_dscritic:= vr_dscritic2;
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF;   
      
		  --Incluir nome do módulo logado - Chamado 664301
      --Seta novamente esta rotina porque foi alterado dentro da pc_elimina_arquivos_requis
			GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_solic_rel_hist_cadastral');

      IF vr_retornvl = 'NOK' THEN
        
        --Se nao tem a descricao do erro
        IF vr_cdcritic = 0 AND 
           vr_dscritic IS NULL THEN
          vr_dscritic:= 'Nao foi possivel gerar o relatorio de historico cadastral.';
        END IF;   
        
        -- Gravar Linha Log
        inss0001.pc_retorna_linha_log(pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                     ,pr_cdprogra => vr_nmdatela   --Nome do Programa
                                     ,pr_dtmvtolt => vr_dtmvtolt   --Data Movimento
                                     ,pr_nrdconta => 0             --Numero da Conta
                                     ,pr_nrcpfcgc => 0             --Numero Cpf
                                     ,pr_nrrecben => pr_nrrecben   --Numero Recebimento Beneficio
                                     ,pr_nmmetodo => 'Relatorio Historico Cadastral' --Nome do metodo
                                     ,pr_cdderror => vr_cdcritic   --Codigo Erro
                                     ,pr_dsderror => vr_dscritic   --Descricao Erro
                                     ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo LOG
                                     ,pr_cdtipofalha => 1          --Tipo 4 gera alerta
                                     ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                     ,pr_dscritic => vr_dscritic2); --Descricao erro 
                                     
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          vr_dscritic:= vr_dscritic2;          
        END IF;
        
        --Levantar Excecao
        RAISE vr_exc_erro; 
      
      END IF;  
      
      --Retorno OK
      pr_des_reto:= vr_retornvl;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        
        -- Retorno não OK          
        pr_des_reto:= vr_retornvl;
        
        --Mensagem de critica
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>'); 
                 
      WHEN OTHERS THEN
        
        -- Retorno não OK
        pr_des_reto:= 'NOK';
        
        --Monta mensagem de erro
        pr_cdcritic := 0;          
        pr_dscritic := 'Erro na inss0001.pc_solic_rel_hist_cadastral --> '|| SQLERRM;
                          
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
                                         
  END pc_solic_rel_hist_cadastral;					   

  --Buscar Beneficiarios do INSS
  PROCEDURE pc_busca_crapdbi (pr_nrcpfcgc IN crapttl.nrcpfcgc%type      --Numero CPF ou CGC
                             ,pr_nrregist IN INTEGER                    --Numero Registros
                             ,pr_nriniseq IN INTEGER                    --Numero Sequencia Inicial
                             ,pr_xmllog   IN VARCHAR2                   --XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER               --Código da crítica
                             ,pr_dscritic OUT VARCHAR2                  --Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType         --Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                  --Nome do Campo
                             ,pr_des_erro OUT VARCHAR2) IS              --Saida OK/NOK
                             
  /*---------------------------------------------------------------------------------------------------------------
  
  Programa : pc_busca_crapdbi             Antigo: procedures/b1wgen0091.p/busca_crapdbi
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Alisson C. Berrido - Amcom
  Data     : Fevereiro/2015                           Ultima atualizacao: 31/03/2015
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo   : Procedure para Buscar Beneficiarios do INSS  
  
  Alterações : 19/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
            
               31/03/2015 - Ajuste na organização e identação da escrita (Adriano).
  -------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados dos Beneficiarios
    CURSOR cr_crapdbi (pr_nrcpfcgc IN crapdbi.nrcpfcgc%type) IS
    SELECT dbi.nrrecben
          ,dbi.nrcpfcgc
          ,dbi.dtmvtolt
      FROM crapdbi dbi
     WHERE dbi.nrcpfcgc = pr_nrcpfcgc;

    --Tabela de Memoria
    vr_tab_benefic inss0001.typ_tab_benefic; --Tabela de beneficios
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Arquivo Dados
    vr_qtregist INTEGER;
         
    --Variaveis Locais
    vr_nrregist INTEGER;
    vr_auxconta PLS_INTEGER:= 0;
    
    --Variaveis de Indices
    vr_index_crapdbi VARCHAR2(50);
    
    --Variaveis de Erro
    vr_dscritic VARCHAR2(4000);
    
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    
    BEGIN
      --Limpar tabelas auxiliares
      vr_tab_benefic.DELETE;
      
      --Inicializar Variavel
      vr_nrregist:= pr_nrregist;
      vr_dscritic:= NULL;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_busca_crapdbi'); 
    

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      
      --Selecionar beneficiarios
      FOR rw_crapdbi IN cr_crapdbi (pr_nrcpfcgc => pr_nrcpfcgc) LOOP
        
        --Incrementar contador
        vr_qtregist:= nvl(vr_qtregist,0) + 1;
        
        /* controles da paginacao */
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
          CONTINUE;
        END IF; 
        
        IF vr_nrregist > 0 THEN 
          
          --Montar Indice para a temp-table
          vr_index_crapdbi:= lpad(rw_crapdbi.nrcpfcgc,25,'0')||
                             lpad(rw_crapdbi.nrrecben,25,'0');
                             
          --Verificar se já existe na temp-table                             
          IF NOT vr_tab_benefic.EXISTS(vr_index_crapdbi) THEN
            
            --Popular dados na tabela memoria
            vr_tab_benefic(vr_index_crapdbi).nrcpfcgc:= rw_crapdbi.nrcpfcgc;
            vr_tab_benefic(vr_index_crapdbi).nrrecben:= rw_crapdbi.nrrecben;
            
            -- Insere as tags dos campos da PLTABLE de aplicações
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => TO_CHAR(vr_tab_benefic(vr_index_crapdbi).nrcpfcgc), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrrecben', pr_tag_cont => TO_CHAR(vr_tab_benefic(vr_index_crapdbi).nrrecben), pr_des_erro => vr_dscritic);

            --Incrementar contador
            vr_qtregist:= nvl(vr_qtregist,0) + 1;
            
          END IF;  
        END IF;
        
        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;  
        
      END LOOP;

      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Dados'             --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_qtregist         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;  
      
      --Retorno OK
      pr_des_erro:= 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Se nao tem a descricao do erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina inss0001.pc_busca_crapdbi. '||vr_dscritic;
        
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina inss0001.pc_busca_crapdbi. '|| SQLERRM;
          
  END pc_busca_crapdbi;
    
  --Buscar Codigo Identificador Orgao Pagador junto ao INSS
  PROCEDURE pc_busca_cdorgins (pr_dtmvtolt IN VARCHAR2                   --Data do Movimento
                              ,pr_nrdconta IN INTEGER                    --Numero da Conta
                              ,pr_xmllog   IN VARCHAR2                   --XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER               --Código da crítica
                              ,pr_dscritic OUT VARCHAR2                  --Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType         --Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                  --Nome do campo com erro                      
                              ,pr_des_erro OUT VARCHAR2) IS              --Identificar de Erro OK/NOK
                              
  /*---------------------------------------------------------------------------------------------------------------
  
  Programa : pc_busca_cdorgins             Antigo: procedures/b1wgen0091.p/busca_cdorgins
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Alisson C. Berrido - Amcom
  Data     : Fevereiro/2015                           Ultima atualizacao: 26/03/2015
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo   : Procedure para Buscar Codigo Identificador do Orgao Pagador junto ao INSS  
  
  Alterações : 19/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
            
               26/03/2015 - Ajuste na organização e identação da escrita (Adriano).
            
  -------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Selecionar dados da agencia
    CURSOR cr_crapage (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
      SELECT  crapage.cdcooper
             ,crapage.cdorgins
             ,crapage.cdagenci
        FROM crapage
        WHERE crapage.cdcooper = pr_cdcooper
        AND   crapage.cdagenci = pr_cdagenci;
    rw_crapage    cr_crapage%ROWTYPE;

    -- Busca dos dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.nrdconta
          ,crapass.nmprimtl
          ,crapass.vllimcre
          ,crapass.nrcpfcgc
          ,crapass.inpessoa
          ,crapass.cdcooper
          ,crapass.cdagenci
     FROM crapass crapass
    WHERE crapass.cdcooper = pr_cdcooper
      AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
     
    --Variaveis Locais
    vr_auxconta PLS_INTEGER:= 0;
    
    --Variaveis de Erro
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    
    BEGIN
      
      --Inicializar Variavel
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_busca_cdorgins');     
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => vr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Campo com critica
        pr_nmdcampo:= 'nrdconta';        
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
        
      -- Verifica se o associado existe
      OPEN cr_crapass (pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
                      
      FETCH cr_crapass INTO rw_crapass;
      
      -- Se nao encontrar
      IF cr_crapass%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        
        -- Montar mensagem de critica
        vr_cdcritic := 9;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Campo com critica
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
        
        --Selecionar Agencia
        OPEN cr_crapage(pr_cdcooper => rw_crapass.cdcooper
                       ,pr_cdagenci => rw_crapass.cdagenci);
                       
        FETCH cr_crapage INTO rw_crapage;
        
        --Se encontrou
        IF cr_crapage%FOUND THEN
         
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

          -- Insere as tags dos campos da PLTABLE de aplicações
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdorgins', pr_tag_cont => rw_crapage.cdorgins, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdagepac', pr_tag_cont => rw_crapage.cdagenci, pr_des_erro => vr_dscritic);
	
        END IF;  
        --Fechar Cursor
        CLOSE cr_crapage;
      END IF;

      --Retorno OK
      pr_des_erro:= 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Se nao tem a descricao do erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= 'Erro na rotina inss0001.pc_busca_cdorgins. '||vr_dscritic;
        
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                 '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina inss0001.pc_busca_cdorgins. '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_busca_cdorgins;

  --Buscar Informações dos titulares
  PROCEDURE pc_busca_crapttl (pr_nrdconta IN crapass.nrdconta%type      --Numero da Conta
                             ,pr_nrregist IN INTEGER                    --Numero Registros
                             ,pr_nriniseq IN INTEGER                    --Numero Sequencia Inicial
                             ,pr_xmllog   IN VARCHAR2                   --XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER               --Código da crítica
                             ,pr_dscritic OUT VARCHAR2                  --Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType         --Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                  --Nome do Campo
                             ,pr_des_erro OUT VARCHAR2) IS              --Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------
  
  Programa : pc_busca_crapttl             Antigo: procedures/b1wgen0091.p/busca_crapttl
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Alisson C. Berrido - Amcom
  Data     : Fevereiro/2015                           Ultima atualizacao: 29/05/2015
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo   : Procedure para Buscar Informacoes dos Titulares  
  
  Alterações : 19/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
            
               26/03/2015 - Ajuste na organização e identação da escrita (Adriano).
               
               29/05/2015 - Ajustes realizados:
                            - Tratar quando o segundo titular não tiver um endereço residencial 
                              cadastradado então, será utilizado o do primeiro titular 
                              independente da relação (Pai, mãe, amigo, etc..) entre ambos;
                            - Quando o telefone do titular tiver mais do que 9 digitos este, 
                              não será pego pois o SICREDI não permiti números superiores;
                            (Adriano).
              
  -------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Selecionar dados da agencia
    CURSOR cr_crapage (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
    SELECT age.cdcooper
          ,age.cdorgins
          ,age.cdagenci
         ,age.nmresage
     FROM crapage age
    WHERE age.cdcooper = pr_cdcooper
      AND age.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;

    -- Busca dos dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.nrdconta
          ,ass.nmprimtl
          ,ass.vllimcre
          ,ass.nrcpfcgc
          ,ass.inpessoa
          ,ass.cdcooper
          ,ass.cdagenci
     FROM crapass ass
    WHERE ass.cdcooper = pr_cdcooper
      AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Busca dos dados dos Titulares
    CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                      ,pr_nrdconta IN crapttl.nrdconta%type) IS
    SELECT ttl.cdcooper
          ,ttl.nrdconta
          ,ttl.idseqttl
          ,ttl.nmmaettl
          ,ttl.nmextttl
          ,ttl.nrcpfcgc
          ,ttl.cdufdttl
          ,ttl.cdsexotl
          ,ttl.dtnasttl
      FROM crapttl ttl
     WHERE ttl.cdcooper = pr_cdcooper 
       AND ttl.nrdconta = pr_nrdconta; 
    rw_crapttl cr_crapttl%ROWTYPE;
     
    --Selecionar Telefones
    CURSOR cr_craptfc (pr_cdcooper IN crapttl.cdcooper%type 
                      ,pr_nrdconta IN crapttl.nrdconta%type
                      ,pr_idseqttl IN crapttl.idseqttl%type
                      ,pr_tptelefo IN craptfc.tptelefo%type) IS
   SELECT /*+ INDEX_ASC(craptfc CRAPTFC##CRAPTFC1) */
           craptfc.nrdddtfc
          ,craptfc.nrtelefo                
      FROM craptfc craptfc
     WHERE craptfc.cdcooper = pr_cdcooper 
       AND craptfc.nrdconta = pr_nrdconta 
       AND craptfc.idseqttl = pr_idseqttl 
       AND craptfc.tptelefo = pr_tptelefo;
    rw_craptfc cr_craptfc%ROWTYPE;        

    --Selecionar Enderecos
    CURSOR cr_crapenc (pr_cdcooper IN crapttl.cdcooper%type 
                      ,pr_nrdconta IN crapttl.nrdconta%type
                      ,pr_idseqttl IN crapttl.idseqttl%type
                      ,pr_tpendass IN crapenc.tpendass%type) IS
   SELECT /*+ INDEX_DESC(crapenc CRAPENC##CRAPENC2) */
          crapenc.nmbairro
         ,crapenc.nmcidade
         ,crapenc.nrcepend
         ,crapenc.cdufende
         ,crapenc.dsendere
         ,crapenc.nrendere                
     FROM crapenc crapenc
    WHERE crapenc.cdcooper = pr_cdcooper 
      AND crapenc.nrdconta = pr_nrdconta 
      AND crapenc.idseqttl = pr_idseqttl 
      AND crapenc.tpendass = pr_tpendass;
    rw_crapenc cr_crapenc%ROWTYPE;        

    --Tabela de Titulares
    vr_tab_titulares inss0001.typ_tab_titulares;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Arquivo Dados
    vr_qtregist INTEGER;
    
    --Variaveis Locais
    vr_nrregist INTEGER;
    vr_index    PLS_INTEGER;
    vr_auxconta PLS_INTEGER:= 0;
    vr_crapenc  BOOLEAN:= FALSE;
    
    --Variaveis de Erro
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    
    BEGIN
      --Limpar tabelas auxiliares
      vr_tab_titulares.DELETE;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
      
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_busca_crapttl');      
      
      --Inicializar Variavel
      vr_nrregist:= pr_nrregist;
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => vr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Campo com critica
        pr_nmdcampo:= 'nrdconta';        
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
        
      -- Verifica se o associado existe
      OPEN cr_crapass (pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
                      
      FETCH cr_crapass INTO rw_crapass;
      
      -- Se nao encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        
        -- Montar mensagem de critica
        vr_cdcritic := 9;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Campo com critica
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;

      --Selecionar Agencia
      OPEN cr_crapage(pr_cdcooper => rw_crapass.cdcooper
                     ,pr_cdagenci => rw_crapass.cdagenci);
                     
      FETCH cr_crapage INTO rw_crapage;
      
      --Se nao encontrou
      IF cr_crapage%NOTFOUND THEN
        -- Montar mensagem de critica
        vr_cdcritic := 962;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Campo com critica
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        --Fechar Cursor
        CLOSE cr_crapage;
      END IF;  
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      
      --Selecionar Titular
      FOR rw_crapttl IN cr_crapttl(pr_cdcooper => rw_crapass.cdcooper
                                  ,pr_nrdconta => rw_crapass.nrdconta) LOOP
                                  
        --Indice para a temp-table
        vr_index:= rw_crapttl.idseqttl;
                                  
        --Incrementar Quantidade Registros do Parametro
        vr_qtregist:= nvl(vr_qtregist,0) + 1;
        
        /* controles da paginacao */
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
           --Proximo Titular
          CONTINUE;
        END IF; 
        
        --Numero Registros
        IF vr_nrregist > 0 THEN 
                             
          --Verificar se já existe na temp-table                             
          IF NOT vr_tab_titulares.EXISTS(vr_index) THEN
            
            --Popular dados na tabela memoria
            vr_tab_titulares(vr_index).cdcooper:= rw_crapcop.cdcooper;
            vr_tab_titulares(vr_index).nrdconta:= rw_crapttl.nrdconta;
            vr_tab_titulares(vr_index).nrcpfcgc:= rw_crapttl.nrcpfcgc;
            vr_tab_titulares(vr_index).idseqttl:= rw_crapttl.idseqttl;
            vr_tab_titulares(vr_index).cdorgins:= rw_crapage.cdorgins;
            vr_tab_titulares(vr_index).cdagepac:= rw_crapage.cdagenci;
            vr_tab_titulares(vr_index).nmresage:= rw_crapage.nmresage;
            vr_tab_titulares(vr_index).cdagesic:= rw_crapcop.cdagesic;
            vr_tab_titulares(vr_index).cdufdttl:= rw_crapttl.cdufdttl;
            vr_tab_titulares(vr_index).nmmaettl:= rw_crapttl.nmmaettl;
            vr_tab_titulares(vr_index).nmextttl:= rw_crapttl.nmextttl;
            vr_tab_titulares(vr_index).cdsexotl:= rw_crapttl.cdsexotl;
            vr_tab_titulares(vr_index).dtnasttl:= rw_crapttl.dtnasttl;

            --Limpar registro
            rw_craptfc:= NULL;
            
            --Selecionar Telefone
            OPEN cr_craptfc (pr_cdcooper => rw_crapttl.cdcooper 
                            ,pr_nrdconta => rw_crapttl.nrdconta
                            ,pr_idseqttl => rw_crapttl.idseqttl
                            ,pr_tptelefo => 1);
                            
            FETCH cr_craptfc INTO rw_craptfc;
            
            --Se Encontrou
            IF cr_craptfc%FOUND                 AND
               LENGTH(rw_craptfc.nrtelefo) < 10 THEN
               
                vr_tab_titulares(vr_index).nrdddtfc:= rw_craptfc.nrdddtfc;
                vr_tab_titulares(vr_index).nrtelefo:= rw_craptfc.nrtelefo;

            END IF;
            
            --Fechar Cursor
            CLOSE cr_craptfc;                
            
            --Limpar registro
            rw_crapenc:= NULL;      
            
            /*Decorrente ao SICREDI exigir um endereço no envio dos request's, se na consulta
             do segundo titular, este, não tiver um endereço residencial cadastrado então,
             será utilizado o endereço do primeiro titrular independetende da relação 
             (Pai, Mae, amigo, etc..) entre ambos.             */                  
            --Selecionar Endereco
            OPEN cr_crapenc (pr_cdcooper => rw_crapttl.cdcooper 
                            ,pr_nrdconta => rw_crapttl.nrdconta
                            ,pr_idseqttl => rw_crapttl.idseqttl
                            ,pr_tpendass => 10); /*Residencial*/
                            
            FETCH cr_crapenc INTO rw_crapenc;
            
            vr_crapenc := cr_crapenc%FOUND;
            
            --Fechar Cursor
            CLOSE cr_crapenc; 
              
            --Se Encontrou
            IF vr_crapenc THEN
            
              vr_tab_titulares(vr_index).nmbairro:= rw_crapenc.nmbairro;
              vr_tab_titulares(vr_index).nmcidade:= rw_crapenc.nmcidade;
              vr_tab_titulares(vr_index).nrcepend:= rw_crapenc.nrcepend;
              vr_tab_titulares(vr_index).dsendres:= rw_crapenc.dsendere;
              vr_tab_titulares(vr_index).nrendere:= rw_crapenc.nrendere;
              vr_tab_titulares(vr_index).cdufdttl:= rw_crapenc.cdufende;
              
            ELSE                         
              --Selecionar Endereco
              OPEN cr_crapenc (pr_cdcooper => rw_crapttl.cdcooper 
                              ,pr_nrdconta => rw_crapttl.nrdconta
                              ,pr_idseqttl => 1 --primeiro titular
                              ,pr_tpendass => 10); /*Residencial*/
                              
              FETCH cr_crapenc INTO rw_crapenc;
              
              vr_crapenc := cr_crapenc%FOUND;
            
              --Fechar Cursor
              CLOSE cr_crapenc;
              
              --Se Encontrou
              IF vr_crapenc THEN
                
                vr_tab_titulares(vr_index).nmbairro:= rw_crapenc.nmbairro;
                vr_tab_titulares(vr_index).nmcidade:= rw_crapenc.nmcidade;
                vr_tab_titulares(vr_index).nrcepend:= rw_crapenc.nrcepend;
                vr_tab_titulares(vr_index).dsendres:= rw_crapenc.dsendere;
                vr_tab_titulares(vr_index).nrendere:= rw_crapenc.nrendere;
                vr_tab_titulares(vr_index).cdufdttl:= rw_crapenc.cdufende;
                
              END IF;
              
            END IF;  
            
            -- Insere as tags dos campos da PLTABLE de aplicações
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdcooper', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).cdcooper), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdconta', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).nrdconta), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).nrcpfcgc), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'idseqttl', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).idseqttl), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdorgins', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).cdorgins), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdagepac', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).cdagepac), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmresage', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).nmresage), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdagesic', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).cdagesic), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdufdttl', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).cdufdttl), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmmaettl', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).nmmaettl), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmextttl', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).nmextttl), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdsexotl', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).cdsexotl), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtnasttl', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).dtnasttl, 'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdddtfc', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).nrdddtfc), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrtelefo', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).nrtelefo), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmbairro', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).nmbairro), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmcidade', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).nmcidade), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrcepend', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).nrcepend), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsendres', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).dsendres), pr_des_erro => vr_dscritic);
    				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrendere', pr_tag_cont => TO_CHAR(vr_tab_titulares(vr_index).nrendere), pr_des_erro => vr_dscritic);

          END IF;  
        END IF;
        -- Incrementa contador p/ posicao no XML
        vr_auxconta := vr_auxconta + 1;
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;  
      END LOOP;  

      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Dados'             --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_qtregist         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;                           
        
      --Se nao encontrar titulares
      IF vr_tab_titulares.COUNT = 0 THEN
        --Mensagem de erro
        vr_dscritic:= 'Nenhum titular encontrado. ';
        
        --Campo Erro
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
        
      --Retorno OK
      pr_des_erro:= 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Se nao tem a descricao do erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina inss0001.pc_busca_crapttl. '|| SQLERRM;
        
  END pc_busca_crapttl;

  --Gerar termo de troca de domicilio 
  PROCEDURE pc_gera_termo_troca_domic (pr_cdcooper IN crapcop.cdcooper%type   --Cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                      ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                      ,pr_cdoperad IN VARCHAR2                --Operador
                                      ,pr_nmdatela IN VARCHAR2                --Nome da tela
                                      ,pr_idorigem IN INTEGER                 --Origem Processamento
                                      ,pr_nrdconta IN crapass.nrdconta%type   --Numero da Conta
                                      ,pr_nrcpfcgc IN crapttl.nrcpfcgc%type   --Numero CPF/CGC
                                      ,pr_idseqttl IN crapttl.idseqttl%type   --Sequencial do Titular
                                      ,pr_cdagesic IN crapage.cdagenci%type   --Codigo Agencia Sicredi
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%type   --Data Movimento
                                      ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficiario
                                      ,pr_cdorgins IN crapage.cdorgins%type   --Numero Orgao pagamento para INSS
                                      ,pr_nmrecben IN VARCHAR2                --Nome Beneficiario
                                      ,pr_dsiduser IN VARCHAR2                --Descricao Identificador Usuario
                                      ,pr_nmarqimp OUT VARCHAR2               --Nome Arquivo Impressao
                                      ,pr_nmarqpdf OUT VARCHAR2               --Nome do Arquivo pdf
                                      ,pr_des_reto OUT VARCHAR2               --Saida OK/NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --Tabela Erros
  /*---------------------------------------------------------------------------------------------------------------
  
  Programa : pc_gera_termo_troca_domic             Antigo: procedures/b1wgen0091.p/gera_termo_troca_domicilio
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Alisson C. Berrido - Amcom
  Data     : Fevereiro/2015                           Ultima atualizacao: 29/05/2015
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo   : Procedure para Gerar termo de troca de domicilio
  
  Alterações : 19/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
               
               26/03/2015 - Ajuste na organização e identação da escrita (Adriano).
            
               29/05/2015 - Ajuste para epenas utilizar a rotina de copia de pdf
                           (Adriano).
  -------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Selecionar dados da agencia
    CURSOR cr_crapage (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
      SELECT  age.cdcooper
             ,age.cdorgins
             ,age.cdagenci
             ,age.nmresage
             ,age.nmcidade
        FROM crapage age
        WHERE age.cdcooper = pr_cdcooper
        AND   age.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;

    -- Busca dos dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.nrdconta
          ,ass.nmprimtl
          ,ass.vllimcre
          ,ass.nrcpfcgc
          ,ass.inpessoa
          ,ass.cdcooper
          ,ass.cdagenci
     FROM crapass ass
    WHERE ass.cdcooper = pr_cdcooper
      AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Busca dos dados dos operadores
    CURSOR cr_crapope (pr_cdcooper IN crapope.cdcooper%type
                      ,pr_cdoperad IN crapope.cdoperad%type) IS
    SELECT ope.nmoperad
      FROM crapope ope
     WHERE ope.cdcooper = pr_cdcooper 
     AND   trim(upper(ope.cdoperad)) = trim(upper(pr_cdoperad)); 
    rw_crapope cr_crapope%ROWTYPE;
     
    --Variaveis do Clob
    vr_clobxml CLOB;
    vr_dstexto VARCHAR2(32767);
    
    --Variaveis Locais
    vr_nmarqimp VARCHAR2(1000);
    vr_nmarquiv VARCHAR2(1000);
    vr_comando  VARCHAR2(1000);
    vr_typ_saida VARCHAR2(3);    
    vr_nmdireto VARCHAR2(1000);
    vr_nmcidade VARCHAR2(1000);
    vr_rel_dsrefere VARCHAR2(1000);
       
    --Variaveis de Erro
    vr_cdcritic INTEGER;
    vr_des_reto VARCHAR2(3);
    vr_dscritic VARCHAR2(4000);
    
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
     
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_gera_termo_troca_domic');      
      
      --Limpar tabelas auxiliares
      pr_tab_erro.DELETE;
      
      --Inicializar Variavel
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      
      -- Verifica se o associado existe
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
                      
      FETCH cr_crapass INTO rw_crapass;
      
      -- Se nao encontrar
      IF cr_crapass%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        
        -- Montar mensagem de critica
        vr_cdcritic := 9;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;

      --Selecionar Operador
      OPEN cr_crapope(pr_cdcooper => pr_cdcooper
                     ,pr_cdoperad => pr_cdoperad);
                     
      FETCH cr_crapope INTO rw_crapope;
      
      --Se nao encontrou
      IF cr_crapope%NOTFOUND THEN
        
        -- Montar mensagem de critica
        vr_cdcritic := 67;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        --Fechar Cursor
        CLOSE cr_crapope;
      END IF;  
      
      --Selecionar Agencia
      OPEN cr_crapage(pr_cdcooper => rw_crapass.cdcooper
                     ,pr_cdagenci => rw_crapass.cdagenci);
                     
      FETCH cr_crapage INTO rw_crapage;
      
      --Se nao encontrou
      IF cr_crapage%NOTFOUND THEN
        
        -- Montar mensagem de critica
        vr_cdcritic := 962;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        --Fechar Cursor
        CLOSE cr_crapage;
      END IF;  
      
      --Nome Diretorio
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'rl');
                                          
      --Nome Arquivo
      vr_nmarquiv:= vr_nmdireto||'/'||pr_dsiduser;
                                                                      
      --Nome Cidade
      vr_nmcidade:= TRIM(Initcap(rw_crapage.nmcidade));

      --Descricao da referencia
      vr_rel_dsrefere:= vr_nmcidade ||', '||to_char(pr_dtmvtolt,'DD')||
                        ' de '||LOWER(TRIM(gene0001.vr_vet_nmmesano(to_number(to_char(pr_dtmvtolt,'MM')))))||
                        ' de '||to_char(pr_dtmvtolt,'YYYY')||'.';
       
      --Se arquivo existir no diretorio
      IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmarquiv) THEN
        
        --Remover arquivo
        vr_comando:= 'rm '||vr_nmarquiv||'* 2>/dev/null';
        
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
                          
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
          -- retornando ao programa chamador
          RAISE vr_exc_erro;
        END IF;
      END IF;  
           
      --Concatenar hora no nome do arquivo
      vr_nmarquiv:= vr_nmarquiv||lpad(gene0002.fn_busca_time,5,'0');
      
      --Nome Arquivo impressao
      vr_nmarqimp:= vr_nmarquiv||'.pdf';
      
      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

      --Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
        '<?xml version="1.0" encoding="UTF-8"?><raiz>');

      --Texto do Termo
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
        '<nmrecben>'|| substr(pr_nmrecben,1,28)  ||'</nmrecben>'||
        '<nrrecben>'|| to_char(pr_nrrecben,'99999999990')  ||'</nrrecben>'||
        '<cdorgins>'|| pr_cdorgins  ||'</cdorgins>'||
        '<nrdconta>'|| gene0002.fn_mask_conta(pr_nrdconta)  ||'</nrdconta>'||
        '<nmextcop>'|| rw_crapcop.nmextcop  ||'</nmextcop>'||
        '<nmrescop>'|| rw_crapcop.nmrescop  ||'</nmrescop>'||
        '<cdagesic>'|| to_char(pr_cdagesic,'99g990')  ||'</cdagesic>'||
        '<dsrefere>'|| substr(vr_rel_dsrefere,1,60)  ||'</dsrefere>'||
        '<nmoperad>'|| substr(trim(rw_crapope.nmoperad),1,40)  ||'</nmoperad>');

      --Finaliza TAG Relatorio
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</raiz>',TRUE); 

      -- Gera relatório
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
                                 ,pr_cdprogra  => pr_nmdatela                   --> Programa chamador
                                 ,pr_dtmvtolt  => pr_dtmvtolt                   --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                    --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz'                       --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'termo_troca_domicilio.jasper' --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                          --> Sem parâmetros                                         
                                 ,pr_dsarqsaid => vr_nmarqimp                   --> Arquivo final com o path
                                 ,pr_qtcoluna  => 80                            --> Colunas do relatorio
                                 ,pr_flg_gerar => 'S'                           --> Geraçao na hora
                                 ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => NULL                          --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                             --> Número de cópias
                                 ,pr_cdrelato  => 695                           --> Codigo do Relatorio
                                 ,pr_des_erro  => vr_dscritic);                 --> Saída com erro
                                 
      --Se ocorreu erro no relatorio
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF; 
            
      --Fechar Clob e Liberar Memoria  
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);               

      IF pr_idorigem = 5 THEN  /** Ayllos Web **/
        
        --O ireport já irá gerar o relatório em formato pdf e por isso, iremos apenas
        --envia-lo ao servidor web.           
        gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_nmarqpdf => vr_nmarqimp
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => pr_tab_erro);

        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          
          --Se tem erro na tabela 
          IF pr_tab_erro.COUNT > 0 THEN
            --Mensagem Erro
            vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
          ELSE
            vr_dscritic:= 'Erro ao enviar arquivo para web.';  
          END IF; 
          
          --Sair 
          RAISE vr_exc_erro;
          
        END IF; 
        
        --Nome do arquivo pdf
        pr_nmarqpdf:= SUBSTR(vr_nmarqimp,INSTR(vr_nmarqimp,'/',-1)+1);
                                    
      END IF;
      
      --Nome arquivo impressao
      pr_nmarqimp:= vr_nmarqimp;
      
      --Retorno OK
      pr_des_reto:= 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        
        -- Retorno não OK
        pr_des_reto:= 'NOK';
        
        IF vr_cdcritic = 0     AND
           vr_dscritic IS NULL THEN
           
          -- Monta mensagem erro
          vr_dscritic:= 'Erro na rotina inss0001.pc_gera_termo_troca_domic.';
        
        END IF;
        
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                             
      WHEN OTHERS THEN
        
        -- Retorno não OK
        pr_des_reto:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        vr_dscritic:= 'Erro na rotina inss0001.pc_gera_termo_troca_domic. '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                             
  END pc_gera_termo_troca_domic; 

  --Gerar termo de troca de conta corrente 
  PROCEDURE pc_gera_termo_troca_conta (pr_cdcooper IN crapcop.cdcooper%type   --Cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                      ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                      ,pr_cdoperad IN VARCHAR2                --Operador
                                      ,pr_nmdatela IN VARCHAR2                --Programa chamador
                                      ,pr_idorigem IN INTEGER                 --Origem Processamento
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%type   --Data Movimento
                                      ,pr_cdcopant IN crapcop.cdcooper%type   --Cooperativa Anterior
                                      ,pr_nrdconta IN crapass.nrdconta%type   --Numero da Conta
                                      ,pr_nrctaant IN crapass.nrdconta%type   --Numero da Conta Anterior
                                      ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficiario
                                      ,pr_nmrecben IN VARCHAR2                --Nome Beneficiario
                                      ,pr_cdorgins IN crapage.cdorgins%type   --Numero Orgao pagamento para INSS
                                      ,pr_dsiduser IN VARCHAR2                --Descricao Identificador Usuario
                                      ,pr_entrecop IN INTEGER                 --Indicador troca entre cooperativas (0=nao, 1=sim)
                                      ,pr_nmarqimp OUT VARCHAR2               --Nome Arquivo Impressao
                                      ,pr_nmarqpdf OUT VARCHAR2               --Nome do Arquivo pdf
                                      ,pr_des_reto OUT VARCHAR2               --Saida OK/NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --Tabela Erros
  /*---------------------------------------------------------------------------------------------------------------
  
  Programa : pc_gera_termo_troca_conta             Antigo: procedures/b1wgen0091.p/gera_termo_troca_conta_corrente
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Alisson C. Berrido - Amcom
  Data     : Fevereiro/2015                           Ultima atualizacao: 30/03/2015
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo   : Procedure para Gerar termo de troca de conta corrente
  
  Alterações : 20/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
  
               30/03/2015 - Ajuste na organização e identação da escrita (Adriano).
            
              
  -------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    rw_crapcop1 cr_crapcop%ROWTYPE;
     
    -- Selecionar dados da agencia
    CURSOR cr_crapage (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
      SELECT  age.cdcooper
             ,age.cdorgins
             ,age.cdagenci
             ,age.nmresage
             ,age.nmcidade
        FROM crapage age
        WHERE age.cdcooper = pr_cdcooper
        AND   age.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;

    -- Busca dos dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.nrdconta
          ,ass.nmprimtl
          ,ass.vllimcre
          ,ass.nrcpfcgc
          ,ass.inpessoa
          ,ass.cdcooper
          ,ass.cdagenci
     FROM crapass ass
    WHERE ass.cdcooper = pr_cdcooper
      AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Busca dos dados dos operadores
    CURSOR cr_crapope (pr_cdcooper IN crapope.cdcooper%type
                      ,pr_cdoperad IN crapope.cdoperad%type) IS
    SELECT ope.nmoperad
      FROM crapope ope
     WHERE ope.cdcooper = pr_cdcooper 
     AND   trim(upper(ope.cdoperad)) = trim(upper(pr_cdoperad)); 
    rw_crapope cr_crapope%ROWTYPE;
     
    --Variaveis do Clob
    vr_clobxml CLOB;
    vr_dstexto VARCHAR2(32767);
    
    --Variaveis Locais
    vr_nmarqimp VARCHAR2(1000);
    vr_nmarquiv VARCHAR2(1000);
    vr_comando  VARCHAR2(1000);
    vr_typ_saida VARCHAR2(3);
    vr_nmdireto VARCHAR2(1000);
    vr_rel_dslocdat VARCHAR2(1000);
       
    --Variaveis de Erro
    vr_cdcritic INTEGER;
    vr_des_reto VARCHAR2(3);
    vr_dscritic VARCHAR2(4000);
    
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
         
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_gera_termo_troca_conta');      
      
      --Limpar tabelas auxiliares
      pr_tab_erro.DELETE;
      
      --Inicializar Variavel
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
        
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      
      -- Verifica se o associado existe
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
                      
      FETCH cr_crapass INTO rw_crapass;
      
      -- Se nao encontrar
      IF cr_crapass%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        
        -- Montar mensagem de critica
        vr_cdcritic := 9;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;

      --Selecionar Agencia
      OPEN cr_crapage(pr_cdcooper => rw_crapass.cdcooper
                     ,pr_cdagenci => rw_crapass.cdagenci);
                     
      FETCH cr_crapage INTO rw_crapage;
      
      --Se nao encontrou
      IF cr_crapage%NOTFOUND THEN
        
        -- Montar mensagem de critica
        vr_cdcritic := 962;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        --Fechar Cursor
        CLOSE cr_crapage;
      END IF;  
      
      --Nome Diretorio
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'rl');
                                          
      --Nome Arquivo
      vr_nmarquiv:= vr_nmdireto||'/'||pr_dsiduser;
      

      --Se arquivo existir no diretorio
      IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmarquiv) THEN
        
        --Remover arquivo
        vr_comando:= 'rm '||vr_nmarquiv||'* 2>/dev/null';
        
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
                          
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
          -- retornando ao programa chamador
          RAISE vr_exc_erro;
        END IF;
      END IF;  

      --Concatenar hora no nome do arquivo
      vr_nmarquiv:= vr_nmarquiv||lpad(gene0002.fn_busca_time,5,'0');
      
      --Nome Arquivo impressao
      vr_nmarqimp:= vr_nmarquiv||'.pdf';
      
      --Selecionar Operador
      OPEN cr_crapope(pr_cdcooper => pr_cdcooper
                     ,pr_cdoperad => pr_cdoperad);
                     
      FETCH cr_crapope INTO rw_crapope;
      
      --Se nao encontrou
      IF cr_crapope%NOTFOUND THEN
        
        -- Montar mensagem de critica
        vr_cdcritic := 67;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        --Fechar Cursor
        CLOSE cr_crapope;
      END IF;  
       
      --Se for troca entre cooperativas
      IF nvl(pr_entrecop,0) = 1 THEN
        
        -- Verifica se a cooperativa esta cadastrada
        OPEN cr_crapcop (pr_cdcooper => pr_cdcopant);
        
        FETCH cr_crapcop INTO rw_crapcop1;
        
        -- Se não encontrar
        IF cr_crapcop%NOTFOUND THEN
          
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapcop;
          
          -- Montar mensagem de critica
          vr_cdcritic := 651;
          
          -- Busca critica
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
          
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_crapcop;
        END IF;
      END IF;                                                                 

      --Descricao da referencia
      vr_rel_dslocdat:= rw_crapage.nmcidade ||', '||to_char(pr_dtmvtolt,'DD/MM/YYYY')||'.';
       
      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

      --Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
        '<?xml version="1.0" encoding="UTF-8"?><raiz>');

      --Texto do Termo
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
        '<nmrecben>'|| substr(pr_nmrecben,1,40)  ||'</nmrecben>'||
        '<nrrecben>'|| to_char(pr_nrrecben,'99999999990')  ||'</nrrecben>'||
        '<cdorgins>'|| to_char(pr_cdorgins,'999990')  ||'</cdorgins>'||
        '<nrdconta>'|| gene0002.fn_mask_conta(pr_nrdconta)  ||'</nrdconta>'||
        '<nrctaant>'|| gene0002.fn_mask_conta(pr_nrctaant)  ||'</nrctaant>'||
        '<nmextcop>'|| rw_crapcop.nmextcop  ||'</nmextcop>'||
        '<nmrescop>'|| rw_crapcop.nmrescop  ||'</nmrescop>'||
        '<nmrescopant>'|| rw_crapcop1.nmrescop  ||'</nmrescopant>'||
        '<dslocdat>'|| substr(vr_rel_dslocdat,1,60)  ||'</dslocdat>'||
        '<nmoperad>'|| substr(trim(rw_crapope.nmoperad),1,40)  ||'</nmoperad>'||
        '<entrecop>'|| pr_entrecop ||'</entrecop>');

      --Finaliza TAG Relatorio
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</raiz>',TRUE); 

      -- Gera relatório
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
                                 ,pr_cdprogra  => pr_nmdatela                   --> Programa chamador
                                 ,pr_dtmvtolt  => pr_dtmvtolt                   --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                    --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz'                       --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'termo_troca_conta.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                          --> Sem parâmetros                                         
                                 ,pr_dsarqsaid => vr_nmarqimp                   --> Arquivo final com o path
                                 ,pr_qtcoluna  => 80                            --> Colunas do relatorio
                                 ,pr_flg_gerar => 'S'                           --> Geraçao na hora
                                 ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => NULL                          --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                             --> Número de cópias
                                 ,pr_cdrelato  => 696                           --> Codigo do Relatorio
                                 ,pr_des_erro  => vr_dscritic);                 --> Saída com erro
                                 
      --Se ocorreu erro no relatorio
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF; 
            
      --Fechar Clob e Liberar Memoria  
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);               

      IF pr_idorigem = 5 THEN  /** Ayllos Web **/
        
        --O ireport já irá gerar o relatório em formato pdf e por isso, iremos apenas
        --envia-lo ao servidor web.           
        gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_nmarqpdf => vr_nmarqimp
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => pr_tab_erro);

        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          
          --Se tem erro na tabela 
          IF pr_tab_erro.COUNT > 0 THEN
            --Mensagem Erro
            vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
          ELSE
            vr_dscritic:= 'Erro ao enviar arquivo para web.';  
          END IF; 
          
          --Sair 
          RAISE vr_exc_erro;
          
        END IF; 
        
        --Nome do arquivo pdf
        pr_nmarqpdf:= SUBSTR(vr_nmarqimp,INSTR(vr_nmarqimp,'/',-1)+1);
                                    
      END IF;
      
      --Nome arquivo impressao
      pr_nmarqimp:= vr_nmarqimp;
            
      --Retorno OK
      pr_des_reto:= 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        
        -- Retorno não OK          
        pr_des_reto:= 'NOK';
        
        IF vr_cdcritic = 0     AND
           vr_dscritic IS NULL THEN
           
          --Monta mensagem de critica
          vr_dscritic:= 'Erro na rotina inss0001.pc_gera_termo_troca_conta.';
          
        END IF;
        
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        vr_dscritic:= 'Erro na rotina inss0001.pc_gera_termo_troca_conta. '|| SQLERRM;
        
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

  END pc_gera_termo_troca_conta; 
       
  --Gerar termo de comprovacao de vida 
  PROCEDURE pc_gera_termo_cpvcao_vida (pr_cdcooper IN crapcop.cdcooper%type   --Cooperativa
                                      ,pr_cdoperad IN VARCHAR2                --Operador
                                      ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%type   --Data Movimento
                                      ,pr_nmdatela IN VARCHAR2                --Programa chamador                                      
                                      ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                      ,pr_idorigem IN INTEGER                 --Origem Processamento
                                      ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficiario
                                      ,pr_nrcpfcgc IN crapttl.nrcpfcgc%type   --Numero Cpf/Cgc
                                      ,pr_nmextttl IN crapttl.nmextttl%type   --Nome Extrato Titular
                                      ,pr_hrtransa IN VARCHAR2                --Hora Transacao
                                      ,pr_respreno IN VARCHAR2                --Tipo
                                      ,pr_nmprocur IN VARCHAR2                --Nome Procurador
                                      ,pr_nrdocpro IN VARCHAR2                --Numero Documento Procurador
                                      ,pr_dtvalprc IN DATE                    --Data Validade Procuracao
                                      ,pr_dsiduser IN VARCHAR2                --Descricao Identificador Usuario
                                      ,pr_nmarqimp OUT VARCHAR2               --Nome Arquivo Impressao
                                      ,pr_nmarqpdf OUT VARCHAR2               --Nome do Arquivo pdf
                                      ,pr_des_reto OUT VARCHAR2               --Saida OK/NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --Tabela Erros
  /*---------------------------------------------------------------------------------------------------------------
  
  Programa : pc_gera_termo_cpvcao_vida             Antigo: procedures/b1wgen0091.p/gera_termo_comprovacao_vida
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Alisson C. Berrido - Amcom
  Data     : Fevereiro/2015                           Ultima atualizacao: 26/03/2015
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo   : Procedure para Gerar termo de comprovacao de vida
  
  Alterações : 20/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
            
               26/03/2015 - Ajuste na organização e identação da escrita (Adriano).
               
  -------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
     
     
    --Variaveis do Clob
    vr_clobxml CLOB;
    vr_dstexto VARCHAR2(32767);
    
    --Variaveis Locais
    vr_nmarqimp VARCHAR2(1000);
    vr_nmarquiv VARCHAR2(1000);
    vr_comando  VARCHAR2(1000);
    vr_typ_saida VARCHAR2(3);
    vr_nmdireto VARCHAR2(1000);
    vr_pxrnvida DATE;
       
    --Variaveis de Erro
    vr_cdcritic INTEGER;
    vr_des_reto VARCHAR2(3);
    vr_dscritic VARCHAR2(4000);
    
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
         
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_gera_termo_cpvcao_vida');      
      
      --Limpar tabelas auxiliares
      pr_tab_erro.DELETE;
      
      --Inicializar Variavel
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
        
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      
      --Nome Diretorio
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'rl');
                                          
      --Nome Arquivo
      vr_nmarquiv:= vr_nmdireto||'/'||pr_dsiduser;
            
      --Proxima Renovacao
      vr_pxrnvida:= add_months(pr_dtmvtolt,12);
      
      --Se arquivo existir no diretorio
      IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmarquiv) THEN
        
        --Remover arquivo
        vr_comando:= 'rm '||vr_nmarquiv||'* 2>/dev/null';
        
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
                          
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
          -- retornando ao programa chamador
          RAISE vr_exc_erro;
        END IF;
      END IF;  

      --Concatenar hora no nome do arquivo
      vr_nmarquiv:= vr_nmarquiv||lpad(gene0002.fn_busca_time,5,'0');
      
      --Nome Arquivo impressao
      vr_nmarqimp:= vr_nmarquiv||'.pdf';

      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

      --Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
        '<?xml version="1.0" encoding="UTF-8"?><raiz>');
 
      --Imprimir 2 vias
      FOR idx IN 1..2 LOOP
        --Texto do Termo
        gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
          '<vias ID="'||idx||'">'||
          '<nmextcop>'|| rw_crapcop.nmextcop  ||'</nmextcop>'||
          '<dtmvtolt>'|| to_char(pr_dtmvtolt,'DD/MM/YYYY') ||'</dtmvtolt>'||
          '<hrtransa>'|| pr_hrtransa ||'</hrtransa>'||
          '<nrrecben>'|| to_char(pr_nrrecben,'99999999990')  ||'</nrrecben>'||
          '<nmextttl>'|| pr_nmextttl ||'</nmextttl>'||
          '<pxrnvida>'|| to_char(vr_pxrnvida,'DD/MM/YYYY') ||'</pxrnvida>'||
          '<nmprocur>'|| pr_nmprocur  ||'</nmprocur>'||
          '<nrdocpro>'|| pr_nrdocpro  ||'</nrdocpro>'||
          '<dtvalprc>'|| to_char(pr_dtvalprc,'DD/MM/YYYY')  ||'</dtvalprc>'||
          '<respreno>'|| CASE pr_respreno WHEN 'BENEFICIARIO' THEN 'S' ELSE 'N' END ||'</respreno>'||
          '<idorigem>'|| pr_idorigem ||'</idorigem>'||
          '</vias>');
      END LOOP;
      
      --Finaliza TAG Relatorio
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</raiz>',TRUE); 

      -- Gera relatório
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
                                 ,pr_cdprogra  => pr_nmdatela                   --> Programa chamador
                                 ,pr_dtmvtolt  => pr_dtmvtolt                   --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                    --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/vias'                  --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'termo_cpvcao_vida.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                          --> Sem parâmetros                                         
                                 ,pr_dsarqsaid => vr_nmarqimp                   --> Arquivo final com o path
                                 ,pr_qtcoluna  => 80                            --> Colunas do relatorio
                                 ,pr_flg_gerar => 'S'                           --> Geraçao na hora
                                 ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '80col'                       --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                             --> Número de cópias
                                 ,pr_cdrelato  => 697                           --> Codigo do Relatorio
                                 ,pr_des_erro  => vr_dscritic);                 --> Saída com erro
                                 
      --Se ocorreu erro no relatorio
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF; 
            
      --Fechar Clob e Liberar Memoria  
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);               

      -- Ayllos Web       
      IF pr_idorigem = 5 THEN  
        
        --O ireport já irá gerar o relatório em formato pdf e por isso, iremos apenas
        --envia-lo ao servidor web.           
        gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_nmarqpdf => vr_nmarqimp
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => pr_tab_erro);

        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          
          --Se tem erro na tabela 
          IF pr_tab_erro.COUNT > 0 THEN
            --Mensagem Erro
            vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
          ELSE
            vr_dscritic:= 'Erro ao enviar arquivo para web.';  
          END IF; 
          
          --Sair 
          RAISE vr_exc_erro;
          
        END IF; 
        
        --Nome do arquivo pdf
        pr_nmarqpdf:= SUBSTR(vr_nmarqimp,INSTR(vr_nmarqimp,'/',-1)+1);
        
      END IF;
      
      --Nome arquivo impressao
      pr_nmarqimp:= vr_nmarqimp;
      
      --Retorno OK
      pr_des_reto:= 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        
        -- Retorno não OK          
        pr_des_reto:= 'NOK';
        
        IF vr_cdcritic = 0     AND
           vr_dscritic IS NULL THEN
        
          --Monta mensagem de erro      
          vr_dscritic:= 'Erro na rotina inss0001.pc_gera_termo_cpvcao_vida.';
          
        END IF;
        
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                             
      WHEN OTHERS THEN
        
        -- Retorno não OK
        pr_des_reto:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        vr_dscritic:= 'Erro na rotina inss0001.pc_gera_termo_cpvcao_vida. '|| SQLERRM;
        
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

  END pc_gera_termo_cpvcao_vida; 
    
  --Gerar Arquivo Demonstrativo 
  PROCEDURE pc_gera_arq_demonstrativo (pr_cdcooper IN crapcop.cdcooper%type   --Cooperativa
                                      ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                      ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                      ,pr_cdoperad IN VARCHAR2                --Operador
                                      ,pr_idorigem IN INTEGER                 --Origem Processamento                                      
                                      ,pr_nmdatela IN VARCHAR2                --Programa chamador                                      
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%type   --Data Movimento
                                      ,pr_cnpjemis IN VARCHAR2                --Cnpj Emissor
                                      ,pr_nomeemis IN VARCHAR2                --Nome Emissor
                                      ,pr_cdorgins IN crapage.cdorgins%type   --Codigo Orgao Pagador
                                      ,pr_nrbenefi IN NUMBER                  --Numero do beneficio
                                      ,pr_nrrecben IN NUMBER                  --Numero do beneficiario
                                      ,pr_dtdcompe IN VARCHAR2                --Data de Competencia
                                      ,pr_nmbenefi IN VARCHAR2                --Nome beneficiario
                                      ,pr_dtprdini IN DATE                    --Periodo Inicial
                                      ,pr_dtprdfin IN DATE                    --Periodo Final
                                      ,pr_vlrbruto IN NUMBER                  --Valor Bruto
                                      ,pr_vlrdscto IN NUMBER                  --Valor Desconto
                                      ,pr_vlrliqui IN NUMBER                  --Valor Liquido
                                      ,pr_dscmensa IN VARCHAR2                --Descricao Mensagem
                                      ,pr_dsiduser IN VARCHAR2                --Descricao Identificador Usuario
                                      ,pr_tab_rubrica IN inss0001.typ_tab_rubrica --Tabela de Rubricas
                                      ,pr_nmarqimp OUT VARCHAR2               --Nome Arquivo Impressao
                                      ,pr_nmarqpdf OUT VARCHAR2               --Nome do Arquivo pdf
                                      ,pr_des_reto OUT VARCHAR2               --Saida OK/NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --Tabela Erros
  /*---------------------------------------------------------------------------------------------------------------
  
  Programa : pc_gera_arq_demonstrativo             Antigo: procedures/b1wgen0091.p/gera_arquivo_demonstrativo
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Alisson C. Berrido - Amcom
  Data     : Fevereiro/2015                           Ultima atualizacao: 15/06/2015
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo   : Procedure para Gerar arquivo demonstrativo.
  
  Alterações : 23/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
            
               30/03/2015 - Ajuste na organização e identação da escrita (Adriano).            
               
               15/06/2015 - Ajuste para utilizar a rotina pc_efetua_copia_pdf ao invés da 
                            pc_envia_arquivo_web
                           (Adriano).
  
  -------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
     
    --Variaveis do Clob
    vr_clobxml CLOB;
    vr_dstexto VARCHAR2(32767);
    
    --Variaveis Locias
    vr_nrrecben  VARCHAR2(100);
    vr_dslinha1 VARCHAR2(40);
    vr_dslinha2 VARCHAR2(40);
    vr_dslinha3 VARCHAR2(40);
    vr_cdtippag VARCHAR2(15);
    vr_timeextr VARCHAR2(10);
    vr_fontepag VARCHAR2(100);
    vr_nmbenefi VARCHAR2(100);
    vr_nrbenefi VARCHAR2(100);
    vr_cdorgins VARCHAR2(100);
    vr_dtcomext VARCHAR2(100);
    vr_vlrubric NUMBER;
    vr_index    PLS_INTEGER;
   
    --Variaveis Locais para arquivos
    vr_nmarqimp VARCHAR2(1000);
    vr_nmarquiv VARCHAR2(1000);
    vr_comando  VARCHAR2(1000);
    vr_typ_saida VARCHAR2(3);
    vr_nmdireto VARCHAR2(1000);
       
    --Variaveis de Erro
    vr_cdcritic INTEGER;
    vr_des_reto VARCHAR2(3);
    vr_dscritic VARCHAR2(4000);
    
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
     
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
			GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_gera_arq_demonstrativo');
      
      --Limpar tabelas auxiliares
      pr_tab_erro.DELETE;
      
      --Inicializar Variavel
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      
      --Nome Diretorio
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'rl');
                                          
      --Nome Arquivo
      vr_nmarquiv:= vr_nmdireto||'/'||pr_dsiduser;
      
      --Se arquivo existir no diretorio
      IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmarquiv) THEN
        
        --Remover arquivo
        vr_comando:= 'rm '||vr_nmarquiv||'* 2>/dev/null';
        
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
                          
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
          -- retornando ao programa chamador
          RAISE vr_exc_erro;
        END IF;
      END IF;  

      --Concatenar hora no nome do arquivo
      vr_nmarquiv:= vr_nmarquiv||lpad(gene0002.fn_busca_time,5,'0');
      
      --Nome Arquivo impressao
      vr_nmarqimp:= vr_nmarquiv||'.pdf';
      
      vr_dslinha1:= SUBSTR(pr_dscmensa,1,48);
      vr_dslinha2:= SUBSTR(pr_dscmensa,49,48);
      vr_dslinha3:= SUBSTR(pr_dscmensa,97,48);
      vr_dtcomext:= SUBSTR(pr_dtdcompe,1,2) ||'/'|| SUBSTR(pr_dtdcompe,4,4);
      vr_timeextr:= to_char(SYSDATE,'HH24:MI:SS');
      vr_cdtippag:= 'Conta';

      --Abreviar Informacoes
      vr_fontepag:= gene0002.fn_abreviar_string(substr(pr_nomeemis,1,40), 7);
      vr_nmbenefi:= gene0002.fn_abreviar_string(substr(pr_nmbenefi,1,28), 35);
      vr_cdtippag:= gene0002.fn_abreviar_string(vr_cdtippag, 27);
      vr_nrbenefi:= gene0002.fn_abreviar_string(pr_nrbenefi, 27);
      vr_cdorgins:= gene0002.fn_abreviar_string(pr_cdorgins, 13);
      vr_nrrecben:= gene0002.fn_abreviar_string(pr_nrrecben, 11);
      vr_dtcomext:= gene0002.fn_abreviar_string(vr_dtcomext, 10);
     
      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

      --Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
        '<?xml version="1.0" encoding="UTF-8"?><raiz>');
 
      --Texto do Termo
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
        '<dtmvtolt>'|| to_char(pr_dtmvtolt,'DD/MM/YYYY')  ||'</dtmvtolt>'||
        '<timeextr>'|| vr_timeextr ||'</timeextr>'||
        '<fontepag>'|| 'Fonte Pagadora:'||lpad(vr_fontepag,7,'.')||' / CNPJ:'||gene0002.fn_mask_cpf_cnpj(pr_cnpjemis,2) ||'</fontepag>'||
        '<nmbenefi>'|| 'Beneficiario:'||lpad(vr_nmbenefi,35,'.') ||'</nmbenefi>'||
        '<dtcomext>'|| 'Competencia:'||lpad(vr_dtcomext,36,'.') ||'</dtcomext>'||
        '<cdtippag>'|| 'Modalidade Pagamento:'||lpad(vr_cdtippag,27,'.') ||'</cdtippag>'||
        '<nrbenefi>'|| 'NB:'||lpad(lpad(vr_nrbenefi,10,'0'),27,'.')||' / NIT:'||lpad(lpad(vr_nrrecben,11,'0'),11,'.')||'</nrbenefi>'||
        '<dscooper>'|| 'OP:'||lpad(lpad(vr_cdorgins,6,'0'),13,'.') ||' / Cooperativa:'||lpad(rw_crapcop.nmrescop,17,'.')||'</dscooper>'||
        '<dsctotal>'|| 'TOTAL'||lpad(to_char(pr_vlrliqui,'999g999g990d00'),43,'.')||'</dsctotal>'||
        '<dslinha1>'|| nvl(gene0002.fn_centraliza_texto(nvl(vr_dslinha1,''),'.',48),'')  ||'</dslinha1>'||
        '<dslinha2>'|| nvl(gene0002.fn_centraliza_texto(nvl(vr_dslinha2,''),'.',48),'')  ||'</dslinha2>'||
        '<dslinha3>'|| nvl(gene0002.fn_centraliza_texto(nvl(vr_dslinha3,''),'.',48),'')  ||'</dslinha3>'||
        '<tracos>'  || lpad('-',48,'-') ||'</tracos><rubricas>');
        
      --Imprimir rubricas
      vr_index:= pr_tab_rubrica.FIRST;
      
      WHILE vr_index IS NOT NULL LOOP
        
        --Filtrar os beneficios
        IF (pr_nrbenefi <> 0 AND pr_tab_rubrica(vr_index).nrbenefi = pr_nrbenefi) OR 
           (pr_nrrecben <> 0 AND pr_tab_rubrica(vr_index).nrrecben = pr_nrrecben) THEN
           
          --Se for DEBITO
          IF pr_tab_rubrica(vr_index).tpnature = 'DEBITO' THEN
            vr_vlrubric:= pr_tab_rubrica(vr_index).vlrubric * -1;
          ELSE
            vr_vlrubric:= pr_tab_rubrica(vr_index).vlrubric;
          END IF;
            
          --Texto do Termo
          gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
            '<rubrica>'||
            '  <cdrubric>'|| pr_tab_rubrica(vr_index).cdrubric ||'</cdrubric>'||
            '  <nmrubric>'|| pr_tab_rubrica(vr_index).nmrubric ||'</nmrubric>'||
            '  <vlrubric>'|| to_char(vr_vlrubric,'999g999g999g999d00')  ||'</vlrubric>'||
            '</rubrica>');
            
        END IF;
        
        --Proximo registro
        vr_index:= pr_tab_rubrica.NEXT(vr_index);
        
      END LOOP;
      
      --Finaliza TAG Relatorio
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</rubricas></raiz>',TRUE); 

      -- Gera relatório
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
                                 ,pr_cdprogra  => pr_nmdatela                   --> Programa chamador
                                 ,pr_dtmvtolt  => pr_dtmvtolt                   --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                    --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/rubricas/rubrica'      --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'demonstrativo_beneficio.jasper' --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                          --> Sem parâmetros                                         
                                 ,pr_dsarqsaid => vr_nmarqimp                   --> Arquivo final com o path
                                 ,pr_qtcoluna  => 80                            --> Colunas do relatorio
                                 ,pr_flg_gerar => 'S'                           --> Geraçao na hora
                                 ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => NULL                          --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                             --> Número de cópias
                                 ,pr_cdrelato  => 699                           --> Codigo do Relatorio
                                 ,pr_des_erro  => vr_dscritic);                 --> Saída com erro
                                 
      --Se ocorreu erro no relatorio
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF; 
            
      --Fechar Clob e Liberar Memoria  
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);               

      -- Ayllos Web       
      IF pr_idorigem = 5 THEN  
        
        --O ireport já irá gerar o relatório em formato pdf e por isso, iremos apenas
        --envia-lo ao servidor web.           
        gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_nmarqpdf => vr_nmarqimp
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => pr_tab_erro);

        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          
          --Se tem erro na tabela 
          IF pr_tab_erro.COUNT > 0 THEN
            --Mensagem Erro
            vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
          ELSE
            vr_dscritic:= 'Erro ao enviar arquivo para web.';  
          END IF; 
          
          --Sair 
          RAISE vr_exc_erro;
          
        END IF; 
        
        --Nome do arquivo pdf
        pr_nmarqpdf:= SUBSTR(vr_nmarqimp,INSTR(vr_nmarqimp,'/',-1)+1);
        
      END IF;
      
      --Nome arquivo impressao
      pr_nmarqimp:= vr_nmarqimp;
      
      --Retorno OK
      pr_des_reto:= 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        
        -- Retorno não OK          
        pr_des_reto:= 'NOK';
        
        IF vr_cdcritic = 0     AND
           vr_dscritic IS NULL THEN
          
          --Monta mensagem de erro          
          vr_dscritic:= 'Erro na rotina inss0001.pc_gera_arq_demonstrativo.';
          
        END IF;
        
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                             
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        vr_dscritic:= 'Erro na rotina inss0001.pc_gera_arq_demonstrativo. '||SQLERRM;
        
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

  END pc_gera_arq_demonstrativo; 

  /* Procedure para Solicitar Troca de Domicilio */
  PROCEDURE pc_solic_troca_domicilio  (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                      ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                      ,pr_cdorgins IN INTEGER                 --Codigo Orgao Pagador
                                      ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                      ,pr_tpbenefi IN VARCHAR2                --Tipo Beneficio
                                      ,pr_tpdpagto IN VARCHAR2                --Tipo de Pagamento
                                      ,pr_nrdconta IN INTEGER                 --Numero da Conta
                                      ,pr_cdagepac IN INTEGER                 --Codigo Agencia 
                                      ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                      ,pr_idseqttl IN INTEGER                 --Sequencial Titular
                                      ,pr_nmbairro IN VARCHAR2                --Nome do Bairro
                                      ,pr_nrcepend IN INTEGER                 --Numero CEP
                                      ,pr_dsendres IN VARCHAR2                --Descricao Endereco Residencial
                                      ,pr_nrendere IN INTEGER                 --Numero Endereco
                                      ,pr_nmcidade IN VARCHAR2                --Nome Cidade
                                      ,pr_cdufdttl IN VARCHAR2                --Codigo UF Titular
                                      ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                      ,pr_nmextttl IN VARCHAR2                --Nome Extrato Titular
                                      ,pr_nmmaettl IN VARCHAR2                --Nome Mae Titular
                                      ,pr_nrdddtfc IN INTEGER                 --Numero DDD
                                      ,pr_nrtelefo IN INTEGER                 --Numero Telefone
                                      ,pr_cdsexotl IN INTEGER                 --Sexo
                                      ,pr_dtnasttl IN VARCHAR2                --Data nascimento
                                      ,pr_dscsitua IN VARCHAR2                --Descricao Situacao
                                      ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                      ,pr_flgerlog IN INTEGER                 --Escrever Erro no Log (0=nao, 1=sim)
                                      ,pr_temsenha IN VARCHAR                 --Verifica se tem senha da internet ativa
                                      ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                      ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solic_troca_domicilio             Antigo: procedures/b1wgen0091.p/solicita_troca_domicilio
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Fevereiro/2015                           Ultima atualizacao: 21/06/2016
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para solicitar ao SICREDI a troca de Domicilio 
  
    Alterações : 24/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
    
                 30/03/2015 - Alterado o nome do arquivo de envio/recebimento
                             (Adriano).
    
                 10/04/2015 - Ajuste para retornar erro corretamente (Adriano).            
    
                 28/05/2015 - Ajustes realizados:
                              - Incluido tratamento para obrigar o envio de UF;
                              - Somente enviar o telefone se ele for menor 10 digitos;
                              - Incluido tratamento para obrigar o envio do endereço;
                              (Adriano).
                 
                 22/09/2015 - Adicionado validação dos campos e alterado a nomenclatura do arquivo.
                              (Douglas - Chamado 314031)
                              
                 25/11/2015 - Adicionada verificacao para gerar contrato somente
                              quando o beneficiario nao tiver senha de internet 
                              cadastrada. Projeto 255 (Lombardi).
                              
                 10/02/2016 - Ajuste para que, quando for realizado a troca de domicilio para um 
                              cooperado que esteja demitido por demissao, não seja permitido
                              realizar a troca
                              (Adriano - SD 398671).
                                           
                 21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                              (Adriano - SD 473539).
                                                       
                 23/06/2016 - Incluir nome do módulo logado - (Ana - Envolti - Chamado 664301)
  ---------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Selecionar dados da agencia
    CURSOR cr_crapage (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdorgins IN crapage.cdorgins%TYPE) IS
      SELECT  crapage.cdcooper
             ,crapage.cdorgins
             ,crapage.cdagenci
        FROM crapage
        WHERE crapage.cdcooper = pr_cdcooper
        AND   crapage.cdorgins = pr_cdorgins;
    rw_crapage    cr_crapage%ROWTYPE;
         
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%type
                     ,pr_nrdconta IN crapass.nrdconta%type) IS
    SELECT crapass.cdcooper
          ,crapass.nrdconta
          ,crapass.cdsitdct
      FROM crapass crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    --Tabela de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
        
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
        
    --Variaveis Locais
    vr_dstime    VARCHAR2(100);
    vr_msgenvio  VARCHAR2(32767);
    vr_msgreceb  VARCHAR2(32767);
    vr_movarqto  VARCHAR2(32767);
    vr_nmarqlog  VARCHAR2(32767);
    vr_nmdireto  VARCHAR2(1000);
    vr_des_reto  VARCHAR2(3);
    vr_retornvl  VARCHAR2(3):= 'NOK';
    vr_dstexto   VARCHAR2(32767);
    vr_dsendres  VARCHAR2(1000);
    vr_dstransa  VARCHAR2(1000);
    vr_dsorigem  VARCHAR2(1000);
    vr_nrdrowid  ROWID;
    vr_dtmvtolt  DATE;
    vr_dtnasttl  DATE;
    vr_nmarqimp  VARCHAR2(100);
    vr_nmarqpdf  VARCHAR2(100);
    vr_auxconta  PLS_INTEGER:= 0;
    vr_dscritic2 VARCHAR2(4000);
    vr_auxnmarq  VARCHAR2(30);
    vr_des_log   varchar(1000);
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
          
    --Variaveis DOM
    vr_XML        XMLType;
    vr_xmldoc     xmldom.DOMDocument;
    vr_lista_nodo DBMS_XMLDOM.DOMNodelist;
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;                                       
    vr_exc_saida EXCEPTION; 
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
      
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_solic_troca_domicilio');      
            
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      vr_msgenvio:= null;
      vr_msgreceb:= null;
      vr_movarqto:= null;
      vr_nmarqlog:= null;
      vr_dstime:=   null;

      BEGIN                                                  
        --Pega a data movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/YYYY'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      BEGIN                                                  
        --Pega a data de nascimento e converte para "DATE"
        vr_dtnasttl:= to_date(pr_dtnasttl,'DD/MM/YYYY'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de nascimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => vr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
       RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
  
      --Selecionar Agencia
      OPEN cr_crapage (pr_cdcooper => vr_cdcooper
                      ,pr_cdorgins => pr_cdorgins);
                      
      FETCH cr_crapage INTO rw_crapage;
      
      IF cr_crapage%NOTFOUND THEN
        
        --Fechar Cursor
        CLOSE cr_crapage;   
                    
        --Monta mensagem de critica 
        vr_cdcritic:= 962;
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        pr_nmdcampo:= 'nrdconta';
        
        --Excecao
        RAISE vr_exc_erro;
      ELSE
        --Fechar Cursor
        CLOSE cr_crapage;
      END IF;

      --Busca o associado
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
                     
      FETCH cr_crapass INTO rw_crapass;
      
      IF cr_crapass%NOTFOUND THEN
        
        --Fechar cursor
        CLOSE cr_crapass;
        
        --Monta mensagem de critica 
        vr_cdcritic:= 9;
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        pr_nmdcampo:= 'nrdconta';
        
        --Excecao
        RAISE vr_exc_erro;
        
      ELSE
        
        --Fechar cursor        
        CLOSE cr_crapass;      
        
        IF rw_crapass.cdsitdct = 4 THEN
          
          --Monta mensagem de critica 
          vr_cdcritic:= 0;
          vr_dscritic:= 'Conta encerrada por demissao.';
          pr_nmdcampo:= 'nrdconta';
        
          --Excecao
          RAISE vr_exc_erro;
        
        END IF;
        
      END IF;
      
      --Verificar parametros
      IF NVL(pr_nrrecben,0) = 0   OR
         LENGTH(pr_nrrecben) > 10 THEN
        
        --Monta mensagem de critica
        vr_dscritic:= 'NB invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_tpbenefi) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Tido do beneficio invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_nmmaettl) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Filiacao invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_dtnasttl) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Data de nascimento invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_cdorgins,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Orgao pagador invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      
      ELSIF TRIM(pr_cdufdttl) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'UF invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_cdagepac,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Unidade de atendimento invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_tpdpagto) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Tipo de pagamento invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_dscsitua) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Situacao invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_cdagesic,0) = 0 THEN  
        
        --Monta mensagem de crtiica
        vr_dscritic:= 'Agencia SICREDI invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_nrdconta,0) = 0 THEN
        
        --Monta mensagem de critica
        vr_cdcritic:= 9;  
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_nrcpfcgc,0) = 0 THEN
        
        --Monta mensagem de critica
        vr_dscritic:= 'CPF invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_nmcidade) IS NULL THEN
        
        --Monta mensagem de critica
        vr_dscritic:= 'Cidade invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_dsendres) IS NULL THEN
        
        --Monta mensagem de critica
        vr_dscritic:= 'Endereco invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF;  
        
      --Buscar Diretorio Padrao da Cooperativa
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => null);
                                          
      --Determinar Nomes do Arquivo de Log
      vr_nmarqlog:= 'SICREDI_Soap_LogErros';

      --Buscar o Horario
      vr_dstime:= lpad(gene0002.fn_busca_time,5,'0');
      
      -- Complemento para o Nome do arquivo
      vr_auxnmarq:= LPAD(pr_nrrecben,11,'0')||'.'||
                    vr_dstime ||
                    LPAD(TRUNC(DBMS_RANDOM.Value(0,9999)),4,'0');
      
      --Determinar Nomes do Arquivo de Envio
      vr_msgenvio:= vr_nmdireto||'/arq/INSS.SOAP.ETRCDOM.'||vr_auxnmarq;
                    
      --Determinar Nome do Arquivo de Recebimento    
      vr_msgreceb:= vr_nmdireto||'/arq/INSS.SOAP.RTRCDOM.'||vr_auxnmarq;
                    
      --Determinar Nome Arquivo movido              
      vr_movarqto:= vr_nmdireto||'/salvar/inss';
      
      --Bloco Domicilio
      BEGIN
        
        --Gerar cabecalho XML
        inss0001.pc_gera_cabecalho_soap (pr_idservic => 2   /* idservic */ 
                                        ,pr_nmmetodo => 'ben:InIncluirBeneficiarioINSS' --Nome Metodo
                                        ,pr_username => 'app_cecred_client' --Username
                                        ,pr_password => fn_senha_sicredi    --Senha
                                        ,pr_dstexto  => vr_dstexto          --Texto do Arquivo de Dados
                                        ,pr_des_reto => vr_des_reto         --Retorno OK/NOK
                                        ,pr_dscritic => vr_dscritic);       --Descricao da Critica
                                       
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          RAISE vr_exc_saida;
        END IF;

        /*Monta as tags de envio
        OBS.: O valor das tags deve respeitar a formatacao presente na
              base do SICREDI do contrario, a operacao nao sera
              realizada. */
              
        --Montar o logradouro
        IF nvl(pr_nrendere,0) > 0 THEN
          vr_dsendres:= SUBSTR(pr_dsendres,1,30)||','||pr_nrendere;
        ELSE
          vr_dsendres:= SUBSTR(pr_dsendres,1,30);
        END IF;
            
        --Montar o XML      
        vr_dstexto:= vr_dstexto||
            '<ben:Beneficiario NumeroDocumento="'||lpad(pr_nrcpfcgc,11,'0')||'">'||
               '<v1:Enderecos>'||
                  '<v12:Endereco>'||
                     '<v12:Logradouro>'||
                        '<v12:Nome>'||vr_dsendres||'</v12:Nome>'||
                     '</v12:Logradouro>'||
                     '<v12:Bairro>'||SUBSTR(pr_nmbairro,1,17)||'</v12:Bairro>'||
                     '<v12:Cidade>'||
                        '<v12:Nome>'||pr_nmcidade||'</v12:Nome>'||            
                        '<v12:Estado>'||
                           '<v12:Sigla>'||pr_cdufdttl||'</v12:Sigla>'||            
                        '</v12:Estado>'|| 
                     '</v12:Cidade>'||            
                     '<v12:CEP>'||pr_nrcepend||'</v12:CEP>'||           
                  '</v12:Endereco>'||
               '</v1:Enderecos>'||
               '<v1:Nome>'||SUBSTR(pr_nmextttl,1,30)||'</v1:Nome>'||
               '<v1:Filiacao>'||
                  '<v1:NomeMae>'||SUBSTR(pr_nmmaettl,1,30)||'</v1:NomeMae>'||            
               '</v1:Filiacao>'||
               '<v1:Sexo>'||CASE pr_cdsexotl WHEN 1 THEN 'MASCULINO' ELSE 'FEMININO' END||'</v1:Sexo>'||
               '<v1:DataNascimento>'||to_char(vr_dtnasttl,'YYYY-MM-DD')||'-00:00:00'||'</v1:DataNascimento>'||
               '<v1:Contatos>'||
                   '<v1:Telefones>'||
                      '<v13:Telefone>'||
                         --Somente vamos enviar o telefone se ele for menor que 10 digitos.
                         '<v13:DDD>'|| CASE WHEN LENGTH(pr_nrtelefo) < 10 THEN pr_nrdddtfc ELSE '' END ||'</v13:DDD>'||
                         '<v13:Numero>'|| CASE WHEN LENGTH(pr_nrtelefo) < 10 THEN pr_nrtelefo ELSE '' END ||'</v13:Numero>'||                         
                      '</v13:Telefone>'||                        
                   '</v1:Telefones>'||                        
                '</v1:Contatos>'||
               '<v14:Identificadores>'||
                  '<v14:IdentificadorBeneficiario>'||
                     '<v14:Codigo>'||lpad(pr_nrrecben,10,'0')||'</v14:Codigo>'||                        
                     '<v14:TipoCodigo>'||pr_tpbenefi||'</v14:TipoCodigo>'||                                    
                  '</v14:IdentificadorBeneficiario>'||                        
               '</v14:Identificadores>'||
               '<v14:OrgaoPagador>'||
                  '<v14:NumeroOrgaoPagador>'||pr_cdorgins||'</v14:NumeroOrgaoPagador>'||                        
                  '<v14:Entidade>'||
                     '<v15:NumeroUnidadeAtendimento>2</v15:NumeroUnidadeAtendimento>'||                                    
                  '</v14:Entidade>'||                        
               '</v14:OrgaoPagador>'||
               '<v14:Beneficio>'||
                  '<v16:TipoPagamento>'||pr_tpdpagto||'</v16:TipoPagamento>'||                        
                  '<v16:Situacao>'||pr_dscsitua||'</v16:Situacao>'||                        
               '</v14:Beneficio>'||
               '<v14:Situacao>'||pr_dscsitua||'</v14:Situacao>'||
               '<v14:ContaCorrente>'||
                  '<v17:codigoAgencia>'||pr_cdagesic||'</v17:codigoAgencia>'||                        
                  '<v17:numero>'||SUBSTR(pr_nrdconta,1,LENGTH(pr_nrdconta)-1)||'</v17:numero>'||                        
                  '<v17:digitoVerificador>'||SUBSTR(pr_nrdconta,LENGTH(pr_nrdconta),1)||'</v17:digitoVerificador>'||                                    
               '</v14:ContaCorrente>'||
            '</ben:Beneficiario>'||
            '</ben:InIncluirBeneficiarioINSS>'||
            '</soapenv:Body></soapenv:Envelope>';                      
           
        --Efetuar Requisicao Soap
        inss0001.pc_efetua_requisicao_soap (pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                           ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                           ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                           ,pr_idservic => 5             --Identificador Servico
                                           ,pr_dsservic => 'Incluir'     --Descricao Servico
                                           ,pr_nmmetodo => 'OutIncluirBeneficiarioINSS' --Nome Método
                                           ,pr_dstexto  => vr_dstexto    --Texto com a msg XML
                                           ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                           ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                           ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                           ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo Log
                                           ,pr_nmdatela => vr_nmdatela   --Nome da Tela
                                           ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                           ,pr_dscritic => vr_dscritic); --Descrição Erros
                                           
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
          
        --Verifica Falha no Pacote
        inss0001.pc_obtem_fault_packet (pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                       ,pr_nmdatela => vr_nmdatela   --Nome da Tela
                                       ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                       ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                       ,pr_dsderror => 'SOAP-ENV:-950' --Descricao Servico
                                       ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                       ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                       ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                       ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo log
                                       ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                       ,pr_dscritic => vr_dscritic); --Mensagem Erro
        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          pr_des_erro:= vr_des_reto;
          RAISE vr_exc_saida;
        ELSE
          /** Valida SOAP retornado pelo WebService **/
          gene0002.pc_arquivo_para_xml (pr_nmarquiv => vr_msgreceb    --> Nome do caminho completo) 
                                       ,pr_xmltype  => vr_XML         --> Saida para o XML
                                       ,pr_des_reto => vr_des_reto    --> Descrição OK/NOK
                                       ,pr_dscritic => vr_dscritic);  --> Descricao Erro 

          --Se Ocorreu erro
          IF vr_des_reto = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_saida;  
          END IF;              
          
          --Realizar o Parse do Arquivo XML
          vr_xmldoc:= xmldom.newDOMDocument(vr_XML);
            
          --Verificar se existe tag "oidBeneficiario"
          vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'oidBeneficiario');
          
          --Se nao existir a tag "oidBeneficiario" 
          IF dbms_xmldom.getlength(vr_lista_nodo) = 0 THEN
            vr_dscritic:= 'Troca de domicilio nao efetuada.';
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;  
          --Retornar OK
          vr_retornvl:= 'OK'; 
        END IF;                                
                                            
      EXCEPTION
        WHEN vr_exc_saida THEN 
          vr_retornvl:= 'NOK';
      END;  
      
      --Eliminar arquivos requisicao
      inss0001.pc_elimina_arquivos_requis (pr_cdcooper => vr_cdcooper      --Codigo Cooperativa
                                          ,pr_cdprogra => vr_nmdatela      --Nome do Programa
                                          ,pr_msgenvio => vr_msgenvio      --Mensagem Envio
                                          ,pr_msgreceb => vr_msgreceb      --Mensagem Recebimento
                                          ,pr_movarqto => vr_movarqto      --Nome Arquivo mover
                                          ,pr_nmarqlog => vr_nmarqlog      --Nome Arquivo LOG
                                          ,pr_des_reto => vr_des_reto      --Retorno OK/NOK 
                                          ,pr_dscritic => vr_dscritic2);    --Descricao Erro
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        --Monta a mensagem de erro
        vr_dscritic := vr_dscritic2;
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;     
      
		  --Incluir nome do módulo logado - Chamado 664301
      --Seta novamente esta rotina porque foi alterado dentro da pc_elimina_arquivos_requis
			GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_solic_troca_domicilio');
      
      --Se for para gerar log
      IF pr_flgerlog = 1 THEN
        
        --Descricao da Origem e da Transacao
        vr_dsorigem:= gene0001.vr_vet_des_origens(vr_idorigem);
        vr_dstransa:= 'Troca de domicilio';
      
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => SUBSTR(vr_dscritic,1,159)
                            ,pr_dsorigem => SUBSTR(vr_dsorigem,1,13)
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => CASE vr_retornvl WHEN 'OK' THEN 1 ELSE 0 END  
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid); 
                                   
        -- Gera item de log com informacao nova
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'nrdconta'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_nrdconta);
                                   
        -- Gera item de log com informacao nova
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'nrrecben'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_nrrecben); 
                                                                   
      END IF;
      
      IF vr_retornvl = 'OK' THEN
        IF UPPER(pr_temsenha) = 'FALSE' THEN
        --Gerar Termo de Troca de Domicilio
        inss0001.pc_gera_termo_troca_domic (pr_cdcooper => vr_cdcooper   --Cooperativa
                                           ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                           ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                           ,pr_cdoperad => vr_cdoperad   --Operador
                                           ,pr_nmdatela => vr_nmdatela   --Nome da tela
                                           ,pr_idorigem => vr_idorigem   --Origem Processamento
                                           ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                           ,pr_nrcpfcgc => pr_nrcpfcgc   --Numero CPF/CGC
                                           ,pr_idseqttl => pr_idseqttl   --Sequencial do Titular
                                           ,pr_cdagesic => pr_cdagesic   --Codigo Agencia Sicredi
                                           ,pr_dtmvtolt => vr_dtmvtolt   --Data Movimento
                                           ,pr_nrrecben => pr_nrrecben   --Numero Recebimento Beneficiario
                                           ,pr_cdorgins => pr_cdorgins   --Numero Orgao pagamento para INSS
                                           ,pr_nmrecben => pr_nmextttl   --Nome Beneficiario
                                           ,pr_dsiduser => pr_dsiduser   --Descricao Identificador Usuario
                                           ,pr_nmarqimp => vr_nmarqimp   --Nome Arquivo Impressao
                                           ,pr_nmarqpdf => vr_nmarqpdf   --Nome do Arquivo pdf
                                           ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                           ,pr_tab_erro => vr_tab_erro);
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Se nao tiver erro na tabela 
          IF vr_tab_erro.COUNT > 0 THEN
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE  
            vr_dscritic:= 'Nao foi possivel gerar o termo de troca de domicilio.';
          END IF;  
          --Levantar Excecao
          RAISE vr_exc_erro;
          END IF;
        END IF;
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

          -- Insere as tags dos campos da PLTABLE de aplicações
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqimp', pr_tag_cont => vr_nmarqimp, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarqpdf, pr_des_erro => vr_dscritic);
	  
      ELSE
        --Se nao possui mensagem de erro
        IF vr_cdcritic = 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= 'Nao foi possivel realizar a troca de domicilio.';
        
        END IF;
          
        --Verificar se possui somente código erro
        IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
                               
        -- Gravar Linha Log
        inss0001.pc_retorna_linha_log(pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                     ,pr_cdprogra => vr_nmdatela   --Nome do Programa
                                     ,pr_dtmvtolt => vr_dtmvtolt   --Data Movimento
                                     ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                     ,pr_nrcpfcgc => pr_nrcpfcgc   --Numero Cpf
                                     ,pr_nrrecben => pr_nrrecben   --Numero Recebimento Beneficio
                                     ,pr_nmmetodo => 'Troca de domicilio' --Nome do metodo
                                     ,pr_cdderror => vr_cdcritic   --Codigo Erro
                                     ,pr_dsderror => vr_dscritic   --Descricao Erro
                                     ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo LOG
                                     ,pr_cdtipofalha => 3          --Tipo 2 abre chamado
                                     ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                     ,pr_dscritic => vr_dscritic2); --Descricao erro
        
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          vr_dscritic:= vr_dscritic2;          
        END IF;
          
        --Gera exeção
        RAISE vr_exc_erro;        
        
      END IF;
      
      vr_des_log :=   
        'Conta: '    || gene0002.fn_mask(pr_nrdconta,'9999.999-9')  || ' | ' ||
        'Nome: '     || pr_nmextttl                         || ' | ' ||
        'NB: '       || to_char(pr_nrrecben)                || ' | ' ||
        'operador: ' || to_char(vr_cdoperad)                || ' | ' ||
        'Alteracao: Troca de domicilio para conta ' || pr_nrdconta || '.';
                                                 
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || vr_nmdatela || ' --> ' || 
                                                    'ALERTA: ' || vr_des_log
                                  ,pr_nmarqlog     => 'inss_historico.log'
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_cdprograma   => vr_nmdatela
                                  );
      
      --Retorno
      pr_des_erro:= vr_retornvl;    

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= vr_retornvl;
        
        --Monta mensagem de erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na inss0001.pc_solic_troca_domicilio --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_solic_troca_domicilio;

  /* Procedure para Solicitar Demonstrativo de beneficio */
  PROCEDURE pc_solicita_demonstrativo  (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                       ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                       ,pr_nrdconta IN INTEGER                 --Numero da Conta
                                       ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                       ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio                                                                            
                                       ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                       ,pr_dtvalida IN VARCHAR2                --Data Validade
                                       ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                       ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solicita_demonstrativo             Antigo: procedures/b1wgen0091.p/solicita_demonstrativo
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Fevereiro/2015                           Ultima atualizacao: 21/06/2016
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para solicitar ao SICREDI a demonstrativo de beneficios 
  
    Alterações : 25/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
    
                 31/03/2015 - Alterado o nome do arquivo envio/recebimento
                              (Adriano).
                              
                 10/04/2015 - Ajuste para retornar erro corretamente (Adriano).             
                 
                 15/06/2015 - Ajuste para gerar corretamente o demonstrativo de NB para cooperados
                              que são segundo titular em conta
                              (Adriano).

                 23/09/2015 - Ajuste na nomenclatura do arquivo (Douglas - Chamado 314031)
                 
                 21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                              (Adriano - SD 473539).
                              
                 23/06/2016 - Incluir nome do módulo logado - (Ana - Envolti - Chamado 664301)
  ---------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
    vr_dscritic2 VARCHAR2(4000); 
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);	
    
    --Variaveis Locais
    vr_qtlinha   INTEGER;
    vr_dstime    VARCHAR2(100);
    vr_msgenvio  VARCHAR2(32767);
    vr_msgreceb  VARCHAR2(32767);
    vr_movarqto  VARCHAR2(32767);
    vr_nmarqlog  VARCHAR2(32767);
    vr_nmdireto  VARCHAR2(1000);
    vr_nmparam   VARCHAR2(1000);
    vr_dstexto   VARCHAR2(32767);
    vr_des_reto  VARCHAR2(3);
    vr_retornvl  VARCHAR2(3):= 'NOK';
    vr_dtinival  DATE;
    vr_dtfinval  DATE;
    vr_dtmvtolt  DATE;
    vr_dtvalida  DATE;
    vr_nmarqimp  VARCHAR2(100);
    vr_nmarqpdf  VARCHAR2(100);
    vr_auxconta  PLS_INTEGER:= 0;
    vr_index     PLS_INTEGER;
    vr_auxnmarq  VARCHAR2(30);
    
    --Variaveis DOM
    vr_XML        XMLType;
    vr_xmldoc     xmldom.DOMDocument;
    vr_lista_nodo DBMS_XMLDOM.DOMNodelist;
    vr_nodo       xmldom.DOMNode;

    --Tabelas de Memoria
    vr_tab_erro    gene0001.typ_tab_erro;
    vr_tab_rubrica inss0001.typ_tab_rubrica;
    vr_tab_demonst inss0001.typ_tab_demonstrativos;
         
    --Indices para tabelas memoria
    vr_index_demonst PLS_INTEGER;
    vr_index_rubrica PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;                                       
    vr_exc_saida EXCEPTION; 
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      --Limpar tabela Demonstrativos
      vr_tab_demonst.DELETE;
      --Limpar tabela Rubricas
      vr_tab_rubrica.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= NULL;
      vr_msgenvio:= NULL;
      vr_msgreceb:= NULL;
      vr_movarqto:= NULL;
      vr_nmarqlog:= NULL;
      vr_dstime:=   NULL;
     
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
      
  	  -- Incluir nome do módulo logado - Chamado 664301
			GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_solicita_demonstrativo');            
      
      BEGIN                                                  
        --Pega a data de movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/YYYY'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      BEGIN                                                  
        --Pega a data de validade e converte para "DATE"
        vr_dtvalida:= to_date(pr_dtvalida,'MM/YYYY'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de validade invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => vr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise        
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica        
        vr_cdcritic := 651;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Gera exceção
        RAISE vr_exc_erro;
        
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
  
      --Buscar Diretorio Padrao da Cooperativa
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => null);
                                          
      --Determinar Nomes do Arquivo de Log
      vr_nmarqlog:= 'SICREDI_Soap_LogErros';

      --Buscar o Horario
      vr_dstime:= lpad(gene0002.fn_busca_time,5,'0');
      
      -- Complemento para o Nome do arquivo
      vr_auxnmarq:= LPAD(pr_nrrecben,11,'0')||'.'||
                    vr_dstime ||
                    LPAD(TRUNC(DBMS_RANDOM.Value(0,9999)),4,'0');
      
      --Determinar Nomes do Arquivo de Envio
      vr_msgenvio:= vr_nmdireto||'/arq/INSS.SOAP.EDEMONS.'||vr_auxnmarq;
                    
      --Determinar Nome do Arquivo de Recebimento    
      vr_msgreceb:= vr_nmdireto||'/arq/INSS.SOAP.RDEMONS.'||vr_auxnmarq;
                    
      --Determinar Nome Arquivo movido              
      vr_movarqto:= vr_nmdireto||'/salvar/inss';

      --Data Inicio Validade
      vr_dtinival:= trunc(vr_dtvalida,'MM');
      
      --Data Final Validade
      vr_dtfinval:= last_day(vr_dtinival);
                           
      --Verificar parametros
      IF nvl(pr_nrdconta,0) = 0 THEN
        
        --Monta mensagem de critica
        vr_cdcritic:= 9;  
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        pr_nmdcampo:= 'dtvalida';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_nrcpfcgc,0) = 0 THEN
        
        --Monta mensagem de critica
        vr_dscritic:= 'CPF invalido.';
        pr_nmdcampo:= 'dtvalida';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_cdagesic,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Agencia SICREDI invalida.';
        pr_nmdcampo:= 'dtvalida';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF pr_dtvalida IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Mes e ano de validade invalida.';
        pr_nmdcampo:= 'dtvalida';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_nrrecben,0) = 0 THEN
        
        --Monta mensagem de critica
        vr_dscritic:= 'NB invalido.';
        pr_nmdcampo:= 'opdemons';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF;  
        
      --Bloco Demonstrativo
      BEGIN
        
        --Modificar o formato dos decimais pois a conexao web modifica
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '',.''';
        
        --Gerar cabecalho XML
        inss0001.pc_gera_cabecalho_soap (pr_idservic => 1   /* idservic */ 
                                        ,pr_nmmetodo => 'ben:InConsultarDemonstrativoINSS' --Nome Metodo
                                        ,pr_username => 'app_cecred_client' --Username
                                        ,pr_password => fn_senha_sicredi    --Senha
                                        ,pr_dstexto  => vr_dstexto          --Texto do Arquivo de Dados
                                        ,pr_des_reto => vr_des_reto         --Retorno OK/NOK
                                        ,pr_dscritic => vr_dscritic);       --Descricao da Critica
                                       
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          RAISE vr_exc_saida;
        END IF;

        /*Monta as tags de envio
        OBS.: O valor das tags deve respeitar a formatacao presente na
              base do SICREDI do contrario, a operacao nao sera
              realizada. */
              
        --Montar o XML      
        vr_dstexto:= vr_dstexto||
            '<ben:dadosContaCorrente>'||
               '<ben:numAgencia>'||pr_cdagesic||'</ben:numAgencia>'||
               '<ben:contaCorrente>'||lpad(pr_nrdconta,10,'0')||'</ben:contaCorrente>'||
               '<ben:dataInicialValidade>'||to_char(vr_dtinival,'YYYY-MM-DD')||'T00:00:00'||'</ben:dataInicialValidade>'||
               '<ben:dataFinalValidade>'||to_char(vr_dtfinval,'YYYY-MM-DD')||'T24:00:00'||'</ben:dataFinalValidade>'||
            '</ben:dadosContaCorrente>>'||
            '</ben:InConsultarDemonstrativoINSS>'||
            '</soapenv:Body></soapenv:Envelope>';                      
           
        --Efetuar Requisicao Soap
        inss0001.pc_efetua_requisicao_soap (pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                           ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                           ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                           ,pr_idservic => 4             --Identificador Servico
                                           ,pr_dsservic => 'Demonstrativo'     --Descricao Servico
                                           ,pr_nmmetodo => 'OutConsultarDemonstrativoINSS' --Nome Método
                                           ,pr_dstexto  => vr_dstexto    --Texto com a msg XML
                                           ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                           ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                           ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                           ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo Log
                                           ,pr_nmdatela => vr_nmdatela   --Nome da Tela
                                           ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                           ,pr_dscritic => vr_dscritic); --Descrição Erros
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
          
        --Verifica Falha no Pacote
        inss0001.pc_obtem_fault_packet (pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                       ,pr_nmdatela => vr_nmdatela   --Nome da Tela
                                       ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                       ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                       ,pr_dsderror => 'SOAP-ENV:-950' --Descricao Servico
                                       ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                       ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                       ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                       ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo log
                                       ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                       ,pr_dscritic => vr_dscritic); --Mensagem Erro
        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          pr_des_erro:= vr_des_reto;
          RAISE vr_exc_saida;
        END IF;
               
        /** Valida SOAP retornado pelo WebService **/
        gene0002.pc_arquivo_para_xml (pr_nmarquiv => vr_msgreceb    --> Nome do caminho completo) 
                                     ,pr_xmltype  => vr_XML         --> Saida para o XML
                                     ,pr_des_reto => vr_des_reto    --> Descrição OK/NOK
                                     ,pr_dscritic => vr_dscritic);  --> Descricao Erro 

        --Se Ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_saida;  
        END IF;              
          
        --Realizar o Parse do Arquivo XML
        vr_xmldoc:= xmldom.newDOMDocument(vr_XML);
            
        --Verificar se existe tag "Demonstrativos"
        vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'Demonstrativos');
          
        --Se nao encontrou nenhum nodo 
        IF dbms_xmldom.getlength(vr_lista_nodo) = 0 THEN
          
          --Monta mensagem de critica
          vr_dscritic:= 'Dados do Demonstrativo nao encontrados.';
          
          --Levantar Excecao
          RAISE vr_exc_saida;
          
        END IF;  
        
        --Arquivo OK, percorrer as tags
          
        --Lista de nodos
        vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'*');
          
        --Quantidade tags no XML
        vr_qtlinha:= xmldom.getLength(vr_lista_nodo);
          
        /* Para cada um dos filhos do DadosBeneficioINSS */
        FOR vr_linha IN 1..(vr_qtlinha-1) LOOP
            
          --Buscar Nodo Corrente
          vr_nodo:= xmldom.item(vr_lista_nodo,vr_linha);
            
          --Nome Parametro Nodo corrente
          vr_nmparam:= xmldom.getNodeName(vr_nodo);
            
          --Buscar somente sufixo (o que tem apos o caracter :)
          vr_nmparam:= SUBSTR(vr_nmparam,instr(vr_nmparam,':')+1);

          --Tratar parametros que possuem dados  
          CASE vr_nmparam
              
            WHEN 'DadosDemonstrativo' THEN
            
              --Incrementar Contador
              vr_index_demonst:= vr_tab_demonst.COUNT + 1;
                
              --Incrementar Contador
              vr_index_rubrica:= vr_tab_rubrica.COUNT + 1;

            WHEN 'cnpjEmissor' THEN
              
              --Buscar o Nodo  
              vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                            
              --CNPJ Emissor
              vr_tab_demonst(vr_index_demonst).cnpjemis:= xmldom.getNodeValue(vr_nodo);
               
            WHEN 'nomeEmissor' THEN
                
              --Buscar o Nodo  
              vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                            
              --Nome Emissor
              vr_tab_demonst(vr_index_demonst).nomeemis:= xmldom.getNodeValue(vr_nodo);
                
            WHEN 'orgaoPagador' THEN  
                
              --Buscar o Nodo  
              vr_nodo:= xmldom.getFirstChild(vr_nodo);
              
              --Orgao Pagador
              vr_tab_demonst(vr_index_demonst).cdorgins:= xmldom.getNodeValue(vr_nodo);
                
            WHEN 'numeroBeneficio' THEN     
                       
              --Buscar o Nodo        
              vr_nodo:= xmldom.getFirstChild(vr_nodo); 
              
              --Numero beneficio
              vr_tab_demonst(vr_index_demonst).nrbenefi:= xmldom.getNodeValue(vr_nodo);
              vr_tab_rubrica(vr_index_rubrica).nrbenefi:= xmldom.getNodeValue(vr_nodo); 
                
            WHEN 'numeroNit' THEN  
                
              --Buscar o Nodo  
              vr_nodo:= xmldom.getFirstChild(vr_nodo); 
              
              --NIT
              vr_tab_demonst(vr_index_demonst).nrrecben:= xmldom.getNodeValue(vr_nodo);
              vr_tab_rubrica(vr_index_rubrica).nrrecben:= xmldom.getNodeValue(vr_nodo); 

                 
            WHEN 'competencia' THEN
                
              --Buscar o Nodo  
              vr_nodo:= xmldom.getFirstChild(vr_nodo); 
              
              --Data Competencia
              vr_tab_demonst(vr_index_demonst).dtdcompe:= SUBSTR(xmldom.getNodeValue(vr_nodo),5,2)||'/'||
                                                          SUBSTR(xmldom.getNodeValue(vr_nodo),1,4);
                 
            WHEN 'nomeBeneficiario' THEN
             
              --Buscar o Nodo     
              vr_nodo:= xmldom.getFirstChild(vr_nodo); 
              
              --Nome beneficiario
              vr_tab_demonst(vr_index_demonst).nmbenefi:= xmldom.getNodeValue(vr_nodo);
              
            WHEN 'dataInicialPeriodo' THEN
                
              --Buscar o Nodo  
              vr_nodo:= xmldom.getFirstChild(vr_nodo);
              
              IF instr(xmldom.getNodeValue(vr_nodo),'4713') = 0 THEN
                --Data Inicio Periodo
                vr_tab_demonst(vr_index_demonst).dtiniprd:= to_date(xmldom.getNodeValue(vr_nodo),'YYYY-MM-DD-HH24:MI');  
              END IF;
                                                    
            WHEN 'dataFinalPeriodo' THEN
                
              --Buscar o Nodo                
              vr_nodo:= xmldom.getFirstChild(vr_nodo); 
              
              IF instr(xmldom.getNodeValue(vr_nodo),'4713') = 0 THEN
                --Data Final Periodo
                vr_tab_demonst(vr_index_demonst).dtfinprd:= to_date(xmldom.getNodeValue(vr_nodo),'YYYY-MM-DD-HH24:MI');  
              END IF;
                        
            WHEN 'vlrBruto' THEN
                
              --Buscar o Nodo  
              vr_nodo:= xmldom.getFirstChild(vr_nodo); 
              
              --Valor Bruto
              vr_tab_demonst(vr_index_demonst).vlrbruto:= replace(xmldom.getNodeValue(vr_nodo),'.',',');
             
            WHEN 'vlrDesconto' THEN
                
              --Buscar o Nodo  
              vr_nodo:= xmldom.getFirstChild(vr_nodo);
              
              --Valor Desconto                  
              vr_tab_demonst(vr_index_demonst).vldescto:= replace(xmldom.getNodeValue(vr_nodo),'.',',');

            WHEN 'vlrLiquido' THEN
               
              --Buscar o Nodo   
              vr_nodo:= xmldom.getFirstChild(vr_nodo); 
              
              --Valor Liquido                  
              vr_tab_demonst(vr_index_demonst).vlliquid:= replace(xmldom.getNodeValue(vr_nodo),'.',',');

            WHEN 'descMensagem' THEN
                
              --Buscar o Nodo   
              vr_nodo:= xmldom.getFirstChild(vr_nodo); 
              
              --mensagem                  
              vr_tab_demonst(vr_index_demonst).dscdamsg:= xmldom.getNodeValue(vr_nodo);
                   
            WHEN 'codRubrica' THEN
               
              --Buscar o Nodo   
              vr_nodo:= xmldom.getFirstChild(vr_nodo); 
              
              --Codigo Rubrica
              vr_tab_rubrica(vr_index_rubrica).cdrubric:= xmldom.getNodeValue(vr_nodo);

            WHEN 'valorRubrica' THEN
                
              --Buscar o Nodo  
              vr_nodo:= xmldom.getFirstChild(vr_nodo); 
              
              --Valor Rubrica
              vr_tab_rubrica(vr_index_rubrica).vlrubric:= replace(xmldom.getNodeValue(vr_nodo),'.',',');

            WHEN 'nomeRubrica' THEN
                
              --Buscar o Nodo  
              vr_nodo:= xmldom.getFirstChild(vr_nodo); 
              
              --Nome Rubrica
              vr_tab_rubrica(vr_index_rubrica).nmrubric:= xmldom.getNodeValue(vr_nodo);

            WHEN 'tpoNatureza' THEN
                
              --Buscar o Nodo  
              vr_nodo:= xmldom.getFirstChild(vr_nodo); 
              
              --Tipo Natureza
              vr_tab_rubrica(vr_index_rubrica).tpnature:= xmldom.getNodeValue(vr_nodo);

            ELSE NULL;  
            
          END CASE;
          
        END LOOP; --vr_linha IN 1..(vr_qtlinha-1)            

        --Se nao Encontrou nada na temp-table
        IF vr_tab_demonst.COUNT = 0 THEN
          
          --Monta mensagem de critica
          vr_dscritic:= 'Demonstrativo nao encontrado.';
          
          --Gera exceção
          RAISE vr_exc_saida;
        
        END IF;  

        --Imprimir rubricas
        vr_index:= vr_tab_demonst.FIRST;
      
        WHILE vr_index IS NOT NULL LOOP
          
          --Gera o demonstrativo do NB consultado
          IF (pr_nrrecben <> 0 AND vr_tab_demonst(vr_index).nrbenefi = pr_nrrecben) OR 
             (pr_nrrecben <> 0 AND vr_tab_demonst(vr_index).nrrecben = pr_nrrecben) THEN
             
            --Gerar Arquivo Demonstrativo
            INSS0001.pc_gera_arq_demonstrativo (pr_cdcooper => vr_cdcooper   --Cooperativa
                                               ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                               ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                               ,pr_cdoperad => vr_cdoperad   --Operador
                                               ,pr_idorigem => vr_idorigem   --Origem Processamento                                      
                                               ,pr_nmdatela => vr_nmdatela   --Programa chamador                                      
                                               ,pr_dtmvtolt => vr_dtmvtolt   --Data Movimento
                                               ,pr_cnpjemis => vr_tab_demonst(vr_index).cnpjemis  --Cnpj Emissor
                                               ,pr_nomeemis => vr_tab_demonst(vr_index).nomeemis  --Nome Emissor
                                               ,pr_cdorgins => vr_tab_demonst(vr_index).cdorgins  --Codigo Orgao Pagador
                                               ,pr_nrbenefi => vr_tab_demonst(vr_index).nrbenefi  --Numero do beneficio
                                               ,pr_nrrecben => vr_tab_demonst(vr_index).nrrecben  --Numero do beneficiario
                                               ,pr_dtdcompe => vr_tab_demonst(vr_index).dtdcompe  --Data de Competencia
                                               ,pr_nmbenefi => vr_tab_demonst(vr_index).nmbenefi  --Nome beneficiario
                                               ,pr_dtprdini => vr_tab_demonst(vr_index).dtiniprd  --Periodo Inicial
                                               ,pr_dtprdfin => vr_tab_demonst(vr_index).dtfinprd  --Periodo Final
                                               ,pr_vlrbruto => vr_tab_demonst(vr_index).vlrbruto  --Valor Bruto
                                               ,pr_vlrdscto => vr_tab_demonst(vr_index).vldescto  --Valor Desconto
                                               ,pr_vlrliqui => vr_tab_demonst(vr_index).vlliquid  --Valor Liquido
                                               ,pr_dscmensa => vr_tab_demonst(vr_index).dscdamsg  --Descricao Mensagem
                                               ,pr_dsiduser => pr_dsiduser       --Descricao Identificador Usuario
                                               ,pr_tab_rubrica => vr_tab_rubrica --Tabela de Rubricas
                                               ,pr_nmarqimp => vr_nmarqimp       --Nome Arquivo Impressao
                                               ,pr_nmarqpdf => vr_nmarqpdf       --Nome do Arquivo pdf
                                               ,pr_des_reto => vr_des_reto       --Saida OK/NOK
                                               ,pr_tab_erro => vr_tab_erro);     --Tabela Erros
                                          
            --Se Ocorreu erro
            IF vr_des_reto = 'NOK' THEN
              
              --Se nao tem erro na temp-table
              IF vr_tab_erro.COUNT > 0 THEN
                vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE  
                vr_dscritic:= 'Nao foi possivel gerar o arquivo de demonstrativo.';
              END IF;  
              
              --Levantar Excecao
              RAISE vr_exc_saida;
              
            ELSE
              -- Criar cabeçalho do XML
              pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

              -- Insere as tags dos campos da PLTABLE de aplicações
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqimp', pr_tag_cont => vr_nmarqimp, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarqpdf, pr_des_erro => vr_dscritic);
	  
            END IF;                                 
          
            --Sai fora do loop pois já gerou o demonstrativo com todas as rúbricas do NB consultado
            EXIT;
          
          END IF;
          
          --Proximo registro
          vr_index:= vr_tab_demonst.NEXT(vr_index);
          
        END LOOP;                                 
        
        --Retornar OK
        vr_retornvl:= 'OK'; 
        
      EXCEPTION
        WHEN vr_exc_saida THEN 
          vr_retornvl:= 'NOK';
      END;  
      
      --Eliminar arquivos requisicao
      inss0001.pc_elimina_arquivos_requis (pr_cdcooper => vr_cdcooper      --Codigo Cooperativa
                                          ,pr_cdprogra => vr_nmdatela      --Nome do Programa
                                          ,pr_msgenvio => vr_msgenvio      --Mensagem Envio
                                          ,pr_msgreceb => vr_msgreceb      --Mensagem Recebimento
                                          ,pr_movarqto => vr_movarqto      --Nome Arquivo mover
                                          ,pr_nmarqlog => vr_nmarqlog      --Nome Arquivo LOG
                                          ,pr_des_reto => vr_des_reto      --Retorno OK/NOK 
                                          ,pr_dscritic => vr_dscritic2);    --Descricao Erro

      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        --Atribuir mensagem erro
        vr_dscritic:= vr_dscritic2;
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;     
      
		  --Incluir nome do módulo logado - Chamado 664301
      --Seta novamente esta rotina porque foi alterado dentro da pc_elimina_arquivos_requis
			GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_solicita_demonstrativo');            
      
      --Se saiu com erro
      IF vr_retornvl = 'NOK' THEN
        
        --Se nao possui mensagem de erro
        IF vr_cdcritic = 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= 'Nao foi possivel gerar o demonstrativo.';
        END IF;
          
        --Verificar se possui somente código erro
        IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Gravar Linha Log
        inss0001.pc_retorna_linha_log(pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                     ,pr_cdprogra => vr_nmdatela   --Nome do Programa
                                     ,pr_dtmvtolt => vr_dtmvtolt   --Data Movimento
                                     ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                     ,pr_nrcpfcgc => pr_nrcpfcgc   --Numero Cpf
                                     ,pr_nrrecben => pr_nrrecben   --Numero Recebimento Beneficio
                                     ,pr_nmmetodo => 'Demonstrativo' --Nome do metodo
                                     ,pr_cdderror => vr_cdcritic   --Codigo Erro
                                     ,pr_dsderror => vr_dscritic   --Descricao Erro
                                     ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo LOG
                                     ,pr_cdtipofalha => 1          --Tipo 4 gera mensagem
                                     ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                     ,pr_dscritic => vr_dscritic2); --Descricao erro
                                     
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          vr_dscritic:= vr_dscritic2;          
        END IF;                              
                                     
        --Gera exceção
        RAISE vr_exc_erro;
                                             
      END IF;
      
      --Retorno
      pr_des_erro:= vr_retornvl;    

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= vr_retornvl;
        
        --Monta mensagem de erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
                             
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        pr_cdcritic:= 0;
        -- Chamar rotina de gravação de erro
        pr_dscritic := 'Erro na inss0001.pc_solicita_demonstrativo --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_solicita_demonstrativo;

  /* Procedure para Solicitar Comprovacao de Vida */
  PROCEDURE pc_solic_comprovacao_vida  (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                       ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                       ,pr_nrdconta IN INTEGER                 --Numero da Conta
                                       ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                       ,pr_nmextttl IN VARCHAR2                --Nome Titular
                                       ,pr_idseqttl IN INTEGER                 --Sequencial do Titular
                                       ,pr_cdorgins IN INTEGER                 --Codigo Orgao Pagamento
                                       ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio                                                                            
                                       ,pr_tpnrbene IN VARCHAR2                --Tipo Beneficio
                                       ,pr_cdagepac IN INTEGER                 --Codigo Agencia 
                                       ,pr_idbenefi IN INTEGER                 --Identificador Beneficio
                                       ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                       ,pr_respreno IN VARCHAR2                --Responsavel Renovacao
                                       ,pr_nmprocur IN VARCHAR2                --Nome Procurador
                                       ,pr_nrdocpro IN VARCHAR2                --Numero Documento Procurador
                                       ,pr_dtvalprc IN VARCHAR2                --Data Validade Procurador
                                       ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                       ,pr_flgerlog IN INTEGER                 --Escrever Erro no Log
                                       ,pr_temsenha IN VARCHAR                 --Verifica se tem senha da internet ativa
                                       ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solic_comprovacao_vida             Antigo: procedures/b1wgen0091.p/solicita_comprovacao_vida
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Fevereiro/2015                           Ultima atualizacao: 21/06/2016
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para solicitar a Comprovacao de Vida 
  
    Alterações : 25/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
    
                 31/03/2015 - Alterado o nome do arquivo de envio/recebimento
                              (Adriano).
    
                 10/04/2015 - Ajuste para retornar erro corretamente (Adriano).            
    
                 22/09/2015 - Adicionado validação dos campos e alterado a nomenclatura do arquivo.
                              (Douglas - Chamado 314031)
                              
                 25/11/2015 - Adicionada verificacao para gerar contrato somente
                              quando o beneficiario nao tiver senha de internet 
                              cadastrada. Projeto 255 (Lombardi).
                              
                 21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                              (Adriano - SD 473539).
                              
                 23/06/2016 - Incluir nome do módulo logado - (Ana - Envolti - Chamado 664301)
  ---------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    --Tabela de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
    vr_dscritic2 VARCHAR2(4000); 
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);	
    vr_des_log  VARCHAR2(1000);
    
    --Variaveis Locais
    vr_dstime    VARCHAR2(100);
    vr_msgenvio  VARCHAR2(32767);
    vr_msgreceb  VARCHAR2(32767);
    vr_movarqto  VARCHAR2(32767);
    vr_nmarqlog  VARCHAR2(32767);
    vr_nmdireto  VARCHAR2(1000);
    vr_dstexto   VARCHAR2(32767);
    vr_dstransa  VARCHAR2(1000);
    vr_dsorigem  VARCHAR2(1000);    
    vr_des_reto  VARCHAR2(3);
    vr_retornvl  VARCHAR2(3):= 'NOK';
    vr_nrdrowid  ROWID;
    vr_dtmvtolt  DATE;
    vr_dtvalprc  DATE;
    vr_nmarqimp VARCHAR2(100);
    vr_nmarqpdf VARCHAR2(100) := '';
    vr_auxconta PLS_INTEGER:= 0;
    vr_auxnmarq VARCHAR2(30);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;                                       
    vr_exc_saida EXCEPTION; 
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= NULL;
      vr_msgenvio:= NULL;
      vr_msgreceb:= NULL;
      vr_movarqto:= NULL;
      vr_nmarqlog:= NULL;
      vr_dstime:=   NULL;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
      
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_solic_comprovacao_vida');    
      
      BEGIN                                                  
        --Pega a data de movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/YYYY'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      BEGIN                                                  
        --Pega a data de validade do procurador e converte para "DATE"
        vr_dtvalprc:= to_date(pr_dtvalprc,'DD/MM/YYYY'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => vr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Gera exceção
        RAISE vr_exc_erro;
       
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
  
      --Verificar parametros
      IF nvl(pr_nrdconta,0) = 0 THEN
        
        --Monta mensagem de critica
        vr_cdcritic:= 9;  
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_nrcpfcgc,0) = 0 THEN
        
        --Monta mensagem de critica
        vr_dscritic:= 'CPF invalido.';
        
        --Levantar Excecao        
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_nmextttl) IS NULL THEN
        
        --Monta mensagem de critica
        vr_dscritic:= 'Nome de beneficiario invalido.';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_cdorgins,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Orgao pagador invalido.';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF NVL(pr_nrrecben,0) = 0   OR 
            LENGTH(pr_nrrecben) > 10 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'NB invalido.';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_tpnrbene) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Tipo do NB invalido.';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_cdagepac,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Unidade de atendimento invalida.';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_idbenefi,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'ID do beneficiario invalido.';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_cdagesic,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Agencia SICREDI invalida.';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF pr_respreno NOT IN ('PROCURADOR','BENEFICIARIO') THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Responsavel pela renovacao invalido.';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF pr_respreno = 'PROCURADOR' THEN  
        
        --Se o nome estiver nulo
        IF TRIM(pr_nmprocur) IS NULL THEN
          
          --Monta mensagem de critica
          vr_dscritic:= 'Nome do procurador invalido.';
          
          --Levantar Excecao
          RAISE vr_exc_erro;
          
        ELSIF TRIM(pr_nrdocpro) IS NULL THEN
          
          --Monta mensagem de critica
          vr_dscritic:= 'CPF do procurador invalido.';
          
          --Levantar Excecao
          RAISE vr_exc_erro;
          
        ELSIF TRIM(vr_dtvalprc) IS NULL THEN
          
          --Monta mensagem de critica
          vr_dscritic:= 'Validade do procurador invalida.';
          
          --Levantar Excecao
          RAISE vr_exc_erro;
          
        ELSIF TRIM(vr_dtvalprc) IS NOT NULL AND TRUNC(vr_dtvalprc) < TRUNC(SYSDATE) THEN
          
          --Monta mensagem de critica
          vr_dscritic:= 'Validade do procurador expirada.';
          
          --Levantar Excecao
          RAISE vr_exc_erro;
          
        END IF;  
      END IF;  

      --Buscar Diretorio Padrao da Cooperativa
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => null);
                                          
      --Determinar Nomes do Arquivo de Log
      vr_nmarqlog:= 'SICREDI_Soap_LogErros';

      --Buscar o Horario
      vr_dstime:= lpad(gene0002.fn_busca_time,5,'0');
      
      -- Complemento para o Nome do arquivo
      vr_auxnmarq:= LPAD(pr_nrrecben,11,'0')||'.'||
                    vr_dstime ||
                    LPAD(TRUNC(DBMS_RANDOM.Value(0,9999)),4,'0');
      
      --Determinar Nomes do Arquivo de Envio
      vr_msgenvio:= vr_nmdireto||'/arq/INSS.SOAP.ECMPVID.'||vr_auxnmarq;
                    
      --Determinar Nome do Arquivo de Recebimento    
      vr_msgreceb:= vr_nmdireto||'/arq/INSS.SOAP.RCMPVID.'||vr_auxnmarq;
                    
      --Determinar Nome Arquivo movido              
      vr_movarqto:= vr_nmdireto||'/salvar/inss';

      --Bloco ComprovaVida
      BEGIN
        
        --Gerar cabecalho XML
        inss0001.pc_gera_cabecalho_soap (pr_idservic => 3   /* idservic */ 
                                        ,pr_nmmetodo => 'prov:InEfetivarProvaDeVida' --Nome Metodo
                                        ,pr_username => 'app_cecred_client' --Username
                                        ,pr_password => fn_senha_sicredi    --Senha
                                        ,pr_dstexto  => vr_dstexto          --Texto do Arquivo de Dados
                                        ,pr_des_reto => vr_des_reto         --Retorno OK/NOK
                                        ,pr_dscritic => vr_dscritic);       --Descricao da Critica
                                       
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          RAISE vr_exc_saida;
        END IF;

        /*Monta as tags de envio
        OBS.: O valor das tags deve respeitar a formatacao presente na
              base do SICREDI do contrario, a operacao nao sera
              realizada. */
              
        --Montar o XML      
        vr_dstexto:= vr_dstexto||
           '<prov:Beneficiario NumeroDocumento="'||lpad(pr_nrcpfcgc,11,'0')||'" v11:ID="'||pr_idbenefi||'">'||
				      '<v14:Identificadores>'||
            		 '<v14:IdentificadorBeneficiario>'||
            		    '<v14:Codigo>'||lpad(pr_nrrecben,10,'0')||'</v14:Codigo>'||
			              '<v14:TipoCodigo>'||pr_tpnrbene||'</v14:TipoCodigo>'||
      		       '</v14:IdentificadorBeneficiario>'||
			        '</v14:Identificadores>'||
      		    '<v14:OrgaoPagador>'||
			   	       '<v14:NumeroOrgaoPagador>'||pr_cdorgins||'</v14:NumeroOrgaoPagador>'||
   				    '</v14:OrgaoPagador>'||
				      '<v14:ContaCorrente>'||
					       '<v17:codigoAgencia>'||pr_cdagesic||'</v17:codigoAgencia>'||
					       '<v17:numero>'||SUBSTR(pr_nrdconta,1,LENGTH(pr_nrdconta)-1)||'</v17:numero>'||
					       '<v17:digitoVerificador>'||SUBSTR(pr_nrdconta,LENGTH(pr_nrdconta),1)||'</v17:digitoVerificador>'||
			        '</v14:ContaCorrente>'||
			     '</prov:Beneficiario>'||
     		   '<v15:UnidadeAtendimento>'||
				      '<v15:Cooperativa>'||
					        '<v15:CodigoCooperativa>'||pr_cdagesic||'</v15:CodigoCooperativa>'||
				      '</v15:Cooperativa>'||
			        '<v15:NumeroUnidadeAtendimento>2</v15:NumeroUnidadeAtendimento>'||
			     '</v15:UnidadeAtendimento>'||
			     '<prov:ResponsavelRenovacao>'||pr_respreno||'</prov:ResponsavelRenovacao>'||
		       '</prov:InEfetivarProvaDeVida>'||
           '</soapenv:Body></soapenv:Envelope>';
           
        --Efetuar Requisicao Soap
        inss0001.pc_efetua_requisicao_soap (pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                           ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                           ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                           ,pr_idservic => 2             --Identificador Servico
                                           ,pr_dsservic => 'Comprova Vida'     --Descricao Servico
                                           ,pr_nmmetodo => 'OutEfetivarProvaDeVida' --Nome Método
                                           ,pr_dstexto  => vr_dstexto    --Texto com a msg XML
                                           ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                           ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                           ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                           ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo Log
                                           ,pr_nmdatela => vr_nmdatela   --Nome da Tela
                                           ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                           ,pr_dscritic => vr_dscritic); --Descrição Erros
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
          
        --Verifica Falha no Pacote
        inss0001.pc_obtem_fault_packet (pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                       ,pr_nmdatela => vr_nmdatela   --Nome da Tela
                                       ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                       ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                       ,pr_dsderror => 'SOAP-ENV:-950' --Descricao Servico
                                       ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                       ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                       ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                       ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo log
                                       ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                       ,pr_dscritic => vr_dscritic); --Mensagem Erro
        
        --Se Ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;                                 

        IF UPPER(pr_temsenha) = 'FALSE' THEN
        --Gerar Termo Comprovacao de Vida
        inss0001.pc_gera_termo_cpvcao_vida (pr_cdcooper => vr_cdcooper    --Cooperativa
                                           ,pr_cdoperad => vr_cdoperad    --Operador
                                           ,pr_nrdcaixa => vr_nrdcaixa    --Numero Caixa
                                           ,pr_dtmvtolt => vr_dtmvtolt    --Data Movimento
                                           ,pr_nmdatela => vr_nmdatela    --Programa chamador                                      
                                           ,pr_cdagenci => vr_cdagenci    --Codigo Agencia
                                           ,pr_idorigem => vr_idorigem    --Origem Processamento
                                           ,pr_nrrecben => pr_nrrecben    --Numero Recebimento Beneficiario
                                           ,pr_nrcpfcgc => pr_nrcpfcgc    --Numero Cpf/Cgc
                                           ,pr_nmextttl => pr_nmextttl    --Nome Extrato Titular
                                           ,pr_hrtransa => to_char(SYSDATE,'HH24:MI:SS') --Hora Transacao
                                           ,pr_respreno => pr_respreno    --Tipo
                                           ,pr_nmprocur => pr_nmprocur    --Nome Procurador
                                           ,pr_nrdocpro => pr_nrdocpro    --Numero Documento Procurador
                                           ,pr_dtvalprc => vr_dtvalprc    --Data Validade Procuracao
                                           ,pr_dsiduser => pr_dsiduser    --Descricao Identificador Usuario
                                           ,pr_nmarqimp => vr_nmarqimp    --Nome Arquivo Impressao
                                           ,pr_nmarqpdf => vr_nmarqpdf    --Nome do Arquivo pdf
                                           ,pr_des_reto => vr_des_reto    --Saida OK/NOK
                                           ,pr_tab_erro => vr_tab_erro);  --Tabela Erros                                      
        END IF;
        --Se Ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          
          --Se nao tem erro na temp-table
          IF vr_tab_erro.COUNT > 0 THEN
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE  
            vr_dscritic:= 'Nao foi possivel gerar o termo de comprovacao de vida.';
          END IF;  
          
          --Levantar Excecao
          RAISE vr_exc_saida;
          
        ELSE
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

          -- Insere as tags dos campos da PLTABLE de aplicações
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqimp', pr_tag_cont => vr_nmarqimp, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarqpdf, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'msgretor', pr_tag_cont => 'Comprovacao efetuada com sucesso.', pr_des_erro => vr_dscritic);	  
        END IF;                                 
        
        --Retornar OK
        vr_retornvl:= 'OK'; 
                                           
      EXCEPTION
        WHEN vr_exc_saida THEN 
          vr_retornvl:= 'NOK';
      END;  
      
      --Eliminar arquivos requisicao
      inss0001.pc_elimina_arquivos_requis (pr_cdcooper => vr_cdcooper      --Codigo Cooperativa
                                          ,pr_cdprogra => vr_nmdatela      --Nome do Programa
                                          ,pr_msgenvio => vr_msgenvio      --Mensagem Envio
                                          ,pr_msgreceb => vr_msgreceb      --Mensagem Recebimento
                                          ,pr_movarqto => vr_movarqto      --Nome Arquivo mover
                                          ,pr_nmarqlog => vr_nmarqlog      --Nome Arquivo LOG
                                          ,pr_des_reto => vr_des_reto      --Retorno OK/NOK 
                                          ,pr_dscritic => vr_dscritic2);    --Descricao Erro
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        vr_dscritic:= vr_dscritic2;
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;     

		  --Incluir nome do módulo logado - Chamado 664301
      --Seta novamente esta rotina porque foi alterado dentro da pc_elimina_arquivos_requis
			GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_solic_comprovacao_vida');

      BEGIN
        UPDATE tbinss_dcb
           SET dtvencpv = add_months(SYSDATE, 12)
         WHERE nrrecben = pr_nrrecben;
      EXCEPTION
        WHEN OTHERS THEN
          vr_retornvl := 'NOK';
          vr_dscritic := SQLERRM;        
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
      
      --Se deve escrever no log
      IF nvl(pr_flgerlog,0) = 1 THEN

        --Descricao da origem e Transacao
        vr_dsorigem:= gene0001.vr_vet_des_origens(vr_idorigem);
        vr_dstransa:= 'Comprovacao de vida.';

        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => CASE vr_retornvl WHEN 'OK' THEN 1 ELSE 0 END  
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
                                    
        -- Gera item de log com informacao nova
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'nrrecben'
                                 ,pr_dsdadant => null
                                 ,pr_dsdadatu => pr_nrdconta);
                                   
      END IF;  
      
      --Se saiu com erro
      IF vr_retornvl = 'NOK' THEN
        
        --Se nao possui mensagem de erro
        IF vr_cdcritic = 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= 'Nao foi possivel comprovar vida.';
        END IF;

        --Verificar se possui somente código erro
        IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        -- Gravar Linha Log
        inss0001.pc_retorna_linha_log(pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                     ,pr_cdprogra => vr_nmdatela   --Nome do Programa
                                     ,pr_dtmvtolt => vr_dtmvtolt   --Data Movimento
                                     ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                     ,pr_nrcpfcgc => pr_nrcpfcgc   --Numero Cpf
                                     ,pr_nrrecben => pr_nrrecben   --Numero Recebimento Beneficio
                                     ,pr_nmmetodo => 'Comprovacao de vida' --Nome do metodo
                                     ,pr_cdderror => vr_cdcritic   --Codigo Erro
                                     ,pr_dsderror => vr_dscritic   --Descricao Erro
                                     ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo LOG
                                     ,pr_cdtipofalha => 3          --Tipo 2 abre chamado
                                     ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                     ,pr_dscritic => vr_dscritic2); --Descricao erro
        
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          vr_dscritic:= vr_dscritic2;          
        END IF;
        
        --Gera exceção
        RAISE vr_exc_erro;
                             
      END IF;
      
      vr_des_log :=   
      'Conta: '    || gene0002.fn_mask(pr_nrdconta,'9999.999-9')  || ' | ' ||
      'Nome: '     || pr_nmextttl                         || ' | ' ||
      'NB: '       || to_char(pr_nrrecben)                || ' | ' ||
      'operador: ' || to_char(vr_cdoperad)                || ' | ' ||
      'Alteracao: Realizado a prova de vida.';
      
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 1
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || vr_nmdatela || ' --> ' || 
                                                    'ALERTA: ' || vr_des_log                               
                              ,pr_nmarqlog     => 'inss_historico.log'
                              ,pr_flfinmsg     => 'N'
                              ,pr_cdprograma   => vr_nmdatela
                              );
      
      --Retorno
      pr_des_erro:= vr_retornvl;    

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= vr_retornvl;
        
        --Monta mensagem de criticaq
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic; 
        
        -- Existe para satisfazer exigência da interface. 
       	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
                             
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        --Erro
        pr_cdcritic:= 0;
        
        -- Chamar rotina de gravação de erro
        pr_dscritic := 'Erro na inss0001.pc_solic_comprovacao_vida --> '|| SQLERRM;
        -- Existe para satisfazer exigência da interface. 
       	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                 '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_solic_comprovacao_vida;  
  
  /* Procedure para Solicitar Relatorio beneficios Rejeitados */
  PROCEDURE pc_relat_benef_rejeitados  (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                       ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                       ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_relat_benef_rejeitados             Antigo: procedures/b1wgen0091.p/relatorio_beneficios_rejeitados
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Fevereiro/2015                           Ultima atualizacao: 31/03/2015
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para gerar relatorio de beneficios rejeitados 
  
    Alterações : 25/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
    
                 31/03/2015 - Ajuste para devolver corretamente o nome do arquivo pdf
                              (Adriano).
    
                
  ---------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_des_reto VARCHAR2(3);           
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
    
    --Variaveis Locais
    vr_nmdireto  VARCHAR2(1000);
    vr_nmarquiv  VARCHAR2(1000);
    vr_nmarqpdf  VARCHAR2(1000);
    vr_comando   VARCHAR2(1000);
    vr_typ_saida VARCHAR2(3);
    vr_auxconta  PLS_INTEGER:= 0;
    
    --tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;                                       
    
    BEGIN
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= NULL;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
       
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_relat_benef_rejeitados');    
             
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => vr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
       RAISE vr_exc_erro;
       
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
  
      --Buscar Diretorio Padrao da Cooperativa
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => 'rl');
                                       
      --Nome do Arquivo
      vr_nmarquiv:= vr_nmdireto||'/'||'crrl657.lst';
         
      --Se nao existir arquivo no diretorio
      IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_nmarquiv) THEN
        --Erro
        vr_dscritic:= 'Nao ha arquivo de beneficios rejeitados.';
        RAISE vr_exc_erro;
      END IF;  
       
      --Nome do Arquivo PDF
      vr_nmarqpdf:= REPLACE(vr_nmarquiv,'.lst','.pdf');
      
      /* Gerar o PDF */
      gene0002.pc_gera_pdf_impressao(pr_cdcooper => vr_cdcooper     --> Cooperativa conectada
                                    ,pr_nmarqimp => vr_nmarquiv     --> Arquivo a ser convertido para pDf
                                    ,pr_nmarqpdf => vr_nmarqpdf     --> Arquivo PDF  a ser gerado                                 
                                    ,pr_des_erro => vr_dscritic);   --> Saída com erro
      --Se Ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;                             
      
      --Efetuar Copia do PDF
      gene0002.pc_efetua_copia_pdf (pr_cdcooper => vr_cdcooper     --> Cooperativa conectada
                                   ,pr_cdagenci => vr_cdagenci     --> Codigo da agencia para erros
                                   ,pr_nrdcaixa => vr_nrdcaixa     --> Codigo do caixa para erros
                                   ,pr_nmarqpdf => vr_nmarqpdf     --> Arquivo PDF  a ser gerado                                 
                                   ,pr_des_reto => vr_des_reto     --> Saída com erro
                                   ,pr_tab_erro => vr_tab_erro);   --> tabela de erros 
                                   
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        
        --Se possui erro
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Nao foi possivel efetuar a copia do relatorio.';
        END IF;
        
        --Levantar Excecao  
        RAISE vr_exc_erro;
        
      END IF; 
        
      --Se Existir arquivo pdf  
      IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmarqpdf) THEN
        
        --Remover arquivo
        vr_comando:= 'rm '||vr_nmarqpdf||'* 2>/dev/null';
        
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
                          
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          
          --Monta mensagem de critica
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
          
          -- retornando ao programa chamador
          RAISE vr_exc_erro;
          
        END IF;
        
      END IF;
        
      /* Nome do PDF para devolver como parametro */
      vr_nmarqpdf:= SUBSTR(vr_nmarqpdf,instr(vr_nmarqpdf,'/',-1)+1);
      
      --Se ocorreu erro
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN                                   
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      -- Insere as tags dos campos da PLTABLE 
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarqpdf, pr_des_erro => vr_dscritic);      --Retorno OK
    
      --Retorno OK
      pr_des_erro:= 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Monta mensagem de erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                      
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        --Erro
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro na inss0001.pc_relat_benef_rejeitados --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     

  END pc_relat_benef_rejeitados;  

  /* Procedure para Solicitar Troca orgao Pagador e/ou Conta Corrente entre Cooperativas */
  PROCEDURE pc_solic_troca_op_cc_coop (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                      ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                      ,pr_cdcopant IN INTEGER                 --Codigo Cooperativa Anterior
                                      ,pr_cdorgins IN INTEGER                 --Codigo Orgao Pagador
                                      ,pr_orgpgant IN INTEGER                 --Codigo Orgao Pagador Anterior
                                      ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                      ,pr_tpnrbene IN VARCHAR2                --Tipo Beneficio
                                      ,pr_tpdpagto IN VARCHAR2                --Tipo de Pagamento
                                      ,pr_dscsitua IN VARCHAR2                --Descricao da Situacao
                                      ,pr_nrdconta IN INTEGER                 --Numero da Conta
                                      ,pr_nrctaant IN INTEGER                 --Numero da Conta Anterior                                      
                                      ,pr_cdagepac IN INTEGER                 --Codigo Agencia 
                                      ,pr_idbenefi IN INTEGER                 --Identificador do Beneficio
                                      ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                      ,pr_nrcpfant IN NUMBER                  --Numero CPF/CNPJ Anterior
                                      ,pr_idseqttl IN INTEGER                 --Sequencial Titular
                                      ,pr_nmbairro IN VARCHAR2                --Nome do Bairro
                                      ,pr_nrcepend IN INTEGER                 --Numero CEP
                                      ,pr_dsendere IN VARCHAR2                --Descricao Endereco Residencial
                                      ,pr_nrendere IN INTEGER                 --Numero Endereco
                                      ,pr_nmcidade IN VARCHAR2                --Nome Cidade
                                      ,pr_cdufende IN VARCHAR2                --Codigo UF Titular
                                      ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                      ,pr_nmbenefi IN VARCHAR2                --Nome Beneficiario
                                      ,pr_dtcompvi IN VARCHAR2                --Data Comprovacao Vida
                                      ,pr_nrdddtfc IN INTEGER                 --Numero DDD
                                      ,pr_nrtelefo IN INTEGER                 --Numero Telefone
                                      ,pr_cdsexotl IN INTEGER                 --Sexo
                                      ,pr_nomdamae IN VARCHAR2                --Nome Da Mae
                                      ,pr_flgerlog IN INTEGER                 --Escrever Erro no Log (0=nao, 1=sim)
                                      ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                      ,pr_temsenha IN VARCHAR                 --Verifica se tem senha da internet ativa
                                      ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                      ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solic_troca_op_cc_coop             Antigo: procedures/b1wgen0091.p/solicita_troca_op_conta_corrente_entre_coop
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Fevereiro/2015                           Ultima atualizacao: 21/06/2016
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para Solicitar Troca orgao Pagador e/ou Conta Corrente entre Cooperativas 
  
    Alterações : 26/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
    
                 27/03/2015 - Alterado o nome do arquivo de envio/recebimento
                             (Adriano).
    
                 10/04/2015 - Ajuste para retorno o erro corretamente ( Adriano).       
                 
                 01/06/2015 - Ajuste para obrigar o envio do endereço (Adriano).   
    
                 22/09/2015 - Adicionado validação dos campos e alterado a nomenclatura do arquivo.
                              (Douglas - Chamado 314031)
                              
                 25/11/2015 - Adicionada verificacao para gerar contrato somente
                              quando o beneficiario nao tiver senha de internet 
                              cadastrada. Projeto 255 (Lombardi).
                              
                 21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                              (Adriano - SD 473539).
                                          
  ---------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    --Tabela de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_des_log  VARCHAR2(1000);
    vr_nmcopant VARCHAR2(50);
    vr_nmcooper VARCHAR2(50);
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
    vr_dscritic2 VARCHAR2(4000);
    
    --Variaveis Locais
    vr_dstime    VARCHAR2(100);
    vr_msgenvio  VARCHAR2(32767);
    vr_msgreceb  VARCHAR2(32767);
    vr_movarqto  VARCHAR2(32767);
    vr_nmarqlog  VARCHAR2(32767);
    vr_nmdireto  VARCHAR2(1000);
    vr_des_reto  VARCHAR2(3);
    vr_retornvl  VARCHAR2(3):= 'NOK';
    vr_dstexto   VARCHAR2(32767);
    vr_dsendere  VARCHAR2(1000);
    vr_dstransa  VARCHAR2(1000);
    vr_dsorigem  VARCHAR2(1000);
    vr_nrdrowid  ROWID;
    vr_dtmvtolt  DATE;
    vr_nmarqimp VARCHAR2(100);
    vr_nmarqpdf VARCHAR2(100);
    vr_auxconta PLS_INTEGER:= 0;
    vr_auxnmarq VARCHAR2(30);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;                                       
    vr_exc_saida EXCEPTION; 
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      vr_msgenvio:= null;
      vr_msgreceb:= null;
      vr_movarqto:= null;
      vr_nmarqlog:= null;
      vr_dstime:=   null;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
        
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_solic_troca_op_cc_coop');                
        
      BEGIN                                                  
        --Pega a data de movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/YYYY'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => vr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
       RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
  
      vr_nmcooper := rw_crapcop.nmrescop;
      
      -- Pegar nome da cooperativa anterior
      OPEN cr_crapcop (pr_cdcooper => pr_cdcopant);
      FETCH cr_crapcop INTO rw_crapcop;
      IF cr_crapcop%FOUND THEN
        vr_nmcopant := rw_crapcop.nmrescop;
      END IF;
  
      --Verificar parametros
      IF nvl(pr_nrdconta,0) = 0 OR nvl(pr_nrctaant,0) = 0 THEN
        
        --Monta mensagem de critica
        vr_cdcritic:= 9;  
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_nrdconta,0) = nvl(pr_nrctaant,0) THEN

        --Monta mensagem de critica
        vr_dscritic:= 'Beneficio ja existe na conta informada.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_cdcopant,0) = nvl(vr_cdcooper,0) THEN
        
        --Monta mensagem de crtiica
        vr_dscritic:= 'Para alteracao entre mesma cooperativa utilize '||
                      'a rotina Troca Conta da opcao (C)onsulta.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF NVL(pr_nrrecben,0) = 0   OR
            LENGTH(pr_nrrecben) > 10 THEN
        vr_dscritic:= 'NB nao foi informado.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSIF TRIM(pr_tpnrbene) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Tido do beneficio invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_nomdamae) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Filiacao invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_cdagepac,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Unidade de atendimento invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_tpdpagto) IS NULL THEN  
        
        --Monta mensagem de erro
        vr_dscritic:= 'Tipo de pagamento invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_dscsitua) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Situacao invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_cdagesic,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Agencia SICREDI invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_nrcpfcgc,0) = 0 THEN
        
        --Monta mensagem de critica
        vr_dscritic:= 'CPF invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_idbenefi,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Codigo do beneficiario invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_cdufende) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'UF invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_nrcpfant,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'CPF antigo invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_nrcpfcgc,0) <> nvl(pr_nrcpfant,0) THEN 
        
        --Monta mensagem de critica 
        vr_dscritic:= 'Titularidade invalida com a conta/dv destino.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_nmcidade) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Cidade invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_dsendere) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Endereco invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
                
      END IF;  
        
      --Buscar Diretorio Padrao da Cooperativa
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => null);
                                          
      --Determinar Nomes do Arquivo de Log
      vr_nmarqlog:= 'SICREDI_Soap_LogErros';

      --Buscar o Horario
      vr_dstime:= lpad(gene0002.fn_busca_time,5,'0');
      
      -- Complemento para o Nome do arquivo
      vr_auxnmarq:= LPAD(pr_nrrecben,11,'0')||'.'||
                    vr_dstime ||
                    LPAD(TRUNC(DBMS_RANDOM.Value(0,9999)),4,'0');
                    
      --Determinar Nomes do Arquivo de Envio
      vr_msgenvio:= vr_nmdireto||'/arq/INSS.SOAP.EALTECO.'||vr_auxnmarq;
                    
      --Determinar Nome do Arquivo de Recebimento    
      vr_msgreceb:= vr_nmdireto||'/arq/INSS.SOAP.RALTECO.'||vr_auxnmarq;
                    
      --Determinar Nome Arquivo movido              
      vr_movarqto:= vr_nmdireto||'/salvar/inss';
      
      --Bloco Troca
      BEGIN
        
        --Gerar cabecalho XML
        inss0001.pc_gera_cabecalho_soap (pr_idservic => 2   /* idservic */ 
                                        ,pr_nmmetodo => 'ben:InAlterarBeneficiarioINSS' --Nome Metodo
                                        ,pr_username => 'app_cecred_client' --Username
                                        ,pr_password => fn_senha_sicredi    --Senha
                                        ,pr_dstexto  => vr_dstexto          --Texto do Arquivo de Dados
                                        ,pr_des_reto => vr_des_reto         --Retorno OK/NOK
                                        ,pr_dscritic => vr_dscritic);       --Descricao da Critica
                                       
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          RAISE vr_exc_saida;
        END IF;

        /*Monta as tags de envio
        OBS.: O valor das tags deve respeitar a formatacao presente na
              base do SICREDI do contrario, a operacao nao sera
              realizada. */
              
        --Montar o logradouro
        IF nvl(pr_nrendere,0) > 0 THEN
          vr_dsendere:= SUBSTR(pr_dsendere,1,30)||','||pr_nrendere;
        ELSE
          vr_dsendere:= SUBSTR(pr_dsendere,1,30);
        END IF;
            
         --Montar o XML      
        vr_dstexto:= vr_dstexto||
            '<ben:Beneficiario NumeroDocumento="'||lpad(pr_nrcpfcgc,11,'0')||'" v1:ID="'||pr_idbenefi||'">'||
               '<v1:Enderecos>'||
                  '<v12:Endereco>'||
                     '<v12:Logradouro>'||
                        '<v12:Nome>'||vr_dsendere||'</v12:Nome>'||
                     '</v12:Logradouro>'||
                     '<v12:Bairro>'||SUBSTR(pr_nmbairro,1,17)||'</v12:Bairro>'||
                        '<v12:Cidade>'||
                           '<v12:Nome>'||pr_nmcidade||'</v12:Nome>'||            
                           '<v12:Estado>'||
                              '<v12:Sigla>'||pr_cdufende||'</v12:Sigla>'||            
                           '</v12:Estado>'|| 
                        '</v12:Cidade>'||            
                     '<v12:CEP>'||pr_nrcepend||'</v12:CEP>'||           
                  '</v12:Endereco>'||
               '</v1:Enderecos>'||
               '<v1:Nome>'||SUBSTR(pr_nmbenefi,1,30)||'</v1:Nome>'||
               '<v1:Filiacao>'||
                  '<v1:NomeMae>'||SUBSTR(pr_nomdamae,1,30)||'</v1:NomeMae>'||            
               '</v1:Filiacao>'||
               '<v1:Sexo>'||CASE pr_cdsexotl WHEN 1 THEN 'MASCULINO' ELSE 'FEMININO' END||'</v1:Sexo>'||
               '<v1:Contatos>'||
                    '<v1:Telefones>'||
                       '<v13:Telefone>'||                       
                          --Somente vamos enviar o telefone se ele for menor que 10 digitos.
                          '<v13:DDD>'|| CASE WHEN LENGTH(pr_nrtelefo) < 10 THEN pr_nrdddtfc ELSE '' END ||'</v13:DDD>'||
                          '<v13:Numero>'|| CASE WHEN LENGTH(pr_nrtelefo) < 10 THEN pr_nrtelefo ELSE '' END ||'</v13:Numero>'||
                       '</v13:Telefone>'||                        
                    '</v1:Telefones>'||                        
               '</v1:Contatos>'||           
               '<v14:Identificadores>'||
                  '<v14:IdentificadorBeneficiario>'||
                     '<v14:Codigo>'||lpad(pr_nrrecben,10,'0')||'</v14:Codigo>'||                        
                     '<v14:TipoCodigo>'||pr_tpnrbene||'</v14:TipoCodigo>'||                                    
                  '</v14:IdentificadorBeneficiario>'||                        
               '</v14:Identificadores>'||
               '<v14:OrgaoPagador>'||
                  '<v14:NumeroOrgaoPagador>'||pr_cdorgins||'</v14:NumeroOrgaoPagador>'||                        
                  '<v14:Entidade>'||
                     '<v15:NumeroUnidadeAtendimento>2</v15:NumeroUnidadeAtendimento>'||                                    
                  '</v14:Entidade>'||                        
               '</v14:OrgaoPagador>'||
               '<v14:Beneficio>'||
                  '<v16:TipoPagamento>'||pr_tpdpagto||'</v16:TipoPagamento>'||                        
                  '<v16:Situacao>'||pr_dscsitua||'</v16:Situacao>'||                        
               '</v14:Beneficio>'||
               '<v14:Situacao>'||pr_dscsitua||'</v14:Situacao>'||
               '<v14:ContaCorrente>'||
                  '<v17:codigoAgencia>'||pr_cdagesic||'</v17:codigoAgencia>'||                        
                  '<v17:numero>'||SUBSTR(pr_nrdconta,1,LENGTH(pr_nrdconta)-1)||'</v17:numero>'||                        
                  '<v17:digitoVerificador>'||SUBSTR(pr_nrdconta,LENGTH(pr_nrdconta),1)||'</v17:digitoVerificador>'||                                    
               '</v14:ContaCorrente>'||
            '</ben:Beneficiario>'||
            '</ben:InAlterarBeneficiarioINSS>'||
            '</soapenv:Body></soapenv:Envelope>';                      
           
        --Efetuar Requisicao Soap
        inss0001.pc_efetua_requisicao_soap (pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                           ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                           ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                           ,pr_idservic => 1             --Identificador Servico
                                           ,pr_dsservic => 'Alterar'     --Descricao Servico
                                           ,pr_nmmetodo => 'OutAlterarBeneficiarioINSS' --Nome Método
                                           ,pr_dstexto  => vr_dstexto    --Texto com a msg XML
                                           ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                           ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                           ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                           ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo Log
                                           ,pr_nmdatela => vr_nmdatela   --Nome da Tela
                                           ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                           ,pr_dscritic => vr_dscritic); --Descrição Erros
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
          
        --Verifica Falha no Pacote
        inss0001.pc_obtem_fault_packet (pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                       ,pr_nmdatela => vr_nmdatela   --Nome da Tela
                                       ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                       ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                       ,pr_dsderror => 'SOAP-ENV:-950' --Descricao Servico
                                       ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                       ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                       ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                       ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo log
                                       ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                       ,pr_dscritic => vr_dscritic); --Mensagem Erro
        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          vr_retornvl:= vr_des_reto;
          RAISE vr_exc_saida;
        END IF;                                
        
        --Retorno OK  
        vr_retornvl:= 'OK';          
                                
      EXCEPTION
        WHEN vr_exc_saida THEN 
          vr_retornvl:= 'NOK';
      END;  
      
      --Eliminar arquivos requisicao
      inss0001.pc_elimina_arquivos_requis (pr_cdcooper => vr_cdcooper      --Codigo Cooperativa
                                          ,pr_cdprogra => vr_nmdatela      --Nome do Programa
                                          ,pr_msgenvio => vr_msgenvio      --Mensagem Envio
                                          ,pr_msgreceb => vr_msgreceb      --Mensagem Recebimento
                                          ,pr_movarqto => vr_movarqto      --Nome Arquivo mover
                                          ,pr_nmarqlog => vr_nmarqlog      --Nome Arquivo LOG
                                          ,pr_des_reto => vr_des_reto      --Retorno OK/NOK 
                                          ,pr_dscritic => vr_dscritic2);    --Descricao Erro
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        vr_dscritic:= vr_dscritic2;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;     
      
		  --Incluir nome do módulo logado - Chamado 664301
      --Seta novamente esta rotina porque foi alterado dentro da pc_elimina_arquivos_requis
			GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_solic_troca_op_cc_coopcomprovacao_vida');
      
      --Se for para gerar log
      IF nvl(pr_flgerlog,0) = 1 THEN

        --Descricao da Origem e da Transacao
        vr_dsorigem:= gene0001.vr_vet_des_origens(vr_idorigem);
        vr_dstransa:= 'Troca de OP/Conta corrente entre cooperativas.';

        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => CASE vr_retornvl WHEN 'OK' THEN 1 ELSE 0 END  
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);        
                            
        -- Gera item de log com informacao nova
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'cdcooper'
                                 ,pr_dsdadant => pr_cdcopant
                                 ,pr_dsdadatu => vr_cdcooper);
                                   
        -- Gera item de log com informacao nova
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'nrdconta'
                                 ,pr_dsdadant => pr_nrctaant
                                 ,pr_dsdadatu => pr_nrdconta);     
                                                               
        -- Gera item de log com informacao nova
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'cdorgins'
                                 ,pr_dsdadant => pr_orgpgant
                                 ,pr_dsdadatu => pr_cdorgins);   
                                                                 
        -- Gera item de log com informacao nova
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'nrrecben'
                                 ,pr_dsdadant => null
                                 ,pr_dsdadatu => pr_nrrecben);     
                                                               
      END IF;
      
      IF vr_retornvl = 'OK' AND nvl(pr_nrctaant,0) <> 0 AND pr_temsenha = 'FALSE' THEN
        --Gerar Termo de Troca de Domicilio
        inss0001.pc_gera_termo_troca_conta (pr_cdcooper => vr_cdcooper   --Cooperativa
                                           ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                           ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                           ,pr_cdoperad => vr_cdoperad   --Operador
                                           ,pr_nmdatela => vr_nmdatela   --Nome da tela
                                           ,pr_idorigem => vr_idorigem   --Origem Processamento
                                           ,pr_dtmvtolt => vr_dtmvtolt   --Data Movimento
                                           ,pr_cdcopant => pr_cdcopant   --Cooperativa Anterior
                                           ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                           ,pr_nrctaant => pr_nrctaant   --Numero da Conta Anterior
                                           ,pr_nrrecben => pr_nrrecben   --Numero Recebimento Beneficiario
                                           ,pr_nmrecben => pr_nmbenefi   --Nome Beneficiario
                                           ,pr_cdorgins => pr_cdorgins   --Numero Orgao pagamento para INSS
                                           ,pr_dsiduser => pr_dsiduser   --Descricao Identificador Usuario
                                           ,pr_entrecop => 1 /*true*/    --Indicador troca entre cooperativas (0=nao, 1=sim)
                                           ,pr_nmarqimp => vr_nmarqimp   --Nome Arquivo Impressao
                                           ,pr_nmarqpdf => vr_nmarqpdf   --Nome do Arquivo pdf
                                           ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                           ,pr_tab_erro => vr_tab_erro); --Tabela Erros
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          
          --Se nao tiver erro na tabela 
          IF vr_tab_erro.COUNT > 0 THEN
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE  
            vr_dscritic:= 'Nao foi possivel gerar o termo de troca de conta corrente.';
          END IF;  
          
          --Levantar Excecao
          RAISE vr_exc_erro;
          
        ELSE
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

          -- Insere as tags dos campos da PLTABLE de aplicações
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqimp', pr_tag_cont => vr_nmarqimp, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarqpdf, pr_des_erro => vr_dscritic);
        END IF;  
      END IF;
      
      --Se ocorreu erro                                              
      IF vr_retornvl = 'NOK' THEN
        
        --Se nao possui mensagem de erro
        IF vr_cdcritic = 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= 'Nao foi possivel realizar alteracao.';
        END IF;
          
        --Verificar se possui somente código erro
        IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        -- Gravar Linha Log
        inss0001.pc_retorna_linha_log(pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                     ,pr_cdprogra => vr_nmdatela   --Nome do Programa
                                     ,pr_dtmvtolt => vr_dtmvtolt   --Data Movimento
                                     ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                     ,pr_nrcpfcgc => pr_nrcpfcgc   --Numero Cpf
                                     ,pr_nrrecben => pr_nrrecben   --Numero Recebimento Beneficio
                                     ,pr_nmmetodo => 'Alteracao'   --Nome do metodo
                                     ,pr_cdderror => vr_cdcritic   --Codigo Erro
                                     ,pr_dsderror => vr_dscritic   --Descricao Erro
                                     ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo LOG
                                     ,pr_cdtipofalha => 3          --Tipo 2 abre chamado
                                     ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                     ,pr_dscritic => vr_dscritic2); --Descricao erro
                                     
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          vr_dscritic:= vr_dscritic2;          
        END IF;
        
        --Levantar Excecao
        RAISE vr_exc_erro;           
                          
      END IF;
      
      vr_des_log :=   
        'Conta: '    || gene0002.fn_mask(pr_nrdconta,'9999.999-9')  || ' | ' ||
        'Nome: '     || pr_nmbenefi                         || ' | ' ||
        'NB: '       || to_char(pr_nrrecben)                || ' | ' ||
        'operador: ' || to_char(vr_cdoperad)                || ' | ' ||
        'Alteracao: Alterado a conta de recebimento de ' ||
        pr_nrctaant || ', cooperativa ' || vr_nmcopant || ' para ' ||
        pr_nrdconta || ', cooperativa ' || vr_nmcooper || '.';
                                                 
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || vr_nmdatela || ' --> ' || 
                                                    'ALERTA: ' || vr_des_log   
                                  ,pr_nmarqlog     => 'inss_historico.log'
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_cdprograma   => vr_nmdatela
                                  );
        
      
      --Retorno
      pr_des_erro:= vr_retornvl;    

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= vr_retornvl;
        
        --Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                       
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        pr_cdcritic:= 0;
        -- Chamar rotina de gravação de erro
        pr_dscritic := 'Erro na inss0001.pc_solic_troca_op_cc_coop --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     


  END pc_solic_troca_op_cc_coop;
  
  /* Procedure para Solicitar Troca orgao Pagador e/ou Conta Corrente */
  PROCEDURE pc_solic_troca_op_cc (pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                 ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                 ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                 ,pr_idorigem IN INTEGER                 --Origem Processamentopr_dtmvtolt IN VARCHAR2                --Data Movimento
                                 ,pr_nmdatela IN VARCHAR2                --Nome da tela
                                 ,pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                 ,pr_cdoperad IN VARCHAR2                --Operador
                                 ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                 ,pr_cdorgins IN INTEGER                 --Codigo Orgao Pagador
                                 ,pr_orgpgant IN INTEGER                 --Codigo Orgao Pagador Anterior
                                 ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                 ,pr_tpnrbene IN VARCHAR2                --Tipo Beneficio
                                 ,pr_tpdpagto IN VARCHAR2                --Tipo de Pagamento
                                 ,pr_dscsitua IN VARCHAR2                --Descricao da Situacao
                                 ,pr_nrdconta IN INTEGER                 --Numero da Conta
                                 ,pr_nrctaant IN INTEGER                 --Numero da Conta Anterior                                      
                                 ,pr_cdagepac IN INTEGER                 --Codigo Agencia 
                                 ,pr_idbenefi IN INTEGER                 --Identificador do Beneficio
                                 ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                 ,pr_nrcpfant IN NUMBER                  --Numero CPF/CNPJ Anterior
                                 ,pr_idseqttl IN INTEGER                 --Sequencial Titular
                                 ,pr_nmbairro IN VARCHAR2                --Nome do Bairro
                                 ,pr_nrcepend IN INTEGER                 --Numero CEP
                                 ,pr_dsendere IN VARCHAR2                --Descricao Endereco Residencial
                                 ,pr_nrendere IN INTEGER                 --Numero Endereco
                                 ,pr_nmcidade IN VARCHAR2                --Nome Cidade
                                 ,pr_cdufende IN VARCHAR2                --Codigo UF Titular
                                 ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                 ,pr_nmbenefi IN VARCHAR2                --Nome Beneficiario
                                 ,pr_dtcompvi IN VARCHAR2                --Data Comprovacao Vida
                                 ,pr_nrdddtfc IN INTEGER                 --Numero DDD
                                 ,pr_nrtelefo IN INTEGER                 --Numero Telefone
                                 ,pr_cdsexotl IN INTEGER                 --Sexo
                                 ,pr_nomdamae IN VARCHAR2                --Nome Da Mae
                                 ,pr_flgerlog IN INTEGER                 --Escrever Erro no Log (0=nao, 1=sim)
                                 ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                 ,pr_temsenha IN VARCHAR DEFAULT 'FALSE' --Verifica se tem senha da internet ativa
                                 ,pr_nmarqimp OUT VARCHAR2               --Nome Arquivo Impressao
                                 ,pr_nmarqpdf OUT VARCHAR2               --Nome Arquivo pdf
                                 ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                 ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                 ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solic_troca_op_cc            Antigo: procedures/b1wgen0091.p/solicita_troca_op_conta_corrente
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Fevereiro/2015                           Ultima atualizacao: 21/06/2016
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para Solicitar Troca orgao Pagador e/ou Conta Corrente 
  
    Alterações : 26/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
    
                 27/03/2015 - Alterado o nome do arquivo de envio/recebimento
                              (Adriano).
    
                 10/04/2015 - Asjute para retornar o erro corretamente (Adriano).            
    
                 29/05/2015 - Ajustes realizados:                              
                              - Somente enviar o telefone se ele for menor 10 digitos;
                              - Incluido tratamento para obrigar o envio do endereço;
                              (Adriano).
                              
                 23/09/2015 - Adicionado validação dos campos e alterado a nomenclatura do arquivo.
                              (Douglas - Chamado 314031)
                              
                 21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                              (Adriano - SD 473539).
                              
                 23/06/2016 - Incluir nome do módulo logado - (Ana - Envolti - Chamado 664301)
  ---------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
        
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_dscritic2 VARCHAR2(4000); 
    
    --Variaveis Locais
    vr_dstime    VARCHAR2(100);
    vr_msgenvio  VARCHAR2(32767);
    vr_msgreceb  VARCHAR2(32767);
    vr_movarqto  VARCHAR2(32767);
    vr_nmarqlog  VARCHAR2(32767);
    vr_nmdireto  VARCHAR2(1000);
    vr_des_reto  VARCHAR2(3);
    vr_retornvl  VARCHAR2(3):= 'NOK';
    vr_dstexto   VARCHAR2(32767);
    vr_dsendere  VARCHAR2(1000);
    vr_dstransa  VARCHAR2(1000);
    vr_dsorigem  VARCHAR2(1000);
    vr_nrdrowid  ROWID;
    vr_dtmvtolt  DATE;
    vr_auxnmarq  VARCHAR2(30);
    vr_des_log   VARCHAR2(1000);
    vr_nmcooper  VARCHAR2(100);
    
    --Tabela de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Variaveis de Excecoes
    vr_exc_erro   EXCEPTION;                                       
    vr_exc_saida  EXCEPTION; 
    vr_exc_status EXCEPTION; 
    
    -- variavel que vai indicar se a mensagem é erro ou alerta - ch 660327    
    vr_cd_tipo_mensagem number (5):= 3; -- Codigo 3 onde na rotina final faz de para gerar 2 erro    
    
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_solic_troca_op_cc');                
        
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= NULL;
      vr_msgenvio:= NULL;
      vr_msgreceb:= NULL;
      vr_movarqto:= NULL;
      vr_nmarqlog:= NULL;
      vr_dstime:=   NULL;
        
      BEGIN                                                  
        --Pega a data de movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/YYYY'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
                                            
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
       RAISE vr_exc_erro;
       
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
  
      vr_nmcooper := rw_crapcop.nmrescop;
  
      --Verificar parametros
      IF nvl(pr_nrdconta,0) = 0 THEN
        
        --Monta mensagem de critica
        vr_cdcritic:= 9;  
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_nrdconta,0) = nvl(pr_nrctaant,0) THEN
        
        --Monta mensagem de critica
        vr_dscritic:= 'Beneficio ja existe na conta informada.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF NVL(pr_nrrecben,0) = 0   OR 
            LENGTH(pr_nrrecben) > 10 THEN
        
        --Monta mensagem de critica
        vr_dscritic:= 'NB nao foi informado.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_tpnrbene) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Tido do beneficio invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_nomdamae) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Filiacao invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_cdorgins,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Beneficio - Orgao pagador invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_cdagepac,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Beneficio - Unidade de atendimento invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_tpdpagto) IS NULL THEN  
      
        --Monta mensagem de critica     
        vr_dscritic:= 'Beneficio - Tipo de pagamento invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_dscsitua) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Beneficio - Situacao invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_cdagesic,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Beneficio - Agencia SICREDI invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_nrcpfcgc,0) = 0 THEN
        
        --Monta mensagem de critica
        vr_dscritic:= 'Beneficio - CPF invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_idbenefi,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Codigo do beneficiario invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_cdufende) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Beneficio - UF invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_nrcpfcgc,0) <> nvl(pr_nrcpfant,0) THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Titularidade invalida com a conta/dv destino.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_nmcidade) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Cidade invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_dsendere) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Endereco invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
                
      END IF;  
        
      --Buscar Diretorio Padrao da Cooperativa
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => null);
                                          
      --Determinar Nomes do Arquivo de Log
      vr_nmarqlog:= 'SICREDI_Soap_LogErros';

      --Buscar o Horario
      vr_dstime:= lpad(gene0002.fn_busca_time,5,'0');
      
      -- Complemento para o Nome do arquivo
      vr_auxnmarq:= LPAD(pr_nrrecben,11,'0')||'.'||
                    vr_dstime ||
                    LPAD(TRUNC(DBMS_RANDOM.Value(0,9999)),4,'0');
                    
      --Determinar Nomes do Arquivo de Envio
      vr_msgenvio:= vr_nmdireto||'/arq/INSS.SOAP.EALTOPC.'||vr_auxnmarq;
                    
      --Determinar Nome do Arquivo de Recebimento    
      vr_msgreceb:= vr_nmdireto||'/arq/INSS.SOAP.RALTOPC.'||vr_auxnmarq;
                    
      --Determinar Nome Arquivo movido              
      vr_movarqto:= vr_nmdireto||'/salvar/inss';
      
      --Bloco Alteracao
      BEGIN
        
        --Gerar cabecalho XML
        inss0001.pc_gera_cabecalho_soap (pr_idservic => 2   /* idservic */ 
                                        ,pr_nmmetodo => 'ben:InAlterarBeneficiarioINSS' --Nome Metodo
                                        ,pr_username => 'app_cecred_client' --Username
                                        ,pr_password => fn_senha_sicredi    --Senha
                                        ,pr_dstexto  => vr_dstexto          --Texto do Arquivo de Dados
                                        ,pr_des_reto => vr_des_reto         --Retorno OK/NOK
                                        ,pr_dscritic => vr_dscritic);       --Descricao da Critica
                                       
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          RAISE vr_exc_saida;
        END IF;

        /*Monta as tags de envio
        OBS.: O valor das tags deve respeitar a formatacao presente na
              base do SICREDI do contrario, a operacao nao sera
              realizada. */
              
        --Montar o logradouro
        IF nvl(pr_nrendere,0) > 0 THEN
          vr_dsendere:= SUBSTR(pr_dsendere,1,30)||','||pr_nrendere;
        ELSE
          vr_dsendere:= SUBSTR(pr_dsendere,1,30);
        END IF;
            
        --Montar o XML      
        vr_dstexto:= vr_dstexto||
            '<ben:Beneficiario NumeroDocumento="'||lpad(pr_nrcpfcgc,11,'0')||'" v1:ID="'||pr_idbenefi||'">'||
               '<v1:Enderecos>'||
                  '<v12:Endereco>'||
                     '<v12:Logradouro>'||
                        '<v12:Nome>'||vr_dsendere||'</v12:Nome>'||
                     '</v12:Logradouro>'||
                     '<v12:Bairro>'||SUBSTR(pr_nmbairro,1,17)||'</v12:Bairro>'||
                     '<v12:Cidade>'||
                        '<v12:Nome>'||pr_nmcidade||'</v12:Nome>'||            
                        '<v12:Estado>'||
                           '<v12:Sigla>'||pr_cdufende||'</v12:Sigla>'||            
                        '</v12:Estado>'|| 
                     '</v12:Cidade>'||            
                     '<v12:CEP>'||pr_nrcepend||'</v12:CEP>'||           
                  '</v12:Endereco>'||
               '</v1:Enderecos>'||
               '<v1:Nome>'||SUBSTR(pr_nmbenefi,1,30)||'</v1:Nome>'||
               '<v1:Filiacao>'||
                  '<v1:NomeMae>'||SUBSTR(pr_nomdamae,1,30)||'</v1:NomeMae>'||            
               '</v1:Filiacao>'||
               '<v1:Sexo>'||CASE pr_cdsexotl WHEN 1 THEN 'MASCULINO' ELSE 'FEMININO' END||'</v1:Sexo>'||
               '<v1:Contatos>'||
                    '<v1:Telefones>'||
                       '<v13:Telefone>'||
                          --Somente vamos enviar o telefone se ele for menor que 10 digitos.
                          '<v13:DDD>'|| CASE WHEN LENGTH(pr_nrtelefo) < 10 THEN pr_nrdddtfc ELSE '' END ||'</v13:DDD>'||
                          '<v13:Numero>'|| CASE WHEN LENGTH(pr_nrtelefo) < 10 THEN pr_nrtelefo ELSE '' END ||'</v13:Numero>'||
                       '</v13:Telefone>'||                        
                    '</v1:Telefones>'||                        
               '</v1:Contatos>'||
               '<v14:Identificadores>'||
                  '<v14:IdentificadorBeneficiario>'||
                     '<v14:Codigo>'||lpad(pr_nrrecben,10,'0')||'</v14:Codigo>'||                        
                     '<v14:TipoCodigo>'||pr_tpnrbene||'</v14:TipoCodigo>'||                                    
                  '</v14:IdentificadorBeneficiario>'||                        
               '</v14:Identificadores>'||
               '<v14:OrgaoPagador>'||
                  '<v14:NumeroOrgaoPagador>'||pr_cdorgins||'</v14:NumeroOrgaoPagador>'||                        
                  '<v14:Entidade>'||
                     '<v15:NumeroUnidadeAtendimento>2</v15:NumeroUnidadeAtendimento>'||                                    
                  '</v14:Entidade>'||                        
               '</v14:OrgaoPagador>'||
               '<v14:Beneficio>'||
                  '<v16:TipoPagamento>'||pr_tpdpagto||'</v16:TipoPagamento>'||                        
                  '<v16:Situacao>'||pr_dscsitua||'</v16:Situacao>'||                        
               '</v14:Beneficio>'||
               '<v14:Situacao>'||pr_dscsitua||'</v14:Situacao>'||
               '<v14:ContaCorrente>'||
                  '<v17:codigoAgencia>'||pr_cdagesic||'</v17:codigoAgencia>'||                        
                  '<v17:numero>'||SUBSTR(pr_nrdconta,1,LENGTH(pr_nrdconta)-1)||'</v17:numero>'||                        
                  '<v17:digitoVerificador>'||SUBSTR(pr_nrdconta,LENGTH(pr_nrdconta),1)||'</v17:digitoVerificador>'||                                    
               '</v14:ContaCorrente>'||
            '</ben:Beneficiario>'||
            '</ben:InAlterarBeneficiarioINSS>'||
            '</soapenv:Body></soapenv:Envelope>';                      
           
        --Efetuar Requisicao Soap
        inss0001.pc_efetua_requisicao_soap (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa 
                                           ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                           ,pr_nrdcaixa => pr_nrdcaixa   --Numero Caixa
                                           ,pr_idservic => 1             --Identificador Servico
                                           ,pr_dsservic => 'Alterar'     --Descricao Servico
                                           ,pr_nmmetodo => 'OutAlterarBeneficiarioINSS' --Nome Método
                                           ,pr_dstexto  => vr_dstexto    --Texto com a msg XML
                                           ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                           ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                           ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                           ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo Log
                                           ,pr_nmdatela => pr_nmdatela   --Nome da Tela
                                           ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                           ,pr_dscritic => vr_dscritic); --Descrição Erros
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
          
        --Verifica Falha no Pacote
        inss0001.pc_obtem_fault_packet (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa 
                                       ,pr_nmdatela => pr_nmdatela   --Nome da Tela
                                       ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                       ,pr_nrdcaixa => pr_nrdcaixa   --Numero Caixa
                                       ,pr_dsderror => 'SOAP-ENV:-950' --Descricao Servico
                                       ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                       ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                       ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                       ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo log
                                       ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                       ,pr_dscritic => vr_dscritic); --Mensagem Erro
                                       
                                       
        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          
          /*Quando é feito a troca de OP de um NB que esteja com status de "Aguardando atualização",
            o SICREDI não irá permitir a troca e retornará a mensgaem de erro 
            "0008 - Cadastro Aguardando Atualização!.  . (NEGOCIO) .".
            Contudo, somente quando a troca de OP for solicitada através do caracter/web (Contas Corrente) 
            vamos considerar esse erro, fazendo com a rotina retorne "OK" para 
            a rotina chamadora, mesmo que a troca não tenha sido efetuada e o OP do cooperado
            cadastrado na base da CECRED, fique divergente ao cadastrado na base do SICREDI.
            Esta exceção foi acordada com a equipe de COMPENSAÇÃO.    */
          IF (pr_idorigem = 1     OR --caracter
              pr_idorigem = 5  ) AND --web
              pr_cddopcao = 'A'  AND
              vr_dscritic LIKE ('%0008%') THEN
            
              if vr_dscritic LIKE ('%0008%') THEN
                  -- Codigo 1 onde na rotina final faz de para gerar 4 alerta - ch 660327
                  vr_cd_tipo_mensagem := 1; 
              end if;
              
            --Gera exceção 
            RAISE vr_exc_status;    
            
          END IF;
          
          vr_retornvl:= vr_des_reto;
          
          --Gera exceção
          RAISE vr_exc_saida;
          
        END IF; 
        
        IF NVL(pr_nrctaant,0) <> 0 AND UPPER(pr_temsenha) = 'FALSE' THEN
          
          --Gerar Termo de Troca de Conta Corrente/OP
          inss0001.pc_gera_termo_troca_conta (pr_cdcooper => pr_cdcooper   --Cooperativa
                                             ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                             ,pr_nrdcaixa => pr_nrdcaixa   --Numero Caixa
                                             ,pr_cdoperad => pr_cdoperad   --Operador
                                             ,pr_nmdatela => pr_nmdatela   --Nome da tela
                                             ,pr_idorigem => pr_idorigem   --Origem Processamento
                                             ,pr_dtmvtolt => vr_dtmvtolt   --Data Movimento
                                             ,pr_cdcopant => 0             --Cooperativa Anterior
                                             ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                             ,pr_nrctaant => pr_nrctaant   --Numero da Conta Anterior
                                             ,pr_nrrecben => pr_nrrecben   --Numero Recebimento Beneficiario
                                             ,pr_nmrecben => pr_nmbenefi   --Nome Beneficiario
                                             ,pr_cdorgins => pr_cdorgins   --Numero Orgao pagamento para INSS
                                             ,pr_dsiduser => pr_dsiduser   --Descricao Identificador Usuario
                                             ,pr_entrecop => 0 /*false*/   --Indicador troca entre cooperativas (0=nao, 1=sim)
                                             ,pr_nmarqimp => pr_nmarqimp   --Nome Arquivo Impressao
                                             ,pr_nmarqpdf => pr_nmarqpdf   --Nome do Arquivo pdf
                                             ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                             ,pr_tab_erro => vr_tab_erro); --Tabela Erros
          --Se ocorreu erro
          IF vr_des_reto = 'NOK' THEN
            
            --Se nao tiver erro na tabela
            IF vr_tab_erro.COUNT > 0 THEN
              vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;           
            ELSE
              vr_dscritic:= 'Nao foi possivel gerar o termo de troca de conta corrente.';
            END IF;  
            
            --Levantar Excecao
            RAISE vr_exc_erro;
            
          END IF;  
        END IF;
        
        --Retorno OK  
        vr_retornvl:= 'OK';        
                                  
      EXCEPTION
        WHEN vr_exc_saida THEN 
          vr_retornvl:= 'NOK';
        WHEN vr_exc_status THEN
          vr_retornvl:= 'OK';           
        
      END;  
      
      --Eliminar arquivos requisicao
      inss0001.pc_elimina_arquivos_requis (pr_cdcooper => pr_cdcooper      --Codigo Cooperativa
                                          ,pr_cdprogra => pr_nmdatela      --Nome do Programa
                                          ,pr_msgenvio => vr_msgenvio      --Mensagem Envio
                                          ,pr_msgreceb => vr_msgreceb      --Mensagem Recebimento
                                          ,pr_movarqto => vr_movarqto      --Nome Arquivo mover
                                          ,pr_nmarqlog => vr_nmarqlog      --Nome Arquivo LOG
                                          ,pr_des_reto => vr_des_reto      --Retorno OK/NOK 
                                          ,pr_dscritic => vr_dscritic2);    --Descricao Erro
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        vr_dscritic:= vr_dscritic2;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;     
      
		  --Incluir nome do módulo logado - Chamado 664301
      --Seta novamente esta rotina porque foi alterado dentro da pc_elimina_arquivos_requis
			GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_solic_troca_op_cc');            
     
      --Se não ocorreu erro                                              
      IF vr_retornvl = 'OK' THEN
        
        --Se for para gerar log
        IF NVL(pr_flgerlog,0) = 1 THEN

          --Descricao da Origem e da Transacao
          vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
          vr_dstransa:= 'Alteracao de OP/DB';

          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => CASE vr_retornvl WHEN 'OK' THEN 1 ELSE 0 END  
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);        
                                     
          -- Gera item de log com informacao nova
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'nrdconta'
                                   ,pr_dsdadant => pr_nrctaant
                                   ,pr_dsdadatu => pr_nrdconta);       
                                                               
          -- Gera item de log com informacao nova
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'cdorgins'
                                   ,pr_dsdadant => pr_orgpgant
                                   ,pr_dsdadatu => pr_cdorgins);   
                                                                   
          -- Gera item de log com informacao nova
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'nrrecben'
                                   ,pr_dsdadant => null
                                   ,pr_dsdadatu => pr_nrrecben);    
                                                                  
        END IF;
        
        vr_des_log :=   
        'Conta: '    || gene0002.fn_mask(pr_nrdconta,'9999.999-9')  || ' | ' ||
        'Nome: '     || pr_nmbenefi                         || ' | ' ||
        'NB: '       || to_char(pr_nrrecben)                || ' | ' ||
        'operador: ' || to_char(pr_cdoperad)                || ' | ' ||
        'Alteracao: Alterado a conta de recebimento de ' ||
        pr_nrctaant || ', cooperativa ' || vr_nmcooper || ' para ' ||
        pr_nrdconta || ', cooperativa ' || vr_nmcooper || '.';
        
        
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || pr_nmdatela || ' --> ' || 
                                                    'ALERTA: ' || vr_des_log   
                                  ,pr_nmarqlog     => 'inss_historico.log'
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_cdprograma   => pr_nmdatela
                                  );
        
        
      ELSE
        
        --Se nao possui mensagem de erro
        IF vr_cdcritic = 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= 'Nao foi possivel realizar a troca de op/conta corrente.';
        END IF;

        --Verificar se possui somente código erro
        IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        -- Gravar Linha Log
        inss0001.pc_retorna_linha_log(pr_cdcooper => pr_cdcooper   --Codigo Cooperativa 
                                     ,pr_cdprogra => pr_nmdatela   --Nome do Programa
                                     ,pr_dtmvtolt => vr_dtmvtolt   --Data Movimento
                                     ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                     ,pr_nrcpfcgc => pr_nrcpfcgc   --Numero Cpf
                                     ,pr_nrrecben => pr_nrrecben   --Numero Recebimento Beneficio
                                     ,pr_nmmetodo => 'Alteracao'   --Nome do metodo
                                     ,pr_cdderror => vr_cdcritic   --Codigo Erro
                                     ,pr_dsderror => vr_dscritic   --Descricao Erro
                                     ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo LOG
                                     ,pr_cdtipofalha => vr_cd_tipo_mensagem  -- erro ou alerta - ch 6603271
                                     ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                     ,pr_dscritic => vr_dscritic2); --Descricao erro
                                     
        
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          vr_dscritic:= vr_dscritic2;          
        END IF;
        
        --Levantar Excecao
        RAISE vr_exc_erro;   
                                          
      END IF;
      
      --Retorno
      pr_des_erro:= vr_retornvl;    

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= vr_retornvl;
        
        --Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;       
           
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        --Erro
        pr_cdcritic:= 0;
        -- Chamar rotina de gravação de erro
        pr_dscritic := 'Erro na inss0001.pc_solic_troca_op_cc --> '|| SQLERRM;
          
  END pc_solic_troca_op_cc;  

  /* Procedure para Solicitar Troca orgao Pagador e/ou Conta Corrente - Modo Caracter */
  PROCEDURE pc_solic_troca_op_cc_car (pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                     ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                     ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                     ,pr_idorigem IN INTEGER                 --Origem Processamentopr_dtmvtolt IN VARCHAR2                --Data Movimento
                                     ,pr_nmdatela IN VARCHAR2                --Nome da tela
                                     ,pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                     ,pr_cdoperad IN VARCHAR2                --Operador
                                     ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                     ,pr_cdorgins IN INTEGER                 --Codigo Orgao Pagador
                                     ,pr_orgpgant IN INTEGER                 --Codigo Orgao Pagador Anterior
                                     ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                     ,pr_tpnrbene IN VARCHAR2                --Tipo Beneficio
                                     ,pr_tpdpagto IN VARCHAR2                --Tipo de Pagamento
                                     ,pr_dscsitua IN VARCHAR2                --Descricao da Situacao
                                     ,pr_nrdconta IN INTEGER                 --Numero da Conta
                                     ,pr_nrctaant IN INTEGER                 --Numero da Conta Anterior                                      
                                     ,pr_cdagepac IN INTEGER                 --Codigo Agencia 
                                     ,pr_idbenefi IN INTEGER                 --Identificador do Beneficio
                                     ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                     ,pr_nrcpfant IN NUMBER                  --Numero CPF/CNPJ Anterior
                                     ,pr_idseqttl IN INTEGER                 --Sequencial Titular
                                     ,pr_nmbairro IN VARCHAR2                --Nome do Bairro
                                     ,pr_nrcepend IN INTEGER                 --Numero CEP
                                     ,pr_dsendere IN VARCHAR2                --Descricao Endereco Residencial
                                     ,pr_nrendere IN INTEGER                 --Numero Endereco
                                     ,pr_nmcidade IN VARCHAR2                --Nome Cidade
                                     ,pr_cdufende IN VARCHAR2                --Codigo UF Titular
                                     ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                     ,pr_nmbenefi IN VARCHAR2                --Nome Beneficiario
                                     ,pr_dtcompvi IN VARCHAR2                    --Data Comprovacao Vida
                                     ,pr_nrdddtfc IN INTEGER                 --Numero DDD
                                     ,pr_nrtelefo IN INTEGER                 --Numero Telefone
                                     ,pr_cdsexotl IN INTEGER                 --Sexo
                                     ,pr_nomdamae IN VARCHAR2                --Nome Da Mae
                                     ,pr_flgerlog IN INTEGER                 --Escrever Erro no Log (0=nao, 1=sim)
                                     ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                     ,pr_nmarqimp OUT VARCHAR2               --Nome Arquivo Impressao
                                     ,pr_nmarqpdf OUT VARCHAR2               --Nome Arquivo pdf
                                     ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                     ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                     ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solic_troca_op_cc_car            Antigo: procedures/b1wgen0091.p/solicita_troca_op_conta_corrente
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Fevereiro/2015                           Ultima atualizacao: 26/03/2015
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para Solicitar Troca orgao Pagador e/ou Conta Corrente 
  
    Alterações : 26/02/2015 Conversao Progress -> Oracle (Alisson-AMcom)
    
                 26/03/2015 - Ajuste na organização e identação de escrita (Adriano).
                
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(3);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;                                       
        
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_solic_troca_op_cc_car');    
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      --Solicitar Troca OP Conta Corrente
      inss0001.pc_solic_troca_op_cc (pr_cdcooper => pr_cdcooper    --Codigo Cooperativa 
                                    ,pr_cdagenci => pr_cdagenci    --Codigo Agencia
                                    ,pr_nrdcaixa => pr_nrdcaixa    --Numero Caixa
                                    ,pr_idorigem => pr_idorigem    --Origem Processamentopr_dtmvtolt IN VARCHAR2                --Data Movimento
                                    ,pr_nmdatela => pr_nmdatela    --Nome da tela
                                    ,pr_dtmvtolt => pr_dtmvtolt    --Data Movimento
                                    ,pr_cdoperad => pr_cdoperad    --Operador
                                    ,pr_cddopcao => pr_cddopcao    --Codigo Opcao
                                    ,pr_cdorgins => pr_cdorgins    --Codigo Orgao Pagador
                                    ,pr_orgpgant => pr_orgpgant    --Codigo Orgao Pagador Anterior
                                    ,pr_nrrecben => pr_nrrecben    --Numero Recebimento Beneficio
                                    ,pr_tpnrbene => pr_tpnrbene    --Tipo Beneficio
                                    ,pr_tpdpagto => pr_tpdpagto    --Tipo de Pagamento
                                    ,pr_dscsitua => pr_dscsitua    --Descricao da Situacao
                                    ,pr_nrdconta => pr_nrdconta    --Numero da Conta
                                    ,pr_nrctaant => pr_nrctaant    --Numero da Conta Anterior                                      
                                    ,pr_cdagepac => pr_cdagepac    --Codigo Agencia 
                                    ,pr_idbenefi => pr_idbenefi    --Identificador do Beneficio
                                    ,pr_nrcpfcgc => pr_nrcpfcgc    --Numero CPF/CNPJ
                                    ,pr_nrcpfant => pr_nrcpfant    --Numero CPF/CNPJ Anterior
                                    ,pr_idseqttl => pr_idseqttl    --Sequencial Titular
                                    ,pr_nmbairro => pr_nmbairro    --Nome do Bairro
                                    ,pr_nrcepend => pr_nrcepend    --Numero CEP
                                    ,pr_dsendere => pr_dsendere    --Descricao Endereco Residencial
                                    ,pr_nrendere => pr_nrendere    --Numero Endereco
                                    ,pr_nmcidade => pr_nmcidade    --Nome Cidade
                                    ,pr_cdufende => pr_cdufende    --Codigo UF Titular
                                    ,pr_cdagesic => pr_cdagesic    --Codigo Agencia Sicredi
                                    ,pr_nmbenefi => pr_nmbenefi    --Nome Beneficiario
                                    ,pr_dtcompvi => pr_dtcompvi    --Data Comprovacao Vida
                                    ,pr_nrdddtfc => pr_nrdddtfc    --Numero DDD
                                    ,pr_nrtelefo => pr_nrtelefo    --Numero Telefone
                                    ,pr_cdsexotl => pr_cdsexotl    --Sexo
                                    ,pr_nomdamae => pr_nomdamae    --Nome Da Mae
                                    ,pr_flgerlog => pr_flgerlog    --Escrever Erro no Log (0=nao, 1=sim)
                                    ,pr_dsiduser => pr_dsiduser    --Identificacao Usuario
                                    ,pr_nmarqimp => pr_nmarqimp    --Nome Arquivo Impressao
                                    ,pr_nmarqpdf => pr_nmarqpdf    --Nome Arquivo pdf
                                    ,pr_cdcritic => vr_cdcritic    --Código da crítica
                                    ,pr_dscritic => vr_dscritic    --Descrição da crítica
                                    ,pr_nmdcampo => pr_nmdcampo    --Nome do Campo
                                    ,pr_des_erro => vr_des_erro);  --Saida OK/NOK      
                                    
      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
        
      --Retorno
      pr_des_erro:= 'OK';    

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;    
      
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        --Erro
        pr_cdcritic:= 0;
        -- Chamar rotina de gravação de erro
        pr_dscritic := 'Erro na inss0001.pc_solic_troca_op_cc_car --> '|| SQLERRM;

  END pc_solic_troca_op_cc_car;  

  /* Procedure para Solicitar Troca orgao Pagador e/ou Conta Corrente */
  PROCEDURE pc_solic_troca_op_cc_web (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                     ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                     ,pr_cdorgins IN INTEGER                 --Codigo Orgao Pagador
                                     ,pr_orgpgant IN INTEGER                 --Codigo Orgao Pagador Anterior
                                     ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                     ,pr_tpnrbene IN VARCHAR2                --Tipo Beneficio
                                     ,pr_tpdpagto IN VARCHAR2                --Tipo de Pagamento
                                     ,pr_dscsitua IN VARCHAR2                --Descricao da Situacao
                                     ,pr_nrdconta IN INTEGER                 --Numero da Conta
                                     ,pr_nrctaant IN INTEGER                 --Numero da Conta Anterior                                      
                                     ,pr_cdagepac IN INTEGER                 --Codigo Agencia 
                                     ,pr_idbenefi IN INTEGER                 --Identificador do Beneficio
                                     ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                     ,pr_nrcpfant IN NUMBER                  --Numero CPF/CNPJ Anterior
                                     ,pr_idseqttl IN INTEGER                 --Sequencial Titular
                                     ,pr_nmbairro IN VARCHAR2                --Nome do Bairro
                                     ,pr_nrcepend IN INTEGER                 --Numero CEP
                                     ,pr_dsendere IN VARCHAR2                --Descricao Endereco Residencial
                                     ,pr_nrendere IN INTEGER                 --Numero Endereco
                                     ,pr_nmcidade IN VARCHAR2                --Nome Cidade
                                     ,pr_cdufende IN VARCHAR2                --Codigo UF Titular
                                     ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                     ,pr_nmbenefi IN VARCHAR2                --Nome Beneficiario
                                     ,pr_dtcompvi IN VARCHAR2                --Data Comprovacao Vida
                                     ,pr_nrdddtfc IN INTEGER                 --Numero DDD
                                     ,pr_nrtelefo IN INTEGER                 --Numero Telefone
                                     ,pr_cdsexotl IN INTEGER                 --Sexo
                                     ,pr_nomdamae IN VARCHAR2                --Nome Da Mae
                                     ,pr_flgerlog IN INTEGER                 --Escrever Erro no Log (0=nao, 1=sim)
                                     ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                     ,pr_temsenha IN VARCHAR                 --Verifica se tem senha da internet ativa
                                     ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                     ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solic_troca_op_cc_web            Antigo: procedures/b1wgen0091.p/solicita_troca_op_conta_corrente
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Fevereiro/2015                           Ultima atualizacao: 26/03/2015
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para Solicitar Troca orgao Pagador e/ou Conta Corrente 
  
    Alterações : 26/02/2015 Conversao Progress -> Oracle (Alisson-AMcom)
    
                 26/03/2015 - Ajuste na organização e identação da escrita (Adriano).
    
                 25/11/2015 - Adicionada verificacao para gerar contrato somente
                              quando o beneficiario nao tiver senha de internet 
                              cadastrada. Projeto 255 (Lombardi).
                
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(3);
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de Retorno
    vr_nmarqimp VARCHAR2(100);
    vr_nmarqpdf VARCHAR2(100);
    vr_auxconta PLS_INTEGER:= 0;
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;                                       
        
    BEGIN
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_solic_troca_op_cc_web');          

      --Solicitar Troca OP Conta Corrente
      inss0001.pc_solic_troca_op_cc (pr_cdcooper => vr_cdcooper    --Codigo Cooperativa 
                                    ,pr_cdagenci => vr_cdagenci    --Codigo Agencia
                                    ,pr_nrdcaixa => vr_nrdcaixa    --Numero Caixa
                                    ,pr_idorigem => vr_idorigem    --Origem Processamentopr_dtmvtolt IN VARCHAR2                --Data Movimento
                                    ,pr_nmdatela => vr_nmdatela    --Nome da tela
                                    ,pr_dtmvtolt => pr_dtmvtolt    --Data Movimento
                                    ,pr_cdoperad => vr_cdoperad    --Operador
                                    ,pr_cddopcao => pr_cddopcao    --Codigo Opcao
                                    ,pr_cdorgins => pr_cdorgins    --Codigo Orgao Pagador
                                    ,pr_orgpgant => pr_orgpgant    --Codigo Orgao Pagador Anterior
                                    ,pr_nrrecben => pr_nrrecben    --Numero Recebimento Beneficio
                                    ,pr_tpnrbene => pr_tpnrbene    --Tipo Beneficio
                                    ,pr_tpdpagto => pr_tpdpagto    --Tipo de Pagamento
                                    ,pr_dscsitua => pr_dscsitua    --Descricao da Situacao
                                    ,pr_nrdconta => pr_nrdconta    --Numero da Conta
                                    ,pr_nrctaant => pr_nrctaant    --Numero da Conta Anterior                                      
                                    ,pr_cdagepac => pr_cdagepac    --Codigo Agencia 
                                    ,pr_idbenefi => pr_idbenefi    --Identificador do Beneficio
                                    ,pr_nrcpfcgc => pr_nrcpfcgc    --Numero CPF/CNPJ
                                    ,pr_nrcpfant => pr_nrcpfant    --Numero CPF/CNPJ Anterior
                                    ,pr_idseqttl => pr_idseqttl    --Sequencial Titular
                                    ,pr_nmbairro => pr_nmbairro    --Nome do Bairro
                                    ,pr_nrcepend => pr_nrcepend    --Numero CEP
                                    ,pr_dsendere => pr_dsendere    --Descricao Endereco Residencial
                                    ,pr_nrendere => pr_nrendere    --Numero Endereco
                                    ,pr_nmcidade => pr_nmcidade    --Nome Cidade
                                    ,pr_cdufende => pr_cdufende    --Codigo UF Titular
                                    ,pr_cdagesic => pr_cdagesic    --Codigo Agencia Sicredi
                                    ,pr_nmbenefi => pr_nmbenefi    --Nome Beneficiario
                                    ,pr_dtcompvi => pr_dtcompvi    --Data Comprovacao Vida
                                    ,pr_nrdddtfc => pr_nrdddtfc    --Numero DDD
                                    ,pr_nrtelefo => pr_nrtelefo    --Numero Telefone
                                    ,pr_cdsexotl => pr_cdsexotl    --Sexo
                                    ,pr_nomdamae => pr_nomdamae    --Nome Da Mae
                                    ,pr_temsenha => pr_temsenha    --Verifica se tem senha da internet ativa
                                    ,pr_flgerlog => pr_flgerlog    --Escrever Erro no Log (0=nao, 1=sim)
                                    ,pr_dsiduser => pr_dsiduser    --Identificacao Usuario
                                    ,pr_nmarqimp => vr_nmarqimp    --Nome Arquivo Impressao
                                    ,pr_nmarqpdf => vr_nmarqpdf    --Nome Arquivo pdf
                                    ,pr_cdcritic => vr_cdcritic    --Código da crítica
                                    ,pr_dscritic => vr_dscritic    --Descrição da crítica
                                    ,pr_nmdcampo => pr_nmdcampo    --Nome do Campo
                                    ,pr_des_erro => vr_des_erro);  --Saida OK/NOK      
                                    
      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      ELSE  
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        -- Insere as tags dos campos da PLTABLE de aplicações
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqimp', pr_tag_cont => vr_nmarqimp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarqpdf, pr_des_erro => vr_dscritic);
      END IF;

      --Retorno
      pr_des_erro:= 'OK';    

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;   
               
        -- Existe para satisfazer exigência da interface. 
       	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        --Erro
        pr_cdcritic:= 0;
        -- Chamar rotina de gravação de erro
        pr_dscritic := 'Erro na inss0001.pc_solic_troca_op_cc_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
       	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_solic_troca_op_cc_web;  

  /* Procedure para Solicitar Alteracao Cadastral do beneficiario Modo WEB */
  PROCEDURE pc_solic_alt_cad_benef (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                   ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                   ,pr_cdorgins IN INTEGER                 --Codigo Orgao Pagador
                                   ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                   ,pr_tpnrbene IN VARCHAR2                --Tipo Beneficio
                                   ,pr_tpdpagto IN VARCHAR2                --Tipo de Pagamento
                                   ,pr_dscsitua IN VARCHAR2                --Descricao da Situacao
                                   ,pr_nrdconta IN INTEGER                 --Numero da Conta
                                   ,pr_cdagepac IN INTEGER                 --Codigo Agencia 
                                   ,pr_idbenefi IN INTEGER                 --Identificador do Beneficio
                                   ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                   ,pr_idseqttl IN INTEGER                 --Sequencial Titular
                                   ,pr_nmbairro IN VARCHAR2                --Nome do Bairro
                                   ,pr_nrcepend IN INTEGER                 --Numero CEP
                                   ,pr_dsendere IN VARCHAR2                --Descricao Endereco Residencial
                                   ,pr_nrendere IN INTEGER                 --Numero Endereco
                                   ,pr_nmcidade IN VARCHAR2                --Nome Cidade
                                   ,pr_cdufende IN VARCHAR2                --Codigo UF Titular
                                   ,pr_cdagesic IN INTEGER                 --Codigo Agencia Sicredi
                                   ,pr_nmbenefi IN VARCHAR2                --Nome Beneficiario
                                   ,pr_dtcompvi IN VARCHAR2                --Data Comprovacao Vida
                                   ,pr_nrdddtfc IN INTEGER                 --Numero DDD
                                   ,pr_nrtelefo IN INTEGER                 --Numero Telefone
                                   ,pr_tpdosexo IN VARCHAR2                --Sexo
                                   ,pr_nomdamae IN VARCHAR2                --Nome Da Mae
                                   ,pr_flgerlog IN INTEGER                 --Escrever Erro no Log (0=nao, 1=sim)
                                   ,pr_dsiduser IN VARCHAR2                --Identificacao Usuario
                                   ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER            --Codigo Erro
                                   ,pr_dscritic OUT VARCHAR2               --Descricao Erro
                                   ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK
                                       
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solic_alt_cad_benef
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Marco/2015                           Ultima atualizacao: 21/06/2016
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para Solicitar Alteracao Cadastral do beneficiario modo Web
  
    Alterações : 10/03/2015 - Desenvolvimento (Alisson-AMcom)
    
                 31/03/2015 - Adaptação para esta rotina se chamada apenas pela Web
                             (Adriano).
                 
                 
                 10/04/2015 - Ajuste para retornar o erro corretamente (Adriano).
                 
                 29/05/2015 - Ajustes realizados:                              
                              - Somente enviar o telefone se ele for menor 10 digitos;
                              - Incluido tratamento para obrigar o envio do endereço;
                              (Adriano).
                 
                 23/09/2015 - Adicionado validação dos campos e alterado a nomenclatura do arquivo.
                              (Douglas - Chamado 314031)
                              
                 21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                              (Adriano - SD 473539).
                              
                 23/06/2016 - Incluir nome do módulo logado - (Ana - Envolti - Chamado 664301)
  ---------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
    vr_dscritic2 VARCHAR2(4000); 
    
    vr_dstime    VARCHAR2(100);
    vr_msgenvio  VARCHAR2(32767);
    vr_msgreceb  VARCHAR2(32767);
    vr_movarqto  VARCHAR2(32767);
    vr_nmarqlog  VARCHAR2(32767);
    vr_nmdireto  VARCHAR2(1000);
    vr_des_reto  VARCHAR2(3);
    vr_retornvl  VARCHAR2(3):= 'NOK';
    vr_dstexto   VARCHAR2(32767);
    vr_dsendere  VARCHAR2(1000);
    vr_dstransa  VARCHAR2(1000);
    vr_dsorigem  VARCHAR2(1000);
    vr_nrdrowid  ROWID;
    vr_auxnmarq  VARCHAR2(30);
    vr_des_log   VARCHAR2(1000);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;                                       
    vr_exc_saida EXCEPTION; 
    
    --Tabela Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais
    vr_dtmvtolt DATE;
    vr_nmarqimp VARCHAR2(100);
    vr_nmarqpdf VARCHAR2(100);
    vr_auxconta PLS_INTEGER:= 0;
    
    -- variavel que vai indicar se a mensagem é erro ou alerta - ch 660327    
    vr_cd_tipo_mensagem number (5):= 3; -- Codigo 3 onde na rotina final faz de para gerar 2 erro
        
    BEGIN
      
      --Limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= NULL;
      vr_msgenvio:= NULL;
      vr_msgreceb:= NULL;
      vr_movarqto:= NULL;
      vr_nmarqlog:= NULL;
      vr_dstime:=   NULL;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
              
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_solic_alt_cad_benef');                      
              
      BEGIN                                                  
        --Pega a data movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/YYYY'); 
        
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => vr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
       RAISE vr_exc_erro;
       
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
  
      --Verificar parametros
      IF NVL(pr_nrrecben,0) = 0   OR
         LENGTH(pr_nrrecben) > 10 THEN
        
        --Monta mesangem de critica
        vr_dscritic:= 'NB invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_tpnrbene) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Tido do beneficio invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_nomdamae) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Filiacao invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_cdorgins,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Orgao pagador invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_cdagepac,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Unidade de atendimento invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_tpdpagto) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Tipo de pagamento invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_dscsitua) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Situacao invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_cdagesic,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Agencia SICREDI invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_nrdconta,0) = 0 THEN
        
        --Monta mesangem de critica
        vr_cdcritic:= 9;
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_nrcpfcgc,0) = 0 THEN
        
        --Monta mensagem de critica
        vr_dscritic:= 'CPF invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_idbenefi,0) = 0 THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Codigo do beneficiario invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_cdufende) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'UF invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      
      ELSIF TRIM(pr_nmcidade) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Cidade invalida.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF TRIM(pr_dsendere) IS NULL THEN  
        
        --Monta mensagem de critica
        vr_dscritic:= 'Endereco invalido.';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF;  
        
      --Buscar Diretorio Padrao da Cooperativa
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => null);
                                          
      --Determinar Nomes do Arquivo de Log
      vr_nmarqlog:= 'SICREDI_Soap_LogErros';

      --Buscar o Horario
      vr_dstime:= lpad(gene0002.fn_busca_time,5,'0');
      
      -- Complemento para o Nome do arquivo
      vr_auxnmarq:= LPAD(pr_nrrecben,11,'0')||'.'||
                    vr_dstime ||
                    LPAD(TRUNC(DBMS_RANDOM.Value(0,9999)),4,'0');
                    
      --Determinar Nomes do Arquivo de Envio
      vr_msgenvio:= vr_nmdireto||'/arq/INSS.SOAP.EALTCAD.'||vr_auxnmarq;
                    
      --Determinar Nome do Arquivo de Recebimento    
      vr_msgreceb:= vr_nmdireto||'/arq/INSS.SOAP.RALTCAD.'||vr_auxnmarq;
                    
      --Determinar Nome Arquivo movido              
      vr_movarqto:= vr_nmdireto||'/salvar/inss';
      
      --Bloco Alteracao
      BEGIN
        
        --Gerar cabecalho XML
        inss0001.pc_gera_cabecalho_soap (pr_idservic => 2   /* idservic */ 
                                        ,pr_nmmetodo => 'ben:InAlterarBeneficiarioINSS' --Nome Metodo
                                        ,pr_username => 'app_cecred_client' --Username
                                        ,pr_password => fn_senha_sicredi    --Senha
                                        ,pr_dstexto  => vr_dstexto          --Texto do Arquivo de Dados
                                        ,pr_des_reto => vr_des_reto         --Retorno OK/NOK
                                        ,pr_dscritic => vr_dscritic);       --Descricao da Critica
                                       
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          RAISE vr_exc_saida;
        END IF;

        /*Monta as tags de envio
        OBS.: O valor das tags deve respeitar a formatacao presente na
              base do SICREDI do contrario, a operacao nao sera
              realizada. */
              
        --Montar o logradouro
        IF nvl(pr_nrendere,0) > 0 THEN
          vr_dsendere:= SUBSTR(pr_dsendere,1,30)||','||pr_nrendere;
        ELSE
          vr_dsendere:= SUBSTR(pr_dsendere,1,30);
        END IF;
            
        --Montar o XML      
        vr_dstexto:= vr_dstexto||
            '<ben:Beneficiario NumeroDocumento="'||lpad(pr_nrcpfcgc,11,'0')||'" v1:ID="'||pr_idbenefi||'">'||
               '<v1:Enderecos>'||
                  '<v12:Endereco>'||
                     '<v12:Logradouro>'||
                        '<v12:Nome>'||vr_dsendere||'</v12:Nome>'||
                     '</v12:Logradouro>'||
                     '<v12:Bairro>'||SUBSTR(pr_nmbairro,1,17)||'</v12:Bairro>'||
                     '<v12:Cidade>'||
                        '<v12:Nome>'||pr_nmcidade||'</v12:Nome>'||            
                        '<v12:Estado>'||
                           '<v12:Sigla>'||pr_cdufende||'</v12:Sigla>'||            
                        '</v12:Estado>'|| 
                     '</v12:Cidade>'||            
                     '<v12:CEP>'||pr_nrcepend||'</v12:CEP>'||           
                  '</v12:Endereco>'||
               '</v1:Enderecos>'||
               '<v1:Nome>'||SUBSTR(pr_nmbenefi,1,30)||'</v1:Nome>'||
               '<v1:Filiacao>'||
                  '<v1:NomeMae>'||SUBSTR(pr_nomdamae,1,30)||'</v1:NomeMae>'||            
               '</v1:Filiacao>'||
               '<v1:Sexo>'||pr_tpdosexo||'</v1:Sexo>'||
               '<v1:Contatos>'||
                    '<v1:Telefones>'||
                       '<v13:Telefone>'||                       
                          --Somente vamos enviar o telefone se ele for menor que 10 digitos.
                          '<v13:DDD>'|| CASE WHEN LENGTH(pr_nrtelefo) < 10 THEN pr_nrdddtfc ELSE '' END ||'</v13:DDD>'||
                          '<v13:Numero>'|| CASE WHEN LENGTH(pr_nrtelefo) < 10 THEN pr_nrtelefo ELSE '' END ||'</v13:Numero>'||
                       '</v13:Telefone>'||                        
                    '</v1:Telefones>'||                        
               '</v1:Contatos>'||               
               '<v14:Identificadores>'||
                  '<v14:IdentificadorBeneficiario>'||
                     '<v14:Codigo>'||lpad(pr_nrrecben,10,'0')||'</v14:Codigo>'||                        
                     '<v14:TipoCodigo>'||pr_tpnrbene||'</v14:TipoCodigo>'||                                    
                  '</v14:IdentificadorBeneficiario>'||                        
               '</v14:Identificadores>'||
               '<v14:OrgaoPagador>'||
                  '<v14:NumeroOrgaoPagador>'||pr_cdorgins||'</v14:NumeroOrgaoPagador>'||                        
                  '<v14:Entidade>'||
                     '<v15:NumeroUnidadeAtendimento>2</v15:NumeroUnidadeAtendimento>'||                                    
                  '</v14:Entidade>'||                        
               '</v14:OrgaoPagador>'||
               '<v14:Beneficio>'||
                  '<v16:TipoPagamento>'||pr_tpdpagto||'</v16:TipoPagamento>'||                        
                  '<v16:Situacao>'||pr_dscsitua||'</v16:Situacao>'||                        
               '</v14:Beneficio>'||
               '<v14:Situacao>'||pr_dscsitua||'</v14:Situacao>'||
               '<v14:ContaCorrente>'||
                  '<v17:codigoAgencia>'||pr_cdagesic||'</v17:codigoAgencia>'||                        
                  '<v17:numero>'||SUBSTR(pr_nrdconta,1,LENGTH(pr_nrdconta)-1)||'</v17:numero>'||                        
                  '<v17:digitoVerificador>'||SUBSTR(pr_nrdconta,LENGTH(pr_nrdconta),1)||'</v17:digitoVerificador>'||                                    
               '</v14:ContaCorrente>'||
            '</ben:Beneficiario>'||
            '</ben:InAlterarBeneficiarioINSS>'||
            '</soapenv:Body></soapenv:Envelope>';                      
        
        --Efetuar Requisicao Soap
        inss0001.pc_efetua_requisicao_soap (pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                           ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                           ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                           ,pr_idservic => 1             --Identificador Servico
                                           ,pr_dsservic => 'Alterar'     --Descricao Servico
                                           ,pr_nmmetodo => 'OutAlterarBeneficiarioINSS' --Nome Método
                                           ,pr_dstexto  => vr_dstexto    --Texto com a msg XML
                                           ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                           ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                           ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                           ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo Log
                                           ,pr_nmdatela => vr_nmdatela   --Nome da Tela
                                           ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                           ,pr_dscritic => vr_dscritic); --Descrição Erros
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
          
        --Verifica Falha no Pacote
        inss0001.pc_obtem_fault_packet (pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                       ,pr_nmdatela => vr_nmdatela   --Nome da Tela
                                       ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                       ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                       ,pr_dsderror => 'SOAP-ENV:-950' --Descricao Servico
                                       ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                       ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                       ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                       ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo log
                                       ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                       ,pr_dscritic => vr_dscritic); --Mensagem Erro
                                       
        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
            
          if vr_dscritic LIKE ('%0008%') THEN
                  -- Codigo 1 onde na rotina final faz de para gerar 4 alerta - ch 660327
                  vr_cd_tipo_mensagem := 1; 
          end if;
              
          vr_retornvl:= vr_des_reto;
          RAISE vr_exc_saida;
        END IF;                                
        
        --Retorno OK  
        vr_retornvl:= 'OK';      
                                    
      EXCEPTION
        WHEN vr_exc_saida THEN 
          vr_retornvl:= 'NOK';
      END;  
      
      --Eliminar arquivos requisicao
      inss0001.pc_elimina_arquivos_requis (pr_cdcooper => vr_cdcooper      --Codigo Cooperativa
                                          ,pr_cdprogra => vr_nmdatela      --Nome do Programa
                                          ,pr_msgenvio => vr_msgenvio      --Mensagem Envio
                                          ,pr_msgreceb => vr_msgreceb      --Mensagem Recebimento
                                          ,pr_movarqto => vr_movarqto      --Nome Arquivo mover
                                          ,pr_nmarqlog => vr_nmarqlog      --Nome Arquivo LOG
                                          ,pr_des_reto => vr_des_reto      --Retorno OK/NOK 
                                          ,pr_dscritic => vr_dscritic2);    --Descricao Erro
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        vr_dscritic:= vr_dscritic2;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;     
      
		  --Incluir nome do módulo logado - Chamado 664301
      --Seta novamente esta rotina porque foi alterado dentro da pc_elimina_arquivos_requis
			GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_solic_alt_cad_benef');
      
      --Se for para gerar log
      IF nvl(pr_flgerlog,0) = 1 THEN
        
        --Descricao da Origem e da Transacao
        vr_dsorigem:= gene0001.vr_vet_des_origens(vr_idorigem);
        vr_dstransa:= 'Beneficiario - Alteracao dos dados cadastrais';
      
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => CASE vr_retornvl WHEN 'OK' THEN 1 ELSE 0 END  
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);        
                                   
        -- Gera item de log com informacao nova
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'nrrecben'
                                 ,pr_dsdadant => null
                                 ,pr_dsdadatu => pr_nrrecben);   
                                                                 
      END IF;
      
      --Se ocorreu erro                                              
      IF vr_retornvl <> 'OK' THEN
        
        --Se nao possui mensagem de erro
        IF vr_cdcritic = 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= 'Nao foi possivel realizar a alteracao cadastral do beneficiario.';
        END IF;
        
        --Verificar se possui somente código erro
        IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Gravar Linha Log
        inss0001.pc_retorna_linha_log(pr_cdcooper => vr_cdcooper   --Codigo Cooperativa 
                                     ,pr_cdprogra => vr_nmdatela   --Nome do Programa
                                     ,pr_dtmvtolt => vr_dtmvtolt   --Data Movimento
                                     ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                     ,pr_nrcpfcgc => pr_nrcpfcgc   --Numero Cpf
                                     ,pr_nrrecben => pr_nrrecben   --Numero Recebimento Beneficio
                                     ,pr_nmmetodo => 'Alteracao Cadastral' --Nome do metodo
                                     ,pr_cdderror => vr_cdcritic   --Codigo Erro
                                     ,pr_dsderror => vr_dscritic   --Descricao Erro
                                     ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo LOG
                                     ,pr_cdtipofalha => vr_cd_tipo_mensagem  -- erro ou alerta - ch 6603271
                                     ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                     ,pr_dscritic => vr_dscritic2); --Descricao erro
                                     
         --Se ocorreu erro
         IF vr_des_reto = 'NOK' THEN
           vr_dscritic:= vr_dscritic2;          
         END IF;                            
                                     
         --Gera exceção
         RAISE vr_exc_erro;                                     
                                     
      END IF;
      
      vr_des_log :=   
      'Conta: '    || gene0002.fn_mask(pr_nrdconta,'9999.999-9')  || ' | ' ||
      'Nome: '     || pr_nmbenefi                         || ' | ' ||
      'NB: '       || to_char(pr_nrrecben)                || ' | ' ||
      'operador: ' || to_char(vr_cdoperad)                || ' | ' ||
      'Alteracao: Efetuada alteracao cadastral na conta ' || 
      pr_nrdconta || '.';
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || vr_nmdatela || ' --> ' || 
                                                    'ALERTA: ' || vr_des_log   
                                ,pr_nmarqlog     => 'inss_historico.log'
                                ,pr_flfinmsg     => 'N'
                                ,pr_cdprograma   => vr_nmdatela
                                );
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      -- Insere as tags dos campos da PLTABLE de aplicações
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqimp', pr_tag_cont => vr_nmarqimp, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarqpdf, pr_des_erro => vr_dscritic);

      --Retorno
      pr_des_erro:= vr_retornvl;    

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= vr_retornvl;
        
        --Monta mensagem de erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;          
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        --Monta a mensagem de erro
        pr_cdcritic:= 0;          
        pr_dscritic := 'Erro na inss0001.pc_solic_alt_cad_benef --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     

  END pc_solic_alt_cad_benef; 
  
  /* Procedure para Solicitar Consulta dos Dados do beneficiario */
  PROCEDURE pc_solic_consulta_benef (pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                    ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                    ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                    ,pr_idorigem IN INTEGER                 --Origem Processamento
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%type   --Data Movimento
                                    ,pr_nmdatela IN VARCHAR2                --Nome da tela
                                    ,pr_cdoperad IN VARCHAR2                --Operador
                                    ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                    ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                    ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                    ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2               --Saida OK/NOK
                                    ,pr_tab_beneficiario OUT inss0001.typ_tab_beneficiario --Tabela Beneficiarios
                                    ,pr_tab_erro  OUT gene0001.typ_tab_erro) IS --Tabela Erros
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solic_consulta_benef             Antigo: procedures/b1wgen0091.p/solicita_consulta_beneficiario
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Fevereiro/2015                           Ultima atualizacao: 05/12/2016
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para Solicitar Consulta dos Dados do beneficiario 
  
    Alterações : 27/02/2015 - Conversao Progress -> Oracle (Alisson-AMcom)
    
                 27/03/2015 - Alterado o nome do arquivo de envio/recebimento
                              (Adriano).
                               
                 10/04/2015 - Ajuste para retornar o erro corretamente (Adriano).   
                 
                 29/05/2015 - Ajustes realizados:
                            - Tratar quando o segundo titular não tiver um endereço residencial 
                              cadastradado então, será utilizado o do primeiro titular 
                              independente da relação (Pai, mãe, amigo, etc..) entre ambos;
                            - Quando o telefone do titular tiver mais do que 9 digitos este, 
                              não será pego pois o SICREDI não permiti números superiores;
                            (Adriano).          

                 23/09/2015 - Ajuste na nomenclatura dos arquivos (Douglas - Chamado 314031)
                 
                 15/05/2015 - Alterado forma de leitura do xml, para ler as tags corretas conforme os 
                              nós pais SD313261 (Odirlei-AMcom)
                              
                 21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                              (Adriano - SD 473539).
                              
                 05/12/2016 - Ajustes Incorporação Transulcred -> Transpocred.
                              PRJ342 (Odirlei-AMcom)              
                                               
                 16/06/2017 - Codigo 1 onde na rotina final faz de para gerar 4 alerta - (Belli Envolti) Ch 664301

                 23/06/2016 - Incluir nome do módulo logado - (Ana - Envolti - Chamado 664301)
  ---------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Busca dos dados da cooperativa
    CURSOR cr_cgagesic (pr_cdagesic IN crapcop.cdagesic%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdagesic = pr_cdagesic;
    rw_crabcop cr_cgagesic%ROWTYPE;

    -- Selecionar dados da agencia
    CURSOR cr_crapage (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
    SELECT crapage.cdcooper
          ,crapage.cdorgins
          ,crapage.cdagenci
          ,crapage.nmresage
      FROM crapage crapage
     WHERE crapage.cdcooper = pr_cdcooper
       AND crapage.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;
        
    --Selecionar Conta Associado
    CURSOR cr_crapass2 (pr_cdcooper IN crapass.cdcooper%type
                      ,pr_nrdconta IN crapass.nrdconta%type) IS
    SELECT crapass.nrcpfcgc
          ,crapass.cdcooper
          ,crapass.nrdconta
          ,crapass.cdagenci
      FROM crapass crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
    rw_crapass2 cr_crapass2%ROWTYPE;

    -- cadastro de contas transferidas entre cooperativas
    CURSOR cr_craptco(pr_cdcopant IN craptco.cdcopant%TYPE
                     ,pr_cdcooper IN craptco.cdcopant%TYPE
                     ,pr_nrdconta IN craptco.nrctaant%TYPE) IS
    SELECT craptco.cdcooper
          ,craptco.nrdconta
          ,craptco.cdagenci
     FROM craptco craptco
     WHERE craptco.cdcopant = pr_cdcopant
       AND craptco.nrctaant = pr_nrdconta
       AND craptco.cdcooper = pr_cdcooper            
       AND craptco.tpctatrf = 1
       AND craptco.flgativo = 1 --true
     UNION
    SELECT craptco.cdcooper
          ,craptco.nrdconta
          ,craptco.cdagenci
     FROM craptco craptco
    WHERE craptco.cdcopant = pr_cdcopant
      AND craptco.nrdconta = pr_nrdconta
      AND craptco.cdcooper = pr_cdcooper
      AND craptco.tpctatrf = 1
      AND craptco.flgativo = 1; --true
    rw_craptco cr_craptco%ROWTYPE;    

    -- Buscar Titular
    CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                      ,pr_nrdconta IN crapttl.nrdconta%type
                      ,pr_nrcpfcgc IN crapttl.nrcpfcgc%type) IS
    SELECT ttl.cdcooper
          ,ttl.nrdconta
          ,ttl.idseqttl 
          ,ttl.nmextttl
          ,ttl.nrcpfcgc
     FROM crapttl ttl
    WHERE ttl.cdcooper = pr_cdcooper
      AND ttl.nrdconta = pr_nrdconta
      AND ttl.nrcpfcgc = pr_nrcpfcgc;
    rw_crapttl cr_crapttl%ROWTYPE;      
    
    -- Buscar Titular
    CURSOR cr_crapttl2(pr_cdcooper IN crapttl.cdcooper%type                      
                      ,pr_nrcpfcgc IN crapttl.nrcpfcgc%type) IS
    SELECT ttl.cdcooper
          ,ttl.nrdconta
          ,ttl.idseqttl 
          ,ttl.nmextttl
          ,ttl.nrcpfcgc
     FROM crapttl ttl
    WHERE ttl.cdcooper = pr_cdcooper
      AND ttl.nrcpfcgc = pr_nrcpfcgc;
    rw_crapttl2 cr_crapttl2%ROWTYPE;   

    --Selecionar Telefones
    CURSOR cr_craptfc (pr_cdcooper IN crapttl.cdcooper%type 
                      ,pr_nrdconta IN crapttl.nrdconta%type
                      ,pr_idseqttl IN crapttl.idseqttl%type
                      ,pr_tptelefo IN craptfc.tptelefo%type) IS
    SELECT /*+ INDEX_ASC(craptfc CRAPTFC##CRAPTFC1) */
           craptfc.nrdddtfc
          ,craptfc.nrtelefo                
     FROM craptfc craptfc
     WHERE craptfc.cdcooper = pr_cdcooper 
       AND craptfc.nrdconta = pr_nrdconta 
       AND craptfc.idseqttl = pr_idseqttl 
       AND craptfc.tptelefo = pr_tptelefo;
    rw_craptfc cr_craptfc%ROWTYPE;        

    --Selecionar Enderecos
    CURSOR cr_crapenc (pr_cdcooper IN crapttl.cdcooper%type 
                      ,pr_nrdconta IN crapttl.nrdconta%type
                      ,pr_idseqttl IN crapttl.idseqttl%type
                      ,pr_tpendass IN crapenc.tpendass%type) IS
   SELECT /*+ INDEX_DESC(crapenc CRAPENC##CRAPENC2) */
           crapenc.nmbairro
          ,crapenc.nmcidade
          ,crapenc.nrcepend
          ,crapenc.cdufende
          ,crapenc.dsendere
          ,crapenc.nrendere                
      FROM crapenc crapenc
     WHERE crapenc.cdcooper = pr_cdcooper 
       AND crapenc.nrdconta = pr_nrdconta 
       AND crapenc.idseqttl = pr_idseqttl 
       AND crapenc.tpendass = pr_tpendass;
    rw_crapenc cr_crapenc%ROWTYPE;        

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
    vr_dscritic2 VARCHAR2(4000); 

    --Variaveis Locais    
    vr_inpessoa  INTEGER;
    vr_qtlinha   INTEGER;
    vr_nrcpfcgc  NUMBER;
    vr_cdcooper  INTEGER;
    vr_cdcopant  INTEGER;
    vr_nrdconta  INTEGER;
    vr_dstime    VARCHAR2(100);
    vr_msgenvio  VARCHAR2(32767);
    vr_msgreceb  VARCHAR2(32767);
    vr_movarqto  VARCHAR2(32767);
    vr_nmarqlog  VARCHAR2(32767);
    vr_nmdireto  VARCHAR2(1000);
    vr_des_reto  VARCHAR2(3);
    vr_retornvl  VARCHAR2(3):= 'NOK';
    vr_dstexto   VARCHAR2(32767);    
    vr_nmparam   VARCHAR2(1000);
    vr_nmparpai  VARCHAR2(1000);
    vr_stsnrcal  BOOLEAN;
    vr_dig       VARCHAR2(1);
    vr_crapenc   BOOLEAN:=FALSE;
    vr_auxnmarq  VARCHAR2(30);
    
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis DOM
    vr_xmlparser  dbms_xmlparser.Parser;    
    vr_xmldoc     xmldom.DOMDocument;
    vr_lista_nodo DBMS_XMLDOM.DOMNodelist;
    vr_lista_nodo_2 DBMS_XMLDOM.DOMNodelist;
    vr_lista_nodo_3 DBMS_XMLDOM.DOMNodelist;
    vr_nodo       xmldom.DOMNode;
    vr_nodo_pai   xmldom.DOMNode;
    vr_elemento   xmldom.DOMElement;
        
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
    vr_exc_saida EXCEPTION; 
        
    -- variavel que vai indicar se a mensagem é erro ou alerta - ch 660327    
    vr_cd_tipo_mensagem number (5):= 3; -- Codigo 3 onde na rotina final faz de para gerar 2 erro
    
    BEGIN
		  -- Incluir nome do módulo logado
			GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_solic_consulta_benef');      
      
      --limpar tabela erros
      pr_tab_erro.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      vr_msgenvio:= null;
      vr_msgreceb:= null;
      vr_movarqto:= null;
      vr_nmarqlog:= null;
      vr_dstime:=   null;
        
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
       RAISE vr_exc_erro;
       
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
  
      --Verificar parametros
      IF NVL(pr_nrrecben,0)  = 0  OR
         LENGTH(pr_nrrecben) > 10 THEN
        
        vr_dscritic:= 'Beneficiario invalido.';
        pr_nmdcampo:= 'nrrecben';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSIF nvl(pr_nrcpfcgc,0) <> 0 THEN
        
        --Verificar se tem conta em alguma cooperativa
        OPEN cr_crapttl2(pr_cdcooper => pr_cdcooper
                        ,pr_nrcpfcgc => pr_nrcpfcgc);
        
        FETCH cr_crapttl2 INTO rw_crapttl2;
        
        --Se nao tem conta
        IF cr_crapttl2%NOTFOUND THEN
          
          --Fechar Cursor
          CLOSE cr_crapttl2;
          
          vr_cdcritic:= 9;          
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
          pr_nmdcampo:= 'nrcpfcgc';
          
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE  
          --Fechar Cursor
          CLOSE cr_crapttl2;          
        END IF;
        
      END IF;
        
      --Buscar Diretorio Padrao da Cooperativa
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => null);
                                          
      --Determinar Nomes do Arquivo de Log
      vr_nmarqlog:= 'SICREDI_Soap_LogErros';

      --Buscar o Horario
      vr_dstime:= lpad(gene0002.fn_busca_time,5,'0');
      
      -- Complemento para o Nome do arquivo
      vr_auxnmarq:= LPAD(pr_nrrecben,11,'0')||'.'||
                    vr_dstime ||
                    LPAD(TRUNC(DBMS_RANDOM.Value(0,9999)),4,'0');
                    
      --Determinar Nomes do Arquivo de Envio
      vr_msgenvio:= vr_nmdireto||'/arq/INSS.SOAP.ECONBEN.'||vr_auxnmarq;
                    
      --Determinar Nome do Arquivo de Recebimento    
      vr_msgreceb:= vr_nmdireto||'/arq/INSS.SOAP.RCONBEN.'||vr_auxnmarq;
                    
      --Determinar Nome Arquivo movido              
      vr_movarqto:= vr_nmdireto||'/salvar/inss';
      
      --Bloco Consulta
      BEGIN
        
        --Gerar cabecalho XML
        inss0001.pc_gera_cabecalho_soap (pr_idservic => 1   /* idservic */ 
                                        ,pr_nmmetodo => 'ben:InConsultarBeneficiarioINSS' --Nome Metodo
                                        ,pr_username => 'app_cecred_client' --Username
                                        ,pr_password => fn_senha_sicredi    --Senha
                                        ,pr_dstexto  => vr_dstexto          --Texto do Arquivo de Dados
                                        ,pr_des_reto => vr_des_reto         --Retorno OK/NOK
                                        ,pr_dscritic => vr_dscritic);       --Descricao da Critica
                                       
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          RAISE vr_exc_saida;
        END IF;

        /*Monta as tags de envio
        OBS.: O valor das tags deve respeitar a formatacao presente na
              base do SICREDI do contrario, a operacao nao sera realizada. */
              
        --Montar o XML      
        vr_dstexto:= vr_dstexto||
            '<ben:codBeneficiario>'||LPAD(pr_nrrecben,10,'0')||'</ben:codBeneficiario>'||
            '</ben:InConsultarBeneficiarioINSS>'||
            '</soapenv:Body></soapenv:Envelope>';                      
           
        --Efetuar Requisicao Soap
        inss0001.pc_efetua_requisicao_soap (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa 
                                           ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                           ,pr_nrdcaixa => pr_nrdcaixa   --Numero Caixa
                                           ,pr_idservic => 1             --Identificador Servico
                                           ,pr_dsservic => 'Consulta'    --Descricao Servico
                                           ,pr_nmmetodo => 'OutConsultarBeneficiarioINSS' --Nome Método
                                           ,pr_dstexto  => vr_dstexto    --Texto com a msg XML
                                           ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                           ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                           ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                           ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo Log
                                           ,pr_nmdatela => pr_nmdatela   --Nome da Tela
                                           ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                           ,pr_dscritic => vr_dscritic); --Descrição Erros
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Levantar Excecao
            
          -- Codigo 1 onde na rotina final faz de para gerar 4 alerta - ch 664301
          vr_cd_tipo_mensagem := 1; 
            
          RAISE vr_exc_saida;
        END IF;
          
        /*O xml que vamos receber do SICREDI, nesta operacao, possui duas 
        premissas referente a erros:
          1) Quando eh pesquisado um beneficiario valido, ja existente, porem
             nao ha dados cadastrais, o retorno sera vazio (recebemos um xml 
             sem a tag "Beneficiario"). 
          2) Quando eh informado um beneficiario invalido, nao existente, sera
             retornado um xml com as tags de erro indicando que este, foi um 
             problema de base. 
             
        Esta distincao eh importante ao SICREDI para facilitar a identificacao
        do problema.
        
        Apenas na consulta, através da tela INSS (Opçção "C") se o retorno
        do SICREDI for a premissa 2 então, iremos retornar uma critica informando
        que não foi encontrado o beneficiário. Do contrário, vamos retornar como
        "OK".
        */ 
        
        --Verifica Falha no Pacote
        inss0001.pc_obtem_fault_packet (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa 
                                       ,pr_nmdatela => pr_nmdatela   --Nome da Tela
                                       ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                       ,pr_nrdcaixa => pr_nrdcaixa   --Numero Caixa
                                       ,pr_dsderror => '0000'        --Premissa 2 (Descricao Servico)
                                       ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                       ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                       ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                       ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo log
                                       ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                       ,pr_dscritic => vr_dscritic); --Mensagem Erro
                                       
        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          vr_retornvl:= vr_des_reto;
          RAISE vr_exc_saida;
        END IF;                                
        
        /* Precisamos instanciar o Parser e efetuar a conversão do XML local para o XMLDOm usando UTF-8
           pois o SICREDI, esta nos enviando informações com acentuação em outro tipo de enconding*/
        vr_xmlparser := dbms_xmlparser.newParser;
        dbms_xmlparser.parse(vr_xmlparser,vr_msgreceb,nls_charset_id('UTF8'));
        vr_xmldoc := dbms_xmlparser.getDocument(vr_xmlparser);
        dbms_xmlparser.freeParser(vr_xmlparser);

        --Lista de nodos
        vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'Beneficiario');
          
        --Se nao existir a tag "Beneficiario" 
        IF xmldom.getLength(vr_lista_nodo) = 0 THEN
          
          /*Se for consulta ou demontrativo, via tela INSS - WEB e o retorno do SICREDI for a premissa 1 então,
            será retornado a critica abaixo. Do contrário vamos retornar com "OK" por considerarmos
            que o beneficio não existe.
            Isto foi acordado com a COMPE para evitar o problema durante a troca de PA através da
            tela CONTAS para os beneficiários que são excluidos da base do SICREDI após 90 dias 
            sem movimentação. Consequentemente, no momento da troca de PA recebiamos o retorno do
            SICREDI de acordo com a premissa 2 e a operação de troca era abortada.  */
          IF (pr_cddopcao = 'C'  OR 
              pr_cddopcao = 'D') AND 
              pr_idorigem = 5    THEN
            
            --Monta mensagem de critica
            vr_dscritic:= 'Beneficiario nao encontrado.';
            
            -- Codigo 1 onde na rotina final faz de para gerar 4 alerta - ch 660327
            vr_cd_tipo_mensagem := 1; 
            
            --Levantar Excecao
            RAISE vr_exc_saida;
                        
          END IF;  
          
          --Levantar Excecao
          RAISE vr_exc_ok;
          
        END IF; 
        
        ---> Ler tags
        FOR vr_linha IN 0..xmldom.getLength (vr_lista_nodo) - 1 LOOP 
        
          --Buscar Nodo do benificiario
          vr_nodo:= xmldom.item(vr_lista_nodo,vr_linha);
          
          --Incrementar Contador
          vr_index:= pr_tab_beneficiario.COUNT + 1;
              
          --Buscar Atributos
          vr_elemento:= xmldom.makeElement(vr_nodo);
                
          --Identificador beneficiario
          pr_tab_beneficiario(vr_index).idbenefi:= to_number(xmldom.getAttribute(vr_elemento,'ID'));
               
          --CPF Beneficiario
          vr_nrcpfcgc:= to_number(xmldom.getAttribute(vr_elemento,'NumeroDocumento'));
              
          --Validar o CPF
          gene0005.pc_valida_cpf_cnpj (pr_nrcalcul => vr_nrcpfcgc   --Numero a ser verificado
                                      ,pr_stsnrcal => vr_stsnrcal   --Situacao
                                      ,pr_inpessoa => vr_inpessoa); --Tipo Inscricao Cedente
              
          --Numero do CPF/CNPJ
          pr_tab_beneficiario(vr_index).nrcpfcgc:= gene0002.fn_mask_cpf_cnpj(vr_nrcpfcgc,vr_inpessoa);              
          
          --> Buscar filhos benificiario
          vr_lista_nodo_2:= xmldom.GETCHILDRENBYTAGNAME(vr_elemento,'*'); 
          FOR vr_linha_2 IN 0..xmldom.getLength (vr_lista_nodo_2) - 1 LOOP
            
            --Buscar Nodo filho
            vr_nodo:= xmldom.item(vr_lista_nodo_2,vr_linha_2);
            --Nome Parametro Nodo corrente
            vr_nmparam := xmldom.getNodeName(vr_nodo);
            
            --Buscar somente sufixo (o que tem apos o caracter :)
            vr_nmparam := SUBSTR(vr_nmparam,instr(vr_nmparam,':')+1);
            
            CASE vr_nmparam
              WHEN 'DataCadastro' THEN        
                vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                --Se possuir informacao
                IF instr(xmldom.getNodeValue(vr_nodo),'4713') = 0 THEN
                  --Data Cadastro
                  pr_tab_beneficiario(vr_index).dtdcadas:= to_date(xmldom.getNodeValue(vr_nodo),'YYYY-MM-DD-HH24:MI');
                END IF;
                
              WHEN 'Nome' THEN
                vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                --Nome beneficiario
                pr_tab_beneficiario(vr_index).nmbenefi:= xmldom.getNodeValue(vr_nodo);                
              WHEN 'Sexo' THEN
                vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                --Sexo do Beneficiario
                pr_tab_beneficiario(vr_index).tpdosexo:= xmldom.getNodeValue(vr_nodo);
              WHEN 'Situacao' THEN
                vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                --Situacao Beneficio
                pr_tab_beneficiario(vr_index).dscsitua:= xmldom.getNodeValue(vr_nodo);  
              WHEN 'DataNascimento' THEN
                vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                --Se possuir informacao  
                IF instr(xmldom.getNodeValue(vr_nodo),'4713') = 0 THEN
                  --Data Nascimento Beneficiario
                  pr_tab_beneficiario(vr_index).dtdnasci:= to_date(xmldom.getNodeValue(vr_nodo),'YYYY-MM-DD-HH24:MI');
                END IF;
              WHEN 'DiaUtilPagamento' THEN
                vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                --Dia util Pagamento
                pr_tab_beneficiario(vr_index).dtutirec:= xmldom.getNodeValue(vr_nodo);  
                
              WHEN 'Enderecos' THEN
                /*Buscar nos filhos do endereco*/
                vr_elemento  := xmldom.makeElement(vr_nodo);
                vr_lista_nodo_3:= xmldom.getElementsByTagName(vr_elemento,'*');
                
                FOR vr_linha_3 IN 0..xmldom.getLength (vr_lista_nodo_3) - 1 LOOP
                  --Buscar Nodo filho
                  vr_nodo:= xmldom.item(vr_lista_nodo_3,vr_linha_3);
                  
                  --Nome Parametro Nodo corrente
                  vr_nmparam := xmldom.getNodeName(vr_nodo);
                  
                  --Buscar somente sufixo (o que tem apos o caracter :)
                  vr_nmparam := SUBSTR(vr_nmparam,instr(vr_nmparam,':')+1);  
                  
                  CASE vr_nmparam 
                    WHEN 'Nome' THEN                
                      -- Retorna a tag principal no Nodo Pai
                      vr_nodo_pai:= xmldom.getParentNode(vr_nodo);
                      --Nome Parametro Nodo Pai
                      vr_nmparpai:= xmldom.getNodeName(vr_nodo_pai);
                      vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                      
                      --Verificar se pai eh tag Logradouro
                      IF instr(vr_nmparpai,'Logradouro') > 0 THEN
                        pr_tab_beneficiario(vr_index).dsendere:= xmldom.getNodeValue(vr_nodo); 
                      ELSIF instr(vr_nmparpai,'Cidade') > 0 THEN
                        pr_tab_beneficiario(vr_index).nmcidade:= xmldom.getNodeValue(vr_nodo);                      
                      END IF; 
                      
                    WHEN 'Bairro' THEN  
                      vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                      pr_tab_beneficiario(vr_index).nmbairro:= xmldom.getNodeValue(vr_nodo);  
                    WHEN 'Sigla' THEN  
                      --Sigla do Estado
                      vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                      pr_tab_beneficiario(vr_index).cdufende:= xmldom.getNodeValue(vr_nodo);
                    WHEN 'CEP' THEN
                      --Cep Endereco
                      vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                      pr_tab_beneficiario(vr_index).nrcepend:= xmldom.getNodeValue(vr_nodo);
                    WHEN 'ResideDesde' THEN
                        
                      /*O SICREDI esta nos enviando a data de validade do 
                        procurador atraves da tag "ResideDesde"*/
                      --Se possuir informacao
                      IF instr(xmldom.getNodeValue(vr_nodo),'4713') = 0 THEN
                        --Data Validade Procuracao
                        vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                        pr_tab_beneficiario(vr_index).resdesde:= to_date(xmldom.getNodeValue(vr_nodo),'YYYY-MM-DD-HH24:MI');
                      END IF;   
                      
                    ELSE NULL;
                  END CASE;
                END LOOP; 
                -----> FIM ENDEREÇOS
                
              WHEN 'Filiacao' THEN
                /*Buscar nos filhos da filiacao */
                vr_lista_nodo_3:= DBMS_XMLDOM.GETCHILDNODES(vr_nodo);
                FOR vr_linha_3 IN 0..xmldom.getLength (vr_lista_nodo_3) - 1 LOOP
                  
                  --ler Nodo filho
                  vr_nodo:= xmldom.item(vr_lista_nodo_3,vr_linha_3);
                  --Nome Parametro Nodo corrente
                  vr_nmparam := xmldom.getNodeName(vr_nodo);
                  
                  --Buscar somente sufixo (o que tem apos o caracter :)
                  vr_nmparam := SUBSTR(vr_nmparam,instr(vr_nmparam,':')+1);  
                  vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                  
                  IF vr_nmparam = 'NomeMae' THEN
                    --Nome Mae do Beneficiario
                    pr_tab_beneficiario(vr_index).nomdamae:= xmldom.getNodeValue(vr_nodo);
                  END IF;
                END LOOP;  
                --- FIM FILIACAO
                
              WHEN 'Contatos' THEN
                /*Buscar nos filhos do endereco*/
                vr_elemento  := xmldom.makeElement(vr_nodo);
                vr_lista_nodo_3:= xmldom.getElementsByTagName(vr_elemento,'*');
                
                FOR vr_linha_3 IN 0..xmldom.getLength (vr_lista_nodo_3) - 1 LOOP
                  --Buscar Nodo filho
                  vr_nodo:= xmldom.item(vr_lista_nodo_3,vr_linha_3);
                  
                  --Nome Parametro Nodo corrente
                  vr_nmparam := xmldom.getNodeName(vr_nodo);
                  
                  --Buscar somente sufixo (o que tem apos o caracter :)
                  vr_nmparam := SUBSTR(vr_nmparam,instr(vr_nmparam,':')+1);  
                  vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                  
                  CASE vr_nmparam  
                    WHEN 'DDD' THEN
                      --Numero DDD do telefone
                      pr_tab_beneficiario(vr_index).nrdddtfc:= xmldom.getNodeValue(vr_nodo);
                    WHEN 'Numero' THEN  
                      pr_tab_beneficiario(vr_index).nrtelefo:= xmldom.getNodeValue(vr_nodo);
                    ELSE NULL;
                  END CASE; 
                END LOOP;  
                --> FIM CONTATOS
                
              WHEN 'Identificadores' THEN
                /*Buscar nos filhos do Identificadores*/
                vr_elemento  := xmldom.makeElement(vr_nodo);
                vr_lista_nodo_3:= xmldom.getElementsByTagName(vr_elemento,'*');
                
                FOR vr_linha_3 IN 0..xmldom.getLength (vr_lista_nodo_3) - 1 LOOP
                  --Buscar Nodo filho
                  vr_nodo:= xmldom.item(vr_lista_nodo_3,vr_linha_3);                  
                  
                  --Nome Parametro Nodo corrente
                  vr_nmparam := xmldom.getNodeName(vr_nodo);
                  
                  --Buscar somente sufixo (o que tem apos o caracter :)
                  vr_nmparam := SUBSTR(vr_nmparam,instr(vr_nmparam,':')+1);  
                  vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                  
                  CASE vr_nmparam  
                    WHEN 'Codigo' THEN
                      --Codigo Identificador Beneficiario
                      pr_tab_beneficiario(vr_index).nrrecben:= xmldom.getNodeValue(vr_nodo);
                    WHEN 'TipoCodigo' THEN  
                      --Tipo Identificador Beneficio                  
                      pr_tab_beneficiario(vr_index).tpnrbene:= xmldom.getNodeValue(vr_nodo);
                    ELSE NULL;
                  END CASE; 
                END LOOP;  
                --> FIM IDENTIFICADORES    
              
              WHEN 'OrgaoPagador' THEN
                /*Buscar nos filhos do OrgaoPagador*/
                vr_elemento  := xmldom.makeElement(vr_nodo);
                vr_lista_nodo_3:= xmldom.getElementsByTagName(vr_elemento,'*');
                
                FOR vr_linha_3 IN 0..xmldom.getLength (vr_lista_nodo_3) - 1 LOOP
                  --Buscar Nodo filho
                  vr_nodo:= xmldom.item(vr_lista_nodo_3,vr_linha_3);
                  
                  --Nome Parametro Nodo corrente
                  vr_nmparam := xmldom.getNodeName(vr_nodo);
                  
                  --Buscar somente sufixo (o que tem apos o caracter :)
                  vr_nmparam := SUBSTR(vr_nmparam,instr(vr_nmparam,':')+1);  
                  vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                  
                  CASE vr_nmparam  
                    WHEN 'NumeroOrgaoPagador' THEN
                      --Numero do Orgao Pagador
                      pr_tab_beneficiario(vr_index).cdorgins:= xmldom.getNodeValue(vr_nodo);
                    WHEN 'CodigoCooperativa' THEN
                      --Codigo Cooperativa
                      pr_tab_beneficiario(vr_index).cdcopsic:= xmldom.getNodeValue(vr_nodo);
                    WHEN 'NumeroUnidadeAtendimento' THEN
                      --Numero Unidade Atendimento
                      pr_tab_beneficiario(vr_index).cdagepac:= xmldom.getNodeValue(vr_nodo);
                    ELSE NULL;
                  END CASE; 
                END LOOP;  
                --> FIM ORGAOPAGADOR
                
              WHEN 'Procurador' THEN
                /*Buscar nos filhos do endereco*/
                vr_elemento  := xmldom.makeElement(vr_nodo);
                vr_lista_nodo_3:= xmldom.getElementsByTagName(vr_elemento,'*');
                
                FOR vr_linha_3 IN 0..xmldom.getLength (vr_lista_nodo_3) - 1 LOOP
                  --Buscar Nodo filho
                  vr_nodo:= xmldom.item(vr_lista_nodo_3,vr_linha_3);
                  
                  --Nome Parametro Nodo corrente
                  vr_nmparam := xmldom.getNodeName(vr_nodo);
                  
                  --Buscar somente sufixo (o que tem apos o caracter :)
                  vr_nmparam := SUBSTR(vr_nmparam,instr(vr_nmparam,':')+1);  
                  vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                  
                  CASE vr_nmparam  
                    WHEN 'Nome' THEN
                      --Nome Procurador
                      pr_tab_beneficiario(vr_index).nmprocur:= xmldom.getNodeValue(vr_nodo);
                    ELSE NULL;
                  END CASE; 
                END LOOP;  
                --> FIM PROCURADOR
                
              WHEN 'Beneficio' THEN
                /*Buscar nos filhos do endereco*/
                vr_elemento  := xmldom.makeElement(vr_nodo);
                vr_lista_nodo_3:= xmldom.getElementsByTagName(vr_elemento,'*');
                
                FOR vr_linha_3 IN 0..xmldom.getLength (vr_lista_nodo_3) - 1 LOOP
                  --Buscar Nodo filho
                  vr_nodo:= xmldom.item(vr_lista_nodo_3,vr_linha_3);
                  
                  --Nome Parametro Nodo corrente
                  vr_nmparam := xmldom.getNodeName(vr_nodo);
                  
                  --Buscar somente sufixo (o que tem apos o caracter :)
                  vr_nmparam := SUBSTR(vr_nmparam,instr(vr_nmparam,':')+1);  
                  vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                  
                  CASE vr_nmparam  
                    WHEN 'TipoPagamento' THEN
                      --Tipo de Pagamento
                      pr_tab_beneficiario(vr_index).tpdpagto:= xmldom.getNodeValue(vr_nodo);
                    WHEN 'Especie' THEN
                      --Especie do Beneficio
                      pr_tab_beneficiario(vr_index).dscespec:= xmldom.getNodeValue(vr_nodo);
                    ELSE NULL;
                  END CASE; 
                END LOOP;  
                --> FIM BENEFICIO
              WHEN 'ContaCorrente' THEN
                /*Buscar nos filhos do ContaCorrente*/
                vr_elemento  := xmldom.makeElement(vr_nodo);
                vr_lista_nodo_3:= xmldom.getElementsByTagName(vr_elemento,'*');
                
                FOR vr_linha_3 IN 0..xmldom.getLength (vr_lista_nodo_3) - 1 LOOP
                  --Buscar Nodo filho
                  vr_nodo:= xmldom.item(vr_lista_nodo_3,vr_linha_3);
                  
                  --Nome Parametro Nodo corrente
                  vr_nmparam := xmldom.getNodeName(vr_nodo);
                  
                  --Buscar somente sufixo (o que tem apos o caracter :)
                  vr_nmparam := SUBSTR(vr_nmparam,instr(vr_nmparam,':')+1);  
                  vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                  
                  CASE vr_nmparam  
                    WHEN'codigoAgencia' THEN
                      --Codigo Agencia
                      pr_tab_beneficiario(vr_index).cdagesic:= xmldom.getNodeValue(vr_nodo);
                    WHEN 'numero' THEN
                      --Conta Corrente
                      pr_tab_beneficiario(vr_index).nrdconta:= xmldom.getNodeValue(vr_nodo);
                    WHEN 'digitoVerificador' THEN  

                      --Digito Verificador
                      vr_dig:= xmldom.getNodeValue(vr_nodo);
                      pr_tab_beneficiario(vr_index).digdacta:= vr_dig;
                        
                      --Conta Corrente com Digito
                      pr_tab_beneficiario(vr_index).nrdconta:= to_number(pr_tab_beneficiario(vr_index).nrdconta||vr_dig);
                    
                    ELSE NULL;
                  END CASE; 
                END LOOP;  
                --> FIM CONTACORRENTE
              
              WHEN 'ProvaVida' THEN
                --Buscar nos filhos do nó ProvaVida
                vr_elemento  := xmldom.makeElement(vr_nodo);
                vr_lista_nodo_3:= xmldom.getElementsByTagName(vr_elemento,'*');
                vr_nmparam := xmldom.getLength (vr_lista_nodo_3); 
                FOR vr_linha_3 IN 0..xmldom.getLength (vr_lista_nodo_3) - 1 LOOP
                  --Buscar Nodo filho
                  vr_nodo:= xmldom.item(vr_lista_nodo_3,vr_linha_3);
                  
                  --Nome Parametro Nodo corrente
                  vr_nmparam := xmldom.getNodeName(vr_nodo);
                  
                  --Buscar somente sufixo (o que tem apos o caracter :)
                  vr_nmparam := SUBSTR(vr_nmparam,instr(vr_nmparam,':')+1);  
                  vr_nodo:= xmldom.getFirstChild(vr_nodo);  
                  
                  CASE vr_nmparam
                    WHEN 'DataVencimento' THEN
                      --Se possui informacao
                      IF instr(xmldom.getNodeValue(vr_nodo),'4713') = 0 THEN
                        --Data Vencimento Prova Vida
                        pr_tab_beneficiario(vr_index).dtdvenci:= to_date(xmldom.getNodeValue(vr_nodo),'YYYY-MM-DD-HH24:MI');
                      END IF;

                    WHEN 'DataAtualizacao' THEN
                      
                      --Se possui informacao
                      IF instr(xmldom.getNodeValue(vr_nodo),'4713') = 0 THEN
                        --Data Vencimento Prova Vida
                        pr_tab_beneficiario(vr_index).dtcompvi:= to_date(xmldom.getNodeValue(vr_nodo),'YYYY-MM-DD-HH24:MI');
                      END IF;
                    ELSE NULL;
                  END CASE;
                END LOOP;  
                --> FIM PROVAVIDA  
                
              ELSE NULL;
            END CASE;  
            
          END LOOP; --> Fim nós Filhos Benificiario
        END LOOP; --> Fim loop Benificiario
        
        
        vr_lista_nodo := DBMS_XMLDOM.getElementsByTagName(vr_xmldoc, 'statusCadastro'); 
        FOR vr_linha IN 0..xmldom.getLength (vr_lista_nodo) - 1 LOOP 
           --Buscar Nodo Corrente
            vr_nodo:= xmldom.item(vr_lista_nodo,vr_linha);
                        
            --Nome Parametro Nodo corrente
            vr_nmparam := xmldom.getNodeName(vr_nodo);
              
            --Buscar somente sufixo (o que tem apos o caracter :)
            vr_nmparam:= SUBSTR(vr_nmparam,instr(vr_nmparam,':')+1);
            vr_nodo   := xmldom.getFirstChild(vr_nodo);
            pr_tab_beneficiario(vr_index).stacadas:= xmldom.getNodeValue(vr_nodo);
          
        END LOOP;
       
        /* Validar Informacoes */
        
        -- Verifica se a cooperativa esta cadastrada
        OPEN cr_cgagesic (pr_cdagesic => pr_tab_beneficiario(vr_index).cdcopsic);
        
        FETCH cr_cgagesic INTO rw_crabcop;
        
        -- Se não encontrar
        IF cr_cgagesic%NOTFOUND THEN
          
          -- Fechar o cursor pois haverá raise
          CLOSE cr_cgagesic;
          
          /*Quando for troca de domicilio e consultamos um NB de outra
               instituicao que ja esteja cadastrado na base do SICREDI,
               temos que despreza-lo conforme abaixo pois, na tela INSS, 
               iremos apresentar que este eh de outra instituicao.
               Os dados a serem enviados para cadastro do NB em questao 
               serao os da conta informada na tela. */
               
          --Se for Troca de Domicilio
          IF pr_cddopcao = 'T' THEN 
            --Limpar tabela Beneficiario
            pr_tab_beneficiario.DELETE;
            --Levantar Excecao OK
            RAISE vr_exc_ok;    
          ELSE  
            -- Montar mensagem de critica
            vr_cdcritic := 794;
            
            --Nome campo Critica
            pr_nmdcampo:= 'nrcpfcgc';
            
            -- Busca critica
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
            RAISE vr_exc_saida;
            
          END IF;  
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_cgagesic;
        END IF;
        /*
        O SICREDI alterou apenas a cooperativa dos beneficiarios migrados
        deixando estes, com a conta da concredi. Desta forma, foi necessario
        realizar a verificacao abaixo para contornar a situacao
        ate que o SICREDI efetue o cadastro para a nova conta.
        1 - 201 775431
        2 - 202 775448
        Verifica se eh um OP da Concredi migrado para Viacredi
        ou da Transulcred migrado para Transpocred*/
        
        IF pr_tab_beneficiario(vr_index).cdorgins IN (775431,775448,787028,801241) THEN
          --> Atribuir codigo da cooperativa anterior
          IF pr_cdcooper = 1 THEN
            vr_cdcopant := 4;
          ELSIF pr_cdcooper = 9 THEN
            vr_cdcopant := 17;
          END IF;          
                  
          /*Verifica se o beneficiario eh um cooperado migrado da: 
             - Concredi para Viacredi.
             - Transulcred para Transpocred */
          OPEN cr_craptco(pr_cdcopant => vr_cdcopant
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_tab_beneficiario(vr_index).nrdconta);
                         
          FETCH cr_craptco INTO rw_craptco;
          
          --Se Encontrou
          IF cr_craptco%FOUND THEN
            
            --Fechar Cursor
            CLOSE cr_craptco;
            
            --Valores Encontrados
            vr_cdcooper:= rw_craptco.cdcooper;
            vr_nrdconta:= rw_craptco.nrdconta;
            
            --Selecionar Agencia
            OPEN cr_crapage (pr_cdcooper => rw_craptco.cdcooper
                            ,pr_cdagenci => rw_craptco.cdagenci);
                            
            FETCH cr_crapage INTO rw_crapage;
            
            --Se nao encontrou
            IF cr_crapage%NOTFOUND THEN
              
              --Fechar Cursor  
              CLOSE cr_crapage;      
                  
              vr_cdcritic:= 962;
              vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
              pr_nmdcampo:= 'nrcpfcgc';
              
              --Levantar Excecao
              RAISE vr_exc_saida;
            ELSE
              --Fechar Cursor  
              CLOSE cr_crapage;          
            END IF;  
          ELSE
            --Fechar Cursor
            CLOSE cr_craptco;
            
            --Valores Encontrados
            vr_cdcooper:= rw_crabcop.cdcooper;
            vr_nrdconta:= pr_tab_beneficiario(vr_index).nrdconta;
            
            --Verificar se tem conta em alguma cooperativa
            OPEN cr_crapass2 (pr_cdcooper => vr_cdcooper
                             ,pr_nrdconta => vr_nrdconta);
                             
            FETCH cr_crapass2 INTO rw_crapass2;
            
            --Se nao tem conta
            IF cr_crapass2%NOTFOUND THEN
              
              --Fechar Cursor
              CLOSE cr_crapass2;  
              
              vr_cdcritic:= 9;
              vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
              pr_nmdcampo:= 'nrcpfcgc';
              
              --Levantar Excecao
              RAISE vr_exc_saida;
            ELSE
              --Fechar Cursor
              CLOSE cr_crapass2;    
            END IF;  
            
            --Selecionar Agencia
            OPEN cr_crapage (pr_cdcooper => rw_crapass2.cdcooper
                            ,pr_cdagenci => rw_crapass2.cdagenci);
                            
            FETCH cr_crapage INTO rw_crapage;
            
            --Se nao encontrou
            IF cr_crapage%NOTFOUND THEN
              
              --Fechar Cursor  
              CLOSE cr_crapage;          
              
              vr_cdcritic:= 962;
              vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
              pr_nmdcampo:= 'nrcpfcgc';
              
              --Levantar Excecao
              RAISE vr_exc_saida;
            ELSE
              --Fechar Cursor  
              CLOSE cr_crapage;          
            END IF;  
          END IF;  
        ELSE
          --Valores Encontrados
          vr_cdcooper:= rw_crabcop.cdcooper;
          vr_nrdconta:= pr_tab_beneficiario(vr_index).nrdconta;
          
          --Verificar se tem conta em alguma cooperativa
          OPEN cr_crapass2 (pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => vr_nrdconta);
                           
          FETCH cr_crapass2 INTO rw_crapass2;
          
          --Se nao tem conta
          IF cr_crapass2%NOTFOUND THEN
            
            --Fechar Cursor
            CLOSE cr_crapass2;
            
            vr_cdcritic:= 9;
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
            pr_nmdcampo:= 'nrcpfcgc';
            
            --Levantar Excecao
            RAISE vr_exc_saida;
          ELSE
            --Fechar Cursor
            CLOSE cr_crapass2;
          END IF;  
          --Selecionar Agencia
          OPEN cr_crapage (pr_cdcooper => rw_crapass2.cdcooper
                          ,pr_cdagenci => rw_crapass2.cdagenci);
                          
          FETCH cr_crapage INTO rw_crapage;
          
          --Se nao encontrou
          IF cr_crapage%NOTFOUND THEN
            
            --Fechar Cursor  
            CLOSE cr_crapage;          
            
            vr_cdcritic:= 962;
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
            pr_nmdcampo:= 'nrcpfcgc';
            
            --Levantar Excecao
            RAISE vr_exc_saida;
          ELSE
            --Fechar Cursor  
            CLOSE cr_crapage;          
          END IF;  
        END IF;  
        
        -- Verifica se a cooperativa esta cadastrada
        OPEN cr_crapcop (pr_cdcooper => vr_cdcooper);
        
        FETCH cr_crapcop INTO rw_crabcop;
        
        -- Se não encontrar
        IF cr_crapcop%NOTFOUND THEN
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapcop;
          
          --Monta mensagem de critica
          vr_cdcritic:= 794;          
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
          pr_nmdcampo:= 'nrcpfcgc';
          
          --Levantar Excecao
          RAISE vr_exc_saida;
        ELSE
          -- Fechar o cursor
          CLOSE cr_crapcop;
        END IF; 
        
        --Buscar Titular
        OPEN cr_crapttl (pr_cdcooper => vr_cdcooper
                        ,pr_nrdconta => vr_nrdconta
                        ,pr_nrcpfcgc => vr_nrcpfcgc);
                        
        FETCH cr_crapttl INTO rw_crapttl;
        
        --Se nao encontrou
        IF cr_crapttl%NOTFOUND THEN
          
          --Fechar Cursor
          CLOSE cr_crapttl;
          
          --Monta mensagem de critica
          vr_cdcritic:= 9;
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
          pr_nmdcampo:= 'nrcpfcgc';
          
          --Levantar Excecao
          RAISE vr_exc_saida;
        ELSE
          --Fechar Cursor
          CLOSE cr_crapttl;        
        END IF;          

        --Selecionar Telefone
        OPEN cr_craptfc (pr_cdcooper => rw_crapttl.cdcooper 
                        ,pr_nrdconta => rw_crapttl.nrdconta
                        ,pr_idseqttl => rw_crapttl.idseqttl
                        ,pr_tptelefo => 1);
                        
        FETCH cr_craptfc INTO rw_craptfc;
        
        --Se Encontrou
        IF cr_craptfc%FOUND                 AND 
           LENGTH(rw_craptfc.nrtelefo) < 10 THEN
          pr_tab_beneficiario(vr_index).nrdddttl:= rw_craptfc.nrdddtfc;
          pr_tab_beneficiario(vr_index).nrtelttl:= rw_craptfc.nrtelefo;
        END IF;
        
        --Fechar Cursor
        CLOSE cr_craptfc;                
            
        /*Decorrente ao SICREDI exigir um endereço no envio dos request's, se na consulta
          do segundo titular, este, não tiver um endereço residencial cadastrado então,
          será utilizado o endereço do primeiro titrular independetende da relação 
         (Pai, Mae, amigo, etc..) entre ambos.             */                  
        --Selecionar Endereco
        OPEN cr_crapenc (pr_cdcooper => rw_crapttl.cdcooper 
                        ,pr_nrdconta => rw_crapttl.nrdconta
                        ,pr_idseqttl => rw_crapttl.idseqttl
                        ,pr_tpendass => 10); /*Residencial*/ 
                        
        FETCH cr_crapenc INTO rw_crapenc;
        
        vr_crapenc := cr_crapenc%FOUND;
        
        --Fechar Cursor
        CLOSE cr_crapenc;
        
        --Se Encontrou
        IF vr_crapenc THEN
          
          pr_tab_beneficiario(vr_index).nmbaittl:= rw_crapenc.nmbairro;
          pr_tab_beneficiario(vr_index).nmcidttl:= rw_crapenc.nmcidade;
          pr_tab_beneficiario(vr_index).nrcepttl:= rw_crapenc.nrcepend;
          pr_tab_beneficiario(vr_index).ufendttl:= rw_crapenc.cdufende;
          pr_tab_beneficiario(vr_index).dsendttl:= rw_crapenc.dsendere;
          pr_tab_beneficiario(vr_index).nrendttl:= rw_crapenc.nrendere;
          
        ELSE
           --Selecionar Endereco
           OPEN cr_crapenc (pr_cdcooper => rw_crapttl.cdcooper 
                           ,pr_nrdconta => rw_crapttl.nrdconta
                           ,pr_idseqttl => 1 --Primeiro titular
                           ,pr_tpendass => 10); /*Residencial*/ 
                            
           FETCH cr_crapenc INTO rw_crapenc;
           
           vr_crapenc := cr_crapenc%FOUND;
           
           --Fechar Cursor
           CLOSE cr_crapenc;
          
           --Se Encontrou
           IF vr_crapenc THEN
              pr_tab_beneficiario(vr_index).nmbaittl:= rw_crapenc.nmbairro;
              pr_tab_beneficiario(vr_index).nmcidttl:= rw_crapenc.nmcidade;
              pr_tab_beneficiario(vr_index).nrcepttl:= rw_crapenc.nrcepend;
              pr_tab_beneficiario(vr_index).ufendttl:= rw_crapenc.cdufende;
              pr_tab_beneficiario(vr_index).dsendttl:= rw_crapenc.dsendere;
              pr_tab_beneficiario(vr_index).nrendttl:= rw_crapenc.nrendere;
           END IF;  
          
        END IF;  
        
        --Carregar demais informacoes na temp-table
        pr_tab_beneficiario(vr_index).idseqttl:= rw_crapttl.idseqttl;
        pr_tab_beneficiario(vr_index).nmextttl:= rw_crapttl.nmextttl; 
        
        /*Na tela INSS vamos mostrar o PA e seu respectivo nome a partir do PA existente no
          no cadastro do cooperado.
          Isto é feito pois, em todas as nossas operações enviamos o PA fixo como 2 e
          temos mais de um PA com mesmo OP em nosso sistema. Consequentemente, não temos
          como identifcar o PA correto. Desta forma, em acordo com o pessoal da COMPE, 
          decidimos deixar apresentando o PA conforme cadastrado do cooperado.*/
        pr_tab_beneficiario(vr_index).nmresage:= rw_crapage.cdagenci||' - '||rw_crapage.nmresage;
        
        pr_tab_beneficiario(vr_index).razaosoc:= rw_crabcop.nmrescop;
        /* 1 => Cop do ben = a coop logada
           2 => Cop do ben <> da coop logada*/
        IF pr_cdcooper = rw_crabcop.cdcooper THEN   
          pr_tab_beneficiario(vr_index).copvalid:= 1;
        ELSE  
          pr_tab_beneficiario(vr_index).copvalid:= 2;
        END IF;  
        pr_tab_beneficiario(vr_index).cdcooper:= rw_crabcop.cdcooper;
        pr_tab_beneficiario(vr_index).nrcpfttl:= rw_crapttl.nrcpfcgc;       

        --Retorno OK  
        vr_retornvl:= 'OK'; 
                                         
      EXCEPTION
        WHEN vr_exc_ok THEN
          --saiu sem problemas
          vr_retornvl:= 'OK';
        WHEN vr_exc_saida THEN 
          --saiu com erro
          vr_retornvl:= 'NOK';
      END;  
      
      --Eliminar arquivos requisicao
      inss0001.pc_elimina_arquivos_requis (pr_cdcooper => pr_cdcooper      --Codigo Cooperativa
                                          ,pr_cdprogra => pr_nmdatela      --Nome do Programa
                                          ,pr_msgenvio => vr_msgenvio      --Mensagem Envio
                                          ,pr_msgreceb => vr_msgreceb      --Mensagem Recebimento
                                          ,pr_movarqto => vr_movarqto      --Nome Arquivo mover
                                          ,pr_nmarqlog => vr_nmarqlog      --Nome Arquivo LOG
                                          ,pr_des_reto => vr_des_reto      --Retorno OK/NOK 
                                          ,pr_dscritic => vr_dscritic2);    --Descricao Erro
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        vr_dscritic:= vr_dscritic2;
        --Levantar Excecao
            
          -- Codigo 1 onde na rotina final faz de para gerar 4 alerta - ch 664301
          vr_cd_tipo_mensagem := 1; 
          
        RAISE vr_exc_erro;
      END IF;     
      
		  --Incluir nome do módulo logado - Chamado 664301
      --Seta novamente esta rotina porque foi alterado dentro da pc_elimina_arquivos_requis
			GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_solic_consulta_benef');      
      
      --Se ocorreu erro                                              
      IF vr_retornvl <> 'OK' THEN
        
        --Se nao possui mensagem de erro
        IF vr_cdcritic = 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= 'Nao foi possivel consultar o beneficiario.';
        END IF;
        
        --Verificar se possui somente código erro
        IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
          
        -- Gravar Linha Log
        inss0001.pc_retorna_linha_log(pr_cdcooper => pr_cdcooper     --Codigo Cooperativa 
                                     ,pr_cdprogra => pr_nmdatela     --Nome do Programa
                                     ,pr_dtmvtolt => pr_dtmvtolt     --Data Movimento
                                     ,pr_nrdconta => 0  /*nrdconta*/ --Numero da Conta
                                     ,pr_nrcpfcgc => pr_nrcpfcgc     --Numero Cpf
                                     ,pr_nrrecben => pr_nrrecben     --Numero Recebimento Beneficio
                                     ,pr_nmmetodo => 'Consulta'      --Nome do metodo
                                     ,pr_cdderror => vr_cdcritic     --Codigo Erro
                                     ,pr_dsderror => vr_dscritic     --Descricao Erro
                                     ,pr_nmarqlog => vr_nmarqlog     --Nome Arquivo LOG
                                     ,pr_cdtipofalha => vr_cd_tipo_mensagem  -- erro ou alerta - ch 6603271
                                     ,pr_des_reto => vr_des_reto     --Saida OK/NOK
                                     ,pr_dscritic => vr_dscritic2);  --Descricao erro
                     
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          vr_dscritic:= vr_dscritic2;          
        END IF;   
                      
        --Gera exceção
        RAISE vr_exc_erro;                                      

      END IF;
      
      --Retorno
      pr_des_erro:= vr_retornvl;    

    EXCEPTION
      WHEN vr_exc_erro THEN
        
        -- Retorno não OK          
        pr_des_erro:= vr_retornvl;
        
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                             
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        vr_dscritic := 'Erro na inss0001.pc_solic_consulta_benef --> '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

  END pc_solic_consulta_benef;

  /* Procedure para Solicitar Consulta dos Dados do beneficiario Modo Caracter */
  PROCEDURE pc_solic_consulta_benef_car (pr_cdcooper IN crapcop.cdcooper%type   --Codigo Cooperativa 
                                        ,pr_cdagenci IN crapage.cdagenci%type   --Codigo Agencia
                                        ,pr_nrdcaixa IN INTEGER                 --Numero Caixa
                                        ,pr_idorigem IN INTEGER                 --Origem Processamento
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%type   --Data Movimento
                                        ,pr_nmdatela IN VARCHAR2                --Nome da tela
                                        ,pr_cdoperad IN VARCHAR2                --Operador
                                        ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                        ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                        ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                        ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2               --Saida OK/NOK
                                        ,pr_clob_ret OUT CLOB                   --Tabela Beneficiarios
                                        ,pr_cdcritic OUT PLS_INTEGER            --Codigo Erro
                                        ,pr_dscritic OUT VARCHAR2) IS           --Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solic_consulta_benef_car              Antigo: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Marco/2015                           Ultima atualizacao: 26/03/2015
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para Solicitar Consulta dos Dados do beneficiario modo Caracter
  
    Alterações : 09/03/2015 Desenvolvimento (Alisson-AMcom)
    
                 26/03/2015 - Ajuste na organização e identação da escrita (Adriano).
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabelas de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    vr_tab_beneficiario inss0001.typ_tab_beneficiario;

    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
        
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
        
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
			GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'INSS0001.pc_solic_consulta_benef_car');      
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Limpar tabela dados
      vr_tab_beneficiario.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      --Consultar Beneficiario
      inss0001.pc_solic_consulta_benef (pr_cdcooper => pr_cdcooper  --Codigo Cooperativa 
                                       ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                       ,pr_nrdcaixa => pr_nrdcaixa  --Numero Caixa
                                       ,pr_idorigem => pr_idorigem  --Origem Processamento
                                       ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                       ,pr_nmdatela => pr_nmdatela  --Nome da tela
                                       ,pr_cdoperad => pr_cdoperad  --Operador
                                       ,pr_cddopcao => pr_cddopcao  --Codigo Opcao
                                       ,pr_nrcpfcgc => pr_nrcpfcgc  --Numero CPF/CNPJ
                                       ,pr_nrrecben => pr_nrrecben  --Numero Recebimento Beneficio
                                       ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                       ,pr_des_erro => vr_des_reto  --Saida OK/NOK
                                       ,pr_tab_beneficiario => vr_tab_beneficiario --Tabela Beneficiarios
                                       ,pr_tab_erro  => vr_tab_erro); --Tabela Erros
                                       
      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a inss0001.pc_solic_consulta_benef.';
        END IF;    
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF;
                                          
      --Montar CLOB
      IF vr_tab_beneficiario.COUNT > 0 THEN
        
        -- Criar documento XML
        dbms_lob.createtemporary(pr_clob_ret, TRUE); 
        dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);
        
        -- Insere o cabeçalho do XML 
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
         
        --Buscar Primeiro beneficiario
        vr_index:= vr_tab_beneficiario.FIRST;
        
        --Percorrer todos os beneficiarios
        WHILE vr_index IS NOT NULL LOOP
          vr_string:= '<benef>'||
                      '<idbenefi>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).idbenefi),'0')|| '</idbenefi>'|| 
                      '<dtdcadas>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).dtdcadas,'DD/MM/YYYY'),' ')|| '</dtdcadas>'|| 
                      '<nmbenefi>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nmbenefi),' ')|| '</nmbenefi>'|| 
                      '<dtdnasci>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).dtdnasci,'DD/MM/YYYY'),' ')|| '</dtdnasci>'|| 
                      '<tpdosexo>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).tpdosexo),' ')|| '</tpdosexo>'|| 
                      '<dtutirec>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).dtutirec),' ')|| '</dtutirec>'|| 
                      '<dscsitua>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).dscsitua),' ')|| '</dscsitua>'|| 
                      '<dtdvenci>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).dtdvenci,'DD/MM/YYYY'),' ')|| '</dtdvenci>'|| 
                      '<dtcompvi>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).dtcompvi,'DD/MM/YYYY'),' ')|| '</dtcompvi>'|| 
                      '<tpdpagto>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).tpdpagto),' ')|| '</tpdpagto>'|| 
                      '<cdorgins>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).cdorgins),'0')|| '</cdorgins>'|| 
                      '<nomdamae>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nomdamae),' ')|| '</nomdamae>'|| 
                      '<nrdddtfc>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nrdddtfc),'0')|| '</nrdddtfc>'|| 
                      '<nrtelefo>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nrtelefo),'0')|| '</nrtelefo>'|| 
                      '<nrrecben>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nrrecben),' ')|| '</nrrecben>'|| 
                      '<tpnrbene>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).tpnrbene),' ')|| '</tpnrbene>'|| 
                      '<cdcooper>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).cdcooper),'0')|| '</cdcooper>'|| 
                      '<cdcopsic>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).cdcopsic),'0')|| '</cdcopsic>'|| 
                      '<nruniate>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nruniate),'0')|| '</nruniate>'|| 
                      '<nrcepend>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nrcepend),'0')|| '</nrcepend>'|| 
                      '<dsendere>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).dsendere),' ')|| '</dsendere>'|| 
                      '<nrendere>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nrendere),'0')|| '</nrendere>'|| 
                      '<nmbairro>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nmbairro),' ')|| '</nmbairro>'|| 
                      '<nmcidade>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nmcidade),' ')|| '</nmcidade>'|| 
                      '<cdufende>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).cdufende),' ')|| '</cdufende>'|| 
                      '<nrcpfcgc>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nrcpfcgc),'0')|| '</nrcpfcgc>'|| 
                      '<resdesde>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).resdesde),' ')|| '</resdesde>'|| 
                      '<dscespec>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).dscespec),' ')|| '</dscespec>'|| 
                      '<nrdconta>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nrdconta),'0')|| '</nrdconta>'|| 
                      '<digdacta>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).digdacta),'0')|| '</digdacta>'|| 
                      '<nmprocur>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nmprocur),' ')|| '</nmprocur>'|| 
                      '<cdagesic>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).cdagesic),'0')|| '</cdagesic>'|| 
                      '<cdagepac>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).cdagepac),'0')|| '</cdagepac>'|| 
                      '<nrdocpro>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nrdocpro),'0')|| '</nrdocpro>'|| 
                      '<nmresage>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nmresage),' ')|| '</nmresage>'|| 
                      '<razaosoc>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).razaosoc),' ')|| '</razaosoc>'|| 
                      '<nmextttl>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nmextttl),' ')|| '</nmextttl>'|| 
                      '<idseqttl>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).idseqttl),'0')|| '</idseqttl>'|| 
                      '<copvalid>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).copvalid),'0')|| '</copvalid>'|| 
                      '<nrcpfttl>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nrcpfttl),'0')|| '</nrcpfttl>'|| 
                      '<dsendttl>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).dsendttl),' ')|| '</dsendttl>'|| 
                      '<nrendttl>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nrendttl),'0')|| '</nrendttl>'|| 
                      '<nrcepttl>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nrcepttl),'0')|| '</nrcepttl>'|| 
                      '<nmbaittl>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nmbaittl),' ')|| '</nmbaittl>'|| 
                      '<nmcidttl>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nmcidttl),' ')|| '</nmcidttl>'|| 
                      '<ufendttl>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).ufendttl),' ')|| '</ufendttl>'|| 
                      '<nrdddttl>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nrdddttl),'0')|| '</nrdddttl>'|| 
                      '<nrtelttl>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).nrtelttl),'0')|| '</nrtelttl>'|| 
                      '<stacadas>'||NVL(TO_CHAR(vr_tab_beneficiario(vr_index).stacadas),' ')|| '</stacadas>'|| 
                      '</benef>';
                      
          -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                                 ,pr_texto_completo => vr_dstexto 
                                 ,pr_texto_novo     => vr_string
                                 ,pr_fecha_xml      => FALSE);   
                                                    
          --Proximo Registro
          vr_index:= vr_tab_beneficiario.NEXT(vr_index);
          
        END LOOP;  
        
        -- Encerrar a tag raiz 
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => '</root>' 
                               ,pr_fecha_xml      => TRUE);
                               
      END IF;
                                         
      --Retorno
      pr_des_erro:= 'OK';    

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;        
          
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        pr_cdcritic:= 0;
        -- Chamar rotina de gravação de erro
        pr_dscritic:= 'Erro na inss0001.pc_solic_consulta_benef_car --> '|| SQLERRM;

  END pc_solic_consulta_benef_car;  

  /* Procedure para Solicitar Consulta dos Dados do beneficiario Modo Web */
  PROCEDURE pc_solic_consulta_benef_web (pr_dtmvtolt IN VARCHAR2                --Data Movimento
                                        ,pr_cddopcao IN VARCHAR2                --Codigo Opcao
                                        ,pr_nrcpfcgc IN NUMBER                  --Numero CPF/CNPJ
                                        ,pr_nrrecben IN NUMBER                  --Numero Recebimento Beneficio
                                        ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                        ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK
                                       
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solic_consulta_benef_web              Antigo: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Alisson C. Berrido - AMcom
    Data     : Marco/2015                           Ultima atualizacao: 10/04/2015
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para Solicitar Consulta dos Dados do beneficiario modo Caracter
  
    Alterações : 09/03/2015 Desenvolvimento (Alisson-AMcom)
    
                 26/03/2015 - Ajuste na organização e identação da escrita (Adriano).
                 
                 10/04/2015 - Incluido tratamento para receber a data de movimento
                              (Adriano).
                 
                 01/12/2015 - Adicionado alerta nas telas de consulta para caso a
                              comprovacao de vida esteja vencida.
                              Projeto INSS (Lombardi).
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de beneficiarios
    vr_tab_beneficiario inss0001.typ_tab_beneficiario;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Auxiliares
    vr_flgpvida INTEGER;
    vr_msgpvida VARCHAR2(100) := '';
    vr_des_log  VARCHAR2(10000);
    vr_nrdconta crapass.nrdconta%TYPE;
    vr_nmbenefi VARCHAR2(100);
    
    --Variaveis Arquivo Dados
    vr_dtmvtolt DATE;
    vr_auxconta PLS_INTEGER:= 0;
        
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Limpar tabela dados
      vr_tab_beneficiario.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
  	  -- Incluir nome do módulo logado - Chamado 664301
			GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_solic_consulta_benef_web');      
      
      BEGIN                                                  
        --Pega a data de movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/YYYY'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      --Consultar Beneficiario
      inss0001.pc_solic_consulta_benef (pr_cdcooper => vr_cdcooper  --Codigo Cooperativa 
                                       ,pr_cdagenci => vr_cdagenci  --Codigo Agencia
                                       ,pr_nrdcaixa => vr_nrdcaixa  --Numero Caixa
                                       ,pr_idorigem => vr_idorigem  --Origem Processamento
                                       ,pr_dtmvtolt => vr_dtmvtolt  --Data Movimento
                                       ,pr_nmdatela => vr_nmdatela  --Nome da tela
                                       ,pr_cdoperad => vr_cdoperad  --Operador
                                       ,pr_cddopcao => pr_cddopcao  --Codigo Opcao
                                       ,pr_nrcpfcgc => pr_nrcpfcgc  --Numero CPF/CNPJ
                                       ,pr_nrrecben => pr_nrrecben  --Numero Recebimento Beneficio
                                       ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                       ,pr_des_erro => vr_des_reto  --Saida OK/NOK
                                       ,pr_tab_beneficiario => vr_tab_beneficiario --Tabela Beneficiarios
                                       ,pr_tab_erro  => vr_tab_erro); --Tabela Erros
      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na inss0001.pc_solic_consulta_benef.';
        END IF;  
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF;
                                          
      --Montar CLOB
      IF vr_tab_beneficiario.COUNT > 0 THEN

        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
                
        --Buscar Primeiro beneficiario
        vr_index:= vr_tab_beneficiario.FIRST;
        
        --Percorrer todos os beneficiarios
        WHILE vr_index IS NOT NULL LOOP

          vr_nrdconta := vr_tab_beneficiario(vr_index).nrdconta;
          vr_nmbenefi := vr_tab_beneficiario(vr_index).nmbenefi;
          
          vr_flgpvida := INSS0001.fn_verifica_renovacao_vida(pr_cdcooper => vr_cdcooper --> Codigo da cooperativa
                                                            ,pr_nrdconta => vr_tab_beneficiario(vr_index).nrdconta --> Numero da conta
                                                            ,pr_nrrecben => vr_tab_beneficiario(vr_index).nrrecben --> Numero do beneficio
                                                            ,pr_dtmvtolt => vr_dtmvtolt); --> Data do movimento
          
          IF vr_flgpvida = 1 THEN
            --> Incluir na temptable
            vr_msgpvida := vr_msgpvida || 'Beneficiario com Prova de Vida Pendente. Efetue Comprovacao. ';
          END IF;																															
        	
				  -- Insere as tags dos campos da PLTABLE de aplicações
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'idbenefi', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).idbenefi), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtdcadas', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).dtdcadas,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmbenefi', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nmbenefi), pr_des_erro => vr_dscritic);
  				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtdnasci', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).dtdnasci,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
	   			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'tpdosexo', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).tpdosexo), pr_des_erro => vr_dscritic);
		  		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtutirec', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).dtutirec), pr_des_erro => vr_dscritic);
			  	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dscsitua', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).dscsitua), pr_des_erro => vr_dscritic);
		  		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtdvenci', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).dtdvenci,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
	  			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtcompvi', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).dtcompvi,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
			  	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'tpdpagto', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).tpdpagto), pr_des_erro => vr_dscritic);
				  gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdorgins', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).cdorgins), pr_des_erro => vr_dscritic);
	  			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nomdamae', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nomdamae),  pr_des_erro => vr_dscritic);
		  		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdddtfc', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nrdddtfc), pr_des_erro => vr_dscritic);
			  	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrtelefo', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nrtelefo), pr_des_erro => vr_dscritic);
				  gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrrecben', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nrrecben), pr_des_erro => vr_dscritic);
	  			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'tpnrbene', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).tpnrbene), pr_des_erro => vr_dscritic);
		  		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdcooper', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).cdcooper), pr_des_erro => vr_dscritic);
			  	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdcopsic', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).cdcopsic), pr_des_erro => vr_dscritic);
				  gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nruniate', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nruniate), pr_des_erro => vr_dscritic);
	  			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrcepend', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nrcepend), pr_des_erro => vr_dscritic);
		  		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsendere', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).dsendere), pr_des_erro => vr_dscritic);
			   	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrendere', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nrendere), pr_des_erro => vr_dscritic);
			  	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmbairro', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nmbairro), pr_des_erro => vr_dscritic);
			  	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmcidade', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nmcidade), pr_des_erro => vr_dscritic);
				  gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdufende', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).cdufende), pr_des_erro => vr_dscritic);
	  			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nrcpfcgc), pr_des_erro => vr_dscritic);
		  		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'resdesde', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).resdesde), pr_des_erro => vr_dscritic);
			  	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dscespec', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).dscespec), pr_des_erro => vr_dscritic);
				  gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdconta', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nrdconta), pr_des_erro => vr_dscritic);
	  			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'digdacta', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).digdacta), pr_des_erro => vr_dscritic);
		  		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmprocur', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nmprocur), pr_des_erro => vr_dscritic);
			   	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdagesic', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).cdagesic), pr_des_erro => vr_dscritic);
			  	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdagepac', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).cdagepac), pr_des_erro => vr_dscritic);
				  gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdocpro', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nrdocpro), pr_des_erro => vr_dscritic);
	  			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmresage', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nmresage), pr_des_erro => vr_dscritic);
		  		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'razaosoc', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).razaosoc), pr_des_erro => vr_dscritic);
			   	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmextttl', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nmextttl), pr_des_erro => vr_dscritic);
			  	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'idseqttl', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).idseqttl), pr_des_erro => vr_dscritic);
			  	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'copvalid', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).copvalid), pr_des_erro => vr_dscritic);
				  gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrcpfttl', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nrcpfttl), pr_des_erro => vr_dscritic);
	  			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsendttl', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).dsendttl), pr_des_erro => vr_dscritic);
		  		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrendttl', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nrendttl), pr_des_erro => vr_dscritic);
			  	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrcepttl', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nrcepttl), pr_des_erro => vr_dscritic);
				  gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmbaittl', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nmbaittl), pr_des_erro => vr_dscritic);
	  			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmcidttl', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nmcidttl), pr_des_erro => vr_dscritic);
		  		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'ufendttl', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).ufendttl), pr_des_erro => vr_dscritic);
			   	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdddttl', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nrdddttl), pr_des_erro => vr_dscritic);
			  	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrtelttl', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).nrtelttl), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'stacadas', pr_tag_cont => TO_CHAR(vr_tab_beneficiario(vr_index).stacadas), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'msgpvida', pr_tag_cont => TO_CHAR(vr_msgpvida), pr_des_erro => vr_dscritic);

          -- Incrementa contador p/ posicao no XML
          vr_auxconta := vr_auxconta + 1;

          --Proximo Registro
          vr_index:= vr_tab_beneficiario.NEXT(vr_index);
          
        END LOOP;
      ELSE
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');    
      END IF;
                                         
      IF pr_cddopcao = 'C' THEN
        vr_des_log :=   
          'Conta: '    || gene0002.fn_mask(vr_nrdconta,'9999.999-9')  || ' | ' ||
          'Nome: '     || vr_nmbenefi                    || ' | ' ||
          'NB: '       || to_char(pr_nrrecben)           || ' | ' ||
          'operador: ' || to_char(vr_cdoperad)           || ' | ' ||
          'Alteracao: Operador ' || to_char(vr_cdoperad) || 
          ' efetuou consulta referente ao NB ' || to_char(pr_nrrecben) || '.';
                                                   
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || vr_nmdatela || ' --> ' || 
                                                    'ALERTA: ' || vr_des_log   
                                    ,pr_nmarqlog     => 'inss_historico.log'
                                    ,pr_flfinmsg     => 'N'
                                    ,pr_cdprograma   => vr_nmdatela
                                    );
      END IF;
                                         
      --Retorno
      pr_des_erro:= 'OK';    

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                       
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na inss0001.pc_solic_consulta_benef_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
  END pc_solic_consulta_benef_web;  

  --Buscar relatorios solicitados
  PROCEDURE pc_busca_rel_solicitados (pr_dsiduser IN VARCHAR2            --Id do usuario
                                     ,pr_nrregist IN INTEGER             --Numero Registros
                                     ,pr_nriniseq IN INTEGER             --Numero Sequencia Inicial
                                     ,pr_idtiprel IN VARCHAR2            --Tipo do Relatorio PAGOS/PAGAR
                                     ,pr_xmllog   IN VARCHAR2            --XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER        --Código da crítica
                                     ,pr_dscritic OUT VARCHAR2           --Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType  --Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2           --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2) IS       --Saida OK/NOK
                                     
  /*---------------------------------------------------------------------------------------------------------------
  
  Programa : pc_busca_rel_solicitados             
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Adriano Marchi
  Data     : Março/2015                           Ultima atualizacao: 24/07/2015
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo   : Procedure para Buscar os relatórios solicitados pelo usuário recebido como  parâmetro  
  
  Alterações : 10/04/2015 - Ajuste para retornar corretamente a critica no excpetion e incluido
                            o formato "pdf" para filtrar os relatórios
                            (Adrinao).
                          
               24/07/2015 - Ajuste realizados: 
                            - Retirado o incremento da variável vr_qtregist realizado indevidamente;
                            - Incluido tratamenteo para eliminar relatórios antigos deixando no /rl
                              apenas os que foram gerados no dia corrente.
                           (Adriano).
              
  -------------------------------------------------------------------------------------------------------------*/

    --Tabela para receber arquivos lidos no unix
    vr_tab_arquivo  gene0002.typ_split;  
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
        
    --Variaveis Arquivo Dados
    vr_qtregist INTEGER;
         
    --Variaveis Locais
    vr_nrregist INTEGER;
    vr_auxconta PLS_INTEGER:= 0;
    vr_dsdircop VARCHAR2(100);
    vr_listadir VARCHAR2(32700);
    vr_index_arq PLS_INTEGER;
    vr_des_erro  VARCHAR2(3);
    vr_nmarqpdf  VARCHAR2(1000);
    vr_dsfiltro  VARCHAR2(1000);
    vr_nmarquivo VARCHAR2(32700);
    vr_dshorari  VARCHAR2(1000);
    
    --Variaveis de Erro
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    
    BEGIN
          
      --Inicializar Variavel
      vr_nrregist:= pr_nrregist;
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      
      --Limpar tabela erros
      vr_tab_erro.DELETE;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_busca_rel_solicitados');                
      
      /* Define Nome do Novo Arquivo */
      vr_dsdircop:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => 'rl');
      
      
      --Filtro
      vr_dsfiltro:= vr_cdoperad||'_%'||pr_idtiprel || '.pdf';
      
      -- Verifica se o filtro e o diretório da busca foram montados
      IF vr_dsfiltro IS NULL OR 
         vr_dsdircop IS NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      /*--- Eliminar relatórios antigos ---*/
      gene0001.pc_oscommand_shell(pr_des_comando => 'find '||vr_dsdircop||' f -name '|| vr_cdoperad||'_*'||pr_idtiprel || '.pdf'|| ' -mtime +1 -exec rm {} \; 2> /dev/null');

      --Buscar a lista de arquivos do diretorio
      gene0001.pc_lista_arquivos(pr_path     => vr_dsdircop        --Nome Diretorio
                                ,pr_pesq     => vr_dsfiltro        --Nome Arquivo
                                ,pr_listarq  => vr_listadir        --Lista de Arquivos
                                ,pr_des_erro => vr_dscritic);      --Mensagem Erro
      
      -- se ocorrer erro ao recuperar lista de arquivos registra no log
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        --Carregar a lista de arquivos na temp table
        vr_tab_arquivo:= gene0002.fn_quebra_string(pr_string => vr_listadir);
      END IF;

      /* Nao existem arquivos para serem importados */
      IF vr_tab_arquivo.COUNT = 0 THEN
        
        --Mensagem Critica
        vr_dscritic:= 'Nenhum relatorio disponivel.';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF; 
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      
      vr_index_arq:= vr_tab_arquivo.FIRST;
            
      WHILE vr_index_arq IS NOT NULL LOOP
        
        vr_nmarquivo := vr_tab_arquivo(vr_index_arq);           
        
        --Incrementar contador
        vr_qtregist:= nvl(vr_qtregist,0) + 1;
        
        -- controles da paginacao 
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
          --Proximo Registro
          vr_index_arq:= vr_tab_arquivo.NEXT(vr_index_arq); 
          --Proximo
          CONTINUE;  
        END IF; 
        
        IF vr_nrregist > 0 THEN 
          
          --Renomear Arquivo
          vr_nmarquivo:= 'BENEFICIOS_'||pr_idtiprel;
          
          --Recuperar Horario geracao
          vr_dshorari:= SUBSTR(vr_tab_arquivo(vr_index_arq),instr(vr_tab_arquivo(vr_index_arq),'_',2)+1,5);
          
          --transformar em Horas/Minutos/Segundos
          vr_dshorari:= gene0002.fn_converte_time_data(vr_dshorari,'S');
          
          -- Insere as tags dos campos da PLTABLE 
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmrelato', pr_tag_cont => vr_tab_arquivo(vr_index_arq), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmfinal', pr_tag_cont => vr_nmarquivo, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'horario', pr_tag_cont => vr_dshorari, pr_des_erro => vr_dscritic);
          
          IF vr_idorigem = 5  THEN  /** Ayllos Web **/
              
            --Montar Nome arquivo com Diretorio
            vr_nmarqpdf:= vr_dsdircop||'/'||vr_tab_arquivo(vr_index_arq);
            
            --Efetuar Copia do PDF
            gene0002.pc_efetua_copia_pdf (pr_cdcooper => vr_cdcooper     --> Cooperativa conectada
                                         ,pr_cdagenci => vr_cdagenci     --> Codigo da agencia para erros
                                         ,pr_nrdcaixa => vr_nrdcaixa     --> Codigo do caixa para erros
                                         ,pr_nmarqpdf => vr_nmarqpdf     --> Arquivo PDF  a ser gerado                                 
                                         ,pr_des_reto => vr_des_erro     --> Saída com erro
                                         ,pr_tab_erro => vr_tab_erro);   --> tabela de erros 
            --Se ocorreu erro
            IF vr_des_erro = 'NOK' THEN
              
              --Se possui erro
              IF vr_tab_erro.COUNT > 0 THEN
                vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              END IF;
              
              --Levantar Excecao  
              RAISE vr_exc_erro;
              
            END IF; 
          END IF;
        END IF;
        
        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;  
        
        --Proximo Registro
        vr_index_arq:= vr_tab_arquivo.NEXT(vr_index_arq);
        
      END LOOP;
      
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Dados'             --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_qtregist         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;  
      
      --Retorno OK
      pr_des_erro:= 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Se nao tem a descricao do erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina inss0001.pc_busca_rel_solicitados. '|| SQLERRM;
        
  END pc_busca_rel_solicitados;

	FUNCTION fn_verifica_renovacao_vida(pr_cdcooper IN tbinss_dcb.cdcooper%TYPE -- Cooperativa
																		 ,pr_dtmvtolt IN tbinss_dcb.dtvencpv%TYPE -- Data de movimento
	                                   ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE DEFAULT 0 -- Nr. da Conta
																		 ,pr_nrrecben IN tbinss_dcb.nrrecben%TYPE DEFAULT 0 -- NB
                                     ) RETURN INTEGER IS
	 /*---------------------------------------------------------------------------------------------------------------

		Programa : fn_verifica_renovacao_vida
		Sistema  : Conta-Corrente - Cooperativa de Credito
		Sigla    : CRED
		Autor    : Lucas Reinert
    Data     : Outubro/2015                           Ultima atualizacao: 17/03/2017


		Dados referentes ao programa:

		Frequencia: -----
		Objetivo   : Procedure para verificar se beneficiario necessita comprovar vida

		Alterações : 06/04/2016 - PRJ 255 Fase 2 - Mesmo vencida a PV, emitir aviso apenas se houve
                               LCM 1399 nos ultimos 3 meses. (Guilherme/SUPERO)
		
		 12/05/2016 - Removido a condicao o OR do numero da conta do cursor cr_verifica. 
                                  Todas as chamadas para essa procedure passam o numero da conta 
                                  (Douglas - Chamado 451221)
        
                 17/03/2017 - Ajuste para buscar na craplcm atraves do NB do beneficiario no 
                              campo cdpesqbb, também ajustado cursor cr_tbinss_dcb para listarmos
                              somente o registro mais antigo da tabela junto com o NB
                              (Lucas Ranghetti #626129)
		------------------------------------------------------------------------------------------------------------------*/
  	-- Tratamento de erros
		vr_cdcritic INTEGER;        -- Código da crítica
		vr_dscritic VARCHAR(4000);  -- Descrição da crítica
		vr_exc_saida EXCEPTION;     -- Exceção

    -- Cursor para verificacao do beneficiário do inss
    CURSOR cr_verifica (pr_cdcooper IN tbinss_dcb.cdcooper%TYPE
												 ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE
												 ,pr_nrrecben IN tbinss_dcb.nrrecben%TYPE) IS
      SELECT MAX(dcb.dtcompet) dtcomp,
             dcb.dtvencpv
        FROM tbinss_dcb dcb
       WHERE dcb.cdcooper = pr_cdcooper
         AND dcb.nrdconta = pr_nrdconta
         AND (dcb.nrrecben = pr_nrrecben OR pr_nrrecben = 0)
      GROUP BY dcb.dtvencpv;
    rw_verifica cr_verifica%ROWTYPE;
    
		-- Cursor para buscar última data de vencimento do beneficiário do inss
		CURSOR cr_tbinss_dcb (pr_cdcooper IN tbinss_dcb.cdcooper%TYPE
												 ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE
												 ,pr_nrrecben IN tbinss_dcb.nrrecben%TYPE)IS
		  SELECT dtvencpv
            ,nrrecben
        FROM (SELECT dcb.dtvencpv
                    ,dcb.nrrecben
									FROM tbinss_dcb dcb
                 WHERE dcb.cdcooper  = pr_cdcooper
									 AND (dcb.nrdconta = pr_nrdconta OR pr_nrdconta = 0)
									 AND (dcb.nrrecben = pr_nrrecben OR pr_nrrecben = 0)
               ORDER BY dcb.dtvencpv)
       WHERE ROWNUM = 1;      
			rw_tbinss_dcb cr_tbinss_dcb%ROWTYPE;

      -- Verificar se a conta teve lancamento 1399 nos ultimos 3 meses
      CURSOR cr_craplcm_inss(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                            ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE
                            ,pr_nrrecben IN tbinss_dcb.nrrecben%TYPE) IS
        SELECT 1
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.nrdconta = pr_nrdconta
           AND lcm.cdhistor = 1399
           AND lcm.dtmvtolt <= pr_dtmvtolt
           AND lcm.dtmvtolt >= (pr_dtmvtolt - 90)
           --Buscar cdpesqbb até o primeiro ';' que é o NB(numero do beneficio)
           AND SUBSTR(lcm.cdpesqbb, 1, INSTR(lcm.cdpesqbb, ';') - 1) = pr_nrrecben;
      rw_craplcm_inss cr_craplcm_inss%ROWTYPE;

		BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => 'INSS0001', pr_action => 'INSS0001.fn_verifica_renovacao_vida');    
      
      -- Busca última data de vencimento mais próxima do beneficiário
		  OPEN cr_verifica(pr_cdcooper => pr_cdcooper,
			                 pr_nrdconta => pr_nrdconta,
											 pr_nrrecben => pr_nrrecben);
			FETCH cr_verifica INTO rw_verifica;
      IF cr_verifica%FOUND THEN
        
        -- Busca última data de vencimento mais próxima do beneficiário
        OPEN cr_tbinss_dcb(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrrecben => pr_nrrecben);
        FETCH cr_tbinss_dcb INTO rw_tbinss_dcb;
        
        -- Verifica se a prova de vida já venceu
        IF (rw_tbinss_dcb.dtvencpv <= (pr_dtmvtolt + 60)) OR rw_tbinss_dcb.dtvencpv IS NULL THEN

          -- Verificar se a conta possui LCM 1399 nos ultimos 3 meses
          OPEN cr_craplcm_inss(pr_cdcooper => pr_cdcooper,
                               pr_dtmvtolt => pr_dtmvtolt,
                               pr_nrdconta => pr_nrdconta,
                               pr_nrrecben => rw_tbinss_dcb.nrrecben);
          FETCH cr_craplcm_inss INTO rw_craplcm_inss;

          IF cr_craplcm_inss%FOUND THEN
            RETURN 1; -- Tem LCM nos ultimos 3 meses / Notificar
        ELSE
            RETURN 0; -- Apesar de Vencido, nao tem LCM nos ultimos 3 meses / Não Notificar
        END IF;
        
      ELSE
          RETURN 0;  -- Em dia
      END IF;
      ELSE
        RETURN 0;  -- Em dia
      END IF;

	END fn_verifica_renovacao_vida;


  --Processar a planilha de pagamentos do INSS 
  PROCEDURE pc_exec_pagto_benef_plani (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                      ,pr_nmarquiv  IN VARCHAR2     -- Nome do Arquivo
                                      ,pr_nrdcaixa  IN INTEGER      -- Numero do Caixa
                                      ,pr_cdprogra  IN VARCHAR2     -- Codigo do programa que esta chamando o procedimento
                                      ,pr_qtplanil OUT INTEGER      -- Quantidade de registros na planilha
                                      ,pr_vltotpla OUT NUMBER       -- Valor total planilha
                                      ,pr_qtproces OUT INTEGER      -- Quantidade processada
                                      ,pr_vltotpro OUT NUMBER       -- Valor Total Processado
                                      ,pr_qtderros OUT INTEGER      -- Quantidade de Erros
                                      ,pr_vlderros OUT NUMBER       -- Valor total de erros
                                      ,pr_nmarqerr OUT VARCHAR2     -- Nome dos relatorios de erro
                                      ,pr_dscritic OUT VARCHAR2) IS -- Descricao do Erro
  /*---------------------------------------------------------------------------------------------------------------
  
  Programa : pc_exec_pagto_benef_plani
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Douglas Quisinski
  Data     : Setembro/2015                         Ultima atualizacao: 21/06/2016
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo   : Procedure para executar o pagamento de benefícios do INSS através da planilha.
               Rotina para contigencia, caso o processo de mensagens tenha que ser parado.
  
  Alterações : 11/11/2015 - Ajustes para retornar mais quantificadores
                            (Adriano).
                            
               19/11/2015 - Ajuste para retirar caracteres especiais 
                           (Adriano).
                         
               10/03/2016 - Ajuste para pegar o código da agencia corretamente
                           (Adriano).
                             
               21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                           (Adriano - SD 473539).           
  -------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa pela agencia sicredi
    CURSOR cr_crapcop IS
    SELECT cop.cdagesic
          ,cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
      FROM crapcop cop;
      
    CURSOR cr_crapcop2 (pr_cdcooper IN crapcop.cdcooper%TYPE) IS  
    SELECT cop.nmrescop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop2 cr_crapcop2%ROWTYPE;
    
    --Selecionar Datas de todas as cooperativas
    CURSOR cr_crapdat_cooper IS
    SELECT crapdat.cdcooper
          ,crapdat.dtmvtolt
      FROM crapdat;  
      
    -- Selecionar dados da agencia
    CURSOR cr_crapage IS
      SELECT  crapage.cdcooper
             ,crapage.cdorgins
             ,crapage.cdagenci
        FROM crapage;
    rw_crapage    cr_crapage%ROWTYPE;
    
    --Variaveis para Diretorios
    vr_nmdireto  VARCHAR2(100);
    vr_nmarquiv  VARCHAR2(1000);
    vr_input_file  UTL_FILE.FILE_TYPE;

    vr_setlinha    VARCHAR2(200);
    vr_conta_linha INTEGER;
    vr_tpdiverg    INTEGER;
    vr_cod_reto    INTEGER;
    
    --Variaveis para Indices temp-tables      
    vr_index_creditos PLS_INTEGER;
    vr_index_erro     PLS_INTEGER;
    
    --Tabela de Agencias
    vr_tab_crapage   INSS0001.typ_tab_crapage;
    --Tabela de Diretorios
    vr_tab_salvar    INSS0001.typ_tab_salvar;
    vr_tab_dircoop   INSS0001.typ_tab_salvar;
    --Tabela de Agencias Sicredi
    vr_tab_cdagesic  INSS0001.typ_tab_cdagesic;
    --Tabela de Datas por Cooperativa
    vr_tab_crapdat   INSS0001.typ_tab_crapdat; 
    --Tabela de Memoria de Creditos
    vr_tab_creditos  INSS0001.typ_tab_creditos;
    --Tabela de Memoria de Arquivos 
    vr_tab_arquivos  INSS0001.typ_tab_arquivos;
    --Tabela de Rejeicoes
    vr_tab_rejeicoes INSS0001.typ_tab_rejeicoes;
    -- Tabela de Erros
    vr_tab_erro      GENE0001.typ_tab_erro;
    
    --Tipo de Tabela para as cooperativas que possuem erro
    TYPE typ_tab_coop IS TABLE OF crapcop.cdcooper%type INDEX BY PLS_INTEGER;
    vr_tab_coop_err typ_tab_coop;

    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);    
                                       
    --Variaveis de Excecoes
    vr_exc_erro    EXCEPTION; 
    vr_exc_saida   EXCEPTION;
    vr_exc_proximo EXCEPTION;
    vr_exc_diverg  EXCEPTION; 
    
    --Procedure para limpar tabelas temporarias
    PROCEDURE pc_limpa_tabela IS
    BEGIN
      vr_tab_crapdat.DELETE;
      vr_tab_salvar.DELETE;
      vr_tab_dircoop.DELETE;
      vr_tab_creditos.DELETE;
      vr_tab_arquivos.DELETE;
      vr_tab_rejeicoes.DELETE;
      vr_tab_cdagesic.DELETE;
      vr_tab_crapage.DELETE;
      vr_tab_coop_err.DELETE;
    END pc_limpa_tabela;
                                         
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 664301
	  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0001.pc_exec_pagto_benef_plani');                
      
    --limpar tabela erros
    vr_tab_erro.DELETE;
    
    --Limpar tabelas de memoria
    pc_limpa_tabela;      
    
    --Inicializar variaveis
    vr_dscritic:= NULL;
    
    -- Zerar os totalizadores
    pr_qtplanil:= 0;
    pr_vltotpla:= 0;
    pr_qtproces:= 0;
    pr_vltotpro:= 0;
    pr_qtderros:= 0;
    pr_vlderros:= 0;
    

    --Buscar Diretorio Micros da Cooperativa
    vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'M' --> Usr/micros
                                        ,pr_cdcooper => 3
                                        ,pr_nmsubdir => 'inss');

    -- Nome do arquivo a ser processado
    vr_nmarquiv := vr_nmdireto || '/' || pr_nmarquiv || '.csv';

    --Se Existir o arquivo original
    IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_nmarquiv) THEN
      --Montar Mensagem
      vr_dscritic:= 'Arquivo nao encontrado. Arquivo: '||vr_nmarquiv; 
      RAISE vr_exc_erro;
    END IF;

    --Carregar tabela de datas
    FOR rw_crapdat_cooper IN cr_crapdat_cooper LOOP
      vr_tab_crapdat(rw_crapdat_cooper.cdcooper):= rw_crapdat_cooper.dtmvtolt;
      
      --Montar Diretorio Padrao de cada cooperativa    
      vr_tab_dircoop(rw_crapdat_cooper.cdcooper):= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                                                         ,pr_cdcooper => rw_crapdat_cooper.cdcooper
                                                                         ,pr_nmsubdir => null);

      --Montar Diretorio Salvar de cada cooperativa
      vr_tab_salvar(rw_crapdat_cooper.cdcooper):= vr_tab_dircoop(rw_crapdat_cooper.cdcooper)||'/salvar/inss';
      
    END LOOP;
    
    --Carregar tabela agencias Sicredi
    FOR rw_cgagesic IN cr_crapcop LOOP
      vr_tab_cdagesic(rw_cgagesic.cdagesic):= rw_cgagesic.cdcooper;
    END LOOP;
      
    --Carregar tabela agencias 
    FOR rw_crapage IN cr_crapage LOOP
      vr_tab_crapage(rw_crapage.cdcooper).tab_agenc(rw_crapage.cdorgins):= rw_crapage.cdagenci;
    END LOOP;
    
    -- Abrir o arquivo para testá-lo
    gene0001.pc_abre_arquivo (pr_nmcaminh => vr_nmarquiv    --> Diretório do arquivo
                             ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                             ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                             ,pr_des_erro => vr_dscritic);  --> Descricao do erro

    -- Se retornou erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Laco para leitura de linhas do arquivo
    BEGIN 
      LOOP
        -- Carrega handle do arquivo
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto lido
        
        vr_setlinha:= replace(replace(vr_setlinha,chr(10),''),chr(13),'');
              
        IF UPPER(SUBSTR(vr_setlinha,1,25)) = 'AGEN.FCAGENCIA||FCNROCOOP' THEN -- Header do Arquivo
          
          vr_setlinha:= UPPER(vr_setlinha);
          
          -- Validar se as colunas possuem essa sequencia de campos
          IF gene0002.fn_busca_entrada(1,vr_setlinha,';')  <> 'AGEN.FCAGENCIA||FCNROCOOP' THEN
             vr_dscritic:= 'Arquivo nao processado. Cabecalho invalido.' ||
                           'CAMPO: ' || gene0002.fn_busca_entrada(1,vr_setlinha,';');
             RAISE vr_exc_erro;
          END IF;
             
          IF gene0002.fn_busca_entrada(2,vr_setlinha,';')  <> 'FCCONTA' THEN
             vr_dscritic:= 'Arquivo nao processado. Cabecalho invalido.' ||
                           'CAMPO: ' || gene0002.fn_busca_entrada(2,vr_setlinha,';');
             RAISE vr_exc_erro;
          END IF;
             
          IF gene0002.fn_busca_entrada(3,vr_setlinha,';')  <> 'FCPOSTO' THEN
             vr_dscritic:= 'Arquivo nao processado. Cabecalho invalido.' ||
                           'CAMPO: ' || gene0002.fn_busca_entrada(3,vr_setlinha,';');
             RAISE vr_exc_erro;
          END IF;
             
          IF gene0002.fn_busca_entrada(4,vr_setlinha,';')  <> 'FCSITU' THEN
             vr_dscritic:= 'Arquivo nao processado. Cabecalho invalido.' ||
                           'CAMPO: ' || gene0002.fn_busca_entrada(4,vr_setlinha,';');
             RAISE vr_exc_erro;
          END IF;
             
          IF gene0002.fn_busca_entrada(5,vr_setlinha,';')  <> 'RECNO' THEN
             vr_dscritic:= 'Arquivo nao processado. Cabecalho invalido.' ||
                           'CAMPO: ' || gene0002.fn_busca_entrada(5,vr_setlinha,';');
             RAISE vr_exc_erro;
          END IF;
             
          IF gene0002.fn_busca_entrada(6,vr_setlinha,';')  <> 'IS_DELETED' THEN
             vr_dscritic:= 'Arquivo nao processado. Cabecalho invalido.' ||
                           'CAMPO: ' || gene0002.fn_busca_entrada(6,vr_setlinha,';');
             RAISE vr_exc_erro;
          END IF;
             
          IF gene0002.fn_busca_entrada(7,vr_setlinha,';')  <> 'FCORGAOPAG' THEN
             vr_dscritic:= 'Arquivo nao processado. Cabecalho invalido.' ||
                           'CAMPO: ' || gene0002.fn_busca_entrada(7,vr_setlinha,';');
             RAISE vr_exc_erro;
          END IF;
             
          IF gene0002.fn_busca_entrada(8,vr_setlinha,';')  <> 'FNVALOR' THEN
             vr_dscritic:= 'Arquivo nao processado. Cabecalho invalido.' ||
                           'CAMPO: ' || gene0002.fn_busca_entrada(8,vr_setlinha,';');
             RAISE vr_exc_erro;
          END IF;
             
          IF gene0002.fn_busca_entrada(9,vr_setlinha,';')  <> 'FCCONTA' THEN
             vr_dscritic:= 'Arquivo nao processado. Cabecalho invalido.' ||
                           'CAMPO: ' || gene0002.fn_busca_entrada(9,vr_setlinha,';');
             RAISE vr_exc_erro;
          END IF;
             
          IF gene0002.fn_busca_entrada(10,vr_setlinha,';') <> 'FCCPF' THEN
             vr_dscritic:= 'Arquivo nao processado. Cabecalho invalido.' ||
                           'CAMPO: ' || gene0002.fn_busca_entrada(10,vr_setlinha,';');
             RAISE vr_exc_erro;
          END IF;
             
          IF gene0002.fn_busca_entrada(11,vr_setlinha,';') <> 'FCCODIGO' THEN
             vr_dscritic:= 'Arquivo nao processado. Cabecalho invalido.' ||
                           'CAMPO: ' || gene0002.fn_busca_entrada(11,vr_setlinha,';');
             RAISE vr_exc_erro;
          END IF;
             
          IF gene0002.fn_busca_entrada(12,vr_setlinha,';') NOT LIKE 'FDDATAINI%' THEN
             vr_dscritic:= 'Arquivo nao processado. Cabecalho invalido. ' ||
                           'CAMPO: ' || gene0002.fn_busca_entrada(12,vr_setlinha,';');
             RAISE vr_exc_erro;
          END IF;
          
          -- Se todos os campos do Cabecalho estão na posição correta, vamos para a próxima linha
          CONTINUE;
        END IF;
        
        --Criar SavePoint 
        SAVEPOINT save_trans_crawarq;
                
        --Bloco para permitir pular para proximo arquivo
        BEGIN
          --Montar Indice de Creditos
          vr_index_creditos:= vr_tab_creditos.COUNT+1;
          vr_tab_creditos(vr_index_creditos).nrcpfcgc:= gene0002.fn_char_para_number(gene0002.fn_busca_entrada(10,vr_setlinha,';'));
          vr_tab_creditos(vr_index_creditos).idbenefi:= gene0002.fn_char_para_number(gene0002.fn_busca_entrada(11,vr_setlinha,';'));
          vr_tab_creditos(vr_index_creditos).nmbenefi:= '';
          vr_tab_creditos(vr_index_creditos).tpnrbene:= '';
          vr_tab_creditos(vr_index_creditos).nrrecben:= gene0002.fn_char_para_number(gene0002.fn_busca_entrada(11,vr_setlinha,';'));
          vr_tab_creditos(vr_index_creditos).cdagesic:= gene0002.fn_char_para_number(gene0002.fn_busca_entrada(1,vr_setlinha,';'));
          vr_tab_creditos(vr_index_creditos).cdagenci:= gene0002.fn_char_para_number(gene0002.fn_busca_entrada(3,vr_setlinha,';'));
          vr_tab_creditos(vr_index_creditos).vlrbenef:= gene0002.fn_char_para_number(gene0002.fn_busca_entrada(8,vr_setlinha,';'));
          vr_tab_creditos(vr_index_creditos).nrdconta:= gene0002.fn_char_para_number(gene0002.fn_busca_entrada(9,vr_setlinha,';'));
          vr_tab_creditos(vr_index_creditos).cdcooper:= gene0002.fn_char_para_number(gene0002.fn_busca_entrada(1,vr_setlinha,';'));
          vr_tab_creditos(vr_index_creditos).dtdpagto:= to_date(gene0002.fn_busca_entrada(12,vr_setlinha,';'),'dd/mm/RRRR');
          vr_tab_creditos(vr_index_creditos).cdorgins:= gene0002.fn_char_para_number(gene0002.fn_busca_entrada(7,vr_setlinha,';'));
        
          -- Incrementar a quantidade na planilha
          pr_qtplanil:= pr_qtplanil + 1;
          pr_vltotpla:= pr_vltotpla + vr_tab_creditos(vr_index_creditos).vlrbenef;
          
          /* Realiza as validações e o pagamento do beneficio */
          pc_proces_pagto_benef_inss (pr_cdcooper        => pr_cdcooper       -- Codigo da Cooperativa
                                     ,pr_cdprogra        => pr_cdprogra       -- Nome do Programa
                                     ,pr_nrdcaixa        => pr_nrdcaixa       -- Numero do Caixa
                                     ,pr_index_creditos  => vr_index_creditos -- Variavel para Indices de credito que esta sendo processado
                                     ,pr_tab_creditos    => vr_tab_creditos   -- Tabela de Memoria de Creditos
                                     -- Tabelas com as informações carregadas
                                     ,pr_tab_arquivos    => vr_tab_arquivos   -- Tabela de Memoria de Arquivos 
                                     ,pr_tab_crapage     => vr_tab_crapage    -- Tabela de Agencias
                                     ,pr_tab_salvar      => vr_tab_salvar     -- Tabela de Diretorios
                                     ,pr_tab_dircoop     => vr_tab_dircoop    -- Tabela de Diretorios
                                     ,pr_tab_cdagesic    => vr_tab_cdagesic   -- Tabela de Agencias Sicredi
                                     ,pr_tab_crapdat     => vr_tab_crapdat    -- Tabela de Datas por Cooperativa
                                     ,pr_tab_rejeicoes   => vr_tab_rejeicoes  -- Tabela de Rejeicoes
                                     ,pr_proc_aut        => 0                 -- Essa procedure esta apenas no CRPS, e é executado com os arquivos do MQ
                                     -- Arquivo e Diretorio
                                     ,pr_nmarquiv         => pr_nmarquiv      -- Nome do arquivo
                                     ,pr_nmdireto_integra => vr_nmdireto      -- Diretorio do Arquivo
                                     -- Erros
                                     ,pr_tpdiverg        => vr_tpdiverg       -- Tipo da Divergencia
                                     ,pr_cod_reto        => vr_cod_reto       -- Retorno (0-OK/1-NOK/2-Divergencia/3-Ignorar Registro)
                                     ,pr_tab_erro        => vr_tab_erro);     -- Tabela Erros
                                     
          CASE vr_cod_reto
            WHEN 0 THEN
              -- Se não ocorreu nenhum problema, comit do pagamento
              COMMIT; 
              -- Incrementa a quantidade processada e o total processado
              pr_qtproces:= pr_qtproces + 1;
              pr_vltotpro:= pr_vltotpro + vr_tab_creditos(vr_index_creditos).vlrbenef;
              
            WHEN 1 THEN
              vr_tab_coop_err(vr_tab_creditos(vr_index_creditos).cdcooper) := vr_tab_creditos(vr_index_creditos).cdcooper;
              -- Quando ocorrer erro, executa o rollback
              RAISE vr_exc_proximo;

            WHEN 2 THEN
              vr_tab_coop_err(vr_tab_creditos(vr_index_creditos).cdcooper) := vr_tab_creditos(vr_index_creditos).cdcooper;
              -- Com divergencia, executa o rollback
              RAISE vr_exc_diverg;
              
            WHEN 3 THEN 
              vr_tab_coop_err(vr_tab_creditos(vr_index_creditos).cdcooper) := vr_tab_creditos(vr_index_creditos).cdcooper;
              -- Se for ignorar o arquivo, ececuta rollback
              RAISE vr_exc_proximo;
          END CASE;
        
        EXCEPTION
          WHEN vr_exc_proximo THEN
            -- Incrementa total de erros
            pr_qtderros:= pr_qtderros + 1;
            pr_vlderros:= pr_vlderros + vr_tab_creditos(vr_index_creditos).vlrbenef;
            -- Desfazer transacao
            ROLLBACK to SAVEPOINT save_trans_crawarq;
          WHEN vr_exc_diverg THEN
            -- Incrementa total de erros
            pr_qtderros:= pr_qtderros + 1;
            pr_vlderros:= pr_vlderros + vr_tab_creditos(vr_index_creditos).vlrbenef;
            -- Desfazer transacao
            ROLLBACK to SAVEPOINT save_trans_crawarq;
        END; --Exception    
      END LOOP;
    EXCEPTION
      WHEN no_data_found THEN
        -- Acabou a leitura
        NULL;
    END;    

    --Se rejeicoes gerar relatorio
    IF vr_tab_rejeicoes.COUNT > 0 THEN
       
      --Gerar relatorio Rejeicoes
      inss0001.pc_gera_relatorio_rejeic (pr_cdcooper      => pr_cdcooper      --Codigo Cooperativa
                                        ,pr_dtmvtolt      => TRUNC(SYSDATE)   --Data movimento
                                        ,pr_cdprogra      => pr_cdprogra      --Codigo Programa
                                        ,pr_tab_arquivos  => vr_tab_arquivos  --Tabela de Arquivos
                                        ,pr_tab_rejeicoes => vr_tab_rejeicoes --Tabela de Rejeicoes
                                        ,pr_dscritic      => vr_dscritic);    --Descricao Erro
                                        
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      pr_nmarqerr:= '';
      vr_index_erro:= vr_tab_coop_err.FIRST;
      WHILE vr_index_erro IS NOT NULL LOOP
      
        OPEN cr_crapcop2(pr_cdcooper => vr_tab_coop_err(vr_index_erro));
        FETCH cr_crapcop2 INTO rw_crapcop2;
        IF cr_crapcop2%FOUND THEN
          IF TRIM(pr_nmarqerr) IS NOT NULL THEN
            pr_nmarqerr:= pr_nmarqerr || ', ';
          END IF;
          pr_nmarqerr:= pr_nmarqerr || rw_crapcop2.nmrescop;
        END IF;
        CLOSE cr_crapcop2;
        
        -- Buscar o próximo
        vr_index_erro := vr_tab_coop_err.NEXT(vr_index_erro);
        
      END LOOP;      
    END IF; 
    
    --Limpar tabelas de memoria
    pc_limpa_tabela;    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Chamar rotina de gravação de erro
      pr_dscritic:= vr_dscritic;
      
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || pr_cdprogra || ' --> ' || 
                                                    'ERRO: ' || vr_dscritic 
                                ,pr_cdprograma   => pr_cdprogra
                                                );
      
    
    WHEN OTHERS THEN
      -- Chamar rotina de gravação de erro
      vr_dscritic:= 'Erro na pc_exec_pagto_benef_plani --> '|| SQLERRM;
      pr_dscritic:= vr_dscritic;
      
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || pr_cdprogra || ' --> ' || 
                                                    'ERRO: ' || vr_dscritic 
                                ,pr_cdprograma   => pr_cdprogra
                                                );
  END pc_exec_pagto_benef_plani;
  
  /*****************************************************************************/
  /**  funcao para encontrar alguma restricao referente a comprovacao de vida **/ 
  /*****************************************************************************/
  FUNCTION fn_bloqueio_inss ( pr_cdcopben IN craplbi.cdcooper%TYPE  --> Codigo do operador
                             ,pr_nrrecben IN craplbi.nrrecben%TYPE  --> Numero de identificacao do recebedor do beneficio.(ID-NIT)
                             ,pr_nrbenefi IN craplbi.nrbenefi%TYPE  --> Numero identificador do beneficio.(NU-NB)
                             ,pr_dtcompvi IN craplbi.dtfimpag%TYPE  --> Data de comprovacao
                             ,pr_dtdmovto IN craplbi.dtfimpag%TYPE  --> Cdate de movimento
                            )RETURN INTEGER IS --> Retorna tipo de bloquei (tpbloque)
     
  /* ..........................................................................
    --
    --  Programa : fn_bloqueio_inss        Antiga: b1wgen0091.p/bloqueio
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Setembto/2015.                   Ultima atualizacao: 18/09/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Funcao para encontrar alguma restricao referente a comprovacao de vida
    --
    --  Alteração : 18/09/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --
    -- ..........................................................................*/
    
    ---------------> cursores <----------------
    --> Busca beneficios bloqueados
    CURSOR cr_craplbi_bloq IS
      SELECT 1
        FROM craplbi
       WHERE craplbi.cdcooper = pr_cdcopben
         AND craplbi.nrrecben = pr_nrrecben
         AND craplbi.nrbenefi = pr_nrbenefi
         AND craplbi.cdsitcre = 2  --> Busca beneficios bloqueados 
         AND craplbi.cdbloque = 9; --> por falta de comprovacao de vida
    rw_craplbi cr_craplbi_bloq%ROWTYPE;
    
    
    /*Busca beneficios que estao sem comprovacao de vida, se recebe no mes
      atual ou se recebeu nos ultimos 2 meses.*/
    CURSOR cr_craplbi_a IS
      SELECT 1
        FROM craplbi
       WHERE craplbi.cdcooper = pr_cdcopben
         AND craplbi.nrrecben = pr_nrrecben
         AND craplbi.nrbenefi = pr_nrbenefi
         AND (craplbi.dtfimpag >= pr_dtdmovto OR
              craplbi.dtdpagto >= add_months(pr_dtdmovto, -2))
         AND pr_dtcompvi IS NULL;
         
    --> Busca registros que realizaram comprovacao de vida
    CURSOR cr_craplbi_b IS
      SELECT 1
        FROM craplbi
       WHERE craplbi.cdcooper = pr_cdcopben
         AND craplbi.nrrecben = pr_nrrecben
         AND craplbi.nrbenefi = pr_nrbenefi
         AND craplbi.dtfimpag >= pr_dtdmovto
         AND pr_dtcompvi IS NOT NULL;
    
    --> Verificar Se o beneficiario recebeu no mes ou nos ultimos 2 meses e que necessitam
     -- comprovar vida ainda neste ano
    CURSOR cr_craplbi_c IS
      SELECT 1
        FROM craplbi
       WHERE craplbi.cdcooper = pr_cdcopben
         AND craplbi.nrrecben = pr_nrrecben
         AND craplbi.nrbenefi = pr_nrbenefi
         AND (craplbi.dtfimpag >= pr_dtdmovto OR
              craplbi.dtdpagto >= add_months(pr_dtdmovto, -2))
         AND to_char(pr_dtcompvi,'RRRR') < to_char(pr_dtdmovto,'RRRR');
    
    vr_przexpir NUMBER;
    
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 664301
		GENE0001.pc_set_modulo(pr_module => 'INSS0001', pr_action => 'INSS0001.fn_bloqueio_inss');
      
    vr_przexpir := 0; --FALSE
    
    --> Busca beneficios bloqueados (cdsitcre = 2) por falta de comprovacao de vida (cdbloque = 9)
    OPEN cr_craplbi_bloq;
    FETCH cr_craplbi_bloq INTO rw_craplbi;
    
    IF cr_craplbi_bloq%FOUND THEN
      CLOSE cr_craplbi_bloq; 
      RETURN 1; --tpbloque
    ELSE
      CLOSE cr_craplbi_bloq;
    END IF;
    
    --> Busca beneficios que estao sem comprovacao de vida, se recebe no mes
      -- atual ou se recebeu nos ultimos 2 meses.
    OPEN cr_craplbi_a;
    FETCH cr_craplbi_a INTO rw_craplbi;
    
    IF cr_craplbi_a%FOUND THEN
      CLOSE cr_craplbi_a;
      RETURN 2; --tpbloque
    ELSE
      CLOSE cr_craplbi_a;
    END IF;
    
    /*Verifica se a data de comprovacao de vida esta proximo dos
      60 dias em relacao ao prazo final.*/
    IF add_months(pr_dtcompvi,12) >= pr_dtdmovto THEN --se já expirou
      -- se ainda não ultrapassou 60 dias do expiração
      IF (add_months(pr_dtcompvi,12) - pr_dtdmovto) <= (add_months(pr_dtdmovto,2) - pr_dtdmovto) THEN
        vr_przexpir := 1; --TRUE
      END IF;  
    ELSE
      -- se falta menos de 60 dia para expirar
      IF (pr_dtdmovto - add_months(pr_dtcompvi,12)) <= (pr_dtdmovto - add_months(pr_dtdmovto,-2) ) THEN
        vr_przexpir := 1; --TRUE
      END IF;
    END IF;
    
    /*Busca registros que realizaram comprovacao de vida e que, a data de
     comprovacao, esteja proximo aos 60 dias da data de expiracao da 
     comprovacao (prazo de um ano a partir da data de comprovacao). */
    IF vr_przexpir = 1 THEN 
      OPEN cr_craplbi_b;
      FETCH cr_craplbi_b INTO rw_craplbi;
      
      IF cr_craplbi_b%FOUND THEN
        CLOSE cr_craplbi_b;
        RETURN 3; --tpbloque
      ELSE
        CLOSE cr_craplbi_b;
      END IF;
    END IF;
    
    --> Se o beneficiario recebeu no mes ou nos ultimos 2 meses e que necessitam
    --  comprovar vida ainda neste ano
    OPEN cr_craplbi_c;
    FETCH cr_craplbi_c INTO rw_craplbi;
    
    IF cr_craplbi_c%FOUND THEN
      CLOSE cr_craplbi_c;
      RETURN 4; --tpbloque
    ELSE
      CLOSE cr_craplbi_c;
    END IF;
    
    RETURN 0; --tpbloque
    
  END fn_bloqueio_inss;      
  
  /*****************************************************************************/
  /**                 funcao verificar bloquieo INSS                          **/ 
  /*****************************************************************************/
  FUNCTION fn_verifica_bloqueio_inss ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nmdatela IN VARCHAR2               --> Nome da tela
                                      ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                      ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE  --> CPF/CNPJ do cooperado
                                      ,pr_nrprocur IN crapcbi.nrbenefi%TYPE  --> Numero do beneficio a ser procurado
                                      ,pr_tpdconsu IN INTEGER                --> Tipo de consulta
                            )RETURN INTEGER IS --> Retorna tipo de bloqueio (tpbloque)
     
  /* ..........................................................................
    --
    --  Programa : fn_verifica_bloqueio_inss        Antiga: b1wgen0091.p/verificacao_bloqueio
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Setembto/2015.                   Ultima atualizacao: 22/09/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : FUNCAO RESPONSAVEL POR VERIFICAR OS ITENS ABAIXO:
    --                  RETURN   => 1 - Beneficio bloqueado por falta de comprovacao de vida
    --                              2 - Comprovacao ainda nao efetuada   
    --                              3 - Menos de 60 dias para expirar o prazo de comprovacao  
    --                  tpdconsu => 1 - Busca qualquer registro referente ao cpf informado
    --                              2 - Busca um registro especifico */
    --
    --  Alteração : 22/09/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------
    --> Buscar beneficiarios do INSS.
    CURSOR cr_crapcbi_1(pr_cdcooper crapcbi.cdcooper%TYPE,
                        pr_nrcpfcgc crapcbi.nrcpfcgc%TYPE) IS
      SELECT crapcbi.cdcooper,
             crapcbi.nrrecben,
             crapcbi.nrbenefi,
             crapcbi.dtcompvi
        FROM crapcbi crapcbi
       WHERE crapcbi.cdcooper = pr_cdcooper 
         AND crapcbi.nrcpfcgc = pr_nrcpfcgc;
    
    --> Buscar beneficiarios do INSS.
    CURSOR cr_crapcbi_2(pr_cdcooper crapcbi.cdcooper%TYPE,
                        pr_nrrecben crapcbi.nrrecben%TYPE,
                        pr_nrbenefi crapcbi.nrbenefi%TYPE) IS
      SELECT crapcbi.cdcooper
            ,crapcbi.nrrecben
            ,crapcbi.nrbenefi
            ,crapcbi.dtcompvi
        FROM crapcbi crapcbi
       WHERE crapcbi.cdcooper = pr_cdcooper
         AND crapcbi.nrrecben = pr_nrrecben
         AND crapcbi.nrbenefi = pr_nrbenefi;
    
    
    vr_tpbloque NUMBER := 0;
    vr_bloqueio NUMBER := 0;
    
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => 'INSS0001', pr_action => 'INSS0001.fn_verifica_bloqueio_inss');    
  
    vr_tpbloque := 0;
    vr_bloqueio := 0;
    
    /*Qualquer beneficio com referencia ao cpf informado*/
    IF pr_tpdconsu = 1 THEN
    
      --> Buscar beneficiarios do INSS.
      FOR rw_crapcbi IN cr_crapcbi_1(pr_cdcooper => pr_cdcooper,
                                      pr_nrcpfcgc => pr_nrcpfcgc ) LOOP
                                      
        vr_bloqueio := fn_bloqueio_inss ( pr_cdcopben => rw_crapcbi.cdcooper  --> Codigo do operador
                                         ,pr_nrrecben => rw_crapcbi.nrrecben --> Numero de identificacao do recebedor do beneficio.(ID-NIT)
                                         ,pr_nrbenefi => rw_crapcbi.nrbenefi --> Numero identificador do beneficio.(NU-NB)
                                         ,pr_dtcompvi => rw_crapcbi.dtcompvi --> Data de comprovacao
                                         ,pr_dtdmovto => pr_dtmvtolt);       --> Cdate de movimento
        IF vr_bloqueio > vr_tpbloque THEN
          vr_tpbloque := vr_bloqueio;
        END IF;  
      END LOOP;
    
    ELSIF pr_tpdconsu = 2 THEN /*Busca beneficio informado*/
    
      --> Buscar beneficiarios do INSS.
      FOR rw_crapcbi IN cr_crapcbi_2(pr_cdcooper => pr_cdcooper,
                                      pr_nrrecben => 0,
                                      pr_nrbenefi => pr_nrprocur) LOOP
                                      
        vr_bloqueio := fn_bloqueio_inss ( pr_cdcopben => rw_crapcbi.cdcooper  --> Codigo do operador
                                         ,pr_nrrecben => rw_crapcbi.nrrecben --> Numero de identificacao do recebedor do beneficio.(ID-NIT)
                                         ,pr_nrbenefi => rw_crapcbi.nrbenefi --> Numero identificador do beneficio.(NU-NB)
                                         ,pr_dtcompvi => rw_crapcbi.dtcompvi --> Data de comprovacao
                                         ,pr_dtdmovto => pr_dtmvtolt);       --> Cdate de movimento
        IF vr_bloqueio > vr_tpbloque THEN
          vr_tpbloque := vr_bloqueio;
        END IF;  
      END LOOP;
      
      
      --> Buscar beneficiarios do INSS.
      FOR rw_crapcbi IN cr_crapcbi_2(pr_cdcooper => pr_cdcooper,
                                      pr_nrrecben => pr_nrprocur,
                                      pr_nrbenefi => 0) LOOP
                                      
        vr_bloqueio := fn_bloqueio_inss ( pr_cdcopben => rw_crapcbi.cdcooper  --> Codigo do operador
                                         ,pr_nrrecben => rw_crapcbi.nrrecben --> Numero de identificacao do recebedor do beneficio.(ID-NIT)
                                         ,pr_nrbenefi => rw_crapcbi.nrbenefi --> Numero identificador do beneficio.(NU-NB)
                                         ,pr_dtcompvi => rw_crapcbi.dtcompvi --> Data de comprovacao
                                         ,pr_dtdmovto => pr_dtmvtolt);       --> Cdate de movimento
        IF vr_bloqueio > vr_tpbloque THEN
          vr_tpbloque := vr_bloqueio;
        END IF;  
      END LOOP;
    END IF;
           
    RETURN vr_tpbloque;
    
  END fn_verifica_bloqueio_inss ;
  
  --Obtem situacao da senha do Tele-Atendimento
  PROCEDURE pc_verifica_situacao_senha (pr_nrdconta IN crapass.nrdconta%TYPE --Numero da conta do beneficiario
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE --Numero do beneficiario
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2) IS         --Saida OK/NOK
                                     
  /*---------------------------------------------------------------------------------------------------------------
  
  Programa : pc_verifica_situacao_senha
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Lombardi
  Data     : Outubro/2015                           Ultima atualizacao: ---/--/----
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo   : Obtem situacao da senha do Tele-Atendimento
  
  Alterações : 
              
  -------------------------------------------------------------------------------------------------------------*/
    
  -- Busca conta do beneficiario
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT * 
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
  
    -- Variaveis extraídas do log
    vr_cdcooper INTEGER := 0;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_cdoperad VARCHAR2(100);
  
  
    -- Campos para o XML
    vr_hrmvtolt VARCHAR2(100);
    vr_nrdconta VARCHAR2(100);
    vr_nmdconta VARCHAR2(100);
    vr_nrrecben VARCHAR2(100);
    vr_historic VARCHAR2(100);
    vr_operador VARCHAR2(100);
    
    -- Auxiliares
    vr_situacao VARCHAR2(20);
    
    -- Variaveis para erros
    vr_dscritic  VARCHAR2(1000);
    vr_cdcritic  INTEGER;
    vr_exc_saida EXCEPTION;
    
    BEGIN
      
      CECRED.GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                                     ,pr_cdcooper => vr_cdcooper
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_nmeacao  => vr_nmeacao
                                     ,pr_cdagenci => vr_cdagenci
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_idorigem => vr_idorigem
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_dscritic => vr_dscritic);
  
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_verifica_situacao_senha');    
  
      vr_situacao := CADA0004.fn_situacao_senha(pr_cdcooper => vr_cdcooper
                                               ,pr_cdagenci => vr_cdagenci
                                               ,pr_nrdcaixa => vr_nrdcaixa
                                               ,pr_cdoperad => vr_cdoperad
                                               ,pr_nmdatela => vr_nmdatela
                                               ,pr_idorigem => vr_idorigem
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_tpdsenha => 1 -- Internet
                                               ,pr_idseqttl => pr_idseqttl);
      
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados><situacao>' || vr_situacao || '</situacao></Dados>');
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
				
        --Se nao tem a descricao do erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina inss0001.pc_solicita_log. '|| SQLERRM;
        
  END pc_verifica_situacao_senha;
  
  -- Consultar log de INSS
  PROCEDURE pc_consulta_log (pr_dtmvtlog IN VARCHAR2            --Data dos registros no log
                            ,pr_nrdnblog IN VARCHAR2            --Numero do beneficiario
                            ,pr_nrdctlog IN VARCHAR2            --Numero da conta do beneficiario
                            ,pr_nriniseq IN VARCHAR2            --Numero do primeiro registro a ser retornado
                            ,pr_qtregist IN VARCHAR2            --Numero de registros a serem retornados
                            ,pr_xmllog   IN VARCHAR2            --XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER        --Código da crítica
                            ,pr_dscritic OUT VARCHAR2           --Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType  --Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2           --Nome do Campo
                            ,pr_des_erro OUT VARCHAR2) IS       --Saida OK/NOK
                                     
  /*---------------------------------------------------------------------------------------------------------------
  
  Programa : pc_consulta_log
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Lombardi
  Data     : Outubro/2015                           Ultima atualizacao: ---/--/----
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo   : Consultar log.
  
  Alterações : 
              
  -------------------------------------------------------------------------------------------------------------*/
    
    -- Campos para o XML
    vr_dtmvtolt VARCHAR2(10000);
    vr_hrmvtolt VARCHAR2(10000);
    vr_nrdconta VARCHAR2(10000);
    vr_nmdconta VARCHAR2(10000);
    vr_nrrecben VARCHAR2(10000);
    vr_historic VARCHAR2(10000);
    vr_operador VARCHAR2(10000);
    
    --Temporario
    vr_temp1 INTEGER := pr_nriniseq;
    vr_temp2 INTEGER := pr_qtregist;
    
    --Variaveis para extrair do log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_cdoperad VARCHAR2(100);
    
    -- Auxiliares
    vr_caminho   VARCHAR2(10000);
    log          UTL_FILE.file_type;
    vr_nmlog     VARCHAR2(10000) := 'resultado_comando.txt';
    vr_tab_log   typ_tab_log;
    linha        VARCHAR(10000);
    vr_fim_log   BOOLEAN := FALSE;
    vr_posicao   INTEGER;
    vr_xml       CLOB;
    vr_qtregist  INTEGER := 0;
    vr_contador  INTEGER := 0;
    vr_comando   VARCHAR2(2000);
    vr_typ_saida VARCHAR2(100);
    vr_des_saida VARCHAR2(1000);
    
    -- Variaveis para erros
    vr_dscritic  VARCHAR2(1000);
    vr_cdcritic  INTEGER;
    vr_exc_saida EXCEPTION;
    
    BEGIN
      CECRED.GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                                     ,pr_cdcooper => vr_cdcooper
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_nmeacao  => vr_nmeacao
                                     ,pr_cdagenci => vr_cdagenci
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_idorigem => vr_idorigem
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_dscritic => vr_dscritic);
                                     
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'INSS0001.pc_consulta_log');
      
      -- Pega o diretorio do log
      vr_caminho := cecred.gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                ,pr_cdcooper => vr_cdcooper
                                                ,pr_nmsubdir => '/log'); --> Utilizaremos o rl
      -- Prepara o comando unix
      vr_comando := 'cat ' || vr_caminho ||'/inss_historico.log';
      -- Filtrar pela data
      IF to_char(pr_dtmvtlog) != '0'THEN
        vr_comando := vr_comando || ' | grep "' || REPLACE(pr_dtmvtlog,'/','\/') || '"';
      END IF;
      -- Filtrar pelo nb
      IF to_char(pr_nrdnblog) != '0' THEN
        vr_comando := vr_comando || ' | grep "' || lpad(pr_nrdnblog,10,'0') || '"';
      END IF;
      -- Filtrar pela conta
      IF pr_nrdctlog != '0000.000-0' OR pr_nrdctlog != '0' THEN
        vr_comando := vr_comando || ' | grep "' || pr_nrdctlog || '"';
      END IF;
      -- Coloca o resultado em um arquivo
      vr_comando := vr_comando || ' >>' || vr_caminho || '/' || vr_nmlog;
      
      -- Executa comando
      gene0001.pc_OSCommand_Shell(pr_des_comando => vr_comando
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_saida);
      
      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic := 'Nenhum registro encontrado.';
        RAISE vr_exc_saida;    
      END IF;
      
      -- Leitura do arquivo de log
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_caminho   --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_nmlog     --> Nome do arquivo
                              ,pr_tipabert => 'R'          --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => log          --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);--> Descricão da critica
         
      IF vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'Nenhum registro encontrado.';
        RAISE vr_exc_saida;
      END IF;
      
      BEGIN
        LOOP
          -- Verifica se o arquivo está aberto
          IF utl_file.IS_OPEN(log) THEN
            -- Ler linha
            gene0001.pc_le_linha_arquivo(pr_utlfileh => log --> Handle do arquivo aberto
                                        ,pr_des_text => linha);  --> Texto lido
            -- Data
            vr_dtmvtolt := substr(linha, 1, 10);
            linha := substr(linha, INSTR(linha, 'Horario: ') + 9);
               
            -- Hora
            vr_posicao := instr(linha, ' ');
            vr_hrmvtolt := substr(linha, 1, vr_posicao - 1);
            linha := substr(linha, instr(linha, ': ') + 2);
              
            -- Conta
            vr_posicao := instr(linha, ' ');
            vr_nrdconta := substr(linha, 1, vr_posicao - 1);
            linha := substr(linha, instr(linha, ': ') + 2);
              
            -- Nome
            vr_posicao := instr(linha, ' |');
            vr_nmdconta := trim(substr(linha, 1, vr_posicao - 1));
            linha := substr(linha, instr(linha, ': ') + 2);
              
            -- Numero do Beneficiario
            vr_posicao := instr(linha, ' ');
            vr_nrrecben := substr(linha, 1, vr_posicao - 1);
            linha := substr(linha, instr(linha, ': ') + 2);
              
            -- Operador
            vr_posicao := instr(linha, ' |');
            vr_operador := trim(substr(linha, 1, vr_posicao - 1));
            linha := substr(linha, instr(linha, ': ') + 2);
              
            -- Alteracao
            vr_historic := linha;
            
            -- Cria sequncial com a data e as horas
            vr_qtregist := vr_qtregist + 1;
            
            -- Popula tabela
            vr_tab_log(vr_qtregist).dtmvtolt := vr_dtmvtolt;
            vr_tab_log(vr_qtregist).hrmvtolt := vr_hrmvtolt;
            vr_tab_log(vr_qtregist).nrdconta := vr_nrdconta;
            vr_tab_log(vr_qtregist).nmdconta := substr(vr_nmdconta,1,20);
            vr_tab_log(vr_qtregist).nrrecben := vr_nrrecben;
            vr_tab_log(vr_qtregist).historic := vr_historic;
            vr_tab_log(vr_qtregist).operador := vr_operador;
            
          END IF;
        END LOOP;
      EXCEPTION
        WHEN no_data_found THEN
          -- Fechar o arquivo
          gene0001.pc_fecha_arquivo(log); --> Handle do arquivo aberto;
        WHEN OTHERS THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro na rotina inss0001.pc_solicita_log. '|| SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      --Remove o arquivo XML fisico de retorno
      GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'rm '|| vr_caminho || '/'|| vr_nmlog ||' 2> /dev/null'
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_des_saida);
      
      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic := vr_des_saida;
        RAISE vr_exc_saida;    
      END IF;
      
      vr_contador := 0;
      -- Popula xml
      FOR vr_index IN REVERSE 1 .. vr_qtregist LOOP
        vr_contador := vr_contador + 1;
        IF vr_contador BETWEEN vr_temp1 AND (vr_temp1 + vr_temp2) THEN
          vr_xml := vr_xml ||
                        '<reg>' ||
                            '<dtmvtolt>' || vr_tab_log(vr_index).dtmvtolt || '</dtmvtolt>' ||
                            '<hrmvtolt>' || vr_tab_log(vr_index).hrmvtolt || '</hrmvtolt>' ||
                            '<nrdconta>' || vr_tab_log(vr_index).nrdconta || '</nrdconta>' ||
                            '<nmdconta>' || vr_tab_log(vr_index).nmdconta || '</nmdconta>' ||
                            '<nrrecben>' || vr_tab_log(vr_index).nrrecben || '</nrrecben>' ||
                            '<historic>' || vr_tab_log(vr_index).historic || '</historic>' ||
                            '<operador>' || vr_tab_log(vr_index).operador || '</operador>' ||
                        '</reg>';
        END IF;
      END LOOP;
      
      -- Retorna lista
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados><registros>' || vr_xml || '</registros><qtregistros>' || vr_qtregist || '</qtregistros></Dados>');
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Se nao tem a descricao do erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina inss0001.pc_solicita_log. '|| SQLERRM;
        
  END pc_consulta_log;
  
  --Buscar relatorios solicitados
  PROCEDURE pc_envia_msg_venc_pv (pr_cdcritic OUT PLS_INTEGER        --Código da crítica
                                 ,pr_dscritic OUT VARCHAR2) IS       --Descrição da crítica
                                     
  /*---------------------------------------------------------------------------------------------------------------
  
  Programa : pc_envia_msg_venc_pv
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Lombardi
  Data     : Novembro/2015                           Ultima atualizacao: ---/--/----
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo   : Enviar mensagem referente ao vencimento da prova de vida.
  
  Alterações : 
  -------------------------------------------------------------------------------------------------------------*/
  
    CURSOR cr_tbinss_dcb(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      Select distinct nmbenefi
            ,nrrecben
            ,nrdconta
            ,dtvencpv
            ,cdcooper
      FROM tbinss_dcb
     WHERE cdcooper = pr_cdcooper
       AND (TRUNC(dtvencpv) = TRUNC(SYSDATE + 30)
        OR TRUNC(dtvencpv) = TRUNC(SYSDATE + 60)
        OR TRUNC(dtvencpv) = TRUNC(SYSDATE - 1));
    
    CURSOR cr_crapmsg (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_nrdiaven IN INTEGER) IS
      SELECT dtdmensg
        FROM crapmsg
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND dtdmensg >= TRUNC(SYSDATE - pr_nrdiaven);
         
    CURSOR cr_crapcop IS
      SELECT cdcooper
            ,nmrescop
        FROM crapcop;
    
    --Variaveis Auxiliares
    vr_titulo_msg VARCHAR2(100);
    vr_corpo_msg VARCHAR2(1000);
    
    -- Variaveis para erros
    vr_dscritic  VARCHAR2(1000);
    vr_cdcritic  INTEGER;
    vr_exc_saida EXCEPTION;
    
    BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => 'INSS0001', pr_action => 'INSS0001.pc_envia_msg_venc_pv');      
    
    FOR rw_crapcop IN cr_crapcop LOOP
    
      FOR rw_tbinss_dcb IN cr_tbinss_dcb(rw_crapcop.cdcooper) LOOP
        IF (TRUNC(rw_tbinss_dcb.dtvencpv) = TRUNC(SYSDATE + 30))
        OR (TRUNC(rw_tbinss_dcb.dtvencpv) = TRUNC(SYSDATE + 60)) THEN
          vr_titulo_msg := 'Renovação Prova de Vida';
          vr_corpo_msg := 'Convocamos você cooperado a comparecer em qualquer ' ||
                          'Posto de Atendimento da sua cooperativa, levando consigo ' ||
                          'um documento oficial com foto, para realizar sua Prova de ' ||
                          'Vida, em cumprimento da norma do INSS. O procedimento é ' ||
                          'simples, rápido e deve ser feito para que o seu benefício ' ||
                          'não seja bloqueado. A prova de vida do seu benefício ' ||
                          rw_tbinss_dcb.nrrecben || ' vence dia ' || 
                          to_char(rw_tbinss_dcb.dtvencpv,'DD/MM/YYYY') || '.';
        ELSE
          vr_titulo_msg := 'Renovação Prova de Vida (Vencida)';
          vr_corpo_msg := 'Convocamos você cooperado a comparecer em qualquer ' ||
                          'Posto de Atendimento da sua cooperativa, levando ' ||
                          'consigo um documento oficial com foto, para realizar ' ||
                          'sua Prova de Vida, em cumprimento da norma do INSS. ' ||
                          'A prova de vida do benefício ' || rw_tbinss_dcb.nrrecben ||
                          ' venceu dia ' || to_char(rw_tbinss_dcb.dtvencpv,'DD/MM/YYYY') ||
                          ' e seu próximo benefício pode ser bloqueado pelo INSS.';
        END IF;
        GENE0003.pc_gerar_mensagem(pr_cdcooper => rw_tbinss_dcb.cdcooper,
                                   pr_nrdconta => rw_tbinss_dcb.nrdconta,
                                   pr_idseqttl => 1, -- fixo Primeiro titular
                                   pr_cdprogra => 'INSS0001',
                                   pr_inpriori => 0,
                                   pr_dsdmensg => vr_corpo_msg,
                                   pr_dsdassun => vr_titulo_msg,
                                   pr_dsdremet => rw_crapcop.nmrescop,
                                   pr_dsdplchv => 'INSS',
                                   pr_cdoperad => '1',
                                   pr_cdcadmsg => '0',
                                   pr_dscritic => vr_dscritic);


        IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || 'INSS0001' || ' --> ' || 
                                                    'ERRO: ' || vr_dscritic ||
                                                    ' - '    || vr_cdcritic
                                    ,pr_cdprograma   => 'INSS0001'
                                                           );

        ELSE -- se nao gerar erro na criacao de avisos
          COMMIT;
        END IF;
      END LOOP;
    END LOOP;  
    EXCEPTION
      WHEN vr_exc_saida THEN
        
        --Se nao tem a descricao do erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
      WHEN OTHERS THEN
        -- Chamar rotina de gravação de erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina inss0001.pc_solicita_log. '|| SQLERRM;
        
  END pc_envia_msg_venc_pv;
  
  --Funcao para buscar senha da sicredi
  FUNCTION fn_senha_sicredi RETURN VARCHAR2 IS
  /*............................................................................

   Programa: fn_senha_sicredi 
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lombardi
   Data    : Dezembro/2015                          Ultima atualizacao: 21/06/2016

   Dados referentes ao programa:
   
   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Busca senha da sicredi.
               
   Alteracoes: 08/04/2016 - Alterado para buscar o mesmo parametro já utilizado
                            no GPS/INSS0002 (Guilherme/SUPERO)
              
               21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                            (Adriano - SD 473539).
                            
  .............................................................................*/  
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => 'INSS0001', pr_action => 'INSS0001.fn_senha_sicredi');    
      
    RETURN gene0001.fn_param_sistema('CRED',0,'PWD_SICREDI_GPS');
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(NULL);  
  END fn_senha_sicredi;  
	
	-- Procedure para alimentar a tabela de beneficiarios do inss
  -- Chamado 660327 eliminada a rotina pc_popula_dcb_inss
						      
  PROCEDURE pc_busca_demonst_sicredi (pr_cdcooper IN crapcop.cdcooper%TYPE
                                     ,pr_nrdconta IN crapcop.nrdconta%TYPE
                                     ,pr_cdagesic IN crapcop.cdagesic%TYPE
                                     ,pr_dtextrat IN DATE
                                     ,pr_cdcritic OUT INTEGER                            --> Cód. da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS                       --> Desc. da crítica
   /*------------------------------------------------------------------------------
   Programa: pc_busca_demonst_sicredi       Antiga: Não há
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Guilherme/SUPERO
   Data    : 06/04/2016                        Ultima atualizacao: 21/06/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Procedimento para retornar o demonstrativo INSS via Webservice SICREDI
               e gravar na base Cecred.

   Alteracoes: 31/05/2016 - Ajuste na pc_busca_demonst_sicredi para não gravar dados do XML
                            que não são referentes ao mês da consulta
                            Retirar o TO_DATE no insert da "DCB" (Guilherme/SUPERO)
                            
               21/06/2016 - Ajuste para enviar o arquivo destino ao subdiretorio inss dentro da pasta salvar
                           (Adriano - SD 473539).             
                            
                            
  -------------------------------------------------------------------------------*/

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;

    --Variaveis Locais
    vr_dtinimes   DATE := TRUNC(pr_dtextrat,'MM') ;
    vr_dtlimite   DATE := add_months(pr_dtextrat,-1);  -- Data limite = Mes solicitado -1
    vr_dtfimmes   DATE := last_day(pr_dtextrat);
    vr_qtlinha    INTEGER;
    vr_nmdireto   VARCHAR2(1000);
    vr_nmarqlog   VARCHAR2(32767);
    vr_dstime     VARCHAR2(100);
    vr_msgenvio   VARCHAR2(32767);
    vr_msgreceb   VARCHAR2(32767);
    vr_movarqto   VARCHAR2(32767);
    vr_des_reto   VARCHAR2(3);
    vr_dstexto    VARCHAR2(32767);
    vr_nmparam    VARCHAR2(1000);
    vr_nrcpfcgc   crapdbi.nrcpfcgc%TYPE;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    --Variaveis DOM
    vr_XML        XMLType;
    vr_xmldoc     xmldom.DOMDocument;
    vr_lista_nodo DBMS_XMLDOM.DOMNodelist;
    vr_nodo       xmldom.DOMNode;

     --Tabelas de Memoria
    vr_tab_rubrica inss0001.typ_tab_rubrica;
    vr_tab_demonst inss0001.typ_tab_demonstrativos;

    --Indices para tabelas memoria
    vr_index_demonst PLS_INTEGER;
    vr_index_rubrica PLS_INTEGER;   


    -- verifica se ja existe o nro beneficio no mes selecionado
    CURSOR cr_tbinss_dcb(pr_cdcooper IN tbinss_dcb.cdcooper%TYPE
                        ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE
                        ,pr_cdagesic IN tbinss_dcb.cdagencia_conv%TYPE
                        ,pr_nrrecben IN tbinss_dcb.nrrecben%TYPE) IS
      SELECT tbinss_dcb.id_dcb
				    ,tbinss_dcb.nrrecben
  			FROM tbinss_dcb
	     WHERE tbinss_dcb.cdcooper  = pr_cdcooper
         AND tbinss_dcb.nrdconta  = pr_nrdconta
         AND tbinss_dcb.dtcompet >= vr_dtinimes
         AND tbinss_dcb.dtcompet <= vr_dtfimmes
         AND tbinss_dcb.cdagencia_conv = pr_cdagesic
         AND tbinss_dcb.nrrecben = pr_nrrecben;
    rw_tbinss_dcb cr_tbinss_dcb%ROWTYPE;

    -- Buscar cpf do beneficiario
    CURSOR cr_crapdbi(pr_nrrecben IN crapdbi.nrrecben%TYPE) IS
      SELECT dbi.nrcpfcgc
        FROM crapdbi dbi
       WHERE dbi.nrrecben = pr_nrrecben
         AND rownum = 1;
    rw_crapdbi cr_crapdbi%ROWTYPE;

    -- Verificar se existe rubrica
    CURSOR cr_tbinss_rubrica(pr_cdrubric tbinss_rubrica.cdrubric%TYPE) IS
      SELECT  1
        FROM tbinss_rubrica rbc
       WHERE rbc.cdrubric = pr_cdrubric;
    rw_tbinss_rubrica cr_tbinss_rubrica%ROWTYPE;

    -- Trazer último lcm do beneficiario
    CURSOR cr_tbinss_landcb(pr_iddcb IN tbinss_landcb.id_dcb%TYPE) IS
      SELECT nvl(max(ldcb.nrseqlan),0) nrseqlan
        FROM tbinss_landcb ldcb
       WHERE ldcb.id_dcb = pr_iddcb;
    rw_tbinss_landcb cr_tbinss_landcb%ROWTYPE;
 
  BEGIN
	  -- Incluir nome do módulo logado - Chamado 664301
		GENE0001.pc_set_modulo(pr_module => 'INSS0001', pr_action => 'INSS0001.pc_busca_demonst_sicredi');    

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
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
  
  
    -- INICIO BUSCA DADOS WEBSERVICE
    
    --Buscar Diretorio Padrao da Cooperativa
    vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => null);

    --Determinar Nomes do Arquivo de Log
    vr_nmarqlog:= 'SICREDI_Soap_LogErros';

    --Buscar o Horario
    vr_dstime:= lpad(gene0002.fn_busca_time,5,'0');

    --Determinar Nomes do Arquivo de Envio - CONsulta DEMonstrativo
    vr_msgenvio:= vr_nmdireto|| '/arq/INSS.SOAP.ECONDEM'||
                  to_char(rw_crapdat.dtmvtolt,'DDMMYYYY')||
                  pr_nrdconta||vr_dstime;

    --Determinar Nome do Arquivo de Recebimento - CONsulta DEMonstrativo
    vr_msgreceb:= vr_nmdireto||'/arq/INSS.SOAP.RCONDEM'||
                  to_char(rw_crapdat.dtmvtolt,'DDMMYYYY')||
                  pr_nrdconta||vr_dstime;

    --Determinar Nome Arquivo movido
    vr_movarqto:= vr_nmdireto||'/salvar/inss';


    /*Monta as tags de envio
    OBS.: O valor das tags deve respeitar a formatacao presente na
    base do SICREDI do contrario, a operacao nao sera realizada. */

    --Gerar cabecalho XML
    INSS0001.pc_gera_cabecalho_soap (pr_idservic => 1   /* idservic */
                                    ,pr_nmmetodo => 'ben:InConsultarDemonstrativoINSS' --Nome Metodo
                                    ,pr_username => 'app_cecred_client' --Username
                                    ,pr_password => INSS0001.fn_senha_sicredi --Senha
                                    ,pr_dstexto  => vr_dstexto          --Texto do Arquivo de Dados
                                    ,pr_des_reto => vr_des_reto         --Retorno OK/NOK
                                    ,pr_dscritic => vr_dscritic);       --Descricao da Critica

    --Se ocorreu erro
    IF vr_des_reto = 'NOK' THEN
      -- Gerar critica no log
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || 'INSS0001' || ' --> ' || 
                                                    'ALERTA: ' || vr_dscritic ||
                                                    ' - pc_busca_demonst_sicredi - Erro ao gerar cabecalho. Conta: ' ||
                                                    pr_nrdconta|| ' Coop: '||pr_cdcooper
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_cdprograma   => 'INSS0001'
                                );
      -- encerra paralelo
      RAISE vr_exc_saida;
    END IF;

    --Montar o XML
    vr_dstexto:= vr_dstexto||
                '<ben:dadosContaCorrente>'   ||
                '  <ben:numAgencia>'         || pr_cdagesic ||'</ben:numAgencia>'||
                '  <ben:contaCorrente>'      || lpad(pr_nrdconta, 10, '0')||'</ben:contaCorrente>'||
                '  <ben:dataInicialValidade>'|| to_char(vr_dtinimes, 'rrrr-mm-dd')||'T00:00:00</ben:dataInicialValidade>' ||
                '  <ben:dataFinalValidade>'  || to_char(vr_dtfimmes, 'rrrr-mm-dd')||'T24:00:00</ben:dataFinalValidade>' ||
                '</ben:dadosContaCorrente>';

    vr_dstexto:= vr_dstexto||
         '</ben:InConsultarDemonstrativoINSS>'||
         '</soapenv:Body></soapenv:Envelope>';

    --Efetuar Requisicao Soap
    INSS0001.pc_efetua_requisicao_soap (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                       ,pr_cdagenci => 1             --Codigo Agencia
                                       ,pr_nrdcaixa => 100           --Numero Caixa
                                       ,pr_idservic => 4             --Identificador Servico
                                       ,pr_dsservic => 'Consulta'    --Descricao Servico
                                       ,pr_nmmetodo => 'OutConsultarDemonstrativoINSS' --Nome Método
                                       ,pr_dstexto  => vr_dstexto    --Texto com a msg XML
                                       ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                       ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                       ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                       ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo Log
                                       ,pr_nmdatela => 'INSS0001'     --Nome da Tela
                                       ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                       ,pr_dscritic => vr_dscritic); --Descrição Erros
    --Se ocorreu erro
    IF vr_des_reto = 'NOK' THEN
      -- Gerar critica no log
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || 'INSS0001' || ' --> ' || 
                                                    'ALERTA: ' || vr_dscritic ||
                                                    ' - pc_busca_demonst_sicredi - Erro ao efetuar requisicao. Conta: ' ||
                                                    pr_nrdconta || ' Coop: '||pr_cdcooper
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_cdprograma   => 'INSS0001'
                                );

      -- encerra paralelo
      RAISE vr_exc_saida;
    END IF;

    --Verifica Falha no Pacote
    inss0001.pc_obtem_fault_packet (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                   ,pr_nmdatela => 'INSS0001'     --Nome da Tela
                                   ,pr_cdagenci => 1             --Codigo Agencia
                                   ,pr_nrdcaixa => 100           --Numero Caixa
                                   ,pr_dsderror => 'SOAP-ENV:-950' --Descricao Servico
                                   ,pr_msgenvio => vr_msgenvio   --Mensagem Envio
                                   ,pr_msgreceb => vr_msgreceb   --Mensagem Recebimento
                                   ,pr_movarqto => vr_movarqto   --Nome Arquivo mover
                                   ,pr_nmarqlog => vr_nmarqlog   --Nome Arquivo log
                                   ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                   ,pr_dscritic => vr_dscritic); --Mensagem Erro

    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
      -- Gerar critica no log
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || 'INSS0001' || ' --> ' || 
                                                    'ALERTA: ' || vr_dscritic ||
                                                    ' - pc_busca_demonst_sicredi - Erro. Conta: ' ||
                                                    pr_nrdconta || ' Coop: '||pr_cdcooper
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_cdprograma   => 'INSS0001'
                                );
      -- encerra paralelo
      RAISE vr_exc_saida;
    ELSE
      /** Valida SOAP retornado pelo WebService **/
      gene0002.pc_arquivo_para_xml (pr_nmarquiv => vr_msgreceb    --> Nome do caminho completo)
                                   ,pr_xmltype  => vr_XML         --> Saida para o XML
                                   ,pr_des_reto => vr_des_reto    --> Descrição OK/NOK
                                   ,pr_dscritic => vr_dscritic    --> Descricao Erro
                                   ,pr_tipmodo  => 2);

      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        -- Gerar critica no log
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || 'INSS0001' || ' --> ' || 
                                                    'ALERTA: ' || vr_dscritic ||
                                                      ' - pc_busca_demonst_sicredi - Erro conversao do arquivo para xml. Conta: ' ||
                                                      pr_nrdconta || ' Coop: '||pr_cdcooper
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_cdprograma   => 'INSS0001'
                                  );

        -- encerra paralelo
        RAISE vr_exc_saida;
      END IF;

      --Realizar o Parse do Arquivo XML
      vr_xmldoc:= xmldom.newDOMDocument(vr_XML);

      --Verificar se existe tag "Demonstrativos"
      vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'Demonstrativos');

      --Se nao encontrou nenhum nodo
      IF dbms_xmldom.getlength(vr_lista_nodo) = 0 THEN

        --Monta mensagem de critica
        vr_dscritic:= 'Dados do Demonstrativo nao encontrados.1';

        -- Gerar critica no log
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                    ' - ' || 'INSS0001' || ' --> ' || 
                                                    'ALERTA: ' || vr_dscritic ||
                                                      ' - pc_busca_demonst_sicredi - Erro. Conta: ' ||
                                                      pr_nrdconta||' Coop: '||pr_cdcooper
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_cdprograma   => 'INSS0001'
                                  );
        -- encerra paralelo
        RAISE vr_exc_saida;

      END IF;

      --Arquivo OK, percorrer as tags

      --Lista de nodos
      vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'*');

      --Quantidade tags no XML
      vr_qtlinha:= xmldom.getLength(vr_lista_nodo);

      -- limpa temp table para proximo demonstrativo
      vr_index_demonst := 0;
      vr_index_rubrica := 0;
      vr_tab_demonst.delete;
      vr_tab_rubrica.delete;

      /* Para cada um dos filhos do DadosDemonstrativo */
      FOR vr_linha IN 1..(vr_qtlinha-1) LOOP

        --Buscar Nodo Corrente
        vr_nodo:= xmldom.item(vr_lista_nodo,vr_linha);

        --Nome Parametro Nodo corrente
        vr_nmparam:= xmldom.getNodeName(vr_nodo);

        --Buscar somente sufixo (o que tem apos o caracter :)
        vr_nmparam:= SUBSTR(vr_nmparam,instr(vr_nmparam,':')+1);

        --Tratar parametros que possuem dados
        CASE vr_nmparam

          WHEN 'DadosDemonstrativo' THEN
            --Incrementar Contador
            vr_index_demonst:= vr_tab_demonst.COUNT + 1;

            --Incrementar Contador
            vr_index_rubrica:= vr_tab_rubrica.COUNT + 1;

          WHEN 'cnpjEmissor' THEN
            --Buscar o Nodo
            vr_nodo:= xmldom.getFirstChild(vr_nodo);

            --CNPJ Emissor
            vr_tab_demonst(vr_index_demonst).cnpjemis:= xmldom.getNodeValue(vr_nodo);

          WHEN 'nomeEmissor' THEN
            --Buscar o Nodo
            vr_nodo:= xmldom.getFirstChild(vr_nodo);

            --Nome Emissor
            vr_tab_demonst(vr_index_demonst).nomeemis:= xmldom.getNodeValue(vr_nodo);

          WHEN 'orgaoPagador' THEN
            --Buscar o Nodo
            vr_nodo:= xmldom.getFirstChild(vr_nodo);

            --Orgao Pagador
            vr_tab_demonst(vr_index_demonst).cdorgins:= to_number(xmldom.getNodeValue(vr_nodo));

          WHEN 'numeroBeneficio' THEN
            --Buscar o Nodo
            vr_nodo:= xmldom.getFirstChild(vr_nodo);

            --Numero beneficio
            vr_tab_demonst(vr_index_demonst).nrbenefi:= to_number(xmldom.getNodeValue(vr_nodo));
            vr_tab_rubrica(vr_index_rubrica).nrbenefi:= to_number(xmldom.getNodeValue(vr_nodo));

          WHEN 'numeroNit' THEN
            --Buscar o Nodo
            vr_nodo:= xmldom.getFirstChild(vr_nodo);

            --NIT
            vr_tab_demonst(vr_index_demonst).nrrecben:= to_number(xmldom.getNodeValue(vr_nodo));
            vr_tab_rubrica(vr_index_rubrica).nrrecben:= to_number(xmldom.getNodeValue(vr_nodo));


          WHEN 'competencia' THEN
            --Buscar o Nodo
            vr_nodo:= xmldom.getFirstChild(vr_nodo);

            --Data Competencia
            vr_tab_demonst(vr_index_demonst).dtdcompe:= SUBSTR(xmldom.getNodeValue(vr_nodo),5,2)||'/'||
                                                        SUBSTR(xmldom.getNodeValue(vr_nodo),1,4);

          WHEN 'nomeBeneficiario' THEN
            --Buscar o Nodo
            vr_nodo:= xmldom.getFirstChild(vr_nodo);

            --Nome beneficiario
            vr_tab_demonst(vr_index_demonst).nmbenefi:= xmldom.getNodeValue(vr_nodo);

          WHEN 'dataInicialPeriodo' THEN
            --Buscar o Nodo
            vr_nodo:= xmldom.getFirstChild(vr_nodo);

            IF instr(xmldom.getNodeValue(vr_nodo),'4713') = 0 THEN
              --Data Inicio Periodo
              vr_tab_demonst(vr_index_demonst).dtiniprd:= to_date(xmldom.getNodeValue(vr_nodo),'YYYY-MM-DD-HH24:MI');
            END IF;

          WHEN 'dataFinalPeriodo' THEN
            --Buscar o Nodo
            vr_nodo:= xmldom.getFirstChild(vr_nodo);

            IF instr(xmldom.getNodeValue(vr_nodo),'4713') = 0 THEN
              --Data Final Periodo
              vr_tab_demonst(vr_index_demonst).dtfinprd:= to_date(xmldom.getNodeValue(vr_nodo),'YYYY-MM-DD-HH24:MI');
            END IF;

          WHEN 'vlrBruto' THEN
            --Buscar o Nodo
            vr_nodo:= xmldom.getFirstChild(vr_nodo);

            --Valor Bruto
            vr_tab_demonst(vr_index_demonst).vlrbruto:= to_number(replace(xmldom.getNodeValue(vr_nodo),'.',','));

          WHEN 'vlrDesconto' THEN
            --Buscar o Nodo
            vr_nodo:= xmldom.getFirstChild(vr_nodo);

            --Valor Desconto
            vr_tab_demonst(vr_index_demonst).vldescto:= to_number(replace(xmldom.getNodeValue(vr_nodo),'.',','));

          WHEN 'vlrLiquido' THEN
            --Buscar o Nodo
            vr_nodo:= xmldom.getFirstChild(vr_nodo);

            --Valor Liquido
            vr_tab_demonst(vr_index_demonst).vlliquid:= to_number(replace(xmldom.getNodeValue(vr_nodo),'.',','));

          WHEN 'codRubrica' THEN
            --Buscar o Nodo
            vr_nodo:= xmldom.getFirstChild(vr_nodo);

            --Codigo Rubrica
            vr_tab_rubrica(vr_index_rubrica).cdrubric:= xmldom.getNodeValue(vr_nodo);

          WHEN 'nomeRubrica' THEN
            --Buscar o Nodo
            vr_nodo:= xmldom.getFirstChild(vr_nodo);

            --Nome Rubrica
            vr_tab_rubrica(vr_index_rubrica).nmrubric:= xmldom.getNodeValue(vr_nodo);


          WHEN 'valorRubrica' THEN
            --Buscar o Nodo
            vr_nodo:= xmldom.getFirstChild(vr_nodo);

            --Valor Rubrica
            vr_tab_rubrica(vr_index_rubrica).vlrubric:= to_number(replace(xmldom.getNodeValue(vr_nodo),'.',','));

          WHEN 'tpoNatureza' THEN
            --Buscar o Nodo
            vr_nodo:= xmldom.getFirstChild(vr_nodo);

            --Tipo Natureza
            vr_tab_rubrica(vr_index_rubrica).tpnature:= xmldom.getNodeValue(vr_nodo);

          ELSE NULL;

        END CASE;

      END LOOP; --vr_linha IN 1..(vr_qtlinha-1)

      --Se nao Encontrou nada na temp-table
      IF vr_tab_demonst.COUNT = 0 THEN

        --Monta mensagem de critica
        vr_dscritic:= 'Demonstrativo nao encontrado.2';

        -- Gerar critica no log
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                      ' - ' || 'INSS0001' || ' --> ' || 
                                                      'ALERTA: ' || vr_dscritic ||
                                                      ' - pc_busca_demonst_sicredi - Erro. Conta: ' ||
                                                      pr_nrdconta||' Coop: '||pr_cdcooper
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_cdprograma   => 'INSS0001'
                                  );
        -- encerra paralelo
        RAISE vr_exc_saida;

      END IF;

      -- busca primeiro registro quando houver demonstrativos
      vr_index_demonst := vr_tab_demonst.first;

      -- Verifica se existem demonstrativos.
      IF vr_tab_demonst.exists(vr_index_demonst) THEN
        -- varre demonstrativos encontrados para possivel insercao ou atualizacao
        WHILE vr_index_demonst IS NOT NULL LOOP
          
          -- VERIFICAR SE A LINHA LIDA REFERE-SE AO MÊS SOLICITADO
          -- SE NAO FOR, PASSA PARA O PROXIMO
          IF  to_char(vr_dtlimite, 'rrrrmm') <> to_char(vr_tab_demonst(vr_index_demonst).dtiniprd, 'rrrrmm') THEN
            vr_index_demonst := vr_tab_demonst.NEXT(vr_index_demonst);
            CONTINUE;
          END IF;

          -- busca cpf do beneficiario
          OPEN cr_crapdbi(pr_nrrecben => vr_tab_demonst(vr_index_demonst).nrbenefi);
          FETCH cr_crapdbi INTO rw_crapdbi;
          CLOSE cr_crapdbi;
          -- verifica se nro beneficio ja foi inserido no mes selecionado
          OPEN cr_tbinss_dcb(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_cdagesic => pr_cdagesic
                            ,pr_nrrecben => vr_tab_demonst(vr_index_demonst).nrbenefi);
          FETCH cr_tbinss_dcb INTO rw_tbinss_dcb;

          IF cr_tbinss_dcb%NOTFOUND THEN -- insere caso beneficio ainda nao exista no mes
            BEGIN
              -- Cria
              INSERT INTO tbinss_dcb(id_dcb
                                    ,dtcompet
                                    ,cdcooper
                                    ,nrdconta
                                    ,cdagencia_conv
                                    ,nmemissor
                                    ,nrcnpj_emissor
                                    ,nmbenefi
                                    ,nrrecben
                                    ,nrnitins
                                    ,cdorgins
                                    ,vlbruto
                                    ,vldesconto
                                    ,vlliquido
                                    ,nrcpf_benefi
                                    )
                            VALUES(
                                     fn_sequence('TBINSS_DCB','ID_DCB','ID_DCB')
                                    ,pr_dtextrat                                    
                                    ,pr_cdcooper
                                    ,pr_nrdconta
                                    ,pr_cdagesic
                                    ,vr_tab_demonst(vr_index_demonst).nomeemis
                                    ,vr_tab_demonst(vr_index_demonst).cnpjemis
                                    ,vr_tab_demonst(vr_index_demonst).nmbenefi
                                    ,vr_tab_demonst(vr_index_demonst).nrbenefi
                                    ,0
                                    ,vr_tab_demonst(vr_index_demonst).cdorgins
                                    ,vr_tab_demonst(vr_index_demonst).vlrbruto
                                    ,vr_tab_demonst(vr_index_demonst).vldescto
                                    ,vr_tab_demonst(vr_index_demonst).vlliquid
                                    ,nvl(rw_crapdbi.nrcpfcgc,0)
                                     )RETURNING id_dcb INTO rw_tbinss_dcb.id_dcb;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir na tbinss_dcb. Erro: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          ELSE -- atualiza caso o beneficio ja exista no mes
            BEGIN
              UPDATE tbinss_dcb dcb
                 SET dcb.nmemissor      = vr_tab_demonst(vr_index_demonst).nomeemis
                    ,dcb.nrcnpj_emissor = vr_tab_demonst(vr_index_demonst).cnpjemis
                    ,dcb.nmbenefi       = vr_tab_demonst(vr_index_demonst).nmbenefi
                    ,dcb.nrrecben       = vr_tab_demonst(vr_index_demonst).nrbenefi
                    ,dcb.nrnitins       = 0
                    ,dcb.cdorgins       = vr_tab_demonst(vr_index_demonst).cdorgins
                    ,dcb.vlbruto        = vr_tab_demonst(vr_index_demonst).vlrbruto
                    ,dcb.vldesconto     = vr_tab_demonst(vr_index_demonst).vldescto
                    ,dcb.vlliquido      = vr_tab_demonst(vr_index_demonst).vlliquid
                    ,dcb.nrcpf_benefi   = vr_nrcpfcgc
               WHERE dcb.id_dcb = rw_tbinss_dcb.id_dcb;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar na tbinss_dcb. Erro: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;

          --Se nao Encontrou nada na temp-table
          IF vr_tab_rubrica.COUNT = 0 THEN

            --Monta mensagem de critica
            vr_dscritic:= 'Rubrica nao encontrada.';

            -- Gerar critica no log
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                          ' - ' || 'INSS0001' || ' --> ' || 
                                                          'ALERTA: ' || vr_dscritic ||
                                                          ' - pc_busca_demonst_sicredi - Erro. Conta: ' ||
                                                          pr_nrdconta||' Coop: '||pr_cdcooper
                                      ,pr_nmarqlog     => vr_nmarqlog
                                      ,pr_cdprograma   => 'INSS0001'
                                      );

            CLOSE cr_tbinss_dcb;
            -- encerra paralelo
            RAISE vr_exc_saida;
          END IF;

          IF vr_tab_rubrica.exists(vr_index_demonst) THEN
            -- Procura se rubrica já está cadastrada
            OPEN cr_tbinss_rubrica(pr_cdrubric => vr_tab_rubrica(vr_index_demonst).cdrubric);
            FETCH cr_tbinss_rubrica INTO rw_tbinss_rubrica;

            -- Se não está cadastrada cria
            IF cr_tbinss_rubrica%NOTFOUND THEN
              BEGIN
                INSERT INTO tbinss_rubrica
                       (cdrubric
                       ,dsrubric
                       ,dsnatureza)
                 VALUES(vr_tab_rubrica(vr_index_demonst).cdrubric
                      ,vr_tab_rubrica(vr_index_demonst).nmrubric
                      ,vr_tab_rubrica(vr_index_demonst).tpnature);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir na tbinss_rubrica. Erro: '||SQLERRM;
                  CLOSE cr_tbinss_rubrica;
                  RAISE vr_exc_saida;
              END;
            END IF;
            CLOSE cr_tbinss_rubrica;

            -- Verifica se já possui algum lançamento
            OPEN cr_tbinss_landcb(pr_iddcb => rw_tbinss_dcb.id_dcb);
            FETCH cr_tbinss_landcb INTO rw_tbinss_landcb;
            CLOSE cr_tbinss_landcb;

            -- Quando a Natureza for Debito, grava na tabela o valor negativo.
            IF vr_tab_rubrica(vr_index_demonst).tpnature = 'DEBITO'THEN
               vr_tab_rubrica(vr_index_demonst).vlrubric := vr_tab_rubrica(vr_index_demonst).vlrubric * -1;
            END IF;

            -- Se encontrou lançamento incrementa sequencial
            BEGIN
              INSERT INTO tbinss_landcb
                     (id_dcb
                     ,nrseqlan
                     ,cdrubric
                     ,vlrubric)
               VALUES(rw_tbinss_dcb.id_dcb
                     ,(rw_tbinss_landcb.nrseqlan + 1)
                     ,vr_tab_rubrica(vr_index_demonst).cdrubric
                     ,vr_tab_rubrica(vr_index_demonst).vlrubric);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir na tbinss_landcb. Erro: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;
          CLOSE cr_tbinss_dcb;

          -- Buscar o proximo
          vr_index_demonst := vr_tab_demonst.NEXT(vr_index_demonst);

        END LOOP;
      END IF;
    END IF;


    IF vr_msgenvio IS NOT NULL THEN
      --Move o arquivo XML fisico de envio
      GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'mv '||vr_msgenvio||' '||vr_movarqto||' 2> /dev/null'
                            ,pr_typ_saida   => vr_des_reto
                            ,pr_des_saida   => vr_dscritic);
      --Se ocorreu erro dar RAISE
      IF vr_des_reto = 'ERR' THEN
        RAISE vr_exc_saida;
      END IF;
    END IF;

    IF vr_msgreceb IS NOT NULL THEN
      --Move o arquivo XML fisico de recebimento
      GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'mv '||vr_msgreceb||' '||vr_movarqto||' 2> /dev/null'
                            ,pr_typ_saida   => vr_des_reto
                            ,pr_des_saida   => vr_dscritic);
      --Se ocorreu erro dar RAISE
      IF vr_des_reto = 'ERR' THEN
        RAISE vr_exc_saida;
      END IF;
    END IF;
    
    -- FIM BUSCA DADOS WEBSERVICE
    COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := 0;      
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro nao tratado na procedure INSS0001.pc_busca_demonst_sicredi --> ' || SQLERRM;
  
  END pc_busca_demonst_sicredi ;



		PROCEDURE pc_carrega_dados_beneficio(pr_cdcooper IN tbinss_dcb.cdcooper%TYPE            --> Cooperativa
		                                  ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE DEFAULT 0  --> Nr. da Conta
																			,pr_nrrecben IN tbinss_dcb.nrrecben%TYPE DEFAULT 0  --> Nr. beneficiario
																			,pr_dtmescom IN VARCHAR DEFAULT ' '                 --> Mês de competência
																			,pr_tab_dcb  OUT typ_tab_dcb                        --> Pltable com dados do beneficiario
																			,pr_cdcritic OUT INTEGER                            --> Cód. da crítica
																			,pr_dscritic OUT VARCHAR2) IS                       --> Desc. da crítica
														
	  -- Indice da PLTable				
	  vr_ind_dcb INTEGER := 0;
	

    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.nmrescop
          ,crapcop.nmextcop
          ,crapcop.dsdircop
          ,crapcop.cdagesic
      FROM crapcop crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

	  -- Busca dados do beneficiario	
	  CURSOR cr_inss_dcb (pr_cdcooper IN tbinss_dcb.cdcooper%TYPE
											 ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE
											 ,pr_nrrecben IN tbinss_dcb.nrrecben%TYPE
											 ,pr_dtmescom IN VARCHAR2)IS
			SELECT dcb.nmbenefi
						,dcb.nrrecben
						,dcb.dtcompet
						,dcb.vlliquido
			 FROM tbinss_dcb dcb
			WHERE dcb.cdcooper = pr_cdcooper
			  AND (dcb.nrdconta = pr_nrdconta OR pr_nrdconta = 0)
			  AND (dcb.nrrecben = pr_nrrecben OR pr_nrrecben = 0)
				AND (trunc(dcb.dtcompet, 'MM') = trunc(to_date(pr_dtmescom, 'DD/MM/RRRR'), 'MM') OR pr_dtmescom = ' ');
	
		BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => 'INSS0001', pr_action => 'INSS0001.pc_carrega_dados_beneficio');    
      
			-- Percorre dados do beneficiario
		  FOR rw_inss_dcb IN cr_inss_dcb(pr_cdcooper => pr_cdcooper
				                            ,pr_nrdconta => pr_nrdconta
																		,pr_nrrecben => pr_nrrecben
																		,pr_dtmescom => pr_dtmescom) LOOP
		
		    -- Atribui indice para a PLTable
		    vr_ind_dcb := pr_tab_dcb.count();
				-- Alimenta PLTable com os dados do beneficario
        pr_tab_dcb(vr_ind_dcb).nmbenefi       :=  rw_inss_dcb.nmbenefi;
        pr_tab_dcb(vr_ind_dcb).dtcompet       :=  rw_inss_dcb.dtcompet;
        pr_tab_dcb(vr_ind_dcb).nrrecben       :=  rw_inss_dcb.nrrecben;
        pr_tab_dcb(vr_ind_dcb).vlliquido      :=  rw_inss_dcb.vlliquido;
      END LOOP;


      -- Se nao tem dados na base CECRED, buscar do SICREDI ON-LINE (WEBSERVICE)
      IF pr_tab_dcb.count = 0 THEN
      
        -- Buscar CDAGESIC da COOP
        -- Verifica se a cooperativa esta cadastrada
        OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;

        -- Se não encontrar
        IF cr_crapcop%NOTFOUND THEN
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapcop;
          -- Montar mensagem de critica
          pr_cdcritic:= 0;
          pr_dscritic:= 'Problemas no cadastro da Cooperativa!';

        ELSE -- FOUND/Encontrou
          -- Fechar o cursor
          CLOSE cr_crapcop;

          -- Solicitar informacoes SICREDI via Webservice
          pc_busca_demonst_sicredi(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_cdagesic => rw_crapcop.cdagesic
                                  ,pr_dtextrat => to_date(pr_dtmescom, 'DD/MM/RRRR')
                                  ,pr_cdcritic => pr_cdcritic
                                  ,pr_dscritic => pr_dscritic);


          -- Buscar dados recém incluídos no processo acima
          FOR rw_inss_dcb IN cr_inss_dcb(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrrecben => pr_nrrecben
                                        ,pr_dtmescom => pr_dtmescom) LOOP

            -- Atribui indice para a PLTable
            vr_ind_dcb := pr_tab_dcb.count();
            -- Alimenta PLTable com os dados do beneficario
            pr_tab_dcb(vr_ind_dcb).nmbenefi       :=  rw_inss_dcb.nmbenefi;
            pr_tab_dcb(vr_ind_dcb).dtcompet       :=  rw_inss_dcb.dtcompet;
            pr_tab_dcb(vr_ind_dcb).nrrecben       :=  rw_inss_dcb.nrrecben;
            pr_tab_dcb(vr_ind_dcb).vlliquido      :=  rw_inss_dcb.vlliquido;
		  END LOOP;


        END IF; -- FIM IF NOTFOUND
      END IF;  -- FIM pr_tab_dcb.count
      

		EXCEPTION
			WHEN OTHERS THEN
				pr_cdcritic := 0;
				pr_dscritic := 'Erro nao tratado na procedure INSS0001.pc_carrega_dados_beneficio --> ' || SQLERRM;
  END pc_carrega_dados_beneficio;
	  

	PROCEDURE pc_carrega_dados_beneficio_car (pr_cdcooper IN tbinss_dcb.cdcooper%TYPE            --> Cooperativa
																					 ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE DEFAULT 0  --> Nr. da Conta
																					 ,pr_nrrecben IN tbinss_dcb.nrrecben%TYPE DEFAULT 0  --> Nr. beneficiario
																			     ,pr_dtmescom IN VARCHAR DEFAULT ' '                 --> Mês de competência																					 
																					 ,pr_clobxmlc OUT CLOB                               --> Clob com dados do beneficiario
																					 ,pr_cdcritic OUT INTEGER                            --> Cód. da crítica
																					 ,pr_dscritic OUT VARCHAR2) IS                       --> Desc. da crítica
																					 
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);

		-- Tratamento de erros
		vr_exc_saida EXCEPTION;

		-- Temp Table
		vr_tab_dcb typ_tab_dcb;

		-- Variaveis de XML
		vr_xml_temp VARCHAR2(32767);
																					 
    BEGIN			
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => 'INSS0001', pr_action => 'INSS0001.pc_carrega_dados_beneficio_car');
      
			-- Busca dados do beneficiario
			pc_carrega_dados_beneficio(pr_cdcooper => pr_cdcooper
			                          ,pr_nrdconta => pr_nrdconta
																,pr_nrrecben => pr_nrrecben
																,pr_dtmescom => pr_dtmescom
																,pr_tab_dcb => vr_tab_dcb
																,pr_cdcritic => vr_cdcritic
																,pr_dscritic => vr_dscritic);
																
		  IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				vr_dscritic := vr_dscritic || pr_dtmescom;
				RAISE vr_exc_saida;
			END IF;
			
			-- Criar documento XML
      dbms_lob.createtemporary(pr_clobxmlc, TRUE);
      dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);

      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<raiz>');
			IF vr_tab_dcb.count() > 0 THEN
				-- Percorre todas as aplicações de captação da conta
				FOR vr_ind_dcb IN vr_tab_dcb.FIRST..vr_tab_dcb.LAST LOOP
					-- Montar XML com registros de aplicação
					gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
																 ,pr_texto_completo => vr_xml_temp
																 ,pr_texto_novo     => '<beneficiario>'
																										||  '<nmbenefi>' || NVL(vr_tab_dcb(vr_ind_dcb).nmbenefi, ' ') || '</nmbenefi>'
																										||  '<dtcompet>' || NVL(to_char(vr_tab_dcb(vr_ind_dcb).dtcompet, 'MM/RRRR'), ' ') || '</dtcompet>'
																										||  '<nrrecben>' || NVL(vr_tab_dcb(vr_ind_dcb).nrrecben, 0) || '</nrrecben>'
																										||  '<vlliquido>' || NVL(vr_tab_dcb(vr_ind_dcb).vlliquido, 0) || '</vlliquido>'
																										|| '</beneficiario>');

				END LOOP;
			END IF;
			-- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);
			
		-- Trata exceções
		EXCEPTION
			WHEN vr_exc_saida THEN
				-- Alimenta críticas parametrizadas
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
			WHEN OTHERS THEN
			  -- Alimenta críticas parametrizadas
				pr_cdcritic := 0;
				pr_dscritic := 'Erro nao tratado na procedure INSS0001.pc_carrega_dados_beneficio_car --> ' || SQLERRM;
						
	END pc_carrega_dados_beneficio_car;
	
	PROCEDURE pc_carrega_demonst_benef(pr_cdcooper IN tbinss_dcb.cdcooper%TYPE            --> Cooperativa
		                                ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE DEFAULT 0  --> Nr. da Conta
																		,pr_nrrecben IN tbinss_dcb.nrrecben%TYPE DEFAULT 0  --> Nr. beneficiario
																		,pr_dtmescom IN VARCHAR2 DEFAULT ' '                --> Mês de competência
                                    ,pr_clobxmlc OUT CLOB                               --> Clob com dados do beneficiario
																		,pr_cdcritic OUT INTEGER                            --> Cód. da crítica
																		,pr_dscritic OUT VARCHAR2) IS                       --> Desc. da crítica
														

		-- Variaveis de XML
		vr_xml_temp VARCHAR2(32767);
	
	  -- Busca dados do beneficiario	
		CURSOR cr_inss_dcb (pr_cdcooper IN tbinss_dcb.cdcooper%TYPE
											 ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE
											 ,pr_nrrecben IN tbinss_dcb.nrrecben%TYPE
											 ,pr_dtmescom IN VARCHAR2)IS
      SELECT dcb.nmemissor
            ,dcb.nrcnpj_emissor
            ,dcb.nmbenefi
            ,dcb.dtcompet
            ,dcb.nrrecben
            ,dcb.nrnitins
            ,dcb.cdorgins
            ,dcb.vlliquido
						,dcb.id_dcb
            ,cop.nmrescop
       FROM tbinss_dcb dcb,
            crapcop cop
      WHERE dcb.cdcooper = pr_cdcooper
			  AND (dcb.nrdconta = pr_nrdconta OR pr_nrdconta = 0)
			  AND (dcb.nrrecben = pr_nrrecben OR pr_nrrecben = 0)
				AND (trunc(dcb.dtcompet, 'MM') = trunc(to_date(pr_dtmescom, 'DD/MM/RRRR'), 'MM') OR pr_dtmescom = ' ')
        AND cop.cdcooper = dcb.cdcooper;
				
	  -- Lançamentos beneficiario
		CURSOR cr_inss_ldcb (pr_id_dcb IN tbinss_dcb.id_dcb%TYPE)IS
		  SELECT rbc.cdrubric
            ,rbc.dsrubric
            ,ldcb.vlrubric
            ,rbc.dsnatureza
			  FROM tbinss_landcb ldcb,
				     tbinss_rubrica rbc				
			 WHERE ldcb.id_dcb = pr_id_dcb
         AND rbc.cdrubric = ldcb.cdrubric;

	
		BEGIN
  	  -- Incluir nome do módulo logado - Chamado 664301
		  GENE0001.pc_set_modulo(pr_module => 'INSS0001', pr_action => 'INSS0001.pc_carrega_demonst_benef');      
		  
			-- Criar documento XML
      dbms_lob.createtemporary(pr_clobxmlc, TRUE);
      dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);

      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<raiz>');
			
			-- Percorre dados do beneficiario
		  FOR rw_inss_dcb IN cr_inss_dcb(pr_cdcooper => pr_cdcooper
				                            ,pr_nrdconta => pr_nrdconta
																		,pr_nrrecben => pr_nrrecben
																		,pr_dtmescom => pr_dtmescom) LOOP
																		
				gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
															 ,pr_texto_completo => vr_xml_temp
															 ,pr_texto_novo     => '<beneficiario>'
																									||  '<nmemissor>' || NVL(rw_inss_dcb.nmemissor, ' ') || '</nmemissor>'
																									||  '<nrcnpj_emissor>' || NVL(rw_inss_dcb.nrcnpj_emissor, 0) || '</nrcnpj_emissor>'
																									||  '<nmbenefi>' || NVL(rw_inss_dcb.nmbenefi, ' ') || '</nmbenefi>'
																									||  '<dtcompet>' || NVL(to_char(rw_inss_dcb.dtcompet, 'MM/RRRR'), ' ') || '</dtcompet>'
																									||  '<nrrecben>' || NVL(rw_inss_dcb.nrrecben, 0) || '</nrrecben>'
																									||  '<nrnitins>' || NVL(rw_inss_dcb.nrnitins, 0) || '</nrnitins>'
																									||  '<cdorgins>' || NVL(rw_inss_dcb.cdorgins, 0) || '</cdorgins>'																										
																									||  '<vlliquido>' || NVL(rw_inss_dcb.vlliquido, 0) || '</vlliquido>' 
																									||  '<nmrescop>' || NVL(rw_inss_dcb.nmrescop, ' ') || '</nmrescop>'																										
																									|| '</beneficiario>'
																									|| '<lancamentos>');
                            
																																																				
				FOR rw_inss_ldcb IN cr_inss_ldcb (pr_id_dcb => rw_inss_dcb.id_dcb) LOOP
						gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
											 ,pr_texto_completo => vr_xml_temp
											 ,pr_texto_novo     => '<lancamento>'
																					||  '<cdrubric>' || NVL(rw_inss_ldcb.cdrubric, 0) || '</cdrubric>'
																					||  '<dsrubric>' || NVL(rw_inss_ldcb.dsrubric, ' ') || '</dsrubric>'																						
																					||  '<vlrubric>' || NVL(rw_inss_ldcb.vlrubric, 0) || '</vlrubric>'
																					||  '<dsnatureza>' || NVL(rw_inss_ldcb.dsnatureza, ' ') || '</dsnatureza>'
																					|| '</lancamento>');
				END LOOP;
					
				-- Encerrar a tag raiz
				gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
															 ,pr_texto_completo => vr_xml_temp
															 ,pr_texto_novo     => '</lancamentos>');
					
		  END LOOP;
			
			-- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);

			
		EXCEPTION
			WHEN OTHERS THEN
				pr_cdcritic := 0;
				pr_dscritic := 'Erro nao tratado na procedure INSS0001.pc_carrega_demonst_benef --> ' || SQLERRM;
  END pc_carrega_demonst_benef;
	
END INSS0001;
/
