CREATE OR REPLACE PROCEDURE CECRED.pc_crps533 (pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                       ,pr_nmtelant IN VARCHAR2
                                       ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                       ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                       ,pr_dscritic OUT varchar2) IS
  BEGIN

  /* .............................................................................

   Programa: PC_CRPS533                      Antigo: Fontes/crps533.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Dezembro/2009                   Ultima atualizacao: 20/08/2019

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 1.
               Integrar arquivos CECRED de cheques - Sua Remessa
               Emite relatorio 526 e 564

   Alteracoes: 03/12/2009 - Primeira Versao

               02/03/2010 - Alterar historicos 469 para 524 (Guilherme/Supero)

               16/06/2010 - Acerto Gerais (Ze).

               22/06/2010 - Permitir que o programa rode diferenciadamente para
                            coop 3, lendo todos os arquivos 1*.RET, importar os
                            dados e gerar um relatorio. Quando for outra coop,
                            continuar o funcionamento atual (Guilherme/Supero)

               28/07/2010 - Incluso Validacao para COMPEFORA (Jonatas/Supero)

               06/07/2010 - Alt. de Age. Apresentante p/ Age. Deposito (Ze).

               23/08/2010 - Ajuste no controle do arquivo integrado (Ze).

               02/09/2010 - Ajuste na Conta onde foi depositado (Ze).

               06/09/2010 - Campos craplcm.cdbanchq, craplcm.cdagechq e
                            craplcm.cdcmpchq sao usados na devolu. Atualizar
                            com dados do cheque (Magui).

               13/09/2010 - Acerto p/ gerar relatorio no diretorio rlnsv
                            (Vitor)

               23/09/2010 - Incluir coluna TD (Tipo de Documento) (Ze).

               01/12/2010 - Substituir alinea 43 por 21 e 49 por 28. (Ze).

               10/12/2010 - Inclusao de Transferencia de PAC quando coop 2
                            (Guilherme/Supero)

               10/01/2011 - Alteracao para criar reg. de devolucao - Migracao
                            de PACs (Ze).

               18/01/2011 - Incluido os e-mails:
                            - fabiano@viacredi.coop.br
                            - moraes@viacredi.coop.br
                            (Adriano).

               18/02/2011 - Alterar alinea para 43 quando ja houve uma 1a vez
                            (Guilherme/Supero)

               25/03/2011 - Acerto para exibir a critica 179 no rel. (Ze).

               13/04/2011 - Nao sera permitido a entrada de cheques que estao
                            em custodia ou em desconto de cheques (Adriano).

               03/06/2011 - Alterado destinatário do envio de email na procedure
                            gera_relatorio_203_99;
                            De: thiago.delfes@viacredi.coop.br
                            Para: brusque@viacredi.coop.br. (Fabricio)

               09/06/2011 - Retirada restrição para os tipos de documentos 75,
                            76,77,90,94 e 95(alerta de roubo), permitindo a
                            utilizacao das mesmas alineas dos historicos de
                            contra-ordem (Diego).

               10/06/2011 - Informar para a Viacredi as contra-ordens das
                            contas migradas atraves do crrl526_99 (Ze).

               07/07/2011 - Nao tarifar devolucao de alinea 31 (Diego).

               15/07/2011 - Tratamento p/ cheques das contas transferidas (Ze).

               01/08/2011 - Ajuste no tratamento das contas TCO (Ze).

               05/08/2011 - Ajuste para nao desprezar reg. qdo ha caracteres
                            em campos numericos - Tarefa 41727 (Ze)

               08/12/2011 - Sustação provisória (André R./Supero).

               23/12/2011 - Retirar Warnings (Gabriel).

               30/03/2012 - Criado registro na crapdev para os cheques com
                            cdcritic = 09 ou 108. Usado alinea 37. (Fabricio)

               02/05/2012 - Ajuste na devolucao da alinea 37 (Ze).

               18/06/2012 - Alteracao na leitura da craptco (David Kruger).

               02/07/2012 - Ajuste na verificacao de cheques em desconto e
                            custodia - Trf. 3820 (Ze).

               04/07/2012 - Retirado email fabiano@viacredi.com.br do recebimento
                            do relatório (Guilherme Maba).

               06/08/2012 - Adicionado parametro "codigo do programa" a chamada
                            da funcao geradev. (Fabricio)

               08/08/2012 - Enviar email quando houver Cheque VLB no arquivo.
                            (Fabricio)

               22/08/2012 - Adicionado include "verifica_fraude_cheque".
                            (Fabricio/Ze).

               27/08/2012 - Alterado posições do cdtipchq de 52,2 para 148,3
                            (Lucas R.).

               27/08/2012 - Validações Projeto TIC (Richard/Supero).

               24/10/2012 - Comentar a validacao da TIC (Ze).

               10/12/2012 - Conversão Progress para PLSQL (Alisson/AMcom)

               28/11/2013 - Ajustes nas variaveis tratadas durante a iniprg (Marcos-Supero)

               18/12/2012 - Retirar comentario da validacao da TIC (Ze).

               20/12/2012 - Tratamento para AltoVale (Ze).

               11/01/2013 - Tratamento para AltoVale - TIC (Ze).

               18/01/2013 - Ajuste TIC - agencia apresent. e agencia dep. e
                            Ajuste no total do rel. 529_99 (Ze).

               10/06/2013 - Alteração função enviar_email_completo para
                            nova versão (Jean Michel).

               13/08/2013 - Exclusao da alinea 29. (Fabricio)

               01/10/2013 - Nova forma de chamar as agências, de PAC agora
                            a escrita será PA (André Euzébio - Supero).

               08/11/2013 - Adicionado o PA do cooperado ao conteudo do email
                            de notificacao de cheque VLB. (Fabricio)

               13/11/2013 - Tratamento para Migracao para Viacredi (Ze).

               22/11/2013 - Quando glb_nmtelant = 'COMPEFORA', passar como
                            parametro glb_dtmvtolt, caso contrario, passar
                            glb_dtmvtopr; isto para as procedures pi_cria_dev e
                            gera_dev_alinea37 - Softdesk 108637.
                            Calcular digito verificador do numero do cheque
                            (aux_nrdocmto) quando da critica 108 e NOT AVAIL
                            crapfdc - Softdesk 104767 (Fabricio)
                          - Incluido tratamento ref. devolucao em duplicidade
                            de alinea 37 no dia seguinte - Softdesk 108015
                            (Diego).

               06/12/2013 - Replicação da manutenção 11/2013 do progress para oracle (Odirlei/AMcom)

               06/01/2014 - Conforme solicitação do David Kistner, Todas as chamadas da procedure
                            pc_gera_dev_alinea37 devem passar o parâmetro pr_nrdconta com valor zerado.
                            (Marcos-Supero)

               17/01/2014 - Manter igualdade com o as implementações realizadas no Progress (Renato - Supero)
                          - Alterado totalizador derelatorio de 99 para 999.(Reinert)
                          - Tratamento da Migracao Acredi/Viacredi (Ze).

               20/01/2014 - Ajustes finos no tratamento de execução e quando levantar a exceção
                            para ir ao próximo arquivo, não escrever no log, pois isto já foi
                            feito na lógica antes do raise (Marcos-Supero)

               16/12/2103 - Manter igualdade com o Oracle (Gabriel).

               23/12/2013 - Alterado totalizador derelatorio de 99 para 999.(Reinert)

               08/01/2014 - Tratamento da Migracao Acredi/Viacredi (Ze).

               28/01/2014 - Adicionado critica 963 na lista de criticas apenas
                            de alertas, pois devem aparecer como INTEGRADO
                            no relatorio. (Fabricio)

               03/02/2014 - No find da crapfdc alterado crapfdc.nrctachq =
                            aux_setlinha,16,9 por "= aux_nrdconta" (Lucas R.)

               19/02/2014 - Manutenção ref. 201402 (Edison - AMcom)

               21/03/2014 - Ajustes na criação dos lotes conforme a craptco (Odirlei - AMcom)

               16/06/2014 - Buscar o motivo do CHEQ0001.pc_verifica_fraude_cheque
                            quando o motivo for 948 (Andrino-RKAM)

               22/07/2014 - Efetuado tratamento para depósito intercooperativa. (Reinert)

               15/09/2014 - Incluir tratamentos para incorporação Concredi pela Via
                            e Credimilsul pela SCRCred (Marcos-Supero)
               
               03/12/2014 - Alterar regra de leitura da crapcor, para passar
                           no campo nrdctabb o numero da conta na cooperativa antiga
                           (Odirlei/Amcom)
                           
               06/01/2015 - Ajustando a procedure para chamar o calculo do digito
                            verificador. SD-240104. (Andre Santos - SUPERO)
                            
               12/01/2015 - Ajuste para não gerar duplicidade na tabela gncpchq, 
                            qnd gerado registro com a critica 928 SD241941 (Odirlei-AMcom)             

               16/03/2015 - Ajustar critica de cooperado inexistente, para quando acontecer, 
                            pular para o próximo registro do arquivo deixando de fazer as demais 
                            validações do mesmo cheque por não se tratarde um cehque de cooperado valido.
                            SD-256627 ( Jean - RKAM )
                            
               20/05/2015 - (Chamado 283185) Retirado raise incluido no chamado 256627.
                            Esse raise estava gerando erros, nao gerando devolucao via
                            alinea 37 (Tiago Castro - RKAM).

               31/08/2015 - Projeto para tratamento dos programas que geram 
                            criticas que necessitam de lancamentos manuais 
                            pela contabilidade. (Jaison/Marcos-Supero)

               06/11/2015 - Ajuste para efetuar o log no arquivo proc_message.log
                            (Douglas - Chamado 306610)

               22/12/2015 - Ajustar os codigos de alines conforme revisao de alineas e 
                            processo de devolucao de cheque (Douglas - Melhoria 100)

         31/03/2016 - Ajuste para nao deixar alinea zerada na validação de historicos
               (Adriano - SD 426308).

               26/04/2016 - Ajuste para evitar geracao de raise quando tiver erro de 
                            conversao para numerico (vr_cdcritic:= 843) (Daniel) 
                            
               20/07/2016 - Ajustes referentes a Melhoria 69 - Devolucao automatica de cheques
                            (Lucas Ranghetti #484923)
                            
               07/10/2016 - Alteração do diretório para geração de arquivo contábil.
                            P308 (Ricardo Linhares).
                            
               04/11/2016 - Ajustar cursor de custodia de cheques - Projeto 300 (Rafael)

               24/11/2016 - Limpar variavel de critica auxiliar vr_cdcritic_aux para 
                            cada conta do arquivo - Melhoria 69 (Lucas Ranghetti/Elton)

               03/12/2016 - Incorporação Transulcred (Guilherme/SUPERO)

			         07/12/2016 - Ajustes referentes a M69, alinea 49 e leitura da crapneg
                            (Lucas Ranghetti/Elton)
                            
               12/01/2017 - Limpar crapdev com situacao devolvido, jogar as 
                            criticas 717 para o fim do relatorio e considerar
                            cheques que serao liberados saldo no dia como 
                            parte do saldo (Tiago/Elton SD584627)
                            
               16/02/2017 - Adicionar cooperativa migrada na verificacao do saldo
                            (Lucas Ranghetti #609838)
                            
               30/03/2017 - Alteração na geração do arquivo AAMMDD_CRITICAS.txt para gerar 
                            lançamentos da crítica de código 96 (Cheques com Contraordem).
                            P307 - (Jonatas - Supero)
 
               07/04/2017 - #642531 Tratamento do tail para pegar/validar os dados da última linha
                            do arquivo corretamente (Carlos)                            
                            
               26/06/2017 - Alteração na geração do arquivo AAMMDD_CRITICAS.txt para gerar 
                            lançamentos da crítica de código 950 414 - P307 - (Jonatas - Supero)                            
 
               21/06/2017 - Removidas condições que validam o valor de cheque VLB e enviam
                            email para o SPB. PRJ367 - Compe Sessao Unica (Lombardi)
 
               25/07/2017 - Incluir nova coluna nrctadep no relatorio crrl526 (Lucas Ranghetti #679023)
               
               08/08/2017 - Ajustes para criar craplcm para historicos 573 ou 78 caso a critica 96
                            (Lucas Ranghetti #715027)
                            
               29/08/2017 - Ajuste para gravar corretamente os dados do cheque, quando for contra-ordem (critica 96),
                            ao gerar o registro de lancamento na tabela craplcm
                            (Adriano - SD 746815). 
                            
               30/08/2017 - Ajuste para utilizar o lote 76000 e gravar o campo cdcmpchq ao criar o lançamento referente
                            a contra-ordem (critica 96)
                            (Adriano - SD 746815). 
                            
               01/09/2017 - SD737676 - Para evitar duplicidade devido o Matera mudar
			               o nome do arquivo apos processamento, iremos gerar o arquivo
						   _Criticas com o sufixo do crrl gerado por este (Marcos-Supero)
               11/09/2017 - Ajustes para criar craplcm para historicos 573 ou 78 caso a critica for 
                            96,257,414,439,950
                            (Adriano - SD 745649).                        
                            
               03/10/2017 - SD761624 - Inclusão de tratamento da Critica 811 - Marcos(Supero)           
                            
               04/01/2018 - #824564 Tratamento para incrementar nrseqdig em 100.000 ao tentar inserir índice
                           duplicado na craplcm (dup_val_on_index) (Carlos)

			   09/02/2018 - Adicionado coluna cdagenci no relatorio 526 - Chamado 771338 - Mateus Zimmermann (Mouts)
                            
               14/02/2018 - SD813179 - Verificar se existe devolucao alinea 70 igual a alinea 21 - Demetrius (Mouts)

			   23/03/2018 - Devido a uma solicitação da ABBC, foi necessário retirar os ajustes efetuados para atender 
					        o chamado SD813179 (Adriano).

               13/04/2018 - Removidas criticas 929 - COMPE SESSAO UNICA (Diego).
               
               04/05/2018 - Chamado #861675.
                           Quando é realizado a devolução automaática deve ser chamado a rotina para criaçaõ da crapdev
                           com insitdev = 1, pois neste programa já serã feito o lançamento de de volução do cheque 
                           na conta do cooperado. Sendo assim, no crps264 não será feito a devlução em duplicidade, apenas
                           será apresentado no relatório crrl219 que o mesmo já foi devolvido. (Wagner/Sustentação).
                           
               08/05/2018 - Efetuado manutenção para não enviar o relatório crrl564 a intranet. Ele não é mais usado
                            pela área de negócio (Jonata - MOUTS SCTASK0012408)                           
                           
			   18/05/2018 - Se conta está encerrada, gera devolução (crítica 64)              
                           
               28/05/2018 - ROLLBACK --> Chamado #861675.
                           Tivemos que voltar versão devido a não estar enviando os cheques para BBC
                           nestes casos, de devolução automática. (Wagner/Sustentação).

			   19/06/2018 - Removida a alteração realizada em 18/05/2018, pois foi realizado a solicitação para retirada 
							do requisito do projeto. (Renato Darosci - Supero)
                           
               08/08/2018 - Melhoria referente a devolucoes de cheques.
                            Chamado PRB0040059 (Gabriel - Mouts).

			   17/08/2018 - SCTASK0018345-Borderô desconto cheque - Paulo Martins - Mouts
               29/11/2018 - Inclusão de log para acompanhamento da crítica 717
                            INC0027476 - Ana - Envolti

				07/12/2018 - Melhoria no processo de devoluções de cheques.
                            Alcemir Mout's (INC0022559).

               27/12/2018 - Inclusão de mensagem para a crítica 757 conforme 
                            instruções da requisição. Chamado SCTASK0029400 - Gabriel (Mouts).
                            
               01/02/2019 - Tratamento para gerar alinea 49 na segunda apresentação da alinea 28
                            Chamado PRB0040576 - Jose Dill (Mouts).

			   07/12/2018 - Incluido parametros na abertura do cursor, Melhoria no processo de devoluções de cheques.
                            Adriano (INC0022559).

			   01/02/2019 - Tratamento para gerar alinea 49 na segunda apresentação da alinea 20
                      (Adriano - INC0011272).
               
               20/05/2019 - Projeto 565 - Alteração compensação cheques
                            Renato Cordeiro - Projeto 565 - Melhorias compensação cheques.
         19/07/2019 - Projeto 565 - Alteração compensação cheques
                      Rafael Rocha - Projeto 565 - INsert na tbcompe_suaremessa

         12/08/2019 - Projeto 565 - Ajuste na Alteração compensação cheques
                      Renato Cordeiro - Projeto 565 - INsert na tbcompe_suaremessa

............................................................................. */

     DECLARE

       --INC0027476
       vr_idprglog     tbgen_prglog.idprglog%TYPE := 0;
       vr_dsparame     VARCHAR2(4000);
       vr_des_corpo    VARCHAR2(4000);

      -- variáveis para controle de arquivos
       vr_dircon VARCHAR2(200);
       vr_arqcon VARCHAR2(200);

       /* Declaracao dos registros e vetores */

       -- Definicao do tipo de registro de rejeicao
       TYPE typ_reg_craprej IS
       RECORD (cdcooper craprej.cdcooper%TYPE
              ,dtrefere craprej.dtrefere%TYPE
              ,nrdconta craprej.nrdconta%TYPE
              ,nrdocmto craprej.nrdocmto%TYPE
              ,vllanmto craprej.vllanmto%TYPE
              ,nrseqdig craprej.nrseqdig%TYPE
              ,cdcritic craprej.cdcritic%TYPE
              ,cdpesqbb craprej.cdpesqbb%TYPE
              ,nrctadep craprej.nrdctitg%TYPE
			  ,cdagenci craprej.cdagenci%TYPE
              ,dscritic VARCHAR2(4000));

       -- Definicao do tipo de tabela de rejeicao
       TYPE typ_tab_craprej IS
         TABLE OF typ_reg_craprej
         INDEX BY VARCHAR2(300);

       TYPE typ_reg_critica IS 
       RECORD(dscritic VARCHAR2(4000)
             ,nrdconta craprej.nrdconta%TYPE
             ,nrseqdig craprej.nrseqdig%TYPE
             ,nrdocmto craprej.nrdocmto%TYPE
             ,vllanmto craprej.vllanmto%TYPE
             ,dspesqbb VARCHAR2(100) 
             ,cdtipdoc NUMBER
             ,nrctadep NUMBER
			 ,cdagenci craprej.cdagenci%TYPE);
             
       TYPE typ_tab_critica IS TABLE OF typ_reg_critica INDEX BY PLS_INTEGER;

       --Vetor para armazenar os arquivos para processamento
       vr_vet_nmarquiv GENE0002.typ_split;

       -- Definicao do tipo de registro para relatorio crps533
       TYPE typ_reg_relat_cecred IS
         RECORD(cdbanchq NUMBER
               ,cdagechq NUMBER
               ,cdcmpchq NUMBER
               ,nrctachq NUMBER
               ,cdtpddoc NUMBER
               ,vllanmto NUMBER);

       -- Tipo tabela para comportar um registro typ_reg_relat_cecred
       TYPE typ_tab_relat_cecred IS
         TABLE OF typ_reg_relat_cecred
         INDEX BY VARCHAR2(40);

       -- Vetor do Tipo typ_tab_relat_cecred
       vr_tab_relat_cecred  typ_tab_relat_cecred;

       -- Definicao do tipo de registro para a tabela genérica - crps533
       TYPE typ_reg_chqtco IS
         RECORD(cdcooper NUMBER
               ,nrdconta NUMBER
               ,nrdctabb NUMBER
               ,cdagenci NUMBER
               ,cdbccxlt NUMBER
               ,tplotmov NUMBER
               ,nrdocmto NUMBER
               ,cdbanchq NUMBER
               ,nrlotchq NUMBER
               ,sqlotchq NUMBER
               ,cdcmpchq NUMBER
               ,cdagechq NUMBER
               ,nrctachq NUMBER
               ,cdtpddoc NUMBER
               ,cdhistor NUMBER
               ,vllanmto NUMBER
               ,nrseqarq NUMBER
               ,cdpesqbb VARCHAR2(200)
               ,cdbandep NUMBER
               ,cdcmpdep NUMBER
               ,cdagedep NUMBER
               ,nrctadep NUMBER
               ,nrddigv1 NUMBER
               ,nrddigv2 NUMBER
               ,nrddigv3 NUMBER
               ,cdtipchq NUMBER
               ,cdtipdoc NUMBER);

       -- Tipo tabela para comportar um registro typ_reg_chqtco
       TYPE typ_tab_chqtco IS
         TABLE OF typ_reg_chqtco
         INDEX BY BINARY_INTEGER;

       -- Vetor do tipo typ_tab_chqtco
       vr_tab_chqtco  typ_tab_chqtco;

       -- Vetor do tipo typ_tab_craprej
       vr_tab_craprej typ_tab_craprej;

       -- Vetor de criticas que vao para o final do relatorio
       vr_tab_critica typ_tab_critica;
       vr_idx_cri INTEGER;

       --Tipo de Tabela de memoria para associados
       TYPE typ_reg_crapass IS
         RECORD (nrdconta crapass.nrdconta%type
                ,cdsitdct crapass.cdsitdct%type
                ,cdagenci crapass.cdagenci%type
                ,cdsitdtl crapass.cdsitdtl%TYPE
                ,vllimcre crapass.vllimcre%TYPE);

       --Tipo de tabela para associados
       TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;
       --Tipo de tabela para negativos
       TYPE typ_tab_crapneg IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(20);

       --Tabela de memoria de associados
       vr_tab_crapass typ_tab_crapass;

       --Tabela de memoria de negativos
       vr_tab_crapneg typ_tab_crapneg;

       /* Cursores Locais da pc_crps533 */

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
         SELECT cop.cdcooper
               ,cop.nmrescop
               ,cop.nrtelura
               ,cop.cdbcoctl
               ,cop.cdagectl
               ,cop.dsdircop
         FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop        cr_crapcop%ROWTYPE;
       rw_crapcop_incorp cr_crapcop%ROWTYPE;

       -- Selecionar cooperativa pela agencia na central
       CURSOR cr_crapcoop (pr_cdagectl IN crapcop.cdagectl%TYPE) IS
         SELECT cop.cdcooper
           FROM crapcop cop
          WHERE cop.cdagectl = pr_cdagectl;
       rw_crapcoop cr_crapcoop%ROWTYPE;

       -- Cursor genérico de calendário
       rw_crapdat btch0001.cr_crapdat%ROWTYPE;

       --Selecionar os dados da tabela de Associados
       CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE) IS
         SELECT /*+ INDEX (crapass crapass##crapass7) */
                crapass.nrdconta
               ,crapass.cdsitdct
               ,crapass.cdagenci
               ,crapass.cdsitdtl
               ,crapass.vllimcre
          FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper;
       rw_crapass cr_crapass%ROWTYPE;

       --Selecionar Saldos Negativos e Devolucoes de Cheque
       CURSOR cr_crapneg (pr_cdcooper IN crapneg.cdcooper%TYPE) IS
         SELECT /*+ index (crapneg crapneg##crapneg7) */
                crapneg.nrdconta
               ,crapneg.nrdocmto
               ,crapneg.cdobserv
          FROM crapneg crapneg
         WHERE crapneg.cdcooper = pr_cdcooper
         AND   crapneg.cdhisest = 1
         AND   crapneg.cdobserv IN (12,13,14,20,25,28,30,35,43,44,45)
         AND   crapneg.dtfimest IS NULL;
       rw_crapneg cr_crapneg%ROWTYPE;

       --Selecionar Saldos Negativos e Devolucoes de Cheque
       CURSOR cr_crapneg_reg (pr_cdcooper IN crapneg.cdcooper%TYPE,
                              pr_nrdconta IN crapneg.nrdconta%TYPE,
                              pr_nrdocmto IN crapneg.nrdocmto%TYPE,
                              pr_cdobserv IN NUMBER ) IS
         SELECT /*+ index (crapneg crapneg##crapneg7) */
                crapneg.nrdconta
               ,crapneg.nrdocmto
               ,crapneg.cdobserv
          FROM crapneg crapneg
         WHERE crapneg.cdcooper = pr_cdcooper
         AND   crapneg.cdhisest = 1
         AND   crapneg.nrdconta = pr_nrdconta
         AND   crapneg.nrdocmto = pr_nrdocmto
         AND   crapneg.cdobserv = pr_cdobserv
         AND   crapneg.dtfimest IS NULL;
       rw_crapneg_reg cr_crapneg_reg%ROWTYPE;
       
       --Selecionar Saldos Negativos e Devolucoes de Cheque
       CURSOR cr_crapneg_2 (pr_cdcooper IN crapneg.cdcooper%TYPE,
                                  pr_nrdconta IN crapneg.nrdconta%TYPE,
                            pr_nrdocmto IN crapneg.nrdocmto%TYPE) IS
         SELECT /*+ index (crapneg crapneg##crapneg7) */
                crapneg.nrdconta
               ,crapneg.nrdocmto
               ,crapneg.cdobserv
          FROM crapneg crapneg
         WHERE crapneg.cdcooper = pr_cdcooper
         AND   crapneg.cdhisest = 1
         AND   crapneg.nrdconta = pr_nrdconta
         AND   crapneg.nrdocmto = pr_nrdocmto
         AND   crapneg.cdobserv IN (11,12,13,14,20,25,28,30,35,43,44,45)
         AND   crapneg.dtfimest IS NULL;
       rw_crapneg_2 cr_crapneg_2%ROWTYPE;
       
       -- Verificar se devolucao é automatica
       CURSOR cr_tbchq_param_conta(pr_cdcooper crapcop.cdcooper%TYPE
                                  ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT tbchq.flgdevolu_autom
          FROM tbchq_param_conta tbchq
         WHERE tbchq.cdcooper = pr_cdcooper
           AND tbchq.nrdconta = pr_nrdconta;
        rw_tbchq_param_conta cr_tbchq_param_conta%ROWTYPE;

       CURSOR cr_crapage(pc_cdcooper IN crapage.cdcooper%TYPE) IS
             SELECT a.cdagepac
             FROM crapage a
             WHERE a.cdcooper = pr_cdcooper;
       rw_crapage  cr_crapage%ROWTYPE;

      TYPE typ_reg_crapage IS
         RECORD (cdagepac crapage.cdagepac%type);

       --Tipo de tabela para associados
       TYPE tab_reg_crapage IS TABLE OF typ_reg_crapage INDEX BY PLS_INTEGER;

       vr_tab_crapage tab_reg_crapage;

       /* Variaveis Locais da pc_crps533 */

       vr_exc_saida       EXCEPTION;
       vr_exc_erro        EXCEPTION;
       vr_exc_fimprg      EXCEPTION;
       vr_typ_saida       VARCHAR2(3);
       vr_dircop_imp      VARCHAR2(200);
       vr_nom_direto      VARCHAR2(200);
       vr_dircop_salvar   VARCHAR2(200);
       vr_dircop_rlnsv    VARCHAR2(200);
       vr_email_dest      VARCHAR2(500);
       vr_caminho_integra VARCHAR2(1000);
       vr_comando         VARCHAR2(4000);
       vr_des_erro        VARCHAR2(4000);
       vr_nmarquiv        VARCHAR2(4000);
       vr_lstdarqv        VARCHAR2(4000);
       vr_nmarquiv_incorp VARCHAR2(4000);
       vr_lstdarqv_incorp VARCHAR2(4000);
       vr_nmformul        VARCHAR2(100);
       vr_dtauxili        VARCHAR2(8);
       vr_nrcopias        NUMBER;
       vr_vlchqvlb        NUMBER;
       vr_cdcritic        NUMBER;
       vr_cdempres        NUMBER;
       vr_cdagenci        NUMBER:= 1;
       vr_tplotmov        NUMBER:= 1;
       vr_numlotebco      NUMBER;
       vr_vlsddisp        NUMBER;
       vr_vldeplib        NUMBER;
       vr_alinea_96       NUMBER;
       
       vr_flg_criou_lcm   BOOLEAN := FALSE;
       vr_nrseqdig        NUMBER;
       
       aux_imprimir       VARCHAR2(4000);
       
       -- Código do programa
       vr_cdprogra crapprg.cdprogra%TYPE;

       --Variaveis de controle do Lote
       vr_nmrescop        crapcop.nmrescop%TYPE;
       vr_dtleiarq        crapdat.dtmvtoan%TYPE;
       vr_cdbanctl        crapcop.cdbcoctl%TYPE;
       vr_cdagectl        crapcop.cdagectl%TYPE;
       vr_cdbccxlt        crapcop.cdbcoctl%TYPE;
       vr_cdcooper_incorp crapcop.cdcooper%TYPE;
       vr_cdbanctl_incorp crapcop.cdbcoctl%TYPE;
       vr_cdagectl_incorp crapcop.cdagectl%TYPE;
       vr_dstextab_vlb    craptab.dstextab%TYPE;
       vr_dstextab_comp   craptab.dstextab%TYPE;

       vr_input_file      utl_file.file_type;

       --Variaveis para indices
       vr_index_crapneg VARCHAR2(20);

       vr_tab_erro      gene0001.typ_tab_erro;
       --Tipo da tabela de saldos
       vr_tab_saldo EXTR0001.typ_tab_saldos;
       
       /* Procedure de Criação da tabela genérica GNCPCHQ */
       PROCEDURE pc_cria_generica_tco (pr_cdcooper  IN crapdev.cdcooper%TYPE
                                      ,pr_cdagenci  IN gncpchq.cdagenci%TYPE
                                      ,pr_dtmvtolt  IN gncpchq.dtliquid%TYPE
                                      ,pr_cdcritic  IN gncpchq.cdcritic%TYPE
                                      ,pr_dtleiarq  IN DATE
                                      ,pr_cdagectl  IN gncpchq.cdagectl%TYPE
                                      ,pr_nmarquiv  IN gncpchq.nmarquiv%TYPE
                                      ,pr_nrdocmto  IN gncpchq.nrcheque%TYPE
                                      ,pr_cdbanchq  IN gncpchq.cdbanchq%TYPE
                                      ,pr_cdagechq  IN gncpchq.cdagechq%TYPE
                                      ,pr_nrctachq  IN gncpchq.nrctachq%TYPE
                                      ,pr_cdcmpchq  IN gncpchq.cdcmpchq%TYPE
                                      ,pr_vlcheque  IN gncpchq.vlcheque%TYPE
                                      ,pr_nrdconta  IN gncpchq.nrdconta%TYPE
                                      ,pr_nrddigv1  IN gncpchq.nrddigv1%TYPE
                                      ,pr_nrddigv2  IN gncpchq.nrddigv2%TYPE
                                      ,pr_nrddigv3  IN gncpchq.nrddigv3%TYPE
                                      ,pr_cdtipchq  IN gncpchq.cdtipchq%TYPE
                                      ,pr_cdtipdoc  IN gncpchq.cdtipdoc%TYPE
                                      ,pr_nrseqarq  IN gncpchq.nrseqarq%TYPE
                                      ,pr_dsidenti  IN gncpchq.dsidenti%TYPE
                                      ,pr_dscritic OUT VARCHAR2) IS

          /* Variaveis locais da procedure */
          vr_retdig BOOLEAN;
          vr_nrcheque   gncpchq.nrcheque%TYPE;
          vr_cdtipreg   gncpchq.cdtipreg%TYPE;
          vr_exc_erro   EXCEPTION;
          
      

        BEGIN

          --Multiplica o nrdocmto po 10
          vr_nrcheque:= pr_nrdocmto * 10;
          vr_retdig := GENE0005.fn_calc_digito(pr_nrcalcul => vr_nrcheque);
          vr_nrcheque := TO_NUMBER(vr_nrcheque);

          -- Atribui valor para variavel de acordo com o parametro
          IF pr_cdcritic = 0 THEN
            vr_cdtipreg:= 4;
          ELSE
            vr_cdtipreg:= 3;
          END IF;

          /* Criação da tabela genérica - GNCPCHQ */
          INSERT INTO gncpchq (cdcooper
                              ,cdagenci
                              ,dtmvtolt
                              ,dtliquid
                              ,cdagectl
                              ,cdbanchq
                              ,cdagechq
                              ,nrctachq
                              ,nrcheque
                              ,cdcmpchq
                              ,vlcheque
                              ,nrdconta
                              ,nrddigv1
                              ,nrddigv2
                              ,nrddigv3
                              ,cdtipchq
                              ,cdtipdoc
                              ,nmarquiv
                              ,cdoperad
                              ,hrtransa
                              ,cdtipreg
                              ,flgconci
                              ,nrseqarq
                              ,cdcritic
                              ,flgpcctl
                              ,dsidenti)
                      VALUES  (pr_cdcooper
                              ,nvl(pr_cdagenci,0)
                              ,pr_dtleiarq
                              ,pr_dtmvtolt
                              ,nvl(pr_cdagectl,0)
                              ,nvl(pr_cdbanchq,0)
                              ,nvl(pr_cdagechq,0)
                              ,nvl(pr_nrctachq,0)
                              ,nvl(vr_nrcheque,0)
                              ,nvl(pr_cdcmpchq,0)
                              ,nvl(pr_vlcheque,0)
                              ,nvl(pr_nrdconta,0)
                              ,nvl(pr_nrddigv1,0)
                              ,nvl(pr_nrddigv2,0)
                              ,nvl(pr_nrddigv3,0)
                              ,nvl(pr_cdtipchq,0)
                              ,nvl(pr_cdtipdoc,0)
                              ,nvl(pr_nmarquiv,' ')
                              ,'1'
                              ,GENE0002.fn_busca_time
                              ,nvl(vr_cdtipreg,0)
                              ,0
                              ,nvl(pr_nrseqarq,0)
                              ,nvl(pr_cdcritic,0)
                              ,0
                              ,nvl(pr_dsidenti,' '));

        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao inserir a devolução na pc_cria_generica_tco. Detalhes: '||sqlerrm;
        END pc_cria_generica_tco;

       /* Procedure de processamento do vetor vr_tab_chqtco */
       PROCEDURE pc_processamento_tco(pr_cdcooper  IN crapdev.cdcooper%TYPE
                                     ,pr_dtmvtolt  IN craplot.dtmvtolt%TYPE
                                     ,pr_cdagenci  IN craplot.cdagenci%TYPE
                                     ,pr_cdbccxlt  IN craplot.cdbccxlt%TYPE
                                     ,pr_tplotmov  IN craplot.tplotmov%TYPE
                                     ,pr_dtleiarq  IN crapdat.dtmvtolt%TYPE
                                     ,pr_nmarquiv  IN gncpchq.nmarquiv%TYPE
                                     ,pr_cdbcoctl  IN crapcop.cdbcoctl%TYPE
                                     ,pr_cdagectl  IN crapcop.cdagectl%TYPE
                                     ,pr_dstextab  IN craptab.dstextab%TYPE
                                     ,pr_dscritic OUT VARCHAR2) IS

         --Buscar informacoes de lote
         CURSOR cr_craplot_tco (pr_cdcooper IN craplot.cdcooper%TYPE
                           ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                           ,pr_cdagenci IN craplot.cdagenci%TYPE
                           ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                           ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
           SELECT  craplot.rowid
                  ,craplot.cdagenci
                  ,craplot.cdbccxlt
                  ,craplot.nrdolote
                  ,craplot.dtmvtolt
            FROM craplot craplot
           WHERE craplot.cdcooper = pr_cdcooper
           AND   craplot.dtmvtolt = pr_dtmvtolt
           AND   craplot.cdagenci = pr_cdagenci
           AND   craplot.cdbccxlt = pr_cdbccxlt
           AND   craplot.nrdolote = pr_nrdolote;
         rw_craplot cr_craplot_tco%ROWTYPE;

         -- Buscar as folhas de cheques emitidas para o cooperado (CRAPFDC)
         CURSOR cr_crapfdc_tco (pr_cdcooper crapfdc.cdcooper%TYPE
                               ,pr_cdbcoctl crapfdc.cdbanchq%TYPE
                               ,pr_cdagectl crapfdc.cdagechq%TYPE
                               ,pr_nrctachq crapfdc.nrctachq%TYPE
                               ,pr_nrcheque crapfdc.nrcheque%TYPE) IS
           SELECT /*+ INDEX (crapfdc crapfdc##crapfdc1) */ crapfdc.rowid
            FROM crapfdc  crapfdc
           WHERE crapfdc.cdcooper = pr_cdcooper
           AND   crapfdc.cdbanchq = pr_cdbcoctl
           AND   crapfdc.cdagechq = pr_cdagectl
           AND   crapfdc.nrctachq = pr_nrctachq
           AND   crapfdc.nrcheque = pr_nrcheque;
         rw_crapfdc  cr_crapfdc_tco%ROWTYPE;

         -- Busca Lançamentos da conta
         CURSOR cr_craplcm_tco (pr_cdcooper   craplcm.cdcooper%TYPE
                               ,pr_dtmvtolt   craplcm.dtmvtolt%TYPE
                               ,pr_cdagenci   craplcm.cdagenci%TYPE
                               ,pr_cdbccxlt   craplcm.cdbccxlt%TYPE
                               ,pr_nrdolote   craplcm.nrdolote%TYPE
                               ,pr_nrdctabb   craplcm.nrdctabb%TYPE
                               ,pr_nrdocmto   craplcm.nrdocmto%TYPE) IS
            SELECT craplcm.ROWID
                  ,craplcm.nrseqdig
              FROM craplcm  craplcm
             WHERE craplcm.cdcooper = pr_cdcooper
             AND   craplcm.dtmvtolt = pr_dtmvtolt
             AND   craplcm.cdagenci = pr_cdagenci
             AND   craplcm.cdbccxlt = pr_cdbccxlt
             AND   craplcm.nrdolote = pr_nrdolote
             AND   craplcm.nrdctabb = pr_nrdctabb
             AND   craplcm.nrdocmto = pr_nrdocmto;
         rw_craplcm  cr_craplcm_tco%ROWTYPE;

         /* Variaveis Locais */
         vr_contareg      NUMBER:= 0;
         vr_flgproc       BOOLEAN;
         vr_flgdig        BOOLEAN;
         vr_flgsair       BOOLEAN;
         vr_cdcritic      NUMBER:= 0;
         vr_segpar        NUMBER:= 0;
         vr_nrdocmt2      NUMBER:= 0;
         vr_dscritic      VARCHAR2(4000);
         vr_compl_erro    VARCHAR2(4000);
         vr_nrlotetc      craplot.nrdolote%TYPE;
         vr_nrlottco      craplot.nrdolote%TYPE;
         vr_flgeneri      BOOLEAN := FALSE; 

       BEGIN

         -- Percorrer o vetor vr_tab_chqtco
         FOR idx IN 1..vr_tab_chqtco.COUNT LOOP
           -- Selecionar as folhas de cheques emitidas para o cooperado (CRAPFDC)
           OPEN cr_crapfdc_tco (pr_cdcooper => pr_cdcooper
                               ,pr_cdbcoctl => pr_cdbcoctl
                               ,pr_cdagectl => pr_cdagectl
                               ,pr_nrctachq => vr_tab_chqtco(idx).nrctachq
                               ,pr_nrcheque => vr_tab_chqtco(idx).nrdocmto);
           FETCH cr_crapfdc_tco INTO rw_crapfdc;
           IF cr_crapfdc_tco%NOTFOUND THEN
             -- Montar mensagem de critica
             vr_cdcritic := 129;
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             vr_compl_erro:= ' Cop: ' || pr_cdcooper ||
                             ' Bco: ' || pr_cdbcoctl ||
                             ' Age: ' || pr_cdagectl ||
                             ' Cta: ' || vr_tab_chqtco(idx).nrctachq ||
                             ' Chq: ' || vr_tab_chqtco(idx).nrdocmto;
             -- Enviar a critica para o log
             btch0001.pc_gera_log_batch(pr_cdcooper   => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic
                                                   || vr_compl_erro);
             --Fechar o Cursor
             CLOSE cr_crapfdc_tco;

             --Pular para proximo registro
             CONTINUE;

           END IF; --cr_crapfdc%NOTFOUND
           --Fechar o Cursor
           CLOSE cr_crapfdc_tco;

           --Incrementar contador registros processados
           vr_contareg:= nvl(vr_contareg,0) + 1;
           vr_nrlotetc:= 7009;

           --Se for o primeiro
           IF vr_contareg = 1 THEN

             --Inicializar variavel de controle
             vr_flgsair:= FALSE;

             WHILE NOT vr_flgsair LOOP
               --Selecionar o Ultimo Lote
               OPEN cr_craplot_tco (pr_cdcooper => vr_tab_chqtco(idx).cdcooper
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_cdbccxlt => pr_cdbccxlt
                                   ,pr_nrdolote => vr_nrlotetc);
               --Posicionar no proximo registro
               FETCH cr_craplot_tco INTO rw_craplot;
               --Se encontrou registro
               IF cr_craplot_tco%FOUND THEN
                 --Incrementa contador
                 vr_nrlotetc:= vr_nrlotetc+1;
               ELSE
                 vr_nrlottco:= vr_nrlotetc;
                 vr_flgsair:= TRUE;
               END IF;
               --Fechar Cursor
               CLOSE cr_craplot_tco;
             END LOOP; --vr_flgsair

             --Inserir Lote
             BEGIN
               INSERT INTO craplot (cdcooper
                                   ,dtmvtolt
                                   ,cdagenci
                                   ,cdbccxlt
                                   ,nrdolote
                                   ,tplotmov)
                           VALUES  (vr_tab_chqtco(idx).cdcooper
                                   ,pr_dtmvtolt
                                   ,nvl(pr_cdagenci,0)
                                   ,nvl(pr_cdbccxlt,0)
                                   ,nvl(vr_nrlottco,0)
                                   ,nvl(pr_tplotmov,0))
               RETURNING craplot.ROWID
                        ,craplot.cdagenci
                        ,craplot.cdbccxlt
                        ,craplot.nrdolote
                        ,craplot.dtmvtolt
               INTO rw_craplot.rowid
                   ,rw_craplot.cdagenci
                   ,rw_craplot.cdbccxlt
                   ,rw_craplot.nrdolote
                   ,rw_craplot.dtmvtolt;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_dscritic:= 'Erro ao inserir na tabela de lotes. '||sqlerrm;
                 RAISE vr_exc_erro;
             END;
           END IF; --vr_contareg = 1
           
           -- iniciar variavel
           vr_flgeneri := FALSE;
           
           -- Se tipo documento for um dos especificados entao cria 928
           IF vr_tab_chqtco(idx).cdtpddoc IN (75,76,77,90,94,95) THEN
             --Executa rotina pi_cria_generica_tco para cdcritic=928
             pc_cria_generica_tco(pr_cdcooper   => vr_tab_chqtco(idx).cdcooper
                                 ,pr_cdagenci   => vr_tab_chqtco(idx).cdagenci
                                 ,pr_dtmvtolt   => pr_dtmvtolt
                                 ,pr_cdcritic   => 928
                                 ,pr_dtleiarq   => pr_dtleiarq
                                 ,pr_cdagectl   => pr_cdagectl
                                 ,pr_nmarquiv   => pr_nmarquiv
                                 ,pr_nrdocmto   => vr_tab_chqtco(idx).nrdocmto
                                 ,pr_cdbanchq   => vr_tab_chqtco(idx).cdbanchq
                                 ,pr_cdagechq   => vr_tab_chqtco(idx).cdagechq
                                 ,pr_nrctachq   => vr_tab_chqtco(idx).nrctachq
                                 ,pr_cdcmpchq   => vr_tab_chqtco(idx).cdcmpchq
                                 ,pr_vlcheque   => vr_tab_chqtco(idx).vllanmto
                                 ,pr_nrdconta   => vr_tab_chqtco(idx).nrdconta
                                 ,pr_nrddigv1   => vr_tab_chqtco(idx).nrddigv1
                                 ,pr_nrddigv2   => vr_tab_chqtco(idx).nrddigv2
                                 ,pr_nrddigv3   => vr_tab_chqtco(idx).nrddigv3
                                 ,pr_cdtipchq   => vr_tab_chqtco(idx).cdtipchq
                                 ,pr_cdtipdoc   => vr_tab_chqtco(idx).cdtipdoc
                                 ,pr_nrseqarq   => vr_tab_chqtco(idx).nrseqarq
                                 ,pr_dsidenti   => vr_tab_chqtco(idx).cdpesqbb
                                 ,pr_dscritic   => vr_dscritic);

             IF vr_dscritic IS NOT NULL THEN
               --Abortar o programa
               RAISE vr_exc_erro;
             END IF;
             
             -- controle se já gerou tabela generica
             vr_flgeneri := TRUE;
             
           END IF;

           --Tirar casas decimais do numero documento
           vr_nrdocmt2:= vr_tab_chqtco(idx).nrdocmto * 10;
           --Calcula o digito verificador
           vr_flgdig:= GENE0005.fn_calc_digito(vr_nrdocmt2);

           vr_flgproc:= TRUE;
           -- Processar select até não encontrar
           WHILE vr_flgproc LOOP
             -- Selecionar os lançamentos
             OPEN cr_craplcm_tco  (pr_cdcooper   => vr_tab_chqtco(idx).cdcooper
                                  ,pr_dtmvtolt   => pr_dtmvtolt
                                  ,pr_cdagenci   => vr_tab_chqtco(idx).cdagenci
                                  ,pr_cdbccxlt   => vr_tab_chqtco(idx).cdbccxlt
                                  ,pr_nrdolote   => vr_nrlotetc
                                  ,pr_nrdctabb   => vr_tab_chqtco(idx).nrdctabb
                                  ,pr_nrdocmto   => vr_nrdocmt2);
             FETCH cr_craplcm_tco INTO rw_craplcm;
             -- Se não encontrou sai do loop
             IF cr_craplcm_tco%NOTFOUND THEN
               --Fechar o cursor
               CLOSE cr_craplcm_tco;
               vr_flgproc:= FALSE;
             ELSE
               vr_nrdocmt2:= nvl(vr_nrdocmt2,0) + 1000000;
               --Fechar o cursor
               CLOSE cr_craplcm_tco;
             END IF;
           END LOOP;

           vr_flg_criou_lcm := FALSE;
           vr_nrseqdig := nvl(vr_tab_chqtco(idx).nrseqarq,0);
           
           WHILE NOT vr_flg_criou_lcm LOOP
           BEGIN
             --Inserir Lancamentos de deposito a vista (CRAPLCM)
             INSERT INTO craplcm (craplcm.cdcooper
                               ,craplcm.dtmvtolt
                               ,craplcm.cdagenci
                               ,craplcm.cdbccxlt
                               ,craplcm.nrdolote
                               ,craplcm.nrdconta
                               ,craplcm.nrdctabb
                               ,craplcm.nrdocmto
                               ,craplcm.cdhistor
                               ,craplcm.vllanmto
                               ,craplcm.nrseqdig
                               ,craplcm.cdpesqbb
                               ,craplcm.dtrefere
                               ,craplcm.cdbanchq
                               ,craplcm.cdcmpchq
                               ,craplcm.cdagechq
                               ,craplcm.nrctachq
                               ,craplcm.sqlotchq
                               ,craplcm.nrlotchq
                               ,craplcm.cdcoptfn)
                          VALUES
                               (vr_tab_chqtco(idx).cdcooper
                               ,pr_dtmvtolt
                               ,nvl(pr_cdagenci,0)
                               ,nvl(pr_cdbccxlt,0)
                               ,nvl(vr_nrlotetc,0)
                               ,nvl(vr_tab_chqtco(idx).nrdconta,0)
                               ,nvl(vr_tab_chqtco(idx).nrdctabb,0)
                               ,nvl(vr_nrdocmt2,0)
                               ,nvl(vr_tab_chqtco(idx).cdhistor,0)
                               ,nvl(vr_tab_chqtco(idx).vllanmto,0)
                                 ,vr_nrseqdig
                               ,nvl(vr_tab_chqtco(idx).cdpesqbb,' ')
                               ,pr_dtleiarq
                               ,nvl(vr_tab_chqtco(idx).cdbandep,0)
                               ,nvl(vr_tab_chqtco(idx).cdcmpdep,0)
                               ,nvl(vr_tab_chqtco(idx).cdagedep,0)
                               ,nvl(vr_tab_chqtco(idx).nrctadep,0)
                               ,nvl(vr_tab_chqtco(idx).sqlotchq,0)
                               ,nvl(vr_tab_chqtco(idx).nrlotchq,0)
                               ,0)
             RETURNING craplcm.nrseqdig INTO rw_craplcm.nrseqdig;
           EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                 vr_nrseqdig := vr_nrseqdig + 100000;
                 continue;
             WHEN OTHERS THEN
                 cecred.pc_internal_exception;
               vr_dscritic:= 'Erro ao inserir craplcm na rotina pc_crps533.pc_processamento_tco: '||SQLERRM;
               RAISE vr_exc_erro;
           END;

             vr_flg_criou_lcm := TRUE;
             
           END LOOP;

           BEGIN
             --Atualizar capas de lote (CRAPLOT)
             UPDATE craplot SET  craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                                ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                                ,craplot.vlinfodb = nvl(craplot.vlinfodb,0) + nvl(vr_tab_chqtco(idx).vllanmto,0)
                                ,craplot.vlcompdb = nvl(craplot.vlcompdb,0) + nvl(vr_tab_chqtco(idx).vllanmto,0)
                                ,craplot.nrseqdig = vr_nrseqdig
             WHERE ROWID = rw_craplot.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic:= 'Erro ao atualizar craplot na rotina pc_crps533.pc_processamento_tco: '||SQLERRM;
               RAISE vr_exc_erro;
           END;

           BEGIN
             --Atualizar cadastro folhas cheque emitidas para cooperado (CRAPFDC)
             UPDATE crapfdc SET crapfdc.dtliqchq = pr_dtmvtolt
                               ,crapfdc.vlcheque = nvl(vr_tab_chqtco(idx).vllanmto,0)
                               ,crapfdc.cdbandep = nvl(vr_tab_chqtco(idx).cdbandep,0)
                               ,crapfdc.cdagedep = nvl(vr_tab_chqtco(idx).cdagedep,0)
                               ,crapfdc.nrctadep = nvl(vr_tab_chqtco(idx).nrctadep,0)
                               ,crapfdc.cdtpdchq = nvl(vr_tab_chqtco(idx).cdtpddoc,0)
                               ,crapfdc.incheque = crapfdc.incheque + 5
             WHERE ROWID = rw_crapfdc.ROWID;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic:= 'Erro ao atualizar crapfdc na rotina pc_crps533.pc_processamento_tco: '||SQLERRM;
               RAISE vr_exc_erro;
           END;
           
           -- gerar tabela generica de cheque somente se ainda não gerou o registro contendo a critica 928
           IF NOT vr_flgeneri THEN
             --Executa rotina pi_cria_generica_tco para cdcritic=0
             pc_cria_generica_tco(pr_cdcooper   => vr_tab_chqtco(idx).cdcooper
                                 ,pr_cdagenci   => vr_tab_chqtco(idx).cdagenci
                                 ,pr_dtmvtolt   => pr_dtmvtolt
                                 ,pr_cdcritic   => 0
                                 ,pr_dtleiarq   => pr_dtleiarq
                                 ,pr_cdagectl   => pr_cdagectl
                                 ,pr_nmarquiv   => pr_nmarquiv
                                 ,pr_nrdocmto   => vr_tab_chqtco(idx).nrdocmto
                                 ,pr_cdbanchq   => vr_tab_chqtco(idx).cdbanchq
                                 ,pr_cdagechq   => vr_tab_chqtco(idx).cdagechq
                                 ,pr_nrctachq   => vr_tab_chqtco(idx).nrctachq
                                 ,pr_cdcmpchq   => vr_tab_chqtco(idx).cdcmpchq
                                 ,pr_vlcheque   => vr_tab_chqtco(idx).vllanmto
                                 ,pr_nrdconta   => vr_tab_chqtco(idx).nrdconta
                                 ,pr_nrddigv1   => vr_tab_chqtco(idx).nrddigv1
                                 ,pr_nrddigv2   => vr_tab_chqtco(idx).nrddigv2
                                 ,pr_nrddigv3   => vr_tab_chqtco(idx).nrddigv3
                                 ,pr_cdtipchq   => vr_tab_chqtco(idx).cdtipchq
                                 ,pr_cdtipdoc   => vr_tab_chqtco(idx).cdtipdoc
                                 ,pr_nrseqarq   => vr_tab_chqtco(idx).nrseqarq
                                 ,pr_dsidenti   => vr_tab_chqtco(idx).cdpesqbb
                                 ,pr_dscritic   => vr_dscritic);

             IF vr_dscritic IS NOT NULL THEN
               --Abortar o programa
               RAISE vr_exc_erro;
             END IF;
           END IF;  
         END LOOP;--vr_tab_chqtco

       EXCEPTION
         WHEN vr_exc_erro THEN
           -- Efetuar rollback
           ROLLBACK;
           -- Retorno do erro
           pr_dscritic := vr_dscritic || vr_compl_erro;
         WHEN OTHERS THEN
           -- Efetuar rollback
           ROLLBACK;
           -- Gerar erro genérico tratado
           pr_dscritic := 'Erro na rotina pc_crps533.pc_processamento_tco. Detalhe: '||sqlerrm;
       END pc_processamento_tco;


       /* Procedure que popula vetor vr_tab_chqtco */
       PROCEDURE pc_cria_cheques_tco(pr_cdcooper IN NUMBER
                                    ,pr_nrdconta IN NUMBER
                                    ,pr_nrdctabb IN NUMBER
                                    ,pr_cdagenci IN NUMBER
                                    ,pr_cdbccxlt IN NUMBER
                                    ,pr_tplotmov IN NUMBER
                                    ,pr_nrdocmto IN NUMBER
                                    ,pr_cdbanchq IN NUMBER
                                    ,pr_nrlotchq IN NUMBER
                                    ,pr_sqlotchq IN NUMBER
                                    ,pr_cdcmpchq IN NUMBER
                                    ,pr_cdagechq IN NUMBER
                                    ,pr_nrctachq IN NUMBER
                                    ,pr_cdtpddoc IN NUMBER
                                    ,pr_vllanmto IN NUMBER
                                    ,pr_nrseqarq IN NUMBER
                                    ,pr_cdpesqbb IN VARCHAR2
                                    ,pr_cdbandep IN NUMBER
                                    ,pr_cdcmpdep IN NUMBER
                                    ,pr_cdagedep IN NUMBER
                                    ,pr_nrctadep IN NUMBER
                                    ,pr_setlinha IN VARCHAR2
                                    ,pr_tpcheque IN crapfdc.tpcheque%TYPE
                                    ,pr_dscritic OUT VARCHAR2) IS

         -- Variaveis Locais
         vr_cdhistor   NUMBER;
         vr_index      NUMBER;
       BEGIN

         --Verificar o tipo do cheque
         IF pr_tpcheque = 2 THEN
           vr_cdhistor:= 572;
         ELSE
           vr_cdhistor:= 524;
         END IF;

         --Verificar qual o proximo indice para o vetor
         vr_index:= vr_tab_chqtco.COUNT + 1;

         --Inserir no vetor as informacoes passadas como parametro
         vr_tab_chqtco(vr_index).cdcooper:= pr_cdcooper;
         vr_tab_chqtco(vr_index).nrdconta:= pr_nrdconta;
         vr_tab_chqtco(vr_index).nrdctabb:= pr_nrdctabb;
         vr_tab_chqtco(vr_index).cdagenci:= pr_cdagenci;
         vr_tab_chqtco(vr_index).cdbccxlt:= pr_cdbccxlt;
         vr_tab_chqtco(vr_index).tplotmov:= pr_tplotmov;
         vr_tab_chqtco(vr_index).nrdocmto:= pr_nrdocmto;
         vr_tab_chqtco(vr_index).cdbanchq:= pr_cdbanchq;
         vr_tab_chqtco(vr_index).nrlotchq:= pr_nrlotchq;
         vr_tab_chqtco(vr_index).sqlotchq:= pr_sqlotchq;
         vr_tab_chqtco(vr_index).cdcmpchq:= pr_cdcmpchq;
         vr_tab_chqtco(vr_index).cdagechq:= pr_cdagechq;
         vr_tab_chqtco(vr_index).nrctachq:= pr_nrctachq;
         vr_tab_chqtco(vr_index).cdtpddoc:= pr_cdtpddoc;
         vr_tab_chqtco(vr_index).cdhistor:= vr_cdhistor;
         vr_tab_chqtco(vr_index).vllanmto:= pr_vllanmto;
         vr_tab_chqtco(vr_index).nrseqarq:= pr_nrseqarq;
         vr_tab_chqtco(vr_index).cdpesqbb:= pr_cdpesqbb;
         vr_tab_chqtco(vr_index).cdbandep:= pr_cdbandep;
         vr_tab_chqtco(vr_index).cdcmpdep:= pr_cdcmpdep;
         vr_tab_chqtco(vr_index).cdagedep:= pr_cdagedep;
         vr_tab_chqtco(vr_index).nrctadep:= pr_nrctadep;
         vr_tab_chqtco(vr_index).nrddigv1:= TO_NUMBER(SUBSTR(pr_setlinha,24,1));
         vr_tab_chqtco(vr_index).nrddigv2:= TO_NUMBER(SUBSTR(pr_setlinha,11,1));
         vr_tab_chqtco(vr_index).nrddigv3:= TO_NUMBER(SUBSTR(pr_setlinha,31,1));
         vr_tab_chqtco(vr_index).cdtipchq:= TO_NUMBER(SUBSTR(pr_setlinha,51,1));
         vr_tab_chqtco(vr_index).cdtipdoc:= TO_NUMBER(SUBSTR(pr_setlinha,148,3));

       EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic:= 'Erro ao inserir a devolução na pc_cria_cheques_tco. Detalhes: '||sqlerrm;
       END pc_cria_cheques_tco;


       /* Procedure de Criação: cria_generica */
       PROCEDURE pc_cria_generica(pr_cdcooper   IN crapdev.cdcooper%TYPE
                                 ,pr_cdagenci   IN gncpchq.cdagenci%TYPE
                                 ,pr_dtmvtolt   IN gncpchq.dtliquid%TYPE
                                 ,pr_cdcritic   IN gncpchq.cdcritic%TYPE
                                 ,pr_dtleiarq   IN DATE
                                 ,pr_cdagectl   IN gncpchq.cdagectl%TYPE
                                 ,pr_nmarquiv   IN gncpchq.nmarquiv%TYPE
                                 ,pr_cdbanchq   IN gncpchq.cdbanchq%TYPE
                                 ,pr_cdagechq   IN gncpchq.cdagechq%TYPE
                                 ,pr_nrctachq   IN gncpchq.nrctachq%TYPE
                                 ,pr_nrdocmto   IN gncpchq.nrcheque%TYPE
                                 ,pr_cdcmpchq   IN gncpchq.cdcmpchq%TYPE
                                 ,pr_vllanmto   IN gncpchq.vlcheque%TYPE
                                 ,pr_nrdconta   IN gncpchq.nrdconta%TYPE
                                 ,pr_nrseqarq   IN gncpchq.nrseqarq%TYPE
                                 ,pr_cdpesqbb   IN gncpchq.dsidenti%TYPE
                                 ,pr_setlinha   IN VARCHAR2
                                 ,pr_dscritic   OUT VARCHAR2) IS

         -- Variaveis Locais
         vr_cdtipreg   gncpchq.cdtipreg%TYPE;
         vr_hora       NUMBER;
       BEGIN

         -- Atribui valor para variavel de acordo com o parametro
          IF pr_cdcritic = 0 THEN
            vr_cdtipreg:= 4;
          ELSE
            vr_cdtipreg:= 3;
          END IF;

          vr_hora := GENE0002.fn_busca_time;
          
          <<lb_gncpchq>>
          
          BEGIN
          /* Criação da tabela genérica - GNCPCHQ */
          INSERT INTO gncpchq (cdcooper
                              ,cdagenci
                              ,dtmvtolt
                              ,dtliquid
                              ,cdagectl
                              ,cdbanchq
                              ,cdagechq
                              ,nrctachq
                              ,nrcheque
                              ,cdcmpchq
                              ,vlcheque
                              ,nrdconta
                              ,nrddigv1
                              ,nrddigv2
                              ,nrddigv3
                              ,cdtipchq
                              ,cdtipdoc
                              ,nmarquiv
                              ,cdoperad
                              ,hrtransa
                              ,cdtipreg
                              ,flgconci
                              ,nrseqarq
                              ,cdcritic
                              ,flgpcctl
                              ,dsidenti)
                      VALUES  (pr_cdcooper
                              ,nvl(pr_cdagenci,0)
                              ,pr_dtleiarq
                              ,pr_dtmvtolt
                              ,nvl(pr_cdagectl,0)
                              ,nvl(pr_cdbanchq,0)
                              ,nvl(pr_cdagechq,0)
                              ,nvl(pr_nrctachq,0)
                              ,nvl(pr_nrdocmto,0)
                              ,nvl(pr_cdcmpchq,0)
                              ,nvl(pr_vllanmto,0)
                              ,nvl(pr_nrdconta,0)
                              ,TO_NUMBER(SUBSTR(pr_setlinha,24,1))
                              ,TO_NUMBER(SUBSTR(pr_setlinha,11,1))
                              ,TO_NUMBER(SUBSTR(pr_setlinha,31,1))
                              ,TO_NUMBER(SUBSTR(pr_setlinha,51,1))
                              ,TO_NUMBER(SUBSTR(pr_setlinha,148,3))
                              ,nvl(pr_nmarquiv,' ')
                              ,'1'
                                ,vr_hora
                              ,nvl(vr_cdtipreg,0)
                              ,0
                              ,nvl(pr_nrseqarq,0)
                              ,nvl(pr_cdcritic,0)
                              ,0
                              ,nvl(pr_cdpesqbb,0));

       EXCEPTION
               -- isto foi necessário fazer pois quando exite um mesmo cheque na seguencia do arquivo.
               -- pois pode ser que de chave duplicada quando é inserido no mesmo segundo.
              WHEN dup_val_on_index THEN
                vr_hora := vr_hora + 1;
                GOTO lb_gncpchq;
           END;         
       EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao inserir a devolução na pc_cria_generica.'|| ' cdcooper => '||pr_cdcooper
                                                                             || ' dtmvtolt => '||pr_dtmvtolt
                                                                             || ' Erro: '||sqlerrm;
       END pc_cria_generica;


       /* Procedure que gera a devolução alinea37 */
       PROCEDURE pc_cria_dev(pr_cdcooper IN crapdev.cdcooper%TYPE
                            ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE
                            ,pr_cdbccxlt IN crapdev.cdbccxlt%TYPE
                            ,pr_inchqdev NUMBER
                            ,pr_nrctaant IN NUMBER
                            ,pr_nrdconta IN crapdev.nrdconta%TYPE
                            ,pr_nrdocmto IN crapdev.nrcheque%TYPE
                            ,pr_nrdctitg IN crapdev.nrdctitg%TYPE
                            ,pr_vllanmto IN crapdev.vllanmto%TYPE
                            ,pr_cdalinea IN crapdev.cdalinea%TYPE
                            ,pr_cdhistor IN crapdev.cdhistor%TYPE
                            ,pr_cdoperad IN crapdev.cdoperad%TYPE
                            ,pr_cdagechq IN crapfdc.cdagechq%TYPE
                            ,pr_nrctachq IN crapfdc.nrctachq%TYPE
                            ,pr_cdbandep IN crapfdc.cdbandep%TYPE
                            ,pr_cdagedep IN crapfdc.cdagedep%TYPE
                            ,pr_nrctadep IN crapfdc.nrctadep%TYPE
                            ,pr_cdcritic OUT NUMBER
                            ,pr_dscritic OUT VARCHAR2) IS

          /* Selecionar os dados da cooperativa */
          CURSOR cr_crapcop_dev (pr_cdcooper crapcop.cdcooper%TYPE) IS
            SELECT crapcop.cdbcoctl
              FROM crapcop crapcop
             WHERE crapcop.cdcooper = pr_cdcooper;
          rw_crapcop  cr_crapcop_dev%ROWTYPE;

          /* Selecionar devoluções de cheque ou taxas de devolução */
          CURSOR cr_crapdev_dev (pr_cdcooper IN crapdev.cdcooper%TYPE
                                ,pr_cdbanchq IN crapdev.cdbanchq%TYPE
                                ,pr_cdagechq IN crapdev.cdagechq%TYPE
                                ,pr_nrctachq IN crapdev.nrctachq%TYPE
                                ,pr_nrcheque IN crapdev.nrcheque%TYPE
                                ,pr_cdhistor IN crapdev.cdhistor%TYPE
                                ,pr_vllanmto IN crapdev.vllanmto%TYPE
                                ,pr_cdbandep IN crapdev.cdbandep%TYPE
                                ,pr_cdagedep IN crapdev.cdagedep%TYPE
                                ,pr_nrctadep IN crapdev.nrctadep%TYPE
                                 ) IS
           SELECT 1
             FROM crapdev crapdev
            WHERE crapdev.cdcooper = pr_cdcooper
            AND   crapdev.cdbanchq = pr_cdbanchq
            AND   crapdev.cdagechq = pr_cdagechq
            AND   crapdev.nrctachq = pr_nrctachq
            AND   crapdev.nrcheque = pr_nrcheque
            AND   nvl(crapdev.cdbandep,0) = nvl(pr_cdbandep,0)
            AND   nvl(crapdev.cdagedep,0) = nvl(pr_cdagedep,0)
            AND   nvl(crapdev.nrctadep,0) = nvl(pr_nrctadep,0)
            AND   crapdev.vllanmto = pr_vllanmto     
            AND   crapdev.cdhistor IN (pr_cdhistor,46);
          rw_crapdev  cr_crapdev_dev%ROWTYPE;

          /* Variaveis locais da procedure */
          vr_indctitg   crapdev.indctitg%TYPE;
          vr_des_erro   VARCHAR2(4000);
          vr_exc_erro   EXCEPTION;

        BEGIN

          -- Se for cheque Normal
          IF  pr_inchqdev = 1 THEN
            -- Selecionar dados da Cooperativa
            OPEN cr_crapcop_dev(pr_cdcooper);
            FETCH cr_crapcop_dev INTO rw_crapcop;
            CLOSE cr_crapcop_dev;

            -- Selecionar devoluções de cheque
            OPEN cr_crapdev_dev (pr_cdcooper => pr_cdcooper
                                ,pr_cdbanchq => rw_crapcop.cdbcoctl
                                ,pr_cdagechq => pr_cdagechq
                                ,pr_nrctachq => pr_nrctachq
                                ,pr_nrcheque => pr_nrdocmto
                                ,pr_cdhistor => pr_cdhistor
                                ,pr_vllanmto => pr_vllanmto
                                ,pr_cdbandep => pr_cdbandep
                                ,pr_cdagedep => pr_cdagedep
                                ,pr_nrctadep => pr_nrctadep);
            FETCH cr_crapdev_dev INTO rw_crapdev;
            -- Se encontrou devolução entao retorna erro
            IF cr_crapdev_dev%FOUND THEN
              -- Fechar o cursor pois efetuaremos raise
              CLOSE cr_crapdev_dev;
              -- Montar mensagem de critica
              vr_cdcritic:= 415;
              vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
              RAISE vr_exc_erro;
            ELSE
              -- Se o indicador de conta integracao está preenchido atribui TRUE
              IF trim(pr_nrdctitg) IS NULL THEN
                vr_indctitg:= 0; --FALSE
              ELSE
                vr_indctitg:= 1; --TRUE
              END IF;

              -- Se não for uma das alineas listadas insere devolução historico 46
              IF NOT cheq0001.fn_existe_alinea(pr_cdalinea) THEN

               -- Inserir devolução de cheque historico 46
               BEGIN
                 INSERT INTO crapdev (cdcooper
                                     ,dtmvtolt
                                     ,cdbccxlt
                                     ,nrdconta
                                     ,nrdctabb
                                     ,nrdctitg
                                     ,nrcheque
                                     ,vllanmto
                                     ,cdalinea
                                     ,cdoperad
                                     ,cdhistor
                                     ,cdpesqui
                                     ,insitdev
                                     ,cdbanchq
                                     ,cdagechq
                                     ,nrctachq
                                     ,indevarq
                                     ,indctitg
                                     ,cdbandep
                                     ,nrctadep
                                     ,cdagedep)
                           VALUES  (pr_cdcooper          --cdcooper
                                   ,pr_dtmvtopr          --dtmvtolt
                                   ,nvl(pr_cdbccxlt,0)   --cdbccxlt
                                   ,nvl(pr_nrctaant,0)   --nrdconta
                                   ,nvl(pr_nrdconta,0)   --nrdctabb
                                   ,nvl(pr_nrdctitg,0)   --nrdctitg
                                   ,nvl(pr_nrdocmto,0)   --nrcheque
                                   ,nvl(pr_vllanmto,0)   --vllanmto
                                   ,nvl(pr_cdalinea,0)   --cdalinea
                                   ,nvl(pr_cdoperad,' ') --cdoperad
                                   ,46                   --cdhistor
                                   ,'TCO'                --cdpesqui
                                   ,0                    --insitdev
                                   ,rw_crapcop.cdbcoctl  --cdbanchq
                                   ,nvl(pr_cdagechq,0)   --cdagechq
                                   ,nvl(pr_nrctachq,0)   --nrctachq
                                   ,1                    --indevarq
                                   ,nvl(vr_indctitg,0)   --indctitg
                                   ,pr_cdbandep          -- cdbandep
                                   ,pr_nrctadep          -- cdctadep
                                   ,pr_cdagedep);        -- cdagedep
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_des_erro:= 'Erro ao inserir na tabela crapdev. Rotina pc_crps533.pc_cria_dev: '||sqlerrm;
                     RAISE vr_exc_erro;
                 END;
               END IF;

               /* Inserir devolução de cheque histórico do parâmetro */
               BEGIN
                 INSERT INTO crapdev (cdcooper
                                     ,dtmvtolt
                                     ,cdbccxlt
                                     ,nrdconta
                                     ,nrdctabb
                                     ,nrdctitg
                                     ,nrcheque
                                     ,vllanmto
                                     ,cdalinea
                                     ,cdoperad
                                     ,cdhistor
                                     ,cdpesqui
                                     ,insitdev
                                     ,cdbanchq
                                     ,cdagechq
                                     ,nrctachq
                                     ,indevarq
                                     ,indctitg
                                     ,cdbandep
                                     ,nrctadep
                                     ,cdagedep)
                             VALUES  (pr_cdcooper               --cdcooper
                                     ,pr_dtmvtopr               --dtmvtolt
                                     ,nvl(pr_cdbccxlt,0)        --cdbccxlt
                                     ,nvl(pr_nrctaant,0)        --nrdconta
                                     ,nvl(pr_nrdconta,0)        --nrdctabb
                                     ,nvl(pr_nrdctitg,0)        --nrdctitg
                                     ,nvl(pr_nrdocmto,0)        --nrcheque
                                     ,nvl(pr_vllanmto,0)        --vllanmto
                                     ,nvl(pr_cdalinea,0)        --cdalinea
                                     ,nvl(pr_cdoperad,' ')      --cdoperad
                                     ,nvl(pr_cdhistor,0)        --cdhistor
                                     ,'TCO'                     --cdpesqui
                                     ,2                         --insitdev 
                                     ,nvl(rw_crapcop.cdbcoctl,0)--cdbanchq
                                     ,nvl(pr_cdagechq,0)        --cdagechq
                                     ,nvl(pr_nrctachq,0)        --nrctachq
                                     ,1                         --indevarq
                                     ,nvl(vr_indctitg,0)        --indctitg
                                     ,pr_cdbandep               --cdbandep
                                     ,pr_nrctadep               --nrctadep
                                     ,pr_cdagedep);             --cdagedep    
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_des_erro:= 'Erro ao inserir na tabela crapdev - TCO. Rotina pc_crps533.pc_cria_dev: '||sqlerrm;
                   RAISE vr_exc_erro;
               END;
            END IF; --cr_crapdev%FOUND
            --Fechar o cursor
            CLOSE cr_crapdev_dev;
          END IF;   --Cheque Normal
        EXCEPTION
          WHEN vr_exc_erro THEN
            pr_cdcritic := 415;
            pr_dscritic := vr_des_erro;
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao inserir a devolução na pc_cria_dev. Detalhes: '||sqlerrm;
        END pc_cria_dev;

       /* Procedure que gera a devolução alinea37 */
       PROCEDURE pc_gera_dev_alinea (pr_cdcooper IN crapdev.cdcooper%TYPE
                                      ,pr_cdbcoctl IN crapcop.cdbcoctl%TYPE
                                      ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE
                                      ,pr_cdbccxlt IN crapdev.cdbccxlt%TYPE
                                      ,pr_nrdconta IN crapdev.nrdconta%TYPE
                                      ,pr_nrdocmto IN crapdev.nrcheque%TYPE
                                      ,pr_nrdctitg IN crapdev.nrdctitg%TYPE
                                      ,pr_vllanmto IN crapdev.vllanmto%TYPE
                                      ,pr_cdalinea IN crapdev.cdalinea%TYPE
                                      ,pr_cdhistor IN crapdev.cdhistor%TYPE
                                      ,pr_cdpesqbb IN crapdev.cdpesqui%TYPE
                                      ,pr_cdoperad IN crapdev.cdoperad%TYPE
                                      ,pr_cdagechq IN crapfdc.cdagechq%TYPE
                                      ,pr_nrctachq IN crapfdc.nrctachq%TYPE
                                      ,pr_cdbandep IN crapfdc.cdbandep%TYPE
                                      ,pr_cdagedep IN crapfdc.cdagedep%TYPE 
                                      ,pr_nrctadep IN crapfdc.nrctadep%TYPE                                  
                                      ,pr_cdcritic OUT NUMBER
                                      ,pr_dscritic OUT VARCHAR2) IS

          /* Selecionar devoluções de cheque ou taxas de devolução */
          CURSOR cr_crapdev_alinea (pr_cdcooper IN crapdev.cdcooper%TYPE
                                   ,pr_cdbanchq IN crapdev.cdbanchq%TYPE
                                   ,pr_cdagechq IN crapdev.cdagechq%TYPE
                                   ,pr_nrctachq IN crapdev.nrctachq%TYPE
                                   ,pr_cdhistor IN crapdev.cdhistor%TYPE
                                   ,pr_vllanmto IN crapdev.vllanmto%TYPE
                                   ,pr_cdbandep IN crapdev.cdbandep%TYPE
                                   ,pr_cdagedep IN crapdev.cdagedep%TYPE
                                   ,pr_nrctadep IN crapdev.nrctadep%TYPE) IS
           SELECT crapdev.cdcooper
             FROM crapdev crapdev
            WHERE crapdev.cdcooper = pr_cdcooper
            AND   crapdev.cdbanchq = pr_cdbanchq
            AND   crapdev.cdagechq = pr_cdagechq
            AND   crapdev.nrctachq = pr_nrctachq
            AND   crapdev.nrcheque = pr_nrdocmto
            AND   crapdev.cdhistor = pr_cdhistor
            AND   nvl(crapdev.cdbandep,0) = nvl(pr_cdbandep,0)
            AND   nvl(crapdev.cdagedep,0) = nvl(pr_cdagedep,0)
            AND   nvl(crapdev.nrctadep,0) = nvl(pr_nrctadep,0)
            AND   crapdev.vllanmto = pr_vllanmto;
          rw_crapdev_alinea  cr_crapdev_alinea%ROWTYPE;

          /* Variaveis locais da procedure */
          vr_indctitg   crapdev.indctitg%TYPE;
          vr_des_erro   VARCHAR2(4000);
          vr_exc_415    EXCEPTION;
          vr_exc_erro   EXCEPTION;

        BEGIN

          /* Selecionar devoluções de cheque */
          OPEN cr_crapdev_alinea (pr_cdcooper => pr_cdcooper
                                 ,pr_cdbanchq => pr_cdbcoctl
                                 ,pr_cdagechq => pr_cdagechq
                                 ,pr_nrctachq => pr_nrctachq
                                 ,pr_cdhistor => pr_cdhistor
                                 ,pr_vllanmto => pr_vllanmto
                                 ,pr_cdbandep => pr_cdbandep
                                 ,pr_cdagedep => pr_cdagedep
                                 ,pr_nrctadep => pr_nrctadep);
          --Posicionar no proximo registro
          FETCH cr_crapdev_alinea INTO rw_crapdev_alinea;

          /* Se encontrou devolução entao retorna erro*/
          IF cr_crapdev_alinea%FOUND THEN
            -- Fechar o cursor pois efetuaremos raise
            CLOSE cr_crapdev_alinea;
            -- Montar mensagem de critica
            RAISE vr_exc_415;
          ELSE
            /* Se o indicador de conta integracao está preenchido atribui TRUE */
            IF trim(pr_nrdctitg) IS NULL THEN
              vr_indctitg:= 0; --false
            ELSE
              vr_indctitg:= 1; --true
            END IF;

            /* Inserir devolução de cheque */
            BEGIN
              INSERT INTO crapdev (cdcooper
                                  ,dtmvtolt
                                  ,cdbccxlt
                                  ,nrdconta
                                  ,nrdctabb
                                  ,nrdctitg
                                  ,nrcheque
                                  ,vllanmto
                                  ,cdalinea
                                  ,cdoperad
                                  ,cdhistor
                                  ,cdpesqui
                                  ,insitdev
                                  ,cdbanchq
                                  ,cdagechq
                                  ,nrctachq
                                  ,indevarq
                                  ,indctitg
                                  ,cdbandep
                                  ,nrctadep
                                  ,cdagedep)
                          VALUES  (pr_cdcooper                -- cdcooper
                                  ,pr_dtmvtopr                -- dtmvtolt
                                  ,nvl(pr_cdbccxlt,0)         -- cdbccxlt
                                  ,nvl(pr_nrdconta,0)         -- nrdconta
                                  ,nvl(pr_nrctachq,0)         -- nrdctabb
                                  ,nvl(pr_nrdctitg,' ')       -- nrdctitg
                                  ,nvl(pr_nrdocmto,0)         -- nrcheque
                                  ,nvl(pr_vllanmto,0)         -- vllanmto
                                  ,nvl(pr_cdalinea,0)         -- cdalinea
                                  ,nvl(pr_cdoperad,' ')       -- cdoperad
                                  ,nvl(pr_cdhistor,0)         -- cdhistor
                                  ,nvl(pr_cdpesqbb,' ')       -- cdpesqui
                                  ,0                          -- insitdev
                                  ,pr_cdbcoctl                -- cdbanchq
                                  ,nvl(pr_cdagechq,0)         -- cdagechq
                                  ,nvl(pr_nrctachq,0)         -- nrctachq
                                  ,1                          -- indevarq
                                  ,nvl(vr_indctitg,0)         -- indctitg
                                  ,pr_cdbandep                -- cdbandep
                                  ,pr_nrctadep                -- nrctadep
                                  ,pr_cdagedep);              -- cdagedep
            EXCEPTION
              WHEN OTHERS THEN
                vr_des_erro:= 'Erro ao inserir na tabela crapdev. Rotina pc_crps533.pc_gera_dev_alinea. '||SQLERRM;
                RAISE vr_exc_erro;
            END;
          END IF;
          --Fechar o cursor
          CLOSE cr_crapdev_alinea;
        EXCEPTION
          WHEN vr_exc_415 THEN
            pr_cdcritic:= 415;
            pr_dscritic:= NULL;
          WHEN vr_exc_erro THEN
            pr_cdcritic:= 0;
            pr_dscritic:= vr_des_erro;
          WHEN OTHERS THEN
            pr_dscritic:= 'Erro ao inserir a devolução na pc_gera_dev_alinea. Detalhes: '||sqlerrm;
        END pc_gera_dev_alinea;

        /* Rotina de Integração da Cecred */
        PROCEDURE pc_integra_cecred(pr_cdcooper      IN crapcop.cdcooper%TYPE
                                          ,pr_nmrescop        IN crapcop.nmrescop%TYPE
                                   ,pr_caminho       IN VARCHAR2
                                          ,pr_cdbcoctl        IN crapcop.cdbcoctl%TYPE
                                          ,pr_cdagectl        IN crapcop.cdagectl%TYPE
                                          ,pr_cdbccxlt        IN crapdev.cdbccxlt%TYPE
                                          ,pr_cdcooper_incorp IN crapcop.cdcooper%TYPE
                                          ,pr_cdbcoctl_incorp IN crapcop.cdbcoctl%TYPE
                                          ,pr_cdagectl_incorp IN crapcop.cdagectl%TYPE
                                   ,pr_dtmvtolt      IN DATE
                                          ,pr_dtmvtopr        IN DATE
                                          ,pr_dtleiarq        IN DATE
                                          ,pr_dtauxili        IN VARCHAR2
                                          ,pr_vlchqvlb        IN NUMBER
                                          ,pr_cdagenci        IN NUMBER
                                          ,pr_tplotmov        IN NUMBER
                                          ,pr_cdprogra        IN VARCHAR2
                                   ,pr_dscritic      OUT VARCHAR2) IS
            /* Variaveis Locais */
            vr_input_file utl_file.file_type;
            vr_flgrejei   BOOLEAN;
            vr_linhanum   NUMBER;
            vr_vldebito   NUMBER;
            vr_qtcompln   NUMBER;
            vr_vlcompdb   NUMBER;
            vr_cdcritic   NUMBER;
            vr_cdbanchq   NUMBER:= 0;
            vr_cdagechq   NUMBER:= 0;
            vr_cdcmpchq   NUMBER:= 0;
            vr_nrctachq   NUMBER:= 0;
            vr_cdtpddoc   NUMBER:= 0;
            vr_vllanmto   NUMBER:= 0;
            vr_index_tab  VARCHAR2(40);

            vr_conta_linha  NUMBER:= 0;

            vr_index      VARCHAR2(100);
            vr_comando    VARCHAR2(100);
            vr_nmarqimp   VARCHAR2(100);
            vr_dscritic   VARCHAR2(4000);
            vr_des_erro   VARCHAR2(4000);
            vr_compl_erro VARCHAR2(4000);
            vr_setlinha   VARCHAR2(4000);
            vr_typ_saida  VARCHAR2(4000);
            vr_exc_erro   EXCEPTION;

            -- Variavel para armazenar as informacos em XML
            vr_xml_rel CLOB;
            vr_chr_rel VARCHAR2(32767);

            vr_dados_log    VARCHAR2(200);  

          BEGIN

            --Processa cada arquivo lido
            FOR idx IN 1..vr_vet_nmarquiv.COUNT LOOP

              --Atribuir valor inicial para variaveis
              vr_flgrejei:= FALSE;
              vr_vldebito:= 0;
              vr_qtcompln:= 0;
              vr_vlcompdb:= 0;
              vr_cdcritic:= 0;
              vr_index_tab:= NULL;
              vr_setlinha := NULL;

              -- Comando para listar a ultima linha do arquivo
              vr_comando:= 'tail -2 ' || pr_caminho|| '/' || vr_vet_nmarquiv(idx);

              --Executar o comando no unix
              GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                   ,pr_des_comando => vr_comando
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_setlinha);
              --Se ocorreu erro dar RAISE
              IF vr_typ_saida = 'ERR' THEN
                vr_des_erro:= 'Não foi possível executar comando unix. '||vr_comando;
                RAISE vr_exc_erro;
              END IF;

              --Se o final do arquivo estiver errado (validar as duas posições possíveis)
              IF SUBSTR(vr_setlinha,01,10) <> '9999999999' AND
                 SUBSTR(vr_setlinha,162,10) <> '9999999999' THEN
                vr_cdcritic:= 258;
                vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                vr_compl_erro:= ' - Arquivo: '|| vr_vet_nmarquiv(idx);
                -- gera log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper   => pr_cdcooper
                        ,pr_ind_tipo_log => 2 -- Erro tratato
                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                      || vr_cdprogra || ' --> '
                                      || vr_des_erro
                                      || vr_compl_erro);
                -- Limpa variaveis de erro
                vr_cdcritic:= 0;
                vr_des_erro := NULL;
                vr_compl_erro:= NULL;

              ELSE
                --Criar copia do arquivo
                -- Comando para copiar o arquivo
                vr_comando:= 'cp ' || pr_caminho|| '/' || vr_vet_nmarquiv(idx)||' '||pr_caminho|| '/' || vr_vet_nmarquiv(idx)||'.q';

                --Executar o comando no unix
                GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                     ,pr_des_comando => vr_comando
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => vr_setlinha);
                --Se ocorreu erro dar RAISE
                IF vr_typ_saida = 'ERR' THEN
                  vr_des_erro:= 'Não foi possível executar comando unix. '||vr_comando;
                  RAISE vr_exc_erro;
                END IF;

              END IF;

              --Validar informacoes da primeira linha do arquivo .q
              vr_nmarquiv:= vr_vet_nmarquiv(idx)||'.q';
              --Abrir o arquivo lido e percorrer as linhas do mesmo
              gene0001.pc_abre_arquivo(pr_nmdireto => pr_caminho     --> Diretório do arquivo
                                      ,pr_nmarquiv => vr_nmarquiv    --> Nome do arquivo
                                      ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                      ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                      ,pr_des_erro => vr_des_erro);  --> Erro
              IF vr_des_erro IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_saida;
              END IF;
              IF  utl_file.IS_OPEN(vr_input_file) THEN
                -- Le os dados do arquivo e coloca na variavel vr_setlinha
                gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                            ,pr_des_text => vr_setlinha); --> Texto lido
                -- Fechar o arquivo
                gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
              END IF;

              --Verificar se as informacoes estao corretas no arquivo
              IF SUBSTR(vr_setlinha,01,10) <> '0000000000' THEN
                vr_cdcritic:= 468;
              ELSIF SUBSTR(vr_setlinha,48,06) <> 'CEL615' THEN
                vr_cdcritic:= 181;
              END IF;

              --Se vr_cdcritic <> 0
              IF vr_cdcritic <> 0 THEN
                vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                vr_compl_erro:= ' - Arquivo: '|| vr_vet_nmarquiv(idx);
                -- gera log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper   => pr_cdcooper
                        ,pr_ind_tipo_log => 2 -- Erro tratato
                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                      || vr_cdprogra || ' --> '
                                      || vr_des_erro
                                      || vr_compl_erro);
                -- Limpa variaveis de erro
                vr_cdcritic:= 0;
                vr_des_erro := NULL;
                vr_compl_erro:= NULL;

                --Apagar arquivo no unix
                vr_comando:= 'rm ' || pr_caminho|| '/' || vr_nmarquiv||'.q';
                --Executar o comando no unix
                GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                     ,pr_des_comando => vr_comando
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => vr_setlinha);
                --Se ocorreu erro dar RAISE
                IF vr_typ_saida = 'ERR' THEN
                  vr_des_erro:= 'Não foi possível executar comando unix. '||vr_setlinha;
                  RAISE vr_exc_erro;
                END IF;

                -- Volta para o inicio do comando FOR
                continue;
              END IF;

              --Jogar mensagem de erro 219 no log
              vr_cdcritic:= 219;
              vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 1 -- Processo normal
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || vr_des_erro || ' ' ||pr_caminho|| '/'|| vr_vet_nmarquiv(idx));

              --Zerar variaveis de erro
              vr_cdcritic:= 0;
              vr_dscritic:= NULL;

              --Determinar o nome do arquivo para processamento
              vr_nmarquiv:= vr_vet_nmarquiv(idx)||'.q';
              --Abrir o arquivo lido e percorrer as linhas do mesmo
              gene0001.pc_abre_arquivo(pr_nmdireto => pr_caminho     --> Diretório do arquivo
                                      ,pr_nmarquiv => vr_nmarquiv    --> Nome do arquivo
                                      ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                      ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                      ,pr_des_erro => vr_des_erro);  --> Erro
              IF vr_des_erro IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_saida;
              END IF;
              --Inicializa variavel de controle de linhas com zero
              vr_conta_linha:= 0;
              LOOP
                --Verifica se o arquivo está aberto
                IF  utl_file.IS_OPEN(vr_input_file) THEN
                  --Incrementa o contador de linhas
                  vr_conta_linha:= vr_conta_linha+1;
                  -- Le os dados do arquivo e coloca na variavel vr_setlinha
                  gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                              ,pr_des_text => vr_setlinha); --> Texto lido
                  --Se for a primeira linha ignora
                  IF vr_conta_linha = 1 THEN
                    -- Le os dados do arquivo e coloca na variavel vr_setlinha
                    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                ,pr_des_text => vr_setlinha); --> Texto lido
                  END IF;
                  -- Sair quando não existir mais linhas
                  EXIT WHEN SUBSTR(vr_setlinha,1,10) = '9999999999';

                  vr_cdbanchq:= TO_NUMBER(SUBSTR(vr_setlinha,04,03));
                  vr_cdagechq:= TO_NUMBER(SUBSTR(vr_setlinha,07,04));
                  vr_cdcmpchq:= TO_NUMBER(SUBSTR(vr_setlinha,01,03));
                  vr_nrctachq:= TO_NUMBER(SUBSTR(vr_setlinha,15,09));
                  vr_cdtpddoc:= TO_NUMBER(SUBSTR(vr_setlinha,148,03));
                  vr_vllanmto:= TO_NUMBER(SUBSTR(vr_setlinha,34,17)) / 100;

                  vr_dados_log := ' Coop= '   ||pr_cdcooper||
                                  ' Banco= '  ||vr_cdbanchq||
                                  ' Agência= '||vr_cdagechq||
                                  ' Conta= '  ||vr_nrctachq||
                                  ' Cheque= ' ||TO_NUMBER(SUBSTR(vr_setlinha,25,06))||' ';

                  IF NOT vr_tab_crapage.EXISTS(vr_cdagechq) THEN
                     -- agencia não cadastrada--------------------------------------------------
                      BEGIN
                        INSERT INTO craprej (cdcooper
                                            ,dtrefere
                                            ,nrdconta
                                            ,nrdocmto
                                            ,vllanmto
                                            ,nrseqdig
                                            ,cdcritic
                                            ,cdpesqbb
                                            ,nrdctitg) -- Conta depositada
                                   VALUES   (pr_cdcooper
                                            ,pr_dtauxili
                                            ,TO_NUMBER(SUBSTR(vr_setlinha,25,06))--nvl(nvl(vr_nrdconta_incorp,vr_nrdconta),0)
                                            ,TO_NUMBER(SUBSTR(vr_setlinha,25,06))--nvl(vr_nrdocmto,0)
                                            ,nvl(vr_vllanmto,0)
                                            ,TO_NUMBER(SUBSTR(vr_setlinha,151,10))--nvl(vr_nrseqarq,0)
                                            ,134
                                            ,vr_setlinha--nvl(vr_cdpesqbb,' ')
                                            ,0--nvl(vr_nrctadep,0)
                                            );

                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_cdcritic:= 843;
                          vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          vr_compl_erro:= ' Seq: '||To_Char(gene0002.fn_mask(TO_NUMBER(SUBSTR(vr_setlinha,151,10)),'zzzz.zz9'));
                          -- Envio centralizado de log de erro
                          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                        || vr_cdprogra || ' --> '
                                                                        || vr_des_erro || vr_compl_erro
                                                                        || vr_dados_log);
                          --Levantar Excecao
                          RAISE vr_exc_erro;
                      END;

                      --Executar rotina pc_cria_generica
                      pc_cria_generica(pr_cdcooper   => pr_cdcooper
                                      ,pr_cdagenci   => 0
                                      ,pr_dtmvtolt   => pr_dtmvtolt
                                      ,pr_cdcritic   => vr_cdcritic
                                      ,pr_dtleiarq   => pr_dtleiarq
                                      ,pr_cdagectl   => pr_cdagectl
                                      ,pr_nmarquiv   => vr_vet_nmarquiv(idx)
                                      ,pr_cdbanchq   => vr_cdbanchq
                                      ,pr_cdagechq   => vr_cdagechq
                                      ,pr_nrctachq   => vr_nrctachq
                                      ,pr_nrdocmto   => TO_NUMBER(SUBSTR(vr_setlinha,25,06))
                                      ,pr_cdcmpchq   => vr_cdcmpchq
                                      ,pr_vllanmto   => vr_vllanmto
                                      ,pr_nrdconta   => TO_NUMBER(SUBSTR(vr_setlinha,25,06))--vr_nrdconta
                                      ,pr_nrseqarq   => TO_NUMBER(SUBSTR(vr_setlinha,151,10))--vr_nrseqarq
                                      ,pr_cdpesqbb   => vr_setlinha--vr_cdpesqbb
                                      ,pr_setlinha   => vr_setlinha--vr_compensacao(vr_indice).cdpesqbb
                                      ,pr_dscritic   => vr_des_erro);

                      --Verificar se retornou erro
                      IF vr_des_erro IS NOT NULL THEN
                        RAISE vr_exc_erro;
                      END IF;

                                --Executar a rotina da alinea 37
                      pc_gera_dev_alinea (pr_cdcooper => pr_cdcooper
                                           ,pr_cdbcoctl => pr_cdbcoctl
                                           ,pr_dtmvtopr => (CASE pr_nmtelant
                                                              WHEN 'COMPEFORA' THEN
                                                                   pr_dtmvtolt
                                                              ELSE PR_dtmvtopr
                                                            END)
                                           ,pr_cdbccxlt => pr_cdbccxlt
                                           ,pr_nrdconta => 0
                                           ,pr_nrdocmto => TO_NUMBER(SUBSTR(vr_setlinha,25,06))--vr_nrdocmto
                                           ,pr_nrdctitg => ' '
                                           ,pr_vllanmto => vr_vllanmto
                                           ,pr_cdalinea => 37
                                           ,pr_cdhistor => 47
                                           ,pr_cdpesqbb => SubStr(vr_setlinha,1,200)
                                           ,pr_cdoperad => '1'
                                           ,pr_cdagechq => vr_cdagechq--> Agencia do cheque
                                           ,pr_nrctachq => TO_NUMBER(SUBSTR(vr_setlinha,25,06))--vr_nrdctabb --> Conta do cheque
                                           ,pr_cdbandep => TO_NUMBER(SUBSTR(vr_setlinha,56,03))--vr_cdbandep
                                           ,pr_cdagedep => TO_NUMBER(SUBSTR(vr_setlinha,63,04))--vr_cdagedep
                                           ,pr_nrctadep => TO_NUMBER(SUBSTR(vr_setlinha,67,12))--vr_nrctadep
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_des_erro);


                      --Verificar se ocorreu erro
                      IF vr_des_erro IS NOT NULL THEN
                        RAISE vr_exc_erro;
                      END IF;

                      --Verificar se retornou erro
                      IF vr_cdcritic = 415 THEN
                        --Inserir na tabela de rejeição
                        BEGIN
                          INSERT INTO craprej (cdcooper
                                              ,dtrefere
                                              ,nrdconta
                                              ,nrdocmto
                                              ,vllanmto
                                              ,nrseqdig
                                              ,cdcritic
                                              ,cdpesqbb
                                              ,nrdctitg) -- Conta depositada
                                     VALUES   (pr_cdcooper
                                              ,pr_dtauxili
                                              ,TO_NUMBER(SUBSTR(vr_setlinha,25,06))--nvl(nvl(vr_nrdconta_incorp,vr_nrdconta),0)
                                              ,TO_NUMBER(SUBSTR(vr_setlinha,25,06))--nvl(vr_nrdocmto,0)
                                              ,nvl(vr_vllanmto,0)
                                              ,TO_NUMBER(SUBSTR(vr_setlinha,151,10))--nvl(vr_nrseqarq,0)
                                              ,nvl(vr_cdcritic,0)
                                              ,vr_setlinha--nvl(vr_cdpesqbb,' ')
                                              ,TO_NUMBER(SUBSTR(vr_setlinha,67,12))--nvl(vr_nrctadep,0)
                                              );
                        EXCEPTION
                          WHEN OTHERS THEN
                            vr_cdcritic:= 843;
                            vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                            vr_compl_erro:= ' Seq: '||To_Char(gene0002.fn_mask(SUBSTR(vr_setlinha,151,10),'zzzz.zz9'));
                            -- Envio centralizado de log de erro
                            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                          || vr_cdprogra || ' --> '
                                                                          || vr_des_erro || vr_compl_erro
                                                                          || vr_dados_log);
                            RAISE vr_exc_erro;
                        END;

                        --Atribuir zero para variavel de erro
                        vr_cdcritic:= 0;
                      END IF;  --vr_cdcritic = 415

                      --Ir para a proxima linha do arquivo
                      
                      INSERT INTO tbcompe_suaremessa (cdcooper, tparquiv, 
                                                      dtarquiv, qtrecebd, 
                                                      vlrecebd, qtintegr, 
                                                      vlintegr, qtrejeit, 
                                                      vlrejeit, nmarqrec)
                            VALUES (pr_cdcooper, 3, -- DEVOLU
                                    pr_dtmvtolt, 1,
                                    vr_vllanmto, 0,
                                    0, 1,
                                    vr_vllanmto, replace(vr_nmarquiv,'.q'));
                    END IF; --cr_crapass%NOTFOUND
                   ---------------------------------------------------------------------------
                  --O indice do vetor é varchar para permitir a ordenação dos dados
                  vr_index_tab:= LPad(vr_cdbanchq,3,'0')||
                                 LPad(vr_cdagechq,4,'0')||
                                 LPad(vr_cdcmpchq,3,'0')||
                                 LPad(vr_nrctachq,9,'0')||
                                 LPad(vr_cdtpddoc,3,'0')||
                                 LPad(Trunc(vr_vllanmto),13,'0')||
                                 LPad(vr_conta_linha,5,'0');

                  --Popular vetor com as informacoes encontradas
                  vr_tab_relat_cecred(vr_index_tab).cdbanchq:= vr_cdbanchq;
                  vr_tab_relat_cecred(vr_index_tab).cdagechq:= vr_cdagechq;
                  vr_tab_relat_cecred(vr_index_tab).cdcmpchq:= vr_cdcmpchq;
                  vr_tab_relat_cecred(vr_index_tab).nrctachq:= vr_nrctachq;
                  vr_tab_relat_cecred(vr_index_tab).cdtpddoc:= vr_cdtpddoc;
                  vr_tab_relat_cecred(vr_index_tab).vllanmto:= vr_vllanmto;

                END IF;
              END LOOP;
              -- Fechar o arquivo
              gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;

              -- Buscar o diretório padrao da cooperativa conectada
              vr_dircop_salvar:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                      ,pr_cdcooper => pr_cdcooper
                                                      ,pr_nmsubdir => 'salvar');

              --Remover arquivo .q no unix
              vr_comando:= 'rm ' || pr_caminho|| '/' || vr_nmarquiv||'.q 2> /dev/null';
              --Executar o comando no unix
              GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                   ,pr_des_comando => vr_comando
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_setlinha);
              --Se ocorreu erro dar RAISE
              IF vr_typ_saida = 'ERR' THEN
                vr_des_erro:= 'Não foi possível executar comando unix. '||vr_setlinha;
                RAISE vr_exc_erro;
              END IF;

            END LOOP; --processa cada arquivo lido

            -- Zerar controles
            vr_cdcritic:= 0;
            vr_linhanum:= 1;

            --Setar o nome do arquivo de impressao
            vr_nmarqimp:= 'crrl564_' || TO_CHAR((vr_vet_nmarquiv.COUNT+1),'FM009') || '.lst';

            --Atribuir valor para variavel
            vr_cdempres:= 11;

            -- Buscar o diretório log da cooperativa conectada
            vr_dircop_imp := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                  ,pr_cdcooper => pr_cdcooper
                                                  ,pr_nmsubdir => 'rl');

            -- Rotina de Impressão no Arquivo
            BEGIN
              -- Inicializar o CLOB
              dbms_lob.createtemporary(vr_xml_rel, true);
              dbms_lob.open(vr_xml_rel, dbms_lob.lob_readwrite);

              gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                     ,pr_texto_completo => vr_chr_rel
                                     ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><crrl564 dtmvtolt="'||To_Char(pr_dtmvtolt,'DD/MM/YYYY')||'" >');

              --Atualiza o contador de linhas
              vr_linhanum:= 14;

              --Posicionar na primeira posicao do vetor
              vr_index:= vr_tab_relat_cecred.FIRST;
              --Percorrer tabela memoria
              LOOP
                --Sair quando acabar o vetor
                EXIT WHEN vr_index IS NULL;

                gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                       ,pr_texto_completo => vr_chr_rel
                                       ,pr_texto_novo     => '<cheque>
                                                                <cdcmpchq>'||vr_tab_relat_cecred(vr_index).cdcmpchq  ||'</cdcmpchq>
                                                                <cdbanchq>'||gene0002.fn_mask(vr_tab_relat_cecred(vr_index).cdbanchq,'z.zz9')||'</cdbanchq>
                                                                <cdagechq>'||gene0002.fn_mask(vr_tab_relat_cecred(vr_index).cdagechq,'zzz9') ||'</cdagechq>
                                                                <cdtpddoc>'||gene0002.fn_mask(vr_tab_relat_cecred(vr_index).cdtpddoc,'zz9')  ||'</cdtpddoc>
                                                                <nrctachq>'||gene0002.fn_mask_conta(vr_tab_relat_cecred(vr_index).nrctachq)  ||'</nrctachq>
                                                                <vllanmto>'||vr_tab_relat_cecred(vr_index).vllanmto  ||'</vllanmto>
                                                              </cheque>');

                --Incrementa o contador de linhas
                vr_linhanum:= vr_linhanum+1;

                --Posicionar vetor no proximo registro
                vr_index := vr_tab_relat_cecred.NEXT(vr_index);
              END LOOP;

              gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                     ,pr_texto_completo => vr_chr_rel
                                     ,pr_texto_novo     => '</crrl564>'
                                     ,pr_fecha_xml      => TRUE);

              -- Salvar copia relatorio para pasta "/rlnsv"
              IF pr_nmtelant = 'COMPEFORA' THEN
                -- Buscar o diretório padrao da cooperativa conectada + /rlnsv
                vr_dircop_rlnsv:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                       ,pr_cdcooper => pr_cdcooper
                                                       ,pr_nmsubdir => 'rlnsv');
              ELSE
                -- Não há copia
                vr_dircop_rlnsv := null;
              END IF;

              -- Solicitar impressao de todas as agencias
              gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                         ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                         ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                         ,pr_dsxml     => vr_xml_rel          --> Arquivo XML de dados
                                         ,pr_dsxmlnode => '/crrl564/cheque'          --> No base do XML para leitura dos dados
                                         ,pr_dsjasper  => 'crrl564.jasper'    --> Arquivo de layout do iReport
                                         ,pr_dsparams  => null                --> Enviar como parametro apenas a agencia
                                         ,pr_dsarqsaid => vr_dircop_imp||'/'||vr_nmarqimp --> Arquivo final com codigo da agencia
                                         ,pr_qtcoluna  => 80                  --> 80 colunas
                                         ,pr_flg_impri => 'N'                 --> Chamar a impress?o (Imprim.p)
                                         ,pr_flg_gerar => 'N'                 --> gerar na hora
                                         ,pr_nmformul  => '80dh'              --> Nome do formulario para impress?o
                                         ,pr_dspathcop => vr_dircop_rlnsv     --> gerar copia no diretorio
                                         ,pr_sqcabrel  => 2
                                         ,pr_nrcopias  => 1                   --> Numero de copias
                                         ,pr_des_erro  => vr_dscritic);       --> Saida com erro

              dbms_lob.freetemporary(vr_xml_rel);
              IF vr_dscritic IS NOT NULL THEN
                -- Gerar excecao
                raise vr_exc_saida;
              END IF;

              -- Após geração dos relatórios:
              -- Processar cada arquivo lido
              FOR idx IN 1..vr_vet_nmarquiv.COUNT LOOP

                --Mover arquivo no unix para a pasta salvar
                vr_comando:= 'mv ' || pr_caminho|| '/' || vr_vet_nmarquiv(idx)||' '||vr_dircop_salvar||'/'|| vr_vet_nmarquiv(idx);
                --Executar o comando no unix
                GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                     ,pr_des_comando => vr_comando
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => vr_setlinha);
                --Se ocorreu erro dar RAISE
                IF vr_typ_saida = 'ERR' THEN
                  -- Gerar log e parar o processo
                  vr_des_erro:= 'Não foi possível executar comando unix. '||vr_comando;
                  RAISE vr_exc_erro;
                END IF;
              END LOOP; -- Fim varredura final dos arquivos

              --Imprimir informacoes no log
              vr_cdcritic:= 191;
              vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 1 -- Processo normal
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || vr_des_erro );
            EXCEPTION
              WHEN vr_exc_erro THEN
                -- Efetuar rollback
                ROLLBACK;
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                              || vr_cdprogra || ' --> '
                                                              || vr_des_erro );
              WHEN OTHERS THEN
                -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
                vr_des_erro := 'Problema ao escrever no arquivo <'||vr_dircop_imp||'/'||vr_nmarqimp||'>: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            --Limpar tabela de memoria
            vr_tab_relat_cecred.DELETE;

          EXCEPTION
            WHEN vr_exc_saida THEN
              -- Enviar a mensagem de erro ao DMBS_OUTPUT e ignorar o log
              gene0001.pc_print(to_char(sysdate,'hh24:mi:ss')||' - '|| 'pc_crps533.pc_integra_cecred --> '||vr_des_erro);
              pr_dscritic := 'Erro na rotina pc_crps533.pc_integra_cecred.vr_exc_saida --> '||vr_des_erro;
            WHEN vr_exc_erro THEN
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || vr_des_erro || vr_compl_erro);
              pr_dscritic:= 'Erro na rotina pc_crps533.pc_integra_cecred.vr_exc_erro --> '||vr_des_erro||vr_compl_erro;
          END pc_integra_cecred;


          /* Rotina de Integração de Todas as cooperativas */
          PROCEDURE pc_integra_todas_coop (pr_cdcooper        IN crapcop.cdcooper%TYPE
                                          ,pr_nmrescop        IN crapcop.nmrescop%TYPE
                                          ,pr_caminho         IN VARCHAR2
                                          ,pr_cdbcoctl        IN crapcop.cdbcoctl%TYPE
                                          ,pr_cdagectl        IN crapcop.cdagectl%TYPE
                                          ,pr_cdbccxlt        IN crapdev.cdbccxlt%TYPE
                                          ,pr_cdcooper_incorp IN crapcop.cdcooper%TYPE
                                          ,pr_cdbcoctl_incorp IN crapcop.cdbcoctl%TYPE
                                          ,pr_cdagectl_incorp IN crapcop.cdagectl%TYPE
                                          ,pr_dtmvtolt        IN DATE
                                          ,pr_dtmvtopr        IN DATE
                                          ,pr_dtleiarq        IN DATE
                                          ,pr_dtauxili        IN VARCHAR2
                                          ,pr_vlchqvlb        IN NUMBER
                                          ,pr_cdagenci        IN NUMBER
                                          ,pr_tplotmov        IN NUMBER
                                          ,pr_cdprogra        IN VARCHAR2
                                          ,pr_dscritic       OUT VARCHAR2) IS

            /* Cursores Locais */

            --Selecionar as tranferencias e duplicação de matriculas
            CURSOR cr_craptrf  (pr_cdcooper IN craptrf.cdcooper%TYPE
                               ,pr_nrdconta IN craptrf.nrdconta%TYPE
                               ,pr_tptransa IN craptrf.tptransa%TYPE) IS
              SELECT craptrf.nrsconta
                FROM craptrf craptrf
               WHERE craptrf.cdcooper = pr_cdcooper
                 AND craptrf.nrdconta = pr_nrdconta
                 AND craptrf.tptransa = pr_tptransa
                 AND ROWNUM = 1;
            rw_craptrf cr_craptrf%ROWTYPE;


            --Selecionar os lancamentos
            CURSOR cr_craplcm1 (pr_cdcooper IN craplcm.cdcooper%TYPE
                               ,pr_nrdconta IN craplcm.nrdconta%TYPE
                               ,pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
              SELECT /*+ INDEX (craplcm craplcm##craplcm2) */
                     craplcm.dtmvtolt
                FROM craplcm craplcm
               WHERE craplcm.cdcooper = pr_cdcooper
                 AND craplcm.nrdconta = pr_nrdconta
                 AND craplcm.nrdocmto = pr_nrdocmto
                 AND craplcm.dtmvtolt = craplcm.dtmvtolt
                 AND craplcm.cdhistor IN (21, 524, 572)
               ORDER BY craplcm.progress_recid DESC;
            rw_craplcm1 cr_craplcm1%ROWTYPE;

            --Selecionar os lancamentos
            CURSOR cr_craplcm2 (pr_cdcooper IN craplcm.cdcooper%TYPE
                               ,pr_nrdconta IN craplcm.nrdconta%TYPE
                               ,pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
              SELECT craplcm.dtmvtolt
                FROM craplcm craplcm
               WHERE craplcm.cdcooper = pr_cdcooper
                 AND craplcm.nrdconta = pr_nrdconta
                 AND craplcm.nrdocmto = pr_nrdocmto
                 AND craplcm.cdpesqbb = '21'
                 AND craplcm.cdhistor IN (47, 191, 338, 573)
               ORDER BY craplcm.progress_recid DESC;
            rw_craplcm2 cr_craplcm2%ROWTYPE;

            --Selecionar os lancamentos
            CURSOR cr_craplcm_ali28 (pr_cdcooper IN craplcm.cdcooper%TYPE
                               ,pr_nrdconta IN craplcm.nrdconta%TYPE
                               ,pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
              SELECT craplcm.dtmvtolt
                FROM craplcm craplcm
               WHERE craplcm.cdcooper = pr_cdcooper
                 AND craplcm.nrdconta = pr_nrdconta
                 AND craplcm.nrdocmto = pr_nrdocmto
                 AND craplcm.cdpesqbb = '28'
                 AND craplcm.cdhistor IN (47, 191, 338, 573)
               ORDER BY craplcm.progress_recid DESC;
            rw_cr_craplcm_ali28 cr_craplcm_ali28%ROWTYPE;            

			      --Selecionar os lancamentos
            CURSOR cr_craplcm_ali20 (pr_cdcooper IN craplcm.cdcooper%TYPE
                                    ,pr_nrdconta IN craplcm.nrdconta%TYPE
                                    ,pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
              SELECT craplcm.dtmvtolt
                FROM craplcm craplcm
               WHERE craplcm.cdcooper = pr_cdcooper
                 AND craplcm.nrdconta = pr_nrdconta
                 AND craplcm.nrdocmto = pr_nrdocmto
                 AND craplcm.cdpesqbb = '20'
                 AND craplcm.cdhistor IN (47, 191, 338, 573)
               ORDER BY craplcm.progress_recid DESC;
            rw_cr_craplcm_ali20 cr_craplcm_ali20%ROWTYPE;            

            --Selecionar os lançamentos
            CURSOR cr_craplcm3 (pr_cdcooper IN craplcm.cdcooper%TYPE
                               ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                               ,pr_cdagenci IN craplcm.cdagenci%TYPE
                               ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                               ,pr_nrdolote IN craplcm.nrdolote%TYPE
                               ,pr_nrdctabb IN craplcm.nrdctabb%TYPE
                               ,pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
              SELECT craplcm.rowid
                FROM craplcm craplcm
               WHERE craplcm.cdcooper = pr_cdcooper
                 AND craplcm.dtmvtolt = pr_dtmvtolt
                 AND craplcm.cdagenci = pr_cdagenci
                 AND craplcm.cdbccxlt = pr_cdbccxlt
                 AND craplcm.nrdolote = pr_nrdolote
                 AND craplcm.nrdctabb = pr_nrdctabb
                 AND craplcm.nrdocmto = pr_nrdocmto;
            rw_craplcm3 cr_craplcm3%ROWTYPE;


            --Selecionar informacoes das contra-ordens
            CURSOR cr_crapcor (pr_cdcooper IN crapcor.cdcooper%TYPE
                              ,pr_cdbanchq IN crapcor.cdbanchq%TYPE
                              ,pr_cdagechq IN crapcor.cdagechq%TYPE
                              ,pr_nrctachq IN crapcor.nrctachq%TYPE
                              ,pr_nrdctabb IN crapcor.nrdctabb%TYPE
                              ,pr_nrcheque IN crapcor.nrcheque%TYPE
                              ,pr_flgativo IN crapcor.flgativo%TYPE) IS
              SELECT crapcor.dtvalcor
                    ,crapcor.dtemscor
                    ,crapcor.cdhistor
              FROM crapcor crapcor
              WHERE crapcor.cdcooper = pr_cdcooper
              AND   crapcor.cdbanchq = pr_cdbanchq
              AND   crapcor.cdagechq = pr_cdagechq
              AND   (pr_nrctachq IS NULL OR pr_nrctachq = crapcor.nrctachq)
              AND   (pr_nrdctabb IS NULL OR pr_nrdctabb = crapcor.nrdctabb)
              AND   crapcor.nrcheque = pr_nrcheque
              AND   crapcor.flgativo = pr_flgativo;
            rw_crapcor cr_crapcor%ROWTYPE;

            --Selecionar as folhas de cheques emitidas
            CURSOR cr_crapfdc (pr_cdcooper crapfdc.cdcooper%TYPE
                              ,pr_cdbanchq crapfdc.cdbanchq%TYPE
                              ,pr_cdagechq crapfdc.cdagechq%TYPE
                              ,pr_nrctachq crapfdc.nrctachq%TYPE
                              ,pr_nrcheque crapfdc.nrcheque%TYPE) IS
              SELECT /*+ INDEX (crapfdc crapfdc##crapfdc1) */
                     crapfdc.nrcheque
                    ,crapfdc.nrdigchq
                    ,crapfdc.tpcheque
                    ,crapfdc.dtemschq
                    ,crapfdc.dtretchq
                    ,crapfdc.incheque
                    ,crapfdc.cdcmpchq
                    ,crapfdc.cdbanchq
                    ,crapfdc.cdagechq
                    ,crapfdc.nrctachq
                    ,crapfdc.cdbantic
                    ,crapfdc.cdagetic
                    ,crapfdc.rowid
                    ,crapfdc.cdcooper
              FROM crapfdc crapfdc
              WHERE crapfdc.cdcooper = pr_cdcooper
              AND   crapfdc.cdbanchq = pr_cdbanchq
              AND   crapfdc.cdagechq = pr_cdagechq
              AND   crapfdc.nrctachq = pr_nrctachq
              AND   crapfdc.nrcheque = pr_nrcheque;
            rw_crapfdc cr_crapfdc%ROWTYPE;

            --Selecionar o indicador do estado do cheque atualizado
            CURSOR cr_crapfdc_incheque(pr_crapfdc_rowid ROWID) IS
              SELECT crapfdc.incheque
                FROM crapfdc
               WHERE crapfdc.rowid = pr_crapfdc_rowid;
            rw_crapfdc_incheque cr_crapfdc_incheque%ROWTYPE;

            --Selecionar Custodia de Cheques
            CURSOR cr_crapcst   (pr_cdcooper IN crapfdc.cdcooper%TYPE
                                ,pr_cdcmpchq IN crapfdc.cdcmpchq%TYPE
                                ,pr_cdbanchq IN crapfdc.cdbanchq%TYPE
                                ,pr_cdagechq IN crapfdc.cdagechq%TYPE
                                ,pr_nrctachq IN crapfdc.nrctachq%TYPE
                                ,pr_nrcheque IN crapfdc.nrcheque%TYPE
                                ,pr_dtlibera IN crapcst.dtlibera%TYPE) IS
              SELECT crapcst.insitchq,
                     crapcst.dtlibera,
                     crapcst.nrdconta
                FROM crapcst crapcst
               WHERE crapcst.cdcooper = pr_cdcooper
                 AND crapcst.cdcmpchq = pr_cdcmpchq
                 AND crapcst.cdbanchq = pr_cdbanchq
                 AND crapcst.cdagechq = pr_cdagechq
                 AND crapcst.nrctachq = pr_nrctachq
                 AND crapcst.nrcheque = pr_nrcheque
                 AND crapcst.insitchq IN (0, 2)
                 AND crapcst.dtlibera > pr_dtlibera
                 AND crapcst.nrborder = 0;
            rw_crapcst cr_crapcst%ROWTYPE;

            --Selecionar Cheques Contidos do Bordero de desconto de cheques
            CURSOR cr_crapcdb   (pr_cdcooper IN crapfdc.cdcooper%TYPE
                                ,pr_cdcmpchq IN crapfdc.cdcmpchq%TYPE
                                ,pr_cdbanchq IN crapfdc.cdbanchq%TYPE
                                ,pr_cdagechq IN crapfdc.cdagechq%TYPE
                                ,pr_nrctachq IN crapfdc.nrctachq%TYPE
                                ,pr_nrcheque IN crapfdc.nrcheque%TYPE
                                ,pr_dtlibera IN crapcdb.dtlibera%TYPE) IS
              SELECT crapcdb.insitchq,
                     crapcdb.dtlibera,
                     crapcdb.nrdconta
                FROM crapcdb crapcdb
               WHERE crapcdb.cdcooper = pr_cdcooper
                 AND crapcdb.cdcmpchq = pr_cdcmpchq
                 AND crapcdb.cdbanchq = pr_cdbanchq
                 AND crapcdb.cdagechq = pr_cdagechq
                 AND crapcdb.nrctachq = pr_nrctachq
                 AND crapcdb.nrcheque = pr_nrcheque
                 AND crapcdb.insitchq IN (0, 2)
                 AND crapcdb.insitana NOT IN (0,2) /* Inclusao Paulo Martins - Mouts (SCTASK0018345)*/
                 AND crapcdb.dtlibera > pr_dtlibera;
            rw_crapcdb cr_crapcdb%ROWTYPE;

            --Selecionar Transferencias entre cooperativas
            CURSOR cr_craptco(pr_cdcopant IN craptco.cdcopant%TYPE
                             ,pr_nrctaant IN craptco.nrctaant%TYPE
                             ,pr_tpctatrf IN craptco.tpctatrf%TYPE DEFAULT NULL
                             ,pr_flgativo IN craptco.flgativo%TYPE DEFAULT NULL) IS
              SELECT tco.cdcopant
                    ,tco.nrctaant
                    ,tco.nrdconta
                    ,tco.cdcooper
                FROM craptco tco
               WHERE tco.cdcopant = pr_cdcopant
                 AND tco.nrctaant = pr_nrctaant
                 AND tco.tpctatrf = nvl(pr_tpctatrf,tco.tpctatrf)
                 AND tco.flgativo = nvl(pr_flgativo,tco.flgativo)
                 AND ROWNUM = 1;
            rw_craptco cr_craptco%ROWTYPE;

            --Selecionar informacoes dos lotes
            CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                              ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                              ,pr_cdagenci IN craplot.cdagenci%TYPE
                              ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                              ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
              SELECT craplot.dtmvtolt,
                     craplot.cdagenci,
                     craplot.cdbccxlt,
                     craplot.nrdolote,
                     craplot.rowid
                FROM craplot craplot
               WHERE craplot.cdcooper = pr_cdcooper
                 AND craplot.dtmvtolt = pr_dtmvtolt
                 AND craplot.cdagenci = pr_cdagenci
                 AND craplot.cdbccxlt = pr_cdbccxlt
                 AND craplot.nrdolote = pr_nrdolote;
            rw_craplot cr_craplot%ROWTYPE;

            --Selecionar informacoes dos lotes (contra-ordem)
            CURSOR cr_craplot2(pr_cdcooper IN craplot.cdcooper%TYPE
                              ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                              ,pr_cdagenci IN craplot.cdagenci%TYPE
                              ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                              ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
              SELECT craplot.dtmvtolt,
                     craplot.cdagenci,
                     craplot.cdbccxlt,
                     craplot.nrdolote,
                     craplot.rowid
                FROM craplot craplot
               WHERE craplot.cdcooper = pr_cdcooper
                 AND craplot.dtmvtolt = pr_dtmvtolt
                 AND craplot.cdagenci = pr_cdagenci
                 AND craplot.cdbccxlt = pr_cdbccxlt
                 AND craplot.nrdolote = pr_nrdolote;
            rw_craplot2 cr_craplot2%ROWTYPE;

            --Selecionar informacoes das rejeicoes
            CURSOR cr_craprej(pr_cdcooper IN craprej.cdcooper%TYPE
                             ,pr_dtrefere IN craprej.dtrefere%TYPE
                             ,pr_tpintegr IN craprej.tpintegr%TYPE DEFAULT NULL) IS
              SELECT rej.cdcooper
                    ,rej.dtrefere
                    ,rej.nrdconta
                    ,rej.nrdocmto
                    ,rej.cdcritic
                    ,rej.cdpesqbb
                    ,rej.nrseqdig
                    ,rej.vllanmto
                    ,rej.dshistor
                    ,rej.nrdctitg
                FROM craprej rej
               WHERE rej.cdcooper = pr_cdcooper
                 AND rej.dtrefere = pr_dtrefere
                 AND rej.tpintegr = nvl(pr_tpintegr,rej.tpintegr)
               ORDER BY rej.nrdconta,
                        rej.cdcritic,
                        rej.nrdocmto;

            CURSOR cr_crapdpb(pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_dtlibban IN crapdat.dtmvtolt%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
              SELECT dpb.vllanmto
                FROM crapdpb dpb, craplcm lcm
               WHERE dpb.cdcooper = pr_cdcooper
                 AND dpb.dtliblan = pr_dtlibban
                 AND dpb.nrdconta = pr_nrdconta
                 AND dpb.cdcooper = lcm.cdcooper
                 AND dpb.dtmvtolt = lcm.dtmvtolt
                 AND dpb.cdagenci = lcm.cdagenci
                 AND dpb.cdbccxlt = lcm.cdbccxlt
                 AND dpb.nrdolote = lcm.nrdolote
                 AND dpb.nrdconta = lcm.nrdconta
                 AND dpb.nrdocmto = lcm.nrdocmto
                 AND dpb.cdhistor = lcm.cdhistor
                 AND dpb.inlibera = 1;
            rw_crapdpb cr_crapdpb%ROWTYPE;

			CURSOR cr_crapass_pa(pr_cdcooper crapass.cdcooper%TYPE
                                ,pr_nrdconta crapass.nrdconta%TYPE) IS
             SELECT crapass.cdagenci
               FROM crapass crapass
              WHERE crapass.cdcooper = pr_cdcooper
                AND crapass.nrdconta = pr_nrdconta;
            rw_crapass_pa cr_crapass_pa%ROWTYPE;

       --Tabela de memoria de associados

      TYPE typ_compensacao IS record(
        linhaatual    NUMBER(10),
        nrdconta      craplcm.nrdconta%TYPE,
        nrdocmto      craplcm.nrdocmto%TYPE,
        vllanmto      craplcm.vllanmto%TYPE,
        nrseqarq      NUMBER(10),
        cdbanchq      craplcm.cdbanchq%TYPE,
        cdcmpchq      craplcm.cdcmpchq%TYPE,
        cdagechq      craplcm.cdagechq%TYPE,
        nrctachq      craplcm.nrctachq%TYPE,
        nrlotchq      craplcm.nrlotchq%TYPE,
        sqlotchq      craplcm.sqlotchq%TYPE,
        cdtpddoc      NUMBER(10),
        cdpesqbb      craplcm.cdpesqbb%TYPE,
        cdbandep      craplcm.cdbanchq%TYPE,
        cdcmpdep      craplcm.cdcmpchq%TYPE,
        cdagedep      craplcm.cdagechq%TYPE,
        nrctadep      craplcm.nrctachq%TYPE,
        cdageapr      craplcm.cdagechq%TYPE,
        dados_log     VARCHAR2(500));

      type tab_compensacao IS TABLE of typ_compensacao INDEX BY VARCHAR2(43);
 
      vr_compensacao tab_compensacao;
  
      vr_indice      varchar2(43);
      vr_cont_indice number(10);
   
      vr_result  varchar2(27);
      
            /* Variaveis Locais pc_integra_todas_coop */
            vr_input_file utl_file.file_type;
            vr_flgrejei   BOOLEAN;
            vr_flgfirst   BOOLEAN;
            vr_flgdigit   BOOLEAN;
            vr_flgsair    BOOLEAN;
            vr_flgccord   BOOLEAN;
            vr_flgachou   BOOLEAN;
            vr_flctamig   BOOLEAN;
            vr_pagnum     NUMBER:= 0;
            vr_linhanum   NUMBER:= 0;
            vr_vldebito   NUMBER:= 0;
            vr_cdcritic   NUMBER:= 0;
            vr_cdalinea   NUMBER:= 0;
            vr_indevchq   NUMBER:= 0;
            vr_nrseqarq   NUMBER:= 0;
            vr_cdbanchq   NUMBER:= 0;
            vr_cdagechq   NUMBER:= 0;
            vr_cdcmpchq   NUMBER:= 0;
            vr_nrctachq   NUMBER:= 0;
            vr_cdtpddoc   NUMBER:= 0;
            vr_vllanmto   NUMBER:= 0;
            vr_contareg   NUMBER:= 0;
            vr_nrdolote   NUMBER:= 0;
            vr_nrdconta   NUMBER:= 0;
            vr_nrdconta_incorp NUMBER:= NULL;
            vr_cdcooper_incorp NUMBER:= NULL;
            vr_cdbcoctl_incorp NUMBER:= NULL;
            vr_cdagectl_incorp NUMBER:= NULL;
            vr_nrdocmto   NUMBER:= 0;
            vr_nrlotchq   NUMBER:= 0;
            vr_sqlotchq   NUMBER:= 0;
            vr_nrdctabb   NUMBER:= 0;
            vr_nrdocsdg   NUMBER:= 0;
            vr_cdhistor   NUMBER:= 0;
            vr_nrdolot2   NUMBER:= 0;
            vr_qtcompln   NUMBER:= 0;
            vr_vlcompdb   NUMBER:= 0;

			vr_cdagenci_pa NUMBER:= 0;

            vr_nrdctitg   VARCHAR2(40);

            vr_cdbandep   NUMBER:= 0;
            vr_cdcmpdep   NUMBER:= 0;
            vr_cdagedep   NUMBER:= 0;
            vr_nrctadep   NUMBER:= 0;
            vr_cdageapr   NUMBER:= 0;
            vr_cdcoptfn   NUMBER:= 0;
            vr_cdcooper   NUMBER:= NULL;

            vr_comando    VARCHAR2(100);
            vr_nmarqimp   VARCHAR2(100);
            vr_dstextab   VARCHAR2(100);
            vr_dscritic   VARCHAR2(4000);
            vr_des_erro   VARCHAR2(4000);
            vr_compl_erro VARCHAR2(4000);
            vr_cdpesqbb   VARCHAR2(4000);
            vr_setlinha   VARCHAR2(4000);
            vr_typ_saida  VARCHAR2(4000);
            vr_conteudo   VARCHAR2(4000);
            vr_desdados   VARCHAR2(4000);
            vr_exc_pula   EXCEPTION;
            vr_exc_sair   EXCEPTION;
            vr_exc_erro   EXCEPTION;
            vr_exc_undo   EXCEPTION;
            vr_exc_proximo_arquivo EXCEPTION;

            vr_des_assunto   VARCHAR2(100);
            vr_rel_dspesqbb  VARCHAR2(100);
            vr_ant_nrdconta  NUMBER;
            vr_cdcritic_aux  NUMBER := 0;
            vr_nrdocmt2      NUMBER;

            vr_rel_cdtipdoc  NUMBER;
            vr_tot_qtregrec  NUMBER:= 0;
            vr_tot_qtregint  NUMBER:= 0;
            vr_tot_qtregrej  NUMBER:= 0;
            vr_tot_vlregrec  NUMBER:= 0;
            vr_tot_vlregint  NUMBER:= 0;
            vr_tot_vlregrej  NUMBER:= 0;
            vr_conta_linha   NUMBER:= 0;
            vr_conta_linha_tab NUMBER:= 0;

            vr_index_craprej VARCHAR2(300);

            vr_tpintegr      craprej.tpintegr%TYPE;

            vr_nrcalcul      NUMBER := 0; --variavel para calcular o digito
            vr_retdig        BOOLEAN;
            -- Variavel para armazenar as informacos em XML
            vr_xml_rel       CLOB;
            vr_clobcri       CLOB;
            vr_chr_rel       VARCHAR2(32767);
            --Vetor para armazenar os arquivos para processamento
            vr_vet_nmarquok GENE0002.typ_split := GENE0002.typ_split();

            vr_dircop_email VARCHAR2(200);
            vr_dados_log    VARCHAR2(200);  
            vr_dsvlrprm     crapprm.dsvlrprm%type;      

          BEGIN

            -- Processa cada arquivo lido
            FOR idx IN 1..vr_vet_nmarquiv.COUNT() LOOP

              -- Se a cooperativa atual possuir incorporação
              -- E o arquivo é um arquivo de cooperativa incorporada
              IF pr_cdcooper_incorp IS NOT NULL AND vr_vet_nmarquiv(idx) LIKE '1'|| TO_CHAR(pr_cdagectl_incorp,'FM0009') || '%.RET' THEN
                -- Guardar as variaveis de incorporação enviadas
                vr_cdcooper_incorp := pr_cdcooper_incorp;
                vr_cdbcoctl_incorp := pr_cdbcoctl_incorp;
                vr_cdagectl_incorp := pr_cdagectl_incorp;
              ELSE
                -- Não há incorporação, deixaremos as informações
                -- como nulla e os NVLS sobs os campos sempre
                -- retornaram os campos atuais do arquivo e cooperativa
                vr_cdcooper_incorp := NULL;
                vr_cdbcoctl_incorp := NULL;
                vr_cdagectl_incorp := NULL;
              END IF;

              --Bloco criado para controlar os pulos de arquivos
              BEGIN

                --Atribuir valor inicial para variaveis
                vr_flgrejei:= FALSE;
                vr_vldebito:= 0;
                vr_qtcompln:= 0;
                vr_vlcompdb:= 0;
                vr_cdcritic:= 0;
                vr_setlinha:= NULL;

                --Eliminar linhas da tabela de memória
                vr_tab_chqtco.DELETE;

                -- Comando para listar a ultima linha do arquivo
                vr_comando:= 'tail -2 ' || pr_caminho|| '/' || vr_vet_nmarquiv(idx);
                --Executar o comando no unix
                GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                     ,pr_des_comando => vr_comando
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => vr_setlinha);
                --Se ocorreu erro dar RAISE
                IF vr_typ_saida = 'ERR' THEN
                  vr_des_erro:= 'Não foi possível executar comando unix. '||vr_setlinha;
                  RAISE vr_exc_erro;
                END IF;

                IF SUBSTR(vr_setlinha,162,10) = '9999999999' THEN
                  vr_setlinha := SUBSTR(vr_setlinha,162);
                END IF;

                --Se o final do arquivo estiver errado
                IF SUBSTR(vr_setlinha,01,10) <> '9999999999' THEN
                  vr_cdcritic:= 0;
                  vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => 258);
                  vr_compl_erro:= ' - Arquivo: '|| vr_vet_nmarquiv(idx);
                  -- gera log de erro
                  btch0001.pc_gera_log_batch(pr_cdcooper   => pr_cdcooper
                          ,pr_ind_tipo_log => 2 -- Erro tratato
                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                        || vr_cdprogra || ' --> '
                                        || vr_des_erro
                                        || vr_compl_erro);
                  -- Limpa variaveis de erro
                  vr_cdcritic:= 0;
                  vr_des_erro := NULL;
                  vr_compl_erro:= NULL;
                ELSE
                  --Armazena os totais contidos na ultima linha do arquivo nas variaveis
                  vr_tot_qtregrec:= To_Number(SubStr(vr_setlinha,151,10)) -2;
                  vr_tot_vlregrec:= Round(To_Number(SubStr(vr_setlinha,74,17)) /100,2);

                  -- Comando para copiar o arquivo
                  vr_comando:= 'cp ' || pr_caminho|| '/' || vr_vet_nmarquiv(idx)||' '||pr_caminho|| '/' || vr_vet_nmarquiv(idx)||'.q';

                  --Executar o comando no unix
                  GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                       ,pr_des_comando => vr_comando
                                       ,pr_typ_saida   => vr_typ_saida
                                       ,pr_des_saida   => vr_setlinha);
                  --Se ocorreu erro dar RAISE
                  IF vr_typ_saida = 'ERR' THEN
                    vr_des_erro:= 'Não foi possível executar comando unix. '||vr_comando;
                    RAISE vr_exc_erro;
                  END IF;
                END IF;

                --Validar informacoes da primeira linha do arquivo .q
                vr_nmarquiv:= vr_vet_nmarquiv(idx)||'.q';
                --Abrir o arquivo lido e percorrer as linhas do mesmo
                gene0001.pc_abre_arquivo(pr_nmdireto => pr_caminho     --> Diretório do arquivo
                                        ,pr_nmarquiv => vr_nmarquiv    --> Nome do arquivo
                                        ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                        ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                        ,pr_des_erro => vr_des_erro);  --> Erro
                IF vr_des_erro IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_saida;
                END IF;

                IF  utl_file.IS_OPEN(vr_input_file) THEN
                  -- Le os dados do arquivo e coloca na variavel vr_setlinha
                  gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                              ,pr_des_text => vr_setlinha);  --> Texto lido
                  -- Fechar o arquivo
                  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
                END IF;

                --Verificar se as informacoes estao corretas no arquivo
                IF SUBSTR(vr_setlinha,01,10) <> '0000000000' THEN
                  vr_cdcritic:= 468;
                ELSIF SUBSTR(vr_setlinha,48,06) <> 'CEL615' THEN
                  vr_cdcritic:= 181;
                ELSIF To_Number(SUBSTR(vr_setlinha,61,03)) <> pr_cdbcoctl THEN
                  vr_cdcritic:= 57;
                ELSIF SUBSTR(vr_setlinha,66,08) <> pr_dtauxili THEN
                  vr_cdcritic:= 13;
                END IF;

                --Se ocorreu erro
                IF vr_cdcritic <> 0 THEN
                  vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                  vr_compl_erro:= ' - Arquivo: '|| vr_vet_nmarquiv(idx);
                  -- gera log de erro
                  btch0001.pc_gera_log_batch(pr_cdcooper   => pr_cdcooper
                          ,pr_ind_tipo_log => 2 -- Erro tratato
                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                        || vr_cdprogra || ' --> '
                                        || vr_des_erro
                                        || vr_compl_erro);
                  -- Limpa variaveis de erro
                  vr_cdcritic  := 0;
                  vr_des_erro  := NULL;
                  vr_compl_erro:= NULL;

                  --Apagar arquivo no unix
                  vr_comando:= 'rm ' || pr_caminho|| '/' || vr_vet_nmarquiv(idx)||'.q';
                  --Executar o comando no unix
                  GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                       ,pr_des_comando => vr_comando
                                       ,pr_typ_saida   => vr_typ_saida
                                       ,pr_des_saida   => vr_setlinha);
                  --Se ocorreu erro dar RAISE
                  IF vr_typ_saida = 'ERR' THEN
                    vr_des_erro:= 'Não foi possível executar comando unix para remoção do arquivo. '||vr_setlinha;
                    RAISE vr_exc_erro;
                  END IF;

                  --Reiniciar variavel de critica
                  vr_cdcritic:= 0;

                  --Abortar o arquivo e pegar proximo
                  RAISE vr_exc_proximo_arquivo;
                END IF;

                --Atribuir valor para as variaveis
                vr_contareg:= 1;
                vr_flgfirst:= TRUE;

                --Jogar mensagem de erro 219 no log
                vr_cdcritic:= 219;
                vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 1 -- Processo normal
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' --> '
                                                             || vr_des_erro || ' '||pr_caminho|| '/'||vr_vet_nmarquiv(idx));

                --Zerar variaveis de erro
                vr_cdcritic:= 0;
                vr_dscritic:= NULL;
                vr_des_erro:= NULL;
                vr_tab_critica.DELETE;

                --Determinar o nome do arquivo para processamento
                vr_nmarquiv:= vr_vet_nmarquiv(idx)||'.q';
                --Abrir o arquivo lido e percorrer as linhas do mesmo
                gene0001.pc_abre_arquivo(pr_nmdireto => pr_caminho     --> Diretório do arquivo
                                        ,pr_nmarquiv => vr_nmarquiv    --> Nome do arquivo
                                        ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                        ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                        ,pr_des_erro => vr_des_erro);  --> Erro
                IF vr_des_erro IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_saida;
                END IF;

                vr_conta_linha_tab := 0;
                vr_cont_indice     := 1;
                WHILE vr_conta_linha_tab <> 9999999999 LOOP
                   -- Le os dados do arquivo e coloca na variavel vr_setlinha
                   gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                               ,pr_des_text => vr_setlinha); --> Texto lido

                   --Incrementa o contador de linhas
                   vr_conta_linha_tab:= vr_conta_linha_tab + 1;

                   --Se for a primeira linha ignora
                   IF vr_conta_linha_tab = 1 THEN
                     -- Le os dados do arquivo e coloca na variavel vr_setlinha
                     gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                 ,pr_des_text => vr_setlinha); --> Texto lido

                     --Incrementa o contador de linhas
                     vr_conta_linha_tab:= vr_conta_linha_tab + 1;
                   END IF;

                   IF SUBSTR(vr_setlinha,1,10) = '9999999999' THEN
                        vr_conta_linha_tab := 9999999999;
                   ELSE
                     if SUBSTR(vr_setlinha,1,10) = '9999999999' then
                       null;
                     end if;
                     -- atribui para o indice conteudo da CONTA e VALOR
                     vr_indice := SUBSTR(vr_setlinha,15,09)||SUBSTR(vr_setlinha,34,17)||SUBSTR(vr_setlinha,25,06)||lpad(vr_cont_indice,10,'0');
                     vr_cont_indice := vr_cont_indice + 1;
                     vr_compensacao(vr_indice).linhaatual := SUBSTR(vr_setlinha,1,10);
                     vr_compensacao(vr_indice).nrdconta   := TO_NUMBER(SUBSTR(vr_setlinha,15,09));
                     vr_compensacao(vr_indice).nrdocmto   := TO_NUMBER(SUBSTR(vr_setlinha,25,06));
                     vr_compensacao(vr_indice).vllanmto   := (TO_NUMBER(SUBSTR(vr_setlinha,34,17)) / 100);
                     vr_compensacao(vr_indice).nrseqarq   := TO_NUMBER(SUBSTR(vr_setlinha,151,10));
                     vr_compensacao(vr_indice).cdbanchq   := TO_NUMBER(SUBSTR(vr_setlinha,04,03));
                     vr_compensacao(vr_indice).cdcmpchq   := TO_NUMBER(SUBSTR(vr_setlinha,01,03));
                     vr_compensacao(vr_indice).cdagechq   := TO_NUMBER(SUBSTR(vr_setlinha,07,04));
                     vr_compensacao(vr_indice).nrctachq   := vr_compensacao(vr_indice).nrdconta;
                     vr_compensacao(vr_indice).nrlotchq   := TO_NUMBER(SUBSTR(vr_setlinha,90,07));
                     vr_compensacao(vr_indice).sqlotchq   := TO_NUMBER(SUBSTR(vr_setlinha,97,03));
                     vr_compensacao(vr_indice).cdtpddoc   := TO_NUMBER(SUBSTR(vr_setlinha,148,03));
                     vr_compensacao(vr_indice).cdpesqbb   := vr_setlinha;
                     vr_compensacao(vr_indice).cdbandep   := TO_NUMBER(SUBSTR(vr_setlinha,56,03));
                     vr_compensacao(vr_indice).cdcmpdep   := TO_NUMBER(SUBSTR(vr_setlinha,79,03));
                     vr_compensacao(vr_indice).cdagedep   := TO_NUMBER(SUBSTR(vr_setlinha,63,04));
                     vr_compensacao(vr_indice).nrctadep   := TO_NUMBER(SUBSTR(vr_setlinha,67,12));
                     vr_compensacao(vr_indice).cdageapr   := TO_NUMBER(SUBSTR(vr_setlinha,59,04));

                     vr_compensacao(vr_indice).dados_log:= ' Coop= '   ||pr_cdcooper||
                                                           ' Banco= '  ||vr_cdbanchq||
                                                           ' Agência= '||vr_cdagechq||
                                                           ' Conta= '  ||vr_nrctachq||
                                                           ' Cheque= ' ||vr_nrdocmto||' ';
                   END IF;

                END LOOP;

                --Inicializar variavel do loop
                vr_indice := vr_compensacao.first;
                IF vr_compensacao.EXISTS(vr_indice) THEN
                vr_flgsair    := FALSE;
                ELSE
                  vr_flgsair    := TRUE;
                END IF;

                vr_flgsair    := FALSE;
                --Inicializa variavel de controle de linhas com zero
--                vr_conta_linha:= 0;

                WHILE NOT vr_flgsair LOOP

                  --Esse bloco é necessário para poder controlar as linhas que devem ser ignoradas
                  BEGIN

                    --Incrementa o contador de linhas
  --                  vr_conta_linha:= vr_conta_linha+1;

                    -- Sair quando não existir mais linhas
                    EXIT WHEN vr_flgsair = TRUE;

                    -- Criando SAVEPOINT para a transação
                    SAVEPOINT vr_savepoint_trans;

                    --Atribuir valores iniciais para as variaveis
                    vr_cdalinea:= 0;
                    vr_indevchq:= 0;
                    vr_nrseqarq:= vr_compensacao(vr_indice).nrseqarq;--TO_NUMBER(SUBSTR(vr_setlinha,151,10));
                    vr_cdcritic:= 0;

                    --Se o arquivo estiver no final
                    IF vr_compensacao(vr_indice).linhaatual = '9999999999' THEN-- SUBSTR(vr_setlinha,1,10) = '9999999999' THEN

                      --Inserir na tabela de rejeitados na integração (CRAPREJ)
                      BEGIN
                        INSERT INTO craprej (cdcooper
                                            ,dtrefere
                                            ,cdcritic
                                            ,nrdconta
                                            ,nrseqdig
                                            ,vllanmto)
                                    VALUES  (pr_cdcooper
                                            ,pr_dtauxili
                                            ,998
                                            ,999999999
                                            ,vr_compensacao(vr_indice).nrseqarq--TO_NUMBER(SUBSTR(vr_setlinha,151,10))
                                            ,vr_compensacao(vr_indice).vllanmto);--(TO_NUMBER(SUBSTR(vr_setlinha,74,17)) / 100));
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_des_erro:= 'Erro ao inserir na tabela craprej. Rotina pc_crps533.pc_integra_todas_coop. '||sqlerrm;
                          RAISE vr_exc_erro;
                      END;

                      --Se nao for o primeiro registro
                      IF NOT vr_flgfirst THEN

                        --Se nao possui lote na tabela generica
                        IF vr_numlotebco IS NULL THEN
                          -- Montar mensagem de critica
                          vr_cdcritic:= 472;
                          vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          --Levantar exceção para saida
                          RAISE vr_exc_erro;
                        ELSE
                          --Verificar informacoes antes de atualizar
                          IF vr_nrdolote = 7019 THEN
                            vr_dstextab:= '7010';
                          ELSE
                            vr_dstextab:= To_Char(vr_nrdolote+1,'FM9999');
                          END IF;
                          --Atualizar lote banco para uso posterior
                          vr_numlotebco:= to_number(vr_dstextab);
                          --Atualizar tabela genérica
                          BEGIN
                            UPDATE craptab SET dstextab = vr_dstextab
                            WHERE craptab.cdcooper = pr_cdcooper
                            AND   craptab.nmsistem = 'CRED'
                            AND   craptab.tptabela = 'GENERI'
                            AND   craptab.cdempres = 00
                            AND   craptab.cdacesso = 'NUMLOTEBCO'
                            AND   craptab.tpregist = 001;
                          EXCEPTION
                            WHEN OTHERS THEN
                              vr_des_erro:= 'Erro ao atualizar a tabela craptab. Rotina pc_crps533.pc_integra_todas_coop. '||sqlerrm;
                              RAISE vr_exc_erro;
                          END;
                        END IF; --cr_craptab%NOTFOUND
                      END IF; --NOT vr_flgfirst

                      --Sair do LOOP
                      vr_flgsair:= TRUE;
                      --levantar exceção para sair do arquivo
                      RAISE vr_exc_sair;
                    END IF; --SUBSTR(vr_setlinha,1,10) = '9999999999'

                    BEGIN
                      --Atribuir valores para as variaveis
                      vr_nrdconta:= vr_compensacao(vr_indice).nrdconta;--TO_NUMBER(SUBSTR(vr_setlinha,15,09));
                      vr_nrdocmto:= vr_compensacao(vr_indice).nrdocmto;--TO_NUMBER(SUBSTR(vr_setlinha,25,06));
                      vr_vllanmto:= vr_compensacao(vr_indice).vllanmto;--(TO_NUMBER(SUBSTR(vr_setlinha,34,17)) / 100);
                      vr_nrseqarq:= vr_compensacao(vr_indice).nrseqarq;--TO_NUMBER(SUBSTR(vr_setlinha,151,10));
                      vr_cdbanchq:= vr_compensacao(vr_indice).cdbanchq;--TO_NUMBER(SUBSTR(vr_setlinha,04,03));
                      vr_cdcmpchq:= vr_compensacao(vr_indice).cdcmpchq;--TO_NUMBER(SUBSTR(vr_setlinha,01,03));
                      vr_cdagechq:= vr_compensacao(vr_indice).cdagechq;--TO_NUMBER(SUBSTR(vr_setlinha,07,04));
                      vr_nrctachq:= vr_nrdconta;
                      vr_nrlotchq:= vr_compensacao(vr_indice).nrlotchq;--TO_NUMBER(SUBSTR(vr_setlinha,90,07));
                      vr_sqlotchq:= vr_compensacao(vr_indice).sqlotchq;--TO_NUMBER(SUBSTR(vr_setlinha,97,03));
                      vr_cdtpddoc:= vr_compensacao(vr_indice).cdtpddoc;--TO_NUMBER(SUBSTR(vr_setlinha,148,03));
                      vr_cdpesqbb:= vr_compensacao(vr_indice).cdpesqbb;
                    
                      vr_dados_log := ' Coop= '   ||pr_cdcooper||
                                      ' Banco= '  ||vr_cdbanchq||
                                      ' Agência= '||vr_cdagechq||
                                      ' Conta= '  ||vr_nrctachq||
                                      ' Cheque= ' ||vr_nrdocmto||' ';
                    
                    EXCEPTION
                      WHEN OTHERS THEN

                        --Montar mensagem no log
                        vr_cdcritic:= 843;
                        vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                        vr_compl_erro:= ' Seq: '||To_Char(gene0002.fn_mask(vr_nrseqarq,'zzzz.zz9'));
                        -- Envio centralizado de log de erro
                        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                      || vr_cdprogra || ' --> '
                                                                      || vr_des_erro || vr_compl_erro);
                        --Sair do LOOP
                        vr_flgsair:= TRUE;
                        RAISE vr_exc_sair;

                    END;

                    --Se nao for a ultima linha do arquivo
                    IF NOT vr_flgsair THEN
                      BEGIN
                        vr_cdbandep:= vr_compensacao(vr_indice).cdbandep;--TO_NUMBER(SUBSTR(vr_setlinha,56,03));
                        vr_cdcmpdep:= vr_compensacao(vr_indice).cdcmpdep;--TO_NUMBER(SUBSTR(vr_setlinha,79,03));
                        vr_cdagedep:= vr_compensacao(vr_indice).cdagedep;--TO_NUMBER(SUBSTR(vr_setlinha,63,04));
                        vr_nrctadep:= vr_compensacao(vr_indice).nrctadep;--TO_NUMBER(SUBSTR(vr_setlinha,67,12));
                        vr_cdageapr:= vr_compensacao(vr_indice).cdageapr;--TO_NUMBER(SUBSTR(vr_setlinha,59,04));
                      EXCEPTION
                        WHEN OTHERS THEN

                          --Zerar variaveis
                          vr_cdbandep:= 0;
                          vr_cdcmpdep:= 0;
                          vr_cdagedep:= 0;
                          vr_nrctadep:= 0;
                          vr_cdageapr:= 0;

                          --Montar mensagem no log
                          vr_cdcritic:= 843;
                          vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          vr_compl_erro:= ' Seq: '||To_Char(gene0002.fn_mask(vr_nrseqarq,'zzzz.zz9'));
                          -- Envio centralizado de log de erro
                          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                        || vr_cdprogra || ' --> '
                                                                        || vr_des_erro || vr_compl_erro
                                                                        || vr_dados_log);
              
                          -- Limpa as variaveis apos efetuar log.
                          vr_cdcritic:= 0;
                          vr_des_erro:= NULL;
                          vr_compl_erro:= NULL;
                      END;
                      -- Limpar variavel de critica auxiliar para cada conta do arquivo
                      vr_cdcritic_aux:= 0;
                      
                      --Numero da conta anterior recebe a que está processando
                      vr_ant_nrdconta:= vr_nrdconta;
                      --Limpar código da conta incorporada
                      vr_nrdconta_incorp := NULL;

                      --Calcular o dígito da conta do associado
                      vr_flgdigit:= gene0005.fn_calc_digito(pr_nrcalcul => vr_nrdconta);

                      --Se deu erro na rotina de calculo do digito
                      IF NOT vr_flgdigit THEN
                        vr_flgdigit:= TRUE;
                      END IF;

                      vr_nrdctabb:= vr_nrdconta;

                      -- Verificar incorporação da conta (se o arquivo for)
                      IF vr_cdcooper_incorp IS NOT NULL THEN
                        -- Selecionar informacoes das transferencias entre contas
                        -- usando a conta antiga igual a conta vinda do cheque
                        OPEN cr_craptco (pr_cdcopant => vr_cdcooper_incorp
                                        ,pr_nrctaant => vr_nrdconta);
                        --Posicionar no proximo registro
                        FETCH cr_craptco INTO rw_craptco;
                        -- Se Encontrou registros
                        IF cr_craptco%FOUND THEN
                          -- Guardar código da conta incorporada
                          vr_nrdconta_incorp := rw_craptco.nrdconta;
                        END IF;
                        --Fechar Cursor
                        CLOSE cr_craptco;
                      END IF;

                      -- Testar se a conta existe na Cooperativa
                      -- Obs: Primeiro testa a conta incorporada, depois a do arquivo
                      -- Inserir na tabela de rejeição
                      vr_cdcritic := 0;
                      IF NOT vr_tab_crapass.EXISTS(nvl(vr_nrdconta_incorp,vr_nrdconta)) THEN
                           vr_cdcritic := 9;
                      ELSIF NOT vr_tab_crapage.EXISTS(vr_cdagechq) THEN
                           vr_cdcritic := 134;-- agencia não cadastrada
                      END IF;
                      IF vr_cdcritic in (9,134) then
                        BEGIN
                          INSERT INTO craprej (cdcooper
                                              ,dtrefere
                                              ,nrdconta
                                              ,nrdocmto
                                              ,vllanmto
                                              ,nrseqdig
                                              ,cdcritic
                                              ,cdpesqbb
                                              ,nrdctitg) -- Conta depositada
                                     VALUES   (pr_cdcooper
                                              ,pr_dtauxili
                                              ,nvl(nvl(vr_nrdconta_incorp,vr_nrdconta),0)
                                              ,nvl(vr_nrdocmto,0)
                                              ,nvl(vr_vllanmto,0)
                                              ,nvl(vr_nrseqarq,0)
                                              ,vr_cdcritic
                                              ,nvl(vr_cdpesqbb,' ')
                                              ,nvl(vr_nrctadep,0));

                        EXCEPTION
                          WHEN OTHERS THEN
                            vr_cdcritic:= 843;
                            vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                            vr_compl_erro:= ' Seq: '||To_Char(gene0002.fn_mask(vr_nrseqarq,'zzzz.zz9'));
                            -- Envio centralizado de log de erro
                            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                          || vr_cdprogra || ' --> '
                                                                          || vr_des_erro || vr_compl_erro
                                                                          || vr_dados_log);
                            --Levantar Excecao
                            RAISE vr_exc_erro;
                        END;

                        --Executar rotina pc_cria_generica
                        pc_cria_generica(pr_cdcooper   => pr_cdcooper
                                        ,pr_cdagenci   => 0
                                        ,pr_dtmvtolt   => pr_dtmvtolt
                                        ,pr_cdcritic   => vr_cdcritic
                                        ,pr_dtleiarq   => pr_dtleiarq
                                        ,pr_cdagectl   => pr_cdagectl
                                        ,pr_nmarquiv   => vr_vet_nmarquiv(idx)
                                        ,pr_cdbanchq   => vr_cdbanchq
                                        ,pr_cdagechq   => vr_cdagechq
                                        ,pr_nrctachq   => vr_nrctachq
                                        ,pr_nrdocmto   => vr_nrdocmto
                                        ,pr_cdcmpchq   => vr_cdcmpchq
                                        ,pr_vllanmto   => vr_vllanmto
                                        ,pr_nrdconta   => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                        ,pr_nrseqarq   => vr_nrseqarq
                                        ,pr_cdpesqbb   => vr_cdpesqbb
                                        ,pr_setlinha   => vr_compensacao(vr_indice).cdpesqbb
                                        ,pr_dscritic   => vr_des_erro);

                        --Verificar se retornou erro
                        IF vr_des_erro IS NOT NULL THEN
                          RAISE vr_exc_erro;
                        END IF;

                                  --Executar a rotina da alinea 37
                        pc_gera_dev_alinea (pr_cdcooper => pr_cdcooper
                                             ,pr_cdbcoctl => pr_cdbcoctl
                                             ,pr_dtmvtopr => (CASE pr_nmtelant
                                                                WHEN 'COMPEFORA' THEN
                                                                     pr_dtmvtolt
                                                                ELSE PR_dtmvtopr
                                                              END)
                                             ,pr_cdbccxlt => pr_cdbccxlt
                                             ,pr_nrdconta => 0
                                             ,pr_nrdocmto => vr_nrdocmto
                                             ,pr_nrdctitg => ' '
                                             ,pr_vllanmto => vr_vllanmto
                                             ,pr_cdalinea => 37
                                             ,pr_cdhistor => 47
                                             ,pr_cdpesqbb => SubStr(vr_cdpesqbb,1,200)
                                             ,pr_cdoperad => '1'
                                             ,pr_cdagechq => vr_cdagechq --> Agencia do cheque
                                             ,pr_nrctachq => vr_nrdctabb --> Conta do cheque
                                             ,pr_cdbandep => vr_cdbandep
                                             ,pr_cdagedep => vr_cdagedep
                                             ,pr_nrctadep => vr_nrctadep
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_des_erro);


                        --Verificar se ocorreu erro
                        IF vr_des_erro IS NOT NULL THEN
                          RAISE vr_exc_erro;
                        END IF;

                        --Verificar se retornou erro
                        IF vr_cdcritic = 415 THEN
                          --Inserir na tabela de rejeição
                          BEGIN
                            INSERT INTO craprej (cdcooper
                                                ,dtrefere
                                                ,nrdconta
                                                ,nrdocmto
                                                ,vllanmto
                                                ,nrseqdig
                                                ,cdcritic
                                                ,cdpesqbb
                                                ,nrdctitg) -- Conta depositada
                                       VALUES   (pr_cdcooper
                                                ,pr_dtauxili
                                                ,nvl(nvl(vr_nrdconta_incorp,vr_nrdconta),0)
                                                ,nvl(vr_nrdocmto,0)
                                                ,nvl(vr_vllanmto,0)
                                                ,nvl(vr_nrseqarq,0)
                                                ,nvl(vr_cdcritic,0)
                                                ,nvl(vr_cdpesqbb,' ')
                                                ,nvl(vr_nrctadep,0));
                          EXCEPTION
                            WHEN OTHERS THEN
                              vr_cdcritic:= 843;
                              vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                              vr_compl_erro:= ' Seq: '||To_Char(gene0002.fn_mask(vr_nrseqarq,'zzzz.zz9'));
                              -- Envio centralizado de log de erro
                              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                            || vr_cdprogra || ' --> '
                                                                            || vr_des_erro || vr_compl_erro
                                                                            || vr_dados_log);
                              RAISE vr_exc_erro;
                          END;

                          --Atribuir zero para variavel de erro
                          vr_cdcritic:= 0;
                        END IF;  --vr_cdcritic = 415

                        --Ir para a proxima linha do arquivo
                        RAISE vr_exc_pula;
                      END IF; --cr_crapass%NOTFOUND
            
                      --Verificar se a situacao da conta (somente para não integradas)
                      IF vr_nrdconta_incorp IS NULL THEN
                        IF vr_tab_crapass(vr_nrdconta).cdsitdtl IN (2,4,5,6,7,8) THEN
                          --Selecionar as transferencias e duplicações de matricula
                          OPEN cr_craptrf (pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => vr_nrdconta
                                          ,pr_tptransa => 1);
                          --Posicionar cursor no primeiro registro
                          FETCH cr_craptrf INTO rw_craptrf;
                          --Se retornou registros
                          IF cr_craptrf%FOUND THEN
                            vr_nrdconta:= rw_craptrf.nrsconta;
                          END IF;
                          --Fechar Cursor
                          CLOSE cr_craptrf;
                        END IF;
                      END IF;

                      -- Se não for um arquivo incorporado
                      IF vr_cdcooper_incorp IS NULL THEN
                        --Se for cooperativa 1 OU 2
                        IF pr_cdcooper IN (1,2) THEN
                          --Selecionar informacoes das transferencias entre contas
                          -- Viacredi -> AltoVale
                          -- Acredi -> Viacredi
                          OPEN cr_craptco (pr_cdcopant => pr_cdcooper
                                          ,pr_nrctaant => vr_nrdconta
                                          ,pr_tpctatrf => 1
                                          ,pr_flgativo => 1);
                          --Posicionar no proximo registro
                          FETCH cr_craptco INTO rw_craptco;
                          --Se Encontrou registros
                          IF cr_craptco%FOUND THEN
                            vr_flctamig:= TRUE;
                            vr_cdcooper := rw_craptco.cdcooper;
                          ELSE
                            vr_flctamig:= FALSE;
                            vr_cdcooper := pr_cdcooper;
                          END IF;
                          --Fechar Cursor
                          CLOSE cr_craptco;
                        ELSE
                          vr_flctamig:= FALSE;
                          vr_cdcooper := pr_cdcooper;                          
                        END IF;
                      ELSE
                        vr_cdcooper := pr_cdcooper;
                      END IF;

                      --Atribuir zero para variavel de erro
                      vr_cdcritic:= 0;
                      -- Selecionar folhas de cheque emitidas
                      -- Obs: Utilizando banco e agencia da incorporada se houver
                      OPEN cr_crapfdc (pr_cdcooper => pr_cdcooper
                                      ,pr_cdbanchq => nvl(vr_cdbcoctl_incorp,pr_cdbcoctl)
                                      ,pr_cdagechq => nvl(vr_cdagectl_incorp,pr_cdagectl)
                                      ,pr_nrctachq => vr_nrctachq
                                      ,pr_nrcheque => vr_nrdocmto);
                      --Posicionar no primeiro registro
                      FETCH cr_crapfdc INTO rw_crapfdc;
                      --Se nao encontrou nada
                      IF cr_crapfdc%NOTFOUND THEN
                        --Fechar cursor
                        CLOSE cr_crapfdc;
                        vr_cdcritic:= 108;
                        /* Calcular o digito do Cheque */
                        vr_nrcalcul := vr_nrdocmto * 10;
                        vr_retdig := GENE0005.fn_calc_digito(pr_nrcalcul => vr_nrcalcul);
                        vr_nrdocmto := TO_NUMBER(vr_nrcalcul);
                      ELSE
                        --Fechar cursor
                        CLOSE cr_crapfdc;
                        --Atribuir valores para as variaveis
                        vr_nrdocsdg:= vr_nrdocmto;
                        vr_nrdocmto:= TO_NUMBER(TO_CHAR(rw_crapfdc.nrcheque,'FM999999')||To_Char(rw_crapfdc.nrdigchq,'FM9'));
                        -- Cheque salario
                        IF rw_crapfdc.tpcheque = 3   THEN
                          vr_cdcritic:= 289;
                        ELSIF rw_crapfdc.dtemschq IS NULL THEN
                          vr_cdcritic:= 108;
                        ELSIF rw_crapfdc.dtretchq IS NULL THEN
                          vr_cdcritic:= 109;
                        ELSIF rw_crapfdc.incheque IN (5,6,7) THEN
                          vr_cdcritic:= 97;
                        ELSIF rw_crapfdc.incheque = 8 THEN
                          vr_cdcritic:= 320;
                        ELSE
                          --Se o banco ou agencia de custodia for <> 0
                          IF rw_crapfdc.cdbantic <> 0 OR rw_crapfdc.cdagetic <> 0 THEN
                            IF NOT (vr_cdbandep = rw_crapfdc.cdbantic AND
                                     (vr_cdagedep = rw_crapfdc.cdagetic OR
                                      vr_cdageapr = rw_crapfdc.cdagetic)
                                   ) THEN
                              /* Tratamento AltoVale e Viacredi
                                Os cheques que tiverem suas contas migradas
                                para outra coop. serao enviados em arquivo de
                                exclusao seguido de inclusao da informacao do
                                do novo banco custodiante(TIC). O registro
                                crapfdc nao sera alterado na coop. antiga.
                                Estes cheques virao no arquivo da COMPE com a
                                informacao do banco depositante atualizada,
                                porem na crapfdc contera o banco/agencia da
                                coop antiga */
                              IF NOT (  (rw_crapfdc.cdbantic = 85 AND rw_crapfdc.cdagetic = 101 AND (vr_cdagedep = 115 OR vr_cdageapr = 115)) --> Via para Altovale
                                      OR(rw_crapfdc.cdbantic = 85 AND rw_crapfdc.cdagetic = 102 AND (vr_cdagedep = 101 OR vr_cdageapr = 101)) --> Acredi para Via
                                      OR(rw_crapfdc.cdbantic = 85 AND rw_crapfdc.cdagetic = 103 AND (vr_cdagedep = 101 OR vr_cdageapr = 101)) --> Concredi para Via
                                      OR(rw_crapfdc.cdbantic = 85 AND rw_crapfdc.cdagetic = 114 AND (vr_cdagedep = 112 OR vr_cdageapr = 112)) --> Credimilsul para SCR
                                      ) THEN
                                vr_cdcritic:= 950;
                                vr_cdalinea:= 35;
                                vr_indevchq:= 1;
                              END IF;
                            END IF;
                          END IF;
                        END IF;

                        --Se nao ocorreu erro
                        IF vr_cdcritic = 0 THEN
                          --Se o indicador de cheque =1
                          IF rw_crapfdc.incheque = 1 THEN
                            --Selecionar Maior Lancamento
                            OPEN cr_craplcm1 (pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                             ,pr_nrdocmto => vr_nrdocmto);
                            --Posicionar cursor no proximo registro
                            FETCH cr_craplcm1 INTO rw_craplcm1;
                            --Se nao encontrou lancamentos
                            IF cr_craplcm1%NOTFOUND THEN
                              --Fechar o cursor
                              CLOSE cr_craplcm1;
                              vr_cdcritic:= 96;
                              IF rw_crapfdc.tpcheque = 1 THEN
                                vr_indevchq:= 1;
                              ELSE
                                vr_indevchq:= 3;
                              END IF;
                              vr_cdalinea:= 0;
                            ELSE
                              --Fechar o cursor
                              CLOSE cr_craplcm1;
                              --Selecionar Contra-Ordens
                              OPEN cr_crapcor (pr_cdcooper => pr_cdcooper
                                              ,pr_cdbanchq => vr_cdbanchq
                                              ,pr_cdagechq => vr_cdagechq
                                              ,pr_nrctachq => vr_nrctachq
                                              ,pr_nrdctabb => NULL
                                              ,pr_nrcheque => vr_nrdocmto
                                              ,pr_flgativo => 1);
                              --Posicionar no proximo registro
                              FETCH cr_crapcor INTO rw_crapcor;

                              --Se nao encontrou
                              IF cr_crapcor%NOTFOUND THEN
                                vr_cdcritic:= 439;
                                vr_indevchq:= 1;
                                vr_cdalinea:= 0;
                              ELSE

                                IF rw_crapcor.dtvalcor >= pr_dtmvtolt THEN
                                  vr_cdcritic:= 96;
                                  vr_indevchq:= 1;
                                  vr_cdalinea:= 70;
                                ELSE

                                  IF rw_crapcor.dtemscor > rw_craplcm1.dtmvtolt THEN
                                    vr_cdcritic:= 96;
                                    vr_cdalinea:= 0;
                                    IF rw_crapfdc.tpcheque = 1 THEN
                                      vr_indevchq:= 1;
                                    ELSE
                                      vr_indevchq:= 3;
                                    END IF;
                                  ELSE
                                    vr_cdcritic:= 439;
                                    IF rw_crapfdc.tpcheque = 1 THEN
                                      vr_indevchq:= 1;
                                    ELSE
                                      vr_indevchq:= 3;
                                    END IF;
                                    IF rw_crapcor.cdhistor = 835 THEN
                                      vr_cdalinea:= 28;
                                    ELSIF rw_crapcor.cdhistor = 815 THEN
                                      vr_cdalinea:= 21;
                                    ELSIF rw_crapcor.cdhistor = 818 THEN
                                      vr_cdalinea:= 20;
                                    ELSE
                                      vr_cdalinea:= 21;
                                    END IF;
                                  END IF;
                                END IF;
                              END IF; --cr_crapcor%NOTFOUND
                              --Fechar cursor
                              CLOSE cr_crapcor;
                            END IF; --cr_craplcm1%NOTFOUND
                            --Fechar o cursor
                            IF cr_craplcm1%ISOPEN THEN
                              CLOSE cr_craplcm1;
                            END IF;
                          END IF; --rw_crapfdc.incheque = 1
                          --Selecionar lancamentos
                        END IF; --vr_cdcritic = 0

                        --Se nao ocorreu erro
                        IF vr_cdcritic = 0 THEN
                          --Montar indice crapneg
                          vr_index_crapneg:= lpad(nvl(vr_nrdconta_incorp,vr_nrdconta),10,'0')||lpad(vr_nrdocmto,10,'0');
                          -- Testar se existe saldos negativos e controles de cheque
                          IF vr_tab_crapneg.EXISTS(vr_index_crapneg) THEN
                            --Se o codigo de observacao for 12 ou 13
                            IF rw_crapfdc.tpcheque = 1 THEN
                              vr_indevchq:= 1;
                            ELSE
                              vr_indevchq:= 3;
                            END IF;
                            vr_cdcritic:= 414;
                            vr_cdalinea:= 49;
                          END IF;
                        END IF; --cr_cdcritic = 0
                      END IF;
                      --Fechar cursor caso esteja aberto
                      IF cr_crapfdc%ISOPEN THEN
                        --Fechar cursor
                        CLOSE cr_crapfdc;
                      END IF;

                      --Verificar se ocorreu a critica 108  linha(1140)
                      IF vr_cdcritic = 108 THEN

                        IF vr_flctamig THEN
                          vr_tpintegr:= 1;
                        ELSE
                          vr_tpintegr:= 0;
                        END IF;

                        --Inserir na tabela de rejeição
                        BEGIN
                          INSERT INTO craprej (cdcooper
                                              ,dtrefere
                                              ,nrdconta
                                              ,nrdocmto
                                              ,vllanmto
                                              ,nrseqdig
                                              ,cdcritic
                                              ,cdpesqbb
                                              ,tpintegr
                                              ,nrdctitg) -- Conta depositada
                                     VALUES   (pr_cdcooper
                                              ,pr_dtauxili
                                              ,nvl(nvl(vr_nrdconta_incorp,vr_nrdconta),0)
                                              ,nvl(vr_nrdocmto,0)
                                              ,nvl(vr_vllanmto,0)
                                              ,nvl(vr_nrseqarq,0)
                                              ,108
                                              ,nvl(vr_cdpesqbb,' ')
                                              ,nvl(vr_tpintegr,0)
                                              ,nvl(vr_nrctadep,0));
                        EXCEPTION
                          WHEN OTHERS THEN
                            vr_cdcritic:= 843;
                            vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                            vr_compl_erro:= ' Seq: '||To_Char(gene0002.fn_mask(vr_nrseqarq,'zzzz.zz9'));
                            -- Envio centralizado de log de erro
                            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                          || vr_cdprogra || ' --> '
                                                                          || vr_des_erro || vr_compl_erro
                                                                          ||vr_dados_log);
                            RAISE vr_exc_erro;
                        END;

                        --Executar a rotina da alinea 37
                        pc_gera_dev_alinea (pr_cdcooper => pr_cdcooper
                                             ,pr_cdbcoctl => pr_cdbcoctl
                                             ,pr_dtmvtopr => (CASE pr_nmtelant
                                                                WHEN 'COMPEFORA' THEN
                                                                     pr_dtmvtolt
                                                                ELSE PR_dtmvtopr
                                                              END)
                                             ,pr_cdbccxlt => pr_cdbcoctl
                                             ,pr_nrdconta => 0
                                             ,pr_nrdocmto => vr_nrdocmto
                                             ,pr_nrdctitg => NULL
                                             ,pr_vllanmto => vr_vllanmto
                                             ,pr_cdalinea => 37
                                             ,pr_cdhistor => 47
                                             ,pr_cdpesqbb => vr_cdpesqbb
                                             ,pr_cdoperad => '1'
                                             ,pr_cdagechq => vr_cdagechq --> Agencia Cheque do Arquivo
                                             ,pr_nrctachq => vr_nrdctabb --> Conta Cheque do Arquivo
                                             ,pr_cdbandep => vr_cdbandep
                                             ,pr_cdagedep => vr_cdagedep
                                             ,pr_nrctadep => vr_nrctadep
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_des_erro);

                        --Verificar se ocorreu erro
                        IF vr_des_erro IS NOT NULL THEN
                          -- Envio centralizado de log de erro
                          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                        || vr_cdprogra || ' --> '
                                                                        || vr_des_erro
                                                                        || vr_dados_log );
                          RAISE vr_exc_erro;
                        END IF;

                        --Verificar se retornou erro
                        IF vr_cdcritic = 415 THEN
                          IF vr_flctamig THEN
                            vr_tpintegr:= 1;
                          ELSE
                            vr_tpintegr:= 0;
                          END IF;

                          --Inserir na tabela de rejeição
                          BEGIN
                            INSERT INTO craprej (cdcooper
                                                ,dtrefere
                                                ,nrdconta
                                                ,nrdocmto
                                                ,vllanmto
                                                ,nrseqdig
                                                ,cdcritic
                                                ,cdpesqbb
                                                ,tpintegr
                                                ,nrdctitg) -- Conta depositada
                                       VALUES   (pr_cdcooper
                                                ,pr_dtauxili
                                                ,nvl(nvl(vr_nrdconta_incorp,vr_nrdconta),0)
                                                ,nvl(vr_nrdocmto,0)
                                                ,nvl(vr_vllanmto,0)
                                                ,nvl(vr_nrseqarq,0)
                                                ,nvl(vr_cdcritic,0)
                                                ,nvl(vr_cdpesqbb,' ')
                                                ,nvl(vr_tpintegr,0)
                                                ,nvl(vr_nrctadep,0));
                          EXCEPTION
                            WHEN OTHERS THEN
                              vr_cdcritic:= 843;
                              vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                              vr_compl_erro:= ' Seq: '||To_Char(gene0002.fn_mask(vr_nrseqarq,'zzzz.zz9'));
                              -- Envio centralizado de log de erro
                              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                            || vr_cdprogra || ' --> '
                                                                            || vr_des_erro || vr_compl_erro
                                                                            || vr_dados_log);
                              RAISE vr_exc_erro;
                          END;
                        END IF;  --vr_cdcritic = 415

                        --Executar rotina pc_cria_generica
                        pc_cria_generica(pr_cdcooper   => pr_cdcooper
                                        ,pr_cdagenci   => vr_tab_crapass(nvl(vr_nrdconta_incorp,vr_nrdconta)).cdagenci
                                        ,pr_dtmvtolt   => pr_dtmvtolt
                                        ,pr_cdcritic   => vr_cdcritic
                                        ,pr_dtleiarq   => pr_dtleiarq
                                        ,pr_cdagectl   => pr_cdagectl
                                        ,pr_nmarquiv   => vr_vet_nmarquiv(idx)
                                        ,pr_cdbanchq   => vr_cdbanchq
                                        ,pr_cdagechq   => vr_cdagechq
                                        ,pr_nrctachq   => vr_nrctachq
                                        ,pr_nrdocmto   => vr_nrdocmto
                                        ,pr_cdcmpchq   => vr_cdcmpchq
                                        ,pr_vllanmto   => vr_vllanmto
                                        ,pr_nrdconta   => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                        ,pr_nrseqarq   => vr_nrseqarq
                                        ,pr_cdpesqbb   => vr_cdpesqbb
                                        ,pr_setlinha   => vr_compensacao(vr_indice).cdpesqbb
                                        ,pr_dscritic   => vr_des_erro);
                        --Verificar se retornou erro
                        IF vr_des_erro IS NOT NULL THEN
                          RAISE vr_exc_erro;
                        END IF;

                        --Inicializar variavel de erro
                        vr_cdcritic:= 0;

                        --Ler proxima linha do arquivo
                        RAISE vr_exc_pula;
                      END IF; --vr_cdcritic = 108

                      -- Se cheque ja entrou critica 97
                      IF vr_cdcritic = 97 THEN

                        vr_cdcritic_aux := vr_cdcritic;
                        
                        IF vr_flctamig THEN
                          vr_tpintegr:= 1;
                        ELSE
                          vr_tpintegr:= 0;
                        END IF;

                        --Inserir na tabela de rejeição
                        BEGIN
                          INSERT INTO craprej (cdcooper
                                              ,dtrefere
                                              ,nrdconta
                                              ,nrdocmto
                                              ,vllanmto
                                              ,nrseqdig
                                              ,cdcritic
                                              ,cdpesqbb
                                              ,tpintegr
                                              ,nrdctitg) -- Conta depositada
                                     VALUES   (pr_cdcooper
                                              ,pr_dtauxili
                                              ,nvl(nvl(vr_nrdconta_incorp,vr_nrdconta),0)
                                              ,nvl(vr_nrdocmto,0)
                                              ,nvl(vr_vllanmto,0)
                                              ,nvl(vr_nrseqarq,0)
                                              ,97
                                              ,nvl(vr_cdpesqbb,' ')
                                              ,nvl(vr_tpintegr,0)
                                              ,nvl(vr_nrctadep,0));
                        EXCEPTION
                          WHEN OTHERS THEN
                            vr_cdcritic:= 843;
                            vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                            vr_compl_erro:= ' Conta: ' || To_Char(gene0002.fn_mask_conta(nvl(vr_nrdconta_incorp,vr_nrdconta)))||
                                            ' Docmto: '|| To_Char(gene0002.fn_mask(vr_nrdocmto,'zzzz.zzz.9'))||
                                            ' Seq: '   || To_Char(gene0002.fn_mask(vr_nrseqarq,'zzzz.zz9'));
                            -- Envio centralizado de log de erro
                            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                                      ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                          || vr_cdprogra || ' --> '
                                                                          || vr_des_erro || vr_compl_erro
                                                                          || vr_dados_log);
                            RAISE vr_exc_erro;
                        END;

                        --Executar a rotina da alinea 35
                        pc_gera_dev_alinea (pr_cdcooper => pr_cdcooper
                                           ,pr_cdbcoctl => pr_cdbcoctl
                                           ,pr_dtmvtopr => (CASE pr_nmtelant
                                                              WHEN 'COMPEFORA' THEN
                                                                   pr_dtmvtolt
                                                              ELSE PR_dtmvtopr
                                                            END)
                                           ,pr_cdbccxlt => pr_cdbcoctl
                                           ,pr_nrdconta => 0
                                           ,pr_nrdocmto => vr_nrdocmto
                                           ,pr_nrdctitg => NULL
                                           ,pr_vllanmto => vr_vllanmto
                                           ,pr_cdalinea => 35
                                           ,pr_cdhistor => 47
                                           ,pr_cdpesqbb => vr_cdpesqbb
                                           ,pr_cdoperad => '1'
                                           ,pr_cdagechq => vr_cdagechq --> Agencia Cheque do Arquivo
                                           ,pr_nrctachq => vr_nrdctabb --> Conta Cheque do Arquivo
                                           ,pr_cdbandep => vr_cdbandep
                                           ,pr_cdagedep => vr_cdagedep
                                           ,pr_nrctadep => vr_nrctadep                                           
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_des_erro);

                        --Verificar se ocorreu erro
                        IF vr_des_erro IS NOT NULL THEN
                          -- Envio centralizado de log de erro
                          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                        || vr_cdprogra || ' --> '
                                                                        || vr_des_erro ||
                                                                        ' Conta: ' || To_Char(gene0002.fn_mask_conta(nvl(vr_nrdconta_incorp,vr_nrdconta)))||
                                                                        ' Docmto: '|| To_Char(gene0002.fn_mask(vr_nrdocmto,'zzzz.zzz.9'))||
                                                                        ' Seq: '   || To_Char(gene0002.fn_mask(vr_nrseqarq,'zzzz.zz9')));
                          RAISE vr_exc_erro;
                        END IF;

                        --Verificar se retornou erro
                        IF vr_cdcritic = 415 THEN

                          vr_cdcritic_aux := vr_cdcritic;
                          
                          IF vr_flctamig THEN
                            vr_tpintegr:= 1;
                          ELSE
                            vr_tpintegr:= 0;
                          END IF;

                          --Inserir na tabela de rejeição
                          BEGIN
                            INSERT INTO craprej (cdcooper
                                                ,dtrefere
                                                ,nrdconta
                                                ,nrdocmto
                                                ,vllanmto
                                                ,nrseqdig
                                                ,cdcritic
                                                ,cdpesqbb
                                                ,tpintegr
                                                ,nrdctitg) -- Conta depositada
                                       VALUES   (pr_cdcooper
                                                ,pr_dtauxili
                                                ,nvl(nvl(vr_nrdconta_incorp,vr_nrdconta),0)
                                                ,nvl(vr_nrdocmto,0)
                                                ,nvl(vr_vllanmto,0)
                                                ,nvl(vr_nrseqarq,0)
                                                ,nvl(vr_cdcritic,0)
                                                ,nvl(vr_cdpesqbb,' ')
                                                ,nvl(vr_tpintegr,0)
                                                ,nvl(vr_nrctadep,0));
                          EXCEPTION
                            WHEN OTHERS THEN
                              vr_cdcritic:= 843;
                              vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                              vr_compl_erro:= ' Conta: ' || To_Char(gene0002.fn_mask_conta(nvl(vr_nrdconta_incorp,vr_nrdconta)))||
                                              ' Docmto: '|| To_Char(gene0002.fn_mask(vr_nrdocmto,'zzzz.zzz.9'))||
                                              ' Seq: '   || To_Char(gene0002.fn_mask(vr_nrseqarq,'zzzz.zz9'));
                              -- Envio centralizado de log de erro
                              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                                        ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                            || vr_cdprogra || ' --> '
                                                                            || vr_des_erro || vr_compl_erro);
                              RAISE vr_exc_erro;
                          END;
                        END IF;  --vr_cdcritic = 415
                        
                        --Executar rotina pc_cria_generica
                        pc_cria_generica(pr_cdcooper   => pr_cdcooper
                                        ,pr_cdagenci   => vr_tab_crapass(nvl(vr_nrdconta_incorp,vr_nrdconta)).cdagenci
                                        ,pr_dtmvtolt   => pr_dtmvtolt
                                        ,pr_cdcritic   => vr_cdcritic_aux
                                        ,pr_dtleiarq   => pr_dtleiarq
                                        ,pr_cdagectl   => pr_cdagectl
                                        ,pr_nmarquiv   => vr_vet_nmarquiv(idx)
                                        ,pr_cdbanchq   => vr_cdbanchq
                                        ,pr_cdagechq   => vr_cdagechq
                                        ,pr_nrctachq   => vr_nrctachq
                                        ,pr_nrdocmto   => vr_nrdocmto
                                        ,pr_cdcmpchq   => vr_cdcmpchq
                                        ,pr_vllanmto   => vr_vllanmto
                                        ,pr_nrdconta   => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                        ,pr_nrseqarq   => vr_nrseqarq
                                        ,pr_cdpesqbb   => vr_cdpesqbb
                                        ,pr_setlinha   => vr_compensacao(vr_indice).cdpesqbb
                                        ,pr_dscritic   => vr_des_erro);
                        --Verificar se retornou erro
                        IF vr_des_erro IS NOT NULL THEN
                          RAISE vr_exc_erro;
                        END IF;

                        --Inicializar variavel de erro
                        vr_cdcritic:= 0;
                        vr_cdcritic_aux:= 0;

                        --Ler proxima linha do arquivo
                        RAISE vr_exc_pula;
                      END IF; --vr_cdcritic = 97
                      
                      --Selecionar Custodias de Cheques  linha(1195)
                      OPEN cr_crapcst (pr_cdcooper => pr_cdcooper
                                      ,pr_cdcmpchq => rw_crapfdc.cdcmpchq
                                      ,pr_cdbanchq => rw_crapfdc.cdbanchq
                                      ,pr_cdagechq => rw_crapfdc.cdagechq
                                      ,pr_nrctachq => rw_crapfdc.nrctachq
                                      ,pr_nrcheque => rw_crapfdc.nrcheque
                                      ,pr_dtlibera => pr_dtmvtolt);
                      --Posicionar na primeira linha
                      FETCH cr_crapcst INTO rw_crapcst;
                      --Se encontrou custodia
                      IF cr_crapcst%FOUND THEN
                        IF rw_crapcst.insitchq IN (0,2) AND rw_crapcst.dtlibera > pr_dtmvtolt THEN
                          vr_cdcritic:= 757;
                          --Determinar proximo indice do vetor
                          vr_index_craprej:= LPad(pr_cdcooper,03,'0')||
                                             LPAD(vr_dtauxili,08,'0')||
                                             LPad(nvl(vr_nrdconta_incorp,vr_nrdconta),10,'0')||
                                             LPad(vr_nrdocmto,25,'0')||
                                             LPad(vr_vllanmto,25,'0')||
                                             lpad(vr_nrseqarq,10,'0')||
                                             LPad(vr_cdcritic,05,'0')||
                                             RPad(vr_cdpesqbb,200,'#');

                          --Inserir na tabela de memoria de rejeição
                          vr_tab_craprej(vr_index_craprej).cdcooper:= pr_cdcooper;
                          vr_tab_craprej(vr_index_craprej).dtrefere:= vr_dtauxili;
                          vr_tab_craprej(vr_index_craprej).nrdconta:= nvl(vr_nrdconta_incorp,vr_nrdconta);
                          vr_tab_craprej(vr_index_craprej).nrdocmto:= vr_nrdocmto;
                          vr_tab_craprej(vr_index_craprej).vllanmto:= vr_vllanmto;
                          vr_tab_craprej(vr_index_craprej).nrseqdig:= vr_nrseqarq;
                          vr_tab_craprej(vr_index_craprej).cdcritic:= vr_cdcritic;
                          vr_tab_craprej(vr_index_craprej).cdpesqbb:= vr_cdpesqbb;
                          vr_tab_craprej(vr_index_craprej).nrctadep:= to_char(vr_nrctadep);
                          --vr_tab_craprej(vr_index_craprej).dscritic:= 'Conta '||rw_crapcst.nrdconta;
                        END IF;
                      END IF;  --cr_crapcst%FOUND
                      --Fechar Cursor
                      CLOSE cr_crapcst;


                      --Selecionar Cheques Contidos do bordero de desconto de cheques
                      OPEN cr_crapcdb (pr_cdcooper => pr_cdcooper
                                      ,pr_cdcmpchq => rw_crapfdc.cdcmpchq
                                      ,pr_cdbanchq => rw_crapfdc.cdbanchq
                                      ,pr_cdagechq => rw_crapfdc.cdagechq
                                      ,pr_nrctachq => rw_crapfdc.nrctachq
                                      ,pr_nrcheque => rw_crapfdc.nrcheque
                                      ,pr_dtlibera => pr_dtmvtolt);
                      --Posicionar na primeira linha
                      FETCH cr_crapcdb INTO rw_crapcdb;
                      --Se encontrou custodia
                      IF cr_crapcdb%FOUND THEN
                        IF rw_crapcdb.insitchq IN (0,2) AND rw_crapcdb.dtlibera > pr_dtmvtolt THEN
                          vr_cdcritic:= 811;
                          --Determinar proximo indice do vetor
                          vr_index_craprej:= LPad(pr_cdcooper,03,'0')||
                                             LPAD(vr_dtauxili,08,'0')||
                                             LPad(nvl(vr_nrdconta_incorp,vr_nrdconta),10,'0')||
                                             LPad(vr_nrdocmto,25,'0')||
                                             LPad(vr_vllanmto,25,'0')||
                                             lpad(vr_nrseqarq,10,'0')||
                                             LPad(vr_cdcritic,05,'0')||
                                             RPad(vr_cdpesqbb,200,'#');

                          --Inserir na tabela de memoria de rejeição
                          vr_tab_craprej(vr_index_craprej).cdcooper:= pr_cdcooper;
                          vr_tab_craprej(vr_index_craprej).dtrefere:= vr_dtauxili;
                          vr_tab_craprej(vr_index_craprej).nrdconta:= nvl(vr_nrdconta_incorp,vr_nrdconta);
                          vr_tab_craprej(vr_index_craprej).nrdocmto:= vr_nrdocmto;
                          vr_tab_craprej(vr_index_craprej).vllanmto:= vr_vllanmto;
                          vr_tab_craprej(vr_index_craprej).nrseqdig:= vr_nrseqarq;
                          vr_tab_craprej(vr_index_craprej).cdcritic:= vr_cdcritic;
                          vr_tab_craprej(vr_index_craprej).cdpesqbb:= vr_cdpesqbb;
                          vr_tab_craprej(vr_index_craprej).nrctadep:= to_char(vr_nrctadep);
                          vr_tab_craprej(vr_index_craprej).dscritic:= 'Conta '||rw_crapcdb.nrdconta;
                        END IF;
                      END IF;
                      --Fechar cursor
                      CLOSE cr_crapcdb;

                      --Se ocorreu erro
                      IF vr_cdcritic > 0 THEN    --linha(1251)
                        IF vr_flctamig THEN
                          vr_tpintegr:= 1;
                        ELSE
                          vr_tpintegr:= 0;
                        END IF;

                        BEGIN
                          INSERT INTO craprej (cdcooper
                                              ,dtrefere
                                              ,nrdconta
                                              ,nrdocmto
                                              ,vllanmto
                                              ,nrseqdig
                                              ,cdcritic
                                              ,cdpesqbb
                                              ,tpintegr
                                              ,nrdctitg) -- Conta depositada
                                     VALUES   (pr_cdcooper
                                              ,pr_dtauxili
                                              ,nvl(nvl(vr_nrdconta_incorp,vr_nrdconta),0)
                                              ,nvl(vr_nrdocmto,0)
                                              ,nvl(vr_vllanmto,0)
                                              ,nvl(vr_nrseqarq,0)
                                              ,nvl(vr_cdcritic,0)
                                              ,nvl(vr_cdpesqbb,' ')
                                              ,nvl(vr_tpintegr,0)
                                              ,nvl(vr_nrctadep,0));
                        EXCEPTION
                          WHEN OTHERS THEN
                            vr_cdcritic:= 843;
                            vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                            vr_compl_erro:= ' Seq: '||To_Char(gene0002.fn_mask(vr_nrseqarq,'zzzz.zz9'));
                            -- Envio centralizado de log de erro
                            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                          || vr_cdprogra || ' --> '
                                                                          || vr_des_erro || vr_compl_erro
                                                                          || vr_dados_log);
                            RAISE vr_exc_erro;
                        END;

                        IF vr_cdcritic IN (96,257,414,439,950) THEN
                          --Guardar valor da critica em variavel auxiliar
                          vr_cdcritic_aux:= vr_cdcritic;
                          vr_cdcritic:= 0;
                          vr_nrdctitg:= To_Char(nvl(vr_nrdconta_incorp,vr_nrdconta),'FM00000000');

                          /*  Se for devolucao de cheque verifica o indicador de historico da contra-ordem.
                              Se for 2, alimenta aux_cdalinea com 28 para nao gerar taxa de devolucao */
                          IF vr_indevchq IN (1,3) AND vr_cdalinea = 0  THEN
                            --Selecionar Contra-Ordens
                            OPEN cr_crapcor (pr_cdcooper => pr_cdcooper
                                            ,pr_cdbanchq => nvl(vr_cdbcoctl_incorp,pr_cdbcoctl)
                                            ,pr_cdagechq => nvl(vr_cdagectl_incorp,pr_cdagectl)
                                            ,pr_nrctachq => NULL
                                            -- buscar pela conta abb a mesma informação de conta vinda no arquivo
                                            ,pr_nrdctabb => vr_nrdconta --> nvl(vr_nrdconta_incorp,vr_nrdconta)
                                            ,pr_nrcheque => vr_nrdocmto
                                            ,pr_flgativo => 1);
                            --Posicionar no proximo registro
                            FETCH cr_crapcor INTO rw_crapcor;
                            --Se nao encontrou
                            IF cr_crapcor%NOTFOUND THEN
                              --Fechar Cursor
                              CLOSE cr_crapcor;

                              vr_cdcritic:= 179;
                              vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                              --Complementar a mensagem de erro
                              vr_compl_erro:= ' Conta: ' || To_Char(gene0002.fn_mask_conta(nvl(vr_nrdconta_incorp,vr_nrdconta)))||
                                              ' Docmto: '|| To_Char(gene0002.fn_mask(vr_nrdocmto,'zzzz.zzz.9'))||
                                              ' Seq: '   || To_Char(gene0002.fn_mask(vr_nrseqarq,'zzzz.zz9'));
                              -- Envio centralizado de log de erro
                              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                         || vr_cdprogra || ' --> '
                                                                         || vr_des_erro || vr_compl_erro);
                              --Inserir registro na tabela de rejeicao
                              BEGIN
                                --Se for conta migrada
                                IF vr_flctamig THEN
                                  vr_tpintegr:= 1;
                                ELSE
                                  vr_tpintegr:= 0;
                                END IF;

                                INSERT INTO craprej (cdcooper
                                                    ,dtrefere
                                                    ,nrdconta
                                                    ,nrdocmto
                                                    ,vllanmto
                                                    ,nrseqdig
                                                    ,cdcritic
                                                    ,cdpesqbb
                                                    ,tpintegr
                                                    ,nrdctitg) -- Conta depositada
                                           VALUES   (pr_cdcooper
                                                    ,pr_dtauxili
                                                    ,nvl(nvl(vr_nrdconta_incorp,vr_nrdconta),0)
                                                    ,nvl(vr_nrdocmto,0)
                                                    ,nvl(vr_vllanmto,0)
                                                    ,nvl(vr_nrseqarq,0)
                                                    ,nvl(vr_cdcritic,0)
                                                    ,nvl(vr_cdpesqbb,' ')
                                                    ,nvl(vr_tpintegr,0)
                                                    ,nvl(vr_nrctadep,0));
                              EXCEPTION
                                WHEN OTHERS THEN
                                  vr_cdcritic:= 843;
                                  vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                                  -- Envio centralizado de log de erro
                                  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                                || vr_cdprogra || ' --> '
                                                                                || vr_des_erro
                                                                                || vr_dados_log );
                                  --Levantar Excecao
                                  RAISE vr_exc_erro;
                              END;
                              --Desfazer alteracoes no banco e ir para proxima linha
                              RAISE vr_exc_undo;
                            ELSE --Encontrou crapcor
                              --Fechar Cursor
                              CLOSE cr_crapcor;

                              /* Contra Ordem Provisoria */
                              IF rw_crapcor.dtvalcor >= pr_dtmvtolt AND rw_crapcor.dtvalcor IS NOT NULL  THEN
                                vr_cdalinea:= 70;
                              ELSIF rw_crapcor.cdhistor = 835 THEN
                                vr_cdalinea:= 28;
                              ELSIF rw_crapcor.cdhistor = 818 THEN
                                vr_cdalinea:= 20;
                              ELSIF rw_crapcor.cdhistor = 815 THEN
                                vr_cdalinea:= 21;
                              ELSE
                                vr_cdalinea:= 21;
                              END IF;
                            END IF; --cr_crapcor%NOTFOUND
                            --Fechar Cursor
                            IF cr_crapcor%ISOPEN THEN
                              CLOSE cr_crapcor;
                            END IF;
                          END IF;


                          IF vr_indevchq > 0  THEN
                            --Selecionar Transferencias entre cooperativas
                            OPEN cr_craptco (pr_cdcopant => pr_cdcooper
                                            ,pr_nrctaant => vr_nrdconta
                                            ,pr_tpctatrf => 1
                                            ,pr_flgativo => 1);
                            --Posicionar no proximo registro
                            FETCH cr_craptco INTO rw_craptco;
                            --Se Encontrou registros
                            IF cr_craptco%FOUND THEN
                              --Fechar Cursor
                              CLOSE cr_craptco;
                              --Executar rotina
                              pc_cria_dev(pr_cdcooper => rw_craptco.cdcopant
                                         ,pr_dtmvtopr => (CASE pr_nmtelant
                                                            WHEN 'COMPEFORA' THEN
                                                                 pr_dtmvtolt
                                                            ELSE PR_dtmvtopr
                                                          END)
                                         ,pr_cdbccxlt => pr_cdbcoctl
                                         ,pr_inchqdev => vr_indevchq
                                         ,pr_nrctaant => rw_craptco.nrctaant
                                         ,pr_nrdconta => rw_craptco.nrdconta
                                         ,pr_nrdocmto => vr_nrdocmto
                                         ,pr_nrdctitg => NULL
                                         ,pr_vllanmto => vr_vllanmto
                                         ,pr_cdalinea => vr_cdalinea
                                         ,pr_cdhistor => (CASE rw_crapfdc.tpcheque
                                                            WHEN 1 THEN 573
                                                            ELSE 78
                                                          END)
                                         ,pr_cdoperad => '1'
                                         ,pr_cdagechq => pr_cdagectl
                                         ,pr_nrctachq => vr_nrdctabb
                                         ,pr_cdbandep => vr_cdbandep
                                         ,pr_cdagedep => vr_cdagedep
                                         ,pr_nrctadep => vr_nrctadep
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_des_erro);


                              IF vr_des_erro IS NOT NULL THEN
                                --Fechar Cursor
                                IF cr_craptco%ISOPEN THEN
                                  CLOSE cr_craptco;
                                END IF;
                                -- Envio centralizado de log de erro
                                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                              || vr_cdprogra || ' --> '
                                                                              || vr_des_erro
                                                                              || vr_dados_log );
                                --Levantar Excecao
                                RAISE vr_exc_erro;
                              END IF;
                            ELSE --cr_craptco%FOUND
                              --Fechar Cursor
                              CLOSE cr_craptco;

                              IF  vr_cdalinea = 21 THEN
                                /* Se ja existir devolucao com a alinea 21, devolver com a alinea 43 */
                                --Selecionar os lancamentos
                                OPEN cr_craplcm2 (pr_cdcooper => pr_cdcooper
                                                 ,pr_nrdconta => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                                 ,pr_nrdocmto => vr_nrdocmto);
                                --Posicionar no proximo registro
                                FETCH cr_craplcm2 INTO rw_craplcm2;
                                --Se encontrou registro
                                IF cr_craplcm2%FOUND THEN
                                  vr_cdalinea:= 43;
                                END IF;
                                --Fechar cursor
                                CLOSE cr_craplcm2;
                              END IF;
                              
                              -- PRB0040576
                              IF  vr_cdalinea = 28 THEN
                                /* Se ja existir devolucao com a alinea 28, devolver com a alinea 49 */
                                --Selecionar os lancamentos
                                OPEN cr_craplcm_ali28 (pr_cdcooper => pr_cdcooper
                                                 ,pr_nrdconta => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                                 ,pr_nrdocmto => vr_nrdocmto);
                                --Posicionar no proximo registro
                                FETCH cr_craplcm_ali28 INTO rw_cr_craplcm_ali28;
                                --Se encontrou registro
                                IF cr_craplcm_ali28%FOUND THEN
                                  vr_cdalinea:= 49;
                                END IF;
                                --Fechar cursor
                                CLOSE cr_craplcm_ali28;
                              END IF;

							                -- INC0011272
                              IF  vr_cdalinea = 20 THEN
                                /* Se ja existir devolucao com a alinea 20, devolver com a alinea 49 */
                                --Selecionar os lancamentos
                                OPEN cr_craplcm_ali20 (pr_cdcooper => pr_cdcooper
                                                      ,pr_nrdconta => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                                      ,pr_nrdocmto => vr_nrdocmto);
                                --Posicionar no proximo registro
                                FETCH cr_craplcm_ali20 INTO rw_cr_craplcm_ali20;
                                --Se encontrou registro
                                IF cr_craplcm_ali20%FOUND THEN
                                  vr_cdalinea:= 49;
                                END IF;
                                --Fechar cursor
                                CLOSE cr_craplcm_ali20;
                              END IF;

                              --Executar rotina para criar registros de devolucao/taxa de cheques.
                              cheq0001.pc_gera_devolucao_cheque (pr_cdcooper => pr_cdcooper
                                                                ,pr_dtmvtolt => pr_dtmvtolt
                                                                ,pr_cdbccxlt => pr_cdbcoctl
                                                                ,pr_cdbcoctl => pr_cdbcoctl
                                                                ,pr_inchqdev => vr_indevchq
                                                                ,pr_nrdconta => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                                                ,pr_nrdocmto => vr_nrdocmto
                                                                ,pr_nrdctitg => vr_nrdctitg
                                                                ,pr_vllanmto => vr_vllanmto
                                                                ,pr_cdalinea => vr_cdalinea
                                                                ,pr_cdhistor => (CASE rw_crapfdc.tpcheque
                                                                                   WHEN 1 THEN 573
                                                                                   ELSE 78
                                                                                 END)
                                                                ,pr_cdoperad => '1'
                                                                ,pr_cdagechq => nvl(vr_cdagectl_incorp,pr_cdagectl)
                                                                ,pr_nrctachq => vr_nrdctabb
                                                                ,pr_cdprogra => pr_cdprogra
                                                                ,pr_nrdrecid => 0
                                                                ,pr_vlchqvlb => pr_vlchqvlb
                                                                ,pr_insitdev => 2 
                                                                ,pr_cdbandep => vr_cdbandep
                                                                ,pr_cdagedep => vr_cdagedep
                                                                ,pr_nrctadep => vr_nrctadep
                                                                ,pr_cdcritic => vr_cdcritic
                                                                ,pr_des_erro => vr_des_erro);


                              IF vr_des_erro IS NOT NULL THEN
                                -- Envio centralizado de log de erro
                                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                              || vr_cdprogra || ' --> '
                                                                              || vr_des_erro 
                                                                              || vr_dados_log);
                                RAISE vr_exc_erro;
                              END IF;

                              --Se ocorreu Erro
                              IF vr_cdcritic > 0 THEN
                                -- Se a descrição do erro estiver vazia, buscar a descrição do código do erro
                                IF TRIM(vr_des_erro) IS NULL THEN
                                  vr_des_erro:= gene0001.fn_busca_critica(vr_cdcritic);
                                END IF;
                              
                                --Complementar a mensagem de erro
                                vr_compl_erro:= ' Conta: ' || To_Char(gene0002.fn_mask_conta(nvl(vr_nrdconta_incorp,vr_nrdconta)))||
                                                ' Docmto: '|| To_Char(gene0002.fn_mask(vr_nrdocmto,'zzzz.zzz.9'))||
                                                ' Seq: '   || To_Char(gene0002.fn_mask(vr_nrseqarq,'zzzz.zz9'));
                                -- Envio centralizado de log de erro
                                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                                          ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                                          ,pr_des_log      => to_char(sysdate,'DD/MM/YYYY hh24:mi:ss')||' - '
                                                                              || vr_cdprogra || ' --> '
                                                                              || vr_des_erro || vr_compl_erro);

                                IF vr_cdcritic <> 415 THEN
                                  /* Critica 415 refere-se a uma tentativa de criar uma devolucao de cheque onde ja
                                   existe uma devolucao ja criada. Prevalece a 1a devolucao - criada - Trf. 23315  */

                                  --Executar rotina pc_cria_generica
                                  pc_cria_generica(pr_cdcooper   => pr_cdcooper
                                                  ,pr_cdagenci   => vr_tab_crapass(nvl(vr_nrdconta_incorp,vr_nrdconta)).cdagenci
                                                  ,pr_dtmvtolt   => pr_dtmvtolt
                                                  ,pr_cdcritic   => vr_cdcritic
                                                  ,pr_dtleiarq   => pr_dtleiarq
                                                  ,pr_cdagectl   => pr_cdagectl
                                                  ,pr_nmarquiv   => vr_vet_nmarquiv(idx)
                                                  ,pr_cdbanchq   => vr_cdbanchq
                                                  ,pr_cdagechq   => vr_cdagechq
                                                  ,pr_nrctachq   => vr_nrctachq
                                                  ,pr_nrdocmto   => vr_nrdocmto
                                                  ,pr_cdcmpchq   => vr_cdcmpchq
                                                  ,pr_vllanmto   => vr_vllanmto
                                                  ,pr_nrdconta   => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                                  ,pr_nrseqarq   => vr_nrseqarq
                                                  ,pr_cdpesqbb   => vr_cdpesqbb
                                                  ,pr_setlinha   => vr_compensacao(vr_indice).cdpesqbb
                                                  ,pr_dscritic   => vr_des_erro);


                                  --Verificar se retornou erro
                                  IF vr_des_erro IS NOT NULL THEN
                                    -- Envio centralizado de log de erro
                                    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                                  || vr_cdprogra || ' --> '
                                                                                  || vr_des_erro 
                                                                                  || vr_dados_log);
                                  END IF;

                                  --Verificar se o cursor está aberto
                                  IF cr_craptco%ISOPEN THEN
                                    --Fechar Cursor
                                    CLOSE cr_craptco;
                                  END IF;

                                  --Pular para proximo registro
                                  RAISE vr_exc_pula;
                                ELSE --vr_cdcritic <> 415

                                  IF vr_flctamig THEN
                                    vr_tpintegr:= 1;
                                  ELSE
                                    vr_tpintegr:= 0;
                                  END IF;

                                  --Inserir registro na tabela de rejeicao
                                  BEGIN
                                    INSERT INTO craprej (cdcooper
                                                        ,dtrefere
                                                        ,nrdconta
                                                        ,nrdocmto
                                                        ,vllanmto
                                                        ,nrseqdig
                                                        ,cdcritic
                                                        ,cdpesqbb
                                                        ,tpintegr
                                                        ,nrdctitg) -- Conta depositada
                                               VALUES   (pr_cdcooper
                                                        ,pr_dtauxili
                                                        ,nvl(nvl(vr_nrdconta_incorp,vr_nrdconta),0)
                                                        ,nvl(vr_nrdocmto,0)
                                                        ,nvl(vr_vllanmto,0)
                                                        ,nvl(vr_nrseqarq,0)
                                                        ,nvl(vr_cdcritic,0)
                                                        ,nvl(vr_cdpesqbb,' ')
                                                        ,nvl(vr_tpintegr,0)
                                                        ,nvl(vr_nrctadep,0));
                                  EXCEPTION
                                    WHEN OTHERS THEN
                                      vr_cdcritic:= 843;
                                      vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                                      -- Envio centralizado de log de erro
                                      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                                    || vr_cdprogra || ' --> '
                                                                                    || vr_des_erro 
                                                                                    || vr_dados_log);
                                      RAISE vr_exc_erro;
                                  END;
                                  vr_cdcritic:= 0;
                                END IF;  --vr_cdcritic <> 415
                              END IF;  --vr_cdcritic > 0
                            END IF; --cr_craptco%FOUND
                            --Fechar Cursor
                            IF cr_craptco%ISOPEN THEN
                              CLOSE cr_craptco;
                            END IF;
                          END IF;  --vr_indevchq > 0  THEN
                        ELSE
                          --Executar rotina pc_cria_generica
                          pc_cria_generica(pr_cdcooper   => pr_cdcooper
                                          ,pr_cdagenci   => vr_tab_crapass(nvl(vr_nrdconta_incorp,vr_nrdconta)).cdagenci
                                          ,pr_dtmvtolt   => pr_dtmvtolt
                                          ,pr_cdcritic   => vr_cdcritic
                                          ,pr_dtleiarq   => pr_dtleiarq
                                          ,pr_cdagectl   => pr_cdagectl
                                          ,pr_nmarquiv   => vr_vet_nmarquiv(idx)
                                          ,pr_cdbanchq   => vr_cdbanchq
                                          ,pr_cdagechq   => vr_cdagechq
                                          ,pr_nrctachq   => vr_nrctachq
                                          ,pr_nrdocmto   => vr_nrdocmto
                                          ,pr_cdcmpchq   => vr_cdcmpchq
                                          ,pr_vllanmto   => vr_vllanmto
                                          ,pr_nrdconta   => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                          ,pr_nrseqarq   => vr_nrseqarq
                                          ,pr_cdpesqbb   => vr_cdpesqbb
                                          ,pr_setlinha   => vr_compensacao(vr_indice).cdpesqbb
                                          ,pr_dscritic   => vr_des_erro);


                          --Verificar se retornou erro
                          IF vr_des_erro IS NOT NULL THEN
                            -- Envio centralizado de log de erro
                            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                          || vr_cdprogra || ' --> '
                                                                          || vr_des_erro 
                                                                          || vr_dados_log);
                            RAISE vr_exc_erro;
                          END IF;

                          --Pular para proxima linha do arquivo
                          RAISE vr_exc_pula;
                        END IF; --vr_cdcritic IN (96,257,414,439,950)
                      END IF; --vr_cdcritic > 0

                      -- Se não tiver critica
                      IF vr_cdcritic = 0 AND 
                         vr_cdcritic_aux = 0 THEN                        
                      
                        IF cr_tbchq_param_conta%ISOPEN THEN
                          CLOSE cr_tbchq_param_conta;  
                        END IF;                         
                        
                        OPEN cr_tbchq_param_conta(pr_cdcooper => vr_cdcooper
                                                 ,pr_nrdconta => nvl(vr_nrdconta_incorp,vr_nrdconta));
                        FETCH cr_tbchq_param_conta INTO rw_tbchq_param_conta;                                      
                          
                        -- Caso encontre registro de devolucao automatica  
                        IF cr_tbchq_param_conta%FOUND THEN
                          -- se for devolucao automatica
                          IF rw_tbchq_param_conta.flgdevolu_autom = 1 THEN

                            --INC0027476
                            vr_dsparame := ' vr_cdcooper:'||vr_cdcooper
                                           ||', cdagenci:'||vr_tab_crapass(nvl(vr_nrdconta_incorp,vr_nrdconta)).cdagenci
                                           ||', nrdconta:'||nvl(vr_nrdconta_incorp,vr_nrdconta)
                                           ||', vllimcre:'||vr_tab_crapass(nvl(vr_nrdconta_incorp,vr_nrdconta)).vllimcre
                                           ||', dtrefere:'||pr_dtmvtolt;

                            extr0001.pc_obtem_saldo_dia(pr_cdcooper => vr_cdcooper, 
                                                        pr_rw_crapdat => rw_crapdat, 
                                                        pr_cdagenci => vr_tab_crapass(nvl(vr_nrdconta_incorp,vr_nrdconta)).cdagenci, 
                                                        pr_nrdcaixa => 0, 
                                                        pr_cdoperad => '1', 
                                                        pr_nrdconta => nvl(vr_nrdconta_incorp,vr_nrdconta), 
                                                        pr_vllimcre => vr_tab_crapass(nvl(vr_nrdconta_incorp,vr_nrdconta)).vllimcre, 
                                                        pr_dtrefere => pr_dtmvtolt, 
                                                        pr_flgcrass => FALSE, 
                                                        pr_tipo_busca => 'A', -- Tipo Busca(A-dtmvtoan)
                                                        pr_des_reto => vr_dscritic, 
                                                        pr_tab_sald => vr_tab_saldo, 
                                                        pr_tab_erro => vr_tab_erro);
                                                            
                            --Se ocorreu erro
                            IF vr_dscritic = 'NOK' THEN
                              -- Tenta buscar o erro no vetor de erro
                              IF vr_tab_erro.COUNT > 0 THEN
                                vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||nvl(vr_nrdconta_incorp,vr_nrdconta);
                              ELSE
                                vr_cdcritic:= 0;
                                vr_dscritic:= 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informação na pr_tab_erro, Conta: '||nvl(vr_nrdconta_incorp,vr_nrdconta);
                              END IF;
                              
                              IF vr_cdcritic <> 0 THEN
                                vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' Conta: '||nvl(vr_nrdconta_incorp,vr_nrdconta);
                              ELSE
                                vr_des_erro := vr_dscritic;
                              END IF;                              

                              --Levantar Excecao
                              RAISE vr_exc_erro;
                            ELSE
                              vr_dscritic:= NULL;
                            END IF;
                            --Verificar o saldo retornado
                            IF vr_tab_saldo.Count = 0 THEN
                              --Montar mensagem erro
                              vr_cdcritic:= 0;
                              vr_dscritic:= 'Nao foi possivel consultar o saldo para a operacao.';
                              vr_des_erro := vr_dscritic;
                              vr_compl_erro:= ' Conta: ' || To_Char(gene0002.fn_mask_conta(nvl(vr_nrdconta_incorp,vr_nrdconta)))||
                                              ' Docmto: '|| To_Char(gene0002.fn_mask(vr_nrdocmto,'zzzz.zzz.9'))||
                                              ' Seq: '   || To_Char(gene0002.fn_mask(vr_nrseqarq,'zzzz.zz9'));                              
                              --Levantar Excecao
                              RAISE vr_exc_erro;
                            ELSE
                              vr_vlsddisp := nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                                             nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0);
                            END IF; 
                            
                            --INC0027476
                            vr_dsparame := vr_dsparame||', Retorno: dtmvtolt:'||vr_tab_saldo(vr_tab_saldo.FIRST).dtmvtolt
                                           ||', vlsddisp:'||nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0)
                                           ||', vllimcre:'||nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0)
                                           ||', vlsdbloq:'||nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsdbloq,0)
                                           ||', vllimutl:'||nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimutl,0)
                                           ||', vlblqjud:'||nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlblqjud,0);
                            
                            /*considerar cheques que terao o valor desbloqueado 
                              no dia seguinte como parte do saldo*/
                            vr_vldeplib := 0;
                              
                            FOR rw_crapdpb IN cr_crapdpb(pr_cdcooper => vr_cdcooper
                                                        ,pr_nrdconta => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                                        ,pr_dtlibban => pr_dtmvtolt) LOOP
                              vr_vldeplib := nvl(vr_vldeplib,0) + nvl(rw_crapdpb.vllanmto,0);
                            END LOOP;
                            
                            vr_vlsddisp := nvl(vr_vlsddisp,0) + nvl(vr_vldeplib,0);                            
                            
                            --INC0027476
                            vr_dsparame := vr_dsparame||', vldeplib:'||nvl(vr_vldeplib,0)
                                           ||', vlsddisp Final:'||vr_vlsddisp;
                            
                            -- Caso o saldo seja insuficiente
                            IF vr_vllanmto > vr_vlsddisp THEN
                               
                              IF rw_crapfdc.tpcheque= 1 THEN
                                vr_indevchq := 1;
                              ELSE
                                vr_indevchq := 3;                                
                              END IF;
                            
                              vr_cdcritic := 717; -- Não há saldo suficiente para operação

                              --Grava tabela de log para acompanhamento do cálculo
                              --INC0027476
                              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||vr_dsparame;
                              --
                              BEGIN         
                                CECRED.pc_log_programa(pr_dstiplog      => 'O', 
                                                       pr_cdcooper      => pr_cdcooper, 
                                                       pr_tpocorrencia  => 4, 
                                                       pr_cdprograma    => vr_cdprogra, 
                                                       pr_tpexecucao    => 1, --cadeia
                                                       pr_cdcriticidade => 0,
                                                       pr_cdmensagem    => vr_cdcritic,    
                                                       pr_dsmensagem    => vr_dscritic,               
                                                       pr_idprglog      => vr_idprglog,
                                                       pr_nmarqlog      => NULL);
                              EXCEPTION
                                WHEN OTHERS THEN
                                  CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
                              END;
                              vr_dscritic := NULL;
                              --

                              vr_cdcritic_aux := vr_cdcritic;
                              vr_cdcritic := 0;
                              
                              /***********************************************************
                              **************** ALINEA DE DEVOLUÇÃO ***********************
                              ***********************************************************/
                              
                              IF cr_crapneg_2%ISOPEN THEN
                                CLOSE cr_crapneg_2;  
                              END IF;  
                              -- Verificar se existe alineas ja devolvidas
                              OPEN cr_crapneg_2(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                               ,pr_nrdocmto => nvl(vr_nrdocmto,0));
                              FETCH cr_crapneg_2 INTO rw_crapneg_2;                                      
                                    
                              -- Caso houver alguma alinea devolvida
                              IF cr_crapneg_2%FOUND THEN
                                CLOSE cr_crapneg_2;        
                                
                                IF cr_crapneg_reg%ISOPEN THEN
                                  CLOSE cr_crapneg_reg;  
                                END IF;  
                                    
                                OPEN cr_crapneg_reg(pr_cdcooper => pr_cdcooper
                                                   ,pr_nrdconta => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                                   ,pr_nrdocmto => nvl(vr_nrdocmto,0)
                                                   ,pr_cdobserv => 12);
                                FETCH cr_crapneg_reg INTO rw_crapneg_reg;                                      
                                  
                                -- Caso encontre registro de devolucao automatica com alinea 12
                                IF cr_crapneg_reg%FOUND THEN
                                  CLOSE cr_crapneg_reg;  
                                  vr_cdalinea := 49;
                                ELSE 
                                  CLOSE cr_crapneg_reg;  
                                  OPEN cr_crapneg_reg(pr_cdcooper => pr_cdcooper
                                                     ,pr_nrdconta => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                                     ,pr_nrdocmto => nvl(vr_nrdocmto,0)
                                                     ,pr_cdobserv => 11);
                                  FETCH cr_crapneg_reg INTO rw_crapneg_reg;                                      
                                    
                                  -- Caso encontre registro de devolucao automatica com alinea 11
                                  IF cr_crapneg_reg%FOUND THEN
                                    CLOSE cr_crapneg_reg;  
                                  vr_cdalinea := 12;
                                ELSE
                                   CLOSE cr_crapneg_reg;  
                                  vr_cdalinea := 49;
                                END IF;
                                END IF;
                              ELSE
                                CLOSE cr_crapneg_2;  
                                vr_cdalinea:= 11;
                              END IF;
                              
                              IF vr_flctamig THEN
                                vr_tpintegr:= 1;
                              ELSE
                                vr_tpintegr:= 0;
                              END IF;

                              /***********************************************************
                              **************** GRAVAR INFORMAÇÕES NO CRRL526 *************
                              ***********************************************************/
                              
                              --Inserir registro na tabela de rejeicao
                              BEGIN
                                INSERT INTO craprej (cdcooper
                                                    ,dtrefere
                                                    ,nrdconta
                                                    ,nrdocmto
                                                    ,vllanmto
                                                    ,nrseqdig
                                                    ,cdcritic
                                                    ,cdpesqbb
                                                    ,tpintegr
                                                    ,nrdctitg) -- Conta depositada
                                           VALUES   (pr_cdcooper
                                                    ,pr_dtauxili
                                                    ,nvl(nvl(vr_nrdconta_incorp,vr_nrdconta),0)
                                                    ,nvl(vr_nrdocmto,0)
                                                    ,nvl(vr_vllanmto,0)
                                                    ,nvl(vr_nrseqarq,0)
                                                    ,nvl(vr_cdcritic_aux,0)
                                                    ,nvl(vr_cdpesqbb,' ')
                                                    ,nvl(vr_tpintegr,0)
                                                    ,nvl(vr_nrctadep,0));
                              EXCEPTION
                                WHEN OTHERS THEN
                                  vr_cdcritic:= 843;
                                  vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                                  vr_compl_erro:= ' Conta: ' || To_Char(gene0002.fn_mask_conta(nvl(vr_nrdconta_incorp,vr_nrdconta)))||
                                                  ' Docmto: '|| To_Char(gene0002.fn_mask(vr_nrdocmto,'zzzz.zzz.9'))||
                                                  ' Seq: '   || To_Char(gene0002.fn_mask(vr_nrseqarq,'zzzz.zz9'));
                                  
                                  -- Envio centralizado de log de erro
                                  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                                            ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                                || vr_cdprogra || ' --> '
                                                                                || vr_des_erro || vr_compl_erro);
                                  RAISE vr_exc_erro;
                              END;
                              
                              /***********************************************************
                              ************************* DEVOLUÇÃO ************************
                              ***********************************************************/
                              
                              --Executar rotina para criar registros de devolucao/taxa de cheques.
                              cheq0001.pc_gera_devolucao_cheque (pr_cdcooper => pr_cdcooper
                                                                ,pr_dtmvtolt => pr_dtmvtolt
                                                                ,pr_cdbccxlt => pr_cdbcoctl
                                                                ,pr_cdbcoctl => pr_cdbcoctl
                                                                ,pr_inchqdev => vr_indevchq
                                                                ,pr_nrdconta => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                                                ,pr_nrdocmto => vr_nrdocmto
                                                                ,pr_nrdctitg => vr_nrdctitg
                                                                ,pr_vllanmto => vr_vllanmto
                                                                ,pr_cdalinea => vr_cdalinea
                                                                ,pr_cdhistor => (CASE rw_crapfdc.tpcheque
                                                                                   WHEN 1 THEN 47
                                                                                   ELSE 78
                                                                                 END)
                                                                ,pr_cdoperad => '1'
                                                                ,pr_cdagechq => nvl(vr_cdagectl_incorp,pr_cdagectl)
                                                                ,pr_nrctachq => vr_nrdctabb
                                                                ,pr_cdprogra => pr_cdprogra
                                                                ,pr_nrdrecid => 0
                                                                ,pr_vlchqvlb => pr_vlchqvlb
                                                                ,pr_cdbandep => vr_cdbandep
                                                                ,pr_cdagedep => vr_cdagedep
                                                                ,pr_nrctadep => vr_nrctadep                                                                                                                                
                                                                ,pr_cdcritic => vr_cdcritic
                                                                ,pr_des_erro => vr_des_erro);

                              IF vr_des_erro IS NOT NULL THEN                             
                              
                                --Complementar a mensagem de erro
                                vr_compl_erro:= ' Conta: ' || To_Char(gene0002.fn_mask_conta(nvl(vr_nrdconta_incorp,vr_nrdconta)))||
                                                ' Docmto: '|| To_Char(gene0002.fn_mask(vr_nrdocmto,'zzzz.zzz.9'))||
                                                ' Seq: '   || To_Char(gene0002.fn_mask(vr_nrseqarq,'zzzz.zz9'));

                                -- Envio centralizado de log de erro
                                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                                          ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                              || vr_cdprogra || ' --> '
                                                                              || vr_des_erro || vr_compl_erro);
                                
                                RAISE vr_exc_erro;
                              END IF;
                              
                              vr_cdcritic := 0;
                              vr_cdcritic_aux := 0;
                              
                            END IF;                            
                          END IF; -- Fim do flgdevolu_autom
                        END IF; -- fim da verificacao critica
                      END IF; -- Fim do cr_tbchq_param_conta
                      
                      -- Se não for um arquivo de incorporação
                      IF vr_cdcooper_incorp IS NULL THEN
                        --Se for Viacredi ou Creditextil
                        IF pr_cdcooper IN (1,2) THEN
                          --Selecionar Transferencias entre cooperativas
                          OPEN cr_craptco (pr_cdcopant => pr_cdcooper
                                          ,pr_nrctaant => vr_nrdconta
                                          ,pr_tpctatrf => 1
                                          ,pr_flgativo => 1);
                          --Posicionar no proximo registro
                          FETCH cr_craptco INTO rw_craptco;
                          --Se Encontrou registros
                          IF cr_craptco%FOUND THEN
                            --Fechar Cursor
                            CLOSE cr_craptco;

                            IF vr_flctamig THEN
                              vr_tpintegr:= 1;
                            ELSE
                              vr_tpintegr:= 0;
                            END IF;

                            --Inserir registro na tabela de rejeicao
                            BEGIN
                              INSERT INTO craprej (cdcooper
                                                  ,dtrefere
                                                  ,nrdconta
                                                  ,nrdocmto
                                                  ,vllanmto
                                                  ,nrseqdig
                                                  ,cdcritic
                                                  ,cdpesqbb
                                                  ,tpintegr
                                                  ,nrdctitg) -- Conta depositada
                                         VALUES   (pr_cdcooper
                                                  ,pr_dtauxili
                                                  ,nvl(vr_nrdconta,0)
                                                  ,nvl(vr_nrdocmto,0)
                                                  ,nvl(vr_vllanmto,0)
                                                  ,nvl(vr_nrseqarq,0)
                                                  ,999
                                                  ,nvl(vr_cdpesqbb,' ')
                                                  ,nvl(vr_tpintegr,0)
                                                  ,nvl(vr_nrctadep,0));
                            EXCEPTION
                              WHEN OTHERS THEN
                                vr_cdcritic:= 843;
                                vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                                -- Envio centralizado de log de erro
                                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                            || vr_cdprogra || ' --> '
                                                                            || vr_des_erro 
                                                                            || vr_dados_log);
                                --Fechar Cursor
                                CLOSE cr_craptco;
                                --Levantar Exceção
                                RAISE vr_exc_erro;
                            END;

                            --Executar rotina
                            pc_cria_cheques_tco(pr_cdcooper => rw_craptco.cdcooper
                                               ,pr_nrdconta => rw_craptco.nrdconta
                                               ,pr_nrdctabb => rw_craptco.nrdconta
                                               ,pr_cdagenci => pr_cdagenci
                                               ,pr_cdbccxlt => pr_cdbccxlt
                                               ,pr_tplotmov => pr_tplotmov
                                               ,pr_nrdocmto => vr_nrdocsdg
                                               ,pr_cdbanchq => vr_cdbanchq
                                               ,pr_nrlotchq => vr_nrlotchq
                                               ,pr_sqlotchq => vr_sqlotchq
                                               ,pr_cdcmpchq => vr_cdcmpchq
                                               ,pr_cdagechq => vr_cdagechq
                                               ,pr_nrctachq => vr_nrctachq
                                               ,pr_cdtpddoc => vr_cdtpddoc
                                               ,pr_vllanmto => vr_vllanmto
                                               ,pr_nrseqarq => vr_nrseqarq
                                               ,pr_cdpesqbb => vr_cdpesqbb
                                               ,pr_cdbandep => vr_cdbandep
                                               ,pr_cdcmpdep => vr_cdcmpdep
                                               ,pr_cdagedep => vr_cdagedep
                                               ,pr_nrctadep => vr_nrctadep
                                               ,pr_setlinha => vr_compensacao(vr_indice).cdpesqbb
                                               ,pr_tpcheque => rw_crapfdc.tpcheque
                                               ,pr_dscritic => vr_des_erro);

                            --Verificar se retornou erro
                            IF vr_des_erro IS NOT NULL THEN
                              -- Envio centralizado de log de erro
                              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                            || vr_cdprogra || ' --> '
                                                                            || vr_des_erro 
                                                                            || vr_dados_log);

                              --Fechar Cursor
                              IF cr_craptco%ISOPEN THEN
                                CLOSE cr_craptco;
                              END IF;
                              --levantar Exceção
                              RAISE vr_exc_erro;
                            END IF;
                            --Pular para proxima linha arquivo
                            RAISE vr_exc_pula;
                          END IF; --cr_craptco%FOUND
                          --Fechar Cursor
                          IF cr_craptco%ISOPEN THEN
                            CLOSE cr_craptco;
                          END IF;
                        END IF; --Se for cooperativa 2
                      END IF;

                      --Verificar se é o primeiro
                      IF vr_flgfirst THEN    --linha(1594)

                        --Verificar se existe um lote de banco
                        IF vr_numlotebco IS NULL THEN
                          --Montar mensagem erro
                          vr_cdcritic:= 472;
                          vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          vr_compl_erro:= 'Executando rollback.';
                          -- Envio centralizado de log de erro
                          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                      || vr_cdprogra || ' --> '
                                                                      || vr_des_erro || ' '|| vr_compl_erro
                                                                      || vr_dados_log);

                          --desfazer alteracoes no banco e ir para proxima linha
                          RAISE vr_exc_undo;
                        END IF;

                        --Atribuir valor lote banco para variavel
                        vr_nrdolot2:= vr_numlotebco;

                        --Inicializar flag de controle
                        vr_flgachou:= FALSE;
                        WHILE NOT vr_flgachou LOOP
                          --Selecionar o próximo lote
                          OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                                          ,pr_dtmvtolt => pr_dtmvtolt
                                          ,pr_cdagenci => pr_cdagenci
                                          ,pr_cdbccxlt => pr_cdbccxlt
                                          ,pr_nrdolote => vr_nrdolot2);
                          --Posicionar o cursor no proximo registro
                          FETCH cr_craplot INTO rw_craplot;
                          --Se encontrou registro
                          IF cr_craplot%FOUND THEN
                            vr_nrdolot2:= vr_nrdolot2 + 1;
                          ELSE
                            --Atribuir valor retornado para a variavel
                            vr_nrdolote:= vr_nrdolot2;
                            vr_flgachou:= TRUE;
                          END IF;
                          --Fechar Cursor
                          CLOSE cr_craplot;
                        END LOOP; --WHILE vr_flgachou = FALSE

                        --Inserir na tabela de lotes
                        BEGIN
                          INSERT INTO craplot (cdcooper
                                              ,dtmvtolt
                                              ,cdagenci
                                              ,cdbccxlt
                                              ,nrdolote
                                              ,tplotmov)
                                      VALUES  (pr_cdcooper
                                              ,pr_dtmvtolt
                                              ,nvl(pr_cdagenci,0)
                                              ,nvl(pr_cdbccxlt,0)
                                              ,nvl(vr_nrdolote,0)
                                              ,nvl(pr_tplotmov,0))
                                    RETURNING  dtmvtolt
                                              ,cdagenci
                                              ,cdbccxlt
                                              ,nrdolote
                                              ,ROWID
                                      INTO    rw_craplot.dtmvtolt
                                              ,rw_craplot.cdagenci
                                              ,rw_craplot.cdbccxlt
                                              ,rw_craplot.nrdolote
                                              ,rw_craplot.ROWID;
                        EXCEPTION
                          WHEN OTHERS THEN
                            vr_des_erro:= 'Erro ao inserir na tabela de lotes. '||sqlerrm;
                            RAISE vr_exc_erro;
                        END;
                        --Mudar a flag para false
                        vr_flgfirst:= FALSE;
                      END IF; --vr_flgfirst

                      IF vr_cdtpddoc IN (75,76,77,90,94,95) THEN
                        --Inserir registro na tabela de rejeicao
                        BEGIN
                          INSERT INTO craprej (cdcooper
                                              ,dtrefere
                                              ,nrdconta
                                              ,nrdocmto
                                              ,vllanmto
                                              ,nrseqdig
                                              ,cdcritic
                                              ,cdpesqbb
                                              ,nrdctitg) -- Conta depositada
                                     VALUES   (pr_cdcooper
                                              ,pr_dtauxili
                                              ,nvl(nvl(vr_nrdconta_incorp,vr_nrdconta),0)
                                              ,nvl(vr_nrdocmto,0)
                                              ,nvl(vr_vllanmto,0)
                                              ,nvl(vr_nrseqarq,0)
                                              ,928
                                              ,nvl(vr_cdpesqbb,' ')
                                              ,nvl(vr_nrctadep,0));
                        EXCEPTION
                          WHEN OTHERS THEN
                          vr_cdcritic:= 843;
                          vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          -- Envio centralizado de log de erro
                          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                        || vr_cdprogra || ' --> '
                                                                        || vr_des_erro 
                                                                        || vr_dados_log);
                          RAISE vr_exc_erro;
                        END;
                      END IF;

                      IF vr_cdcritic > 0 THEN  --(1690)
                        IF vr_flctamig THEN
                          vr_tpintegr:= 1;
                        ELSE
                          vr_tpintegr:= 0;
                        END IF;

                        --Inserir registro na tabela de rejeicao
                        BEGIN
                          INSERT INTO craprej (cdcooper
                                              ,dtrefere
                                              ,nrdconta
                                              ,nrdocmto
                                              ,vllanmto
                                              ,nrseqdig
                                              ,cdcritic
                                              ,cdpesqbb
                                              ,tpintegr
                                              ,nrdctitg) -- Conta depositada
                                     VALUES   (pr_cdcooper
                                              ,pr_dtauxili
                                              ,nvl(nvl(vr_nrdconta_incorp,vr_nrdconta),0)
                                              ,nvl(vr_nrdocmto,0)
                                              ,nvl(vr_vllanmto,0)
                                              ,nvl(vr_nrseqarq,0)
                                              ,nvl(vr_cdcritic,0)
                                              ,nvl(vr_cdpesqbb,' ')
                                              ,nvl(vr_tpintegr,0)
                                              ,nvl(vr_nrctadep,0));
                        EXCEPTION
                          WHEN OTHERS THEN
                          vr_cdcritic:= 843;
                          vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          -- Envio centralizado de log de erro
                          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                        || vr_cdprogra || ' --> '
                                                                        || vr_des_erro 
                                                                        || vr_dados_log);
                          RAISE vr_exc_erro;
                        END;

                        --Executar rotina pc_cria_generica
                        pc_cria_generica(pr_cdcooper   => pr_cdcooper
                                        ,pr_cdagenci   => vr_tab_crapass(nvl(vr_nrdconta_incorp,vr_nrdconta)).cdagenci
                                        ,pr_dtmvtolt   => pr_dtmvtolt
                                        ,pr_cdcritic   => vr_cdcritic
                                        ,pr_dtleiarq   => pr_dtleiarq
                                        ,pr_cdagectl   => pr_cdagectl
                                        ,pr_nmarquiv   => vr_vet_nmarquiv(idx)
                                        ,pr_cdbanchq   => vr_cdbanchq
                                        ,pr_cdagechq   => vr_cdagechq
                                        ,pr_nrctachq   => vr_nrctachq
                                        ,pr_nrdocmto   => vr_nrdocmto
                                        ,pr_cdcmpchq   => vr_cdcmpchq
                                        ,pr_vllanmto   => vr_vllanmto
                                        ,pr_nrdconta   => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                        ,pr_nrseqarq   => vr_nrseqarq
                                        ,pr_cdpesqbb   => vr_cdpesqbb
                                        ,pr_setlinha   => vr_compensacao(vr_indice).cdpesqbb
                                        ,pr_dscritic   => vr_des_erro);

                        --Verificar se retornou erro
                        IF vr_des_erro IS NOT NULL THEN
                          -- Envio centralizado de log de erro
                          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                        || vr_cdprogra || ' --> '
                                                                        || vr_des_erro 
                                                                        || vr_dados_log);
                          RAISE vr_exc_erro;
                        END IF;

                        --Inicializa variavel de erro
                        vr_cdcritic:= 0;

                        --Pular para proximo registro do arquivo
                        RAISE vr_exc_pula;
                      END IF;  --vr_cdcritic > 0

                      /* Verificar possiveis fraudes nos cheques Sua Remessa roubados em outras IF's  */
                      cheq0001.pc_verifica_fraude_cheque (pr_cdcooper => pr_cdcooper
                                                         ,pr_cdagectl => nvl(vr_cdagectl_incorp,pr_cdagectl) --> Usa AgCtl antiga se houver
                                                         ,pr_nrctachq => vr_nrctachq
                                                         ,pr_dtrefere => pr_dtauxili
                                                         ,pr_nrdconta => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                                         ,pr_nrdocmto => vr_nrdocmto
                                                         ,pr_vllanmto => vr_vllanmto
                                                         ,pr_nrseqdig => vr_nrseqarq
                                                         ,pr_cdpesqbb => vr_cdpesqbb
                                                         ,pr_des_erro => vr_des_erro);

                      IF vr_des_erro IS NOT NULL THEN
                        -- Envio centralizado de log de erro
                        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                      || vr_cdprogra || ' --> '
                                                                      || vr_des_erro 
                                                                      || vr_dados_log);
                        RAISE vr_exc_erro;
                      END IF;

                      --Inicializar flag de controle
                      vr_flgachou:= FALSE;
                      vr_nrdocmt2:= vr_nrdocmto;
                      WHILE NOT vr_flgachou LOOP
                        --Selecionar lancamentos
                        OPEN cr_craplcm3 (pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => pr_cdbccxlt
                                         ,pr_nrdolote => vr_nrdolote
                                         ,pr_nrdctabb => nvl(vr_nrdconta_incorp,vr_nrdctabb)
                                         ,pr_nrdocmto => vr_nrdocmt2);
                        --Posicionar no proximo registro
                        FETCH cr_craplcm3 INTO rw_craplcm3;
                        --Se encontrou registro
                        IF cr_craplcm3%FOUND THEN
                          vr_nrdocmt2:= (vr_nrdocmt2 + 1000000);
                        ELSE
                          vr_nrdocmto:= vr_nrdocmt2;
                          vr_flgachou:= TRUE;
                        END IF;
                        --Fechar cursor
                        CLOSE cr_craplcm3;
                      END LOOP; --WHILE vr_flgachou = FALSE

                      -- Depósito intercooperativa
                      IF vr_cdbandep = 85 AND vr_cdageapr <> vr_cdagedep THEN

                          --Verificar o tipo de cheque para determinar o código do histórico
                          IF rw_crapfdc.tpcheque = 2 THEN
                            vr_cdhistor:= 572;
                          ELSE
                            vr_cdhistor:= 524;
                          END IF;

                          OPEN cr_crapcoop (vr_cdageapr);
                           FETCH cr_crapcoop INTO rw_crapcoop;

                          IF cr_crapcoop%FOUND THEN
                            vr_cdcoptfn := rw_crapcoop.cdcooper;
                          ELSE
                            vr_cdcoptfn := 0;
                          END IF;

                          CLOSE cr_crapcoop;

                        vr_flg_criou_lcm := FALSE;
                        vr_nrseqdig := nvl(vr_nrseqarq,0);
                        
                        WHILE NOT vr_flg_criou_lcm LOOP
                          BEGIN
                          --Inserir lancamento
                          INSERT INTO craplcm (cdcooper
                                              ,dtmvtolt
                                              ,dtrefere
                                              ,cdagenci
                                              ,cdbccxlt
                                              ,nrdolote
                                              ,nrdconta
                                              ,nrdctabb
                                              ,nrdocmto
                                              ,cdhistor
                                              ,vllanmto
                                              ,nrseqdig
                                              ,cdpesqbb
                                              ,cdbanchq
                                              ,cdcmpchq
                                              ,cdagechq
                                              ,nrctachq
                                              ,nrlotchq
                                              ,sqlotchq
                                              ,cdcoptfn
                                              ,cdagetfn
                                              ,hrtransa)
                                     VALUES   (pr_cdcooper
                                              ,rw_craplot.dtmvtolt
                                              ,pr_dtleiarq
                                              ,nvl(rw_craplot.cdagenci,0)
                                              ,nvl(rw_craplot.cdbccxlt,0)
                                              ,nvl(rw_craplot.nrdolote,0)
                                              ,nvl(nvl(vr_nrdconta_incorp,vr_nrdconta),0)
                                              ,nvl(nvl(vr_nrdconta_incorp,vr_nrdctabb),0)
                                              ,nvl(vr_nrdocmto,0)
                                              ,nvl(vr_cdhistor,0)
                                              ,nvl(vr_vllanmto,0)
                                                ,vr_nrseqdig
                                              ,nvl(vr_cdpesqbb,' ')
                                              ,nvl(vr_cdbandep,0)
                                              ,nvl(vr_cdcmpdep,0)
                                              ,nvl(vr_cdagedep,0)
                                              ,nvl(vr_nrctadep,0)
                                              ,nvl(vr_nrlotchq,0)
                                              ,nvl(vr_sqlotchq,0)
                                              ,vr_cdcoptfn
                                              ,vr_cdageapr
                                              ,to_char(SYSDATE,'sssss'));
                        EXCEPTION
                            WHEN DUP_VAL_ON_INDEX THEN
                              vr_nrseqdig := vr_nrseqdig + 100000;
                              continue;
                          WHEN OTHERS THEN
                              cecred.pc_internal_exception;
                            vr_des_erro:= 'Erro ao inserir na tabela craplcm, deposito intercooperativa. Rotina pc_crps533.pc_integra_todas_coop. '||sqlerrm;
                            RAISE vr_exc_erro;
                        END;
                          
                          vr_flg_criou_lcm := TRUE;
                          
                        END LOOP;

                      ELSE

                          --Verificar o tipo de cheque para determinar o código do histórico
                          IF rw_crapfdc.tpcheque = 2 THEN
                            vr_cdhistor:= 572;
                          ELSE
                            vr_cdhistor:= 524;
                          END IF;

                        vr_flg_criou_lcm := FALSE;
                        vr_nrseqdig := nvl(vr_nrseqarq,0);               
                        
                        WHILE NOT vr_flg_criou_lcm LOOP
                          BEGIN
                          --Inserir lancamento
                          INSERT INTO craplcm (cdcooper
                                              ,dtmvtolt
                                              ,dtrefere
                                              ,cdagenci
                                              ,cdbccxlt
                                              ,nrdolote
                                              ,nrdconta
                                              ,nrdctabb
                                              ,nrdocmto
                                              ,cdhistor
                                              ,vllanmto
                                              ,nrseqdig
                                              ,cdpesqbb
                                              ,cdbanchq
                                              ,cdcmpchq
                                              ,cdagechq
                                              ,nrctachq
                                              ,nrlotchq
                                              ,sqlotchq
                                              ,cdcoptfn
                                              ,hrtransa)
                                     VALUES   (pr_cdcooper
                                              ,rw_craplot.dtmvtolt
                                              ,pr_dtleiarq
                                              ,nvl(rw_craplot.cdagenci,0)
                                              ,nvl(rw_craplot.cdbccxlt,0)
                                              ,nvl(rw_craplot.nrdolote,0)
                                              ,nvl(nvl(vr_nrdconta_incorp,vr_nrdconta),0)
                                              ,nvl(nvl(vr_nrdconta_incorp,vr_nrdctabb),0)
                                              ,nvl(vr_nrdocmto,0)
                                              ,nvl(vr_cdhistor,0)
                                              ,nvl(vr_vllanmto,0)
                                                ,vr_nrseqdig
                                              ,nvl(vr_cdpesqbb,' ')
                                              ,nvl(vr_cdbandep,0)
                                              ,nvl(vr_cdcmpdep,0)
                                              ,nvl(vr_cdagedep,0)
                                              ,nvl(vr_nrctadep,0)
                                              ,nvl(vr_nrlotchq,0)
                                              ,nvl(vr_sqlotchq,0)
                                              ,0
                                              ,to_char(SYSDATE,'sssss'));
                        EXCEPTION
                            WHEN DUP_VAL_ON_INDEX THEN
                              vr_nrseqdig := vr_nrseqdig + 100000;
                              continue;
                          WHEN OTHERS THEN
                              cecred.pc_internal_exception;
                            vr_des_erro:= 'Erro ao inserir na tabela craplcm. Rotina pc_crps533.pc_integra_todas_coop. '||sqlerrm;
                            RAISE vr_exc_erro;
                        END;

                          vr_flg_criou_lcm := TRUE;

                        END LOOP;
                      END IF;

                      --Atualizar informacoes dos Lotes
                      BEGIN
                        UPDATE craplot SET craplot.qtinfoln = craplot.qtinfoln + 1
                                          ,craplot.qtcompln = craplot.qtcompln + 1
                                          ,craplot.vlinfodb = craplot.vlinfodb + vr_vllanmto
                                          ,craplot.vlcompdb = craplot.vlcompdb + vr_vllanmto
                                          ,craplot.nrseqdig = vr_nrseqdig
                        WHERE craplot.ROWID = rw_craplot.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_des_erro:= 'Erro ao atualizar a tabela craplot. Rotina pc_crps533.pc_integra_todas_coop. '||sqlerrm;
                          RAISE vr_exc_erro;
                      END;

                      -- Deposito intercooperativa
                      IF vr_cdbandep = 85 AND vr_cdageapr <> vr_cdagedep THEN
                        --Atualizar informacoes de folha de cheque deposito intercoop.
                        BEGIN
                          UPDATE crapfdc SET crapfdc.dtliqchq = pr_dtmvtolt
                                            ,crapfdc.vlcheque = nvl(vr_vllanmto,0)
                                            ,crapfdc.cdbandep = vr_compensacao(vr_indice).cdbandep
                                            ,crapfdc.cdagedep = vr_compensacao(vr_indice).cdagedep
                                            ,crapfdc.nrctadep = vr_compensacao(vr_indice).nrctadep
                                            ,crapfdc.cdtpdchq = nvl(vr_cdtpddoc,0)
                                            ,crapfdc.incheque = crapfdc.incheque + 5
                                            ,crapfdc.cdageaco = vr_cdageapr
                                       WHERE crapfdc.ROWID = rw_crapfdc.ROWID;
                        EXCEPTION
                         WHEN OTHERS THEN
                           vr_des_erro:= 'Erro ao atualizar a tabela crapfdc, deposito intercooperativa. Rotina pc_crps533.pc_integra_todas_coop. '||sqlerrm;
                           RAISE vr_exc_erro;
                        END;
                      ELSE
                        --Atualizar informacoes de folha de cheque
                        BEGIN
                          UPDATE crapfdc SET crapfdc.dtliqchq = pr_dtmvtolt
                                            ,crapfdc.vlcheque = nvl(vr_vllanmto,0)
                                            ,crapfdc.cdbandep = vr_compensacao(vr_indice).cdbandep
                                            ,crapfdc.cdagedep = vr_compensacao(vr_indice).cdagedep
                                            ,crapfdc.nrctadep = vr_compensacao(vr_indice).nrctadep
                                            ,crapfdc.cdtpdchq = nvl(vr_cdtpddoc,0)
                                            ,crapfdc.incheque = crapfdc.incheque + 5
                                       WHERE crapfdc.ROWID = rw_crapfdc.ROWID;
                        EXCEPTION
                          WHEN OTHERS THEN
                            vr_des_erro:= 'Erro ao atualizar a tabela crapfdc. Rotina pc_crps533.pc_integra_todas_coop. '||sqlerrm;
                            RAISE vr_exc_erro;
                        END;
                      END IF;

                      --Executar rotina pc_cria_generica
                      pc_cria_generica(pr_cdcooper   => pr_cdcooper
                                      ,pr_cdagenci   => vr_tab_crapass(nvl(vr_nrdconta_incorp,vr_nrdconta)).cdagenci
                                      ,pr_dtmvtolt   => pr_dtmvtolt
                                      ,pr_cdcritic   => 0
                                      ,pr_dtleiarq   => pr_dtleiarq
                                      ,pr_cdagectl   => pr_cdagectl
                                      ,pr_nmarquiv   => vr_vet_nmarquiv(idx)
                                      ,pr_cdbanchq   => vr_cdbanchq
                                      ,pr_cdagechq   => vr_cdagechq
                                      ,pr_nrctachq   => vr_nrctachq
                                      ,pr_nrdocmto   => vr_nrdocmto
                                      ,pr_cdcmpchq   => vr_cdcmpchq
                                      ,pr_vllanmto   => vr_vllanmto
                                      ,pr_nrdconta   => nvl(vr_nrdconta_incorp,vr_nrdconta)
                                      ,pr_nrseqarq   => vr_nrseqarq
                                      ,pr_cdpesqbb   => vr_cdpesqbb
                                      ,pr_setlinha   => vr_compensacao(vr_indice).cdpesqbb
                                      ,pr_dscritic   => vr_des_erro);

                      --Verificar se retornou erro
                      IF vr_des_erro IS NOT NULL THEN
                        -- Envio centralizado de log de erro
                        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                      || vr_cdprogra || ' --> '
                                                                      || vr_des_erro 
                                                                      || vr_dados_log);
                        RAISE vr_exc_erro;
                      END IF;

                       --Atribuir quantidade e valor integrado para as variaveis
                      vr_qtcompln:= nvl(vr_qtcompln,0) + 1;
                      vr_vlcompdb:= nvl(vr_vlcompdb,0) + vr_vllanmto;

                      /*
                      096 - Cheque com contra-ordem.
                      257 - Cheque com alerta.
                      414 - Cheque devolvido pelo sistema.
                      439 - Ch. C.Ordem - Apr. Indevida.
                      950 - Cheque Custodiado/Descontado em outra IF.*/
                      IF vr_cdcritic_aux IN (96,257,414,439,950) THEN

                        OPEN cr_craplot2 (pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdagenci => 1
                                         ,pr_cdbccxlt => 100
                                         ,pr_nrdolote => 7600);  
                                        
                        --Posicionar no proximo registro
                        FETCH cr_craplot2 INTO rw_craplot2;
                        
                        --Se encontrou registro
                        IF cr_craplot2%NOTFOUND THEN
                          --Criar lote
                          BEGIN
                            --Inserir a capa do lote retornando informacoes para uso posterior
                            INSERT INTO craplot (cdcooper
                                                ,dtmvtolt
                                                ,cdagenci
                                                ,cdbccxlt
                                                ,nrdolote
                                                ,tplotmov)
                                        VALUES  (pr_cdcooper
                                                ,pr_dtmvtolt
                                                ,1
                                                ,100
                                                ,7600
                                                ,1)
                                      RETURNING dtmvtolt
                                               ,cdagenci
                                               ,cdbccxlt
                                               ,nrdolote
                                               ,ROWID
                                         INTO  rw_craplot2.dtmvtolt
                                              ,rw_craplot2.cdagenci
                                              ,rw_craplot2.cdbccxlt
                                              ,rw_craplot2.nrdolote
                                              ,rw_craplot2.rowid;
                                              
                          EXCEPTION
                            WHEN OTHERS THEN
                              vr_des_erro := 'Erro ao inserir na tabela craplot. '||SQLERRM;
                              --Sair do programa
                              RAISE vr_exc_erro;
                          END;
                        END IF;
                        
                        --Fechar Cursor
                        CLOSE cr_craplot2;
                         
                        IF vr_cdalinea <> 0 THEN
                          vr_alinea_96:= vr_cdalinea;
                        ELSE
                          vr_alinea_96:= 21;
                        END IF;
                      
                        vr_flg_criou_lcm := FALSE;
                        vr_nrseqdig := nvl(vr_nrseqarq, 0);

                        WHILE NOT vr_flg_criou_lcm LOOP
                        BEGIN
                         INSERT INTO craplcm
                           (cdcooper,
                            dtmvtolt,
                            dtrefere,
                            cdagenci,
                            cdbccxlt,
                            nrdolote,
                            nrdconta,
                            nrdctabb,
                            nrdocmto,
                            cdhistor,
                            vllanmto,
                            nrseqdig,
                            cdpesqbb,
                            cdbanchq,
                            cdagechq,
                            cdcmpchq,
                            nrctachq,
                            nrlotchq,
                            sqlotchq,
                            cdcoptfn,
                            dsidenti,
                            hrtransa)
                         VALUES
                           (pr_cdcooper,
                            rw_craplot2.dtmvtolt,
                            pr_dtleiarq,
                            nvl(rw_craplot2.cdagenci, 0),
                            nvl(rw_craplot2.cdbccxlt, 0),
                            nvl(rw_craplot2.nrdolote, 0),
                            nvl(nvl(vr_nrdconta_incorp, vr_nrdconta), 0),
                            nvl(nvl(vr_nrdconta_incorp, vr_nrdctabb), 0),
                            nvl(vr_nrdocmto, 0),
                            (CASE rw_crapfdc.tpcheque WHEN 1 THEN 573 ELSE 78 END),
                            nvl(vr_vllanmto, 0),
                              vr_nrseqdig,
                            vr_alinea_96,
                            rw_crapfdc.cdbanchq,
                            rw_crapfdc.cdagechq,
                            rw_crapfdc.cdcmpchq,
                            rw_crapfdc.nrctachq,
                            nvl(vr_nrlotchq, 0),
                            nvl(vr_sqlotchq, 0),
                            0,
                            2, -- dsidenti 
                            to_char(SYSDATE, 'sssss'));
                         EXCEPTION
                             WHEN DUP_VAL_ON_INDEX THEN
                               -- Incrementar o nrseqdig e tentar inserir novamente
                               vr_nrseqdig := vr_nrseqdig + 100000;
                               continue;
                           WHEN OTHERS THEN
                               cecred.pc_internal_exception;
                             vr_des_erro:= 'Erro ao inserir na tabela craplcm (devolucao). Rotina'
                                           || ' pc_crps533.pc_integra_todas_coop. '||SQLERRM;
                             RAISE vr_exc_erro;
                        END;
                        
                          vr_flg_criou_lcm := TRUE;

                        END LOOP;
                        
                        --Atualizar informacoes dos Lotes
                        BEGIN
                          UPDATE craplot
                             SET craplot.qtinfoln = craplot.qtinfoln + 1,
                                 craplot.qtcompln = craplot.qtcompln + 1,
                                 craplot.vlinfocr = craplot.vlinfocr + vr_vllanmto,
                                 craplot.vlcompcr = craplot.vlcompcr + vr_vllanmto,
                                 craplot.nrseqdig = vr_nrseqdig
                           WHERE craplot.rowid = rw_craplot2.rowid;
                        EXCEPTION
                          WHEN OTHERS THEN
                            vr_des_erro:= 'Erro ao atualizar a tabela craplot (devolucao). Rotina'
                                          || ' pc_crps533.pc_integra_todas_coop. '||SQLERRM;
                            RAISE vr_exc_erro;
                         END;
                         -- Busca incheque atualizado
                         BEGIN
                           IF cr_crapfdc_incheque%ISOPEN THEN
                             CLOSE cr_crapfdc_incheque;
                           END IF;
                           OPEN cr_crapfdc_incheque(rw_crapfdc.rowid);
                           FETCH cr_crapfdc_incheque INTO rw_crapfdc_incheque;
                           IF cr_crapfdc_incheque%NOTFOUND THEN
                             RAISE vr_exc_erro;
                           END IF;
                           IF cr_crapfdc_incheque%ISOPEN THEN
                             CLOSE cr_crapfdc_incheque;
                           END IF;
                         EXCEPTION
                           WHEN vr_exc_erro THEN
                             IF cr_crapfdc_incheque%ISOPEN THEN
                               CLOSE cr_crapfdc_incheque;
                             END IF;
                             vr_des_erro:= 'Erro ao buscar incheque atualizado. Rotina'
                                           || ' pc_crps533.pc_integra_todas_coop. '||SQLERRM;
                             RAISE vr_exc_erro;
                         END;
                         IF (rw_crapfdc_incheque.incheque - 5) < 0 THEN
                           -- Não deixar fazer o update que deixa a situação negativo;
                           BEGIN
                             UPDATE crapfdc
                                SET crapfdc.dtliqchq = NULL,
                                    crapfdc.vlcheque = 0,
                                    crapfdc.cdbandep = 0,
                                    crapfdc.cdagedep = 0,
                                    crapfdc.nrctadep = 0,
                                    crapfdc.cdtpdchq = 0,
                                    crapfdc.cdageaco = 0
                              WHERE crapfdc.rowid = rw_crapfdc.rowid;
                           EXCEPTION
                             WHEN OTHERS THEN
                               vr_des_erro:= 'Erro ao atualizar a tabela crapfdc, devolucao contra-ordem.' 
                                             ||' Rotina pc_crps533.pc_integra_todas_coop.'||SQLERRM;
                             RAISE vr_exc_erro;
                           END;
                           -- Enviar email para área de compensação, informando que foi verificado que o cheque X, teve uma movimentação
                           -- que gerou situação inválida (negativa), e será necessário abrir um incidente para a sustentação para 
                           -- analisar o problema.

                           -- Buscar o diretório padrao da cooperativa conectada
                           vr_dircop_email:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                                  ,pr_cdcooper => rw_crapfdc.cdcooper
                                                                  ,pr_nmsubdir => 'salvar');                                         
                         
                           -- Corpo do e-mail para enviar para a área de compensação
                           vr_des_corpo:= 'ATENÇÃO a movimentação do cheque abaixo iria gerar uma situação de cheque negativa. Favor abrir um incidente para a sustentação analisar o problema!'||chr(10)||
                                         'Cooperativa: '||rw_crapfdc.cdcooper||chr(10)||
                                         'Conta: '||rw_crapfdc.nrctachq||chr(10)||
                                         'Cheque: '||vr_nrdocmto||chr(10)||
                                         'Arquivo: '||vr_dircop_email||'/'||replace(vr_nmarquiv,'.q','');
                                         
                                         
                           -- Buscar o endereço do e-mail para envio                                         
                           vr_dsvlrprm:= gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                   pr_cdcooper => 0,
                                                                   pr_cdacesso => 'PC_CRPS533_EMAIL');
                           
                           -- Comando para enviar e-mail a OQS
                           GENE0003.pc_solicita_email(pr_cdcooper        => rw_crapfdc.cdcooper --> Cooperativa conectada
                                                     ,pr_cdprogra        => 'PC_CRPS533.PRC' --> Programa conectado
                                                     ,pr_des_destino     => vr_dsvlrprm --> Um ou mais detinatários separados por ';' ou ','
                                                     ,pr_des_assunto     => 'PC_CRPS533 - Movimentação de cheque gerou situação inválida (negativa)' --> Assunto do e-mail
                                                     ,pr_des_corpo       => vr_des_corpo --> Corpo (conteudo) do e-mail
                                                     ,pr_des_anexo       => null --> Um ou mais anexos separados por ';' ou ','
                                                     ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                                     ,pr_flg_log_batch   => 'N' --> Incluir no log a informação do anexo?
                                                     ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                                     ,pr_des_erro        => vr_dscritic);      
                           IF vr_dscritic IS NOT NULL THEN -- verifica se deu erro mas não aborta
                             -- Envio centralizado de log de erro
                             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                           || vr_cdprogra || ' --> '
                                                                           || vr_dscritic 
                                                                           || vr_dados_log);
                           END IF;                                                     
                         ELSE
                         -- Mudar situacao do cheque contra-ordenado
                         BEGIN
                           UPDATE crapfdc
                              SET crapfdc.dtliqchq = NULL,
                                  crapfdc.vlcheque = 0,
                                  crapfdc.cdbandep = 0,
                                  crapfdc.cdagedep = 0,
                                  crapfdc.nrctadep = 0,
                                  crapfdc.cdtpdchq = 0,
                                  crapfdc.incheque = crapfdc.incheque - 5,
                                  crapfdc.cdageaco = 0
                            WHERE crapfdc.rowid = rw_crapfdc.rowid;
                         EXCEPTION
                           WHEN OTHERS THEN
                             vr_des_erro:= 'Erro ao atualizar a tabela crapfdc, devolucao contra-ordem.' 
                                           ||' Rotina pc_crps533.pc_integra_todas_coop.'||SQLERRM;
                           RAISE vr_exc_erro;
                         END;
                         END IF;
                         
                         -- Atualizar alinea do cheque contra-ordenado
                         BEGIN
                           UPDATE gncpchq 
                              SET gncpchq.cdalinea = vr_alinea_96
                            WHERE gncpchq.cdcooper = pr_cdcooper 
                              AND gncpchq.dtmvtolt = rw_craplot2.dtmvtolt
                              AND gncpchq.cdbanchq = nvl(vr_cdbanchq,0)
                              AND gncpchq.cdagechq = nvl(vr_cdagechq,0)
                              AND gncpchq.nrctachq = nvl(vr_nrctachq,0)
                              AND gncpchq.nrcheque = nvl(vr_nrdocmto,0)
                              AND gncpchq.cdtipreg IN(3,4);
                         EXCEPTION 
                           WHEN OTHERS THEN
                             vr_des_erro:= 'Erro ao atualizar a tabela gncpchq (devolucao). Rotina'
                                        || ' pc_crps533.pc_integra_todas_coop. '||SQLERRM;
                            RAISE vr_exc_erro;
                         END;

                      END IF; -- critica 96
                    END IF; --vr_flgsai

                   EXCEPTION
                    WHEN vr_exc_undo THEN
                       --Desfazer as alteracoes no banco de dados
                      ROLLBACK TO SAVEPOINT vr_savepoint_trans;
                      --Atribuir valor para continuar processamento
                      vr_flgsair:= FALSE;
                      --Atribuir zero para variavel de erro
                      vr_cdcritic:= 0;
                    WHEN vr_exc_pula THEN
                      --Atribuir valor para continuar processamento
                      vr_flgsair:= FALSE;
                      --Atribuir zero para variavel de erro
                      vr_cdcritic:= 0;
                    WHEN vr_exc_sair THEN
                      --Chegou ao final do arquivo
                      NULL;
                    WHEN vr_exc_erro THEN
                      -- Envio centralizado de log de erro
                      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                    || vr_cdprogra || ' --> '
                                                                    || vr_des_erro 
                                                                    || vr_dados_log);
                      RAISE vr_exc_erro;
                    WHEN OTHERS THEN
                      --Busca a mensagem de erro no banco de dados
                      vr_des_erro:= 'Erro ao processar arquivo. Detalhe: '||SQLERRM;
                      -- Envio centralizado de log de erro
                      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                    || vr_cdprogra || ' --> '
                                                                    || vr_des_erro 
                                                                    || vr_dados_log);
                      RAISE vr_exc_erro;
                  END; --bloco controle

                  vr_indice := vr_compensacao.next(vr_indice);
                  
                  IF not (vr_compensacao.exists(vr_indice)) THEN
                    vr_flgsair := TRUE;
                  END IF;

                END LOOP; --LOOP de leitura de linhas do arquivo
                -- Fechar o arquivo de leitura
                gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;

                -- Caso não for um arquivo de incorporação
                IF vr_cdcooper_incorp IS NULL THEN
                  --Se for cooperativa 1 ou 2
                  IF pr_cdcooper IN (1,2) THEN  --linha 1788
                    --Executar rotina
                    pc_processamento_tco(pr_cdcooper   => pr_cdcooper
                                        ,pr_dtmvtolt   => pr_dtmvtolt
                                        ,pr_cdagenci   => pr_cdagenci
                                        ,pr_cdbccxlt   => pr_cdbccxlt
                                        ,pr_tplotmov   => pr_tplotmov
                                        ,pr_dtleiarq   => pr_dtleiarq
                                        ,pr_cdbcoctl   => pr_cdbcoctl
                                        ,pr_cdagectl   => pr_cdagectl
                                        ,pr_nmarquiv   => vr_vet_nmarquiv(idx)
                                        ,pr_dstextab   => vr_dstextab_vlb
                                        ,pr_dscritic   => vr_des_erro);
                    IF vr_des_erro IS NOT NULL THEN
                      -- Envio centralizado de log de erro
                        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                      || vr_cdprogra || ' --> '
                                                                      || vr_des_erro 
                                                                      || vr_dados_log);
                    END IF;
                  END IF;
                END IF;

                --Zerar variaveis para proxima iteração
                vr_tot_qtregrej:= 0;
                vr_tot_vlregrej:= 0;
                vr_cdcritic:= 0;
                vr_flgfirst:= TRUE;
                vr_pagnum:= 1;

                vr_nmarqimp:= 'crrl526_' || TO_CHAR(idx,'FM009') ||  '.lst';
                vr_cdempres:= 11;

                --Criar Arquivo de impressao

                -- Buscar o diretório log da cooperativa conectada
                vr_dircop_imp := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                      ,pr_cdcooper => pr_cdcooper
                                                      ,pr_nmsubdir => 'rl');

                -- Busca do diretório base da cooperativa para a geração de relatórios
                vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                                      ,pr_cdcooper => pr_cdcooper);


                -- Inicializar o CLOB
                dbms_lob.createtemporary(vr_xml_rel, true);
                dbms_lob.open(vr_xml_rel, dbms_lob.lob_readwrite);

                gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                       ,pr_texto_completo => vr_chr_rel
                                       ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><crrl526 nmarquiv="integra/'||vr_vet_nmarquiv(idx)||'" >'
                                                          || '<agencia dtmvtolt="'||To_Char(pr_dtmvtolt,'DD/MM/YYYY')||'"
                                                                 cdagenci="'||gene0002.fn_mask(pr_cdagenci,'zz9')||'"
                                                                 cdbccxlt="'||gene0002.fn_mask(pr_cdbccxlt,'zz9')||'"
                                                                 nrdolote="'||gene0002.fn_mask(vr_nrdolote,'zzz.zz9')||'"
                                                                 tplotmov="'||gene0002.fn_mask(pr_tplotmov,'99')||'" >');

                -- Preparar o CLOB para armazenar as infos do arquivo
                dbms_lob.createtemporary(vr_clobcri, TRUE, dbms_lob.CALL);
                dbms_lob.open(vr_clobcri, dbms_lob.lob_readwrite);

                -- Zerar a tabela de criticas que irao para o fim do relatorio
                vr_tab_critica.DELETE;

                --Imprimir demais informações
                FOR rw_craprej IN cr_craprej (pr_cdcooper => pr_cdcooper
                                             ,pr_dtrefere => pr_dtauxili) LOOP

                  IF rw_craprej.nrdconta < 999999999 THEN
                    vr_flgrejei:= TRUE;
                    vr_cdcritic:= rw_craprej.cdcritic;

                    IF vr_cdcritic = 999 THEN
                      IF pr_cdcooper = 2 THEN
                        vr_dscritic:= 'Associado da VIACREDI';
                      ELSE
                        vr_dscritic:= 'Associado da ALTOVALE';
                      END IF;
                    ELSIF vr_cdcritic = 948 THEN -- Oriundo da rotina CHEQ0001 - Cheques sinistrados
                      vr_dscritic:= rw_craprej.dshistor; -- Busca o motivo do cheque sinistrado
                    ELSIF vr_cdcritic = 757 THEN -- Requisicao XYZ
                      vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||' Conta 922.';
                    ELSE
                      --Selecionar a mensagem da critica
                      vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                    END IF;

                    vr_rel_cdtipdoc:= TO_NUMBER(SUBSTR(rw_craprej.cdpesqbb,148,3));
                    vr_rel_dspesqbb:= LPad(SUBSTR(rw_craprej.cdpesqbb,56,3),3,'0') || ' '||
                                      LPad(SUBSTR(rw_craprej.cdpesqbb,59,4),4,'0') || ' '||
                                      LPad(SUBSTR(rw_craprej.cdpesqbb,79,3),3,'0');

                    /* Estas criticas integram os cheques, sao "alertas" */
                    IF vr_cdcritic IN (96,257,414,439,717,928,929,948,963) THEN
                      vr_dscritic:= LTrim(RTRIM(vr_dscritic)) || ' INTEGRADO';
                    ELSE
                      --Nao contar os registros com critica 415
                      IF vr_cdcritic <> 415 THEN
                        --Totalizar quantidade e valor rejeitado
                        vr_tot_qtregrej:= Nvl(vr_tot_qtregrej,0) + 1;
                        vr_tot_vlregrej:= Nvl(vr_tot_vlregrej,0) + Nvl(rw_craprej.vllanmto,0);
                        
                        -- Caso esteja dentro da lista abaixo
                        IF vr_cdcritic IN (9,97,108,109,320,757,811) THEN
                          -- Monta a mensagem
                          vr_desdados := '50' || TO_CHAR(rw_crapdat.dtmvtolt,'DDMMRR') || ',' || TO_CHAR(rw_crapdat.dtmvtolt,'DDMMRR') ||
                                         ',1773,1455,' || TO_CHAR(rw_craprej.vllanmto,'fm9999999990d00','NLS_NUMERIC_CHARACTERS=.,') ||
                                         ',5210,"' || GENE0007.fn_caract_acento(UPPER(LTRIM(vr_dscritic,lpad(vr_cdcritic,3,0) || ' - '))) || 
                                         ' CHEQUE ' || GENE0002.fn_mask(rw_craprej.nrdocmto,'zzz.zzz.z') || 
                                         ' COOPERADO C/C ' || GENE0002.fn_mask_conta(rw_craprej.nrdconta) ||
                                         ' (CONFORME CRITICA RELATORIO 526)"' || chr(10);
                          -- Adiciona a linha ao arquivo de criticas
                          dbms_lob.writeappend(vr_clobcri, length(vr_desdados),vr_desdados);
                        END IF;
                      END IF;
                    END IF;
                    
                    IF vr_cdcritic = 96 THEN
                      -- Monta a mensagem
                      vr_desdados := '50' || 
                                     TO_CHAR(rw_crapdat.dtmvtolt,'DDMMRR') || ',' || 
                                     TO_CHAR(rw_crapdat.dtmvtopr,'DDMMRR') || --Entra no próximo dia útil
                                     ',4958,1413,' ||               
                                     TO_CHAR(rw_craprej.vllanmto,'fm9999999990d00','NLS_NUMERIC_CHARACTERS=.,') ||
                                     ',5210,"' || 
                                     ' DEVOLUCAO DO CHEQUE COM CONTRA-ORDEM ' || GENE0002.fn_mask(rw_craprej.nrdocmto,'zzz.zzz.z') || 
                                     ' DO COOPERADO C/C ' || GENE0002.fn_mask_conta(rw_craprej.nrdconta) ||
                                     ' (CONFORME CRITICA RELATORIO 526)"' || chr(10);
                      -- Adiciona a linha ao arquivo de criticas
                      dbms_lob.writeappend(vr_clobcri, length(vr_desdados),vr_desdados);
                      
                    ELSIF vr_cdcritic = 950 THEN
                      -- Monta a mensagem
                      vr_desdados := '50' || 
                                     TO_CHAR(rw_crapdat.dtmvtolt,'DDMMRR') || ',' || 
                                     TO_CHAR(rw_crapdat.dtmvtopr,'DDMMRR') || --Entra no próximo dia útil
                                     ',4958,1413,' ||               
                                     TO_CHAR(rw_craprej.vllanmto,'fm9999999990d00','NLS_NUMERIC_CHARACTERS=.,') ||
                                     ',5210,"' || 
                                     ' DEVOLUCAO DO CHEQUE CUSTODIADO/DESCONTADO EM OUTRA IF' || GENE0002.fn_mask(rw_craprej.nrdocmto,'zzz.zzz.z') || 
                                     ' DO COOPERADO C/C ' || GENE0002.fn_mask_conta(rw_craprej.nrdconta) ||
                                     ' (CONFORME CRITICA RELATORIO 526)"' || chr(10);
                      -- Adiciona a linha ao arquivo de criticas
                      dbms_lob.writeappend(vr_clobcri, length(vr_desdados),vr_desdados);                      
                    ELSIF vr_cdcritic = 414 THEN
                      -- Monta a mensagem
                      vr_desdados := '50' || 
                                     TO_CHAR(rw_crapdat.dtmvtolt,'DDMMRR') || ',' || 
                                     TO_CHAR(rw_crapdat.dtmvtopr,'DDMMRR') || --Entra no próximo dia útil
                                     ',4958,1413,' ||               
                                     TO_CHAR(rw_craprej.vllanmto,'fm9999999990d00','NLS_NUMERIC_CHARACTERS=.,') ||
                                     ',5210,"' || 
                                     ' CHEQUE DEVOLVIDO PELO SISTEMA ' || GENE0002.fn_mask(rw_craprej.nrdocmto,'zzz.zzz.z') || 
                                     ' DO COOPERADO C/C ' || GENE0002.fn_mask_conta(rw_craprej.nrdconta) ||
                                     ' (CONFORME CRITICA RELATORIO 526)"' || chr(10);
                      -- Adiciona a linha ao arquivo de criticas
                      dbms_lob.writeappend(vr_clobcri, length(vr_desdados),vr_desdados);                      

                    ELSIF vr_cdcritic = 439 THEN
                      -- Monta a mensagem
                      vr_desdados := '50' || 
                                     TO_CHAR(rw_crapdat.dtmvtolt,'DDMMRR') || ',' || 
                                     TO_CHAR(rw_crapdat.dtmvtopr,'DDMMRR') || --Entra no próximo dia útil
                                     ',4958,1413,' ||               
                                     TO_CHAR(rw_craprej.vllanmto,'fm9999999990d00','NLS_NUMERIC_CHARACTERS=.,') ||
                                     ',5210,"' || 
                                     ' DEVOLUÇÃO DO CHEQUE C.ORDEM - APR.INDEVIDA ' || GENE0002.fn_mask(rw_craprej.nrdocmto,'zzz.zzz.z') || 
                                     ' DO COOPERADO C/C ' || GENE0002.fn_mask_conta(rw_craprej.nrdconta) ||
                                     ' (CONFORME CRITICA RELATORIO 526)"' || chr(10);
                      -- Adiciona a linha ao arquivo de criticas
                      dbms_lob.writeappend(vr_clobcri, length(vr_desdados),vr_desdados);					                      
                    END IF;


                    IF vr_cdcritic <> 999 THEN
                      -- Lógica para adição de sufixo para cooperativas incorporadas / migradas
                      IF pr_cdcooper IN (1,2,13,9) THEN
                        -- Se houve incorporação
                        IF vr_cdcooper_incorp = 4 THEN
                          vr_dscritic:= LTrim(RTRIM(vr_dscritic)) || ' - Ass. CONCREDI ';
                        ELSIF vr_cdcooper_incorp = 15 THEN
                          vr_dscritic:= LTrim(RTRIM(vr_dscritic)) || ' - Ass. CREDIMILSUL ';
                        ELSIF vr_cdcooper_incorp = 17 THEN
                          vr_dscritic:= LTrim(RTRIM(vr_dscritic)) || ' - Ass. TRANSULCRED ';
                        ELSE
                          -- Testar migração comum
                          OPEN cr_craptco (pr_cdcopant => pr_cdcooper
                                          ,pr_nrctaant => rw_craprej.nrdconta
                                          ,pr_tpctatrf => 1
                                          ,pr_flgativo => 1);
                          --Posicionar no proximo registro
                          FETCH cr_craptco INTO rw_craptco;
                          --se encontrou
                          IF cr_craptco%FOUND THEN
                            IF pr_cdcooper = 2 THEN
                              vr_dscritic:= LTrim(RTRIM(vr_dscritic)) || ' - Ass. VIACREDI';
                            ELSE
                              vr_dscritic:= LTrim(RTRIM(vr_dscritic)) || ' - Ass. ALTOVALE';
                            END IF;
                          END IF;
                          --Fechar Cursor
                          CLOSE cr_craptco;
                        END IF;
                      END IF;
                    END IF;

                    IF vr_cdcritic IN (811,757) THEN
                      --Montar indice para pesquisar tabela de memoria de rejeicao
                      vr_index_craprej:=  LPad(rw_craprej.cdcooper,03,'0')||
                                          LPAD(rw_craprej.dtrefere,08,'0')||
                                          LPad(rw_craprej.nrdconta,10,'0')||
                                          LPad(rw_craprej.nrdocmto,25,'0')||
                                          LPad(rw_craprej.vllanmto,25,'0')||
                                          lpad(rw_craprej.nrseqdig,10,'0')||
                                          LPad(rw_craprej.cdcritic,05,'0')||
                                          RPad(rw_craprej.cdpesqbb,200,'#');
                      --Verificar existencia do indice na tabela de rejeicao
                      IF vr_tab_craprej.EXISTS(vr_index_craprej) THEN
                        vr_dscritic:= LTrim(RTRIM(vr_dscritic)) ||' '|| vr_tab_craprej(vr_index_craprej).dscritic ;
                      END IF;

                    END IF;  --vr_cdcritic IN (811,757)

					-- Buscar o numero do PA(cdagenci)
                    OPEN cr_crapass_pa(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => rw_craprej.nrdconta);
                    FETCH cr_crapass_pa INTO rw_crapass_pa;
                    
                    --Se encontrou 
                    IF cr_crapass_pa%FOUND THEN
                       vr_cdagenci_pa := rw_crapass_pa.cdagenci;
                    ELSE
                       vr_cdagenci_pa := 0;
                    END IF;
                    --Fechar Cursor
                    CLOSE cr_crapass_pa;

                    -- Por as criticas 717 dentro de uma temp-table 
                    -- para apresentar apenas no final do relatorio
                    IF vr_cdcritic = 717 THEN
                       vr_idx_cri := vr_tab_critica.count;
                       vr_tab_critica(vr_idx_cri).dscritic := vr_dscritic;
                       vr_tab_critica(vr_idx_cri).nrdconta := rw_craprej.nrdconta;
                       vr_tab_critica(vr_idx_cri).nrseqdig := rw_craprej.nrseqdig;
                       vr_tab_critica(vr_idx_cri).nrdocmto := rw_craprej.nrdocmto;
                       vr_tab_critica(vr_idx_cri).vllanmto := rw_craprej.vllanmto;
                       vr_tab_critica(vr_idx_cri).dspesqbb := vr_rel_dspesqbb;
                       vr_tab_critica(vr_idx_cri).cdtipdoc := vr_rel_cdtipdoc;
                       vr_tab_critica(vr_idx_cri).nrctadep := REPLACE(rw_craprej.nrdctitg,' ',to_number(SUBSTR(rw_craprej.cdpesqbb,67,12)));
					   vr_tab_critica(vr_idx_cri).cdagenci := vr_cdagenci_pa;
                       CONTINUE;
                    END IF;

                    gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                           ,pr_texto_completo => vr_chr_rel
                                           ,pr_texto_novo     => '<rejeitados>
                                                                     <nrseqdig>'||gene0002.fn_mask(rw_craprej.nrseqdig,'zzz.zz9')  ||'</nrseqdig>
                                                                     <nrdconta>'||gene0002.fn_mask_conta(rw_craprej.nrdconta)      ||'</nrdconta>
                                                                     <nrdocmto>'||gene0002.fn_mask(rw_craprej.nrdocmto,'zzz.zzz.z')||'</nrdocmto>
                                                                     <nrctadep>'||REPLACE(rw_craprej.nrdctitg,' ',to_number(SUBSTR(rw_craprej.cdpesqbb,67,12))) ||'</nrctadep>
                                                                     <vllanmto>'||rw_craprej.vllanmto                              ||'</vllanmto>
                                                                     <dspesqbb>'||vr_rel_dspesqbb                                  ||'</dspesqbb>
                                                                     <cdtipdoc>'||To_Char(vr_rel_cdtipdoc,'FM999')                 ||'</cdtipdoc>
																	 <cdagenci_conta>'||vr_cdagenci_pa                             ||'</cdagenci_conta>
                                                                     <dscritic>'||vr_dscritic                                      ||'</dscritic>
                                                                  </rejeitados>');

                  END IF; --rw_craprej.nrdconta < 999999999

                END LOOP; --cr_craprej

                --Processar a tabela de criticas de fim de relatorio
                IF vr_tab_critica.count > 0 THEN
                  
                   FOR vr_idx_cri IN vr_tab_critica.FIRST..vr_tab_critica.LAST LOOP
                     
                      gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                             ,pr_texto_completo => vr_chr_rel
                                             ,pr_texto_novo     => '<rejeitados>
                                                                       <nrseqdig>'||gene0002.fn_mask(vr_tab_critica(vr_idx_cri).nrseqdig,'zzz.zz9')  ||'</nrseqdig>
                                                                       <nrdconta>'||gene0002.fn_mask_conta(vr_tab_critica(vr_idx_cri).nrdconta)      ||'</nrdconta>
                                                                       <nrdocmto>'||gene0002.fn_mask(vr_tab_critica(vr_idx_cri).nrdocmto,'zzz.zzz.z')||'</nrdocmto>
                                                                       <nrctadep>'||to_char(vr_tab_critica(vr_idx_cri).nrctadep)                     ||'</nrctadep>
                                                                       <vllanmto>'||vr_tab_critica(vr_idx_cri).vllanmto                              ||'</vllanmto>
                                                                       <dspesqbb>'||vr_tab_critica(vr_idx_cri).dspesqbb                              ||'</dspesqbb>
                                                                       <cdtipdoc>'||To_Char(vr_tab_critica(vr_idx_cri).cdtipdoc,'FM999')             ||'</cdtipdoc>
																	   <cdagenci_conta>'||vr_tab_critica(vr_idx_cri).cdagenci                        ||'</cdagenci_conta>
                                                                       <dscritic>'||vr_tab_critica(vr_idx_cri).dscritic                              ||'</dscritic>
                                                                    </rejeitados>');
                   END LOOP; --vr_tab_critica
                   
                END IF;

                -- Incluir tag caso não gerar nenhum rejeitado, para que funcione corretamente no ireport
                IF NOT vr_flgrejei THEN
                  gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                         ,pr_texto_completo => vr_chr_rel
                                         ,pr_texto_novo     => '<rejeitados/>');
                END IF;

                --Atualizar totalizador de registros integrados
                vr_tot_qtregint:= vr_qtcompln;
                vr_tot_vlregint:= vr_vlcompdb;

                gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                       ,pr_texto_completo => vr_chr_rel
                                       ,pr_texto_novo     => '</agencia>');
                --Mostrar totalizadores no relatorio
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                       ,pr_texto_completo => vr_chr_rel
                                       ,pr_texto_novo     => '<totais>
                                                                 <tot_qtregrec>'|| vr_tot_qtregrec ||'</tot_qtregrec>
                                                                 <tot_qtregint>'|| vr_tot_qtregint ||'</tot_qtregint>
                                                                 <tot_qtregrej>'|| vr_tot_qtregrej ||'</tot_qtregrej>
                                                                 <tot_vlregrec>'|| vr_tot_vlregrec ||'</tot_vlregrec>
                                                                 <tot_vlregint>'|| vr_tot_vlregint ||'</tot_vlregint>
                                                                 <tot_vlregrej>'|| vr_tot_vlregrej ||'</tot_vlregrej>
                                                              </totais>');
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                       ,pr_texto_completo => vr_chr_rel
                                       ,pr_texto_novo     => '</crrl526>'
                                       ,pr_fecha_xml      => TRUE);

                  --PJ 565.1
                BEGIN
                  INSERT INTO tbcompe_suaremessa
                    (cdcooper,
                     tparquiv,
                     dtarquiv,
                     qtrecebd,
                     vlrecebd,
                     qtintegr,
                     vlintegr,
                     qtrejeit,
                     vlrejeit,
                     nmarqrec)
                  VALUES
                    (pr_cdcooper,
                     3,
                     trunc(sysdate),
                     vr_tot_qtregrec,
                     vr_tot_vlregrec,
                     vr_tot_qtregint,
                     vr_tot_vlregint,
                     vr_tot_qtregrej,
                     vr_tot_vlregrej,
                     vr_vet_nmarquiv(idx)
                    );
                EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                      NULL;
                  WHEN OTHERS THEN
                      cecred.pc_internal_exception;
                      vr_des_erro:= 'Erro ao inserir na tabela tbcompe_suaremessa, Rotina pc_crps533.pc_integra_todas_coop. '||sqlerrm;
                      RAISE vr_exc_erro;
                END;

                -- Salvar copia relatorio para pasta "/rlnsv"
                IF pr_nmtelant = 'COMPEFORA' THEN
                  -- Buscar o diretório padrao da cooperativa conectada + /rlnsv
                  vr_dircop_rlnsv:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                         ,pr_cdcooper => pr_cdcooper
                                                         ,pr_nmsubdir => 'rlnsv');
                ELSE
                  -- Não haverá cópia
                  vr_dircop_rlnsv := null;
                END IF;

                -- Solicitar impressao de todas as agencias
                gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                           ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                           ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                           ,pr_dsxml     => vr_xml_rel          --> Arquivo XML de dados
                                           ,pr_dsxmlnode => '/crrl526/agencia/rejeitados'          --> No base do XML para leitura dos dados
                                           ,pr_dsjasper  => 'crrl526.jasper'    --> Arquivo de layout do iReport
                                           ,pr_dsparams  => null                --> Enviar como parametro apenas a agencia
                                           ,pr_dsarqsaid => vr_dircop_imp||'/'||vr_nmarqimp --> Arquivo final com codigo da agencia
                                           ,pr_qtcoluna  => 132                 --> 132 colunas
                                           ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                                           ,pr_flg_gerar => 'S'                 -- Gerar na hora
                                           ,pr_nmformul  => '132dh'             --> Nome do formulario para impress?o
                                           ,pr_sqcabrel  => 1
                                           ,pr_dspathcop => vr_dircop_rlnsv     --> gerar copia no diretorio
                                           ,pr_nrcopias  => 1                   --> Numero de copias
										   ,pr_nrvergrl => 1                    --> Numero da versão da função de geração de relatorio
                                           ,pr_des_erro  => vr_dscritic);      --> Saida com erro

                dbms_lob.freetemporary(vr_xml_rel);
                IF vr_dscritic IS NOT NULL THEN
                  -- Gerar excecao
                  raise vr_exc_saida;
                END IF;

                -- Se possuir conteudo de critica no CLOB
                IF LENGTH(vr_clobcri) > 0 THEN

                  -- Busca o diretório para contabilidade
                  vr_dircon := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                        ,pr_cdcooper => 0
                                                        ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
                  vr_arqcon := TO_CHAR(rw_crapdat.dtmvtolt,'RRMMDD')||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_CRITICAS_526.txt';
                  
                  -- Chama a geracao do TXT
                  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper              --> Cooperativa conectada
                                                     ,pr_cdprogra  => vr_cdprogra              --> Programa chamador
                                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt      --> Data do movimento atual
                                                     ,pr_dsxml     => vr_clobcri               --> Arquivo XML de dados
                                                     ,pr_dsarqsaid => vr_nom_direto || '/contab/' || vr_arqcon    --> Arquivo final com o path
                                                     ,pr_cdrelato  => NULL                     --> Código fixo para o relatório
                                                     ,pr_flg_gerar => 'N'                      --> Apenas submeter
                                                     ,pr_dspathcop => vr_dircon
                                                     ,pr_fldoscop  => 'S'
                                                     ,pr_des_erro  => vr_des_erro);            --> Saída com erro

                END IF;

                -- Liberando a memória alocada pro CLOB
                dbms_lob.close(vr_clobcri);
                dbms_lob.freetemporary(vr_clobcri);

                -- Verifica se ocorreram erros na geracao do TXT
                IF vr_des_erro IS NOT NULL THEN
                  -- Envio centralizado de log de erro
                  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' --> ERRO NA GERACAO DO ' || vr_arqcon || ': '
                                                             || vr_des_erro);
                END IF;

                -- Buscar o diretório padrao da cooperativa conectada + /salvar
                vr_dircop_salvar:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                        ,pr_cdcooper => pr_cdcooper
                                                        ,pr_nmsubdir => 'salvar');

                --Se tiver rejeitados
                IF vr_flgrejei THEN
                  vr_cdcritic:= 191;
                ELSE
                  vr_cdcritic:= 190;
                END IF;

                --Mostrar mensagem no log
                vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                vr_compl_erro:= ' - Arquivo: integra/' || vr_vet_nmarquiv(idx);
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 1 -- Processo normal
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                              || vr_cdprogra || ' --> '
                                                              || vr_des_erro || vr_compl_erro);
                --Quantidade copias e nome formulario
                vr_nrcopias:= 1;
                vr_nmformul:= NULL;
                vr_cdcritic:= 0;
                vr_des_erro:= NULL;
                vr_compl_erro:= NULL;

                -- Desde que não seja um arquivo de incorporação
                IF vr_cdcooper_incorp IS NULL THEN
                  --Viacredi ou Creditextil
                  IF pr_cdcooper IN (1,2) THEN  -- linha(1972)

                    --Zerar variaveis
                    vr_tot_qtregrec:= 0;
                    vr_tot_qtregint:= 0;
                    vr_tot_qtregrej:= 0;
                    vr_tot_vlregrec:= 0;
                    vr_tot_vlregint:= 0;
                    vr_tot_vlregrej:= 0;
                    vr_cdcritic    := 0;
                    vr_flgfirst    := TRUE;
                    vr_flgccord    := FALSE;
                    vr_flgrejei    := false;

                    vr_nmarqimp    := 'crrl526_'||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL')
                                                ||'_' || TO_CHAR(idx,'FM009') ||  '.lst';
                    vr_cdempres    := 11;

                    -- Buscar o diretório log da cooperativa conectada
                    vr_dircop_imp := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                          ,pr_cdcooper => pr_cdcooper
                                                          ,pr_nmsubdir => 'rl');

                    -- Inicializar o CLOB novamente
                    dbms_lob.createtemporary(vr_xml_rel, true);
                    dbms_lob.open(vr_xml_rel, dbms_lob.lob_readwrite);

                    gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                           ,pr_texto_completo => vr_chr_rel
                                           ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><crrl526 nmarquiv="integra/'||vr_vet_nmarquiv(idx)||'" >'
                                                              || '<agencia dtmvtolt="'||To_Char(pr_dtmvtolt,'DD/MM/YYYY')||'"
                                                                                       cdagenci="'||gene0002.fn_mask(pr_cdagenci,'zz9')||'"
                                                                                       cdbccxlt="'||gene0002.fn_mask(pr_cdbccxlt,'zz9')||'"
                                                                                       nrdolote="'||gene0002.fn_mask(vr_nrdolote,'zzz.zz9')||'"
                                                                                       tplotmov="'||gene0002.fn_mask(pr_tplotmov,'99')||'" >');

                    vr_linhanum := 0;
                    --Processar registros rejeitados
                    FOR rw_craprej IN cr_craprej(pr_cdcooper => pr_cdcooper
                                                ,pr_dtrefere => pr_dtauxili
                                                ,pr_tpintegr => 1) LOOP

                      vr_flgrejei:= TRUE;
                      vr_cdcritic:= rw_craprej.cdcritic;

                      IF pr_cdcooper = 2 THEN
                        vr_dscritic:= 'Associado da VIACREDI';
                      ELSE
                        IF vr_cdcritic <> 999 THEN
                          --Selecionar a mensagem da critica
                          vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                        ELSE
                          vr_dscritic:= 'Integrado';
                        END IF;
                      END IF;

                      IF vr_cdcritic = 96 THEN
                         vr_dscritic:= vr_dscritic || ' - Integrado';
                      END IF;

                      --Tipo Documento
                      vr_rel_cdtipdoc:= TO_NUMBER(SUBSTR(rw_craprej.cdpesqbb,148,3));
                      --Descricao Pesquisa
                      vr_rel_dspesqbb:= LPad(SUBSTR(rw_craprej.cdpesqbb,56,3),3,'0') || ' '||
                                        LPad(SUBSTR(rw_craprej.cdpesqbb,59,4),4,'0') || ' '||
                                        LPad(SUBSTR(rw_craprej.cdpesqbb,79,3),3,'0');


                      IF vr_cdcritic IN (96,999) THEN
                        vr_tot_qtregint:= Nvl(vr_tot_qtregint,0) + 1;
                        vr_tot_vlregint:= Nvl(vr_tot_vlregint,0) + rw_craprej.vllanmto;
                      ELSE
                        vr_tot_qtregrej:= Nvl(vr_tot_qtregrej,0) + 1;
                        vr_tot_vlregrej:= Nvl(vr_tot_vlregrej,0) + rw_craprej.vllanmto;
                      END IF;

                      vr_tot_qtregrec:= Nvl(vr_tot_qtregrec,0) + 1;
                      vr_tot_vlregrec:= Nvl(vr_tot_vlregrec,0) + rw_craprej.vllanmto;

					  -- Buscar o numero do PA(cdagenci)
                      OPEN cr_crapass_pa(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => rw_craprej.nrdconta);
                      FETCH cr_crapass_pa INTO rw_crapass_pa;
                      
                      --Se encontrou 
                      IF cr_crapass_pa%FOUND THEN
                         vr_cdagenci_pa := rw_crapass_pa.cdagenci;
                      ELSE
                         vr_cdagenci_pa := 0;
                      END IF;
                      --Fechar Cursor
                      CLOSE cr_crapass_pa;

                      --Montar os lançamentos
                      gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                             ,pr_texto_completo => vr_chr_rel
                                             ,pr_texto_novo     => '<rejeitados>
                                                                       <nrseqdig>'||gene0002.fn_mask(rw_craprej.nrseqdig,'zzz.zz9')  ||'</nrseqdig>
                                                                       <nrdconta>'||gene0002.fn_mask_conta(rw_craprej.nrdconta)      ||'</nrdconta>
                                                                       <nrdocmto>'||gene0002.fn_mask(rw_craprej.nrdocmto,'zzz.zzz.z')||'</nrdocmto>
                                                                       <nrctadep>'||REPLACE(rw_craprej.nrdctitg,' ',to_number(substr(rw_craprej.cdpesqbb,67,12)))||'</nrctadep>
                                                                       <vllanmto>'||rw_craprej.vllanmto                              ||'</vllanmto>
                                                                       <dspesqbb>'||vr_rel_dspesqbb                                  ||'</dspesqbb>
                                                                       <cdtipdoc>'||To_Char(vr_rel_cdtipdoc,'FM999')                 ||'</cdtipdoc>
																	   <cdagenci_conta>'||vr_cdagenci_pa                             ||'</cdagenci_conta>
                                                                       <dscritic>'||vr_dscritic                                      ||'</dscritic>
                                                                    </rejeitados>');

                      --Incrementar o contador de linha
                      vr_linhanum:= vr_linhanum+1;
                    END LOOP;  --cr_craprej1

                    -- Incluir tag caso não gerar nenhum rejeitado, para que funcione corretamente no ireport
                    IF NOT vr_flgrejei THEN
                      gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                             ,pr_texto_completo => vr_chr_rel
                                             ,pr_texto_novo     => '<rejeitados/>');
                    END IF;

                    -- se não gerou nenhuma linha, criar apenas a tag vazia para funionamento do IReport
                    IF vr_linhanum = 0 THEN
                      gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                             ,pr_texto_completo => vr_chr_rel
                                             ,pr_texto_novo     => '<rejeitados></rejeitados>');
                    END IF;

                    gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                           ,pr_texto_completo => vr_chr_rel
                                           ,pr_texto_novo     => '</agencia>');
                    --Mostrar totalizadores no relatorio
                    gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                           ,pr_texto_completo => vr_chr_rel
                                           ,pr_texto_novo     => '<totais>
                                                                     <tot_qtregrec>'|| vr_tot_qtregrec ||'</tot_qtregrec>
                                                                     <tot_qtregint>'|| vr_tot_qtregint ||'</tot_qtregint>
                                                                     <tot_qtregrej>'|| vr_tot_qtregrej ||'</tot_qtregrej>
                                                                     <tot_vlregrec>'|| vr_tot_vlregrec ||'</tot_vlregrec>
                                                                     <tot_vlregint>'|| vr_tot_vlregint ||'</tot_vlregint>
                                                                     <tot_vlregrej>'|| vr_tot_vlregrej ||'</tot_vlregrej>
                                                                  </totais>');

                    gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel
                                           ,pr_texto_completo => vr_chr_rel
                                           ,pr_texto_novo     => '</crrl526>'
                                           ,pr_fecha_xml      => TRUE);

                    -- Salvar copia relatorio para pasta "/rlnsv"
                    IF pr_nmtelant = 'COMPEFORA' THEN
                      -- Buscar o diretório padrao da cooperativa conectada + /rlnsv
                      vr_dircop_rlnsv:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                             ,pr_cdcooper => pr_cdcooper
                                                             ,pr_nmsubdir => 'rlnsv');
                    ELSE
                      -- Não haverá cópia
                      vr_dircop_rlnsv := null;
                    END IF;

                    --Montar o conteúdo do email
                    vr_conteudo:= NULL;
                    --Montar o assunto do Email
                    vr_des_assunto:= 'Relatorio de Integracao Cheques AILOS';

                    --Recuperar emails de destino
                    vr_email_dest:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'RELAT_INTEGRACAO');

                    -- Solicitar impressão do relatorio crrl526_ totalizador
                    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                               ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                               ,pr_dsxml     => vr_xml_rel          --> Arquivo XML de dados
                                               ,pr_dsxmlnode => '/crrl526/agencia/rejeitados'          --> No base do XML para leitura dos dados
                                               ,pr_dsjasper  => 'crrl526.jasper'    --> Arquivo de layout do iReport
                                               ,pr_dsparams  => null                --> Enviar como parametro apenas a agencia
                                               ,pr_dsarqsaid => vr_dircop_imp||'/'||vr_nmarqimp --> Arquivo final com codigo da agencia
                                               ,pr_qtcoluna  => 132                 --> 132 colunas
                                               ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                                               ,pr_flg_gerar => 'N'                 --> Gerar na hora
                                               ,pr_nmformul  => '132dh'             --> Nome do formulario para impress?o
                                               ,pr_sqcabrel  => 1
                                               ,pr_dspathcop => vr_dircop_rlnsv     --> gerar copia no diretorio
                                               ,pr_dsmailcop => vr_email_dest       --> Lista sep. por ';' de emails para envio do relatório
                                               ,pr_dsassmail => vr_des_assunto      --> Assunto do e-mail que enviará o relatório
                                               ,pr_dscormail => vr_conteudo         --> HTML corpo do email que enviará o relatório
                                               ,pr_fldosmail => 'S'                 --> Conversar anexo para DOS antes de enviar
                                               ,pr_dscmaxmail => ' | tr -d "\032"'  --> Complemento do comando converte-arquivo
                                               ,pr_nrcopias  => 1                   --> Numero de copias
											   ,pr_nrvergrl => 1                    --> Numero da versão da função de geração de relatorio
                                               ,pr_des_erro  => vr_dscritic);       --> Saida com erro

                    dbms_lob.freetemporary(vr_xml_rel);
                    IF vr_dscritic IS NOT NULL THEN
                      -- Gerar excecao
                      raise vr_exc_saida;
                    END IF;

                    IF vr_flgrejei THEN
                      vr_cdcritic:= 191;
                    ELSE
                      vr_cdcritic:= 190;
                    END IF;

                    --Mostrar mensagem no log
                    vr_des_erro:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                    vr_compl_erro:= ' - Arquivo: integra/' || vr_vet_nmarquiv(idx) ;
                    -- Envio centralizado de log de erro
                    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                  || vr_cdprogra || ' --> '
                                                                  || vr_des_erro || vr_compl_erro);

                    vr_nrcopias:= 1;
                    vr_nmformul:= NULL;
                    vr_cdcritic:= 0;
                    vr_des_erro:= NULL;
                    vr_compl_erro:= NULL;

                  END IF;  --IF pr_cdcooper in(1,2)
                END IF;

                --Excluir os registros de rejeicao
                DELETE craprej
                 WHERE craprej.cdcooper = pr_cdcooper
                   AND craprej.dtrefere = pr_dtauxili;

                --Limpar tabela temporaria
                vr_tab_craprej.DELETE;

                -- Remove os arquivos ".q" caso existam
                GENE0001.pc_OScommand_Shell('rm ' || pr_caminho || '/'|| vr_vet_nmarquiv(idx) || '.q 2> /dev/null');

                -- Adiciona o arquivo na lista de arquivos OK
                vr_vet_nmarquok.extend;
                vr_vet_nmarquok(vr_vet_nmarquok.count) := vr_vet_nmarquiv(idx);

              EXCEPTION
                WHEN vr_exc_saida THEN
                  -- Propagar o erro ao bloco superior
                  RAISE vr_exc_saida;
                WHEN vr_exc_erro THEN
                  -- Propagar o erro ao bloco superior
                  RAISE vr_exc_erro;
                WHEN vr_exc_proximo_arquivo THEN
                  -- Apenas ignorar o restante
                  -- do fluxo deste arquivo
                  NULL;
              END;
            END LOOP; --FOR idx IN 1..pr_contador LOOP

            -- Ao final do processamento de todos os arquivos
            -- Efetuar nova varredura para mover um a um para a salvar
            FOR idx IN 1..vr_vet_nmarquok.COUNT() LOOP
              --Mover arquivo no unix para a pasta salvar
              vr_comando:= 'mv ' || pr_caminho|| '/' || vr_vet_nmarquok(idx)||' '||vr_dircop_salvar||'/'|| vr_vet_nmarquok(idx);
              --Executar o comando no unix
              GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                   ,pr_des_comando => vr_comando
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_des_erro);
              -- Se houve erro ao mover para a salvar
              IF vr_typ_saida = 'ERR' THEN
                -- Efetuar rollback e sair
                RAISE vr_exc_erro;
              END IF;
            END LOOP;

          EXCEPTION
            WHEN vr_exc_saida THEN
              -- Enviar a mensagem de erro ao DMBS_OUTPUT e ignorar o log
              gene0001.pc_print(to_char(sysdate,'hh24:mi:ss')||' - '|| 'pc_crps533.pc_integra_todas_coop --> '||vr_des_erro);
              pr_dscritic := 'Erro executando pc_crps533.pc_integra_todas_coop --> '||vr_des_erro;
            WHEN vr_exc_erro THEN
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || vr_des_erro || vr_compl_erro|| vr_dados_log);
              pr_dscritic:= 'Erro executando pc_crps533.pc_integra_todas_coop --> '||vr_des_erro|| vr_compl_erro;
            WHEN OTHERS THEN
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || vr_dados_log
                                                           || SQLERRM);
              pr_dscritic:= 'Erro executando pc_crps533.pc_integra_todas_coop --> '||SQLERRM;
          END pc_integra_todas_coop;

     ---------------------------------------
     -- Inicio Bloco Principal pc_crps533
     ---------------------------------------
     BEGIN

       --Atribuir o nome do programa que está executando
       vr_cdprogra := 'CRPS533';

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                 ,pr_action => null);

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se não encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic := 651;
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       OPEN cr_crapage(pr_cdcooper);
       FETCH cr_crapage INTO rw_crapage;
       WHILE cr_crapage%FOUND LOOP
         vr_tab_crapage(rw_crapage.cdagepac).cdagepac:= rw_crapage.cdagepac;
         FETCH cr_crapage INTO rw_crapage;
       END LOOP;
       CLOSE cr_crapage;

       -- Buscar informações das Cooperativas Incorporadas a
       -- 1-Viacredi (4-Concredi) e 13-ScrCred (15-Credimilsul) 9-Transpocred(17-Transulcred)
       IF pr_cdcooper IN(1,9,13) THEN
         -- Buscar informações da cooperativa Incorporada
         CASE pr_cdcooper
            WHEN  1 THEN -- Viacredi
           vr_cdcooper_incorp := 4;  --> Concredi
            WHEN  9 THEN -- Transpocred
              vr_cdcooper_incorp := 17; --> Transulcred
            WHEN 13 THEN -- ScrCred
           vr_cdcooper_incorp := 15; --> CredimilSul
         END CASE;

         -- Buscar informações da mesma
         OPEN cr_crapcop(pr_cdcooper => vr_cdcooper_incorp);
         FETCH cr_crapcop INTO rw_crapcop_incorp;
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a cooperativa esta cadastrada
       OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH btch0001.cr_crapdat INTO rw_crapdat;
       -- Se não encontrar
       IF btch0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE btch0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic := 1;
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE btch0001.cr_crapdat;
       END IF;

       -- Validações iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 1
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);
       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_des_erro );
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;

       --Verificar se a Cooperativa esta preparada para executar COMPE 85 - ABBC
       vr_dstextab_comp:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                  ,pr_nmsistem => 'CRED'
                                                  ,pr_tptabela => 'GENERI'
                                                  ,pr_cdempres => 0
                                                  ,pr_cdacesso => 'EXECUTAABBC'
                                                  ,pr_tpregist => 0);
       --Se nao encontrou entao
       IF trim(vr_dstextab_comp) IS NULL THEN
         --Levantar exceção para saida
         --vr_des_erro:= 'Cooperativa nao esta preparada para executar COMPE 85 - ABBC';
         RAISE vr_exc_fimprg;
       ELSE
         --Verificar valor retornado
         IF Upper(vr_dstextab_comp) != 'SIM' THEN
           --Levantar exceção para saida
           --vr_des_erro:= 'Cooperativa nao esta preparada para executar COMPE 85 - ABBC';
           RAISE vr_exc_fimprg;
         END IF;
       END IF;

       --Busca informacoes da craptab para lotes de banco
       vr_numlotebco:= GENE0002.fn_char_para_number(
                         TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 0
                                                   ,pr_cdacesso => 'NUMLOTEBCO'
                                                   ,pr_tpregist => 1));

       /* A partir de 16/04/2018 nao havera mais Cheque VLB - Projeto Compe Sessao Unica */  
       --Buscar informormacoes da craptab para valores vlb
       vr_dstextab_vlb:= '';
	   vr_vlchqvlb:= 0;

       ----- Gravar informações vindas do cadastro da cooperativa ----
       -- Inicializar contador de arquivos processados
       vr_cdbccxlt:= rw_crapcop.cdbcoctl;
       -- Atribuir o nome resumido da cooperativa
       vr_nmrescop:= rw_crapcop.nmrescop;
       --Banco e Agencia centralizadora
       vr_cdbanctl := rw_crapcop.cdbcoctl;
       vr_cdagectl := rw_crapcop.cdagectl;
       --Banco e Agencia centralizadora Incorporadas
       vr_cdbanctl_incorp := rw_crapcop_incorp.cdbcoctl;
       vr_cdagectl_incorp := rw_crapcop_incorp.cdagectl;

       -- Se CECRED, integra todos os demais arquivos que nao foram identificadas a Agencia e a Coop.
       IF rw_crapcop.cdcooper = 3 THEN
         vr_nmarquiv        := '1%.RET';
         vr_nmarquiv_incorp := NULL;
       -- Validar incorporação: 1-Viacredi (4-Concredi) e 13-ScrCred (15-Credimilsul) 9-Transpocred(17-Transulcred)
       ELSIF rw_crapcop.cdcooper IN(1,9,13) THEN
         vr_nmarquiv        := '1'|| TO_CHAR(vr_cdagectl,'FM0009')        || '%.RET';
         vr_nmarquiv_incorp := '1'|| TO_CHAR(vr_cdagectl_incorp,'FM0009') || '%.RET';
       ELSE
         -- As demais cooperativas, executa o processo atual (Guilherme/Supero)
         vr_nmarquiv        := '1'|| TO_CHAR(vr_cdagectl,'FM0009') || '%.RET';
         vr_nmarquiv_incorp := NULL;
       END IF;

       --Busca o caminho padrao do arquivo no unix + /integra
       vr_caminho_integra := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                                  ,pr_cdcooper => pr_cdcooper
                                                  ,pr_nmsubdir => 'integra');

       -- Remove os arquivos ".q" caso existam
       GENE0001.pc_OScommand_Shell(pr_des_comando => 'rm ' || vr_caminho_integra || '/'|| vr_nmarquiv || '.q 2> /dev/null');


       -- Executar rotina para listar os arquivos da pasta
       gene0001.pc_lista_arquivos(pr_path     => vr_caminho_integra
                                 ,pr_pesq     => vr_nmarquiv
                                 ,pr_listarq  => vr_lstdarqv
                                 ,pr_des_erro => vr_des_erro);
       IF vr_des_erro IS NOT NULL THEN
         RAISE vr_exc_saida;
       END IF;

       -- Se houver arquivos de cooperativas incorporadas
       IF vr_nmarquiv_incorp IS NOT NULL THEN
         -- Executar rotina para listar os arquivos da pasta
         gene0001.pc_lista_arquivos(pr_path     => vr_caminho_integra
                                   ,pr_pesq     => vr_nmarquiv_incorp
                                   ,pr_listarq  => vr_lstdarqv_incorp
                                   ,pr_des_erro => vr_des_erro);
         IF vr_des_erro IS NOT NULL THEN
           RAISE vr_exc_saida;
         END IF;
         -- Se encontrar algo
         IF TRIM(vr_lstdarqv_incorp) IS NOT NULL THEN
           -- Se existe lista da coop conectada
           IF TRIM(vr_lstdarqv) IS NOT NULL THEN
             -- Concatenar as listas para trabalharmos como uma lógica única
             vr_lstdarqv := vr_lstdarqv||','||vr_lstdarqv_incorp;
           ELSE
             -- Considerar apenas os arquivos incorporados
             vr_lstdarqv := vr_lstdarqv_incorp;
           END IF;
         END IF;
       END IF;

       --Montar vetor com nomes dos arquivos
       vr_vet_nmarquiv := GENE0002.fn_quebra_string(pr_string => vr_lstdarqv);
       --Se nao encontrou arquivos
       IF vr_vet_nmarquiv.COUNT <= 0 THEN
         --Montar mensagem critica
         vr_cdcritic:= 182;
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Levantar Excecao para continuar o processo
         RAISE vr_exc_fimprg;
       END IF;

       -- Somente para execução da tela COMPEFORA
       IF pr_nmtelant = 'COMPEFORA'   THEN
         vr_dtleiarq := rw_crapdat.dtmvtoan;
         vr_dtauxili := To_Char(rw_crapdat.dtmvtoan,'YYYYMMDD');
       ELSE
         vr_dtleiarq := rw_crapdat.dtmvtolt;
         vr_dtauxili := To_Char(rw_crapdat.dtmvtolt,'YYYYMMDD');
       END IF;

       --Limpar tabela temporaria
       vr_tab_crapass.DELETE;
       vr_tab_crapneg.DELETE;

       --Carregar tabela memoria associados
       FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapass(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
         vr_tab_crapass(rw_crapass.nrdconta).cdsitdct:= rw_crapass.cdsitdct;
         vr_tab_crapass(rw_crapass.nrdconta).cdagenci:= rw_crapass.cdagenci;
         vr_tab_crapass(rw_crapass.nrdconta).cdsitdtl:= rw_crapass.cdsitdtl;
         vr_tab_crapass(rw_crapass.nrdconta).vllimcre:= rw_crapass.vllimcre;
       END LOOP;

       --Carregar tabela memoria negativos
       FOR rw_crapneg IN cr_crapneg (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapneg(lpad(rw_crapneg.nrdconta,10,'0')||lpad(rw_crapneg.nrdocmto,10,'0')):= 0;
       END LOOP;

       IF nvl(TRIM(pr_nmtelant),' ') <> 'COMPEFORA' THEN
         BEGIN 
           DELETE 
             FROM crapdev 
            WHERE crapdev.cdcooper = pr_cdcooper
              AND crapdev.insitdev = 1;
         EXCEPTION
           WHEN OTHERS THEN
             vr_des_erro := 'Erro na hora de deletar registros da CRAPDEV com a Coop '||TO_CHAR(pr_cdcooper);
             RAISE vr_exc_saida;  
         END;
       END IF;

       -- Se CECRED, integra todos os demais arquivos que nao foram identificadas a Agencia e a Coop.
       -- As demais cooperativas, executa o processo atual (Guilherme/Supero)     */
       IF pr_cdcooper = 3 THEN
         pc_integra_cecred(pr_cdcooper  => pr_cdcooper
                              ,pr_nmrescop  => vr_nmrescop

                          ,pr_caminho   => vr_caminho_integra
                              ,pr_cdbcoctl  => vr_cdbanctl
                              ,pr_cdagectl  => vr_cdagectl
                              ,pr_cdbccxlt  => vr_cdbccxlt

                              ,pr_cdcooper_incorp => vr_cdcooper_incorp
                              ,pr_cdbcoctl_incorp => vr_cdbanctl_incorp
                              ,pr_cdagectl_incorp => vr_cdagectl_incorp

                          ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                              ,pr_dtmvtopr  => rw_crapdat.dtmvtopr
                              ,pr_dtleiarq  => vr_dtleiarq
                              ,pr_dtauxili  => vr_dtauxili

                              ,pr_vlchqvlb  => vr_vlchqvlb
                              ,pr_cdagenci  => vr_cdagenci
                              ,pr_tplotmov  => vr_tplotmov
                              ,pr_cdprogra  => vr_cdprogra
                          ,pr_dscritic  => vr_des_erro);
       ELSE
         --Executar rotina intergracao de todas as cooperativas
         pc_integra_todas_coop(pr_cdcooper  => pr_cdcooper
                              ,pr_nmrescop  => vr_nmrescop

                              ,pr_caminho   => vr_caminho_integra
                              ,pr_cdbcoctl  => vr_cdbanctl
                              ,pr_cdagectl  => vr_cdagectl
                              ,pr_cdbccxlt  => vr_cdbccxlt

                              ,pr_cdcooper_incorp => vr_cdcooper_incorp
                              ,pr_cdbcoctl_incorp => vr_cdbanctl_incorp
                              ,pr_cdagectl_incorp => vr_cdagectl_incorp

                              ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                              ,pr_dtmvtopr  => rw_crapdat.dtmvtopr
                              ,pr_dtleiarq  => vr_dtleiarq
                              ,pr_dtauxili  => vr_dtauxili

                              ,pr_vlchqvlb  => vr_vlchqvlb
                              ,pr_cdagenci  => vr_cdagenci
                              ,pr_tplotmov  => vr_tplotmov
                              ,pr_cdprogra  => vr_cdprogra
                              ,pr_dscritic  => vr_des_erro);
       END IF;
       -- Testar retorno de erro
       IF vr_des_erro IS NOT NULL THEN
         RAISE vr_exc_saida;
       END IF;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);
       --Salvar informacoes no banco de dados
       COMMIT;

     EXCEPTION
       WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_des_erro IS NULL THEN
          -- Buscar a descrição
          vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Se foi gerada critica para envio ao log
        IF vr_cdcritic > 0 OR vr_des_erro IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_des_erro );
        END IF;
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit pois gravaremos o que foi processo até então
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_des_erro IS NULL THEN
          -- Buscar a descrição
          vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_des_erro;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
     END;
   END pc_crps533;
/
