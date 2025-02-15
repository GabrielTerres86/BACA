CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS652_FABRICIO(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                             -- Parametros paralelistmo
                                             ,pr_cdcoppar IN NUMBER                  --> Cooperativa (QUando execu��o paralela)
                                             ,pr_cdagepar IN NUMBER                  --> Agencia (Quando execucao paralela)
                                             ,pr_idparale IN crappar.idparale%TYPE   --> Indicador de processoparalelo
                                             ,pr_cdprogra IN VARCHAR2                --> Rotina acionadora
                                             ,pr_qtdejobs IN NUMBER                  --> Programa chamador
                                             -- Retornos para processo Batch
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da Critica
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica
  BEGIN

  /* .............................................................................
  
   Programa: PC_CRPS652                      Antigo: Fontes/CRPS652.p
   Sistema : CYBER - GERACAO DE ARQUIVO
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : AGOSTO/2013                      Ultima atualizacao: 23/01/2019

   Dados referentes ao programa:

   Frequencia: Diaria.
   Objetivo  : Gerar diariamente para o sistema CYBER os layouts de entrada
               (Carga, Carga Manutencao Cadastral, Carga Manutencao Financeira,
               Carga Relations, Carga Garantias, Carga Pagamentos, Carga
               Baixas) e controlar as baixas e pagamentos para os contratos
               que estao na cobran�a do sistema CYBER.

   Alteracoes: 26/09/2013 - Ajuste para gerar pagamento e baixa para os
                            registros que nao fizeram atualizacao financeira
                            no crps280.i "Foram liquidados". (James)

               09/10/2013 - Ajuste para atualizar o campo crapcyb.cdagenci de
                            acordo com a agencia do cooperado (James).

               28/10/2013 - Ajuste para atualizar o Saldo Devedor e Valor a
                            Regularizar para a origem conta, quando for
                            baixado (James).

               04/11/2013 - Ajuste para enviar o endereco do "Interveniente
                            Garantidor" quando for conta (James).

               13/11/2013 - Ajuste para buscar o tipo do documento e numero
                            do documento quando nao possuir na tabela crapass.
                            (James).

               20/11/2013 - Ajuste no tipo de garantia (Oscar).

               21/11/2013 - Ajuste no envio do valor do pagamento. (James)

               12/12/2013 - Ajuste para enviar primeiro o Nome do Pai e depois
                            o Nome da Mae no layout "_rel_in.txt". (James)

               16/01/2013 - Conversao Progress -> Oracle (Alisson - Amcom)

               21/01/2014 - Ajuste para atualizar agencia. (James)

               24/01/2014 - Ajuste para atualizar o Valor a Regularizar quando
                            for baixado. (James)

               13/02/2014 - Comentado o DELETE da tabela crapcyb. (James).

               07/03/2014 - Ajuste para liberar o CYBER para mais 7
                            cooperativas (James).

               11/03/2014 - Ajuste no envio da carga de garantia, para somente
                            enviar os bens, caso possui alguma informacao
                            cadastrada. (James)

               01/04/2014 - Ajuste para liberar o CYBER para todas as
                            cooperativas. (James)

               26/05/2014 - Ajuste no envio dos dados da data de compra e data de vencimento
                            quando o contrato for de prejuizo. (James)

               10/06/2014 - Troca do nome e data nascimento do conjuge para ser
                            usado na tabela cracje e nao mais na crapass
                            (Chamado 117414) - (Tiago Castro - RKAM).

               16/06/2014 - Ajuste no campo cdestcvl e dsestcvl, foram removidos da
                            crapass e adicionados na crapttl. (Douglas - Chamado 131253)

               25/06/2014 - Ajustar os cursores que realizam a busca das informa��es do
                            estado civil. (Douglas - Chamado 131253)

               25/07/2014 - Incluso ajustes gera��o arquivo Cyber (Daniel)

               03/10/2014 - Altera��o do fone comercial (tptelefo: 3)
                            para celular (tptelefo: 2) na procedure "pc_gera_aval"
                            na chamada do cursor "cr_craptfc". (Jaison)

               23/10/2014 - Altera��o no cursor "cr_crapcop" para filtrar somente
                            as cooperativas ativas campo "flgativo". (Jaison)

               01/12/2014 - Ajuste para gerar as baixas para a Concredi e Credimilsul
                            quando o contrato for prejuizo. (James)

               02/12/2014 - Altera��o no cursor "cr_crapcop" para filtrar somente
                            as cooperativas ativas campo "flgativo". (James)

               12/12/2014 - Ajustado para nao enviar nos arquivos acentuacao. (James)

               13/04/2015 - Ajuste na data do ultimo vencimento nao pago (Andrino-RKAM)
                            Chamado 235518.

               27/07/2015 - Nos avalistas que tenham o tpctrato = 1 ou 9, deve enviar o
                            campo dsendres##2 ao inv�s de enviar o nmbairro. Foi cortado o
                            campo dsendres##2 em 40 posi��es, para respeitar o tamanho m�ximo
                            do nmbairro. Chamado 307644 (Heitor - RKAM)

               17/08/2015 - Complementar envio de dados cadastrais e financeiros ao sistema Cyber,
                            adicionando cursores novos e ajustando os existes, al�m de adicionar os
                            campos aos arquivos correspondentes na procedures pr_gera_carga_MC e
                            adicionar procedure complementar para pc_gera_carga_MF (Douglas - Melhoria 13)

               27/08/2015 - Refeito a busca da data do ultimo vencimento nao pago para
                            melhorar a performance (Andrino - RKAM)

               11/09/2015 - Inclusao dos nomes dos parametros na chamada da
                            pc_clob_para_arquivo. (Jaison/Marcos-Supero)

               11/09/2015 - Adicionar os campos de assessoria e motivo CIN para gera��o da carga
                            de manuten��o cadastral, al�m dos ajustes no envio dos pagamentos detalhados
                            por hist�rico (Douglas - Melhoria 12)

               08/10/2015 - Adicionado condicao AND rw_crapcyb.flgpreju = 0) em if de efetuar
                            Baixa. (Jorge/Gielow) - SD 326766

               19/10/2015 - Ajuste emergencial para condicao de atribuicao da variavel vr_dtdpagto.
                            (Jorge/Gielow)

               27/10/2015 - Alterar o pr_flcomple de FALSE para 0 na chamada da procedure
                            CADA0001.pc_busca_idade (Lucas Ranghetti $340156)

               12/11/2015 - Aumentado o espa�o destinado � linha de cr�dito nos arquivos de carga
                            Completa e Financeira. O c�digo ocupar� uma posi��o extra (de 3 para 4),
                            enquanto o campo seguinte (Descri��o Linha Cr�dito) ocupar� uma posi��o
                            a menos (De 30 para 29). Foi adotada essa solu��o para que n�o seja
                            necess�rio altera��o em todo o layout dos arquivos.
                            Melhoria 19 (Heitor - RKAM)

               12/11/2015 - Para os contratos Pr�-Fixados (tpemprst = 1), deve enviar ao Cyber
                            o valor de multa e juros de mora juntamente com o valor da parcela.
                            Melhoria 155 (Heitor - RKAM)

               15/01/2016 - Alteracoes para o Prj. 131 - Assinatura conjunta (Jean Michel)

               01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
                            Transferencia entre PAs (Heitor - RKAM)

               23/02/2016 - Chamado 374738 - Alteracao na busca das informacoes de pagamentos em
                            conta corrente. Estava buscando indevidamente da tabela craplem, quando
                            o correto deveria ser craplcm (Heitor - RKAM)

               18/03/2016 - Chamado 374738 - Alteracao na busca das informacoes de pagamentos de
                            multa e juros de mora em emprestimos. Estava buscando indevidamente da
                            tabela craplem, quando o correto deveria ser craplcm (Heitor - RKAM)

                            
               26/07/2016 - Corre��o n�o estava trazendo o nome da acessoria de cobran�a
                            na manuten��o cadastral. (Oscar)
               27/09/2016 - Correcao na chamada da gene0007 para remocao de caracteres especiais.
			                Nao deve remover o @ devido ao campo de email.
							Heitor (RKAM) - Chamado 521909

               20/09/2016 - Inclusao do arquivo de acordo de pagamentos,
                            Prj. 302 (Jean Michel)  

               10/10/2016 - 449436 - Altera��es Envio Cyber - Alterado para acrescetar a mora e juros ao valor devedor
                            do cyber. (Gil - Mouts)

               06/12/2016 - Incorpora��o altera��o no cursor "cr_crapcop" para retirar o filtro
                            das cooperativas ativas campo "flgativo". (Oscar)

			   
			   30/11/2016 - Ajuste na busca de multa e juros de mora para so trazer o valor caso a origem seja 2 ou 3.
			                Antes, poderia causar problema se um numero de contrato tiver a mesma numeracao da conta.
							Gil (Mouts)
              
               05/01/2017 - Ajuste para for�a o uso do indice 2 da tabela craplcm problemas
                           de performance  Oracle usa o indice 1. (Oscar)
                           
               06/01/2017 - Ajuste no hint da craplcm, retirar espa�o entre o index. 
                Voltar a flgativo nos cursor da cooperativas.(Oscar)            
                           
               06/03/2017 - Ajuste no hint cr_valor_pago_emprestimo mover para baixo
               do primeiro union. (Oscar)
                           
         16/01/2017 - Prj 432 - Melhorias envio Cyber - Altera��es diversas referente projeto 432. (Jean - Mout�S)   

               04/04/2017 - Alterado a forma de como o programa acumula as datas iniciais
                            para que ele possa ser chamado por JOB fora do processo
                            noturno (Tiago/Rodrigo SD588601).

			   26/04/2017 - Prj 432 - Melhorias envio Cyber - adequa��o da gera��o do arquivo de baixas / pagamentos,
			                                                  n�o est� atualizando corretamente se o contrato for VIP (Jean/Mout�S)
               28/04/2017 - Ajuste nas regras para enviar as baixas dos contratos. (James)             

               28/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 


		 02/05/2017 - Prj 432 - retirar regra de n�o enviar baixa se contrato VIP, est� gerando conflitos no Cyber 
		                        e esta regra ser� revista na melhoria 302. (Jean / Mout�s)

               16/05/2017 - Inclus�o de identifica��o das origens de pagamento "Boletagem Massiva", "Pagto. por avalista", 
                            "Pagto. Boleto Preju�zo", "Descto. Boleto Preju�zo" e "Pagto. de Boleto".
                            Inclus�o de verifica��o dos historicos 2277, 2278 e 2279. Prj. 210.2 (Lombardi)

               09/08/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)

               17/09/2017 - Ajuste para efetuar a regulariza��o do contrato quando o mesmo for liquidado
                            (Jonata - SD 742850). 
                            
               14/11/2017 - Log de trace da exception others (Carlos)
               
               23/11/2017 - Alterado processo de envio das Garantias ao Cyber para sinalizar quando a opera��o possui
                            cobertura da opera��o vinculada a opera��o de cr�dito. Projeto 404 (Lombardi)

               09/01/2018 - #826598 Concatena��o da cr�tica no par�metro de retorno do crps (Carlos)
			   
			   01/02/2018 - Nao enviar lancamentos efetuados na tabela CRAPLCM, somente devem ser enviados lancamentos
                            feitos na CRAPLEM e parametrizados na tela PARCYB.
							Zerar o saldo devedor de registros que tenha sido efetuado acordo.
                            Heitor (Mouts) - Chamado 798744

               27/02/2018 - Enviar registros da LCM somente para TR, alguns historicos especificos e que conseguimos filtrar
                            o contrato pelo campo CDPESQBB.
                            Ajustes no envio de pagamentos de conta corrente.
                            Heitor (Mouts)

			   26/04/2018 - Enviar registro da LCM do historico 2386 - Recuperacao de prejuizo, pois na tabela CRAPLEM ele se divide
                            entre alguns historicos que nao devem ser enviados.
							Heitor (Mouts) - Prj 324.

               05/06/2018 - Inclus�o de Descont de Titulos (Border� de Titulos) (Andrew Albuquerque(GFT))

               17/06/2018 - Revis�o de campos para envio de T�tulos para a Cyber (Andrew Albuquerque - GFT)

               26/06/2018 - Alterado a tabela CRAPGRP para TBCC_GRUPO_ECONOMICO. (Mario Bernat - AMcom)
                 
							 13/09/2018 - Ajuste para identifica��o do pagamento com hist�rico 2386 (Recupera��o de 
							              preju�zo - empr�stimo em preju�zo) a partir do extrato do preju�zo (TBCC_PREJUIZO_DETALHE)
														(Reginaldo - AMcom - P450)
							            

               23/07/2018 - Projeto Revitaliza�ao Sistemas - Execucao paralela por Coop e Agencia (Andreatta - MOUTs)

               19/10/2018 - P442 - Troca de checagem fixa por func�o para garantir se bem � alien�vel (Marcos-Envolti)
                                
               23/01/2019 - Somar ao valor do saldo prejuizo (vlsdprej) o valor a ser pago de mora, multa
                            e IOF para ser enviado no arquivo de carga_mf ao Cyber - INC0030650. (Fabricio)
                                
     ............................................................................. */

     DECLARE

     /* Tipos de Registro para Tabelas de Memoria */
     TYPE typ_reg_crapctt IS RECORD
       (nrdctato crapavt.nrdctato%type
       ,nmdavali crapavt.nmdavali%type
       ,nrtelefo crapavt.nrtelefo%type
       ,dsdemail crapavt.dsdemail%type
       ,dsdemiss BOOLEAN
       ,cdagenci crapavt.cdagenci%type
       ,nrcepend crapavt.nrcepend%type
       ,dsendere crapavt.dsendres##1%type
       ,nrendere crapavt.nrendere%type
       ,complend crapavt.complend%type
       ,nmbairro crapavt.nmbairro%type
       ,nmcidade crapavt.nmcidade%type
       ,cdufende VARCHAR2(2)
       ,nrcxapst crapavt.nrcxapst%type
       ,cddctato VARCHAR2(100)
       ,nrdrowid ROWID);

     TYPE typ_reg_crapass IS RECORD
       -- Campos da crapass
       (nrdconta crapass.nrdconta%TYPE   -- Conta/DV
       ,inpessoa crapass.inpessoa%TYPE   -- Tipo Pessoa
       ,dtnasctl crapass.dtnasctl%TYPE   -- Data Nascimento
       ,nmprimtl crapass.nmprimtl%TYPE   -- Nome Primeiro Titular
       ,tpdocptl crapass.tpdocptl%TYPE   -- Tipo Documento Primeiro Titular
       ,nrdocptl crapass.nrdocptl%TYPE   -- N�mero Documento Primeiro Titular
       ,dtemdptl crapass.dtemdptl%TYPE   -- Data de emissao do documento do titular.
       ,cdsexotl crapass.cdsexotl%TYPE   -- Sexo
       ,cdsitdct crapass.cdsitdct%TYPE   -- Situa��o da Conta
       ,nrcpfcgc crapass.nrcpfcgc%TYPE   -- CPF
       ,dtadmiss crapass.dtadmiss%TYPE   -- Data de Admiss�o
       ,dtdemiss crapass.dtdemiss%TYPE   -- Data de Demiss�o
       ,inlbacen crapass.inlbacen%TYPE   -- CCF
       ,inrisctl crapass.inrisctl%TYPE   -- Risco do Cooperado
       ,idastcjt crapass.idastcjt%TYPE   -- Indicador de Ass. Conjunta
       -- Informa��es do estado civil
       ,cdestcvl gnetcvl.cdestcvl%TYPE   -- Codigo Estado Civil
       ,dsestcvl gnetcvl.dsestcvl%TYPE   -- Descricao Estado Civil
       ,rsestcvl gnetcvl.rsestcvl%TYPE   -- Descricao Resumida Estado Civil
       -- Informa��es do conjugue
       ,nmconjug crapcje.nmconjug%TYPE   -- Nome Conjugue
       ,dtnasccj crapcje.dtnasccj%TYPE); -- Data Nascimento Conjugue

     TYPE typ_reg_boleto IS RECORD
       -- Campos da crapass
       (idarquivo tbrecup_cobranca.idarquivo%TYPE   -- Id do arquivo
       ,nrcpfava  tbrecup_cobranca.nrcpfava%TYPE    -- CPF Avalista
       ,tpparcela tbrecup_cobranca.tpparcela%TYPE); -- Tipo de parcela

     /* Tipos de Dados para vetores e tabelas de memoria */
     TYPE typ_tab_crapass  IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;
     TYPE typ_tab_crapctt  IS TABLE OF typ_reg_crapctt INDEX BY PLS_INTEGER;
     TYPE typ_tab_boleto   IS TABLE OF typ_reg_boleto  INDEX BY VARCHAR2(30);
     TYPE typ_tab_crapjur  IS TABLE OF crapjur%ROWTYPE INDEX BY PLS_INTEGER;
     TYPE typ_tab_categ    IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
     TYPE typ_tab_idatribu IS VARRAY(10) OF PLS_INTEGER;
     TYPE typ_tab_contlinh IS VARRAY(8) OF PLS_INTEGER;
     TYPE typ_tab_telcoop  IS VARRAY(5) OF VARCHAR2(1000);
     TYPE typ_tab_nmclob   IS VARRAY(8) OF VARCHAR2(100);
     TYPE typ_tab_linha    IS VARRAY(8) OF VARCHAR2(5000);
     TYPE typ_tab_acordo   IS TABLE OF NUMBER(10) INDEX BY VARCHAR2(40);

     /* Vetores de Memoria */
     vr_tab_idatribu typ_tab_idatribu:= typ_tab_idatribu(0,0,0,0,0,0,0,0,0,0);
     vr_tab_contlinh typ_tab_contlinh:= typ_tab_contlinh(0,0,0,0,0,0,0,0);
     vr_tab_telcoop  typ_tab_telcoop:= typ_tab_telcoop(NULL,NULL,NULL,NULL,NULL);
     vr_tab_nmclob   typ_tab_nmclob:= typ_tab_nmclob(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
     vr_tab_linha    typ_tab_linha:= typ_tab_linha (NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
     vr_tab_crapctt  typ_tab_crapctt;
     vr_tab_boleto   typ_tab_boleto;
     vr_tab_crapass  typ_tab_crapass;
     vr_tab_crapjur  typ_tab_crapjur;
     vr_tab_categ    typ_tab_categ;
     vr_tab_acordo   typ_tab_acordo;

     /* Cursores da rotina CRPS652 */
     
     -- Selecionar os dados da Cooperativa Global
     CURSOR cr_crapcop1 (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
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
     rw_crapcop1 cr_crapcop1%ROWTYPE;

     -- Selecionar todas Cooperativas para o processamento
     CURSOR cr_crapcop (pr_cdcoppar crapcop.cdcooper%TYPE              DEFAULT 0
                       ,pr_cdprogra tbgen_batch_controle.cdprogra%TYPE DEFAULT 0 
                       ,pr_qterro   number                             DEFAULT 0
                       ,pr_dtmvtolt tbgen_batch_controle.dtmvtolt%TYPE DEFAULT NULL) IS
       SELECT cop.cdcooper
             ,cop.nmrescop
             ,cop.nrtelura
             ,cop.cdbcoctl
             ,cop.cdagectl
             ,cop.dsdircop
             ,cop.nrctactl
             ,cop.cdagedbb
             ,cop.cdageitg
             ,cop.nrdocnpj
        FROM crapcop cop
       WHERE cop.cdcooper <> 3
         AND cop.cdcooper = decode(pr_cdcoppar,0,cop.cdcooper,pr_cdcoppar)
         AND cop.flgativo = 1
         AND (pr_qterro = 0 or
              (pr_qterro > 0 and exists (select 1
                                           from tbgen_batch_controle
                                          where tbgen_batch_controle.cdcooper    = pr_cdcooper -- Controle � gravado com a Coop Central
                                            and tbgen_batch_controle.cdprogra    = pr_cdprogra
                                            and tbgen_batch_controle.tpagrupador = 3
                                            -- Somente possibilidades de agencia desta Coop
                                            AND tbgen_batch_controle.cdagrupador BETWEEN (lpad(cop.cdcooper,3,'0')||'00000') AND (lpad(cop.cdcooper,3,'0')||'99999')
                                            and tbgen_batch_controle.insituacao  = 1
                                            and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)))
       ORDER BY cop.cdcooper;
     
     -- Busca listagem das agencias da cooperativa
     CURSOR cr_crapage(pr_cdcoppar crapcop.cdcooper%TYPE              DEFAULT 0
                      ,pr_cdagepar crapage.cdagenci%TYPE              DEFAULT 0 
                      ,pr_cdprogra tbgen_batch_controle.cdprogra%TYPE DEFAULT 0 
                      ,pr_qterro   number                             DEFAULT 0
                      ,pr_dtmvtolt tbgen_batch_controle.dtmvtolt%TYPE DEFAULT NULL) IS
      SELECT age.cdagenci
        FROM crapage age
       WHERE age.cdcooper = pr_cdcoppar
         AND age.cdagenci = decode(pr_cdagepar,0,age.cdagenci,pr_cdagepar)
         AND (pr_qterro = 0 or
             (pr_qterro > 0 and exists (select 1
                                          from tbgen_batch_controle
                                         where tbgen_batch_controle.cdcooper    = pr_cdcooper -- Controle � gravado com a Coop Central
                                           and tbgen_batch_controle.cdprogra    = pr_cdprogra
                                           and tbgen_batch_controle.tpagrupador = 3
                                           AND tbgen_batch_controle.cdagrupador = (lpad(age.cdcooper,3,'0')||lpad(age.cdagenci,5,'0'))
                                           and tbgen_batch_controle.insituacao  = 1
                                           and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)));
     
     --Selecionar associados
     CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%type
                       ,pr_cdagenci in crapage.cdagenci%type default 0
                       ,pr_nrdconta in crapass.nrdconta%type default 0) IS
       SELECT crapass.dtemdptl
             ,crapass.dtnasctl
             ,crapass.nmprimtl
             ,crapass.tpdocptl
             ,crapass.nrdocptl
             ,crapass.cdsexotl
             ,crapass.cdsitdct
             ,crapass.inpessoa
             ,crapass.nrdconta
             ,crapass.nrcpfcgc
             ,crapass.dtadmiss
             ,crapass.dtdemiss
             ,crapass.inlbacen
             ,crapass.inrisctl
             ,crapass.idastcjt
       FROM crapass crapass
       WHERE crapass.cdcooper = pr_cdcooper
         and crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
         and crapass.nrdconta = decode(pr_nrdconta,0,crapass.nrdconta,pr_nrdconta);
     rw_crapass cr_crapass%ROWTYPE;

     CURSOR cr_gnetcvl (pr_cdcooper IN crapass.cdcooper%type
                       ,pr_nrdconta IN crapass.nrdconta%type) IS
       SELECT gnetcvl.cdestcvl
             ,gnetcvl.rsestcvl
       FROM crapttl, gnetcvl
       WHERE crapttl.cdcooper = pr_cdcooper
       AND   crapttl.nrdconta = pr_nrdconta
       AND   crapttl.idseqttl = 1 -- Primeiro Titular
       AND   gnetcvl.cdestcvl = crapttl.cdestcvl;
     rw_gnetcvl cr_gnetcvl%ROWTYPE;

     --Selecionar dados do conjuge
     CURSOR cr_crapcje1 (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapcje.nrdconta%TYPE) IS
       SELECT crapcje.nmconjug
             ,crapcje.dtnasccj
       FROM  crapcje
       WHERE crapcje.cdcooper = pr_cdcooper
       AND   crapcje.nrdconta = pr_nrdconta
       AND   crapcje.idseqttl = 1;
     rw_crapcje1 cr_crapcje1%ROWTYPE;

     --Selecionar dados pessoa Juridica
     CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%type
                       ,pr_cdagenci in crapage.cdagenci%type) IS
       SELECT crapjur.nrdconta
             ,crapjur.nrinsest
             ,crapjur.dsendweb
             ,crapjur.cdrmativ
       FROM crapjur
           ,crapass
       WHERE crapjur.cdcooper = crapass.cdcooper
         and crapjur.nrdconta = crapass.nrdconta
         and crapjur.cdcooper = pr_cdcooper
         and crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);
     rw_crapjur cr_crapjur%ROWTYPE;

     --Selecionar Dados Cyber
     CURSOR cr_crapcyb (pr_cdcooper IN crapcop.cdcooper%type
                       ,pr_cdagenci in crapass.cdagenci%type) IS
       WITH t_soma_crappep as (
          select x.cdcooper
                ,x.nrdconta
                ,x.nrctremp
                ,sum(x.vlmrapar) as vlmrapar -- juros por atraso de pagamento
                ,sum(x.vlmtapar) as vlmtapar -- multa por atraso de pagamento
                ,sum(x.vliofcpl) as vliofcpl -- Valor do IOF Complementar de atraso
            from crappep x
           inner join crapcyb
              on x.cdcooper = crapcyb.cdcooper
             and x.nrdconta = crapcyb.nrdconta
             and x.nrctremp = crapcyb.nrctremp
           where ((crapcyb.cdorigem = 1
					   AND crapcyb.cdlcremp = 0) 
						  OR crapcyb.cdorigem IN (2,3))
             and x.inliquid = 0
             and x.cdcooper = pr_cdcooper
           group by x.cdcooper
                   ,x.nrdconta
                   ,x.nrctremp
       ),
       t_soma_desc_tit as (
          SELECT cyb.cdcooper
                ,cyb.nrdconta
                ,tdb.nrborder
                ,tdb.nrdocmto
                ,cyb.nrctremp
                ,tdb.nrctrlim
                ,tdb.vlmratit -- juros por atraso de pagamento
                ,tdb.vlmtatit -- multa por atraso de pagamento
                ,tdb.vliofcpl -- Valor do IOF Complementar de atraso
            FROM craptdb tdb
           INNER JOIN tbdsct_titulo_cyber tcy
              ON tcy.cdcooper = tdb.cdcooper
             AND tcy.nrdconta = tdb.nrdconta
             AND tcy.nrborder = tdb.nrborder
             AND tcy.nrtitulo = tdb.nrtitulo
           INNER JOIN crapcyb cyb
              ON cyb.cdcooper = tcy.cdcooper
             AND cyb.nrdconta = tcy.nrdconta
             AND cyb.nrctremp = tcy.nrctrdsc
             AND cyb.cdorigem = 4
           WHERE tdb.insittit = 4 -- liberado
             AND tdb.cdcooper = pr_cdcooper
       )
       SELECT crapcyb.cdcooper
             ,crapcyb.nrdconta
             ,crapcyb.cdfinemp
             ,crapcyb.nrctremp
             ,crapcyb.cdlcremp
             ,crapcyb.vlsdeved
             ,crapcyb.vljura60
             ,crapcyb.vlpreemp
             ,crapcyb.qtdiaatr
             ,crapcyb.dtdrisan
             ,crapcyb.vlpreapg
             ,crapcyb.vldespes
             ,crapcyb.vlperris
             ,crapcyb.cdagenci
             ,crapcyb.nivrisat
             ,crapcyb.nivrisan
             ,crapcyb.qtdiaris
             ,crapcyb.flgrpeco
             ,crapcyb.dtefetiv
             ,crapcyb.qtpreemp
             ,crapcyb.vlprepag
             ,crapcyb.dtdpagto
             ,crapcyb.dtdbaixa
             
             ,CASE
                WHEN crapcyb.cdorigem in (2,3) then -- emprestimos
                  NVL((crapcyb.vlsdprej + (epr.vlttmupr - epr.vlpgmupr)
                                        + (epr.vlttjmpr - epr.vlpgjmpr)
                                        + (epr.vltiofpr - epr.vlpiofpr)
                       ),0)
                ELSE
                  crapcyb.vlsdprej
              END AS vlsdprej
             
             ,crapcyb.flgresid
             ,crapcyb.flgconsg
             ,crapcyb.flgfolha
             ,crapcyb.dtmvtolt
             ,crapcyb.cdorigem
             ,crapcyb.qtpreatr
             ,crapcyb.vlemprst
             ,crapcyb.txmensal
             ,crapcyb.txdiaria
             ,crapcyb.qtprepag
             ,crapcyb.qtmesdec
             ,crapcyb.dtprejuz
             ,crapcyb.flgpreju
             ,crapcyb.dtmancad
             ,crapcyb.dtmanavl
             ,crapcyb.dtmangar
             ,crapcyb.dtatufin
             ,crapcyb.vlprapga
             ,crapcyb.vlsdevan
             ,crapcyb.vlsdprea
             ,crapcyb.ROWID
             ,crapass.cdagenci cdagenci_ass
             ,crapass.nrcpfcgc
             ,crapcyb.cdorigem||lpad(crapcyb.nrdconta,10,'0')||lpad(crapcyb.nrctremp,9,'0') dsdchave
             ,case
                when crapcyb.cdorigem in (1,2,3) then -- emprestimos/conta
                  tpep.vlmtapar
                when crapcyb.cdorigem = 4 then -- desconto de titulo
                  tdt.vlmtatit  -- multa por atraso de pagamento
              end AS vlmtapar
             ,case
                when crapcyb.cdorigem in (1,2,3) then -- emprestimos/conta
                  tpep.vlmrapar
                when crapcyb.cdorigem = 4 then -- desconto de titulo
                  tdt.vlmratit
              end AS vlmrapar -- juros por atraso de pagamento

             ,CASE
                WHEN crapcyb.cdorigem in (1,2,3) THEN -- emprestimos/conta
                  tpep.vliofcpl
                WHEN crapcyb.cdorigem = 4 THEN -- desconto de titulo
                  tdt.vliofcpl
              END AS vliofcpl -- Valor do IOF Complementar de atraso
              ,crapcyb.flgjudic
              ,crapcyb.flextjud
              ,crapcyb.flgehvip              
              ,tdt.nrctrlim -- Desconto de Titulo: Chave para busca de Avalista Terceiro
              ,tdt.nrborder -- Desconto de Titulo
              ,tdt.nrdocmto -- Desconto de Titulo
       FROM crapcyb
        INNER JOIN crapass ON crapass.cdcooper = crapcyb.cdcooper AND crapass.nrdconta = crapcyb.nrdconta
         LEFT JOIN t_soma_crappep tpep ON tpep.cdcooper = crapcyb.cdcooper AND tpep.nrdconta = crapcyb.nrdconta AND tpep.nrctremp = crapcyb.nrctremp
         LEFT JOIN t_soma_desc_tit tdt ON tdt.cdcooper = crapcyb.cdcooper  AND tdt.nrdconta = crapcyb.nrdconta  AND tdt.nrctremp = crapcyb.nrctremp
         LEFT JOIN crapepr epr         ON epr.cdcooper = crapcyb.cdcooper  AND epr.nrdconta = crapcyb.nrdconta  AND epr.nrctremp = crapcyb.nrctremp
        WHERE crapcyb.cdcooper = pr_cdcooper
          AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
       AND   (crapcyb.dtdbaixa IS NULL OR crapcyb.dtdbaixa = to_date('19/02/2019', 'dd/mm/RRRR'))
       ORDER BY crapcyb.cdcooper
               ,crapcyb.cdorigem
               ,crapcyb.nrdconta
               ,crapcyb.nrctremp;

       --Selecionar Linhas de Credito e Linhas de de Desconto
       CURSOR cr_craplcr (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_cdlcremp IN craplcr.cdlcremp%TYPE
                         ,pr_cdorigem IN crapcyb.cdorigem%TYPE) IS
         SELECT lin.dslcremp
               ,lin.tpctrato
           FROM (SELECT 'LDC' AS tabela
                       ,ldc.cddlinha AS cdlcremp
                       ,ldc.dsdlinha AS dslcremp
                       ,ldc.tpctrato 
                   FROM crapldc ldc
                  WHERE ldc.tpdescto = 3 -- desconto de titulo
                    AND ldc.cdcooper = pr_cdcooper
                    AND ldc.cddlinha = pr_cdlcremp
                  UNION
                 SELECT 'LCR' AS tabela 
                       ,lcr.cdlcremp
                       ,lcr.dslcremp
                       ,lcr.tpctrato
                   FROM craplcr lcr
                  WHERE lcr.cdcooper = pr_cdcooper
                    AND lcr.cdlcremp = pr_cdlcremp) lin
          WHERE lin.tabela = DECODE(pr_cdorigem,4,'LDC','LCR');
       rw_craplcr cr_craplcr%ROWTYPE;

       --Selecionar Titulares da Conta
       CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                         ,pr_nrdconta IN crapttl.nrdconta%type
                         ,pr_idseqttl IN crapttl.idseqttl%type) IS
         SELECT crapttl.dsnatura
               ,crapttl.cdufnatu
               ,crapttl.nmmaettl
               ,crapttl.nmpaittl
               ,crapttl.cdocpttl
               ,crapttl.cdempres
               ,crapttl.cdcooper
               ,crapttl.nmextemp
               ,crapttl.vlsalari
               ,crapttl.vldrendi##1
               ,crapttl.vldrendi##2
               ,crapttl.vldrendi##3
               ,crapttl.vldrendi##4
               ,crapttl.vldrendi##5
               ,crapttl.vldrendi##6
               ,crapttl.grescola
             ,crapttl.inhabmen 
         FROM crapttl
         WHERE crapttl.cdcooper = pr_cdcooper
         AND   crapttl.nrdconta = pr_nrdconta
         AND   crapttl.idseqttl = pr_idseqttl
         ORDER BY crapttl.progress_recid ASC;
       rw_crapttl cr_crapttl%ROWTYPE;

       --Selecionar Endereco
       CURSOR cr_crapenc (pr_cdcooper IN crapenc.cdcooper%type
                         ,pr_nrdconta IN crapenc.nrdconta%type
                         ,pr_idseqttl IN crapenc.idseqttl%type
                         ,pr_tpendass IN crapenc.tpendass%type) IS
         SELECT crapenc.dsendere
               ,crapenc.nmbairro
               ,crapenc.nmcidade
               ,crapenc.cdufende
               ,crapenc.nrcepend
               ,crapenc.nrendere
               ,crapenc.complend
               ,crapenc.incasprp
               ,crapenc.nrdoapto
               ,crapenc.cddbloco
               ,crapenc.nrcxapst
         FROM crapenc
         WHERE crapenc.cdcooper = pr_cdcooper
         AND   crapenc.nrdconta = pr_nrdconta
         AND   crapenc.idseqttl = pr_idseqttl
         AND   crapenc.tpendass = pr_tpendass;
       rw_crapenc cr_crapenc%ROWTYPE;

       -- Verificar se o avalista do contrato eh a cooperativa
       CURSOR cr_crapass_cpf (pr_cdcooper IN crapcop.cdcooper%type
                             ,pr_nrcpfcgc IN crapass.nrcpfcgc%type) IS
         SELECT crapass.cdcooper
               ,crapass.nrdconta
               ,crapass.inpessoa
               ,crapass.nrcpfcgc
               ,crapass.dtnasctl
               ,crapass.tpdocptl
               ,crapass.nrdocptl
         FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
         AND   crapass.nrcpfcgc = pr_nrcpfcgc
         ORDER BY crapass.progress_recid ASC;
       rw_crapass_cpf cr_crapass_cpf%ROWTYPE;

       -- Consulta contratos ativos de acordos
     CURSOR cr_ctr_acordo(pr_cdcooper crapcop.cdcooper%type 
                         ,pr_cdagenci crapass.cdagenci%type) IS
       SELECT tbrecup_acordo_contrato.nracordo
             ,tbrecup_acordo.cdcooper
             ,tbrecup_acordo.nrdconta
             ,tbrecup_acordo_contrato.cdorigem
             ,tbrecup_acordo_contrato.nrctremp
         FROM tbrecup_acordo_contrato
           ,tbrecup_acordo
           ,crapass
      where tbrecup_acordo.nracordo   = tbrecup_acordo_contrato.nracordo      
        and crapass.cdcooper = tbrecup_acordo.cdcooper
        and crapass.nrdconta = tbrecup_acordo.nrdconta
        and tbrecup_acordo.cdsituacao = 1
        and crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);
       rw_ctr_acordo cr_ctr_acordo%ROWTYPE; 

       --Buscar valor pago Emprestimo
       CURSOR cr_valor_pago_emprestimo (pr_cdcooper  IN crapcyb.cdcooper%type
                                       ,pr_nrdconta  IN crapcyb.nrdconta%type
                                       ,pr_nrctremp  IN crapcyb.nrctremp%type
                                       ,pr_dtmvtolt  IN crapdat.dtmvtolt%type) IS
         SELECT SUM(craplem.vllanmto) vllanmto
               ,craplem.cdhistor
               ,craphis.dshistor
           FROM craplem, craphis
          WHERE craphis.cdcooper = craplem.cdcooper
            AND craphis.cdhistor = craplem.cdhistor
            AND craplem.cdcooper = pr_cdcooper
            AND craplem.nrdconta = pr_nrdconta
            AND craplem.nrctremp = pr_nrctremp
            AND craplem.dtmvtolt = pr_dtmvtolt
            AND craphis.indcalem = 'S'
         GROUP BY craplem.cdhistor,craphis.dshistor
         UNION
         SELECT /*+ index(craplcm CRAPLCM##CRAPLCM2) */
               SUM(craplcm.vllanmto) vllanmto
               ,craplcm.cdhistor
               ,craphis.dshistor
           FROM craplcm, craphis, crapepr
          WHERE crapepr.cdcooper = craplcm.cdcooper
            AND crapepr.nrdconta = craplcm.nrdconta
            and crapepr.tpemprst = 0 -- TR
            AND craphis.cdcooper = craplcm.cdcooper
            AND craphis.cdhistor = craplcm.cdhistor
            AND trim(replace(craplcm.cdpesqbb,'.')) = pr_nrctremp
            AND craplcm.cdcooper = pr_cdcooper
            AND craplcm.nrdconta = pr_nrdconta
            AND crapepr.nrctremp = pr_nrctremp
            AND craplcm.dtmvtolt = pr_dtmvtolt
            --Multa e juros de mora
            AND craphis.cdhistor in (2084,2085,2087,2088,2090,2091,2093,2094)
         GROUP BY craplcm.cdhistor,craphis.dshistor
		 UNION
         SELECT /*+ index(craplcm CRAPLCM##CRAPLCM2) */
               SUM(craplcm.vllanmto) vllanmto
               ,craplcm.cdhistor
               ,craphis.dshistor
           FROM craplcm, craphis, crapepr
          WHERE crapepr.cdcooper = craplcm.cdcooper
            AND crapepr.nrdconta = craplcm.nrdconta
            AND craphis.cdcooper = craplcm.cdcooper
            AND craphis.cdhistor = craplcm.cdhistor
            AND trim(replace(craplcm.cdpesqbb,'.')) = pr_nrctremp
            AND craplcm.cdcooper = pr_cdcooper
            AND craplcm.nrdconta = pr_nrdconta
            AND crapepr.nrctremp = pr_nrctremp
            AND craplcm.dtmvtolt = pr_dtmvtolt
            --Pagamento de Prejuizo
            AND craphis.cdhistor in (2386)
					GROUP BY craplcm.cdhistor,craphis.dshistor
		 UNION
		     /* P450 - Reginaldo/AMcom - Ajuste para processar corretamente 
				           os preju�zos de empr�stimo pagos via Conta Transit�ria */
			   SELECT prj.vllanmto
				      , prj.cdhistor 
							, his.dshistor
					 FROM tbcc_prejuizo_detalhe prj
					    , craphis his
					WHERE prj.cdcooper = pr_cdcooper
					  AND prj.nrdconta = pr_nrdconta
						AND prj.nrctremp = pr_nrctremp
						AND prj.cdhistor = 2781 -- Recupera��o de preju�zo
						AND his.cdcooper = prj.cdcooper
						AND his.cdhistor = prj.cdhistor;
         
       -- [Projeto 403] Busca o valor pago para desconto de t�tulos  
       CURSOR cr_valor_pago_dsct_tit (pr_cdcooper  IN crapcyb.cdcooper%type
                                     ,pr_nrdconta  IN crapcyb.nrdconta%type
                                     ,pr_nrctremp  IN crapcyb.nrctremp%type
                                     ,pr_dtmvtolt  IN crapdat.dtmvtolt%type) IS
              -- Busca os lan�amentos de hist�ricos marcados na tela PARCYB para desconto de t�tulos
              SELECT SUM(lbdt.vllanmto) vllanmto
                    ,lbdt.cdhistor
                    ,his.dshistor
                FROM tbdsct_lancamento_bordero lbdt
          INNER JOIN craphis his ON his.cdcooper = lbdt.cdcooper AND his.cdhistor = lbdt.cdhistor
          INNER JOIN tbdsct_titulo_cyber tcy ON tcy.cdcooper = lbdt.cdcooper AND tcy.nrdconta = lbdt.nrdconta AND tcy.nrborder = lbdt.nrborder AND tcy.nrtitulo = lbdt.nrtitulo
               WHERE tcy.cdcooper  = pr_cdcooper
                 AND tcy.nrdconta  = pr_nrdconta
                 AND tcy.nrctrdsc  = pr_nrctremp
                 AND lbdt.dtmvtolt = pr_dtmvtolt
                 AND his.indcalem  = 'S' -- a marca��o de desconto de t�tulos e empr�stimos � a mesma
           GROUP BY lbdt.cdhistor,his.dshistor;                                
                                         
       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;


       -- 27/01/2017 -- Melhoria 432 - envio informa��es CYBER
       -- Verifica se � contrato de refinancimamento para envio do campo c�digo transacao CYBER
       CURSOR c_refinanciamento (pr_cdcooper  IN crapcyb.cdcooper%type
                                ,pr_nrdconta  IN crapcyb.nrdconta%type
                                ,pr_nrctremp  IN crapcyb.nrctremp%type) IS
         
         SELECT DECODE(CRAWEPR.IDQUAPRO,1,'RF',2,'RN',3,'RG',4,'CP','PA') CDTRSCYB
           FROM   crawepr
           WHERE  crawepr.cdcooper = pr_cdcooper
           AND    crawepr.nrdconta = pr_nrdconta
           AND    crawepr.insitapr = 1 -- aprovado
           AND   pr_nrctremp IN (crawepr.nrctrliq##1 ,
                   crawepr.nrctrliq##2 ,
                   crawepr.nrctrliq##3 , 
                   crawepr.nrctrliq##4 ,
                   crawepr.nrctrliq##5 ,
                   crawepr.nrctrliq##6 ,
                   crawepr.nrctrliq##7 ,
                   crawepr.nrctrliq##8 ,
                   crawepr.nrctrliq##9 ,
                   crawepr.nrctrliq##10 );
   
     -- Busca dados de Boleto
       CURSOR cr_boleto (pr_cdcooper IN crapcyb.cdcooper%TYPE
                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                      ,pr_cdagenci in crapass.cdagenci%type) IS
         SELECT epr.cdcooper
               ,epr.nrdconta
               ,epr.nrctremp
               ,epr.idarquivo
               ,epr.nrcpfava
               ,epr.tpparcela
           FROM tbrecup_cobranca epr
               ,crapass ass
          WHERE epr.tpproduto = 0
            AND epr.cdcooper = pr_cdcooper
            AND EXISTS (SELECT 1 
                          FROM crapcob cob
                         WHERE cob.cdcooper = epr.cdcooper
                          AND cob.nrdconta = epr.nrdconta_cob
                          AND cob.nrcnvcob = epr.nrcnvcob
                          AND cob.nrdocmto = epr.nrboleto
                          AND cob.incobran = 5
                          AND cob.dtdpagto = pr_dtmvtolt)
          and epr.cdcooper = ass.cdcooper
          and epr.nrdconta = ass.nrdconta
          and ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)
          ORDER BY epr.cdcooper, epr.nrdconta, epr.nrctremp;
         vr_cdtrscyb VARCHAR2(6);
                                
     -- Dados das tabela de trabalho de dados do arquivo
     cursor cr_work_arquv(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                         ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                         ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                         ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
      SELECT dsxml
        FROM tbgen_batch_relatorio_wrk
       WHERE cdcooper    = pr_cdcooper   
         AND cdprograma  = pr_cdprograma 
         AND dsrelatorio = pr_dsrelatorio
         AND dtmvtolt    = pr_dtmvtolt 
       ORDER BY cdagenci,nrdconta,dschave,nrctremp; -- Cdagenci � a Coop, nrdconta � o Arquivo, Dschave � a Sequencia(Origem,Conta,Contrato) e nrctremp � a linha dentro do arquivo da Agencia                    

       --Constantes
       vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS652';

       --Variaveis Locais
       vr_nrcpfcgc        VARCHAR2(1000);
       vr_caminho         VARCHAR2(1000);
       vr_tempoatu        VARCHAR2(1000);
       vr_avalist1        VARCHAR2(1000);
       vr_avalist2        VARCHAR2(1000);
       vr_contador        INTEGER;
       vr_vlrpagto        NUMBER;
       vr_buscocup        BOOLEAN;
       vr_rsdocupa        VARCHAR2(1000);
       vr_flgaval1        BOOLEAN;
       vr_flgaval2        BOOLEAN;
       vr_dtatual         DATE;
       vr_dtmvtolt        VARCHAR2(10);
       vr_dtmvtopr        VARCHAR2(10);
       vr_dtmvtlt2        VARCHAR2(10);
       vr_dtdrisan        VARCHAR2(10);
       vr_dtefetiv        VARCHAR2(10);
       vr_dtdpagto        VARCHAR2(10);
       vr_dtprejuz        VARCHAR2(10);
       vr_dtemdptl        VARCHAR2(10);
       vr_dtnasctl        VARCHAR2(10);
       vr_dtvalida        VARCHAR2(10);
       vr_dtnasccj        VARCHAR2(10);
       vr_dtnascav        VARCHAR2(10);
       vr_msgconta        VARCHAR2(1000);
       vr_dsdidade        VARCHAR2(1000);
       vr_dscatcyb        VARCHAR2(1000);
       vr_tparquiv        VARCHAR2(1000);
       vr_comando         VARCHAR2(1000);
       vr_typ_saida       VARCHAR2(1000);
       vr_setlinha        VARCHAR2(5000);
       vr_nrdrowid        ROWID;
       vr_menorida        BOOLEAN;
       vr_tem_craplcr     BOOLEAN;
       vr_nrdeanos        INTEGER:= 0;
       vr_nrdmeses        INTEGER:= 0;
       vr_tpendass        INTEGER:= 0;
       vr_nrindice        INTEGER:= 1;
       vr_qtdlinha        INTEGER;
       vr_vllammto        NUMBER:= 0;
       vr_flgbatch        INTEGER:= 0;
       vr_index           INTEGER;
       vr_idindice        VARCHAR2(40) := ''; -- Indice da tabela de acordos
       vr_idboleto        VARCHAR2(40) := '';
       vr_flacordo        NUMBER(1);

       --Tabela de Erros
       vr_tab_erro       gene0001.typ_tab_erro;

       --Variaveis para retorno de erro
       vr_des_erro        VARCHAR2(3);
       vr_cdcritic        INTEGER:= 0;
       vr_dscritic        VARCHAR2(4000);

       --Variaveis de Excecao
       vr_exc_final       EXCEPTION;
       vr_exc_saida       EXCEPTION;
       vr_exc_fimprg      EXCEPTION;

       -- Variavel para armazenar as informacoes em XML
       vr_des_xml1        CLOB;
       vr_des_xml2        CLOB;
       vr_des_xml3        CLOB;
       vr_des_xml4        CLOB;
       vr_des_xml5        CLOB;
       vr_des_xml6        CLOB;
       vr_des_xml7        CLOB;
       vr_des_xml8        CLOB;
     vr_des_txt1 VARCHAR2(32767);
     vr_des_txt2 VARCHAR2(32767);
     vr_des_txt3 VARCHAR2(32767);
     vr_des_txt4 VARCHAR2(32767);
     vr_des_txt5 VARCHAR2(32767);
     vr_des_txt6 VARCHAR2(32767);
     vr_des_txt7 VARCHAR2(32767);
     vr_des_txt8 VARCHAR2(32767);
     
     -- PLTables para armazenar as informa��es dos arquivos em mem�ria
     TYPE vr_reg_texto is record(dsdchave varchar2(30)
                                ,dsdtexto varchar2(5000));
     TYPE vr_typ_texto IS TABLE OF vr_reg_texto INDEX BY pls_integer;
     vr_tab_texto1 vr_typ_texto;
     vr_tab_texto2 vr_typ_texto;
     vr_tab_texto3 vr_typ_texto;
     vr_tab_texto4 vr_typ_texto;
     vr_tab_texto5 vr_typ_texto;
     vr_tab_texto6 vr_typ_texto;
     vr_tab_texto7 vr_typ_texto;
     vr_tab_texto8 vr_typ_texto;
     vr_tab_texto_Generi vr_typ_texto;
     
     -- ID para o paralelismo
     vr_idparale      INTEGER := 0;
     -- Qtde parametrizada de Jobs
     vr_qtdjobs       NUMBER := pr_qtdejobs;
     -- Job name dos processos criados
     vr_jobname       varchar2(30);
     -- Bloco PLSQL para chamar a execu��o paralela do pc_crps750
     vr_dsplsql       varchar2(4000);
     
     -- C�digo de controle retornado pela rotina gene0001.pc_grava_batch_controle
     vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;  
     vr_idlog_ini_ger tbgen_prglog.idprglog%type;
     vr_idlog_ini_par tbgen_prglog.idprglog%type;
     vr_tpexecucao    tbgen_prglog.tpexecucao%type; 
     vr_qterro        number := 0;      

     -- Procedure para Inicializar os CLOBs
       PROCEDURE pc_inicializa_clob IS
       BEGIN
         dbms_lob.createtemporary(vr_des_xml1, TRUE);
       dbms_lob.open(vr_des_xml1,dbms_lob.lob_readwrite);
         dbms_lob.createtemporary(vr_des_xml2, TRUE);
       dbms_lob.open(vr_des_xml2,dbms_lob.lob_readwrite);
         dbms_lob.createtemporary(vr_des_xml3, TRUE);
       dbms_lob.open(vr_des_xml3,dbms_lob.lob_readwrite);
         dbms_lob.createtemporary(vr_des_xml4, TRUE);
       dbms_lob.open(vr_des_xml4,dbms_lob.lob_readwrite);
         dbms_lob.createtemporary(vr_des_xml5, TRUE);
       dbms_lob.open(vr_des_xml5,dbms_lob.lob_readwrite);
         dbms_lob.createtemporary(vr_des_xml6, TRUE);
       dbms_lob.open(vr_des_xml6,dbms_lob.lob_readwrite);
         dbms_lob.createtemporary(vr_des_xml7, TRUE);
       dbms_lob.open(vr_des_xml7,dbms_lob.lob_readwrite);
         dbms_lob.createtemporary(vr_des_xml8, TRUE);
       dbms_lob.open(vr_des_xml8,dbms_lob.lob_readwrite);
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao inicializar CLOB. Rotina pc_crps652.pc_inicializa_clob. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END pc_inicializa_clob;

     -- Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_crapctt.DELETE;
         vr_tab_crapass.DELETE;
         vr_tab_crapjur.DELETE;
         vr_tab_categ.DELETE;
       vr_tab_texto1.delete;
       vr_tab_texto2.delete;
       vr_tab_texto3.delete;
       vr_tab_texto4.delete;
       vr_tab_texto5.delete;
       vr_tab_texto6.delete;
       vr_tab_texto7.delete;
       vr_tab_texto8.delete;
       vr_tab_texto_generi.delete;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao limpar tabelas de memoria. Rotina pc_crps652.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END pc_limpa_tabela;

     -- Carga dos associados
     procedure pc_carrega_associados(pr_cdcooper in crapcop.cdcooper%type
                                    ,pr_cdagenci in crapage.cdagenci%type default 0
                                    ,pr_nrdconta in crapass.nrdconta%type default 0) is
     begin
       FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdconta => pr_nrdconta) LOOP
         rw_crapcje1 := null;
         OPEN cr_crapcje1(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => rw_crapass.nrdconta);
         FETCH cr_crapcje1 INTO rw_crapcje1;
         CLOSE cr_crapcje1;
         vr_tab_crapass(rw_crapass.nrdconta).dtemdptl:= rw_crapass.dtemdptl;
         vr_tab_crapass(rw_crapass.nrdconta).dtnasctl:= rw_crapass.dtnasctl;
         vr_tab_crapass(rw_crapass.nrdconta).nmprimtl:= rw_crapass.nmprimtl;
         vr_tab_crapass(rw_crapass.nrdconta).tpdocptl:= rw_crapass.tpdocptl;
         vr_tab_crapass(rw_crapass.nrdconta).nrdocptl:= rw_crapass.nrdocptl;
         vr_tab_crapass(rw_crapass.nrdconta).cdsexotl:= rw_crapass.cdsexotl;
         vr_tab_crapass(rw_crapass.nrdconta).cdsitdct:= rw_crapass.cdsitdct;
         vr_tab_crapass(rw_crapass.nrdconta).inpessoa:= rw_crapass.inpessoa;
         vr_tab_crapass(rw_crapass.nrdconta).nrcpfcgc:= rw_crapass.nrcpfcgc;
         vr_tab_crapass(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
         vr_tab_crapass(rw_crapass.nrdconta).dtadmiss:= rw_crapass.dtadmiss;
         vr_tab_crapass(rw_crapass.nrdconta).dtdemiss:= rw_crapass.dtdemiss;
         vr_tab_crapass(rw_crapass.nrdconta).inlbacen:= rw_crapass.inlbacen;
         vr_tab_crapass(rw_crapass.nrdconta).inrisctl:= rw_crapass.inrisctl;
         vr_tab_crapass(rw_crapass.nrdconta).idastcjt:= rw_crapass.idastcjt;
         -- Informa��es do Conjugue
         vr_tab_crapass(rw_crapass.nrdconta).dtnasccj:= rw_crapcje1.dtnasccj;
         vr_tab_crapass(rw_crapass.nrdconta).nmconjug:= rw_crapcje1.nmconjug;
         -- Vamos carregar as informa��es do estado civil apenas quando for pessoa f�sica
         IF rw_crapass.inpessoa = 1 THEN
           OPEN cr_gnetcvl (pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_crapass.nrdconta);
           FETCH cr_gnetcvl INTO rw_gnetcvl;
           IF cr_gnetcvl%FOUND THEN
             vr_tab_crapass(rw_crapass.nrdconta).cdestcvl:= rw_gnetcvl.cdestcvl;
             vr_tab_crapass(rw_crapass.nrdconta).dsestcvl:= rw_gnetcvl.rsestcvl;
           END IF;
           CLOSE cr_gnetcvl;
         END IF;
       END LOOP;
     end;
     
     
     -- Escrever em CLOB
     PROCEDURE pc_escreve_clob(pr_des_text IN VARCHAR2
                              ,pr_cod_info IN INTEGER
                              ,pr_flfechar IN BOOLEAN DEFAULT FALSE) IS -- Identifica se deve fechar o CLOB
     BEGIN
       -- Escrever no arquivo XML
       CASE pr_cod_info
         WHEN 1 THEN gene0002.pc_escreve_xml(vr_des_xml1,vr_des_txt1,pr_des_text,pr_flfechar);
         WHEN 2 THEN gene0002.pc_escreve_xml(vr_des_xml2,vr_des_txt2,pr_des_text,pr_flfechar);
         WHEN 3 THEN gene0002.pc_escreve_xml(vr_des_xml3,vr_des_txt3,pr_des_text,pr_flfechar);
         WHEN 4 THEN gene0002.pc_escreve_xml(vr_des_xml4,vr_des_txt4,pr_des_text,pr_flfechar);
         WHEN 5 THEN gene0002.pc_escreve_xml(vr_des_xml5,vr_des_txt5,pr_des_text,pr_flfechar);
         WHEN 6 THEN gene0002.pc_escreve_xml(vr_des_xml6,vr_des_txt6,pr_des_text,pr_flfechar);
         WHEN 7 THEN gene0002.pc_escreve_xml(vr_des_xml7,vr_des_txt7,pr_des_text,pr_flfechar);
         WHEN 8 THEN gene0002.pc_escreve_xml(vr_des_xml8,vr_des_txt8,pr_des_text,pr_flfechar);
       END CASE;
     EXCEPTION
       WHEN OTHERS THEN
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao escrever no CLOB('||pr_cod_info||') --> '||sqlerrm;
         -- Levantar Excecao
         RAISE vr_exc_saida;
     END pc_escreve_clob;
    
     -- Escrever em tabela de mem�ria
     PROCEDURE pc_escreve_dado(pr_des_text IN VARCHAR2
                              ,pr_cod_info IN INTEGER
                              ,pr_des_chav IN VARCHAR2) IS
       vr_count number;
          vr_linha VARCHAR2(5000);
       BEGIN
       -- Se foi passada infomacao
       IF pr_des_text IS NOT NULL THEN
         -- Atribuir o parametro para a variavel
         vr_linha := pr_des_text;
       ELSE
         -- Enviar para a pltable o conteudo da tab_linha
         vr_linha := vr_tab_linha(pr_cod_info);
         -- Limpar string
         vr_tab_linha(pr_cod_info) := NULL;
       END IF;
       
       -- Enviar para a tabela de mem�ria correspondente o char montado acima
       IF pr_cod_info = 1 THEN 
         vr_count := vr_tab_texto1.count();
         vr_tab_texto1(vr_count).dsdchave := pr_des_chav;
         vr_tab_texto1(vr_count).dsdtexto := vr_linha;
       ELSIF pr_cod_info = 2 THEN 
         vr_count := vr_tab_texto2.count();
         vr_tab_texto2(vr_count).dsdchave := pr_des_chav;
         vr_tab_texto2(vr_count).dsdtexto := vr_linha;
       ELSIF pr_cod_info = 3 THEN 
         vr_count := vr_tab_texto3.count();
         vr_tab_texto3(vr_count).dsdchave := pr_des_chav;
         vr_tab_texto3(vr_count).dsdtexto := vr_linha;
       ELSIF pr_cod_info = 4 THEN
         vr_count := vr_tab_texto4.count();
         vr_tab_texto4(vr_count).dsdchave := pr_des_chav;
         vr_tab_texto4(vr_count).dsdtexto := vr_linha;
       ELSIF pr_cod_info = 5 THEN 
         vr_count := vr_tab_texto5.count();
         vr_tab_texto5(vr_count).dsdchave := pr_des_chav;
         vr_tab_texto5(vr_count).dsdtexto := vr_linha;
       ELSIF pr_cod_info = 6 THEN
         vr_count := vr_tab_texto6.count(); 
         vr_tab_texto6(vr_count).dsdchave := pr_des_chav;
         vr_tab_texto6(vr_count).dsdtexto := vr_linha;
       ELSIF pr_cod_info = 7 THEN 
         vr_count := vr_tab_texto7.count();
         vr_tab_texto7(vr_count).dsdchave := pr_des_chav;
         vr_tab_texto7(vr_count).dsdtexto := vr_linha;
       ELSIF pr_cod_info = 8 THEN
         vr_count := vr_tab_texto8.count();
         vr_tab_texto8(vr_count).dsdchave := pr_des_chav;
         vr_tab_texto8(vr_count).dsdtexto := vr_linha;
       END IF; 
       
       EXCEPTION
         WHEN OTHERS THEN
           vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao escrever na PLTABLE('||pr_cod_info||'). '||sqlerrm;
           --Levantar Excecao
           RAISE vr_exc_saida;
     END pc_escreve_dado;

     -- Procedure para atualizar Agencia
       PROCEDURE pc_atualiza_agencia (pr_rw_crapcyb IN OUT cr_crapcyb%ROWTYPE
                                     ,pr_des_erro OUT VARCHAR2
                                     ,pr_cdcritic OUT INTEGER
                                     ,pr_dscritic OUT VARCHAR2
                                     ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS
       BEGIN
         DECLARE
           --Variaveis de Excecao
           vr_exc_erro EXCEPTION;
           --Variaveis Erro
           vr_cdcritic INTEGER;
           vr_dscritic VARCHAR2(4000);
         BEGIN
           --Limpar parametros erro
           pr_cdcritic:= NULL;
           pr_dscritic:= NULL;
           pr_des_erro:= 'NOK';

           --Limpar tabela erros
           pr_tab_erro.DELETE;
           
           BEGIN
            -- UPDATE crapcyb SET crapcyb.cdagenci = pr_rw_crapcyb.cdagenci_ass
             SELECT crapcyb.cdagenci INTO pr_rw_crapcyb.cdagenci FROM crapcyb
             WHERE crapcyb.cdcooper = pr_rw_crapcyb.cdcooper
             AND   crapcyb.cdorigem = pr_rw_crapcyb.cdorigem
             AND   crapcyb.nrdconta = pr_rw_crapcyb.nrdconta
             AND   crapcyb.nrctremp = pr_rw_crapcyb.nrctremp;
          --   RETURNING crapcyb.cdagenci
             
           EXCEPTION
             WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao atualizar agencia na crapcyb. '||sqlerrm;
           END;
           
           --Se ocorreu erro
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
             pr_des_erro:= 'NOK';
             --Gerar erro
             GENE0001.pc_gera_erro(pr_cdcooper => pr_rw_crapcyb.cdcooper
                                  ,pr_cdagenci => pr_rw_crapcyb.cdagenci_ass
                                  ,pr_nrdcaixa => 0
                                  ,pr_nrsequen => 1 /** Sequencia **/
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_tab_erro => vr_tab_erro);
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               --Levantar Excecao
               RAISE vr_exc_erro;
             END IF;
           ELSE
             pr_des_erro:= 'OK';
           END IF;
         EXCEPTION
           WHEN vr_exc_erro THEN
             pr_cdcritic:= vr_cdcritic;
             pr_dscritic:= vr_dscritic;
           WHEN OTHERS THEN
             --Variavel de erro recebe erro ocorrido
             pr_cdcritic:= 0;
             pr_dscritic:= 'Erro ao atualizar agencia. Rotina pc_CRPS652.pc_atualiza_agencia. '||sqlerrm;
         END;
       END pc_atualiza_agencia;

       --Funcao para retornar cpf/cnpj
       FUNCTION fn_busca_cpfcgc (pr_nrcpfcgc IN NUMBER) RETURN VARCHAR2 IS
       BEGIN
         DECLARE
           --Variaveis Locais
           vr_stsnrcal BOOLEAN;
           vr_inpessoa INTEGER;
         BEGIN
           --Validar o cpf/cnpj
           gene0005.pc_valida_cpf_cnpj (pr_nrcalcul => pr_nrcpfcgc
                                       ,pr_stsnrcal => vr_stsnrcal
                                       ,pr_inpessoa => vr_inpessoa);
           --Se o parametro esta preenchido
           IF pr_nrcpfcgc IS NOT NULL AND pr_nrcpfcgc <> 0 THEN
             --Se for pessoa fisica
             IF vr_inpessoa = 1 THEN
               RETURN(gene0002.fn_mask(pr_nrcpfcgc,'99999999999'));
             ELSE
               RETURN(gene0002.fn_mask(pr_nrcpfcgc,'99999999999999'));
             END IF;
           END IF;
           RETURN(NULL);
         EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic:= 0;
             vr_dscritic:= 'Erro ao validar cpf/cnpj. '||SQLERRM;
             RAISE vr_exc_saida;
         END;
       END fn_busca_cpfcgc;

       --Procedure para controle da String
       PROCEDURE pc_monta_linha(pr_text    in varchar2,
                                pr_nrposic in integer,
                                pr_arquivo in integer) IS
         vr_linha       varchar2(5000) := null;
         vr_tam_linha   integer;
         vr_qtd_brancos integer;
       BEGIN
         vr_linha := vr_tab_linha(pr_arquivo);
         -- Verifica quantos caracteres j� existem na linha
         vr_tam_linha := nvl(length(vr_linha), 0);
         -- Calcula quantidade de espa�os a incluir na linha
         vr_qtd_brancos := pr_nrposic - vr_tam_linha - 1;
         -- Concatena os espa�os em branco e o novo texto
         vr_linha := vr_linha || rpad(' ', vr_qtd_brancos, ' ') || pr_text;
       -- Modificar vetor com a linha atualizada
         vr_tab_linha(pr_arquivo) := gene0007.fn_caract_acento(GENE0007.fn_caract_acento(vr_linha,0),1,'`�#$&%������*!?<>/\|','                    ');
       END pc_monta_linha;

       --Procedure para Gravar Campos Obrigatorios
       PROCEDURE pc_gera_campos_obrig (pr_idarquivo IN INTEGER
                                      ,pr_cdcooper  IN crapcyb.cdcooper%type
                                      ,pr_cdorigem  IN crapcyb.cdorigem%type
                                      ,pr_nrdconta  IN crapcyb.nrdconta%type
                                      ,pr_nrctremp  IN crapcyb.nrctremp%type
                                      ,pr_nrcpfcgc  IN crapass.nrcpfcgc%type
                                      ,pr_cdcritic  OUT INTEGER
                                      ,pr_dscritic  OUT VARCHAR2) IS
       BEGIN
         DECLARE
           --Variaveis de Excecao
           vr_exc_erro EXCEPTION;
           --Variaveis Erro
           vr_cdcritic INTEGER;
           vr_dscritic VARCHAR2(4000);
         BEGIN
           --Limpar parametros erro
           pr_cdcritic:= NULL;
           pr_dscritic:= NULL;
           --Escrever no arquivo
           pc_monta_linha('1',4,pr_idarquivo);
           pc_monta_linha(gene0002.fn_mask(pr_cdcooper,'9999'),5,pr_idarquivo);
           pc_monta_linha(gene0002.fn_mask(pr_cdorigem,'9999'),9,pr_idarquivo);
           pc_monta_linha(gene0002.fn_mask(pr_nrdconta,'99999999'),13,pr_idarquivo);
           pc_monta_linha(gene0002.fn_mask(pr_nrctremp,'99999999'),21,pr_idarquivo);

           --Montar cpf/cnpj
           vr_nrcpfcgc:= fn_busca_cpfcgc (pr_nrcpfcgc => pr_nrcpfcgc);
           pc_monta_linha(vr_nrcpfcgc,30,pr_idarquivo);

         EXCEPTION
           WHEN vr_exc_erro THEN
             pr_cdcritic:= vr_cdcritic;
             pr_dscritic:= vr_dscritic;
           WHEN OTHERS THEN
             --Variavel de erro recebe erro ocorrido
             pr_cdcritic:= 0;
             pr_dscritic:= 'Erro na rotina pc_CRPS652.pc_gera_campos_obrig. '||sqlerrm;
         END;
       END pc_gera_campos_obrig;

     -- Procedure para gerar Avalista
       PROCEDURE pc_gera_aval (pr_idarquivo  IN INTEGER
                              ,pr_opccarga   IN VARCHAR2
                              ,pr_cdcooper   IN crapcyb.cdcooper%type
                              ,pr_nrdconta   IN crapcyb.nrdconta%type
                              ,pr_nrctremp   IN crapcyb.nrctremp%type
                              ,pr_cdorigem   IN crapcyb.cdorigem%type
                              ,pr_nrdocnpj   IN crapcop.nrdocnpj%type
                              ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
                              ,pr_flgtemlcr  IN BOOLEAN
                              ,pr_nrctrlim   IN craptdb.nrctrlim%TYPE DEFAULT 0
                              ,pr_rw_craplcr IN cr_craplcr%ROWTYPE
                            ,pr_dsdchave   in varchar2
                              ,pr_cdcritic   OUT INTEGER
                              ,pr_dscritic   OUT VARCHAR2) IS
       BEGIN
         DECLARE
           /* Cursores Locais */
           --Selecionar Informacoes do Emprestimo - chave dos Avalistas
           CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%type
                             ,pr_nrdconta IN crapepr.nrdconta%type
                             ,pr_nrctremp IN crapepr.nrctremp%type) IS
            -- Avalistas de Empr�stimos
             SELECT  crapepr.cdcooper
                    ,crapepr.nrctaav1
                    ,crapepr.nrctaav2
                  ,crapepr.nrctremp
             FROM crapepr
             WHERE crapepr.cdcooper = pr_cdcooper
             AND   crapepr.nrdconta = pr_nrdconta
               AND crapepr.nrctremp = pr_nrctremp
               AND pr_cdorigem = 3 
             UNION ALL
            -- Avalistas de Titulos de Desconto de Titulos
            SELECT tdb.cdcooper
                  ,l.nrctaav1
                  ,l.nrctaav2
                  ,tcy.nrctrdsc
              FROM craptdb tdb
             INNER join craplim l -- para buscar os avalistas do t�tulo
                ON l.cdcooper = tdb.cdcooper
               AND l.nrdconta = tdb.nrdconta
               AND l.nrctrlim = tdb.nrctrlim
             INNER JOIN tbdsct_titulo_cyber tcy
                ON tcy.cdcooper = tdb.cdcooper
               AND tcy.nrdconta = tdb.nrdconta
               AND tcy.nrborder = tdb.nrborder
               AND tcy.nrtitulo = tdb.nrtitulo
             WHERE tcy.cdcooper = pr_cdcooper
               AND tcy.nrdconta = pr_nrdconta
               AND tcy.nrctrdsc = pr_nrctremp
               AND pr_cdorigem = 4;
           rw_crapepr cr_crapepr%ROWTYPE;

           /* Verificar se o avalista do contrato eh a cooperativa */
           CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%type
                             ,pr_nrdconta IN crapass.nrdconta%type
                             ,pr_nrcpfcgc IN crapass.nrcpfcgc%type) IS
             SELECT crapass.nmprimtl
                   ,crapass.nrdconta
                   ,crapass.nrcpfcgc
                   ,crapass.inpessoa
                   ,crapass.dtnasctl
                   ,crapass.tpdocptl
                   ,crapass.nrdocptl
             FROM crapass
             WHERE crapass.cdcooper = pr_cdcooper
             AND   crapass.nrdconta = pr_nrdconta
             AND   crapass.nrcpfcgc = pr_nrcpfcgc;
           rw_crapass cr_crapass%ROWTYPE;
           --Selecionar Saldo Conta
           CURSOR cr_crapsda (pr_cdcooper IN crapcop.cdcooper%type
                             ,pr_nrdconta IN crapass.nrdconta%type
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%type) IS
             SELECT crapsda.vlsdcota
                   ,crapsda.vllimcre
                   ,crapsda.vlsdrdpp
                   ,crapsda.vlsdrdca
                   ,crapsda.vllimutl
             FROM crapsda
             WHERE crapsda.cdcooper = pr_cdcooper
             AND   crapsda.nrdconta = pr_nrdconta
             AND   crapsda.dtmvtolt = pr_dtmvtolt;
           rw_crapsda cr_crapsda%ROWTYPE;
           --Selecionar Telefone
           CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%type
                             ,pr_nrdconta IN craptfc.nrdconta%type
                             ,pr_idseqttl IN craptfc.idseqttl%type
                             ,pr_tptelefo IN craptfc.tptelefo%type) IS
             SELECT craptfc.nrdddtfc
                   ,craptfc.nrtelefo
             FROM craptfc
             WHERE craptfc.cdcooper = pr_cdcooper
             AND   craptfc.nrdconta = pr_nrdconta
             AND   craptfc.idseqttl = pr_idseqttl
             AND   craptfc.tptelefo = pr_tptelefo
             AND   craptfc.idsittfc = 1
             ORDER BY craptfc.progress_recid ASC;
           rw_craptfc cr_craptfc%ROWTYPE;
           rw_crabtfc cr_craptfc%ROWTYPE;
           --Selecionar Avalistas do Emprestimo
           CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%type
                             ,pr_tpctrato IN crapavt.tpctrato%type
                             ,pr_nrdconta IN crapavt.nrdconta%type
                             ,pr_nrctremp IN crapavt.nrctremp%type
                             ,pr_nrcpfcgc IN crapavt.nrcpfcgc%type
                             ,pr_nrctrlim IN craptdb.nrctrlim%type DEFAULT 0) IS
             SELECT crapavt.cdcooper
                   ,crapavt.nrcpfcgc
                   ,crapavt.nmdavali
                   ,crapavt.dsendres##1
                   ,crapavt.dsendres##2
                   ,decode(crapavt.tpctrato,1,substr(crapavt.dsendres##2,1,40) --Cortado em 40 posi��es
                                           ,9,substr(crapavt.dsendres##2,1,40) --Tamanho m�ximo do campo nmbairro
                                             ,crapavt.nmbairro) nmbairro       --Chamado 307644
                   ,crapavt.nmcidade
                   ,crapavt.cdufresd
                   ,crapavt.nrcepend
                   ,crapavt.nrfonres
                   ,crapavt.nrendere
                   ,crapavt.complend
                   ,crapavt.inpessoa
                   ,crapavt.dtnascto
             FROM crapavt
             WHERE crapavt.cdcooper =  pr_cdcooper
             AND   crapavt.tpctrato =  pr_tpctrato
             AND   crapavt.nrdconta =  pr_nrdconta
             AND   crapavt.nrctremp =  pr_nrctremp
             AND   pr_cdorigem = 3
             AND   crapavt.nrcpfcgc <> pr_nrdocnpj
            UNION ALL
            -- Desconto de Titulo
             SELECT crapavt.cdcooper
                   ,crapavt.nrcpfcgc
                   ,crapavt.nmdavali
                   ,crapavt.dsendres##1
                   ,crapavt.dsendres##2
                   ,decode(crapavt.tpctrato,1,substr(crapavt.dsendres##2,1,40) --Cortado em 40 posi��es
                                           ,9,substr(crapavt.dsendres##2,1,40) --Tamanho m�ximo do campo nmbairro
                                             ,crapavt.nmbairro) nmbairro       --Chamado 307644
                   ,crapavt.nmcidade
                   ,crapavt.cdufresd
                   ,crapavt.nrcepend
                   ,crapavt.nrfonres
                   ,crapavt.nrendere
                   ,crapavt.complend
                   ,crapavt.inpessoa
                   ,crapavt.dtnascto
             FROM crapavt
             WHERE crapavt.cdcooper = pr_cdcooper
             AND   crapavt.tpctrato = 3
             AND   crapavt.nrdconta = pr_nrdconta
             AND   pr_cdorigem = 4
             AND   crapavt.nrctremp = pr_nrctrlim;
           rw_crapavt cr_crapavt%ROWTYPE;

           --Variaveis Locais
           vr_crapass  BOOLEAN;
           vr_crapsda  BOOLEAN;
           vr_crapenc  BOOLEAN;
           vr_craptfc  BOOLEAN;
           vr_crabtfc  BOOLEAN;
           vr_crapttl  BOOLEAN;
           vr_flgaval1 BOOLEAN;
           vr_tpendass INTEGER;
           vr_nrctaava INTEGER;
           vr_avalista VARCHAR2(1000);
           vr_interven VARCHAR2(1000);
           --Variaveis de Excecao
           vr_exc_erro EXCEPTION;
           --Variaveis Erro
           vr_cdcritic INTEGER;
           vr_dscritic VARCHAR2(4000);
         BEGIN
           --Limpar Variaveis Avalista
           vr_avalist1:= NULL;
           vr_avalist2:= NULL;
           --Selecionar emprestimo
           OPEN cr_crapepr (pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp);
           FETCH cr_crapepr INTO rw_crapepr;
           CLOSE cr_crapepr;

           --Percorrer 2x, uma para avalista1 e outra para avalista2
           FOR idx IN 1..2 LOOP
             --Limpar variavel auxiliar
             vr_avalista:= NULL;
             --Inicializar Variaveis
             CASE idx
               WHEN 1 THEN
                 vr_flgaval1:= FALSE;
                 vr_nrctaava:= rw_crapepr.nrctaav1;
               WHEN 2 THEN
                 vr_flgaval2:= FALSE;
                 vr_nrctaava:= rw_crapepr.nrctaav2;
             END CASE;
             vr_tpendass:= 0;
             --Selecionar Associado
             OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => vr_nrctaava
                             ,pr_nrcpfcgc => pr_nrdocnpj);
             FETCH cr_crapass INTO rw_crapass;
             --Se achou
             vr_crapass:= cr_crapass%FOUND;
             CLOSE cr_crapass;
             --Selecionar Saldo Diario
             OPEN cr_crapsda (pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => vr_nrctaava
                             ,pr_dtmvtolt => pr_dtmvtolt);
             FETCH cr_crapsda INTO rw_crapsda;
             --Se achou
             vr_crapsda:= cr_crapsda%FOUND;
             CLOSE cr_crapsda;

             --Possuir saldo e nao tem associado
             IF vr_crapsda AND NOT vr_crapass THEN

             -- Para execu��es paralelas, onde o vetor vr_tab_crapass pode n�o estar completo
             if pr_cdcoppar > 0 and not vr_tab_crapass.EXISTS(vr_nrctaava) then 
               -- Carrega somente esta conta
               pc_carrega_associados(pr_cdcooper => pr_cdcoppar
                                    ,pr_nrdconta => vr_nrctaava);
             end if;
           
               --Se Encontrou Associado
               IF vr_tab_crapass.EXISTS(vr_nrctaava) THEN
                 --Marcar encontrou avalista
                 CASE idx
                   WHEN 1 THEN vr_flgaval1:= TRUE;
                   WHEN 2 THEN vr_flgaval2:= TRUE;
                 END CASE;
                 /* MF */
                 IF pr_opccarga = 'F' THEN
                   /* Avalista 1 com conta */
                   vr_avalista:= rpad(fn_busca_cpfcgc (pr_nrcpfcgc => vr_tab_crapass(vr_nrctaava).nrcpfcgc),14,' ')||
                                 rpad(vr_tab_crapass(vr_nrctaava).nrdconta,8,' ')||
                                 rpad(vr_tab_crapass(vr_nrctaava).nmprimtl,50,' ')||
                                 to_char(rw_crapsda.vlsdcota*100,'00000000000000')||
                                 to_char(rw_crapsda.vllimcre*100,'00000000000000')||
                                 to_char(rw_crapsda.vlsdrdpp*100,'00000000000000')||
                                 to_char(rw_crapsda.vlsdrdca*100,'00000000000000');
                 ELSIF pr_opccarga = 'R' THEN /* Relations */
                   --Se for pessoa fisica
                   IF vr_tab_crapass(vr_nrctaava).inpessoa = 1 THEN
                     vr_tpendass:= 10;
                   ELSE
                     vr_tpendass:= 9;
                   END IF;
                   --Selecionar Endereco
                   OPEN cr_crapenc (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => vr_nrctaava
                                   ,pr_idseqttl => 1
                                   ,pr_tpendass => vr_tpendass);
                   --Posicionar primeiro registro
                   FETCH cr_crapenc INTO rw_crapenc;
                   --Verificar se encontrou
                   vr_crapenc:= cr_crapenc%FOUND;
                   --Fechar Cursor
                   CLOSE cr_crapenc;
                   --Selecionar primeiro telefone residencial
                   OPEN cr_craptfc (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => vr_nrctaava
                                   ,pr_idseqttl => 1
                                   ,pr_tptelefo => 1);  /* Residencial */
                   --Posicionar primeiro registro
                   FETCH cr_craptfc INTO rw_craptfc;
                   vr_craptfc:= cr_craptfc%FOUND;
                   --Fechar Cursor
                   CLOSE cr_craptfc;
                   --Selecionar primeiro telefone celular
                   OPEN cr_craptfc (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => vr_nrctaava
                                   ,pr_idseqttl => 1
                                   ,pr_tptelefo => 2);  /* Celular */
                   --Posicionar primeiro registro
                   FETCH cr_craptfc INTO rw_crabtfc;
                   vr_crabtfc:= cr_craptfc%FOUND;
                   --Fechar Cursor
                   CLOSE cr_craptfc;
                   --Selecionar Primeiro Titular
                   OPEN cr_crapttl (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => vr_nrctaava
                                   ,pr_idseqttl => 1);
                   --Posicionar primeiro registro
                   FETCH cr_crapttl INTO rw_crapttl;
                   --Se Encontrou
                   vr_crapttl:= cr_crapttl%FOUND;
                   --Fechar Cursor
                   CLOSE cr_crapttl;
                   /* Avalista 1 com conta */
                   vr_avalista:= '1'|| gene0002.fn_mask(pr_cdcooper,'9999')||
                                       gene0002.fn_mask(pr_cdorigem,'9999')||
                                       gene0002.fn_mask(pr_nrdconta,'99999999')||
                                       gene0002.fn_mask(pr_nrctremp,'99999999')||
                                       '  8'||
                                       rpad(' ',3,' ')||
                                       rpad(vr_tab_crapass(vr_nrctaava).nmprimtl,80,' ')||
                                       rpad(vr_tab_crapass(vr_nrctaava).nrdconta,80,' ');
                   --Se possui endereco
                   IF vr_crapenc THEN
                     vr_avalista:= vr_avalista || rpad(rw_crapenc.dsendere,80,' ')||
                                                  rpad(rw_crapenc.nmbairro,80,' ')||
                                                  rpad(rw_crapenc.nmcidade,40,' ')||
                                                  rpad(rw_crapenc.cdufende,5,' ')||
                                                  rpad(rw_crapenc.nrcepend,10,' ');
                   ELSE
                     vr_avalista:= vr_avalista || rpad(' ',215,' ');
                   END IF;
                   --Concatenar o cpf/cnpj
                   vr_avalista:= vr_avalista|| rpad(fn_busca_cpfcgc (pr_nrcpfcgc => vr_tab_crapass(vr_nrctaava).nrcpfcgc),25,' ');
                   --Se possui telefone residencial
                   IF vr_craptfc THEN
                     vr_avalista:= vr_avalista||rpad(' ',5,' ')||
                                   rpad(rw_craptfc.nrdddtfc||
                                        rw_craptfc.nrtelefo,13,' '); /* Tel residencial */
                   ELSE
                     vr_avalista:= vr_avalista||rpad(' ',18,' ');
                   END IF;
                   --Se possui telefone celular
                   IF vr_crabtfc THEN
                     vr_avalista:= vr_avalista||
                                   rpad(rw_crabtfc.nrdddtfc||
                                        rw_crabtfc.nrtelefo,18,' '); /* Tel celular */
                   ELSE
                     vr_avalista:= vr_avalista||rpad(' ',18,' ');
                   END IF;
                   --Se possui endereco
                   IF vr_crapenc THEN
                     vr_avalista:= vr_avalista|| rpad(rw_crapenc.nrendere,6,' ')||
                                                 rpad(rw_crapenc.complend,40,' ');
                   ELSE
                     vr_avalista:= vr_avalista||rpad(' ',46,' ');
                   END IF;
                   --Inicializar data nascimento conjuge
                   vr_dtnasccj:= ' ';
                   --Determinar estado civil
                   IF vr_tab_crapass(vr_nrctaava).cdestcvl = 1 THEN /*Solteiro*/
                     vr_avalista:= vr_avalista || 'S';
                   ELSIF vr_tab_crapass(vr_nrctaava).cdestcvl IN (2,3,4,8,9,11,12) THEN /*Casado*/
                     vr_avalista:= vr_avalista|| 'C';
                     --Se a data nascimento conjuge estiver preenchida
                     IF vr_tab_crapass(vr_nrctaava).dtnasccj IS NOT NULL THEN
                       vr_dtnasccj:= TO_CHAR(vr_tab_crapass(vr_nrctaava).dtnasccj,'MMDDYYYY');
                     END IF;
                   ELSIF vr_tab_crapass(vr_nrctaava).cdestcvl = 5 THEN /* Viuvo */
                     vr_avalista:= vr_avalista || 'V';
                   ELSIF vr_tab_crapass(vr_nrctaava).cdestcvl IN (6,7) THEN /* Divorciado */
                     vr_avalista:= vr_avalista|| 'D';
                   ELSE
                     vr_avalista:= vr_avalista || chr(32);
                   END IF;
                   --Data Nascimento Avalista
                   vr_dtnascav:= nvl(to_char(vr_tab_crapass(vr_nrctaava).dtnasctl,'MMDDYYYY'), ' ');
                   --Concatenar Informacoes
                   vr_avalista:= vr_avalista||rpad(vr_tab_crapass(vr_nrctaava).nmconjug,50,' ')||
                                              rpad(vr_dtnasccj,8,' ')||
                                              rpad(vr_dtnascav,8,' ');
                   --Se possui titulares
                   IF vr_crapttl THEN
                     --Nome pai titular
                     vr_avalista:= vr_avalista || rpad(substr(rw_crapttl.nmpaittl, 1, 50),50,' ');
                     --Nome mae titular
                     vr_avalista:= vr_avalista || rpad(substr(rw_crapttl.nmmaettl, 1, 50),50,' ');
                   ELSE
                     --Nome pai titular - VAZIO
                     vr_avalista:= vr_avalista||rpad(' ',50,' ');
                     --Nome mae titular - VAZIO
                     vr_avalista:= vr_avalista||rpad(' ',50,' ');
                   END IF;
                   --Se possui titular
                   IF vr_crapttl THEN
                     vr_avalista:= vr_avalista || rpad(rw_crapttl.dsnatura,25,' ')||
                                                  rpad(rw_crapttl.cdufnatu,2,' ');
                   ELSE
                     vr_avalista:= vr_avalista ||rpad(' ',27,' ');
                   END IF;
                   --Concatenar BRA
                   vr_avalista:= vr_avalista|| 'BRA';
                   --Se possuir associado
                   vr_avalista:= vr_avalista ||gene0002.fn_mask(vr_tab_crapass(vr_nrctaava).inpessoa,'9')||
                                               rpad(upper(vr_tab_crapass(vr_nrctaava).tpdocptl),2,' ')||
                                               rpad(vr_tab_crapass(vr_nrctaava).nrdocptl,15,' ');
                 END IF;
               END IF;
             END IF;
             --Atribuir valor para variavel definitiva
             CASE idx
               WHEN 1 THEN vr_avalist1:= vr_avalista;
               WHEN 2 THEN vr_avalist2:= vr_avalista;
             END CASE;
           END LOOP; --avalista1 e 2
           /* Terceiros */
           IF NOT vr_flgaval1 OR NOT vr_flgaval2 THEN
             /* Avalista de Emprestimo */
             FOR rw_crapavt IN cr_crapavt (pr_cdcooper => pr_cdcooper
                                          ,pr_tpctrato => 1
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrctremp => pr_nrctremp
                                          ,pr_nrcpfcgc => pr_nrdocnpj
                                          -- Parametro para Desconto de Titulo
                                          ,pr_nrctrlim => nvl(pr_nrctrlim,0)) LOOP
               --Se nao tem avalista1
               IF NOT vr_flgaval1 THEN
                 --Marcar avalista1 como true
                 vr_flgaval1:= TRUE;
                 --Carga Financeira
                 IF pr_opccarga = 'F' THEN
                   /* Avalista 1 terceiro Financeiro */
                   vr_avalist1:= rpad(nvl(fn_busca_cpfcgc (pr_nrcpfcgc => rw_crapavt.nrcpfcgc),' '),14,' ')||
                                   rpad('0',8,' ')||
                                   rpad(rw_crapavt.nmdavali,50,' ')||
                                   ' '||rpad('0',14,'0')||
                                   ' '||rpad('0',14,'0')||
                                   ' '||rpad('0',14,'0')||
                                   ' '||rpad('0',14,'0');
                 ELSIF pr_opccarga = 'R' THEN
                   vr_avalist1:= '1'||
                                 gene0002.fn_mask(pr_cdcooper,'9999')||
                                 gene0002.fn_mask(pr_cdorigem,'9999')||
                                 gene0002.fn_mask(pr_nrdconta,'99999999')||
                                 gene0002.fn_mask(pr_nrctremp,'99999999')||
                                 '  8'||
                                 rpad(' ',3,' ')||
                                 rpad(rw_crapavt.nmdavali,80,' ')||
                                 rpad('0',80,' ')||
                                 rpad(rw_crapavt.dsendres##1,80,' ')||
                                 rpad(rw_crapavt.nmbairro,80,' ')||
                                 rpad(rw_crapavt.nmcidade,40,' ')||
                                 rpad(rw_crapavt.cdufresd,5,' ')||
                                 rpad(rw_crapavt.nrcepend,10,' ')||
                                 rpad(fn_busca_cpfcgc (pr_nrcpfcgc => rw_crapavt.nrcpfcgc),25,' ')||
                                 rpad(' ',5,' ')||
                                 rpad(SubStr(rw_crapavt.nrfonres,1,13),31,' ')||
                                 rpad(rw_crapavt.nrendere,6,' ')||
                                 rpad(rw_crapavt.complend,40,' ')||
                 rpad(' ',59,' ')||
                                 rpad(NVL(to_char(rw_crapavt.dtnascto,'MMDDRRRR'), ' '),8,' ')||
                                 rpad(' ',127,' ')||
                                 'BRA'||
                                 gene0002.fn_mask(NVL(rw_crapavt.inpessoa,0),'9') ||
                                 rpad(' ',17,' ');
                 END IF;
               ELSIF NOT vr_flgaval2 THEN
                 --Marcar avalista2 como true
                 vr_flgaval2:= TRUE;
                 --Carga Financeira
                 IF pr_opccarga = 'F' THEN
                   /* Avalista 2 terceiro Financeiro */
                   vr_avalist2:= rpad(nvl(fn_busca_cpfcgc (pr_nrcpfcgc => rw_crapavt.nrcpfcgc),' '),14,' ')||
                                   rpad('0',8,' ')||
                                   rpad(rw_crapavt.nmdavali,50,' ')||
                                   ' '||rpad('0',14,'0')||
                                   ' '||rpad('0',14,'0')||
                                   ' '||rpad('0',14,'0')||
                                   ' '||rpad('0',14,'0');
                 ELSIF pr_opccarga = 'R' THEN
                   /* Avalista 2 terceiro Relations*/
                   vr_avalist2:= '1'||
                                 gene0002.fn_mask(pr_cdcooper,'9999')||
                                 gene0002.fn_mask(pr_cdorigem,'9999')||
                                 gene0002.fn_mask(pr_nrdconta,'99999999')||
                                 gene0002.fn_mask(pr_nrctremp,'99999999')||
                                 '  8'||
                                 rpad(' ',3,' ')||
                                 rpad(rw_crapavt.nmdavali,80,' ')||
                                 rpad('0',80,' ')||
                                 rpad(rw_crapavt.dsendres##1,80,' ')||
                                 rpad(rw_crapavt.nmbairro,80,' ')||
                                 rpad(rw_crapavt.nmcidade,40,' ')||
                                 rpad(rw_crapavt.cdufresd,5,' ')||
                                 rpad(rw_crapavt.nrcepend,10,' ')||
                                 rpad(fn_busca_cpfcgc (pr_nrcpfcgc => rw_crapavt.nrcpfcgc),25,' ')||
                                 rpad(' ',5,' ')||
                                 rpad(SubStr(rw_crapavt.nrfonres,1,13),31,' ')||
                                 rpad(rw_crapavt.nrendere,6,' ')||
                                 rpad(rw_crapavt.complend,40,' ')||
                 rpad(' ',59,' ')||
                                 rpad(NVL(to_char(rw_crapavt.dtnascto,'MMDDRRRR'), ' '),8,' ')||
                                 rpad(' ',127,' ')||
                                 'BRA'||
                                 gene0002.fn_mask(NVL(rw_crapavt.inpessoa,0),'9') ||
                                 rpad(' ',17,' ');
                 END IF;
               END IF;
             END LOOP; --cr_crapavt
           END IF;  --NOT vr_flgaval1 OR NOT vr_flgaval2

           --Carga Financeira
           IF pr_opccarga = 'F' THEN
             -- Se for desconto de t�tulos, ou n�o tem garantia ou a garantia � de avalista
             IF pr_cdorigem = 4 THEN
               IF trim(vr_avalist1) IS NULL AND
                  trim(vr_avalist2) IS NULL THEN
                 pc_monta_linha('0',592,pr_idarquivo);
               ELSE
               pc_monta_linha('1',592,pr_idarquivo);
               END IF;      
             --Se possuir Tipo Contrato
             ELSIF pr_flgtemlcr THEN
               --Normal e Sem Avalista
               IF pr_rw_craplcr.tpctrato = 1 AND
                  trim(vr_avalist1) IS NULL AND
                  trim(vr_avalist2) IS NULL THEN
                 pc_monta_linha('0',592,pr_idarquivo);
               ELSE
                 pc_monta_linha(pr_rw_craplcr.tpctrato,592,pr_idarquivo);
               END IF;
             ELSE
               pc_monta_linha('0',592,pr_idarquivo);
             END IF;
             --Tamanho informacao avalista
             IF nvl(LENGTH(vr_avalist1), 0) < 132 THEN
               vr_avalist1:= rpad(nvl(vr_avalist1, ' '),132,' ');
             END IF;
             --Tamanho informacao avalista
             IF nvl(LENGTH(vr_avalist2), 0) < 132 THEN
               vr_avalist2:= rpad(nvl(vr_avalist2, ' '),132,' ');
             END IF;
             --Escrever a Linha
             pc_monta_linha(vr_avalist1,593,pr_idarquivo);
             pc_monta_linha(vr_avalist2,725,pr_idarquivo);
             --Escrever Linha Arquivo
             IF pr_idarquivo NOT IN (1,3) THEN
               -- escrever somente se n�o for o arquivo de carga ou carga financeira, pois para este a escrita ser� na pc_gera_carga_mc
             pc_escreve_dado(NULL,pr_idarquivo,pr_dsdchave);
             END IF;
           ELSIF pr_opccarga = 'R' THEN /*Relations*/
             --Se o avalista1 esta preenchido
             IF trim(vr_avalist1) IS NOT NULL THEN
               --Montar a Linha
               pc_monta_linha(vr_avalist1,4,pr_idarquivo);
               --Escrever Linha Arquivo
             pc_escreve_dado(NULL,pr_idarquivo,pr_dsdchave);
             END IF;
             --Se o avalista2 esta preenchido
             IF trim(vr_avalist2) IS NOT NULL THEN
               --Incrementar Contador Linha
               pc_monta_linha(vr_avalist2,4,pr_idarquivo);
               --Escrever no arquivo
             pc_escreve_dado(NULL,pr_idarquivo,pr_dsdchave);
             END IF;
           END IF; --pr_opccarga = 'F'
           --Limpar variaveis de avalista
           vr_avalist1:= NULL;
           vr_avalist2:= NULL;

           --Relations
           IF pr_opccarga = 'R' THEN
             /* Avalista de Emprestimo */
             FOR rw_crapavt IN cr_crapavt (pr_cdcooper => pr_cdcooper
                                          ,pr_tpctrato => 9
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrctremp => pr_nrctremp
                                          ,pr_nrcpfcgc => pr_nrdocnpj
                                          -- Parametro para Desconto de Titulo
                                          ,pr_nrctrlim => nvl(pr_nrctrlim,0)) LOOP
               --Selecionar Associado
               OPEN cr_crapass_cpf (pr_cdcooper => rw_crapavt.cdcooper
                                   ,pr_nrcpfcgc => rw_crapavt.nrcpfcgc);
               --Posicionar Primeiro registro
               FETCH cr_crapass_cpf INTO rw_crapass_cpf;
               --Se encontrou
               vr_crapass:= cr_crapass_cpf%FOUND;
               --Fechar Cursor
               CLOSE cr_crapass_cpf;

             rw_crapcje1 := null;
               OPEN cr_crapcje1(pr_cdcooper,
                                rw_crapass_cpf.nrdconta);
               FETCH cr_crapcje1 INTO rw_crapcje1;
               CLOSE cr_crapcje1;

               --Inicializar Variaveis
               vr_interven:= NULL;
               vr_dtnasccj:= NULL;
               vr_tpendass:= 0;

               /* Interveniente Garantidor */
               --Incrementar Contador Linha
               pc_monta_linha('1',4,pr_idarquivo);
               pc_monta_linha(gene0002.fn_mask(pr_cdcooper,'9999'),5,pr_idarquivo);
               pc_monta_linha(gene0002.fn_mask(pr_cdorigem,'9999'),9,pr_idarquivo);
               pc_monta_linha(gene0002.fn_mask(pr_nrdconta,'99999999'),13,pr_idarquivo);
               pc_monta_linha(gene0002.fn_mask(pr_nrctremp,'99999999'),21,pr_idarquivo);
               pc_monta_linha('12',30,pr_idarquivo);
               pc_monta_linha(rw_crapavt.nmdavali,35,pr_idarquivo);
               --Se possui associado
               IF vr_crapass THEN
                 pc_monta_linha(rpad(rw_crapass_cpf.nrdconta,8,' '),115,pr_idarquivo);
               ELSE
                 pc_monta_linha(rpad('0',8,' '),115,pr_idarquivo);
               END IF;
               --Se possui associado
               IF vr_crapass THEN
                 --Verificar Tipo Endereco
                 IF rw_crapass_cpf.inpessoa = 1 THEN
                   vr_tpendass:= 10;
                 ELSE
                   vr_tpendass:= 9;
                 END IF;
                 /* Buscar o endereco*/
                 OPEN cr_crapenc (pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapass_cpf.nrdconta
                                 ,pr_idseqttl => 1
                                 ,pr_tpendass => vr_tpendass);
                 --Posicionar primeiro registro
                 FETCH cr_crapenc INTO rw_crapenc;
                 --Verificar se encontrou
                 vr_crapenc:= cr_crapenc%FOUND;
                 --Fechar Cursor
                 CLOSE cr_crapenc;
                 /* Telefone Residencial */
                 OPEN cr_craptfc (pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapass_cpf.nrdconta
                                 ,pr_idseqttl => 1
                                 ,pr_tptelefo => 1);  /* Residencial */
                 --Posicionar primeiro registro
                 FETCH cr_craptfc INTO rw_craptfc;
                 vr_craptfc:= cr_craptfc%FOUND;
                 --Fechar Cursor
                 CLOSE cr_craptfc;
                 /* Telefone Celular */
                 OPEN cr_craptfc (pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapass_cpf.nrdconta
                                 ,pr_idseqttl => 1
                                 ,pr_tptelefo => 2);  /* Celular */
                 --Posicionar primeiro registro
                 FETCH cr_craptfc INTO rw_crabtfc;
                 vr_crabtfc:= cr_craptfc%FOUND;
                 --Fechar Cursor
                 CLOSE cr_craptfc;
                 --Selecionar Primeiro Titular
                 OPEN cr_crapttl (pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapass_cpf.nrdconta
                                 ,pr_idseqttl => 1);
                 --Posicionar primeiro registro
                 FETCH cr_crapttl INTO rw_crapttl;
                 --Se Encontrou
                 vr_crapttl:= cr_crapttl%FOUND;
                 --Fechar Cursor
                 CLOSE cr_crapttl;
                 --Se possui endereco
                 IF vr_crapenc THEN
                   vr_interven:= vr_interven || rpad(rw_crapenc.dsendere,80,' ')||
                                                rpad(rw_crapenc.nmbairro,80,' ')||
                                                rpad(rw_crapenc.nmcidade,40,' ')||
                                                rpad(rw_crapenc.cdufende,5,' ')||
                                                rpad(rw_crapenc.nrcepend,10,' ');
                 ELSE
                   vr_interven:= vr_interven || rpad(' ',215,' ');
                 END IF;
                 --Concatenar o cpf/cnpj
                 vr_interven:= vr_interven|| rpad(fn_busca_cpfcgc (pr_nrcpfcgc => rw_crapass_cpf.nrcpfcgc),25,' ');
                 --Se possui telefone residencial
                 IF vr_craptfc THEN
                   vr_interven:= vr_interven||rpad(' ',5,' ')||
                                 rpad(rw_craptfc.nrdddtfc||
                                      rw_craptfc.nrtelefo,13,' '); /* Tel residencial */
                 ELSE
                   vr_interven:= vr_interven||rpad(' ',18,' ');
                 END IF;
                 --Se possui telefone celular
                 IF vr_crabtfc THEN
                   vr_interven:= vr_interven||
                                 rpad(rw_crabtfc.nrdddtfc||
                                      rw_crabtfc.nrtelefo,18,' '); /* Tel celular */
                 ELSE
                   vr_interven:= vr_interven||rpad(' ',18,' ');
                 END IF;
                 --Se possui endereco
                 IF vr_crapenc THEN
                   vr_interven:= vr_interven|| rpad(rw_crapenc.nrendere,6,' ')||
                                               rpad(rw_crapenc.complend,40,' ');
                 ELSE
                   vr_interven:= vr_interven||rpad(' ',46,' ');
                 END IF;
                 --Determinar estado civil
                 vr_dtnasccj:= ' ';

                 IF rw_crapass_cpf.inpessoa = 1 THEN
                   OPEN cr_gnetcvl (pr_cdcooper => rw_crapass_cpf.cdcooper
                                   ,pr_nrdconta => rw_crapass_cpf.nrdconta);
                   FETCH cr_gnetcvl INTO rw_gnetcvl;
                   IF cr_gnetcvl%FOUND THEN
                     IF rw_gnetcvl.cdestcvl = 1 THEN
                       vr_interven:= vr_interven || 'S'; /*Solteiro*/
                     ELSIF rw_gnetcvl.cdestcvl IN (2,3,4,8,9,11,12) THEN /*Casado*/
                       vr_interven:= vr_interven|| 'C';
                       --Se a data nascimento conjuge estiver preenchida
                   IF rw_crapcje1.dtnasccj IS NOT NULL THEN
                     vr_dtnasccj:= TO_CHAR(rw_crapcje1.dtnasccj,'MMDDYYYY');
                       END IF;
                     ELSIF rw_gnetcvl.cdestcvl = 5 THEN
                       vr_interven:= vr_interven || 'V'; /*Viuvo*/
                     ELSIF rw_gnetcvl.cdestcvl IN (6,7) THEN /*Divorciado*/
                       vr_interven:= vr_interven|| 'D';
                     ELSE
                       vr_interven:= vr_interven || chr(32);
                     END IF;
                   ELSE
                     vr_interven:= vr_interven || chr(32);
                   END IF;
                   CLOSE cr_gnetcvl;
                 ELSE
                   vr_interven:= vr_interven || chr(32);
                 END IF;

                 --Data Nascimento Avalista
                 vr_dtnascav:= to_char(rw_crapass_cpf.dtnasctl,'MMDDYYYY');
                 --Concatenar Informacoes
                 vr_interven:= vr_interven||rpad(rw_crapcje1.nmconjug,50,' ')||
                                            rpad(vr_dtnasccj,8,' ')||
                                            rpad(vr_dtnascav,8,' ');
                 --Se possui titulares
                 IF vr_crapttl THEN
                   --Nome pai titular
                   vr_interven:= vr_interven || rpad(substr(rw_crapttl.nmpaittl, 1, 50),50,' ');
                   --Nome mae titular
                   vr_interven:= vr_interven || rpad(substr(rw_crapttl.nmmaettl, 1, 50),50,' ');
                 ELSE
                   --Nome pai titular - VAZIO
                   vr_interven:= vr_interven||rpad(' ',50,' ');
                   --Nome mae titular - VAZIO
                   vr_interven:= vr_interven||rpad(' ',50,' ');
                 END IF;
                 /* Naturalidade */
                 IF vr_crapttl THEN
                   vr_interven:= vr_interven || rpad(rw_crapttl.dsnatura,25,' ')||
                                                rpad(rw_crapttl.cdufnatu,2,' ');
                 ELSE
                   vr_interven:= vr_interven ||rpad(' ',27,' ');
                 END IF;
                 --Concatenar BRA
                 vr_interven:= vr_interven|| 'BRA';
                 --Se possuir associado
                 IF vr_crapass THEN
                   vr_interven:= vr_interven ||gene0002.fn_mask(rw_crapass_cpf.inpessoa,'9')||
                                               rpad(upper(rw_crapass_cpf.tpdocptl),2,' ')||
                                               rpad(rw_crapass_cpf.nrdocptl,15,' ');
                 ELSE
                   vr_interven:= vr_interven ||rpad(' ',18,' ');
                 END IF;
                 --Montar Linha
                 pc_monta_linha(vr_interven,195,pr_idarquivo);
               ELSE
                 --Formatar Cpf/cnpj
                 vr_nrcpfcgc:= fn_busca_cpfcgc (rw_crapavt.nrcpfcgc);
                 --Montar Linha do Arquivo
                 pc_monta_linha(rw_crapavt.dsendres##1,195,pr_idarquivo);
                 pc_monta_linha(rw_crapavt.dsendres##2,275,pr_idarquivo);
                 pc_monta_linha(rw_crapavt.nmcidade,355,pr_idarquivo);
                 pc_monta_linha(rw_crapavt.cdufresd,395,pr_idarquivo);
                 pc_monta_linha(substr(rw_crapavt.nrcepend,1,10),400,pr_idarquivo);
                 pc_monta_linha(vr_nrcpfcgc,410,pr_idarquivo);
                 pc_monta_linha(substr(rw_crapavt.nrfonres,1,13),440,pr_idarquivo);
                 pc_monta_linha(rpad(rw_crapavt.nrendere,6,' '),471,pr_idarquivo);
                 pc_monta_linha(rw_crapavt.complend,477,pr_idarquivo);
                 pc_monta_linha('BRA'||rpad(' ',18,' '),711,pr_idarquivo);
               END IF; --vr_crapass
               --Gravar no Clob
             pc_escreve_dado(NULL,pr_idarquivo,pr_dsdchave);
             END LOOP; --cr_crapavt
           END IF; --pr_opccarga = 'R'
         EXCEPTION
           WHEN vr_exc_erro THEN
             pr_cdcritic:= vr_cdcritic;
             pr_dscritic:= vr_dscritic;
           WHEN OTHERS THEN
             --Variavel de erro recebe erro ocorrido
             pr_cdcritic:= 0;
             pr_dscritic:= 'Erro ao gerar avalista. Rotina pc_crps652.pc_gera_aval. '||sqlerrm;
         END;
       END pc_gera_aval;

       --Procedure Para Gerar a Carga de Pagamentos
       PROCEDURE pc_gera_carga_pagamentos (pr_cdcooper IN crapcyb.cdcooper%TYPE    --Codigo Cooperativa
                                          ,pr_cdorigem IN crapcyb.cdorigem%TYPE    --Codigo Origem
                                          ,pr_nrdconta IN crapcyb.nrdconta%TYPE    --Numero Conta
                                          ,pr_nrctremp IN crapcyb.nrctremp%TYPE    --Numero Contrato Emprestimo
                                          ,pr_vlrpagto IN NUMBER                   --Valor Pagamento
                                          ,pr_dtmvtlt2 IN VARCHAR2                 --Data Movimento
                                          ,pr_cdhistor IN VARCHAR2                 --Codigo Historico
                                          ,pr_dshistor IN VARCHAR2                 --Descticao Historico
                                        ,pr_dsdchave in varchar2                 --Chave de ordenacao
                                          ,pr_cdcritic OUT INTEGER                 --Codigo Critica
                                          ,pr_dscritic OUT VARCHAR2) IS            --Descricao Critica
       BEGIN
          
         DECLARE
           --Selecionar Cadastro Cyber
           CURSOR cr_crapcyc (pr_cdcooper IN crapcyc.cdcooper%type
                             ,pr_cdorigem IN crapcyc.cdorigem%type
                             ,pr_nrdconta IN crapcyc.nrdconta%type
                             ,pr_nrctremp IN crapcyc.nrctremp%type) IS
             SELECT tbcobran_assessorias.cdassessoria_cyber
             FROM crapcyc, tbcobran_assessorias
             WHERE tbcobran_assessorias.cdassessoria = crapcyc.cdassess
               AND crapcyc.cdcooper = pr_cdcooper
               AND DECODE(crapcyc.cdorigem,2,3,crapcyc.cdorigem) = pr_cdorigem
               AND crapcyc.nrdconta = pr_nrdconta
               AND crapcyc.nrctremp = pr_nrctremp;
           rw_crapcyc cr_crapcyc%ROWTYPE;

           --Variaveis de Excecao
           vr_exc_erro EXCEPTION;
           --Variaveis Erro
           vr_cdcritic INTEGER;
           vr_dscritic VARCHAR2(4000);
           vr_asscyber tbcobran_assessorias.cdassessoria_cyber%TYPE; -- Codigo de Assessoria CYBER
           vr_cdindice VARCHAR2(40) := '';

         BEGIN
           --Limpar parametros erro
           pr_cdcritic:= NULL;
           pr_dscritic:= NULL;

           -- Selecionar Cadastro Cyber
           OPEN cr_crapcyc(pr_cdcooper => pr_cdcooper
                          ,pr_cdorigem => pr_cdorigem
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctremp => pr_nrctremp);

           FETCH cr_crapcyc INTO rw_crapcyc;
           
           IF cr_crapcyc%FOUND THEN
             vr_asscyber:= rw_crapcyc.cdassessoria_cyber;
           ELSE
             vr_asscyber := 0;
           END IF;
           CLOSE cr_crapcyc;

           --Montar Linha para arquivo
           pc_monta_linha('500',1,6);
           pc_monta_linha('1',4,6);
           pc_monta_linha(gene0002.fn_mask(pr_cdcooper,'9999'),5,6);
           pc_monta_linha(gene0002.fn_mask(pr_cdorigem,'9999'),9,6);
           pc_monta_linha(gene0002.fn_mask(pr_nrdconta,'99999999'),13,6);
           pc_monta_linha(gene0002.fn_mask(pr_nrctremp,'99999999'),21,6);
           pc_monta_linha(pr_dtmvtlt2,30,6);
           pc_monta_linha(pr_dtmvtlt2,38,6);
           pc_monta_linha(to_char(pr_vlrpagto*100,'00000000000000'),46,6);
           
           vr_cdindice := LPAD(pr_cdcooper,10,'0') || LPAD(pr_cdorigem,10,'0') ||
                          LPAD(pr_nrdconta,10,'0') || LPAD(pr_nrctremp,10,'0');

           IF vr_tab_acordo.EXISTS(vr_cdindice) THEN
             pc_monta_linha(LPAD(vr_tab_acordo(vr_cdindice),15,'0'),76,6);
             pc_monta_linha(RPAD('PC',6,' '),91,6);
           ELSE  
             pc_monta_linha(SUBSTR(NVL(pr_dshistor,' '),1,15),76,6);
             --pc_monta_linha(gene0002.fn_mask(NVL(pr_cdhistor,0),'999999'),91,6);
             pc_monta_linha(NVL(pr_cdhistor,'PA'),91,6);
           END IF;          

           pc_monta_linha(gene0002.fn_mask(NVL(vr_asscyber,0),'99999999'),97,6); -- Codigo de Assessoria CYBER
           
           --Escrever no arquivo
         pc_escreve_dado(NULL,6,pr_dsdchave);

         EXCEPTION
           WHEN vr_exc_erro THEN
             pr_cdcritic:= vr_cdcritic;
             pr_dscritic:= vr_dscritic;
           WHEN OTHERS THEN
             --Variavel de erro recebe erro ocorrido
             pr_cdcritic:= 0;
             pr_dscritic:= 'Erro ao gerar carga de baixa. Rotina pc_crps652.pc_gera_carga_pagamentos. '||sqlerrm;
         END;
       END pc_gera_carga_pagamentos;

     -- Popular Categoria do BEM
       PROCEDURE pc_popula_categoria IS
       BEGIN
         --Limpar tabela
         vr_tab_categ.DELETE;
         --Popular Categorias
         vr_tab_categ('APARTAMENTO'):= 'APTO';
         vr_tab_categ('CAMINHAO'):= 'CAMINHAO';
         vr_tab_categ('CASA'):= 'CASA';
         vr_tab_categ('MOTO'):= 'MOTO';
         vr_tab_categ('TERRENO'):= 'TERRENO';
         vr_tab_categ('EQUIPAMENTO'):= 'EQUIP';
         vr_tab_categ('MAQUINA DE COSTURA'):= 'MAQCOSTURA';
         vr_tab_categ('AUTOMOVEL'):= 'AUTOMOVEL';
         vr_tab_categ('OUTROS VEICULOS'):= 'OUTROS VEICULOS';
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao carregar categorias. '||SQLERRM;
           RAISE vr_exc_saida;
       END;

       --Retornar a Categoria do Bem
       FUNCTION fn_busca_categoria_bem (pr_dscatbem IN VARCHAR2) RETURN VARCHAR2 IS
       BEGIN
         BEGIN
           --Retornar a categoria do Bem
           RETURN(vr_tab_categ(upper(pr_dscatbem)));
         EXCEPTION
           WHEN OTHERS THEN
             --Variavel de erro recebe erro ocorrido
             RETURN(NULL);
         END;
       END fn_busca_categoria_bem;

       --Procedure Para Gerar a Carga de Baixa
       PROCEDURE pc_gera_carga_baixa (pr_rw_crapcyb IN OUT cr_crapcyb%ROWTYPE
                                     ,pr_dtmvtolt IN DATE
                                     ,pr_dtmvtlt2 IN VARCHAR2
                                     ,pr_cdcritic OUT INTEGER
                                     ,pr_dscritic OUT VARCHAR2) IS
       BEGIN
         DECLARE
           --Variaveis de Excecao
           vr_exc_erro EXCEPTION;
           --Variaveis Erro
           vr_cdcritic INTEGER;
           vr_dscritic VARCHAR2(4000);
           vr_cdindice VARCHAR2(40) := '';
           
           --Selecionar Cadastro Cyber
           CURSOR cr_crapcyc1 (pr_cdcooper IN crapcyc.cdcooper%type
                              ,pr_cdorigem IN crapcyc.cdorigem%type
                              ,pr_nrdconta IN crapcyc.nrdconta%type
                              ,pr_nrctremp IN crapcyc.nrctremp%type) IS
             SELECT crapcyc.flgjudic
               FROM crapcyc
              WHERE cdcooper = pr_cdcooper
                AND nrdconta = pr_nrdconta
                AND nrctremp = pr_nrctremp
                AND DECODE(cdorigem,2,3,cdorigem) = pr_cdorigem;
           rw_crapcyc1 cr_crapcyc1%ROWTYPE;         
           
         BEGIN
           --Limpar parametros erro
           pr_cdcritic:= NULL;
           pr_dscritic:= NULL;

           vr_cdindice := LPAD(pr_rw_crapcyb.cdcooper,10,'0') || LPAD(pr_rw_crapcyb.cdorigem,10,'0') ||
                          LPAD(pr_rw_crapcyb.nrdconta,10,'0') || LPAD(pr_rw_crapcyb.nrctremp,10,'0');

           IF vr_tab_acordo.EXISTS(vr_cdindice) THEN
             vr_flacordo := 1;
           ELSE
             vr_flacordo := 0;
           END IF;

           -- Buscar os dados cadastrado na tela CADCYB
           OPEN cr_crapcyc1(pr_cdcooper => pr_rw_crapcyb.cdcooper
                           ,pr_cdorigem => pr_rw_crapcyb.cdorigem
                           ,pr_nrdconta => pr_rw_crapcyb.nrdconta
                           ,pr_nrctremp => pr_rw_crapcyb.nrctremp);
                           
           FETCH cr_crapcyc1 INTO rw_crapcyc1;           
            
             CLOSE cr_crapcyc1;             

           --Se a origem = Conta
           IF pr_rw_crapcyb.cdorigem = 1 THEN
             BEGIN
               -- Caso o contrato estiver em Cobran�a Judicial (rw_crapcyc1.flgjudic = 1) nao deve atualizar a data da baixa, apenas os valores para efetuar a regulariza��o do contrato
              /* UPDATE crapcyb SET crapcyb.dtdbaixa = case when nvl(rw_crapcyc1.flgjudic,0) = 0 and vr_flacordo = 0 then pr_dtmvtolt
                                                          else crapcyb.dtdbaixa end
                                 ,crapcyb.vlprapga = pr_rw_crapcyb.vlpreapg
                                 ,crapcyb.vlpreapg = 0
                                 ,crapcyb.vlsdevan = pr_rw_crapcyb.vlsdeved
                                 ,crapcyb.vlsdeved = 0
																 -- Acrescido pelo projeto 450 para correto tratamento do preju�zo de conta corrente (Reginaldo/AMcom)
																 ,crapcyb.vlsdprea = pr_rw_crapcyb.vlsdprej
																 ,crapcyb.vlsdprej = 0
																 ,crapcyb.flgpreju = 0
																 -- Fim (P450) */
               SELECT crapcyb.dtdbaixa
                        ,crapcyb.vlprapga
                        ,crapcyb.vlpreapg
                        ,crapcyb.vlsdevan
                        ,crapcyb.vlsdeved
												,crapcyb.vlsdprea
												,crapcyb.vlsdprej
												,crapcyb.flgpreju
               INTO pr_rw_crapcyb.dtdbaixa
                   ,pr_rw_crapcyb.vlprapga
                   ,pr_rw_crapcyb.vlpreapg
                   ,pr_rw_crapcyb.vlsdevan
                   ,pr_rw_crapcyb.vlsdeved
									 ,pr_rw_crapcyb.vlsdprea
									 ,pr_rw_crapcyb.vlsdprej
									 ,pr_rw_crapcyb.flgpreju
               FROM crapcyb
               WHERE crapcyb.rowid = pr_rw_crapcyb.rowid;
        /*       RETURNING crapcyb.dtdbaixa
                        ,crapcyb.vlprapga
                        ,crapcyb.vlpreapg
                        ,crapcyb.vlsdevan
                        ,crapcyb.vlsdeved
												,crapcyb.vlsdprea
												,crapcyb.vlsdprej
												,crapcyb.flgpreju */
               
             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao atualizar crapcyb. '||sqlerrm;
                 --Levantar Excecao
                 RAISE vr_exc_erro;
             END;
           ELSE
             BEGIN
               -- Caso o contrato estiver em Cobran�a Judicial (rw_crapcyc1.flgjudic = 1) nao deve atualizar a data da baixa, apenas os valores para efetuar a regulariza��o do contrato
            /*   UPDATE crapcyb SET crapcyb.dtdbaixa = case when nvl(rw_crapcyc1.flgjudic,0) = 0 and vr_flacordo = 0 then pr_dtmvtolt
                                                          else crapcyb.dtdbaixa end
                                 ,crapcyb.vlprapga = nvl(pr_rw_crapcyb.vlpreapg,0)
                                 ,crapcyb.vlpreapg = 0 */
               SELECT crapcyb.dtdbaixa
                        ,crapcyb.vlprapga
                        ,crapcyb.vlpreapg
               INTO pr_rw_crapcyb.dtdbaixa
                   ,pr_rw_crapcyb.vlprapga
                   ,pr_rw_crapcyb.vlpreapg
               FROM crapcyb
               WHERE crapcyb.rowid = pr_rw_crapcyb.rowid;
           /*    RETURNING crapcyb.dtdbaixa
                        ,crapcyb.vlprapga
                        ,crapcyb.vlpreapg */
               
             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao atualizar crapcyb. '||sqlerrm;
                 --Levantar Excecao
                 RAISE vr_exc_erro;
             END;

           END IF;

           -- Caso o contrato estiver em Cobran�a Judicial ou existir acordo, nao ser� enviado a baixa para o CYBER
           IF vr_flacordo = 1 or NVL(rw_crapcyc1.flgjudic,0) = 1 THEN
             RETURN;
           END IF;

           --Montar Linha para arquivo
           pc_monta_linha('302',1,7);
           pc_monta_linha('1',4,7);
           pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdcooper,'9999'),5,7);
           pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdorigem,'9999'),9,7);
           pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrdconta,'99999999'),13,7);
           pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrctremp,'99999999'),21,7);
           pc_monta_linha(pr_dtmvtlt2,30,7);
           
           --Escrever no Clob
         pc_escreve_dado(NULL,7,pr_rw_crapcyb.dsdchave);
           
         EXCEPTION
           WHEN vr_exc_erro THEN
             pr_cdcritic:= vr_cdcritic;
             pr_dscritic:= vr_dscritic;
           WHEN OTHERS THEN
             --Variavel de erro recebe erro ocorrido
             pr_cdcritic:= 0;
             pr_dscritic:= 'Erro ao gerar carga de baixa. Rotina pc_crps652.pc_gera_carga_baixa. '||sqlerrm;
         END;
       END pc_gera_carga_baixa;

       --Funcao para retornar a data do ultimo vencimento nao pago
       FUNCTION fn_data_vct_nao_pago(pr_cdcooper IN  crapcyb.cdcooper%TYPE, --> Codigo da cooperativa
                                     pr_nrdconta IN  crapcyb.nrdconta%TYPE, --> Numero da conta do associado
                                     pr_nrctremp IN  crapcyb.nrctremp%TYPE, --> Numero do contrato
                                     pr_cdorigem IN  crapcyb.cdorigem%TYPE, --> Origem da pendencia
                                     pr_dtmvtolt IN  DATE,                  --> Data do movimento
                                     pr_dscritic OUT VARCHAR2               --> Descricao do erro da rotina
                                     ) RETURN VARCHAR2 IS

          -- Cursor sobre os lancamentos de emprestimos
          CURSOR cr_craplem IS

            SELECT nvl(SUM(round(craplem.vllanmto / craplem.vlpreemp,4)*
                       DECODE(craplem.cdhistor,88,-1,
                                                 120,-1,
                                             507,-1,
                                                  1)),0) valor
              FROM craphis,
                   craplem
             WHERE craplem.cdcooper = pr_cdcooper
               AND craplem.nrdconta = pr_nrdconta
               AND craplem.nrctremp = pr_nrctremp
               AND craplem.vlpreemp > 0
               AND craplem.dtmvtolt >= TRUNC(pr_dtmvtolt,'MM')
               AND craphis.cdcooper = craplem.cdcooper
               AND craphis.cdhistor = craplem.cdhistor
               AND (craphis.indebcre = 'C' OR craphis.cdhistor IN (88, 120, 507));

          -- Cursor sobre os dados do contrato
          CURSOR cr_crapcyb IS
            SELECT crapepr.qtmdecat,  -- Quantidade de meses decorridos
                   crapepr.dtdpagto,
                   crapepr.dtultpag,
                   crawepr.dtvencto,
                   crawepr.dtaltniv,
                   crapepr.vlpreemp,
                   crapepr.qtprecal,
                   crawepr.cdlcremp,
                   crapcyb.vlpreapg, -- Valor em atraso
                   crapepr.qtpreemp, -- Quantidade de parcelas no contrato
                   crapcyb.dtdbaixa,
                   crapcyb.flgpreju,
                   crawepr.tpemprst,
                   crapcyb.dtdpagto dtdpagto_cyb,
                   (SELECT 1
                      FROM tbcrd_cessao_credito ces
                     WHERE ces.cdcooper     = crapcyb.cdcooper
                       AND ces.nrdconta     = crapcyb.nrdconta
                       AND ces.nrctremp     = crapcyb.nrctremp) fleprces
              FROM crawepr,
                   crapepr,
                   crapcyb
             WHERE crapcyb.cdcooper = pr_cdcooper
               AND crapcyb.nrdconta = pr_nrdconta
               AND crapcyb.nrctremp = pr_nrctremp
               AND crapcyb.cdorigem = pr_cdorigem
               AND crapepr.cdcooper = crapcyb.cdcooper
               AND crapepr.nrctremp = crapcyb.nrctremp
               AND crapepr.nrdconta = crapcyb.nrdconta
               AND crawepr.cdcooper = crapepr.cdcooper
               AND crawepr.nrctremp = crapepr.nrctremp
               AND crawepr.nrdconta = crapepr.nrdconta
         --AWAE: Adicionando Titulos Vencidos que devem ir para a CYBER
         UNION ALL
            SELECT 0 as qtmdecat  -- Quantidade de meses decorridos
                  ,tdb.dtdpagto
                  ,tdb.dtdpagto as dtultpag
                  ,tdb.dtvencto
                  ,null as dtaltniv
                  ,tdb.vltitulo as vlpreemp
                  ,0 as qtprecal
                  ,cyb.cdlcremp
                  ,cyb.vlpreapg -- Valor em atraso
                  ,1 as qtpreemp
                  ,cyb.dtdbaixa
                  ,cyb.flgpreju
                  ,null as tpemprst
                  ,cyb.dtdpagto dtdpagto_cyb
                  ,(SELECT 1
                      FROM tbcrd_cessao_credito ces
                     WHERE ces.cdcooper     = cyb.cdcooper
                       AND ces.nrdconta     = cyb.nrdconta
                       AND ces.nrctremp     = cyb.nrctremp) fleprces
              FROM craptdb tdb
             INNER JOIN tbdsct_titulo_cyber tcy
                ON tcy.cdcooper = tdb.cdcooper
               AND tcy.nrdconta = tdb.nrdconta
               AND tcy.nrborder = tdb.nrborder
               AND tcy.nrtitulo = tdb.nrtitulo
             INNER JOIN crapcyb cyb
                ON cyb.cdcooper = tcy.cdcooper
               AND cyb.nrdconta = tcy.nrdconta
               AND cyb.nrctremp = tcy.nrctrdsc
             WHERE tdb.insittit = 4 -- liberado
               AND cyb.cdcooper = pr_cdcooper
               AND cyb.nrdconta = pr_nrdconta
               AND cyb.nrctremp = pr_nrctremp
               AND cyb.cdorigem = pr_cdorigem;
          rw_crapcyb cr_crapcyb%ROWTYPE;



          vr_diavenci NUMBER(2); -- Dia do Vencimento
          vr_qtprecal     NUMBER(15,4);
          vr_qtprecal_lem NUMBER(15,4); -- Parcelas Pagas
          vr_qtmesatr     PLS_INTEGER; -- Quantidade de meses em atraso
          vr_excecao      VARCHAR2(1); -- Indicador de excecao no calculo da data
          vr_dtcalcul     DATE; -- Data do vencimento calculada


       BEGIN

         -- Inicializa a variavel de excecao como nao
         vr_excecao := 'N';

         -- Inicializa a quantidade de parcelas pagas
         vr_qtprecal_lem := 0;

         -- Busca os dados do emprestimo
         OPEN cr_crapcyb;
         FETCH cr_crapcyb INTO rw_crapcyb;
         IF cr_crapcyb%NOTFOUND THEN
           CLOSE cr_crapcyb;
           RETURN NULL;
         END IF;
         CLOSE cr_crapcyb;

         -- [Projeto 403] Se for desconto de t�tulos, retorna a data de vencimento do t�tulo
         IF pr_cdorigem = 4 THEN
           RETURN to_char(rw_crapcyb.dtvencto,'MMDDYYYY');
         END IF;
         
         -- Se for PP ou POS, deve-se fazer o calculo antigo
         IF rw_crapcyb.tpemprst IN (1,2) THEN
           --Data Pagamento preenchida e Data de Baixa nula
           IF rw_crapcyb.dtdpagto IS NOT NULL AND rw_crapcyb.dtdbaixa IS NULL THEN
             IF rw_crapcyb.cdlcremp = 100 AND rw_crapcyb.flgpreju = 1 THEN
               vr_dtcalcul:= rw_crapcyb.dtdpagto + 10;
             ELSE
               vr_dtcalcul:= rw_crapcyb.dtdpagto;
             END IF;
           ELSE
             vr_dtcalcul:= NULL;
           END IF;

           /* Caso for cessao, utilizaremos a data da primeira parcela nao paga do crapcyb */
           IF rw_crapcyb.fleprces = 1 THEN
             vr_dtcalcul:= rw_crapcyb.dtdpagto_cyb;
           END IF;

           -- Retorna a data calculada
           RETURN to_char(vr_dtcalcul,'MMDDYYYY');

         END IF;


          -- Efetua a busca sobre os lancamentos de emprestimos
         OPEN cr_craplem;
         FETCH cr_craplem INTO vr_qtprecal_lem;
         CLOSE cr_craplem;

         -- Calcula a quantidade de parcelas pagas
         vr_qtprecal := rw_crapcyb.qtprecal + vr_qtprecal_lem;

         -- Se possuir apenas uma parcela, entao a quantidade paga deve ser zero
         IF rw_crapcyb.qtpreemp = 1 THEN
           vr_qtprecal := 0;
         END IF;

         -- Se parcelas pagas for maior que as parcelasdo contrato, deve-se jogar a data atual como vencimento
         IF vr_qtprecal >= rw_crapcyb.qtpreemp THEN

           -- Atualiza a variavel de excecao como S
           vr_excecao := 'S';

           -- Busca o mesmo calculo que o campo FORMA PAGTO da tela atenda / prestacoes
           -- Este calculo ja existia no Cyber.
           IF rw_crapcyb.dtdpagto IS NOT NULL AND rw_crapcyb.dtdbaixa IS NULL THEN
             IF rw_crapcyb.cdlcremp = 100 AND rw_crapcyb.flgpreju = 1 THEN
               vr_dtcalcul := rw_crapcyb.dtdpagto + 10;
             ELSE
               vr_dtcalcul := rw_crapcyb.dtdpagto;
             END IF;
           ELSE
             vr_dtcalcul := NULL;
           END IF;

         -- Calcula a quantidade de meses em atraso
         ELSIF round(vr_qtprecal,0) - rw_crapcyb.qtmdecat >= 0 THEN
           -- Se o cooperado pagou mais parcelas do que o necessario, entao o cooperado adiantou parcelas,
           -- nao pagando algumas que deveriam ser pagas. Neste caso deve-se efetuar um calculo especial
           vr_qtmesatr := round(rw_crapcyb.vlpreapg / rw_crapcyb.vlpreemp,0) * -1;

           -- Se o valor dos meses em atraso for zeros e o vencimento for maior que
           -- o dia atual, entao deve-se subtrair 1 mes
           IF vr_qtmesatr = 0 AND
              to_char(pr_dtmvtolt,'dd') < to_char(rw_crapcyb.dtdpagto,'dd') THEN
             vr_qtmesatr := -1;
           END IF;

         -- Se possuir apenas uma parcela, entao nao deve-se somar meses.
         ELSIF rw_crapcyb.qtpreemp = 1 THEN
           -- Nao ira somar meses
           vr_qtmesatr := 0;
           -- Coloca como excecao
           vr_excecao := 'S';
           -- Coloca a data de ultimo vencimento igual ao da primeira parcela
           vr_dtcalcul := rw_crapcyb.dtdpagto;

         ELSE
           -- Calculo normal
           vr_qtmesatr := round(vr_qtprecal,0) - rw_crapcyb.qtmdecat;
         END IF;

         -- Busca o dia do vencimento que esta parametrizado no emprestimo
         vr_diavenci := to_char(rw_crapcyb.dtdpagto,'dd');

         -- Se nao possuir excecao efetua o calculo da data
         IF vr_excecao = 'N' THEN
           -- Busca o dia do vencimento
           vr_diavenci := to_char(rw_crapcyb.dtdpagto,'dd');
           vr_dtcalcul := add_months(pr_dtmvtolt,vr_qtmesatr);

           -- Se o dia atual for maior que o dia do vencimento, deve-se somar um mes
           IF to_char(pr_dtmvtolt,'dd') >= vr_diavenci AND
              vr_qtmesatr <> 0 THEN -- Colocado esta consistencia, pois se nao somar mes e fizer o calculo, vai dar uma data futura
             vr_dtcalcul := add_months(vr_dtcalcul,1);
           END IF;

           -- Este loop serve para os casos onde o dia de vencimento cair no final do mes e o mes calculado
           -- nao possuir o dia da data de vencimento
           LOOP
             BEGIN
               vr_dtcalcul := to_date(lpad(vr_diavenci,2,'0')||to_char(vr_dtcalcul,'mmyyyy'),'ddmmyyyy');
               EXIT;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_diavenci := vr_diavenci - 1;
             END;
           END LOOP;

         END IF;

         -- Retorna a data calculada
         RETURN to_char(vr_dtcalcul,'MMDDYYYY');

       EXCEPTION
         WHEN OTHERS THEN
           pr_dscritic := 'Erro rotina fn_data_vct_nao_pago: '||SQLERRM;
           RETURN NULL;
       END fn_data_vct_nao_pago;

       --Procedure para Gerar Carga MF
       PROCEDURE pc_gera_carga_MF (pr_idarquivo  IN INTEGER
                                  ,pr_cdcooper   IN crapcyb.cdcooper%type
                                  ,pr_cdfinemp   IN crapcyb.cdfinemp%type
                                  ,pr_cdlcremp   IN crapcyb.cdlcremp%type
                                  ,pr_nrdconta   IN crapcyb.nrdconta%type
                                  ,pr_nrctremp   IN crapcyb.nrctremp%type
                                  ,pr_cdorigem   IN crapcyb.cdorigem%type
                                  ,pr_nrdocnpj   IN crapcop.nrdocnpj%type
                                  ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
                                  ,pr_nmrescop   IN crapcop.nmrescop%TYPE
                                  ,pr_rw_crapcyb IN cr_crapcyb%ROWTYPE
                                  ,pr_flgtemlcr  OUT BOOLEAN
                                  ,pr_cdcritic   OUT INTEGER
                                  ,pr_dscritic   OUT VARCHAR2) IS
       BEGIN
         DECLARE
           /* Cursores Locais */

           --Selecionar Financiamento
           CURSOR cr_crapfin (pr_cdcooper IN crapfin.cdcooper%type
                             ,pr_cdfinemp IN crapfin.cdfinemp%type) IS
             SELECT crapfin.dsfinemp
             FROM crapfin
             WHERE crapfin.cdcooper = pr_cdcooper
             AND   crapfin.cdfinemp = pr_cdfinemp;
           rw_crapfin cr_crapfin%ROWTYPE;

           --Selecionar Saldo Conta
           CURSOR cr_crapsda (pr_cdcooper IN crapcop.cdcooper%type
                             ,pr_nrdconta IN crapass.nrdconta%type
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%type) IS
             SELECT crapsda.vlsdcota
                   ,crapsda.vllimcre
                   ,crapsda.vlsdrdpp
                   ,crapsda.vlsdrdca
                   ,crapsda.vllimutl
             FROM crapsda
             WHERE crapsda.cdcooper = pr_cdcooper
             AND   crapsda.nrdconta = pr_nrdconta
             AND   crapsda.dtmvtolt = pr_dtmvtolt;
           rw_crapsda cr_crapsda%ROWTYPE;

           --Selecionar Cadastro Cyber
           CURSOR cr_crapcyc (pr_cdcooper IN crapcyc.cdcooper%type
                             ,pr_cdorigem IN crapcyc.cdorigem%type
                             ,pr_nrdconta IN crapcyc.nrdconta%type
                             ,pr_nrctremp IN crapcyc.nrctremp%type) IS
             SELECT crapcyc.flgjudic
                   ,crapcyc.flextjud
                   ,crapcyc.flgehvip
             FROM crapcyc
             WHERE crapcyc.cdcooper = pr_cdcooper
             AND   crapcyc.cdorigem = pr_cdorigem
             AND   crapcyc.nrdconta = pr_nrdconta
             AND   crapcyc.nrctremp = pr_nrctremp;
           rw_crapcyc cr_crapcyc%ROWTYPE;

           --Variaveis Locais
           vr_cdorigem crapcyb.cdorigem%type;
           --Variaveis Controle
           vr_dsfinemp crapfin.dsfinemp%TYPE;
           vr_cdfinemp crapfin.cdfinemp%TYPE;
                      
           vr_crapfin BOOLEAN;
           vr_crapsda BOOLEAN;
           vr_craplcr BOOLEAN;
           vr_crapcyc BOOLEAN;
           --Variaveis de Excecao
           vr_exc_erro EXCEPTION;
           --Variaveis Erro
           vr_cdcritic INTEGER;
           vr_dscritic VARCHAR2(4000);
         BEGIN
           --Limpar parametros erro
           pr_cdcritic:= NULL;
           pr_dscritic:= NULL;

           --Selecionar Financiamento
           OPEN cr_crapfin (pr_cdcooper => pr_cdcooper
                           ,pr_cdfinemp => pr_cdfinemp);
           FETCH cr_crapfin INTO rw_crapfin;
           vr_crapfin:= cr_crapfin%FOUND;
           CLOSE cr_crapfin;

           --Selecionar Saldo Conta
           OPEN cr_crapsda (pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_dtmvtolt => pr_dtmvtolt);
           FETCH cr_crapsda INTO rw_crapsda;
           vr_crapsda:= cr_crapsda%FOUND;
           CLOSE cr_crapsda;

           --Selecionar Linha Credito ou de Desconto (4-Desconto de T�tulos)
           OPEN cr_craplcr (pr_cdcooper => pr_cdcooper
                           ,pr_cdlcremp => pr_cdlcremp
                           ,pr_cdorigem => pr_cdorigem);
           FETCH cr_craplcr INTO rw_craplcr;
           vr_craplcr:= cr_craplcr%FOUND;
           --Retornar para parametro se encontrou
           pr_flgtemlcr:= vr_craplcr;
           --Fechar Cursor
           CLOSE cr_craplcr;

           --Verificar Origem
           IF pr_cdorigem = 2 THEN
             vr_cdorigem:= 3;
           ELSE
             vr_cdorigem:= pr_cdorigem;
           END IF;

           --Selecionar Cadastro Cyber
           OPEN cr_crapcyc (pr_cdcooper => pr_cdcooper
                           ,pr_cdorigem => vr_cdorigem
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp);
           FETCH cr_crapcyc INTO rw_crapcyc;
           vr_crapcyc:= cr_crapcyc%FOUND;
           CLOSE cr_crapcyc;

           --Escrever no arquivo
           pc_monta_linha(rpad(pr_rw_crapcyb.cdcooper,4,' '),55,pr_idarquivo);
           pc_monta_linha(rpad(pr_nmrescop,30,' '),59,pr_idarquivo);
           pc_monta_linha(rpad(pr_rw_crapcyb.nrdconta,8,' '),89,pr_idarquivo);
           pc_monta_linha(pr_rw_crapcyb.cdorigem,97,pr_idarquivo);
           pc_monta_linha(rpad(pr_rw_crapcyb.nrctremp,8,' '),98,pr_idarquivo);
          --Melhoria 19
           pc_monta_linha(rpad(pr_rw_crapcyb.cdlcremp,4,' '),106,pr_idarquivo);

           --Se tem linha credito
           IF vr_craplcr THEN
             --Melhoria 19
             pc_monta_linha(rpad(rw_craplcr.dslcremp,29,' '),110,pr_idarquivo);
           END IF;

           pc_monta_linha(to_char((pr_rw_crapcyb.vlsdeved + nvl(pr_rw_crapcyb.vlmrapar, 0) + nvl(pr_rw_crapcyb.vlmtapar, 0) + nvl(pr_rw_crapcyb.vliofcpl, 0))*100,'00000000000000'),139,pr_idarquivo);
           pc_monta_linha(to_char(pr_rw_crapcyb.vljura60*100,'00000000000000'),154,pr_idarquivo);
           pc_monta_linha(to_char(pr_rw_crapcyb.vlpreemp*100,'00000000000000'),169,pr_idarquivo);
           pc_monta_linha(lpad(pr_rw_crapcyb.qtpreatr,3,' '),184,pr_idarquivo);
           pc_monta_linha(lpad(pr_rw_crapcyb.qtdiaatr,4,' '),187,pr_idarquivo);

           --Se data risco estiver preenchida
           IF pr_rw_crapcyb.dtdrisan IS NOT NULL THEN
             vr_dtdrisan:= to_char(pr_rw_crapcyb.dtdrisan,'MMDDYYYY');
           ELSE
             vr_dtdrisan:= NULL;
           END IF;

           pc_monta_linha(to_char(pr_rw_crapcyb.vlpreapg*100,'00000000000000'),191,pr_idarquivo);
           pc_monta_linha(to_char(pr_rw_crapcyb.vldespes*100,'00000000000000'),206,pr_idarquivo);
           pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.vlperris*100,'99999'),221,pr_idarquivo);
           pc_monta_linha(rpad(pr_rw_crapcyb.cdagenci,3,' '),226,pr_idarquivo);
           pc_monta_linha(rpad(pr_rw_crapcyb.nivrisat,2,' '),229,pr_idarquivo);
           pc_monta_linha(rpad(pr_rw_crapcyb.nivrisan,2,' '),231,pr_idarquivo);
           pc_monta_linha(rpad(nvl(vr_dtdrisan,' '),8,' '),233,pr_idarquivo);
           pc_monta_linha(lpad(nvl(pr_rw_crapcyb.qtdiaris,0),5,' '),241,pr_idarquivo);
           pc_monta_linha(lpad(nvl(pr_rw_crapcyb.qtdiaatr,0),5,' '),246,pr_idarquivo);

           --Se possui grupo economico
           IF pr_rw_crapcyb.flgrpeco = 1 THEN
             pc_monta_linha('S',251,pr_idarquivo);
           ELSE
             pc_monta_linha('N',251,pr_idarquivo);
           END IF;

           --Se ja estiver efetivado
           IF pr_rw_crapcyb.dtefetiv IS NOT NULL THEN
             -- Vamos verificar se eh prejuizo de conta
             IF pr_rw_crapcyb.cdlcremp = 100 AND pr_rw_crapcyb.flgpreju = 1 AND pr_rw_crapcyb.dtdpagto IS NOT NULL THEN
               vr_dtefetiv:= to_char(pr_rw_crapcyb.dtdpagto,'MMDDYYYY');
             ELSE
               vr_dtefetiv:= to_char(pr_rw_crapcyb.dtefetiv,'MMDDYYYY');
             END IF;
           ELSE
             vr_dtefetiv:= NULL;
           END IF;

           pc_monta_linha(rpad(nvl(vr_dtefetiv,' '),8,' '),252,pr_idarquivo);
           pc_monta_linha(to_char(pr_rw_crapcyb.vlemprst*100,'00000000000000'),260,pr_idarquivo);
           pc_monta_linha(lpad(nvl(pr_rw_crapcyb.qtpreemp,0),3,' '),275,pr_idarquivo);
           pc_monta_linha(to_char(pr_rw_crapcyb.vlprepag*100,'00000000000000'),278,pr_idarquivo);
           pc_monta_linha(to_char(pr_rw_crapcyb.vlpreapg*100,'00000000000000'),293,pr_idarquivo);

           -- Se for do tipo CONTA CORRENTE ou PREJUIZO, faz o calculo antigo
           IF pr_cdorigem = 1 OR pr_rw_crapcyb.flgpreju = 1 THEN
             --Data Pagamento preenchida e Data de Baixa nula
             IF pr_rw_crapcyb.dtdpagto IS NOT NULL AND pr_rw_crapcyb.dtdbaixa IS NULL THEN
               IF pr_rw_crapcyb.cdlcremp = 100 AND pr_rw_crapcyb.flgpreju = 1 THEN
                 vr_dtdpagto:= to_char(pr_rw_crapcyb.dtdpagto + 10,'MMDDYYYY');
               ELSE
                 vr_dtdpagto:= to_char(pr_rw_crapcyb.dtdpagto,'MMDDYYYY');
               END IF;
             ELSE
               vr_dtdpagto:= NULL;
             END IF;
           ELSE
             -- [Projeto 403] Para desconto de t�tulos, busca o vencimento do t�tulo comom data de pagamento
             IF (pr_rw_crapcyb.dtdpagto IS NOT NULL AND pr_rw_crapcyb.dtdbaixa IS NULL) OR pr_rw_crapcyb.cdorigem = 4 THEN 
                -- Busca a data de ultimo vencimento nao pago
                vr_dtdpagto := fn_data_vct_nao_pago(pr_cdcooper => pr_cdcooper,
                                                 pr_nrdconta => pr_nrdconta,
                                                 pr_nrctremp => pr_nrctremp,
                                                 pr_cdorigem => pr_cdorigem,
                                                 pr_dtmvtolt => pr_dtmvtolt,
                                                 pr_dscritic => vr_dscritic);
                IF vr_dscritic IS NOT NULL THEN
                   RAISE vr_exc_saida;
                END IF;
             ELSE
                vr_dtdpagto:= NULL;
             END IF;
           END IF;

           -- [Projeto 403] Ajuste no c�digo e na descri��o da finalidade
           IF pr_cdorigem = 4 THEN
             vr_cdfinemp := 0;
             vr_dsfinemp := 'Border� de desconto de t�tulo';
           ELSE
             vr_cdfinemp := pr_rw_crapcyb.cdfinemp;
             vr_dsfinemp := rw_crapfin.dsfinemp;
           END IF;
           
           pc_monta_linha(rpad(nvl(vr_dtdpagto,' '),8,' '),308,pr_idarquivo);
           pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.txmensal*1000000000,'999999999999'),316,pr_idarquivo);
           pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.txdiaria*100*1000000000,'999999999999'),328,pr_idarquivo);
           pc_monta_linha(lpad(pr_rw_crapcyb.qtprepag,3,' '),340,pr_idarquivo);
           pc_monta_linha(lpad(pr_rw_crapcyb.qtmesdec,3,' '),343,pr_idarquivo);
           pc_monta_linha(rpad(vr_cdfinemp,3,' '),346,pr_idarquivo);

           --Tem financiamento
           IF vr_crapfin OR pr_cdorigem = 4 THEN
             pc_monta_linha(rpad(nvl(vr_dsfinemp,' '),30,' '),349,pr_idarquivo);
           END IF;
           --Data prejuizo preenchida
           IF pr_rw_crapcyb.dtprejuz IS NOT NULL THEN
             vr_dtprejuz:= to_char(pr_rw_crapcyb.dtprejuz,'MMDDYYYY');
           ELSE
             vr_dtprejuz:= NULL;
           END IF;

           pc_monta_linha(rpad(nvl(vr_dtprejuz,' '),8,' '),379,pr_idarquivo);
           pc_monta_linha(to_char(pr_rw_crapcyb.vlsdprej*100,'00000000000000'),387,pr_idarquivo);
           --Possui Contrato Cyber
           IF vr_crapcyc AND rw_crapcyc.flgjudic = 1 THEN
             pc_monta_linha('S',402,pr_idarquivo);
           ELSE
             pc_monta_linha('N',402,pr_idarquivo);
           END IF;
           --Extra Judicial
           IF vr_crapcyc AND rw_crapcyc.flextjud = 1 THEN
             pc_monta_linha('S',403,pr_idarquivo);
           ELSE
             pc_monta_linha('N',403,pr_idarquivo);
           END IF;
           --Vip
           IF vr_crapcyc AND rw_crapcyc.flgehvip = 1 THEN
             pc_monta_linha('S',404,pr_idarquivo);
           ELSE
             pc_monta_linha('N',404,pr_idarquivo);
           END IF;
           --Prejuizo
           IF pr_rw_crapcyb.flgpreju = 1 THEN
             pc_monta_linha('S',405,pr_idarquivo);
           ELSE
             pc_monta_linha('N',405,pr_idarquivo);
           END IF;
           --Prejuizo
           IF pr_rw_crapcyb.flgresid = 1 THEN
             pc_monta_linha('S',406,pr_idarquivo);
           ELSE
             pc_monta_linha('N',406,pr_idarquivo);
           END IF;
           --Consignado
           IF pr_rw_crapcyb.flgconsg = 1 THEN
             pc_monta_linha('S',407,pr_idarquivo);
           ELSE
             pc_monta_linha('N',407,pr_idarquivo);
           END IF;
           --Pagto Folha
           IF pr_rw_crapcyb.flgfolha = 1 THEN
             pc_monta_linha('S',408,pr_idarquivo);
           ELSE
             pc_monta_linha('N',408,pr_idarquivo);
           END IF;
           --Tem saldo
           IF vr_crapsda THEN
             pc_monta_linha(to_char(rw_crapsda.vlsdcota*100,'00000000000000'),409,pr_idarquivo);
             pc_monta_linha(to_char(rw_crapsda.vllimcre*100,'00000000000000'),424,pr_idarquivo);
             pc_monta_linha(to_char(rw_crapsda.vlsdrdpp*100,'00000000000000'),439,pr_idarquivo);
             pc_monta_linha(to_char(rw_crapsda.vlsdrdca*100,'00000000000000'),454,pr_idarquivo);
             pc_monta_linha(rpad(' ',14,' ')||'0', 469, pr_idarquivo);
             pc_monta_linha(rpad(' ',14,' ')||'0', 484, pr_idarquivo);
             pc_monta_linha(rpad(' ',14,' ')||'0', 499, pr_idarquivo);
             pc_monta_linha(to_char(rw_crapsda.vllimutl*100,'00000000000000'),514,pr_idarquivo);
           END IF;

           -- Se for um Titulo de Bordero de Desconto de Titulo, gera as linhas
           -- especificas dele.
           IF pr_rw_crapcyb.cdorigem = 4 THEN
             pc_monta_linha(pr_rw_crapcyb.nrdocmto,567,pr_idarquivo);
             pc_monta_linha(pr_rw_crapcyb.nrborder,576,pr_idarquivo);
             pc_monta_linha(pr_rw_crapcyb.nrctrlim,584,pr_idarquivo);
           END IF;
           --Gerar Avalista
           pc_gera_aval (pr_idarquivo  => pr_idarquivo
                        ,pr_opccarga   => 'F'
                        ,pr_cdcooper   => pr_cdcooper
                        ,pr_nrdconta   => pr_nrdconta
                        ,pr_nrctremp   => pr_nrctremp
                        ,pr_cdorigem   => pr_cdorigem
                        ,pr_nrdocnpj   => pr_nrdocnpj
                        ,pr_dtmvtolt   => pr_dtmvtolt
                        ,pr_flgtemlcr  => vr_craplcr
                        ,pr_nrctrlim   => nvl(pr_rw_crapcyb.nrctrlim,0) -- Desconto de T�tulo: Busca de Avalista Terceiros
                        ,pr_rw_craplcr => rw_craplcr
                      ,pr_dsdchave   => pr_rw_crapcyb.dsdchave
                        ,pr_cdcritic   => vr_cdcritic
                        ,pr_dscritic   => vr_dscritic);
           --Se ocorreu erro
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_erro;
           END IF;
         EXCEPTION
           WHEN vr_exc_erro THEN
             pr_cdcritic:= vr_cdcritic;
             pr_dscritic:= vr_dscritic;
           WHEN OTHERS THEN
             --Variavel de erro recebe erro ocorrido
             pr_cdcritic:= 0;
             pr_dscritic:= 'Erro na rotina pc_crps652.pc_gera_carga_MF. '||sqlerrm;
         END;
       END pc_gera_carga_MF;

       --Procedure para Gerar Carga MF - Complementar
       PROCEDURE pc_gera_carga_MF_complem (pr_idarquivo IN INTEGER
                                          ,pr_cdcooper  IN crapcyb.cdcooper%TYPE
                                          ,pr_nrdconta  IN crapcyb.nrdconta%TYPE
                                          ,pr_nrctremp  IN crapcyb.nrctremp%TYPE
                                          ,pr_cdorigem  IN crapcyb.cdorigem%TYPE
                                          ,pr_cdcritic OUT INTEGER
                                          ,pr_dscritic OUT VARCHAR2) IS
       BEGIN
         DECLARE
           /* Cursores Locais */
           --Informa��es do Emprestimo
           CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                            ,pr_nrdconta IN crapepr.nrdconta%TYPE
                            ,pr_nrctremp IN crapepr.nrctremp%TYPE
                            ,pr_cdorigem IN INTEGER) IS
              SELECT * FROM              
             (SELECT crapepr.cdagenci
                   ,crapepr.tpemprst
                   ,crawepr.idquapro
                   ,crawepr.dtdpagto
                   ,crawepr.percetop
                   ,3 as cdorigem
               FROM crapepr, crawepr
              WHERE crawepr.cdcooper = crapepr.cdcooper
                AND crawepr.nrdconta = crapepr.nrdconta
                AND crawepr.nrctremp = crapepr.nrctremp
                AND crapepr.cdcooper = pr_cdcooper
                AND crapepr.nrdconta = pr_nrdconta
                AND crapepr.nrctremp = pr_nrctremp
              UNION ALL
              -- Desconto de Titulos
            SELECT bdt.cdagenci
                  ,null as tpemprst
                  ,null as idquapro
                  ,tdb.dtvencto as dtdpagto
                  ,null as percetop
                  ,4 as cdorigem
              FROM craptdb tdb
             INNER JOIN crapbdt bdt
                ON bdt.cdcooper = tdb.cdcooper
               AND bdt.nrborder = tdb.nrborder
               AND bdt.nrdconta = tdb.nrdconta
             INNER JOIN tbdsct_titulo_cyber tcy
                ON tcy.cdcooper = tdb.cdcooper
               AND tcy.nrdconta = tdb.nrdconta
               AND tcy.nrborder = tdb.nrborder
               AND tcy.nrtitulo = tdb.nrtitulo
             WHERE tcy.cdcooper = pr_cdcooper
               AND tcy.nrdconta = pr_nrdconta
               AND tcy.nrctrdsc = pr_nrctremp) cyb
               WHERE cyb.cdorigem = pr_cdorigem;
           rw_crapepr cr_crapepr%ROWTYPE;

           --Informa��es do Rating
           CURSOR cr_crapnrc(pr_cdcooper IN crapnrc.cdcooper%TYPE
                            ,pr_nrdconta IN crapnrc.nrdconta%TYPE) IS
             SELECT crapnrc.indrisco
               FROM crapnrc
              WHERE crapnrc.cdcooper = pr_cdcooper
                AND crapnrc.nrdconta = pr_nrdconta
                AND crapnrc.insitrat = 2;
           rw_crapnrc cr_crapnrc%ROWTYPE;

           --Informa��es de Devolu��es
           CURSOR cr_crapneg(pr_cdcooper IN crapneg.cdcooper%TYPE
                            ,pr_nrdconta IN crapneg.nrdconta%TYPE) IS
             SELECT COUNT(*) qtdevolu
               FROM crapneg
              WHERE crapneg.cdcooper = pr_cdcooper
                AND crapneg.nrdconta = pr_nrdconta
                AND crapneg.cdhisest = 1
                AND crapneg.cdobserv IN(11,12,13);
           rw_crapneg cr_crapneg%ROWTYPE;

           --Informa��es de Estouros
           CURSOR cr_crapsld(pr_cdcooper IN crapsld.cdcooper%TYPE
                            ,pr_nrdconta IN crapsld.nrdconta%TYPE) IS
             SELECT crapsld.qtddtdev
               FROM crapsld
              WHERE crapsld.cdcooper = pr_cdcooper
                AND crapsld.nrdconta = pr_nrdconta;
           rw_crapsld cr_crapsld%ROWTYPE;

           --Informa��es de Estouros
           --Alterado a tabela CRAPGRP para TBCC_GRUPO_ECONOMICO
           CURSOR cr_crapgrp(pr_cdcooper IN tbcc_grupo_economico_integ.cdcooper%TYPE
                                    ,pr_nrdconta IN tbcc_grupo_economico_integ.nrdconta%TYPE) IS
           SELECT dsdrisgp
             FROM (SELECT int.nrdconta
                         ,int.idgrupo
                         ,DECODE(p.inrisco_grupo,10,'HH',9,'H',8,'G',7,'F',6,'E',5,'D',4,'C',3,'B','A')  dsdrisgp
                     FROM tbcc_grupo_economico_integ INT
                         ,tbcc_grupo_economico p
                    WHERE int.dtexclusao IS NULL
                      AND int.cdcooper = pr_cdcooper
                      AND int.idgrupo  = p.idgrupo
                    UNION
                   SELECT pai.nrdconta
                         ,pai.idgrupo
                         ,DECODE(pai.inrisco_grupo,10,'HH',9,'H',8,'G',7,'F',6,'E',5,'D',4,'C',3,'B','A')  dsdrisgp
                     FROM tbcc_grupo_economico       pai
                        , crapass                    ass
                        , tbcc_grupo_economico_integ int
                    WHERE ass.cdcooper = pai.cdcooper
                      AND ass.nrdconta = pai.nrdconta
                      AND int.idgrupo  = pai.idgrupo
                      AND int.dtexclusao is null
                      AND ass.cdcooper = pr_cdcooper
                      AND int.cdcooper = pr_cdcooper
                 ) dados
            WHERE dados.nrdconta = pr_nrdconta
            ORDER BY idgrupo;
           rw_crapgrp cr_crapgrp%ROWTYPE;

           --Selecionar Cadastro Cyber
           CURSOR cr_crapcyc (pr_cdcooper IN crapcyc.cdcooper%type
                             ,pr_cdorigem IN crapcyc.cdorigem%type
                             ,pr_nrdconta IN crapcyc.nrdconta%type
                             ,pr_nrctremp IN crapcyc.nrctremp%type) IS
             SELECT tbcobran_assessorias.cdassessoria_cyber
             FROM crapcyc, tbcobran_assessorias
             WHERE tbcobran_assessorias.cdassessoria = crapcyc.cdassess
               AND crapcyc.cdcooper = pr_cdcooper
               AND DECODE(crapcyc.cdorigem,2,3,crapcyc.cdorigem) = pr_cdorigem
               AND crapcyc.nrdconta = pr_nrdconta
               AND crapcyc.nrctremp = pr_nrctremp;
           rw_crapcyc cr_crapcyc%ROWTYPE;

           --Informa��es
           vr_cdagenci crapepr.cdagenci%TYPE; -- PA onde foi digitado o contrato de emprestimo
           vr_idquapro crawepr.idquapro%TYPE; -- Qualifica��o da Opera��o
           vr_indrisco crapnrc.indrisco%TYPE; -- Rating
           vr_qtdevolu INTEGER;               -- Devolu��es
           vr_qtddtdev crapsld.qtddtdev%TYPE; -- Estouros
           vr_inlbacen crapass.inlbacen%TYPE; -- CCF
           vr_inrisctl crapass.inrisctl%TYPE; -- Risco do Cooperado
           vr_dsdrisgp crapgrp.dsdrisgp%TYPE; -- Risco do Grupo Econ�mico
           vr_dtdpagto crapepr.dtdpagto%TYPE; -- Data de Pagamento
           vr_tpemprst crapepr.tpemprst%TYPE; -- Produto
           vr_vldocet  crawepr.percetop%TYPE; -- CET
           vr_asscyber tbcobran_assessorias.cdassessoria_cyber%TYPE; -- Codigo de Assessoria CYBER

           --Variaveis de Excecao
           vr_exc_erro EXCEPTION;
           --Variaveis Erro
           vr_cdcritic INTEGER;
           vr_dscritic VARCHAR2(4000);
         BEGIN
           --Limpar parametros erro
           pr_cdcritic:= NULL;
           pr_dscritic:= NULL;

           IF vr_tab_crapass.EXISTS(pr_nrdconta) THEN
             vr_inlbacen:= vr_tab_crapass(pr_nrdconta).inlbacen;
             vr_inrisctl:= vr_tab_crapass(pr_nrdconta).inrisctl;
           END IF;

           -- Buscar as informa��es do emprestimo
           OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctremp => pr_nrctremp
                          ,pr_cdorigem => pr_cdorigem);
           FETCH cr_crapepr INTO rw_crapepr;
           IF cr_crapepr%FOUND THEN
             vr_cdagenci:= rw_crapepr.cdagenci;
             vr_dtdpagto:= rw_crapepr.dtdpagto;
             vr_tpemprst:= rw_crapepr.tpemprst;
             vr_idquapro:= rw_crapepr.idquapro;
             vr_vldocet := rw_crapepr.percetop;
           END IF;
           CLOSE cr_crapepr;

           -- Buscar as informa��es do Rating
           OPEN cr_crapnrc(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta);
           FETCH cr_crapnrc INTO rw_crapnrc;
           IF cr_crapnrc%FOUND THEN
             IF rw_crapnrc.indrisco = 'AA' THEN
               vr_indrisco:= 'A';
             ELSE
               vr_indrisco:= rw_crapnrc.indrisco;
             END IF;
           END IF;
           CLOSE cr_crapnrc;

           -- Buscar as informa��es do Rating
           OPEN cr_crapneg(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta);
           FETCH cr_crapneg INTO rw_crapneg;
           IF cr_crapneg%FOUND THEN
             vr_qtdevolu:= rw_crapneg.qtdevolu;
           END IF;
           CLOSE cr_crapneg;

           -- Buscar as informa��es de Estouros
           OPEN cr_crapsld(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta);
           FETCH cr_crapsld INTO rw_crapsld;
           IF cr_crapsld%FOUND THEN
             vr_qtddtdev:= rw_crapsld.qtddtdev;
           END IF;
           CLOSE cr_crapsld;

           -- Buscar as informa��es do Risco do Grupo economico
           OPEN cr_crapgrp(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta);
           FETCH cr_crapgrp INTO rw_crapgrp;
           IF cr_crapgrp%FOUND THEN
             vr_dsdrisgp:= rw_crapgrp.dsdrisgp;
           END IF;
           CLOSE cr_crapgrp;

           -- Selecionar Cadastro Cyber
           OPEN cr_crapcyc(pr_cdcooper => pr_cdcooper
                          ,pr_cdorigem => pr_cdorigem
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctremp => pr_nrctremp);

           FETCH cr_crapcyc INTO rw_crapcyc;
           
           IF cr_crapcyc%FOUND THEN
             vr_asscyber:= rw_crapcyc.cdassessoria_cyber;
           ELSE
             vr_asscyber := 0;
           END IF;
           CLOSE cr_crapcyc;

           -- Novos campos para o arquivo de _carga_in e _financeiro_in (Melhoria 13)
           IF pr_idarquivo = 3 THEN
             -- Quando for o arquivo _financeiro_in (pr_idarquivo = 3)
             pc_monta_linha(RPad(NVL(vr_cdagenci,0),5,' '),857,pr_idarquivo); -- Pa onde o contrato foi digitado
             pc_monta_linha(RPad(NVL(vr_idquapro,0),2,' '),862,pr_idarquivo); -- Qualifica��o da Opera��o
             pc_monta_linha(RPad(NVL(vr_indrisco,' '),3,' '),864,pr_idarquivo); -- Rating
             pc_monta_linha(gene0002.fn_mask(vr_qtdevolu,'999'),867,pr_idarquivo); -- Devolu��es
             pc_monta_linha(gene0002.fn_mask(vr_qtddtdev,'99999'),870,pr_idarquivo); -- Estouros
             pc_monta_linha(RPad(NVL(vr_inlbacen,0),1,' '),875,pr_idarquivo); -- No CCF
             pc_monta_linha(RPad(NVL(vr_inrisctl,' '),3,' '),876,pr_idarquivo); -- Risco Cooperado
             pc_monta_linha(RPad(NVL(vr_dsdrisgp,' '),3,' '),879,pr_idarquivo); -- Risco Grupo Econ�mico
             pc_monta_linha(RPad(to_char(vr_dtdpagto,'MMDDYYYY'),8,' '),882,pr_idarquivo);-- Data pagamento
             pc_monta_linha(RPad(NVL(vr_tpemprst,0),1,' '),890,pr_idarquivo); -- Produto
             pc_monta_linha(gene0002.fn_mask(NVL(vr_vldocet,0) * 100,'99999'),891,pr_idarquivo); -- CET
             pc_monta_linha(LPAD(TO_CHAR(vr_asscyber),8,'0') ,896,pr_idarquivo); -- Codigo da Assessoria CYBER
           ELSIF pr_idarquivo = 1 THEN
             -- Quando for o arquivo _carga_in (pr_idarquivo = 1)
             pc_monta_linha(RPad(NVL(vr_cdagenci,0),5,' '),4493,pr_idarquivo); -- Pa onde o contrato foi digitado
             pc_monta_linha(RPad(NVL(vr_idquapro,0),2,' '),4498,pr_idarquivo); -- Qualifica��o da Opera��o
             pc_monta_linha(RPad(NVL(vr_indrisco,' '),3,' '),4500,pr_idarquivo); -- Rating
             pc_monta_linha(gene0002.fn_mask(vr_qtdevolu,'999'),4503,pr_idarquivo); -- Devolu��es
             pc_monta_linha(gene0002.fn_mask(vr_qtddtdev,'99999'),4506,pr_idarquivo); -- Estouros
             pc_monta_linha(RPad(NVL(vr_inlbacen,0),1,' '),4511,pr_idarquivo); -- No CCF
             pc_monta_linha(RPad(NVL(vr_inrisctl,' '),3,' '),4512,pr_idarquivo); -- Risco Cooperado
             pc_monta_linha(RPad(NVL(vr_dsdrisgp,' '),3,' '),4515,pr_idarquivo); -- Risco Grupo Econ�mico
             pc_monta_linha(RPad(to_char(vr_dtdpagto,'MMDDYYYY'),8,' '),4518,pr_idarquivo);-- Data pagamento
             pc_monta_linha(RPad(NVL(vr_tpemprst,0),1,' '),4526,pr_idarquivo); -- Produto
             pc_monta_linha(gene0002.fn_mask(NVL(vr_vldocet,0) * 100,'99999'),4527,pr_idarquivo); -- CET
           END IF;

         EXCEPTION
           WHEN vr_exc_erro THEN
             pr_cdcritic:= vr_cdcritic;
             pr_dscritic:= vr_dscritic;
           WHEN OTHERS THEN
             --Variavel de erro recebe erro ocorrido
             pr_cdcritic:= 0;
             pr_dscritic:= 'Erro na rotina pc_crps652.pc_gera_carga_MF_complem. '||sqlerrm;
         END;
       END pc_gera_carga_MF_complem;

       --Procedure para Pagamentos de Acordos
       PROCEDURE pc_gera_carga_pagto_acordo (pr_idarquivo  IN INTEGER
                                            ,pr_cdcooper   IN crapcop.cdcooper%TYPE
                                            ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
                                            ,pr_cdcritic  OUT INTEGER
                                            ,pr_dscritic  OUT VARCHAR2) IS
         BEGIN
           DECLARE

           --Selecionar Pagamentos de Acordos
           CURSOR cr_crapret (pr_cdcooper IN crapcop.cdcooper%type
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                             ,pr_nrcnvcob IN crapret.nrcnvcob%TYPE) IS

             SELECT tbrecup_acordo.nracordo,
                    tbrecup_acordo_parcela.nrparcela,
                    crapcob.nrnosnum,
                    crapoco.dsocorre,
                    crapret.vlrpagto,
                    crapret.dtocorre,
                    crapcob.vltitulo
               FROM crapret
               JOIN crapcco
                 ON crapcco.cdcooper = crapret.cdcooper
                AND crapcco.nrconven = crapret.nrcnvcob
               JOIN crapcob
                 ON crapcob.cdcooper = crapret.cdcooper
                AND crapcob.nrcnvcob = crapret.nrcnvcob
                AND crapcob.nrdconta = crapret.nrdconta
                AND crapcob.nrdocmto = crapret.nrdocmto     
                AND crapcob.nrdctabb = crapcco.nrdctabb
                AND crapcob.cdbandoc = crapcco.cddbanco
               JOIN crapoco
                 ON crapoco.cdcooper = crapcob.cdcooper
                AND crapoco.cddbanco = crapcob.cdbandoc
                AND crapoco.cdocorre = crapret.cdocorre
                AND crapoco.tpocorre = 2
               JOIN tbrecup_acordo_parcela
                 ON tbrecup_acordo_parcela.nrboleto     = crapcob.nrdocmto
                AND tbrecup_acordo_parcela.nrconvenio   = crapcob.nrcnvcob
                AND tbrecup_acordo_parcela.nrdconta_cob = crapcob.nrdconta
               JOIN tbrecup_acordo
                 ON tbrecup_acordo.nracordo = tbrecup_acordo_parcela.nracordo
              WHERE crapret.cdcooper = pr_cdcooper
                AND crapret.nrcnvcob = pr_nrcnvcob
                AND crapret.dtocorre = pr_dtmvtolt
                AND crapret.cdocorre IN (6,76);       -- liquidacao normal COO/CEE

           vr_nrcnvcob crapprm.dsvlrprm%TYPE;

         BEGIN
           --Limpar parametros erro
           pr_cdcritic:= NULL;
           pr_dscritic:= NULL;

           -- Localizar convenio de cobran�a
           vr_nrcnvcob := gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'ACORDO_NRCONVEN');
                                                              
           FOR rw_crapret IN cr_crapret(pr_cdcooper => pr_cdcooper       -- Cooperativa
                                       ,pr_dtmvtolt => pr_dtmvtolt       -- Data Movimento
                                       ,pr_nrcnvcob => vr_nrcnvcob) LOOP -- Numero do Convenio
                                          
             pc_monta_linha(RPAD('',3,' '),1,pr_idarquivo);                                           -- Tipo de Registro 
             pc_monta_linha(RPAD(rw_crapret.nrnosnum,20,' '),4,pr_idarquivo);                         -- Nosso Numero
             pc_monta_linha(GENE0002.fn_mask(rw_crapret.nracordo,'9999999999999'),24,pr_idarquivo);   -- N�mero do Acordo
             pc_monta_linha(GENE0002.fn_mask(rw_crapret.nrparcela,'99999'),37,pr_idarquivo);          -- N�mero da Parcela do Acordo
             pc_monta_linha(RPAD(rw_crapret.dsocorre,2,' '),42,pr_idarquivo);                         -- Identificacao de Ocorrencia           
             pc_monta_linha(GENE0002.fn_mask(rw_crapret.vlrpagto*100,'999999999999999'),44,pr_idarquivo); -- Valor pago
             pc_monta_linha(GENE0002.fn_mask(rw_crapret.vltitulo*100,'999999999999999'),59,pr_idarquivo); -- Valor do Boleto
             pc_monta_linha(RPAD(TO_CHAR(rw_crapret.dtocorre,'MMDDYYYY'),8,' '),74,pr_idarquivo);     -- Data de entrada de pagamento
             pc_monta_linha(RPAD(TO_CHAR(rw_crapret.dtocorre,'MMDDYYYY'),8,' '),82,pr_idarquivo);     -- Data de Transacao
             pc_monta_linha(RPAD('Acordo:' || GENE0002.fn_mask(rw_crapret.nracordo,'9999999999999') ||
                                 ', Parcela:' || GENE0002.fn_mask(rw_crapret.nrparcela,'99999'),100,' '),90,pr_idarquivo); -- Descri��o do Pagamento                                 
             --Escrever no arquivo
           pc_escreve_dado(NULL,pr_idarquivo,null);             
           END LOOP;
           
         EXCEPTION
           WHEN OTHERS THEN
             --Variavel de erro recebe erro ocorrido
             pr_cdcritic:= 0;
             pr_dscritic:= 'Erro na rotina pc_crps652.pc_gera_carga_pagto_acordo. '|| SQLERRM;
         END;
       END pc_gera_carga_pagto_acordo;

       --Buscar valor pago Conta Corrente
       FUNCTION fn_valor_pago_conta_corrente (pr_cdcooper  IN crapcyb.cdcooper%type
                                             ,pr_nrdconta  IN crapcyb.nrdconta%type
                                             ,pr_nrctremp  IN crapcyb.nrctremp%type
                                             ,pr_dtmvtolt  IN crapdat.dtmvtolt%type) RETURN NUMBER IS
       BEGIN
         DECLARE
           --Cursor para somar lancamentos
           CURSOR cr_soma (pr_cdcooper IN crapcyb.cdcooper%type
                          ,pr_nrdconta IN crapcyb.nrdconta%type
                          ,pr_nrctremp IN crapcyb.nrctremp%type
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%type) IS
             SELECT nvl(sum(nvl(craplcm.vllanmto,0)),0) as vllanmto
               FROM craplcm, craphis
              WHERE craphis.cdcooper = craplcm.cdcooper
                AND craphis.cdhistor = craplcm.cdhistor
                AND craplcm.cdcooper = pr_cdcooper
                AND craplcm.nrdconta = pr_nrdconta
                AND craplcm.dtmvtolt = pr_dtmvtolt
               AND craphis.indcalcc = 'S';
           --Variaveis Locais
           vr_vllanmto NUMBER:= 0;
         BEGIN
           --Somar os lancamentos de pagamento do emprestimo na data
           OPEN cr_soma (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrctremp => pr_nrctremp
                        ,pr_dtmvtolt => pr_dtmvtolt);
           FETCH cr_soma INTO vr_vllanmto;
           --Fechar Cursor
           CLOSE cr_soma;
           --Retornar somatorio
           RETURN(vr_vllanmto);
         EXCEPTION
           WHEN OTHERS THEN
             RETURN(0);
         END;
       END fn_valor_pago_conta_corrente;

       --Procedure para gerar carga MC
       PROCEDURE pc_gera_carga_MC (pr_idarquivo  IN INTEGER
                                  ,pr_cdcooper   IN crapcyb.cdcooper%type
                                  ,pr_nrdconta   IN crapcyb.nrdconta%type
                                  ,pr_cdorigem   IN crapcyb.cdorigem%TYPE
                                  ,pr_nrctremp   IN crapcyb.nrctremp%TYPE
                                  ,pr_posicini   IN INTEGER
                                  ,pr_cdcritic   OUT INTEGER
                                  ,pr_dscritic   OUT VARCHAR2) IS
       BEGIN
         DECLARE
           /* Cursores Locais */

           --Listar Telefones
           CURSOR cr_craptfc(pr_cdcooper IN craptfc.cdcooper%type
                            ,pr_nrdconta IN craptfc.nrdconta%type
                            ,pr_idseqttl IN craptfc.idseqttl%type) IS
             SELECT craptfc.nrdddtfc
                   ,craptfc.nrtelefo
             FROM craptfc
             WHERE craptfc.cdcooper = pr_cdcooper
             AND   craptfc.nrdconta = pr_nrdconta
             AND   craptfc.idseqttl = pr_idseqttl
             AND   craptfc.idsittfc = 1
             ORDER BY craptfc.progress_recid ASC;
           rw_craptfc cr_craptfc%ROWTYPE;
           --Listar Telefones Por Tipo
           CURSOR cr_craptfc_tipo (pr_cdcooper IN craptfc.cdcooper%type
                                  ,pr_nrdconta IN craptfc.nrdconta%type) IS
             SELECT craptfc.tptelefo
                   ,craptfc.cdopetfn
                   ,craptfc.nrdddtfc
                   ,craptfc.nrtelefo
                   ,craptfc.nrdramal
                   ,craptfc.nmpescto
                   ,row_number() over (partition By craptfc.tptelefo
                                       order by craptfc.tptelefo
                                               ,craptfc.cdcooper
                                               ,craptfc.nrdconta
                                               ,craptfc.idseqttl
                                               ,craptfc.cdseqtfc) nrseqreg
                   ,count(1) over (partition By craptfc.tptelefo) nrtotreg
             FROM craptfc
             WHERE craptfc.cdcooper = pr_cdcooper
             AND   craptfc.nrdconta = pr_nrdconta
             AND   craptfc.idseqttl = 1
             and   craptfc.idsittfc = 1;
           --Selecionar Email
           CURSOR cr_crapcem (pr_cdcooper IN crapcem.cdcooper%type
                             ,pr_nrdconta IN crapcem.nrdconta%type
                             ,pr_idseqttl IN crapcem.idseqttl%type) IS
             SELECT crapcem.dsdemail
             FROM crapcem
             WHERE crapcem.cdcooper = pr_cdcooper
             AND   crapcem.nrdconta = pr_nrdconta
             AND   crapcem.idseqttl = pr_idseqttl
             ORDER BY crapcem.progress_recid ASC;
           rw_crapcem cr_crapcem%ROWTYPE;
           --Selecionar Dados Conjuge
           CURSOR cr_crapcje (pr_cdcooper IN crapcje.cdcooper%type
                             ,pr_nrdconta IN crapcje.nrdconta%type
                             ,pr_idseqttl IN crapcje.idseqttl%type) IS
             SELECT crapcje.nrctacje
                   ,crapcje.nrcpfcjg
                   ,crapcje.nmconjug
             FROM crapcje
             WHERE crapcje.cdcooper = pr_cdcooper
             AND   crapcje.nrdconta = pr_nrdconta
             AND   crapcje.idseqttl = pr_idseqttl;
           rw_crapcje cr_crapcje%ROWTYPE;
           --Selecionar dados do Ramo de Atividade - PJ
           CURSOR cr_gnrativ(pr_cdrmativ IN gnrativ.cdrmativ%TYPE) IS
             SELECT gnrativ.nmrmativ
               FROM gnrativ
              WHERE gnrativ.cdrmativ = pr_cdrmativ;
           rw_gnrativ cr_gnrativ%ROWTYPE;
           --Selecionar dados da Escolaridade - PF
           CURSOR cr_gngresc(pr_grescola IN gngresc.grescola%TYPE) IS
             SELECT gngresc.dsescola
               FROM gngresc
              WHERE gngresc.grescola = pr_grescola;
           rw_gngresc cr_gngresc%ROWTYPE;
           --Situa��o do Cart�o CECRED
           CURSOR cr_crawcrd(pr_cdcooper IN crawcrd.cdcooper%TYPE
                            ,pr_nrdconta IN crawcrd.nrdconta%TYPE) IS
             SELECT insitcrd
               FROM (SELECT crawcrd.*
                       FROM crawcrd
                      WHERE crawcrd.cdcooper = pr_cdcooper
                        AND crawcrd.nrdconta = pr_nrdconta
                        AND crawcrd.cdadmcrd BETWEEN 10 AND 80
                      ORDER BY decode(crawcrd.insitcrd, 4, 1, 3, 2, 1, 3, 2, 4, 0, 5, 6))
              WHERE rownum = 1;
           rw_crawcrd cr_crawcrd%ROWTYPE;
             --Quantidade de Cart�es
           CURSOR cr_crapcrm(pr_cdcooper IN crapcrm.cdcooper%TYPE
                            ,pr_nrdconta IN crapcrm.nrdconta%TYPE) IS
             SELECT COUNT(*) qtd
               FROM crapcrd c
              WHERE c.nrdconta = pr_nrdconta
                AND c.cdcooper = pr_cdcooper
                and c.cdadmcrd BETWEEN 10 AND 80
                AND c.dtcancel IS NULL;
           rw_crapcrm cr_crapcrm%ROWTYPE;
           --Informa��es de Acesso ao Internet Bank
           CURSOR cr_crapsnh(pr_cdcooper IN crapsnh.cdcooper%TYPE
                            ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                            ,pr_idseqttl IN crapsnh.idseqttl%TYPE) IS
             SELECT crapsnh.cdsitsnh
               FROM crapsnh
              WHERE crapsnh.cdcooper = pr_cdcooper
                AND crapsnh.nrdconta = pr_nrdconta
                AND crapsnh.idseqttl = pr_idseqttl
                AND crapsnh.tpdsenha = 1;

           rw_crapsnh cr_crapsnh%ROWTYPE;

           --Informa��es de Acesso ao Internet Bank
           CURSOR cr_crapsnh_astcjt(pr_cdcooper IN crapsnh.cdcooper%TYPE
                                   ,pr_nrdconta IN crapsnh.nrdconta%TYPE) IS
             SELECT crapsnh.cdsitsnh
               FROM crapsnh
              WHERE crapsnh.cdcooper = pr_cdcooper
                AND crapsnh.nrdconta = pr_nrdconta
                AND crapsnh.tpdsenha = 1
                AND crapsnh.cdsitsnh = 1 -- Ativo
                AND rownum = 1;

           rw_crapsnh_astcjt cr_crapsnh_astcjt%ROWTYPE;
           --Listagem dos Bens
           CURSOR cr_crapbem(pr_cdcooper IN crapbem.cdcooper%TYPE
                            ,pr_nrdconta IN crapbem.nrdconta%TYPE
                            ,pr_idseqttl IN crapbem.idseqttl%TYPE) IS
             SELECT dsrelbem
                   ,vlrdobem
               FROM (SELECT crapbem.dsrelbem
                           ,crapbem.vlrdobem
                       FROM crapbem
                      WHERE crapbem.cdcooper = pr_cdcooper
                        AND crapbem.nrdconta = pr_nrdconta
                        AND crapbem.idseqttl = pr_idseqttl
                      ORDER BY crapbem.vlrdobem DESC)
              WHERE rownum <= 5;
           -- Buscar o faturamento da PJ
           CURSOR cr_busca_faturamento(pr_cdcooper crapjur.cdcooper%TYPE
                                      ,pr_nrdconta crapjur.nrdconta%TYPE) IS
             SELECT ROUND(AVG(valor_faturamento),2) valor
               FROM (SELECT cdcooper,
                            nrdconta,
                            mes_faturamento,
                            ano_faturamento,
                            valor_faturamento,
                            mes
                       FROM crapjfn UNPIVOT((mes_faturamento, ano_faturamento, valor_faturamento)
                                 FOR mes IN((mesftbru##1,anoftbru##1,vlrftbru##1) as 1,
                                            (mesftbru##2,anoftbru##2,vlrftbru##2) as 2,
                                            (mesftbru##3,anoftbru##3,vlrftbru##3) as 3,
                                            (mesftbru##4,anoftbru##4,vlrftbru##4) as 4,
                                            (mesftbru##5,anoftbru##5,vlrftbru##5) as 5,
                                            (mesftbru##6,anoftbru##6,vlrftbru##6) as 6,
                                            (mesftbru##7,anoftbru##7,vlrftbru##7) as 7,
                                            (mesftbru##8,anoftbru##8,vlrftbru##8) as 8,
                                            (mesftbru##9,anoftbru##9,vlrftbru##9) as 9,
                                            (mesftbru##10,anoftbru##10,vlrftbru##10) as 10,
                                            (mesftbru##11,anoftbru##11,vlrftbru##11) as 11,
                                            (mesftbru##12,anoftbru##12,vlrftbru##12) as 12))
                     WHERE cdcooper = pr_cdcooper
                       AND nrdconta = pr_nrdconta
                     ORDER BY ano_faturamento || lpad(mes_faturamento, 2, '0') desc)
               WHERE rownum <= 6;
           rw_faturamento cr_busca_faturamento%ROWTYPE;
           -- [Projeto 403] Dados do sacado
           CURSOR cr_crapsab(pr_cdcooper crapjur.cdcooper%TYPE
                            ,pr_nrdconta crapjur.nrdconta%TYPE
                            ,pr_nrctrdsc crapcyb.nrctremp%TYPE) IS
                SELECT sab.nmdsacad, -- nome do sacado
                       sab.nrinssac, -- cpf/cnpj
                       sab.nrdconta, -- conta
                       sab.nrcelsac, -- telefone
                       sab.dsendsac, -- endere�o
                       sab.nrendsac, -- n�mero
                       sab.complend, -- complemento
                       sab.nmbaisac, -- bairro
                       sab.nmcidsac, -- cidade
                       sab.nrcepsac, -- CEP
                       sab.cdufsaca  -- UF
                  FROM tbdsct_titulo_cyber tcy
            INNER JOIN craptdb tdb ON tdb.cdcooper = tcy.cdcooper 
                                  AND tdb.nrdconta = tcy.nrdconta 
                                  AND tdb.nrborder = tcy.nrborder 
                                  AND tdb.nrtitulo = tcy.nrtitulo
            INNER JOIN crapsab sab ON sab.cdcooper = tdb.cdcooper 
                                  AND sab.nrdconta = tdb.nrdconta 
                                  AND sab.nrinssac = tdb.nrinssac
                 WHERE tcy.cdcooper = pr_cdcooper
                   AND tcy.nrdconta = pr_nrdconta
                   AND tcy.nrctrdsc = pr_nrctrdsc;
           rw_crapsab cr_crapsab%ROWTYPE;
           --Tabela Memoria Avalistas
           vr_tab_crapcct CADA0001.typ_tab_crapavt;
           vr_tab_crapavt CADA0001.typ_tab_crapavt_58;
           --Tabela Representanes Legais
           vr_tab_crapcrl CADA0001.typ_tab_crapcrl;
           --Tabela memoria Bens
           vr_tab_bens CADA0001.typ_tab_bens;
           --Tabela Memoria Empresas Paticipantes
           vr_tab_crapepa CADA0001.typ_tab_crapepa;
           --Tabela Memoria Contatos Juridicos
           vr_tab_contato CADA0001.typ_tab_contato_juridica;
           --Tabela Erros
           vr_tab_erro GENE0001.typ_tab_erro;
           --Variaveis Locais
           vr_crapttl  BOOLEAN;
           vr_crapenc  BOOLEAN;
           vr_contador INTEGER;
           vr_index    INTEGER;
           vr_idseqttl INTEGER;
           vr_dsestcvl CHAR;
           --Variaveis da procedure Busca_idade
           vr_nrdeanos INTEGER:= 0;
           vr_nrdmeses INTEGER:= 0;
           vr_dsdidade VARCHAR2(1000);
           --Variaveis de Excecao
           vr_exc_erro EXCEPTION;
           --Variaveis Erro
           vr_cdcritic INTEGER;
           vr_dscritic VARCHAR2(4000);
           -- Rendimento PF
           vr_rendimento  NUMBER(15);
           -- Faturamento PJ
           vr_faturamento NUMBER(15);
           -- Quantidade de Bens Adicionados no arquivo
           vr_qtd_bens    INTEGER;
           -- Situa��o do Cart�o CECRED
           vr_insitcrd    INTEGER;
           -- Situa��o do acesso ao internet bank
           vr_cdsitsnh    INTEGER;
           -- Escolaridade
           vr_dsescola gngresc.dsescola%TYPE;
           -- Ramo de Atividade
           vr_nmrmativ gnrativ.nmrmativ%TYPE;
           -- Posi��o Inicial Auxiliar
           vr_posicini_aux INTEGER;
   		     --Habilita��o de menor
  		     vr_inhabmen crapttl.inhabmen%TYPE;
         BEGIN
           --Limpar parametros erro
           pr_cdcritic:= NULL;
           pr_dscritic:= NULL;

           --Limpar tabelas de memoria
           vr_tab_crapcct.DELETE;
           vr_tab_crapavt.DELETE;
           vr_tab_bens.DELETE;
           vr_tab_erro.DELETE;

           -- Limpar vari�veis
           vr_buscocup := false;
           vr_rsdocupa := null;

           --Selecionar Titulares da Conta
           OPEN cr_crapttl (pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_idseqttl => 1);
           --Posicionar Primeiro registro
           FETCH cr_crapttl INTO rw_crapttl;
           --Se encontrou
           vr_crapttl:= cr_crapttl%FOUND;
           --Fechar Cursor
           CLOSE cr_crapttl;

           --Se existir associado
           IF vr_tab_crapass.EXISTS(pr_nrdconta) THEN
             --Data Emissao Documento nao nula
             IF vr_tab_crapass(pr_nrdconta).dtemdptl IS NOT NULL THEN
              vr_dtemdptl:= to_char(vr_tab_crapass(pr_nrdconta).dtemdptl,'MMDDYYYY');
             ELSE
               vr_dtemdptl:= NULL;
             END IF;
             --Data Nascimento nao nula
             IF vr_tab_crapass(pr_nrdconta).dtnasctl IS NOT NULL THEN
               vr_dtnasctl:= to_char(vr_tab_crapass(pr_nrdconta).dtnasctl,'MMDDYYYY');
             ELSE
               vr_dtnasctl:= NULL;
             END IF;
             /* AT definido pela posicao inicial do layout MC + o tamanho dos campos anteriores */
             pc_monta_linha(rpad(vr_tab_crapass(pr_nrdconta).nmprimtl,50,' '),pr_posicini,pr_idarquivo);
             pc_monta_linha(vr_tab_crapass(pr_nrdconta).inpessoa,pr_posicini+50,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapass(pr_nrdconta).tpdocptl,2,' '),pr_posicini+51,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapass(pr_nrdconta).nrdocptl,15,' '),pr_posicini+53,pr_idarquivo);
             pc_monta_linha(vr_dtemdptl,pr_posicini+68,pr_idarquivo);
             pc_monta_linha(vr_dtnasctl,pr_posicini+76,pr_idarquivo);
             pc_monta_linha(vr_tab_crapass(pr_nrdconta).cdsexotl,pr_posicini+84,pr_idarquivo);
           END IF; --avail crapass

           --Se encontrou titular
           IF vr_crapttl THEN
             pc_monta_linha(rpad(rw_crapttl.dsnatura,25,' '),pr_posicini+85,pr_idarquivo);
           END IF;

           --Se Encontrou Associado
           IF vr_tab_crapass.EXISTS(pr_nrdconta) THEN
             pc_monta_linha(rpad(vr_tab_crapass(pr_nrdconta).dsestcvl,30,' '),pr_posicini+110,pr_idarquivo);
             --Se possuir titular
             IF vr_crapttl THEN
               --Nome mae tabela titular
               pc_monta_linha(rpad(rw_crapttl.nmmaettl,50,' '),pr_posicini+140,pr_idarquivo);
               --Nome mae tabela titular
               pc_monta_linha(rpad(rw_crapttl.nmpaittl,50,' '),pr_posicini+190,pr_idarquivo);

			         vr_inhabmen:= rw_crapttl.inhabmen;

             END IF;

           END IF; --avail crapass

           --Pessoa Fisica
           IF vr_tab_crapass(pr_nrdconta).inpessoa = 1 THEN
             --Selecionar Endereco
             OPEN cr_crapenc (pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_idseqttl => 1    /* Primeiro titular */
                             ,pr_tpendass => 10); /* 10 - Residencial */
             --Posicionar primeiro registro
             FETCH cr_crapenc INTO rw_crapenc;
             --Verificar se encontrou
             vr_crapenc:= cr_crapenc%FOUND;
             --Fechar Cursor
             CLOSE cr_crapenc;
             --Se possui titular
             IF vr_crapttl THEN
               --Buscar ocupacao
               vr_buscocup:= CADA0001.fn_busca_ocupacao (pr_cddocupa => rw_crapttl.cdocpttl
                                                        ,pr_rsdocupa => vr_rsdocupa
                                                        ,pr_cdcritic => vr_cdcritic
                                                        ,pr_dscritic => vr_dscritic);
               --Nao � verificado se ocorreu erro
             END IF;
           ELSE
             --Selecionar Endereco
             OPEN cr_crapenc (pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_idseqttl => 1    /* Primeiro titular */
                             ,pr_tpendass => 9);  /* 9 - Comercio */
             --Posicionar primeiro registro
             FETCH cr_crapenc INTO rw_crapenc;
             --Verificar se encontrou
             vr_crapenc:= cr_crapenc%FOUND;
             --Fechar Cursor
             CLOSE cr_crapenc;

			       vr_inhabmen:= 0;

           END IF;
           /* Imovel cooperado */
           IF vr_crapenc THEN
             pc_monta_linha(rw_crapenc.incasprp,pr_posicini+240,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.dsendere,40,' '),pr_posicini+241,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nrendere,6,' '),pr_posicini+281,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.complend,40,' '),pr_posicini+287,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nrdoapto,4,' '),pr_posicini+327,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.cddbloco,3,' '),pr_posicini+331,pr_idarquivo);
           END IF;
           /* Ocupacao cooperado */
           IF vr_buscocup THEN
             pc_monta_linha(rpad(vr_rsdocupa,15,' '),pr_posicini+334,pr_idarquivo);
           END IF;
           /* Empresa cooperado */
           IF vr_crapttl THEN
             pc_monta_linha(rpad(rw_crapttl.nmextemp,30,' '),pr_posicini+349,pr_idarquivo);
           END IF;
           /* Endereco cooperado */
           IF vr_crapenc THEN
             pc_monta_linha(rpad(rw_crapenc.nmbairro,40,' '),pr_posicini+379,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nmcidade,25,' '),pr_posicini+419,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nrcepend,8,' '),pr_posicini+444,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.cdufende,2,' '),pr_posicini+452,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nrcxapst,5,' '),pr_posicini+454,pr_idarquivo);
           END IF;
           --Limpar Variaveis telefone
           FOR idx in 1..5 LOOP
             vr_tab_telcoop(idx):= NULL;
           END LOOP;
           --Inicializar Contador
           vr_contador := 1;
           --Selecionar Telefones
           FOR rw_craptfc IN cr_craptfc_tipo (pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => pr_nrdconta) LOOP
             --Se for o ultimo fone daquele tipo
             IF rw_craptfc.nrseqreg = rw_craptfc.nrtotreg THEN
               --Montar o tipo (Residencial/Celeular/Comercial)
               IF rw_craptfc.tptelefo IN (1,2,3) THEN
                 vr_tab_telcoop(rw_craptfc.tptelefo):= rpad(rw_craptfc.cdopetfn,5,' ')||
                                                       rpad(rw_craptfc.nrdddtfc,3,' ')||
                                                       rpad(rw_craptfc.nrtelefo,10,' ')||
                                                       rpad(rw_craptfc.nrdramal,4,' ')||
                                                       rpad(rw_craptfc.tptelefo,1,' ')||
                                                       rpad(rw_craptfc.nmpescto,50,' ');
               END IF;
             END IF;
             IF vr_contador IN (4,5) THEN
               vr_tab_telcoop(vr_contador):= rpad(rw_craptfc.cdopetfn,5,' ')||
                                             rpad(rw_craptfc.nrdddtfc,3,' ')||
                                             rpad(rw_craptfc.nrtelefo,10,' ')||
                                             rpad(rw_craptfc.nrdramal,4,' ')||
                                             rpad(rw_craptfc.tptelefo,1,' ')||
                                             rpad(rw_craptfc.nmpescto,50,' ');
             END IF;
             --Incrementar Contador
             vr_contador:= vr_contador + 1;
           END LOOP;
           --Mostrar os telefones
           --Residencial,Comercial,Celular
           pc_monta_linha(vr_tab_telcoop(1),pr_posicini+459,pr_idarquivo);
           pc_monta_linha(vr_tab_telcoop(3),pr_posicini+532,pr_idarquivo);
           pc_monta_linha(vr_tab_telcoop(2),pr_posicini+605,pr_idarquivo);
           pc_monta_linha(vr_tab_telcoop(4),pr_posicini+678,pr_idarquivo);
           pc_monta_linha(vr_tab_telcoop(5),pr_posicini+751,pr_idarquivo);
           --Selecionar Email
           OPEN cr_crapcem (pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_idseqttl => 1);
           FETCH cr_crapcem INTO rw_crapcem;
           --Se encontrou
           IF cr_crapcem%FOUND THEN
             pc_monta_linha(rpad(rw_crapcem.dsdemail,40,' '),pr_posicini+824,pr_idarquivo);
           END IF;
           --Fechar Cursor
           CLOSE cr_crapcem;
           /* Conjuge */
           --Selecionar Informacoes Conjuge
           OPEN cr_crapcje (pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_idseqttl => 1);
           FETCH cr_crapcje INTO rw_crapcje;
           --Se Encontrou
           IF cr_crapcje%FOUND THEN
             pc_monta_linha(rpad(rw_crapcje.nmconjug,50,' '),pr_posicini+864,pr_idarquivo);
             --Se o numero cpf/cgc esta preenchido
             IF nvl(rw_crapcje.nrcpfcjg,0) <> 0 THEN
               pc_monta_linha(gene0002.fn_mask(rw_crapcje.nrcpfcjg,'99999999999'),pr_posicini+914,pr_idarquivo);
             END IF;
             pc_monta_linha(rpad(rw_crapcje.nrctacje,8,' '),pr_posicini+925,pr_idarquivo);
           END IF;
           --Fechar Cursor
           CLOSE cr_crapcje;

           --Buscar Dados
           CADA0001.pc_busca_dados_73 (pr_cdcooper => pr_cdcooper         --Codigo Cooperativa
                                      ,pr_cdagenci => 0                   --Codigo Agencia
                                      ,pr_nrdcaixa => 0                   --Numero Caixa
                                      ,pr_cdoperad => '1'                 --Codigo Operador
                                      ,pr_nmdatela => 'crps652'           --Nome Tela
                                      ,pr_idorigem => 1                   --Origem da chamada
                                      ,pr_nrdconta => pr_nrdconta         --Numero da Conta
                                      ,pr_idseqttl => 1                   --Sequencial Titular
                                      ,pr_flgerlog => FALSE               --Erro no Log
                                      ,pr_dtmvtolt => vr_dtatual --Data Movimento
                                      ,pr_cddopcao => 'C'                 --Codigo opcao
                                      ,pr_nrdctato => 0                   --Numero Contato
                                      ,pr_nrdrowid => vr_nrdrowid         --Rowid Empresa participante
                                      ,pr_tab_crapavt => vr_tab_crapcct   --Tabela Avalistas
                                      ,pr_tab_erro => vr_tab_erro         --Tabela Erro
                                      ,pr_cdcritic => vr_cdcritic         --Codigo de erro
                                      ,pr_dscritic => vr_dscritic);       --Retorno de Erro
           -- Manter tratamento efetuado no Progress, ou seja, desprezar erro vindo
           --Se ocorreu erro
           IF /*vr_cdcritic IS NOT NULL OR */ vr_dscritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_erro;
           END IF;
           /* Contato 1 */
           --Verificar se possui contato
           vr_index:= vr_tab_crapcct.FIRST;
           IF vr_index IS NOT NULL THEN
             pc_monta_linha(rpad(vr_tab_crapcct(vr_index).nmdavali,50,' '),pr_posicini+933,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapcct(vr_index).nrtelefo,20,' '),pr_posicini+983,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapcct(vr_index).nrdctato,8,' '),pr_posicini+1003,pr_idarquivo);
           END IF;
           /* Contato 2 */
           --Proximo Contato
           vr_index:= vr_tab_crapcct.NEXT(vr_index);
           IF vr_index IS NOT NULL THEN
             pc_monta_linha(rpad(vr_tab_crapcct(vr_index).nmdavali,50,' '),pr_posicini+1011,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapcct(vr_index).nrtelefo,20,' '),pr_posicini+1061,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapcct(vr_index).nrdctato,8,' '),pr_posicini+1081,pr_idarquivo);
           END IF;

           --Pessoa Fisica ou Juridica
           IF vr_tab_crapass(pr_nrdconta).inpessoa IN (1,2) THEN
             CASE vr_tab_crapass(pr_nrdconta).inpessoa
               WHEN 1 THEN vr_idseqttl:= 1;
               WHEN 2 THEN vr_idseqttl:= 0;
             END CASE;
             /* Buscar dados dos representantes/procuradores */
             CADA0001.pc_busca_dados_58 (pr_cdcooper => pr_cdcooper        --Codigo Cooperativa
                                        ,pr_cdagenci => 0                  --Codigo Agencia
                                        ,pr_nrdcaixa => 0                  --Numero Caixa
                                        ,pr_cdoperad => '1'                --Codigo Operador
                                        ,pr_nmdatela => 'crps652'          --Nome Tela
                                        ,pr_idorigem => 1                  --Origem da chamada
                                        ,pr_nrdconta => pr_nrdconta        --Numero da Conta
                                        ,pr_idseqttl => vr_idseqttl        --Sequencial Titular
                                        ,pr_flgerlog => FALSE              --Erro no Log
                                        ,pr_cddopcao => 'C'                --Codigo opcao
                                        ,pr_nrdctato => 0                  --Numero Contato
                                        ,pr_nrcpfcto => 0                  --Numero Cpf Contato
                                        ,pr_nrdrowid => vr_nrdrowid        --Rowid Empresa participante
                                        ,pr_tab_crapavt => vr_tab_crapavt  --Tabela Avalistas
                                        ,pr_tab_bens => vr_tab_bens        --Tabela bens
                                        ,pr_tab_erro => vr_tab_erro        --Tabela Erro
                                        ,pr_cdcritic => vr_cdcritic        --Codigo de erro
                                        ,pr_dscritic => vr_dscritic);      --Retorno de Erro
             -- Manter tratamento efetuado no Progress, ou seja, desprezar erro vindo
             --Se ocorreu erro
             IF /*vr_cdcritic IS NOT NULL OR */ vr_dscritic IS NOT NULL THEN
               --Levantar Excecao
               RAISE vr_exc_erro;
             END IF;
           END IF;
           --Se Encontrou Procurador
           vr_index:= vr_tab_crapavt.FIRST;
           IF vr_index IS NOT NULL THEN
             --Data Validade Preenchida
             IF vr_tab_crapavt(vr_index).dtvalida IS NOT NULL THEN
               --Data Validade
               vr_dtvalida:= to_char(vr_tab_crapavt(vr_index).dtvalida,'MMDDYYYY');
             ELSE
               vr_dtvalida:= NULL;
             END IF;
             /* Procurador 1 */
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nmdavali,50,' '),pr_posicini+1089,pr_idarquivo);

             --Buscar Cpf/Cgc
             vr_nrcpfcgc:= fn_Busca_cpfcgc(pr_nrcpfcgc => vr_tab_crapavt(vr_index).nrcpfcgc);

             pc_monta_linha(vr_nrcpfcgc,pr_posicini+1139,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).dsproftl,21,' '),pr_posicini+1150,pr_idarquivo);
             pc_monta_linha(rpad(vr_dtvalida,8,' '),pr_posicini+1171,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nrdctato,8,' '),pr_posicini+1179,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).dsendres(1),40,' '),pr_posicini+1187,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nrendere,6,' '),pr_posicini+1227,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).complend,40,' '),pr_posicini+1233,pr_idarquivo);

             if vr_tab_crapavt(vr_index).tpctrato in (1,9) then --Chamado 307644
               pc_monta_linha(rpad(vr_tab_crapavt(vr_index).dsendres(2),40,' '),pr_posicini+1273,pr_idarquivo);
             else
               pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nmbairro,40,' '),pr_posicini+1273,pr_idarquivo);
             end if;

             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nmcidade,25,' '),pr_posicini+1313,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nrcepend,8,' '),pr_posicini+1338,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nrcxapst,5,' '),pr_posicini+1346,pr_idarquivo);

             --Selecionar Telefone
             OPEN cr_craptfc(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => vr_tab_crapavt(vr_index).nrdctato
                            ,pr_idseqttl => 1);
             FETCH cr_craptfc INTO rw_craptfc;
             --Se encontrou
             IF cr_craptfc%FOUND THEN
               pc_monta_linha(rpad(rw_craptfc.nrdddtfc,3,' '),pr_posicini+1351,pr_idarquivo);
               pc_monta_linha(rpad(rw_craptfc.nrtelefo,10,' '),pr_posicini+1354,pr_idarquivo);
             END IF;
             --Fechar Cursor
             CLOSE cr_craptfc;
           END IF;
           --Proximo Procurador
           vr_index:= vr_tab_crapavt.NEXT(vr_index);
           IF vr_index IS NOT NULL THEN
             --Data Validade Preenchida
             IF vr_tab_crapavt(vr_index).dtvalida IS NOT NULL THEN
               --Data Validade
               vr_dtvalida:= to_char(vr_tab_crapavt(vr_index).dtvalida,'MMDDYYYY');
             ELSE
               vr_dtvalida:= NULL;
             END IF;
             /* Procurador 2 */
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nmdavali,50,' '),pr_posicini+1364,pr_idarquivo);

             --Buscar Cpf/Cgc
             vr_nrcpfcgc:= fn_Busca_cpfcgc(pr_nrcpfcgc => vr_tab_crapavt(vr_index).nrcpfcgc);

             pc_monta_linha(vr_nrcpfcgc,pr_posicini+1414,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).dsproftl,21,' '),pr_posicini+1425,pr_idarquivo);
             pc_monta_linha(rpad(vr_dtvalida,8,' '),pr_posicini+1446,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nrdctato,8,' '),pr_posicini+1454,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).dsendres(1),40,' '),pr_posicini+1462,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nrendere,6,' '),pr_posicini+1502,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).complend,40,' '),pr_posicini+1508,pr_idarquivo);

             if vr_tab_crapavt(vr_index).tpctrato in (1,9) then --Chamado 307644
               pc_monta_linha(rpad(vr_tab_crapavt(vr_index).dsendres(2),40,' '),pr_posicini+1548,pr_idarquivo);
             else
               pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nmbairro,40,' '),pr_posicini+1548,pr_idarquivo);
             end if;

             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nmcidade,25,' '),pr_posicini+1588,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nrcepend,8,' '),pr_posicini+1613,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nrcxapst,5,' '),pr_posicini+1621,pr_idarquivo);

             --Selecionar Telefone
             OPEN cr_craptfc(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => vr_tab_crapavt(vr_index).nrdctato
                            ,pr_idseqttl => 1);
             FETCH cr_craptfc INTO rw_craptfc;
             --Se encontrou
             IF cr_craptfc%FOUND THEN
               pc_monta_linha(rpad(rw_craptfc.nrdddtfc,3,' '),pr_posicini+1626,pr_idarquivo);
               pc_monta_linha(rpad(rw_craptfc.nrtelefo,10,' '),pr_posicini+1629,pr_idarquivo);
             END IF;
             --Fechar Cursor
             CLOSE cr_craptfc;
           END IF;
           --Proximo Procurador
           vr_index:= vr_tab_crapavt.NEXT(vr_index);
           IF vr_index IS NOT NULL THEN
             --Data Validade Preenchida
             IF vr_tab_crapavt(vr_index).dtvalida IS NOT NULL THEN
               --Data Validade
               vr_dtvalida:= to_char(vr_tab_crapavt(vr_index).dtvalida,'MMDDYYYY');
             ELSE
               vr_dtvalida:= NULL;
             END IF;
             /* Procurador 3 */
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nmdavali,50,' '),pr_posicini+1639,pr_idarquivo);

             --Buscar Cpf/Cgc
             vr_nrcpfcgc:= fn_Busca_cpfcgc(pr_nrcpfcgc => vr_tab_crapavt(vr_index).nrcpfcgc);

             pc_monta_linha(vr_nrcpfcgc,pr_posicini+1689,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).dsproftl,21,' '),pr_posicini+1700,pr_idarquivo);
             pc_monta_linha(rpad(vr_dtvalida,8,' '),pr_posicini+1721,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nrdctato,8,' '),pr_posicini+1729,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).dsendres(1),40,' '),pr_posicini+1737,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nrendere,6,' '),pr_posicini+1777,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).complend,40,' '),pr_posicini+1783,pr_idarquivo);

             if vr_tab_crapavt(vr_index).tpctrato in (1,9) then --Chamado 307644
               pc_monta_linha(rpad(vr_tab_crapavt(vr_index).dsendres(2),40,' '),pr_posicini+1823,pr_idarquivo);
             else
               pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nmbairro,40,' '),pr_posicini+1823,pr_idarquivo);
             end if;

             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nmcidade,25,' '),pr_posicini+1863,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nrcepend,8,' '),pr_posicini+1888,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapavt(vr_index).nrcxapst,5,' '),pr_posicini+1896,pr_idarquivo);

             --Selecionar Telefone
             OPEN cr_craptfc(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => vr_tab_crapavt(vr_index).nrdctato
                            ,pr_idseqttl => 1);
             FETCH cr_craptfc INTO rw_craptfc;
             --Se encontrou
             IF cr_craptfc%FOUND THEN
               pc_monta_linha(rpad(rw_craptfc.nrdddtfc,3,' '),pr_posicini+1901,pr_idarquivo);
               pc_monta_linha(rpad(rw_craptfc.nrtelefo,10,' '),pr_posicini+1904,pr_idarquivo);
             END IF;
             --Fechar Cursor
             CLOSE cr_craptfc;
           END IF;

           --Buscar Idade
           CADA0001.pc_busca_idade (pr_dtnasctl => vr_tab_crapass(pr_nrdconta).dtnasctl   --Data de Nascimento
                                   ,pr_dtmvtolt => vr_dtatual                    --Data da utilizacao atual
                                   ,pr_flcomple => 0                                  --Controle para validar o m?todo de c?lculo de datas
                                   ,pr_nrdeanos => vr_nrdeanos                            --Numero de Anos
                                   ,pr_nrdmeses => vr_nrdmeses                            --Numero de meses
                                   ,pr_dsdidade => vr_dsdidade                            --Descricao da idade
                                   ,pr_des_erro => vr_dscritic);                          --Mensagem de Erro
           --Se ocorreu erro
           IF vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_erro;
           END IF;

           --Nao habilitado e menor 18 anos
           IF ((vr_inhabmen = 0 AND vr_nrdeanos < 18) OR
                vr_inhabmen = 2) THEN

             /* Buscar dados dos Responsaveis Legais do associado */
             CADA0001.pc_busca_dados_72 (pr_cdcooper => pr_cdcooper         --Codigo Cooperativa
                                        ,pr_cdagenci => 0                   --Codigo Agencia
                                        ,pr_nrdcaixa => 0                   --Numero Caixa
                                        ,pr_cdoperad => '1'                 --Codigo Operador
                                        ,pr_nmdatela => 'crps652'           --Nome Tela
                                        ,pr_idorigem => 1                   --Origem da chamada
                                        ,pr_nrdconta => pr_nrdconta         --Numero da Conta
                                        ,pr_idseqttl => 1                   --Sequencial Titular
                                        ,pr_flgerlog => FALSE               --Erro no Log
                                        ,pr_dtmvtolt => vr_dtatual --Data Movimento
                                        ,pr_cddopcao => 'C'                 --Codigo opcao
                                        ,pr_nrdctato => 0                   --Numero Contato
                                        ,pr_nrcpfcto => 0                   --Numero Cpf Contato
                                        ,pr_nrdrowid => vr_nrdrowid         --Rowid Responsavel
                                        ,pr_cpfprocu => 0                   --Cpf Procurador
                                        ,pr_nmrotina => 'crps652'           --Nome da Rotina
                                        ,pr_dtdenasc => vr_tab_crapass(pr_nrdconta).dtnasctl  --Data Nascimento
                                        ,pr_cdhabmen => vr_inhabmen         --Codigo Habilitacao
                                        ,pr_permalte => FALSE               --Flag Permanece/Altera
                                        ,pr_menorida => vr_menorida         --Flag Menor idade
                                        ,pr_msgconta => vr_msgconta         --Mensagem Conta
                                        ,pr_tab_crapcrl => vr_tab_crapcrl   --Tabela Representantes Legais
                                        ,pr_tab_erro => vr_tab_erro         --Tabela Erro
                                        ,pr_cdcritic => vr_cdcritic         --Codigo de erro
                                        ,pr_dscritic => vr_dscritic);       --Retorno de Erro
             -- Manter tratamento efetuado no Progress, ou seja, desprezar erro vindo
             --Se ocorreu erro
             IF /*vr_cdcritic IS NOT NULL OR */ vr_dscritic IS NOT NULL THEN
               --Levantar Excecao
               RAISE vr_exc_erro;
             END IF;
             /* Responsavel legal */
             vr_index:= vr_tab_crapcrl.FIRST;
             IF vr_index IS NOT NULL THEN
               --Buscar Cpf/Cgc
               vr_nrcpfcgc:= fn_Busca_cpfcgc(pr_nrcpfcgc => vr_tab_crapcrl(vr_index).nrcpfcgc);
               pc_monta_linha(rpad(vr_tab_crapcrl(vr_index).nrdconta,8,' '),pr_posicini+1914,pr_idarquivo);
               pc_monta_linha(rpad(vr_tab_crapcrl(vr_index).nmrespon,50,' '),pr_posicini+1922,pr_idarquivo);
               pc_monta_linha(vr_nrcpfcgc,pr_posicini+1972,pr_idarquivo);
             END IF;
           END IF;
           --Se existe Conta
           IF vr_tab_crapass.EXISTS(pr_nrdconta) THEN
             pc_monta_linha(vr_tab_crapass(pr_nrdconta).cdsitdct,pr_posicini+1983,pr_idarquivo);
           END IF;
           --Buscar dados pessoa Juridica
           IF vr_tab_crapjur.EXISTS(pr_nrdconta) THEN
             pc_monta_linha(rpad(vr_tab_crapjur(pr_nrdconta).dsendweb,40,' '),pr_posicini+1984,pr_idarquivo);
             pc_monta_linha(rpad(vr_tab_crapjur(pr_nrdconta).nrinsest,13,' '),pr_posicini+2024,pr_idarquivo);
           END IF;
           --Limpar tabela Empresas participantes
           vr_tab_crapepa.DELETE;
           /* Buscar os Dados das Empresas Participantes */
           CADA0001.pc_busca_dados_80 (pr_cdcooper => pr_cdcooper              --Codigo Cooperativa
                                      ,pr_cdagenci => 0                        --Codigo Agencia
                                      ,pr_nrdcaixa => 0                        --Numero Caixa
                                      ,pr_cdoperad => '1'                      --Codigo Operador
                                      ,pr_nmdatela => 'crps652'                --Nome Tela
                                      ,pr_idorigem => 1                        --Origem da chamada
                                      ,pr_nrdconta => pr_nrdconta              --Numero da Conta
                                      ,pr_idseqttl => 0                        --Sequencial Titular
                                      ,pr_flgerlog => FALSE                    --Erro no Log
                                      ,pr_cddopcao => 'C'                      --Codigo opcao
                                      ,pr_nrdctato => 0                        --Numero Contato
                                      ,pr_nrcpfcto => 0                        --Numero Cpf Contato
                                      ,pr_nrdrowid => vr_nrdrowid              --Rowid Empresa participante
                                      ,pr_tab_crapepa => vr_tab_crapepa        --Tabela Empresa Paticipante
                                      ,pr_tab_erro => vr_tab_erro              --Tabela Erro
                                      ,pr_cdcritic => vr_cdcritic              --Codigo de erro
                                      ,pr_dscritic => vr_dscritic);            --Retorno de Erro
           --Se ocorreu erro
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_erro;
           END IF;
           /* Participacao Empresas 1 */
           vr_index:= vr_tab_crapepa.FIRST;
           IF vr_index IS NOT NULL THEN
             pc_monta_linha(RPad(vr_tab_crapepa(vr_index).nrctasoc,8,' '),pr_posicini+2037,pr_idarquivo);
             pc_monta_linha(RPad(vr_tab_crapepa(vr_index).nmprimtl,50,' '),pr_posicini+2045,pr_idarquivo);
             pc_monta_linha(REPLACE(REPLACE(REPLACE(vr_tab_crapepa(vr_index).cdcpfcgc,'.',''),'/',''),'-',''),pr_posicini+2095,pr_idarquivo);
             pc_monta_linha(RPad(vr_tab_crapepa(vr_index).dsendweb,40,' '),pr_posicini+2109,pr_idarquivo);
           END IF;
           /* Participacao Empresas 2 */
           vr_index:= vr_tab_crapepa.NEXT(vr_index);
           IF vr_index IS NOT NULL THEN
             pc_monta_linha(RPad(vr_tab_crapepa(vr_index).nrctasoc,8,' '),pr_posicini+2149,pr_idarquivo);
             pc_monta_linha(RPad(vr_tab_crapepa(vr_index).nmprimtl,50,' '),pr_posicini+2157,pr_idarquivo);
             pc_monta_linha(REPLACE(REPLACE(REPLACE(vr_tab_crapepa(vr_index).cdcpfcgc,'.',''),'/',''),'-',''),pr_posicini+2207,pr_idarquivo);
             pc_monta_linha(RPad(vr_tab_crapepa(vr_index).dsendweb,40,' '),pr_posicini+2221,pr_idarquivo);
           END IF;
           --Limpar tabela contato Juridica
           vr_tab_contato.DELETE;
           /* Buscar os Contatos do Associado */
           CADA0001.pc_obtem_contatos (pr_cdcooper => pr_cdcooper                --Codigo Cooperativa
                                      ,pr_cdagenci => 0                          --Codigo Agencia
                                      ,pr_nrdcaixa => 0                          --Numero Caixa
                                      ,pr_cdoperad => '1'                        --Codigo Operador
                                      ,pr_nmdatela => 'crps652'                  --Nome Tela
                                      ,pr_idorigem => 1                          --Origem da chamada
                                      ,pr_nrdconta => pr_nrdconta                --Numero da Conta
                                      ,pr_idseqttl => 1                          --Sequencial Titular
                                      ,pr_flgerlog => FALSE                      --Erro no Log
                                      ,pr_tab_contato_juridica => vr_tab_contato --Tabela Contato
                                      ,pr_tab_erro => vr_tab_erro                --Tabela Erro
                                      ,pr_cdcritic => vr_cdcritic                --Codigo de erro
                                      ,pr_dscritic => vr_dscritic);              --Retorno de Erro
           --Se ocorreu erro e o erro n�o for NOK
           IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) AND vr_dscritic <> 'NOK' THEN
             --Levantar Excecao
             RAISE vr_exc_erro;
           END IF;
           /* Referencia 1 */
           vr_index:= vr_tab_contato.FIRST;
           IF vr_index IS NOT NULL THEN
             pc_monta_linha(RPad(vr_tab_contato(vr_index).nrdctato,8,' '),pr_posicini+2261,pr_idarquivo);
             pc_monta_linha(RPad(vr_tab_contato(vr_index).nmdavali,50,' '),pr_posicini+2269,pr_idarquivo);
             pc_monta_linha(RPad(vr_tab_contato(vr_index).nrtelefo,20,' '),pr_posicini+2319,pr_idarquivo);
           END IF;
           /* Referencia 2 */
           vr_index:= vr_tab_contato.NEXT(vr_index);
           IF vr_index IS NOT NULL THEN
             pc_monta_linha(RPad(vr_tab_contato(vr_index).nrdctato,8,' '),pr_posicini+2339,pr_idarquivo);
             pc_monta_linha(RPad(vr_tab_contato(vr_index).nmdavali,50,' '),pr_posicini+2347,pr_idarquivo);
             pc_monta_linha(RPad(vr_tab_contato(vr_index).nrtelefo,20,' '),pr_posicini+2397,pr_idarquivo);
           END IF;
           
           -- [Projeto 403] Adiciona informa��es do sacado para t�tulos vencidos
           IF pr_cdorigem = 4 THEN
             OPEN cr_crapsab(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrctrdsc => pr_nrctremp);
             FETCH cr_crapsab INTO rw_crapsab;
             --Se encontrou
             IF cr_crapsab%FOUND THEN
               pc_monta_linha(rpad(rw_crapsab.nmdsacad,50, ' '),pr_posicini+2784,pr_idarquivo); -- nome do sacado
               pc_monta_linha(rpad(rw_crapsab.nrinssac,14, ' '),pr_posicini+2834,pr_idarquivo); -- cpf/cnpj
               --pc_monta_linha(rpad(rw_crapsab.nrdconta, 8, ' '),pr_posicini+2848,pr_idarquivo); -- conta
               pc_monta_linha(rpad(rw_crapsab.nrcelsac,20, ' '),pr_posicini+2856,pr_idarquivo); -- telefone
               pc_monta_linha(rpad(rw_crapsab.dsendsac,40, ' '),pr_posicini+2976,pr_idarquivo); -- endere�o
               pc_monta_linha(rpad(rw_crapsab.nrendsac, 6, ' '),pr_posicini+3016,pr_idarquivo); -- n�mero
               pc_monta_linha(rpad(rw_crapsab.complend,40, ' '),pr_posicini+3022,pr_idarquivo); -- n�mero
               pc_monta_linha(rpad(rw_crapsab.nmbaisac,40, ' '),pr_posicini+3069,pr_idarquivo); -- complemento
               pc_monta_linha(rpad(rw_crapsab.nmcidsac,25, ' '),pr_posicini+3109,pr_idarquivo); -- bairro
               pc_monta_linha(rpad(rw_crapsab.nrcepsac, 8, ' '),pr_posicini+3134,pr_idarquivo); -- cidade
               pc_monta_linha(rpad(rw_crapsab.cdufsaca, 2, ' '),pr_posicini+3147,pr_idarquivo); -- CEP
             END IF;
             --Fechar Cursor
             CLOSE cr_crapsab;
           ELSE
             -- N�o h� dados do sacado para os demais produtos
           pc_monta_linha(' ',pr_posicini+3148,pr_idarquivo);
           END IF;
           
           --Se possuir Conta
           IF vr_tab_crapass.EXISTS(pr_nrdconta) THEN
             --Data Nascimento Conjuge
             vr_dtnasccj:= To_Char(vr_tab_crapass(pr_nrdconta).dtnasccj,'MMDDYYYY');
             --Se Data Nascimento Conjuge
             IF vr_dtnasccj IS NOT NULL THEN
               pc_monta_linha(vr_dtnasccj,pr_posicini+3149,pr_idarquivo);
             END IF;
             --Estado Civil
             IF vr_tab_crapass(pr_nrdconta).cdestcvl = 1 THEN
               vr_dsestcvl:= 'S';
             ELSIF vr_tab_crapass(pr_nrdconta).cdestcvl IN (2,3,4,8,9,11,12) THEN
               vr_dsestcvl:= 'C';
             ELSIF vr_tab_crapass(pr_nrdconta).cdestcvl IN (6,7) THEN
               vr_dsestcvl:= 'D';
             ELSIF vr_tab_crapass(pr_nrdconta).cdestcvl = 5 THEN
               vr_dsestcvl:= 'V';
             ELSE
               vr_dsestcvl:= NULL;
             END IF;
             --Montar a Linha
             pc_monta_linha(vr_dsestcvl,pr_posicini+3157,pr_idarquivo);
             --Se tem titular
             IF vr_crapttl THEN
               pc_monta_linha(rw_crapttl.cdufnatu,pr_posicini+3158,pr_idarquivo);
             END IF;
             pc_monta_linha('BRA',pr_posicini+3160,pr_idarquivo);
           END IF;

           -- Novos campos para o arquivo de _carga_in e _cadastral_in (Melhoria 13)
           -- Rendimento PF
           vr_rendimento:= 0;
           -- Verificamos se existe titular para a conta
           IF vr_crapttl THEN
             vr_rendimento:= NVL(rw_crapttl.vlsalari,   0) +
                             NVL(rw_crapttl.vldrendi##1,0) +
                             NVL(rw_crapttl.vldrendi##2,0) +
                             NVL(rw_crapttl.vldrendi##3,0) +
                             NVL(rw_crapttl.vldrendi##4,0) +
                             NVL(rw_crapttl.vldrendi##5,0) +
                             NVL(rw_crapttl.vldrendi##6,0);
           END IF;
           -- Gera o rendimento do cooperado
           pc_monta_linha(gene0002.fn_mask(vr_rendimento * 100,'999999999999999'),pr_posicini+3163,pr_idarquivo);-- Rendimento PF

           -- Faturamento PJ
           vr_faturamento:= 0;
           -- Busca o valor de faturamento do cooperado
           IF vr_tab_crapjur.EXISTS(pr_nrdconta) THEN
             OPEN cr_busca_faturamento(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta);
             FETCH cr_busca_faturamento INTO rw_faturamento;
             IF cr_busca_faturamento%FOUND THEN
               IF rw_faturamento.valor > 0 THEN
                 -- Somente atualiza o valor se o rendimento � maior que zero
                 vr_faturamento:= rw_faturamento.valor;
               END IF;
             END IF;
           END IF;
           -- Gera o faturamento do cooperado
           pc_monta_linha(gene0002.fn_mask(vr_faturamento *100,'999999999999999'),pr_posicini+3178,pr_idarquivo);-- Faturamento PJ

           -- Posi��o Inicial para colocar a descri��o do bem
           -- Quantidade de Bens Adicionados no arquivo
           vr_qtd_bens:= 0;
           vr_posicini_aux:= 3193;
           -- LOOP para listar os 5 bens de maior valor
           FOR rw_crapbem IN cr_crapbem(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => 1) LOOP

             pc_monta_linha(RPad(NVL(SUBSTR(rw_crapbem.dsrelbem,1,60), ' '),60,' '),pr_posicini+vr_posicini_aux,pr_idarquivo); -- Descri��o do Bem
             -- Incrementar a posi��o inicial auxiliar com o tamanho da descri��o do bem
             vr_posicini_aux:= vr_posicini_aux + 60;
             pc_monta_linha(gene0002.fn_mask(NVL(rw_crapbem.vlrdobem * 100,0),'999999999999999'),pr_posicini+vr_posicini_aux,pr_idarquivo); -- Valor do Bem
             -- Incrementar a posi��o inicial auxiliar com o tamanho do valor do bem
             vr_posicini_aux:= vr_posicini_aux + 15;
             -- Totalizamos a quantidade de bens que est� sendo adicionada no arquivo
             vr_qtd_bens:= vr_qtd_bens + 1;
           END LOOP;

           -- LOOP da quantidade adicionada at� os 5 bens que temos que adicionar
           WHILE vr_qtd_bens < 5 LOOP
             pc_monta_linha(RPad(' ',60,' '),pr_posicini+vr_posicini_aux,pr_idarquivo); -- Descri��o do Bem
             -- Incrementar a posi��o inicial auxiliar com o tamanho da descri��o do bem
             vr_posicini_aux:= vr_posicini_aux + 60;
             pc_monta_linha(gene0002.fn_mask(0,'999999999999999'),pr_posicini+vr_posicini_aux,pr_idarquivo); -- Valor do Bem
             -- Incrementar a posi��o inicial auxiliar com o tamanho do valor do bem
             vr_posicini_aux:= vr_posicini_aux + 15;
             -- Totalizamos a quantidade de bens que est� sendo adicionada no arquivo
             vr_qtd_bens:= vr_qtd_bens + 1;
           END LOOP;

           -- Data de Admiss�o do cooperado
           IF vr_tab_crapass(pr_nrdconta).dtadmiss IS NOT NULL THEN
             pc_monta_linha(to_char(vr_tab_crapass(pr_nrdconta).dtadmiss,'MMDDYYYY'),pr_posicini+3568,pr_idarquivo); -- Admiss�o
           END IF;

           -- Data de Demiss�o do cooperado
           IF vr_tab_crapass(pr_nrdconta).dtdemiss IS NOT NULL THEN
             pc_monta_linha(to_char(vr_tab_crapass(pr_nrdconta).dtdemiss,'MMDDYYYY'),pr_posicini+3576,pr_idarquivo); -- Demiss�o
           END IF;

           -- Situa��o do Cart�o CECRED
           vr_insitcrd:= 0;
           OPEN cr_crawcrd(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta);
           FETCH cr_crawcrd INTO rw_crawcrd;
           IF cr_crawcrd%FOUND THEN
             vr_insitcrd:= NVL(rw_crawcrd.insitcrd,0);
           END IF;
           CLOSE cr_crawcrd;
           pc_monta_linha(gene0002.fn_mask(vr_insitcrd,'99'),pr_posicini+3584,pr_idarquivo); -- Situa��o Cart�o CECRED

           -- Quantidade de cart�es magn�ticos ativos
           OPEN cr_crapcrm(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta);
           FETCH cr_crapcrm INTO rw_crapcrm;
           IF cr_crapcrm%FOUND THEN
             -- Adiciona a quantidade de cart�es magn�tico ativos que o cooperado possui
             pc_monta_linha(gene0002.fn_mask(rw_crapcrm.qtd,'999'),pr_posicini+3586,pr_idarquivo); -- Quantidade de cart�es magn�ticos ativos
           END IF;
           CLOSE cr_crapcrm;

           IF ( vr_tab_crapass(pr_nrdconta).idastcjt = 0) THEN

             -- Situa��o Internet
             vr_cdsitsnh:= 0;
             OPEN cr_crapsnh(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_idseqttl => 1);
             FETCH cr_crapsnh INTO rw_crapsnh;
             IF cr_crapsnh%FOUND THEN
               vr_cdsitsnh:= NVL(rw_crapsnh.cdsitsnh,0);
             END IF;
             CLOSE cr_crapsnh;
           ELSE
             -- Situa��o Internet
             vr_cdsitsnh:= 0;

             OPEN cr_crapsnh_astcjt(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta);
             FETCH cr_crapsnh_astcjt INTO rw_crapsnh_astcjt;
             IF cr_crapsnh_astcjt%FOUND THEN
               vr_cdsitsnh:= NVL(rw_crapsnh_astcjt.cdsitsnh,0);
             END IF;
             CLOSE cr_crapsnh_astcjt;

           END IF;

           pc_monta_linha(gene0002.fn_mask(vr_cdsitsnh,'99'),pr_posicini+3589,pr_idarquivo); -- Situa��o Internet

           -- Escolaridade do cooperado
           vr_dsescola:= NULL;
           -- Verifica se encontrou pessoa fisica
           IF vr_crapttl THEN
             -- Pesquisa a escolaridade
             OPEN cr_gngresc(pr_grescola => rw_crapttl.grescola);
             FETCH cr_gngresc INTO rw_gngresc;
             IF cr_gngresc%FOUND THEN
               vr_dsescola:= SUBSTR(rw_gngresc.dsescola,1,15);
             END IF;
             CLOSE cr_gngresc;
           END IF;
           pc_monta_linha(RPad(NVL(vr_dsescola,' '),15,' '),pr_posicini+3591,pr_idarquivo); -- Escolaridade

           -- Ramo de atividade da empresa do cooperado
           vr_nmrmativ:= NULL;
           --Buscar dados pessoa Juridica
           IF vr_tab_crapjur.EXISTS(pr_nrdconta) THEN
             -- Busca o ramo de atividade
             OPEN cr_gnrativ(pr_cdrmativ => vr_tab_crapjur(pr_nrdconta).cdrmativ);
             FETCH cr_gnrativ INTO rw_gnrativ;
             IF cr_gnrativ%FOUND THEN
               vr_nmrmativ:= SUBSTR(rw_gnrativ.nmrmativ,1,30);
             END IF;
             CLOSE cr_gnrativ;
           END IF;
           pc_monta_linha(RPad(NVL(vr_nmrmativ,' '),30,' '),pr_posicini+3606,pr_idarquivo); -- Ramo de Atividade

         EXCEPTION
           WHEN vr_exc_erro THEN
             pr_cdcritic:= vr_cdcritic;
             pr_dscritic:= vr_dscritic;
           WHEN OTHERS THEN
             --Variavel de erro recebe erro ocorrido
             pr_cdcritic:= 0;
             pr_dscritic:= 'Erro na rotina pc_crps652.pc_gera_carga_MC, Conta: '||pr_nrdconta||'. Erro:'||sqlerrm;
         END;
       END pc_gera_carga_MC;

       --Procedure para Gerar Carga MC - Complementar
       PROCEDURE pc_gera_carga_MC_complem (pr_idarquivo  IN INTEGER               -- ID do arquivo
                                          ,pr_cdcooper   IN crapcyb.cdcooper%type -- Cooperativa
                                          ,pr_cdorigem   IN crapcyb.cdorigem%type -- Origem
                                          ,pr_nrdconta   IN crapcyb.nrdconta%type -- Conta
                                          ,pr_nrctremp   IN crapcyb.nrctremp%type -- Contrato de Emprestimo
                                          ,pr_posicini   IN INTEGER               -- Posi��o Inicial da Informa��o
                                          ,pr_cdcritic  OUT INTEGER               -- Codigo do Erro
                                          ,pr_dscritic  OUT VARCHAR2) IS          -- Descricao do Erro
       BEGIN
         DECLARE
           -- Variaveis locais
           vr_nmassessoria tbcobran_assessorias.nmassessoria%TYPE;
           vr_cdmotivo_cin tbcobran_motivos_cin.cdmotivo%TYPE;
           vr_cdorigem     crapcyc.cdorigem%TYPE;

           /* Cursores Locais */
           --Selecionar Cadastro Cyber
           CURSOR cr_crapcyc (pr_cdcooper IN crapcyc.cdcooper%type
                             ,pr_cdorigem IN crapcyc.cdorigem%type
                             ,pr_nrdconta IN crapcyc.nrdconta%type
                             ,pr_nrctremp IN crapcyc.nrctremp%type) IS
             SELECT crapcyc.cdassess
                   ,tbcobran_assessorias.nmassessoria
                   ,crapcyc.cdmotcin
                   ,tbcobran_assessorias.cdassessoria_cyber
             FROM crapcyc, tbcobran_assessorias
             WHERE tbcobran_assessorias.cdassessoria = crapcyc.cdassess
               AND crapcyc.cdcooper = pr_cdcooper
               AND crapcyc.cdorigem = pr_cdorigem
               AND crapcyc.nrdconta = pr_nrdconta
               AND crapcyc.nrctremp = pr_nrctremp;
           rw_crapcyc cr_crapcyc%ROWTYPE;

         BEGIN
           --Verificar Origem
           IF pr_cdorigem = 2 THEN
             vr_cdorigem:= 3;
           ELSE
             vr_cdorigem:= pr_cdorigem;
           END IF;

           vr_nmassessoria := '';
           vr_cdmotivo_cin := 0;
           OPEN cr_crapcyc(pr_cdcooper => pr_cdcooper
                          ,pr_cdorigem => vr_cdorigem
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctremp => pr_nrctremp);
           FETCH cr_crapcyc INTO rw_crapcyc;
           IF cr_crapcyc%FOUND THEN
             vr_nmassessoria := rw_crapcyc.nmassessoria;
             vr_cdmotivo_cin := rw_crapcyc.cdmotcin;
           END IF;
           CLOSE cr_crapcyc;

           pc_monta_linha(rpad(vr_nmassessoria,50,' '),pr_posicini,pr_idarquivo);-- Nome da Assessoria
           pc_monta_linha(gene0002.fn_mask(vr_cdmotivo_cin,'999'),pr_posicini+50,pr_idarquivo);-- C�digo do Motivo CIN

           OPEN cr_crapenc(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_idseqttl => 1
                          ,pr_tpendass => 14);
           FETCH cr_crapenc INTO rw_crapenc;
           IF cr_crapenc%FOUND THEN
             pc_monta_linha(rpad(rw_crapenc.incasprp,1,' ') ,pr_posicini+53,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.dsendere,40,' '),pr_posicini+54,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nrendere,6,' ') ,pr_posicini+94,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.complend,40,' '),pr_posicini+100,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nrdoapto,4,' ') ,pr_posicini+140,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.cddbloco,3,' ') ,pr_posicini+144,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nmbairro,40,' '),pr_posicini+147,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nmcidade,25,' '),pr_posicini+185,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nrcepend,8,' ') ,pr_posicini+212,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.cdufende,2,' ') ,pr_posicini+220,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nrcxapst,5,' ') ,pr_posicini+222,pr_idarquivo);
           ELSE
             pc_monta_linha(rpad(' ',174,' '),pr_posicini+53,pr_idarquivo);
           END IF;
           CLOSE cr_crapenc;

           OPEN cr_crapenc(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_idseqttl => 1
                          ,pr_tpendass => 13);
           FETCH cr_crapenc INTO rw_crapenc;
           IF cr_crapenc%FOUND THEN
             pc_monta_linha(rpad(rw_crapenc.incasprp,1,' ') ,pr_posicini+227,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.dsendere,40,' '),pr_posicini+228,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nrendere,6,' ') ,pr_posicini+268,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.complend,40,' '),pr_posicini+274,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nrdoapto,4,' ') ,pr_posicini+314,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.cddbloco,3,' ') ,pr_posicini+318,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nmbairro,40,' '),pr_posicini+321,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nmcidade,25,' '),pr_posicini+361,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nrcepend,8,' ') ,pr_posicini+386,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.cdufende,2,' ') ,pr_posicini+394,pr_idarquivo);
             pc_monta_linha(rpad(rw_crapenc.nrcxapst,5,' ') ,pr_posicini+396,pr_idarquivo);
           ELSE
             pc_monta_linha(rpad(' ',174,' '),pr_posicini+227,pr_idarquivo);
           END IF;
           CLOSE cr_crapenc;

           pc_monta_linha(rpad(' ',45,' '),pr_posicini+401,pr_idarquivo);-- Posicoes em branco reservadas para futuros campos
           
           IF pr_idarquivo = 1 THEN
             pc_monta_linha(LPAD(rw_crapcyc.cdassessoria_cyber,8,'0') ,pr_posicini+446,pr_idarquivo);
           END IF;                                

         EXCEPTION
           WHEN OTHERS THEN
             --Variavel de erro recebe erro ocorrido
             pr_cdcritic:= 0;
             pr_dscritic:= 'Erro na rotina pc_crps652.pc_gera_carga_MC_complem. '||sqlerrm;
         END;
       END pc_gera_carga_MC_complem;

       /* Gerar a carga de Garantias */
       PROCEDURE pc_gera_carga_garantias (pr_cdcooper   IN crapcyb.cdcooper%TYPE   --Codigo Cooperativa
                                         ,pr_nrdconta   IN crapcyb.nrdconta%TYPE   --Numero da Conta
                                         ,pr_nrctremp   IN crapcyb.nrctremp%TYPE   --Contrato Emprestimo
                                         ,pr_rw_crapcyb IN cr_crapcyb%ROWTYPE      --Registro Cyber
                                         ,pr_flgtemlcr  OUT BOOLEAN                --Encontrou craplcr
                                         ,pr_cdcritic   OUT INTEGER                --Codigo Erro
                                         ,pr_dscritic   OUT VARCHAR2) IS           --Descricao Erro
       BEGIN
         DECLARE
           /* Cursores Locais */

           --Selecionar bens da proposta emprestimo
           CURSOR cr_crapbpr (pr_cdcooper IN crapbpr.cdcooper%type
                             ,pr_nrdconta IN crapbpr.nrdconta%type
                             ,pr_nrctremp IN crapbpr.nrctrpro%type) IS
             SELECT /*+ PARALLEL (crapepr,4,1) */
                    crapbpr.dscatbem
                   ,crapbpr.dsrelbem
                   ,crapbpr.idseqbem
                   ,crapbpr.dsbemfin
                   ,crapbpr.dscorbem
                   ,crapbpr.nrcpfbem
                   ,crapbpr.cdcooper
                   ,crapbpr.vlmerbem
                   ,crapbpr.dschassi
                   ,crapbpr.ufdplaca
                   ,crapbpr.nrdplaca
                   ,crapbpr.nrrenava
                   ,crapbpr.nranobem
                   ,crapbpr.nrmodbem
                   ,craplcr.tpctrato
             FROM crapbpr, crapepr, craplcr
             WHERE  craplcr.cdcooper = crapepr.cdcooper
             AND    craplcr.cdlcremp = crapepr.cdlcremp
             AND    craplcr.tpctrato IN (2,3)
             AND    crapepr.cdcooper = crapbpr.cdcooper
             AND    crapepr.nrctremp = crapbpr.nrctrpro
             AND    crapepr.nrdconta = crapbpr.nrdconta
             AND    crapbpr.cdcooper = pr_cdcooper
             AND    crapbpr.nrdconta = pr_nrdconta
             AND    crapbpr.nrctrpro = pr_nrctremp
             AND    crapbpr.tpctrpro = 90
             AND    crapbpr.flgalien = 1
             AND    TRIM(crapbpr.dscatbem) IS NOT NULL;
           --Selecionar Numeros Telefones
           CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%type
                             ,pr_nrdconta IN craptfc.nrdconta%type
                             ,pr_idseqttl IN craptfc.idseqttl%type
                             ,pr_tptelefo IN craptfc.tptelefo%type) IS
             SELECT craptfc.nrdddtfc
                   ,craptfc.nrtelefo
                   ,craptfc.cdcooper
                   ,craptfc.nrdconta
                   ,craptfc.idseqttl
                   ,craptfc.progress_recid
             FROM craptfc
             WHERE craptfc.cdcooper = pr_cdcooper
             AND   craptfc.nrdconta = pr_nrdconta
             AND   craptfc.idseqttl = pr_idseqttl
             AND   craptfc.tptelefo = pr_tptelefo
             AND   craptfc.idsittfc = 1
             ORDER BY craptfc.progress_recid ASC;
           rw_craptfc cr_craptfc%ROWTYPE;
           --Selecionar Numeros Telefones
           CURSOR cr_craptfc_next (pr_cdcooper IN craptfc.cdcooper%type
                                  ,pr_nrdconta IN craptfc.nrdconta%type
                                  ,pr_idseqttl IN craptfc.idseqttl%type
                                  ,pr_progress_recid IN craptfc.progress_recid%type) IS
             SELECT craptfc.nrdddtfc
                   ,craptfc.nrtelefo
                   ,craptfc.cdcooper
                   ,craptfc.nrdconta
                   ,craptfc.idseqttl
                   ,craptfc.progress_recid
             FROM craptfc
             WHERE craptfc.cdcooper = pr_cdcooper
             AND   craptfc.nrdconta = pr_nrdconta
             AND   craptfc.idseqttl = pr_idseqttl
             AND   craptfc.progress_recid > pr_progress_recid /*next*/
             AND   craptfc.idsittfc = 1
             ORDER BY craptfc.progress_recid ASC;
           rw_craptfc_next cr_craptfc_next%ROWTYPE;
           
           CURSOR cr_garant (pr_cdcooper IN crawepr.cdcooper%TYPE
                            ,pr_nrdconta IN crawepr.nrdconta%TYPE
                            ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
             SELECT wpr.idcobope
               FROM crawepr wpr
              WHERE wpr.cdcooper = pr_cdcooper
                AND wpr.nrdconta = pr_nrdconta
                AND wpr.nrctremp = pr_nrctremp
              UNION ALL
             SELECT l.idcobope
               FROM craptdb tdb
              INNER join craplim l -- para buscar os avalistas do t�tulo
                 ON l.cdcooper = tdb.cdcooper
                AND l.nrdconta = tdb.nrdconta
                AND l.nrctrlim = tdb.nrctrlim
              INNER JOIN tbdsct_titulo_cyber tcy
                 ON tcy.cdcooper = tdb.cdcooper
                AND tcy.nrdconta = tdb.nrdconta
                AND tcy.nrborder = tdb.nrborder
                AND tcy.nrtitulo = tdb.nrtitulo
               WHERE tcy.cdcooper = pr_cdcooper
                AND tcy.nrdconta = pr_nrdconta
                AND tcy.nrctrdsc = pr_nrctremp
                AND tdb.insittit = 4;
           
           vr_idcobope    crawepr.idcobope%TYPE;
           vr_vlcobert    NUMBER := 0;
           vr_vlroriginal NUMBER;
           vr_nrcpfcnpj   NUMBER;

           --Variaveis Locais
           vr_atributo INTEGER;
           vr_craptfc  BOOLEAN;
           vr_crapenc  BOOLEAN;
           --Variaveis de Excecao
           vr_exc_erro EXCEPTION;
           --Variaveis Erro
           vr_cdcritic INTEGER;
           vr_dscritic VARCHAR2(4000);
         BEGIN
           --Limpar parametros erro
           pr_cdcritic:= NULL;
           pr_dscritic:= NULL;
           pr_flgtemlcr:= FALSE;
           --Selecionar bens da proposta de emprestimo
           FOR rw_crapbpr IN cr_crapbpr (pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrctremp => pr_nrctremp) LOOP
             --Retornar que encontrou craplcr
             pr_flgtemlcr:= TRUE;
             --Selecionar telefones
             OPEN cr_craptfc (pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_idseqttl => 1
                             ,pr_tptelefo => 1); /* Residencial */
             FETCH cr_craptfc INTO rw_craptfc;
             --Se encontrou
             vr_craptfc:= cr_craptfc%FOUND;
             CLOSE cr_craptfc;
             --Buscar Categoria Bem
             vr_dscatcyb:= fn_busca_categoria_bem(pr_dscatbem => upper(rw_crapbpr.dscatbem));
             --Montar linha
             pc_monta_linha('1',1,4);
             pc_monta_linha('1',2,4);
             pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdcooper,'9999'),3,4);
             pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdorigem,'9999'),7,4);
             pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrdconta,'99999999'),11,4);
             pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrctremp,'99999999'),19,4);
             pc_monta_linha(gene0002.fn_mask(rw_crapbpr.idseqbem,'zzzzzzzz9'),28,4);
             pc_monta_linha(RPad(vr_dscatcyb,30,' '),37,4);
             --Bem possui descricao
             IF trim(rw_crapbpr.dsbemfin) IS NOT NULL THEN
               pc_monta_linha(RPad(rw_crapbpr.dsbemfin,600,' '),187,4);
             ELSE
               pc_monta_linha(RPad(rw_crapbpr.dsrelbem,600,' '),187,4);
             END IF;
             --Valor Mercado Bem
             pc_monta_linha(to_char(rw_crapbpr.vlmerbem*100,'00000000000000'),827,4);
             pc_monta_linha('REAL',842,4);
             pc_monta_linha(RPad(' ',41,' '),846,4);
              --Gravar linha no arquivo
           pc_escreve_dado(NULL,4,pr_rw_crapcyb.dsdchave);

             /* HIPOTECA */
             IF rw_crapbpr.tpctrato = 3 THEN
               CASE Upper(rw_crapbpr.dscatbem)
                 WHEN 'APARTAMENTO' THEN
                   vr_tab_idatribu(1):= 435;
                   vr_tab_idatribu(2):= 436;
                   vr_tab_idatribu(3):= 437;
                 WHEN 'CASA' THEN
                   vr_tab_idatribu(1):= 448;
                   vr_tab_idatribu(2):= 449;
                   vr_tab_idatribu(3):= 450;
                 WHEN 'TERRENO' THEN
                   vr_tab_idatribu(1):= 471;
                   vr_tab_idatribu(2):= 472;
                   vr_tab_idatribu(3):= 473;
                 ELSE NULL;
               END CASE;
               --Indice
               FOR vr_nrindice IN 1..3 LOOP
                 --Montar Linha
                 pc_monta_linha('2',1,4);
                 pc_monta_linha('1',2,4);
                 pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdcooper,'9999'),3,4);
                 pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdorigem,'9999'),7,4);
                 pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrdconta,'99999999'),11,4);
                 pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrctremp,'99999999'),19,4);
                 pc_monta_linha(gene0002.fn_mask(rw_crapbpr.idseqbem,'zzzzzzzz9'),28,4);
                 pc_monta_linha(RPad(vr_dscatcyb,10,' '),37,4);
                 pc_monta_linha(gene0002.fn_mask(vr_tab_idatribu(vr_nrindice),'zzzzzz9'),47,4);
                 CASE vr_nrindice
                   WHEN 1 THEN
                     pc_monta_linha(RPad(rw_crapbpr.dsbemfin,100,' '),54,4);
                     pc_monta_linha(RPad(' ',30,'0'),154,4);
                     pc_monta_linha(RPad(' ',17,' '),184,4);
                   WHEN 2 THEN
                     pc_monta_linha(RPad(rw_crapbpr.dscatbem,100,' '),54,4);
                     pc_monta_linha(RPad(' ',30,'0'),154,4);
                     pc_monta_linha(RPad(' ',17,' '),184,4);
                   ELSE
                     pc_monta_linha(to_char(rw_crapbpr.vlmerbem*1000000,'00000000000000000000000000000'),154,4);
                     pc_monta_linha(RPad(' ',17,' '),184,4);
                 END CASE;
                 --Gravar linha no arquivo
               pc_escreve_dado(NULL,4,pr_rw_crapcyb.dsdchave);
               END LOOP;
               --Se nao possuir cor
               IF trim(rw_crapbpr.dscorbem) IS NULL THEN
                 --Encontrar Associado
                 IF vr_tab_crapass.EXISTS(pr_nrdconta) THEN
                   --Se o cpf da conta igual do bem ou o bem for nulo
                   IF vr_tab_crapass(pr_nrdconta).nrcpfcgc = rw_crapbpr.nrcpfbem OR Nvl(rw_crapbpr.nrcpfbem,0) = 0 THEN
                     --Pessoa Fisica
                     IF vr_tab_crapass(pr_nrdconta).inpessoa = 1 THEN
                       --Tipo Endereco
                       vr_tpendass:= 10; /* RESIDENCIAL */
                   ELSE
                       vr_tpendass:= 9; /* COMERCIAL */
                     END IF;
                     --Endereco
                     OPEN cr_crapenc (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => vr_tab_crapass(pr_nrdconta).nrdconta
                                     ,pr_idseqttl => 1
                                     ,pr_tpendass => vr_tpendass);
                     --Posicionar primeiro registro
                     FETCH cr_crapenc INTO rw_crapenc;
                     --Verificar se encontrou
                     vr_crapenc:= cr_crapenc%FOUND;
                     --Fechar Cursor
                     CLOSE cr_crapenc;
                   ELSE
                     --Selecionar Associado pelo CPF
                     OPEN cr_crapass_cpf (pr_cdcooper => rw_crapbpr.cdcooper
                                         ,pr_nrcpfcgc => rw_crapbpr.nrcpfbem);
                     --Posicionar Primeiro registro
                     FETCH cr_crapass_cpf INTO rw_crapass_cpf;
                     --Se encontrou
                     IF cr_crapass_cpf%FOUND THEN
                       --Pessoa Fisica
                       IF rw_crapass_cpf.inpessoa = 1 THEN
                         --Tipo Endereco
                         vr_tpendass:= 10; /* RESIDENCIAL */
                     ELSE
                         vr_tpendass:= 9; /* COMERCIAL */
                       END IF;
                       --Endereco
                       OPEN cr_crapenc (pr_cdcooper => rw_crapass_cpf.cdcooper
                                       ,pr_nrdconta => rw_crapass_cpf.nrdconta
                                       ,pr_idseqttl => 1
                                       ,pr_tpendass => vr_tpendass);
                       --Posicionar primeiro registro
                       FETCH cr_crapenc INTO rw_crapenc;
                       --Verificar se encontrou
                       vr_crapenc:= cr_crapenc%FOUND;
                       --Fechar Cursor
                       CLOSE cr_crapenc;
                     else
                       vr_crapenc := false;
                     END IF;
                     --Fechar Cursor
                     CLOSE cr_crapass_cpf;
                   END IF;
                   --Montar Linha
                   pc_monta_linha('3',1,4);
                   pc_monta_linha('1',2,4);
                   pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdcooper,'9999'),3,4);
                   pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdorigem,'9999'),7,4);
                   pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrdconta,'99999999'),11,4);
                   pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrctremp,'99999999'),19,4);
                   pc_monta_linha(gene0002.fn_mask(rw_crapbpr.idseqbem,'zzzzzzzz9'),28,4);
                   --Se possui endereco
                   IF vr_crapenc THEN
                     pc_monta_linha(RPad(rw_crapenc.dsendere||', '||rw_crapenc.nrendere,80,' '),37,4);
                     pc_monta_linha(RPad(rw_crapenc.nmbairro,80,' '),117,4);
                     pc_monta_linha(RPad(rw_crapenc.nmcidade,30,' '),197,4);
                     pc_monta_linha(RPad(rw_crapenc.nrcxapst,10,' '),227,4);
                     pc_monta_linha(RPad(rw_crapenc.cdufende,30,' '),237,4);
                     pc_monta_linha(RPad('BRASIL',30,' '),267,4);
                   END IF;
                   --Se possuir telefone
                   IF vr_craptfc THEN
                     pc_monta_linha(RPad(rw_craptfc.nrdddtfc||rw_craptfc.nrtelefo,25,' '),297,4);
                   ELSE
                     pc_monta_linha(RPad(' ',25,' '),297,4);
                   END IF;
                   --Selecionar Proximo Telefone
                   OPEN cr_craptfc_next(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => 1
                                       ,pr_progress_recid => nvl(rw_craptfc.progress_recid, 0));
                   FETCH cr_craptfc_next INTO rw_craptfc_next;
                   --Se Encontrou
                   IF cr_craptfc_next%FOUND THEN
                     pc_monta_linha(RPad(rw_craptfc_next.nrdddtfc||rw_craptfc_next.nrtelefo,25,' '),322,4);
                   ELSE
                     pc_monta_linha(RPad(' ',25,' '),322,4);
                   END IF;
                   --Fechar Cursor
                   CLOSE cr_craptfc_next;
                   --Escrever Linha Arquivo
                 pc_escreve_dado(NULL,4,pr_rw_crapcyb.dsdchave);
                 END IF;
               ELSE
                 --Montar Linha
                 pc_monta_linha('3',1,4);
                 pc_monta_linha('1',2,4);
                 pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdcooper,'9999'),3,4);
                 pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdorigem,'9999'),7,4);
                 pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrdconta,'99999999'),11,4);
                 pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrctremp,'99999999'),19,4);
                 pc_monta_linha(gene0002.fn_mask(rw_crapbpr.idseqbem,'zzzzzzzz9'),28,4);
                 pc_monta_linha(rpad(rw_crapbpr.dscorbem,80,' '),37,4);
                 pc_monta_linha(RPad('BRASIL',30,' '),267,4);
                 --Se possuir telefone
                 IF vr_craptfc THEN
                   pc_monta_linha(RPad(rw_craptfc.nrdddtfc||rw_craptfc.nrtelefo,25,' '),297,4);
                 ELSE
                   pc_monta_linha(RPad(' ',25,' '),297,4);
                 END IF;
                 --Selecionar Proximo Telefone
                 OPEN cr_craptfc_next(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_idseqttl => 1
                                     ,pr_progress_recid => nvl(rw_craptfc.progress_recid, 0));
                 FETCH cr_craptfc_next INTO rw_craptfc_next;
                 --Se Encontrou
                 IF cr_craptfc_next%FOUND THEN
                   pc_monta_linha(RPad(rw_craptfc_next.nrdddtfc||rw_craptfc_next.nrtelefo,25,' '),322,4);
                 ELSE
                   pc_monta_linha(RPad(' ',25,' '),322,4);
                 END IF;
                 --Fechar Cursor
                 CLOSE cr_craptfc_next;
                 --Escrever Linha no Arquivo
               pc_escreve_dado(NULL,4,pr_rw_crapcyb.dsdchave);
               END IF;
             ELSE
               /* ALIENACAO */
               IF rw_crapbpr.tpctrato = 2 THEN

                 CASE Upper(rw_crapbpr.dscatbem)
                   WHEN 'APARTAMENTO' THEN
                     vr_tab_idatribu(1):= 435;
                     vr_tab_idatribu(2):= 436;
                     vr_tab_idatribu(3):= 437;
                   WHEN 'CASA' THEN
                     vr_tab_idatribu(1):= 448;
                     vr_tab_idatribu(2):= 449;
                     vr_tab_idatribu(3):= 450;
                   WHEN 'TERRENO' THEN
                     vr_tab_idatribu(1):= 471;
                     vr_tab_idatribu(2):= 472;
                     vr_tab_idatribu(3):= 473;
                   WHEN 'CAMINHAO' THEN
                     vr_atributo:= 438;
                     FOR idx IN 1..10 LOOP
                       vr_tab_idatribu(idx):= vr_atributo;
                       vr_atributo:= vr_atributo + 1;
                     END LOOP;
                   WHEN 'OUTROS VEICULOS' THEN
                     vr_atributo:= 438;
                     FOR idx IN 1..10 LOOP
                       vr_tab_idatribu(idx):= vr_atributo;
                       vr_atributo:= vr_atributo + 1;
                     END LOOP;
                   WHEN 'EQUIPAMENTO' THEN
                     vr_atributo:= 451;
                     FOR idx IN 1..10 LOOP
                       vr_tab_idatribu(idx):= vr_atributo;
                       vr_atributo:= vr_atributo + 1;
                     END LOOP;
                   WHEN 'MOTO' THEN
                     vr_atributo:= 461;
                     FOR idx IN 1..10 LOOP
                       vr_tab_idatribu(idx):= vr_atributo;
                       vr_atributo:= vr_atributo + 1;
                     END LOOP;
                   WHEN 'MAQUINA DE COSTURA' THEN
                     vr_atributo:= 474;
                     FOR idx IN 1..8 LOOP
                       vr_tab_idatribu(idx):= vr_atributo;
                       vr_atributo:= vr_atributo + 1;
                     END LOOP;
                   WHEN 'AUTOMOVEL' THEN
                     vr_atributo:= 425;
                     FOR idx IN 1..10 LOOP
                       vr_tab_idatribu(idx):= vr_atributo;
                       vr_atributo:= vr_atributo + 1;
                     END LOOP;
                   ELSE NULL;
                 END CASE;
                 --Categoria do Bem
                 IF rw_crapbpr.dscatbem IN ('CASA','APARTAMENTO','TERRENO') THEN
                   --Indice
                   FOR vr_nrindice IN 1..3 LOOP
                     --Montar Linha
                     pc_monta_linha('2',1,4);
                     pc_monta_linha('1',2,4);
                     pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdcooper,'9999'),3,4);
                     pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdorigem,'9999'),7,4);
                     pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrdconta,'99999999'),11,4);
                     pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrctremp,'99999999'),19,4);
                     pc_monta_linha(gene0002.fn_mask(rw_crapbpr.idseqbem,'zzzzzzzz9'),28,4);
                     pc_monta_linha(RPad(vr_dscatcyb,10,' '),37,4);
                     pc_monta_linha(gene0002.fn_mask(vr_tab_idatribu(vr_nrindice),'zzzzzz9'),47,4);
                     CASE vr_nrindice
                       WHEN 1 THEN
                         pc_monta_linha(RPad(rw_crapbpr.dsbemfin,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 2 THEN
                         pc_monta_linha(RPad(rw_crapbpr.dscatbem,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       ELSE
                         pc_monta_linha(to_char(rw_crapbpr.vlmerbem*1000000,'00000000000000000000000000000'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                     END CASE;
                     --Concatenar Quebra de linha no clob
                     vr_setlinha:= vr_setlinha;
                     --Gravar linha no arquivo
                   pc_escreve_dado(vr_setlinha,4,pr_rw_crapcyb.dsdchave);
                   END LOOP;
                 END IF;

                 --Categoria do Bem
                 IF rw_crapbpr.dscatbem = 'EQUIPAMENTO' OR grvm0001.fn_valida_categoria_alienavel(rw_crapbpr.dscatbem) = 'S' THEN
                   --Indice
                   FOR vr_nrindice IN 1..10 LOOP
                     --Montar Linha
                     pc_monta_linha('2',1,4);
                     pc_monta_linha('1',2,4);
                     pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdcooper,'9999'),3,4);
                     pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdorigem,'9999'),7,4);
                     pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrdconta,'99999999'),11,4);
                     pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrctremp,'99999999'),19,4);
                     pc_monta_linha(gene0002.fn_mask(rw_crapbpr.idseqbem,'zzzzzzzz9'),28,4);
                     pc_monta_linha(RPad(vr_dscatcyb,10,' '),37,4);
                     pc_monta_linha(gene0002.fn_mask(vr_tab_idatribu(vr_nrindice),'zzzzzz9'),47,4);
                     CASE vr_nrindice
                       WHEN 1 THEN
                         pc_monta_linha(RPad(rw_crapbpr.dsbemfin,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 2 THEN
                         pc_monta_linha(RPad(rw_crapbpr.dscatbem,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 3 THEN
                         pc_monta_linha(RPad(rw_crapbpr.dscorbem,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 4 THEN
                         pc_monta_linha(RPad(' ',100,' '),54,4);
                         pc_monta_linha(to_char(rw_crapbpr.vlmerbem*1000000,'00000000000000000000000000000'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 5 THEN
                         pc_monta_linha(RPad(rw_crapbpr.dschassi,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 6 THEN
                         pc_monta_linha(RPad(trim(rw_crapbpr.ufdplaca)||'/'||rw_crapbpr.nrdplaca,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 7 THEN
                         pc_monta_linha(RPad(rw_crapbpr.nrrenava,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 8 THEN
                         --Buscar cpf/cgc
                         vr_nrcpfcgc:= fn_busca_cpfcgc (pr_nrcpfcgc => rw_crapbpr.nrcpfbem);
                         pc_monta_linha(RPad(vr_nrcpfcgc,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 9 THEN
                         pc_monta_linha(RPad(rw_crapbpr.nranobem,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 10 THEN
                         pc_monta_linha(RPad(rw_crapbpr.nrmodbem,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                     END CASE;
                     --Gravar linha no arquivo
                   pc_escreve_dado(NULL,4,pr_rw_crapcyb.dsdchave);
                   END LOOP;
                 END IF;
                 --Categoria Bem
                 IF rw_crapbpr.dscatbem = 'MAQUINA DE COSTURA' THEN
                   --Indice
                   FOR vr_nrindice IN 1..8 LOOP
                     --Montar Linha
                     pc_monta_linha('2',1,4);
                     pc_monta_linha('1',2,4);
                     pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdcooper,'9999'),3,4);
                     pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdorigem,'9999'),7,4);
                     pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrdconta,'99999999'),11,4);
                     pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrctremp,'99999999'),19,4);
                     pc_monta_linha(gene0002.fn_mask(rw_crapbpr.idseqbem,'zzzzzzzz9'),28,4);
                     pc_monta_linha(RPad(vr_dscatcyb,10,' '),37,4);
                     pc_monta_linha(gene0002.fn_mask(vr_tab_idatribu(vr_nrindice),'zzzzzz9'),47,4);
                     CASE vr_nrindice
                       WHEN 1 THEN
                         pc_monta_linha(RPad(rw_crapbpr.dsbemfin,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 2 THEN
                         pc_monta_linha(RPad(rw_crapbpr.dscatbem,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 3 THEN
                         pc_monta_linha(RPad(rw_crapbpr.dscorbem,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 4 THEN
                         pc_monta_linha(RPad(' ',100,' '),54,4);
                         pc_monta_linha(to_char(rw_crapbpr.vlmerbem*1000000,'00000000000000000000000000000'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 5 THEN
                         pc_monta_linha(RPad(rw_crapbpr.dschassi,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 6 THEN
                         --Buscar cpf/cgc
                         vr_nrcpfcgc:= fn_busca_cpfcgc (pr_nrcpfcgc => rw_crapbpr.nrcpfbem);
                         pc_monta_linha(RPad(vr_nrcpfcgc,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 7 THEN
                         pc_monta_linha(RPad(rw_crapbpr.nranobem,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                       WHEN 8 THEN
                         pc_monta_linha(RPad(rw_crapbpr.nrmodbem,100,' '),54,4);
                         pc_monta_linha(RPad(' ',30,'0'),154,4);
                         pc_monta_linha(RPad(' ',17,' '),184,4);
                     END CASE;
                     --Gravar linha no arquivo
                   pc_escreve_dado(NULL,4,pr_rw_crapcyb.dsdchave);
                   END LOOP;
                 END IF;
                 --Se Existe associado
                 IF vr_tab_crapass.EXISTS(pr_nrdconta) then
                   -- Mesmo CPF ou bem sem cpf
                   if vr_tab_crapass(pr_nrdconta).nrcpfcgc = rw_crapbpr.nrcpfbem OR Nvl(rw_crapbpr.nrcpfbem,0) = 0 THEN
                     --Pessoa Fisica
                     IF vr_tab_crapass(pr_nrdconta).inpessoa = 1 THEN
                       --Tipo Endereco
                       vr_tpendass:= 10; /* RESIDENCIAL */
                   ELSE
                       vr_tpendass:= 9; /* COMERCIAL */
                     END IF;
                     --Endereco
                     OPEN cr_crapenc (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_idseqttl => 1
                                     ,pr_tpendass => vr_tpendass);
                     --Posicionar primeiro registro
                     FETCH cr_crapenc INTO rw_crapenc;
                     --Verificar se encontrou
                     vr_crapenc:= cr_crapenc%FOUND;
                     --Fechar Cursor
                     CLOSE cr_crapenc;
                   ELSE
                     --Selecionar Associado pelo CPF
                     OPEN cr_crapass_cpf (pr_cdcooper => rw_crapbpr.cdcooper
                                         ,pr_nrcpfcgc => rw_crapbpr.nrcpfbem);
                     --Posicionar Primeiro registro
                     FETCH cr_crapass_cpf INTO rw_crapass_cpf;
                     --Se encontrou
                     IF cr_crapass_cpf%FOUND THEN
                       --Pessoa Fisica
                       IF rw_crapass_cpf.inpessoa = 1 THEN
                         --Tipo Endereco
                         vr_tpendass:= 10; /* RESIDENCIAL */
                     ELSE
                         vr_tpendass:= 9; /* COMERCIAL */
                       END IF;
                       --Endereco
                       OPEN cr_crapenc (pr_cdcooper => rw_crapass_cpf.cdcooper
                                       ,pr_nrdconta => rw_crapass_cpf.nrdconta
                                       ,pr_idseqttl => 1
                                       ,pr_tpendass => vr_tpendass);
                       --Posicionar primeiro registro
                       FETCH cr_crapenc INTO rw_crapenc;
                       --Verificar se encontrou
                       vr_crapenc:= cr_crapenc%FOUND;
                       --Fechar Cursor
                       CLOSE cr_crapenc;
                     else
                       vr_crapenc := false;
                     END IF;
                     --Fechar Cursor
                     CLOSE cr_crapass_cpf;
                   end if;
                 else
                   vr_crapenc := false;
                 END IF;

                 --Montar Linha
                 pc_monta_linha('3',1,4);
                 pc_monta_linha('1',2,4);
                 pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdcooper,'9999'),3,4);
                 pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdorigem,'9999'),7,4);
                 pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrdconta,'99999999'),11,4);
                 pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrctremp,'99999999'),19,4);
                 pc_monta_linha(gene0002.fn_mask(rw_crapbpr.idseqbem,'zzzzzzzz9'),28,4);

                 --Se possuir Endereco
                 IF vr_crapenc THEN
                   pc_monta_linha(rpad(rw_crapenc.dsendere|| ', '||rw_crapenc.nrendere,80,' '),37,4);
                   pc_monta_linha(RPad(rw_crapenc.nmbairro,80,' '),117,4);
                   pc_monta_linha(RPad(rw_crapenc.nmcidade,30,' '),197,4);
                   pc_monta_linha(RPad(rw_crapenc.nrcxapst,10,' '),227,4);
                   pc_monta_linha(RPad(rw_crapenc.cdufende,30,' '),237,4);
                   pc_monta_linha(RPad('BRASIL',30,' '),267,4);
                 END IF;
                 --Se possuir Telefone
                 IF vr_craptfc THEN
                   pc_monta_linha(RPad(rw_craptfc.nrdddtfc||rw_craptfc.nrtelefo,25,' '),297,4);
                 ELSE
                   pc_monta_linha(RPad(' ',25,' '),297,4);
                 END IF;
                 --Selecionar Proximo Telefone
                 OPEN cr_craptfc_next(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_idseqttl => 1
                                     ,pr_progress_recid => nvl(rw_craptfc.progress_recid, 0));
                 FETCH cr_craptfc_next INTO rw_craptfc_next;
                 --Se Encontrou
                 IF cr_craptfc_next%FOUND THEN
                   pc_monta_linha(RPad(rw_craptfc_next.nrdddtfc||rw_craptfc_next.nrtelefo,25,' '),322,4);
                 ELSE
                   pc_monta_linha(RPad(' ',25,' '),322,4);
                 END IF;
                 --Fechar Cursor
                 CLOSE cr_craptfc_next;
                 --Escrever Linha Arquivo
               pc_escreve_dado(NULL,4,pr_rw_crapcyb.dsdchave);
               END IF; --rw_crapbpr.tpctrato = 2
             END IF;  --rw_crapbpr.tpctrato = 3
           END LOOP;
           
           OPEN cr_garant(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrctremp => pr_nrctremp);
           FETCH cr_garant INTO vr_idcobope;
          
           -- Se encontrar
           IF cr_garant%FOUND THEN
             CLOSE cr_garant;
             
             -- Acionaremos fun��o para retornar se h� valor de cobertura
             BLOQ0001.pc_bloqueio_garantia_atualizad(pr_idcobert            => vr_idcobope
                                                    ,pr_vlroriginal         => vr_vlroriginal
                                                    ,pr_vlratualizado       => vr_vlcobert
                                                    ,pr_nrcpfcnpj_cobertura => vr_nrcpfcnpj
                                                    ,pr_dscritic            => vr_dscritic);
             -- Se h� valor de Bloqueio
             IF vr_vlcobert > 0 THEN
               -- Categoria Bem Fixa
               vr_dscatcyb:= 'APLICACAO';
               
               -- Montar linha
               pc_monta_linha('1',1,4);
               pc_monta_linha('1',2,4);
               pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdcooper,'9999'),3,4);
               pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdorigem,'9999'),7,4);
               pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrdconta,'99999999'),11,4);
               pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrctremp,'99999999'),19,4);
               pc_monta_linha(gene0002.fn_mask(0,'zzzzzzzz9'),28,4); -- Fixo ID 0
               pc_monta_linha(RPad(vr_dscatcyb,30,' '),37,4); -- Fixo APLICACAO
               
               -- Descri��o
               pc_monta_linha(RPad('APLICACAO VINCULADA',600,' '),187,4);
               
               -- Valor Atualizado Bem
               pc_monta_linha(to_char(vr_vlcobert*100,'00000000000000'),827,4);
               pc_monta_linha('REAL',842,4);
               pc_monta_linha(RPad(' ',41,' '),846,4);
               
               --Gravar linha no arquivo
             pc_escreve_dado(NULL,4,pr_rw_crapcyb.dsdchave);
               
               --Montar Linha
               pc_monta_linha('2',1,4);
               pc_monta_linha('1',2,4);
               pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdcooper,'9999'),3,4);
               pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdorigem,'9999'),7,4);
               pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrdconta,'99999999'),11,4);
               pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrctremp,'99999999'),19,4);
               pc_monta_linha(gene0002.fn_mask(0,'zzzzzzzz9'),28,4); -- Fixo ID 0
               pc_monta_linha(RPad(vr_dscatcyb,10,' '),37,4); -- Fixo APLICACAO
               
               -- Codigo
               pc_monta_linha(gene0002.fn_mask(482,'zzzzzz9'),47,4);
               
               -- Atributos
               pc_monta_linha(RPad('APLICACAO VINCULADA',100,' '),54,4);
               pc_monta_linha(RPad(' ',29,'0'),141,4);
               pc_monta_linha(RPad(' ',31,' '),170,4);
               
               -- Gravar linha no arquivo
             pc_escreve_dado(NULL,4,pr_rw_crapcyb.dsdchave);
               
               -- Se Existe associado
               IF vr_tab_crapass.EXISTS(pr_nrdconta) then
                 -- Mesmo CPF ou bem sem cpf
                 IF vr_tab_crapass(pr_nrdconta).nrcpfcgc = vr_nrcpfcnpj OR vr_nrcpfcnpj IS NULL THEN
                   
                   --Pessoa Fisica
                   IF vr_tab_crapass(pr_nrdconta).inpessoa = 1 THEN
                     --Tipo Endereco
                     vr_tpendass:= 10; /* RESIDENCIAL */
                 ELSE
                     vr_tpendass:= 9; /* COMERCIAL */
                   END IF;
                   
                   --Endereco
                   OPEN cr_crapenc(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => 1
                                  ,pr_tpendass => vr_tpendass);
                   
                   --Posicionar primeiro registro
                   FETCH cr_crapenc INTO rw_crapenc;
                   
                   --Verificar se encontrou
                   vr_crapenc:= cr_crapenc%FOUND;
                   
                   --Fechar Cursor
                   CLOSE cr_crapenc;
                   
                 ELSE
                   
                   --Selecionar Associado pelo CPF
                   OPEN cr_crapass_cpf(pr_cdcooper => pr_cdcooper
                                      ,pr_nrcpfcgc => vr_nrcpfcnpj);
                   
                   --Posicionar Primeiro registro
                   FETCH cr_crapass_cpf INTO rw_crapass_cpf;
                   
                   --Se encontrou
                   IF cr_crapass_cpf%FOUND THEN
                     --Pessoa Fisica
                     IF rw_crapass_cpf.inpessoa = 1 THEN
                       --Tipo Endereco
                       vr_tpendass:= 10; /* RESIDENCIAL */
                   ELSE
                       vr_tpendass:= 9; /* COMERCIAL */
                     END IF;
                     --Endereco
                     OPEN cr_crapenc(pr_cdcooper => rw_crapass_cpf.cdcooper
                                    ,pr_nrdconta => rw_crapass_cpf.nrdconta
                                    ,pr_idseqttl => 1
                                    ,pr_tpendass => vr_tpendass);
                     --Posicionar primeiro registro
                     FETCH cr_crapenc INTO rw_crapenc;
                     --Verificar se encontrouvr_crapenc:= cr_crapenc%FOUND;
                     --Fechar Cursor
                     CLOSE cr_crapenc;
                   ELSE
                     vr_crapenc := false;
                   END IF;
                   
                   --Fechar Cursor
                   CLOSE cr_crapass_cpf;
                   
                 END IF;
               ELSE
                 vr_crapenc := false;
               END IF;
               
               --Montar Linha
               pc_monta_linha('3',1,4);
               pc_monta_linha('1',2,4);
               pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdcooper,'9999'),3,4);
               pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.cdorigem,'9999'),7,4);
               pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrdconta,'99999999'),11,4);
               pc_monta_linha(gene0002.fn_mask(pr_rw_crapcyb.nrctremp,'99999999'),19,4);
               pc_monta_linha(gene0002.fn_mask(0,'zzzzzzzz9'),28,4); -- Fixo ID 0
               
               --Se possuir Endereco
               IF vr_crapenc THEN
                 pc_monta_linha(rpad(rw_crapenc.dsendere|| ', '||rw_crapenc.nrendere,80,' '),37,4);
                 pc_monta_linha(RPad(rw_crapenc.nmbairro,80,' '),117,4);
                 pc_monta_linha(RPad(rw_crapenc.nmcidade,30,' '),197,4);
                 pc_monta_linha(RPad(rw_crapenc.nrcxapst,10,' '),227,4);
                 pc_monta_linha(RPad(rw_crapenc.cdufende,30,' '),237,4);
                 pc_monta_linha(RPad('BRASIL',30,' '),267,4);
               END IF;
               
               --Se possuir Telefone
               IF vr_craptfc THEN
                 pc_monta_linha(RPad(rw_craptfc.nrdddtfc||rw_craptfc.nrtelefo,25,' '),297,4);
               ELSE
                 pc_monta_linha(RPad(' ',25,' '),297,4);
               END IF;
               
               --Selecionar Proximo Telefone
               OPEN cr_craptfc_next(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_idseqttl => 1
                                   ,pr_progress_recid => nvl(rw_craptfc.progress_recid, 0));
               FETCH cr_craptfc_next INTO rw_craptfc_next;
               
               --Se Encontrou
               IF cr_craptfc_next%FOUND THEN
                 pc_monta_linha(RPad(rw_craptfc_next.nrdddtfc||rw_craptfc_next.nrtelefo,25,' '),322,4);
               ELSE
                 pc_monta_linha(RPad(' ',25,' '),322,4);
               END IF;
               
               --Fechar Cursor
               CLOSE cr_craptfc_next;
               
               --Escrever Linha Arquivo
             pc_escreve_dado(NULL,4,pr_rw_crapcyb.dsdchave);
             END IF;
           ELSE
             CLOSE cr_garant;
           END IF;
           
         EXCEPTION
           WHEN vr_exc_erro THEN
             pr_cdcritic:= vr_cdcritic;
             pr_dscritic:= vr_dscritic;
           WHEN OTHERS THEN
             --Variavel de erro recebe erro ocorrido
             pr_cdcritic:= 0;
             pr_dscritic:= 'Erro na rotina pc_crps652.pc_gera_carga_garantias. '||sqlerrm;
         END;
       END pc_gera_carga_garantias;

     ---------------------------------------
     -- Inicio Bloco Principal PC_CRPS652
     ---------------------------------------
     BEGIN
     
     -- Na execu��o principal
     if nvl(pr_idparale,0) = 0 then
       -- Grava LOG sobre o �nicio da execu��o da procedure na tabela tbgen_prglog
       vr_idlog_ini_ger := null;
       pc_log_programa(pr_dstiplog   => 'I'    
                      ,pr_cdprograma => vr_cdprogra          
                      ,pr_cdcooper   => pr_cdcooper
                      ,pr_tpexecucao => 2    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      ,pr_idprglog   => vr_idlog_ini_ger);
     end if;     

       -- Incluir nome do modulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                 ,pr_action => NULL);

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop1(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop1 INTO rw_crapcop1;
       -- Se nao encontrar
       IF cr_crapcop1%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE cr_crapcop1;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop1;
       END IF;

       -- Verifica se a data esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se nao encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
       END IF;
     
       -- Validacoes iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => vr_flgbatch
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

     -- Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
       -- Descricao do erro recebe mensagam da critica
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
       -- Sair do programa
         RAISE vr_exc_saida;
       END IF;

     -- Para execu��o principal ou sem paralelo
     IF pr_idparale = 0 THEN
       -- Buscar Caminho Cyber para Envio
       vr_caminho:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRPS652_CYBER_ENVIA');
       IF vr_caminho IS NULL THEN
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao buscar caminho Cyber para envio.';
         RAISE vr_exc_saida;
       END IF;
     END IF;

     -- Se estiver rodando p�s processo 
       IF rw_crapdat.inproces = 1 THEN
          vr_dtatual := rw_crapdat.dtmvtoan;
          vr_dtmvtopr:= TO_CHAR(rw_crapdat.dtmvtolt,'YYYYMMDD');
       ELSE
          vr_dtatual := rw_crapdat.dtmvtolt;
       vr_dtmvtopr:= TO_CHAR(rw_crapdat.dtmvtopr,'YYYYMMDD');
       END IF;  
       
     -- Data Movimento
       vr_dtmvtolt:= TO_CHAR(vr_dtatual,'YYYYMMDD');
       vr_dtmvtlt2:= TO_CHAR(vr_dtatual,'MMDDYYYY');       
       vr_tempoatu:= TO_CHAR(SYSDATE,'HH24MISS');
       vr_nrdrowid:= NULL;

     -- Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

     -- Carregar Categorias
       pc_popula_categoria;

     -- Checar se n�o existem erros de execu��es anteriores
     vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                  ,pr_cdprogra    => pr_cdprogra
                                                  ,pr_dtmvtolt    => vr_dtatual
                                                  ,pr_tpagrupador => 3
                                                  ,pr_nrexecucao  => 1);  
     
     -- Caso esta execu��o n�o tenha recebido jObs para paralelizar, mas houveram execu��es anteriores
     if vr_qtdjobs = 0 and vr_qterro > 0 then
       -- Iremos alterar para 1 job para que o programa retome a execu��o corretamente, mesmo n�o paralelizando o restante pendente
       vr_qtdjobs := 1;
     end if;
   
     /* CAso tenha retornado threads para paralelizar */
     IF vr_qtdjobs > 0 and pr_cdcoppar = 0 then  
       
       -- Gerar o ID para o paralelismo
       vr_idparale := gene0001.fn_gera_ID_paralelo;
       
       -- Se houver algum erro, o id vira zerado
       IF vr_idparale = 0 THEN
          -- Levantar exce��o
          vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
          RAISE vr_exc_saida;
       END IF;

       -- Buscar todas as cooperativas sem erros de execu��es anteriores
       FOR rw_crapcop IN cr_crapcop(pr_cdprogra => pr_cdprogra
                                   ,pr_qterro   => vr_qterro
                                   ,pr_dtmvtolt => vr_dtatual) LOOP
          
         -- Buscar todas as agencias ou as com erros de execu�oes anteriores
         FOR rw_crapage IN cr_crapage(pr_cdcoppar => rw_crapcop.cdcooper
                                     ,pr_cdprogra => pr_cdprogra
                                     ,pr_qterro   => vr_qterro
                                     ,pr_dtmvtolt => vr_dtatual) LOOP
            
           -- Montar o prefixo do c�digo do programa para o jobname
           vr_jobname := pr_cdprogra ||'_'|| rw_crapcop.cdcooper ||'_'|| rw_crapage.cdagenci || '$';  
       
           -- Cadastra o programa paralelo
           gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                     ,pr_idprogra => (LPAD(rw_crapcop.cdcooper,3,'0')||LPAD(rw_crapage.cdagenci,5,'0'))
                                     ,pr_des_erro => vr_dscritic);
                                     
           -- Testar saida com erro
           if vr_dscritic is not null then
             -- Levantar exce�ao
             raise vr_exc_saida;
           end if;     
           
           -- Montar o bloco PLSQL que ser� executado
           -- Ou seja, executaremos a gera��o dos dados
           -- para a ag�ncia atual atraves de Job no banco
           vr_dsplsql := 'DECLARE' || chr(13) 
                      || '  wpr_cdcritic NUMBER;' || chr(13) 
                      || '  wpr_dscritic VARCHAR2(1500);' || chr(13) 
                      || '  wpr_stprogra NUMBER;' || chr(13) 
                      || '  wpr_infimsol NUMBER;' || chr(13) 
                      || 'BEGIN' || chr(13) 
                      || '  pc_crps652_FABRICIO('||pr_cdcooper
                      || '            ,'||rw_crapcop.cdcooper
                      || '            ,'||rw_crapage.cdagenci
                      || '            ,'||vr_idparale 
                      || '            ,'||''''||pr_cdprogra||''''
                      || '            ,'||pr_qtdejobs
                      || '            ,wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);' 
                      || chr(13) 
                      || 'END;';   
            
            -- Faz a chamada ao programa paralelo atraves de JOB
            gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> C�digo da cooperativa
                                  ,pr_cdprogra => pr_cdprogra  --> C�digo do programa
                                  ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                                  ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                                  ,pr_interva  => NULL         --> Sem intervalo de execu��o da fila, ou seja, apenas 1 vez
                                  ,pr_jobname  => vr_jobname   --> Nome randomico criado
                                  ,pr_des_erro => vr_dscritic);    
                                  
            -- Testar saida com erro
            if vr_dscritic is not null then 
              -- Levantar exce�ao
              raise vr_exc_saida;
            end if;

            -- Chama rotina que ir� pausar este processo controlador
            -- caso tenhamos excedido a quantidade de JOBS em execu�ao
            gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                        ,pr_qtdproce => vr_qtdjobs --> M�ximo de 10 jobs neste processo
                                        ,pr_des_erro => vr_dscritic);

            -- Testar saida com erro
            if  vr_dscritic is not null then 
              -- Levantar exce�ao
              raise vr_exc_saida;
            end if;
            
         end loop;
       end loop;
       
       -- Chama rotina de aguardo agora passando 0, para esperarmos
       -- at� que todos os Jobs tenha finalizado seu processamento
       gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                   ,pr_qtdproce => 0
                                   ,pr_des_erro => vr_dscritic);
                                   
       -- Testar saida com erro
       if vr_dscritic is not null then 
         -- Levantar exce�ao
         raise vr_exc_saida;
       end if;    

       -- Verifica se algum job executou com erro
       vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                    ,pr_cdprogra    => pr_cdprogra
                                                    ,pr_dtmvtolt    => vr_dtatual
                                                    ,pr_tpagrupador => 3
                                                    ,pr_nrexecucao  => 1);
       if vr_qterro > 0 then 
         vr_cdcritic := 0;
         vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
         raise vr_exc_saida;
       end if;
     
     ELSE
       
       if pr_cdcoppar <> 0 then
         vr_tpexecucao := 2;
       else
         vr_tpexecucao := 1;
       end if;   
       
       -- Grava controle de batch por ag�ncia
       gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper      -- Codigo da Cooperativa
                                       ,pr_cdprogra    => pr_cdprogra      -- Codigo do Programa
                                       ,pr_dtmvtolt    => vr_dtatual       -- Data de Movimento
                                       ,pr_tpagrupador => 3                -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                       ,pr_cdagrupador => lpad(pr_cdcoppar,3,'0')||lpad(pr_cdagepar,5,'0') -- Codigo do agrupador conforme (tpagrupador)
                                       ,pr_cdrestart   => null             -- Controle do registro de restart em caso de erro na execucao
                                       ,pr_nrexecucao  => 1                -- Numero de identificacao da execucao do programa
                                       ,pr_idcontrole  => vr_idcontrole    -- ID de Controle
                                       ,pr_cdcritic    => pr_cdcritic      -- Codigo da critica
                                       ,pr_dscritic    => vr_dscritic);    -- Descricao da critica
       -- Testar saida com erro
       if vr_dscritic is not null then 
         -- Levantar exce�ao
         raise vr_exc_saida;
       end if; 

       -- Grava LOG sobre o �nicio da execu��o da procedure na tabela tbgen_prglog
       pc_log_programa(pr_dstiplog   => 'I'  
                      ,pr_cdprograma => pr_cdprogra||'_'||pr_cdcoppar||'_'||pr_cdagepar          
                      ,pr_cdcooper   => pr_cdcooper 
                      ,pr_tpexecucao => vr_tpexecucao    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      ,pr_idprglog   => vr_idlog_ini_par); 

       -- Percorrer Cooperativas ativas
       FOR rw_crapcop IN cr_crapcop (pr_cdcoppar => pr_cdcoppar) LOOP

         -- Limpar tabelas memoria por cooperativa
         vr_tab_crapass.DELETE;
         vr_tab_crapjur.DELETE;

         -- Carregar associados
         pc_carrega_associados(pr_cdcooper => rw_crapcop.cdcooper
                              ,pr_cdagenci => pr_cdagepar);

         -- Carregar tabela memoria pessoa Juridica
         FOR rw_crapjur IN cr_crapjur (pr_cdcooper => rw_crapcop.cdcooper
                                      ,pr_cdagenci => pr_cdagepar) LOOP
           vr_tab_crapjur(rw_crapjur.nrdconta).dsendweb:= rw_crapjur.dsendweb;
           vr_tab_crapjur(rw_crapjur.nrdconta).nrinsest:= rw_crapjur.nrinsest;
           vr_tab_crapjur(rw_crapjur.nrdconta).cdrmativ:= rw_crapjur.cdrmativ;
         END LOOP;

         -- Carregar Contratos de Acordos
         FOR rw_ctr_acordo IN cr_ctr_acordo (pr_cdcooper => rw_crapcop.cdcooper
                                            ,pr_cdagenci => pr_cdagepar) LOOP
           vr_idindice := LPAD(rw_ctr_acordo.cdcooper,10,'0') || LPAD(rw_ctr_acordo.cdorigem,10,'0') ||
                          LPAD(rw_ctr_acordo.nrdconta,10,'0') || LPAD(rw_ctr_acordo.nrctremp,10,'0');
           vr_tab_acordo(vr_idindice) := rw_ctr_acordo.nracordo;
         END LOOP;

         -- Carregar boletos
         FOR rw_boleto IN cr_boleto (pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_dtmvtolt => vr_dtatual
                                    ,pr_cdagenci => pr_cdagepar) LOOP           
           vr_idboleto := rw_boleto.cdcooper || LPAD(rw_boleto.nrdconta,10,0) || LPAD(rw_boleto.nrctremp,10,0);
           vr_tab_boleto(vr_idboleto).idarquivo := rw_boleto.idarquivo;
           vr_tab_boleto(vr_idboleto).nrcpfava  := rw_boleto.nrcpfava;
           vr_tab_boleto(vr_idboleto).tpparcela  := rw_boleto.tpparcela;
         END LOOP;
         
         -- Selecionar Contratos em Cobranca no Cyber
         FOR rw_crapcyb IN cr_crapcyb (pr_cdcooper => rw_crapcop.cdcooper
                                      ,pr_cdagenci => pr_cdagepar) LOOP
           
           -- Atualizar agencia
           pc_atualiza_agencia (pr_rw_crapcyb => rw_crapcyb      --Registro Cyber
                               ,pr_des_erro   => vr_des_erro     --Retorno Erro
                               ,pr_cdcritic   => vr_cdcritic     --Codigo Critica
                               ,pr_dscritic   => vr_dscritic     --Descricao Critica
                               ,pr_tab_erro   => vr_tab_erro);   --Tabela Erro
           -- Se ocorreu erro
           IF vr_des_erro = 'NOK' THEN
             -- Buscar Indice primeiro elemento
             vr_index:= vr_tab_erro.FIRST;
             IF vr_index IS NOT NULL THEN
               -- Envio centralizado de log de erro
               btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                         ,pr_ind_tipo_log => 2 -- Erro tratato
                                         ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' --> '
                                                             || vr_tab_erro(vr_index).dscritic );
             END IF;
           END IF;

           -- Data Movimento Cyber igual atual
           IF rw_crapcyb.dtmvtolt = vr_dtatual THEN
             /* gera carga campos obrigatorios */
             pc_gera_campos_obrig (pr_idarquivo => 1 /*str_1*/             --Id do arquivo
                                  ,pr_cdcooper  => rw_crapcyb.cdcooper     --Cooperativa
                                  ,pr_cdorigem  => rw_crapcyb.cdorigem     --Origem
                                  ,pr_nrdconta  => rw_crapcyb.nrdconta     --Numero Conta
                                  ,pr_nrctremp  => rw_crapcyb.nrctremp     --Contrato Emprestimo
                                  ,pr_nrcpfcgc  => rw_crapcyb.nrcpfcgc     --Cpf/cnpj
                                  ,pr_cdcritic  => vr_cdcritic             --Codigo Erro
                                  ,pr_dscritic  => vr_dscritic);           --Descricao erro
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;
             --Gerar Carga Financeira
             pc_gera_carga_MF (pr_idarquivo  => 1 /*str_1*/               --Id do arquivo
                              ,pr_cdcooper   => rw_crapcyb.cdcooper       --Cooperativa
                              ,pr_nrdconta   => rw_crapcyb.nrdconta       --Numero Conta
                              ,pr_cdfinemp   => rw_crapcyb.cdfinemp       --Financiamento
                              ,pr_cdlcremp   => rw_crapcyb.cdlcremp       --Linha Credito
                              ,pr_nrctremp   => rw_crapcyb.nrctremp       --Numero Contrato Emprestimo
                              ,pr_cdorigem   => rw_crapcyb.cdorigem       --Origem
                              ,pr_nrdocnpj   => rw_crapcop.nrdocnpj       --Cpf/cnpj
                              ,pr_dtmvtolt   => vr_dtatual       --Data Movimento
                              ,pr_nmrescop   => rw_crapcop.nmrescop       --Nome Cooperativa
                              ,pr_rw_crapcyb => rw_crapcyb                --Registro Cyber
                              ,pr_flgtemlcr  => vr_tem_craplcr            --Encontrou craplcr
                              ,pr_cdcritic   => vr_cdcritic               --Codigo Erro
                              ,pr_dscritic   => vr_dscritic);             --Descricao Erro
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;
             --Gerar Carga
             pc_gera_carga_MC (pr_idarquivo  => 1 /*str_1*/             --Id do arquivo
                              ,pr_cdcooper   => rw_crapcyb.cdcooper     --Cooperativa
                              ,pr_nrdconta   => rw_crapcyb.nrdconta     --Numero Conta
                              ,pr_cdorigem   => rw_crapcyb.cdorigem    -- Origem
                              ,pr_nrctremp   => rw_crapcyb.nrctremp     -- Contrato Emprestimo
                              ,pr_posicini   => 857                     --Posicao Inicial de Escrita
                              ,pr_cdcritic   => vr_cdcritic             --Codigo Erro
                              ,pr_dscritic   => vr_dscritic);           --Descricao erro
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;
             --Ap�s gerar a Carga, deve gerar as informa��es complementares para a Carga Financeira
             pc_gera_carga_MF_complem(pr_idarquivo  => 1 /*str_1*/               --Id do arquivo
                                     ,pr_cdcooper   => rw_crapcyb.cdcooper       --Cooperativa
                                     ,pr_nrdconta   => rw_crapcyb.nrdconta       --Numero Conta
                                     ,pr_nrctremp   => rw_crapcyb.nrctremp       --Numero Contrato Emprestimo
                                     ,pr_cdorigem   => rw_crapcyb.cdorigem       --Origem
                                     ,pr_cdcritic   => vr_cdcritic               --Codigo Erro
                                     ,pr_dscritic   => vr_dscritic);             --Descricao Erro
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;

             --Ap�s gerar a Carga Complementar, deve gerar as informa��es complementares para a Carga Cadastral
             pc_gera_carga_MC_complem(pr_idarquivo => 1 /*str_1*/         -- Id do arquivo
                                     ,pr_cdcooper  => rw_crapcyb.cdcooper -- Cooperativa
                                     ,pr_cdorigem  => rw_crapcyb.cdorigem -- Origem
                                     ,pr_nrdconta  => rw_crapcyb.nrdconta -- Numero Conta
                                     ,pr_nrctremp  => rw_crapcyb.nrctremp -- Contrato Emprestimo
                                     ,pr_posicini  => 4532                -- Posi��o Inicial da Informa��o
                                     ,pr_cdcritic  => vr_cdcritic         -- Codigo Erro
                                     ,pr_dscritic  => vr_dscritic);       -- Descricao Erro
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;

             /* Vamos escrever no arquivo a linha que foi gerada em:
                      - pc_gera_carga_MF
                      - pc_gera_carga_MC
                      - pc_gera_carga_MF_complem
                      - pc_gera_carga_MC_complem
             */
             pc_escreve_dado(NULL,1,rw_crapcyb.dsdchave);

             /* gera carga relations */
             pc_gera_aval (pr_idarquivo  => 5                          --Id do arquivo
                          ,pr_opccarga   => 'R'  /* Relations */       --Tipo de Carga
                          ,pr_cdcooper   => rw_crapcyb.cdcooper        --Cooperativa
                          ,pr_nrdconta   => rw_crapcyb.nrdconta        --Numero Conta
                          ,pr_nrctremp   => rw_crapcyb.nrctremp        --Contrato Emprestimo
                          ,pr_cdorigem   => rw_crapcyb.cdorigem        --Origem
                          ,pr_nrdocnpj   => rw_crapcop.nrdocnpj        --Cnpj da Cooperativa
                          ,pr_dtmvtolt   => vr_dtatual        --Data Movimento
                          ,pr_flgtemlcr  => vr_tem_craplcr             --Flag possui craplcr
                          ,pr_nrctrlim   => nvl(rw_crapcyb.nrctrlim,0) --Chave para Desconto de Titulos
                          ,pr_rw_craplcr => rw_craplcr                 --Tabela Memoria Representantes
                          ,pr_dsdchave   => rw_crapcyb.dsdchave        --Chave de ordenacao
                          ,pr_cdcritic   => vr_cdcritic                --Codigo Erro
                          ,pr_dscritic   => vr_dscritic);              --Descricao erro
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;
             /* gerar a carga de garantias */
             pc_gera_carga_garantias (pr_cdcooper   => rw_crapcyb.cdcooper   --Cooperativa
                                     ,pr_nrdconta   => rw_crapcyb.nrdconta   --Numero Conta
                                     ,pr_nrctremp   => rw_crapcyb.nrctremp   --Contrato Emprestimo
                                     ,pr_rw_crapcyb => rw_crapcyb            --Registro atual Cyber
                                     ,pr_flgtemlcr  => vr_tem_craplcr        --Encontrou craplcr
                                     ,pr_cdcritic   => vr_cdcritic           --Codigo Erro
                                     ,pr_dscritic   => vr_dscritic);         --Descricao erro
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;
           ELSE

             --Data Manutencao Cadastro
             IF rw_crapcyb.dtmancad = vr_dtatual THEN
               /* gera carga campos obrigatorios */
               pc_gera_campos_obrig (pr_idarquivo => 2 /*str_2*/           --Id do arquivo
                                    ,pr_cdcooper  => rw_crapcyb.cdcooper   --Cooperativa
                                    ,pr_cdorigem  => rw_crapcyb.cdorigem   --Origem
                                    ,pr_nrdconta  => rw_crapcyb.nrdconta   --Numero Conta
                                    ,pr_nrctremp  => rw_crapcyb.nrctremp   --Contrato Emprestimo
                                    ,pr_nrcpfcgc  => rw_crapcyb.nrcpfcgc   --Cpf/cnpj
                                    ,pr_cdcritic  => vr_cdcritic           --Codigo Erro
                                    ,pr_dscritic  => vr_dscritic);         --Descricao erro
               --Se ocorreu erro
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 RAISE vr_exc_saida;
               END IF;

               --Gerar Carga
               pc_gera_carga_MC (pr_idarquivo  => 2 /*str_2*/            --Id do arquivo
                                ,pr_cdcooper   => rw_crapcyb.cdcooper    --Cooperativa
                                ,pr_nrdconta   => rw_crapcyb.nrdconta    --Numero Conta
                                ,pr_cdorigem   => rw_crapcyb.cdorigem    -- Origem
                                ,pr_nrctremp   => rw_crapcyb.nrctremp    -- Contrato Emprestimo
                                ,pr_posicini   => 55                     --Posicao Inicial de Escrita
                                ,pr_cdcritic   => vr_cdcritic            --Codigo Erro
                                ,pr_dscritic   => vr_dscritic);          --Descricao erro
               --Se ocorreu erro
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 RAISE vr_exc_saida;
               END IF;

               --Ap�s gerar a Carga, deve gerar as informa��es complementares para a Carga Cadastral
               pc_gera_carga_MC_complem(pr_idarquivo => 2 /*str_1*/          -- Id do arquivo
                                       ,pr_cdcooper  => rw_crapcyb.cdcooper  -- Cooperativa
                                       ,pr_cdorigem  => rw_crapcyb.cdorigem  -- Origem
                                       ,pr_nrdconta  => rw_crapcyb.nrdconta  -- Numero Conta
                                       ,pr_nrctremp  => rw_crapcyb.nrctremp  -- Contrato Emprestimo
                                       ,pr_posicini  => 3691                 -- Posi��o Inicial da Informa��o
                                       ,pr_cdcritic  => vr_cdcritic          -- Codigo Erro
                                       ,pr_dscritic  => vr_dscritic);        -- Descricao Erro
               --Se ocorreu erro
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 RAISE vr_exc_saida;
               END IF;
               /* Vamos escrever no arquivo a linha que foi gerada em:
                        - pc_gera_carga_MC
                        - pc_gera_carga_MC_complem
               */
               pc_escreve_dado(NULL,2,rw_crapcyb.dsdchave);

             END IF;
             --Data Manutencao Avalista igual movimento atual
             IF rw_crapcyb.dtmanavl = vr_dtatual THEN
               --Gera Avalista
               pc_gera_aval (pr_idarquivo  => 5                        --Id do arquivo
                            ,pr_opccarga   => 'R'  /* Relations */     --Tipo de Carga
                            ,pr_cdcooper   => rw_crapcyb.cdcooper      --Cooperativa
                            ,pr_nrdconta   => rw_crapcyb.nrdconta      --Numero Conta
                            ,pr_nrctremp   => rw_crapcyb.nrctremp      --Contrato Emprestimo
                            ,pr_cdorigem   => rw_crapcyb.cdorigem      --Origem
                            ,pr_nrdocnpj   => rw_crapcop.nrdocnpj      --Cnpj da Cooperativa
                            ,pr_dtmvtolt   => vr_dtatual      --Data Movimento
                            ,pr_rw_craplcr => rw_craplcr               --Tabela Memoria Representantes
                            ,pr_flgtemlcr  => vr_tem_craplcr           --Flag possui craplcr
                            ,pr_nrctrlim   => nvl(rw_crapcyb.nrctrlim,0) --Chave para Desconto de Titulos
                            ,pr_dsdchave   => rw_crapcyb.dsdchave      --Chave ordena��o
                            ,pr_cdcritic   => vr_cdcritic              --Codigo Erro
                            ,pr_dscritic   => vr_dscritic);            --Descricao erro
               --Se ocorreu erro
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 RAISE vr_exc_saida;
               END IF;
             END IF;
             --Data Manutencao Garantia igual movimento atual
             IF rw_crapcyb.dtmangar = vr_dtatual THEN
               pc_gera_carga_garantias (pr_cdcooper   => rw_crapcyb.cdcooper     --Cooperativa
                                       ,pr_nrdconta   => rw_crapcyb.nrdconta     --Numero Conta
                                       ,pr_nrctremp   => rw_crapcyb.nrctremp     --Contrato Emprestimo
                                       ,pr_rw_crapcyb => rw_crapcyb              --Registro atual Cyber
                                       ,pr_flgtemlcr  => vr_tem_craplcr           --Flag possui craplcr
                                       ,pr_cdcritic   => vr_cdcritic             --Codigo Erro
                                       ,pr_dscritic   => vr_dscritic);           --Descricao erro
               --Se ocorreu erro
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 RAISE vr_exc_saida;
               END IF;
             END IF;
             /* Desconto ou Emprestimo */
             IF rw_crapcyb.cdorigem IN (2,3) THEN
               --Buscar valor Pago Emprestimo
               FOR rw_valor_pago_emprestimo IN cr_valor_pago_emprestimo(pr_cdcooper => rw_crapcyb.cdcooper       -- Cooperativa
                                                                       ,pr_nrdconta => rw_crapcyb.nrdconta       -- Numero Conta
                                                                       ,pr_nrctremp => rw_crapcyb.nrctremp       -- Contrato Emprestimo
                                                                       ,pr_dtmvtolt => vr_dtatual) LOOP -- Data Movimento
                
                 -- Melhoria 432 - verifica se � refinanciamento - Jean / Mout�S
                 vr_cdtrscyb := NULL;
                 
                 OPEN c_refinanciamento(pr_cdcooper => rw_crapcyb.cdcooper       -- Cooperativa
                                       ,pr_nrdconta => rw_crapcyb.nrdconta       -- Numero Conta
                                       ,pr_nrctremp => rw_crapcyb.nrctremp);       -- Contrato Emprestimo
                 FETCH c_refinanciamento INTO vr_cdtrscyb;
                 CLOSE c_refinanciamento;
                 
                 IF vr_cdtrscyb IS NULL THEN
                    vr_cdtrscyb := 'PA'; --rw_valor_pago_emprestimo.cdhistor;
                 END IF;                      
                 
                 vr_idboleto := rw_crapcyb.cdcooper || LPAD(rw_crapcyb.nrdconta,10,0) || LPAD(rw_crapcyb.nrctremp,10,0);
                   
                 IF vr_tab_boleto.exists(vr_idboleto) THEN
                   -- Pagto. de Boleto
                   vr_cdtrscyb := 'PB';
                   -- Boletagem Massiva
                   IF vr_tab_boleto(vr_idboleto).idarquivo > 0 THEN
                     vr_cdtrscyb := 'BM';
                   -- Pagto. por Avalista                             "Pagto. Boleto Prejuizo
                   ELSIF vr_tab_boleto(vr_idboleto).nrcpfava  <> 0 OR vr_tab_boleto(vr_idboleto).tpparcela IN (5,6) THEN
                     vr_cdtrscyb := 'PB';
                   -- Descto. Boleto Prejuizo
                   ELSIF vr_tab_boleto(vr_idboleto).tpparcela = 7 THEN
                     vr_cdtrscyb := 'DB';
                   END IF;
                 END IF;
                 
                 --Gerar Carga Pagamentos
                 pc_gera_carga_pagamentos (pr_cdcooper => rw_crapcyb.cdcooper    --Codigo Cooperativa
                                          ,pr_cdorigem => rw_crapcyb.cdorigem    --Codigo Origem
                                          ,pr_nrdconta => rw_crapcyb.nrdconta    --Numero Conta
                                          ,pr_nrctremp => rw_crapcyb.nrctremp    --Numero Contrato Emprestimo
                                          ,pr_vlrpagto => rw_valor_pago_emprestimo.vllanmto -- Valor Lancamento
                                          ,pr_dtmvtlt2 => vr_dtmvtlt2            --Data Movimento
                                          ,pr_cdhistor => vr_cdtrscyb -- Codigo Historico
                                          ,pr_dshistor => rw_valor_pago_emprestimo.dshistor --Descricao Historico
                                          ,pr_dsdchave => rw_crapcyb.dsdchave     --Chave ordenacao
                                          ,pr_cdcritic => vr_cdcritic            --Codigo Erro
                                          ,pr_dscritic => vr_dscritic);          --Descricao Erro
                 --Se ocorreu erro
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                   RAISE vr_exc_saida;
                 END IF;
               END LOOP;
               -- Precisamos gerar arquivo de pagamento e baixa para os registros que nao fizeram
               -- atualizacao financeira no crps280.i (Foram liquidados)
               IF rw_crapcyb.dtmvtolt < vr_dtatual AND
                  rw_crapcyb.flgpreju = 0 AND
                  rw_crapcyb.dtatufin < vr_dtatual THEN

                      --Gerar carga de Baixa
                      pc_gera_carga_baixa (pr_rw_crapcyb => rw_crapcyb             --Registro Cyber
                                     ,pr_dtmvtolt   => vr_dtatual    --Data Movimento
                                          ,pr_dtmvtlt2   => vr_dtmvtlt2            --Data Movimento formatada
                                          ,pr_cdcritic   => vr_cdcritic            --Codigo Erro
                                          ,pr_dscritic   => vr_dscritic);          --Descricao Erro
                      --Se ocorreu erro
                      IF vr_cdcritic IS NOT NULL OR 
                         vr_dscritic IS NOT NULL THEN
                       RAISE vr_exc_saida;
                     END IF;

               ELSE
                 -- Verifica se o saldo a regularizar e o saldo do prejuizo estao liquidados para
                 -- gerar a baixa ou se for residuo o saldo devedor deve estar liquidado para gerar uma baixa
                 IF ((rw_crapcyb.vlpreapg <= 0 AND rw_crapcyb.flgpreju = 0) OR
                     (rw_crapcyb.flgpreju = 1 AND Nvl(rw_crapcyb.vlsdprej,0) <= 0))  OR
                     ((rw_crapcyb.flgresid = 1) AND (Nvl(rw_crapcyb.vlsdeved,0) <= 0) AND rw_crapcyb.flgpreju = 0) THEN

                         --Gerar carga de Baixa
                         pc_gera_carga_baixa (pr_rw_crapcyb => rw_crapcyb              --Registro Cyber
                                       ,pr_dtmvtolt   => vr_dtatual     --Data Movimento
                                         ,pr_dtmvtlt2   => vr_dtmvtlt2             --Data Movimento formatada
                                         ,pr_cdcritic   => vr_cdcritic             --Codigo Erro
                                         ,pr_dscritic   => vr_dscritic);           --Descricao Erro
                         --Se ocorreu erro
                         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                           RAISE vr_exc_saida;
                         END IF;
                     end if;

               END IF;
               
             -- [Projeto 403] Adicionando tratamento de baixa e pagamentos para desconto de t�tulos
             ELSIF rw_crapcyb.cdorigem = 4 THEN  
               
               FOR rw_valor_pago_dsct_tit IN cr_valor_pago_dsct_tit(pr_cdcooper => rw_crapcyb.cdcooper       -- Cooperativa
                                                                   ,pr_nrdconta => rw_crapcyb.nrdconta       -- Numero Conta
                                                                   ,pr_nrctremp => rw_crapcyb.nrctremp       -- Contrato Emprestimo
                                                                   ,pr_dtmvtolt => vr_dtatual) LOOP -- Data Movimento

                 vr_cdtrscyb := 'PA'; --rw_valor_pago_emprestimo.cdhistor;
                 
                 vr_idboleto := rw_crapcyb.cdcooper || LPAD(rw_crapcyb.nrdconta,10,0) || LPAD(rw_crapcyb.nrctremp,10,0);

                 IF vr_tab_boleto.exists(vr_idboleto) THEN
                   -- Pagto. de Boleto
                   vr_cdtrscyb := 'PB';
                   -- Boletagem Massiva
                   IF vr_tab_boleto(vr_idboleto).idarquivo > 0 THEN
                     vr_cdtrscyb := 'BM';
                   -- Pagto. por Avalista                             "Pagto. Boleto Prejuizo
                   ELSIF vr_tab_boleto(vr_idboleto).nrcpfava  <> 0 /*OR vr_tab_boleto(vr_idboleto).tpparcela IN (5,6) */THEN
                     vr_cdtrscyb := 'PB';
                   -- Descto. Boleto Prejuizo
                   /*ELSIF vr_tab_boleto(vr_idboleto).tpparcela = 7 THEN
                     vr_cdtrscyb := 'DB';*/
                   END IF;
                 END IF;

                 --Gerar Carga Pagamentos
                 pc_gera_carga_pagamentos (pr_cdcooper => rw_crapcyb.cdcooper    --Codigo Cooperativa
                                          ,pr_cdorigem => rw_crapcyb.cdorigem    --Codigo Origem
                                          ,pr_nrdconta => rw_crapcyb.nrdconta    --Numero Conta
                                          ,pr_nrctremp => rw_crapcyb.nrctremp    --Numero Contrato Emprestimo
                                          ,pr_vlrpagto => rw_valor_pago_dsct_tit.vllanmto -- Valor Lancamento
                                          ,pr_dtmvtlt2 => vr_dtmvtlt2            --Data Movimento
                                          ,pr_cdhistor => vr_cdtrscyb            -- Codigo Historico
                                          ,pr_dshistor => rw_valor_pago_dsct_tit.dshistor --Descricao Historico
                                          ,pr_dsdchave => rw_crapcyb.dsdchave    --Chave de ordenacao
                                          ,pr_cdcritic => vr_cdcritic            --Codigo Erro
                                          ,pr_dscritic => vr_dscritic);          --Descricao Erro
                 --Se ocorreu erro
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                   RAISE vr_exc_saida;
                 END IF;
               END LOOP;
               
               -- Precisamos gerar arquivo de pagamento e baixa para os registros que nao fizeram
               -- atualizacao financeira no crps280.i (Foram liquidados)
               IF rw_crapcyb.dtmvtolt < vr_dtatual AND
                  rw_crapcyb.flgpreju = 0 AND
                  rw_crapcyb.dtatufin < vr_dtatual THEN

                      --Gerar carga de Baixa
                      pc_gera_carga_baixa (pr_rw_crapcyb => rw_crapcyb             --Registro Cyber
                                          ,pr_dtmvtolt   => vr_dtatual    --Data Movimento
                                          ,pr_dtmvtlt2   => vr_dtmvtlt2            --Data Movimento formatada
                                          ,pr_cdcritic   => vr_cdcritic            --Codigo Erro
                                          ,pr_dscritic   => vr_dscritic);          --Descricao Erro
                      --Se ocorreu erro
                      IF vr_cdcritic IS NOT NULL OR
                         vr_dscritic IS NOT NULL THEN
                       RAISE vr_exc_saida;
                     END IF;

               END IF;
						 ELSIF rw_crapcyb.cdorigem = 1
						 AND (rw_crapcyb.flgpreju = 1
						 OR PREJ0003.fn_verifica_liquidacao_preju(rw_crapcyb.cdcooper, rw_crapcyb.nrdconta, vr_dtatual))  THEN -- Preju�zo de conta corrente
							 -- Se houve pagamentos no dia
							 vr_vllammto := PREJ0003.fn_valor_pago_conta_prej(rw_crapcyb.cdcooper
							                                                , rw_crapcyb.nrdconta
																															, vr_dtatual);
							 IF vr_vllammto > 0 THEN
								 --Gerar Carga Pagamentos
								 pc_gera_carga_pagamentos (pr_cdcooper => rw_crapcyb.cdcooper    --Codigo Cooperativa
																					,pr_cdorigem => rw_crapcyb.cdorigem    --Codigo Origem
																					,pr_nrdconta => rw_crapcyb.nrdconta    --Numero Conta
																					,pr_nrctremp => rw_crapcyb.nrctremp    --Numero Contrato Emprestimo
																					,pr_vlrpagto => vr_vllammto            --Valor A pagar emprestimo
																					,pr_dtmvtlt2 => vr_dtmvtlt2            --Data Movimento formatada
																					,pr_cdhistor => 'PA'                  --Codigo Historico (Gen�rico)
																					,pr_dshistor => NULL                   --Descricao Historico
                                          ,pr_dsdchave => rw_crapcyb.dsdchave    --Chave de ordenacao
																					,pr_cdcritic => vr_cdcritic            --Codigo Erro
																					,pr_dscritic => vr_dscritic);          --Descricao Erro
								 --Se ocorreu erro
								 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
									 RAISE vr_exc_saida;
								 END IF;
							 END IF;
               
							 -- Se o preju�zo foi liquidado
							 IF NOT PREJ0003.fn_verifica_preju_conta(rw_crapcyb.cdcooper
								                                     , rw_crapcyb.nrdconta) THEN
								
								 --Gerar carga de Baixa
								 pc_gera_carga_baixa (pr_rw_crapcyb => rw_crapcyb  --Registro Cyber
																     ,pr_dtmvtolt => vr_dtatual    --Data Movimento
																		 ,pr_dtmvtlt2 => vr_dtmvtlt2   --Data Movimento formatada
																		 ,pr_cdcritic => vr_cdcritic   --Codigo Erro
																		 ,pr_dscritic => vr_dscritic); --Descricao Erro
																		 
								 --Se ocorreu erro
								 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
									 RAISE vr_exc_saida;
								 END IF;
							 END IF;
             ELSE
               -- Precisamos gerar arquivo de pagamento e baixa para os registros que nao fizeram atualizacao
               -- financeira no crps280.i (Foram liquidados)
               IF rw_crapcyb.dtmvtolt < vr_dtatual AND rw_crapcyb.dtatufin < vr_dtatual THEN
                 vr_vllammto := fn_valor_pago_conta_corrente(pr_cdcooper => rw_crapcyb.cdcooper   --Cooperativa
                                                            ,pr_nrdconta => rw_crapcyb.nrdconta   --Numero Conta
                                                            ,pr_nrctremp => rw_crapcyb.nrctremp   --Contrato Emprestimo
                                                            ,pr_dtmvtolt => vr_dtatual);
                 -- Verifica se houve pagamento
                 IF (rw_crapcyb.vlpreapg - nvl(vr_vllammto,0)) > 0 THEN
                   
                   -- Melhoria 432 - verifica se � refinanciamento - Jean / Mout�S
                   vr_cdtrscyb := NULL;
                   
                   OPEN c_refinanciamento(pr_cdcooper => rw_crapcyb.cdcooper       -- Cooperativa
                                         ,pr_nrdconta => rw_crapcyb.nrdconta       -- Numero Conta
                                         ,pr_nrctremp => rw_crapcyb.nrctremp);       -- Contrato Emprestimo
                   FETCH c_refinanciamento INTO vr_cdtrscyb;
                   CLOSE c_refinanciamento;
                   
                   IF vr_cdtrscyb IS NULL THEN
                      vr_cdtrscyb := 'PA';
                   END IF;   
                

                   --Gerar Carga Pagamentos
                   pc_gera_carga_pagamentos (pr_cdcooper => rw_crapcyb.cdcooper    --Codigo Cooperativa
                                            ,pr_cdorigem => rw_crapcyb.cdorigem    --Codigo Origem
                                            ,pr_nrdconta => rw_crapcyb.nrdconta    --Numero Conta
                                            ,pr_nrctremp => rw_crapcyb.nrctremp    --Numero Contrato Emprestimo
                                            ,pr_vlrpagto => (rw_crapcyb.vlpreapg - nvl(vr_vllammto,0))    --Valor A pagar emprestimo
                                            ,pr_dtmvtlt2 => vr_dtmvtlt2            --Data Movimento formatada
                      -- 16/01/2017  - deve gerar historico parametrizado, se generico, gera "PA" (Jean/Mout�S)
                                           -- ,pr_cdhistor => 999999               --Codigo Historico (Gen�rico)
                                            ,pr_cdhistor => vr_cdtrscyb            --Codigo Historico (Gen�rico)
                                            ,pr_dshistor => NULL                   --Descricao Historico
                                            ,pr_dsdchave => rw_crapcyb.dsdchave    --Chave de ordenacao
                                            ,pr_cdcritic => vr_cdcritic            --Codigo Erro
                                            ,pr_dscritic => vr_dscritic);          --Descricao Erro
                   --Se ocorreu erro
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                     RAISE vr_exc_saida;
                   END IF;

                 END IF;

                     --Gerar carga de Baixa
                     pc_gera_carga_baixa (pr_rw_crapcyb => rw_crapcyb            --Registro Cyber
                                     ,pr_dtmvtolt => vr_dtatual     --Data Movimento
                                             ,pr_dtmvtlt2 => vr_dtmvtlt2             --Data Movimento formatada
                                             ,pr_cdcritic => vr_cdcritic             --Codigo Erro
                                             ,pr_dscritic => vr_dscritic);           --Descricao Erro
                     --Se ocorreu erro
                     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      RAISE vr_exc_saida;
                 end IF;
                   
               ELSE
                 -- Quando for normal verificar o saldo a regulalizar para ver se houve pagamento
                 -- Buscar o valor do lan�amento dos hist�ricos parametrizados para c�lculo de conta corrente
                 vr_vllammto:= fn_valor_pago_conta_corrente(pr_cdcooper => rw_crapcyb.cdcooper   --Cooperativa
                                                           ,pr_nrdconta => rw_crapcyb.nrdconta   --Numero Conta
                                                           ,pr_nrctremp => rw_crapcyb.nrctremp   --Contrato Emprestimo
                                                           ,pr_dtmvtolt => vr_dtatual); --Data Movimento

                 --Valor a regularizar anterior menos valor a regularizar menos o valor parametrizado
                 vr_vlrpagto:= Nvl(rw_crapcyb.vlprapga,0) - Nvl(rw_crapcyb.vlpreapg,0) - Nvl(vr_vllammto,0);

                 IF nvl(vr_vlrpagto,0) > 0 THEN
                  

                   -- Melhoria 432 - verifica se � refinanciamento - Jean / Mout�S
                   vr_cdtrscyb := NULL;
                   
                   OPEN c_refinanciamento(pr_cdcooper => rw_crapcyb.cdcooper       -- Cooperativa
                                         ,pr_nrdconta => rw_crapcyb.nrdconta       -- Numero Conta
                                         ,pr_nrctremp => rw_crapcyb.nrctremp);       -- Contrato Emprestimo
                   FETCH c_refinanciamento INTO vr_cdtrscyb;
                   CLOSE c_refinanciamento;
                   
                   IF vr_cdtrscyb IS NULL THEN
                      vr_cdtrscyb := 'PA';
                   END IF; 
                   
                    --Gerar Carga Pagamentos
                   pc_gera_carga_pagamentos (pr_cdcooper => rw_crapcyb.cdcooper    --Codigo Cooperativa
                                            ,pr_cdorigem => rw_crapcyb.cdorigem    --Codigo Origem
                                            ,pr_nrdconta => rw_crapcyb.nrdconta    --Numero Conta
                                            ,pr_nrctremp => rw_crapcyb.nrctremp    --Numero Contrato Emprestimo
                                            ,pr_vlrpagto => vr_vlrpagto            --Valor saldo a regularizar
                                            ,pr_dtmvtlt2 => vr_dtmvtlt2            --Data Movimento Formatada
                                            -- 16/01/2017  - deve gerar historico parametrizado, se generico, gera "PA" (Jean/Mout�S)
                                            --,pr_cdhistor => 999999               --Codigo Historico (Gen�rico)
                                            ,pr_cdhistor => vr_cdtrscyb            --Codigo Historico (Gen�rico)
                                            ,pr_dshistor => NULL                   --Descricao Historico
                                            ,pr_dsdchave => rw_crapcyb.dsdchave    --Chave ordenacao
                                            ,pr_cdcritic => vr_cdcritic            --Codigo Erro
                                            ,pr_dscritic => vr_dscritic);          --Descricao Erro
                   --Se ocorreu erro
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                     RAISE vr_exc_saida;
                   END IF;
                 END IF;
                 -- Verifica se o saldo a regularizar e o saldo do prejuizo estao liquidados para gerar a baixa,
                 -- ou se for residuo o saldo devedor deve estar liquidado para gerar uma baixa
                 IF Nvl(rw_crapcyb.vlpreapg,0) <= 0 THEN

                       --Gerar carga de Baixa
                       pc_gera_carga_baixa (pr_rw_crapcyb => rw_crapcyb             --Registro Cyber
                                       ,pr_dtmvtolt   => vr_dtatual      --Data Movimento
                                 ,pr_dtmvtlt2   => vr_dtmvtlt2              --Data Movimento Formatada
                                 ,pr_cdcritic   => vr_cdcritic              --Codigo Erro
                                 ,pr_dscritic   => vr_dscritic);            --Descricao Erro
                       --Se ocorreu erro
                       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                          RAISE vr_exc_saida;
                       END IF;
                   
                 END IF;
               END IF;
             END IF;

             /* gera carga campos obrigatorios */
             pc_gera_campos_obrig (pr_idarquivo => 3 /*str_3*/              --Id do arquivo
                                  ,pr_cdcooper  => rw_crapcyb.cdcooper      --Cooperativa
                                  ,pr_cdorigem  => rw_crapcyb.cdorigem      --Origem
                                  ,pr_nrdconta  => rw_crapcyb.nrdconta      --Numero Conta
                                  ,pr_nrctremp  => rw_crapcyb.nrctremp      --Contrato Emprestimo
                                  ,pr_nrcpfcgc  => rw_crapcyb.nrcpfcgc      --Cpf/cnpj
                                  ,pr_cdcritic  => vr_cdcritic              --Codigo Erro
                                  ,pr_dscritic  => vr_dscritic);            --Descricao erro


             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;

             --Gerar Carga Financeira
             pc_gera_carga_MF (pr_idarquivo  => 3 /*str_3*/              --Id do arquivo
                              ,pr_cdcooper   => rw_crapcyb.cdcooper      --Cooperativa
                              ,pr_nrdconta   => rw_crapcyb.nrdconta      --Numero Conta
                              ,pr_cdfinemp   => rw_crapcyb.cdfinemp      --Financiamento
                              ,pr_cdlcremp   => rw_crapcyb.cdlcremp      --Linha Credito
                              ,pr_nrctremp   => rw_crapcyb.nrctremp      --Numero Contrato Emprestimo
                              ,pr_cdorigem   => rw_crapcyb.cdorigem      --Origem
                              ,pr_nrdocnpj   => rw_crapcop.nrdocnpj      --Cpf/cnpj
                              ,pr_dtmvtolt   => vr_dtatual      --Data Movimento
                              ,pr_nmrescop   => rw_crapcop.nmrescop      --Nome Cooperativa
                              ,pr_rw_crapcyb => rw_crapcyb               --Registro Cyber
                              ,pr_flgtemlcr  => vr_tem_craplcr           --Flag possui craplcr
                              ,pr_cdcritic   => vr_cdcritic              --Codigo Erro
                              ,pr_dscritic   => vr_dscritic);            --Descricao Erro

             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;

             --Gerar Carga Financeira complementar
             pc_gera_carga_MF_complem (pr_idarquivo  => 3 /*str_3*/              --Id do arquivo
                                      ,pr_cdcooper   => rw_crapcyb.cdcooper      --Cooperativa
                                      ,pr_nrdconta   => rw_crapcyb.nrdconta      --Numero Conta
                                      ,pr_nrctremp   => rw_crapcyb.nrctremp      --Numero Contrato Emprestimo
                                      ,pr_cdorigem   => rw_crapcyb.cdorigem      --Origem
                                      ,pr_cdcritic   => vr_cdcritic              --Codigo Erro
                                      ,pr_dscritic   => vr_dscritic);            --Descricao Erro
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;

             /* Vamos escrever no arquivo a linha que foi gerada em:
                      - pc_gera_carga_MF
                      - pc_gera_carga_MF_complem
             */
             pc_escreve_dado(NULL,3,rw_crapcyb.dsdchave);

           END IF;
         END LOOP;

         -- Se for execucao paralela, gravar pltables nas tabelas WORK
         IF pr_cdcoppar > 0 THEN
           
           -- Processar pltables de dados de arquivo para grava��o em tabela
           FOR idx IN 1..7 LOOP 
             -- Copiar para variavel gen�rica o conteudo da tab espec�fica
             CASE idx
               WHEN 1 THEN vr_tab_texto_Generi := vr_tab_texto1;
               WHEN 2 THEN vr_tab_texto_Generi := vr_tab_texto2;
               WHEN 3 THEN vr_tab_texto_Generi := vr_tab_texto3;
               WHEN 4 THEN vr_tab_texto_Generi := vr_tab_texto4;
               WHEN 5 THEN vr_tab_texto_Generi := vr_tab_texto5;
               WHEN 6 THEN vr_tab_texto_Generi := vr_tab_texto6;
               WHEN 7 THEN vr_tab_texto_Generi := vr_tab_texto7;
             END CASE;   

             -- Efetuar la�o para ler todos os registros da pltable e transportar ao CLOB
             FOR idx2 IN 0..vr_tab_texto_Generi.count()-1 LOOP
               -- Somente no ultimo, pode ser que o mesmo esteja vazio devido a quebra prevendo 
               -- o reposicionamento na proxima linha, neste caso ent�o n�o gravamos nada
               IF idx2 != vr_tab_texto_Generi.last OR trim(vr_tab_texto_Generi(idx2).dsdtexto) IS NOT NULL THEN 
                 -- Inserir na tabela tempor�ria
                 BEGIN
                   insert into tbgen_batch_relatorio_wrk
                              (cdcooper
                              ,cdprograma
                              ,dsrelatorio
                              ,dtmvtolt
                              ,cdagenci -- Coop
                              ,nrdconta -- Arq
                              ,dschave  -- Seq Ordena��o
                              ,nrctremp -- Seq Linha
                              ,dsxml)
                        values(pr_cdcooper
                              ,pr_cdprogra
                              ,'dados_arquivo_'||lpad(idx,2,'0')
                              ,vr_dtatual 
                              ,pr_cdcoppar -- Coop   
                              ,idx         -- Arq
                              ,vr_tab_texto_Generi(idx2).dsdchave 
                              ,idx2
                              ,vr_tab_texto_Generi(idx2).dsdtexto);
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_dscritic := 'Erro ao inserir dados na tbgen_batch_relatorio_wrk[dados_arquivo]: ' || SQLERRM;
                     RAISE vr_exc_saida;
                 END;
               END IF;
             END LOOP;
             
             -- Limpar
             vr_tab_texto_generi.delete;
             
           END LOOP;
           
           END IF;
           
         -- Grava data fim para o JOB na tabela de LOG 
         pc_log_programa(pr_dstiplog   => 'F'  
                        ,pr_cdprograma => pr_cdprogra||'_'||pr_cdcoppar||'_'||pr_cdagepar           
                        ,pr_cdcooper   => pr_cdcooper
                        ,pr_tpexecucao => vr_tpexecucao -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        ,pr_idprglog   => vr_idlog_ini_par
                        ,pr_flgsucesso => 1);
         
       END LOOP;
     
     END IF;
     

     -- Para execu��o principal ou sem paralelo
     IF pr_idparale = 0 THEN
       
       -- Caso execu��o paralela
       IF vr_idparale > 0 THEN
         -- La�o para buscar dados dos 7 arquivos
         FOR vr_idx IN 1..7 LOOP         
           -- Buscar dados da tabela gen�rica para a pltable
           FOR rw_work IN cr_work_arquv(pr_cdcooper    => pr_cdcooper
                                       ,pr_cdprograma  => pr_cdprogra
                                       ,pr_dsrelatorio => 'dados_arquivo_'||lpad(vr_idx,2,'0')
                                       ,pr_dtmvtolt    => vr_dtatual) LOOP
             -- Cada registro � uma linha para o arquivo
             pc_escreve_dado(rw_work.dsxml,vr_idx,null);
           END LOOP;
         END LOOP;
       END IF;
       
       
       -- Inicializar os CLOBs
       pc_inicializa_clob;
       
       -- Salvar Nomes e escrever cabecalho nos Arquivos
       FOR idx IN 1..8 LOOP
         -- Montar nome do arquivo de cada clob
         vr_setlinha:= vr_caminho|| vr_dtmvtolt || '_' ||vr_tempoatu;
         -- Complementar a string
         CASE idx
           WHEN 1 THEN
             vr_setlinha:= vr_setlinha ||'_carga_in.txt';      /* Carga */
             vr_tparquiv:= 'completa';
           WHEN 2 THEN
             vr_setlinha:= vr_setlinha ||'_cadastral_in.txt';  /* Carga MC */
             vr_tparquiv:= 'cadastral';
           WHEN 3 THEN
             vr_setlinha:= vr_setlinha ||'_financeira_in.txt'; /* Carga MF */
             vr_tparquiv:= 'financeira';
           WHEN 4 THEN
             vr_setlinha:= vr_setlinha ||'_gar_in.txt';        /* Carga Garantia */
             vr_tparquiv:= 'garantia';
           WHEN 5 THEN
             vr_setlinha:= vr_setlinha ||'_rel_in.txt';        /* Carga Relations */
             vr_tparquiv:= 'relation';
           WHEN 6 THEN
             vr_setlinha:= vr_setlinha ||'_pagamentos_in.txt'; /* Pagamentos */
             vr_tparquiv:= 'pagamentos';
           WHEN 7 THEN
             vr_setlinha:= vr_setlinha ||'_baixa_in.txt';      /* Baixas */
             vr_tparquiv:= 'baixa';
           WHEN 8 THEN
             vr_setlinha:= vr_setlinha ||'_pagboleto_in.txt';   /* Pagamentos Acordo */
             vr_tparquiv:= 'acordo';  
         END CASE;
         -- Salvar o nome de cada CLOB no vetor
         vr_tab_nmclob(idx):= vr_setlinha;
         -- Montar linha que sera gravada no arquivo
         vr_setlinha:= rpad('H',3,' ')||RPAD('AYLLOS',15,' ')||rpad('CYBER',15,' ')||RPAD(vr_tparquiv,10,' ')||
                       rpad('00000000',8,' ')||rpad(vr_dtmvtolt,8,' ')||chr(10);
         -- Escrever Header no CLOB
         pc_escreve_clob(vr_setlinha,idx);
         END LOOP;

       -- Gerar informa��es de Acordos para cada Coop
       FOR rw_crapcop IN cr_crapcop LOOP
         -- Gera carga de pagamentos de acordos
         pc_gera_carga_pagto_acordo (pr_idarquivo => 8 /*str_8*/         --Id do arquivo
                                    ,pr_cdcooper  => rw_crapcop.cdcooper --Cooperativa
                                    ,pr_dtmvtolt  => vr_dtatual --Data de Movimentac         
                                    ,pr_cdcritic  => vr_cdcritic         --Codigo Erro
                                    ,pr_dscritic  => vr_dscritic);       --Descricao erro

         --Se ocorreu erro
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_saida;
         END IF;
       end loop;
       
       -- Processar pltables de dados de arquivo para envi�-la aos seus devidos CLOBs
       FOR idx IN 1..8 LOOP 
         -- Copiar para variavel gen�rica o conteudo da tab espec�fica
         CASE idx
           WHEN 1 THEN vr_tab_texto_Generi := vr_tab_texto1;
           WHEN 2 THEN vr_tab_texto_Generi := vr_tab_texto2;
           WHEN 3 THEN vr_tab_texto_Generi := vr_tab_texto3;
           WHEN 4 THEN vr_tab_texto_Generi := vr_tab_texto4;
           WHEN 5 THEN vr_tab_texto_Generi := vr_tab_texto5;
           WHEN 6 THEN vr_tab_texto_Generi := vr_tab_texto6;
           WHEN 7 THEN vr_tab_texto_Generi := vr_tab_texto7;
           WHEN 8 THEN vr_tab_texto_Generi := vr_tab_texto8;
         END CASE; 
         
         -- Guardar quantidade de linhas
         vr_tab_contlinh(idx) := vr_tab_texto_Generi.count();      
         
         -- Efetuar la�o para ler todos os registros da pltable e transportar ao CLOB
         FOR idx2 IN 0..vr_tab_texto_Generi.count()-1 LOOP
           -- Somente no ultimo, pode ser que o mesmo esteja vazio devido a quebra prevendo 
           -- o reposicionamento na proxima linha, neste caso ent�o n�o enviamos nada
           IF idx2 != vr_tab_texto_Generi.last OR trim(vr_tab_texto_Generi(idx2).dsdtexto) IS NOT NULL THEN 
             pc_escreve_clob(vr_tab_texto_Generi(idx2).dsdtexto||chr(10),idx);
           END IF;
       END LOOP;

         -- Limpar
         vr_tab_texto_generi.delete;
         
       END LOOP;       
       
       -- Escrever Trailer nos 8 arquivos, fechar e liberar os 8 Clobs.
       FOR idx IN 1..8 LOOP
         -- Incrementar Contador Linha de cada arquivo
         vr_qtdlinha:= vr_tab_contlinh(idx) + 2;
         -- Montar Linha
         vr_setlinha:= RPad('T',3,' ')||gene0002.fn_mask(vr_qtdlinha,'9999999')||chr(10);
         -- Escrever linha no arquivo e finaliza varchar2 tempor�ria para o CLOB
         pc_escreve_clob(vr_setlinha,idx,TRUE);
         -- Gerar os 8 arquivos fisicamente
         CASE idx
           WHEN 1 THEN
             gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml1
                                          ,pr_caminho  => vr_caminho
                                          ,pr_arquivo  => vr_tab_nmclob(idx)
                                          ,pr_des_erro => vr_dscritic);
             dbms_lob.close(vr_des_xml1);
             dbms_lob.freetemporary(vr_des_xml1);
           WHEN 2 THEN
             gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml2
                                          ,pr_caminho  => vr_caminho
                                          ,pr_arquivo  => vr_tab_nmclob(idx)
                                          ,pr_des_erro => vr_dscritic);
             dbms_lob.close(vr_des_xml2);
             dbms_lob.freetemporary(vr_des_xml2);
           WHEN 3 THEN
             gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml3
                                          ,pr_caminho  => vr_caminho
                                          ,pr_arquivo  => vr_tab_nmclob(idx)
                                          ,pr_des_erro => vr_dscritic);
             dbms_lob.close(vr_des_xml3);
             dbms_lob.freetemporary(vr_des_xml3);
           WHEN 4 THEN
             gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml4
                                          ,pr_caminho  => vr_caminho
                                          ,pr_arquivo  => vr_tab_nmclob(idx)
                                          ,pr_des_erro => vr_dscritic);
             dbms_lob.close(vr_des_xml4);
             dbms_lob.freetemporary(vr_des_xml4);
           WHEN 5 THEN
             gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml5
                                          ,pr_caminho  => vr_caminho
                                          ,pr_arquivo  => vr_tab_nmclob(idx)
                                          ,pr_des_erro => vr_dscritic);
             dbms_lob.close(vr_des_xml5);
             dbms_lob.freetemporary(vr_des_xml5);
           WHEN 6 THEN
             gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml6
                                          ,pr_caminho  => vr_caminho
                                          ,pr_arquivo  => vr_tab_nmclob(idx)
                                          ,pr_des_erro => vr_dscritic);
             dbms_lob.close(vr_des_xml6);
             dbms_lob.freetemporary(vr_des_xml6);
           WHEN 7 THEN
             gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml7
                                          ,pr_caminho  => vr_caminho
                                          ,pr_arquivo  => vr_tab_nmclob(idx)
                                          ,pr_des_erro => vr_dscritic);
             dbms_lob.close(vr_des_xml7);
             dbms_lob.freetemporary(vr_des_xml7);
           WHEN 8 THEN
             gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml8
                                          ,pr_caminho  => vr_caminho
                                          ,pr_arquivo  => vr_tab_nmclob(idx)
                                          ,pr_des_erro => vr_dscritic);
             dbms_lob.close(vr_des_xml8);
             dbms_lob.freetemporary(vr_des_xml8);             
         END CASE;
         -- Testa retorno
         if vr_dscritic is not null then
           raise vr_exc_saida;
         end if;
       END LOOP;

       -- Gerar Arquivo ZIP
       vr_comando:= 'zip '||vr_caminho||'/'||vr_dtmvtopr||'_'||vr_tempoatu||'_CYBER.zip -j '||
                            vr_caminho||'/'||vr_dtmvtolt||'_'||vr_tempoatu||'*.txt 1> /dev/null';

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

       -- Eliminar arquivos
       IF vr_caminho IS NOT NULL THEN
         -- Montar Comando
         vr_comando:= 'rm '||vr_caminho||'/'||vr_dtmvtolt||'_'||vr_tempoatu||'*.txt 2> /dev/null';

         --Executar o comando no unix
         GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
         -- Se ocorreu erro dar RAISE
         IF vr_typ_saida = 'ERR' THEN
           vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
           RAISE vr_exc_saida;
         END IF;
       END IF;

       -- Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg (pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);

       -- M432 - envio Cyber. no fim do processo, chamar a carga de importa��o cyber
       CYBE0001.pc_importa_arquivo_cyber(pr_dtmvto => SYSDATE
                                        ,pr_des_reto => vr_typ_saida
                                        ,pr_des_erro => vr_dscritic );
       
       -- Erros da importacao Cyber n�o ser�o tratados aqui, ser�o tratados no LOG do programa CYBE0001
       --IF vr_typ_saida = 'NOK' then
       --   vr_dscritic := 'Erro na chamada da importacao arquivo CYBER: ' || vr_dscritic;
       --   raise vr_exc_saida;
       --end if;

       -- Limpa os registros da tabela de trabalho somente em execu��o paralela
       IF vr_idparale > 0 THEN
         begin    
           delete from tbgen_batch_relatorio_wrk
            where cdcooper    = pr_cdcooper
              and cdprograma  = pr_cdprogra
              AND dsrelatorio IN('dados_arquivo_01','dados_arquivo_02','dados_arquivo_03','dados_arquivo_04'
                                ,'dados_arquivo_05','dados_arquivo_06','dados_arquivo_07','dados_arquivo_08')
              and dtmvtolt    = vr_dtatual;    
         exception
           when others then
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao deletar tabela tbgen_batch_relatorio_wrk: '||sqlerrm;
             raise vr_exc_saida;            
         END;       
               
       END IF;
       
       -- Caso seja o controlador 
       if vr_idcontrole <> 0 then
         -- Atualiza finaliza��o do batch na tabela de controle 
         gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                            ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                            ,pr_dscritic   => vr_dscritic);
         -- Testar saida com erro
         if  vr_dscritic is not null then 
           -- Levantar exce�ao
           raise vr_exc_saida;
         end if;                                       
       end if;   
       
       -- Grava LOG sobre o fim da execu��o da procedure na tabela tbgen_prglog
       pc_log_programa(pr_dstiplog   => 'F'   
                      ,pr_cdprograma => pr_cdprogra           
                      ,pr_cdcooper   => pr_cdcooper 
                      ,pr_tpexecucao => 2 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      ,pr_idprglog   => vr_idlog_ini_ger
                      ,pr_flgsucesso => 1);      
       
       --Salvar informacoes no banco de dados
       COMMIT;
     ELSE
       -- Atualiza finaliza��o do batch na tabela de controle 
       gene0001.pc_finaliza_batch_controle(vr_idcontrole   --pr_idcontrole IN tbgen_batch_controle.idcontrole%TYPE -- ID de Controle
                                          ,vr_cdcritic     --pr_cdcritic  OUT crapcri.cdcritic%TYPE                -- Codigo da critica
                                          ,vr_dscritic);   --pr_dscritic  OUT crapcri.dscritic%TYPE
       IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
       END IF;
       -- Encerrar o job do processamento paralelo dessa ag�ncia
       gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                   ,pr_idprogra => (LPAD(pr_cdcoppar,3,'0')||LPAD(pr_cdagepar,5,'0'))
                                   ,pr_des_erro => vr_dscritic);  
       IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
       END IF;
       -- Salvar informacoes no banco de dados
       COMMIT;
     END IF;  

     EXCEPTION
     WHEN vr_exc_saida THEN
       -- Buscar a descricao
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
       -- Devolvemos codigo e critica encontradas
       pr_cdcritic := NVL(vr_cdcritic,0);
       pr_dscritic := vr_dscritic;
        
       -- Na execu��o paralela
       IF nvl(pr_idparale,0) <> 0 THEN

         --Grava data fim para o JOB na tabela de LOG 
         pc_log_programa(pr_dstiplog   => 'F',    
                         pr_cdprograma => pr_cdprogra||'_'||pr_cdcoppar||'_'||pr_cdagepar,           
                         pr_cdcooper   => pr_cdcooper, 
                         pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_idprglog   => vr_idlog_ini_par,
                         pr_flgsucesso => 0);                                     
         
         -- Grava LOG de erro com as cr�ticas retornadas                           
         pc_log_programa(pr_dstiplog      => 'E', 
                         pr_cdprograma    => pr_cdprogra||'_'||pr_cdcoppar||'_'||pr_cdagepar,
                         pr_cdcooper      => pr_cdcooper,
                         pr_tpexecucao    => vr_tpexecucao,
                         pr_tpocorrencia  => 3,
                         pr_cdcriticidade => 1,
                         pr_cdmensagem    => pr_cdcritic,
                         pr_dsmensagem    => pr_dscritic,
                         pr_flgsucesso    => 0,
                         pr_idprglog      => vr_idlog_ini_par);  
                         
         -- Encerrar o job do processamento paralelo dessa ag�ncia
         gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                     ,pr_idprogra => (LPAD(pr_cdcoppar,3,'0')||LPAD(pr_cdagepar,5,'0'))
                                     ,pr_des_erro => vr_dscritic);                        

       ELSE
         IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || pr_cdprogra || ' --> '
                                                      || vr_dscritic );
         END IF;
       END IF;

         -- Efetuar rollback
         ROLLBACK;
       -- Zerar tabela de memoria auxiliar
         pc_limpa_tabela;
       WHEN OTHERS THEN
         cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper, 
                                      pr_compleme => vr_dscritic);
         -- Efetuar retorno do erro nao tratado
         pr_cdcritic := 0;
         pr_dscritic := vr_dscritic || ' - ' || sqlerrm;
       
       -- Na execu��o paralela
       if nvl(pr_idparale,0) <> 0 then 
         -- Grava LOG de ocorr�ncia final da procedure apli0001.pc_calc_poupanca
         pc_log_programa(PR_DSTIPLOG           => 'E',
                         PR_CDPROGRAMA         => pr_cdprogra||'_'||pr_cdcoppar||'_'||pr_cdagepar,
                         pr_cdcooper           => pr_cdcooper,
                         pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_tpocorrencia       => 2,
                         pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                  'pr_dscritic:'||pr_dscritic,
                         PR_IDPRGLOG           => vr_idlog_ini_par); 
         --Grava data fim para o JOB na tabela de LOG 
         pc_log_programa(pr_dstiplog   => 'F',    
                         pr_cdprograma => pr_cdprogra||'_'||pr_cdcoppar||'_'||pr_cdagepar,           
                         pr_cdcooper   => pr_cdcooper, 
                         pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_idprglog   => vr_idlog_ini_par,
                         pr_flgsucesso => 0);  
         -- Encerrar o job do processamento paralelo dessa ag�ncia
         gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                     ,pr_idprogra => (LPAD(pr_cdcoppar,3,'0')||LPAD(pr_cdagepar,5,'0'))
                                     ,pr_des_erro => vr_dscritic);
       end if;        
       
         -- Efetuar rollback
         ROLLBACK;
       -- Zerar tabela de memoria auxiliar
         pc_limpa_tabela;
     END;
END PC_CRPS652_FABRICIO;
/
