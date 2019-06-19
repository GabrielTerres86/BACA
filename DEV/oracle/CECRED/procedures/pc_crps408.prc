create or replace procedure cecred.pc_crps408 (pr_cdcooper in craptab.cdcooper%TYPE
                     ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                     ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                     ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                     ,pr_cdcritic out crapcri.cdcritic%TYPE
                     ,pr_dscritic out varchar2) as
/* ..........................................................................

   Programa: PC_CRPS408 (Antigo Fontes/crps408.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Setembro/2004.                  Ultima atualizacao: 19/07/2018

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Atende a solicitacao 027.
               Gerar arquivo de pedido de cheques.
               Relatorios :  392 e 393 (Cheque)
                             572 e 573 (Formulario Continuo)

   Alteracoes: 14/03/2005 - Modificada a busca da data do tempo de conta do
                            associado (Evandro).

               18/03/2005 - Modificado o FORMAT da C/C INTEGRACAO (Evandro).

               05/07/2005 - Alimentado campo cdcooper das tabelas crapchq e
                            crapped (Diego).

               16/08/2005 - Alterar recebimento de email de talonarios (de
                            fabio@cecred para douglas@cecred) (Junior).

               03/10/2005 - Formulario Continuo ITG (Ze).

               13/10/2005 - Ajuste no "Cooperado desde" (Ze).

               17/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).

               31/10/2005 - Tratar crapchq.nrdctitg, crapreq.dtpedido e
                            crapreq.nrpedido (Ze).

               02/11/2005 - Substituicao da condicao crapfdc.nrdctitg = STRING(
                            aux_nrdctitg por crapfdc.nrdctitg =
                            crapass.nrdctitg. (SQLWorks - Andre).

               07/12/2005 - Revisao do crapfdc (Ze Eduardo).

               23/12/2005 - Inclusao do parametro "tipo de cheque" no fonte
                            calc_cmc7.p  (Julio).

               20/01/2006 - Acerto no relatorio de criticas (Ze).

               09/02/2006 - Nao solicitar para Cta. Aplicacao (Ze).

               14/02/2006 - Alterado para ler folhas ao inves de taloes para o
                            "Formulario Continuo" (Evandro).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               18/08/2006 - Alteracao para solicitar taloes de 10 folhas
                            (Julio)

               30/08/2006 - Alterado envio de email pela BO b1wgen0011 (David)
                            Mudanca de CGC para CNPJ (Ze).

               29/11/2006 - Criticar qdo tipo de conta for Individual e tiver
                            mais de um titular (Ze).

               13/12/2006 - Alterado envio de e-mail de makelly@cecred.coop.br
                            para jonathan@cecred.coop.br (David).

               02/01/2007 - Alterado para enviar talonarios do convenio Bancoob
                            (Ze).

               27/02/2007 - Tirar condicao p/ tipo 3 - tratar conforme qtd.
                            folhas no cadastro do cooperado (ass).
                            Tirar condicao p/ tipo 3 - put no arq.p/ interprint
                            qdo conta <> conta_ant e tprequis <> tprequis_ant
                            (Ze Eduardo).

               19/03/2007 - Padronizacao dos nomes de arquivo (Ze).

               21/03/2007 - Acerto no programa (Ze).

               18/04/2007 - Tratar sequencia do nro pedido atraves do gnsequt
                            Sequencia unica para todas as cooperativas e
                            Acerto no programa para conta com 8 digitos (Ze).

               30/04/2007 - Para Bancoob eliminar Grp. SETEC e tratar C1 E
                            Acerto no CHEQUE ESPECIAL para Bancoob (Ze).

               18/05/2007 - Mudanca de leiate referente ao Grp. SETEC
                            Segundo Digito do 3o Campo do CMC-7 (Ze).

               14/08/2007 - Alterado para pegar a data de abertura de conta mais
                            antiga do cooperado cadastrada na crapsfn (Elton).

               09/10/2007 - Remover envio de email de talonarios (douglas@cecred
                            e jonathan@cecred) (Guilherme).

               25/02/2008 - Enviar arquivos para Interprint atraves da Nexxera
                            (Julio).

               02/07/2008 - Nao tratar mais os formularios continuos pois o
                            programa crps296.p faz isso (Evandro).

               19/08/2008 - Tratar pracas de compensacao (Magui).

               02/12/2008 - Utilizar agencia na geracao do arq BB pelo
                            crapcop.cdageitg e calcular o digito da agencia
                            (Guilherme).

               27/02/2009 - Acerto na formatacao do crapcop.cdageitg - digito
                            da agencia (Ze).

               26/05/2009 - Permitir gerar relatorios de pedidos zerados para
                            Intranet (Diego).

               30/09/2009 - Adaptacoes projeto IF CECRED
                          - Alterar inhabmen da crapass para crapttl(Guilherme).

               01/03/2010 - Tratar formulario continuo para IF CECRED
                            (Voltar alteraçao do dia 02/07/2008) (Guilherme).

               30/07/2010 - Verificar AVAIL crapage para endereco do PAC
                            (Guilherme).

               25/08/2010 - A pedidos do suprimentos, criar relatorios 572 e 573
                            para Form. Cont. baseado no 247 e 248 (Guilherme).

               11/10/2010 - Acerto no rel. 572 - rel_cdagenci (Trf.35393) (Ze).

               10/02/2011 - Utilizar camnpos ref. Nome no talao - crapttl
                           (Diego).

               18/08/2011 - Alimentar campo da Data Confec. do Cheque (Ze).

               12/12/2011 - Imprimir somente os relatorios do Banco 085
                            - Trf. 43974 (Ze).

               24/09/2013 - Conversão Progress >> Oracle PL/SQL (Andrino - RKAM).

               12/12/2011 - Imprimir somente os relatorios do Banco 085
                            - Trf. 43974 (Ze).

               22/01/2014 - Incluir VALIDATE crapped, crapfdc (Lucas R.)

               23/01/2014 - Incluido variavel aux_flggerou na procedure
                            p_gera_talonario, afim de controlar se foi
                            gerado arquivo de requisicao de talao/formulario
                            de cheque, para disponibilizar tais arquivos no
                            diretorio de envio a Nexxera. (Fabricio)

               20/02/2014 - Conversão das alterações de 01/2014 (Daniel - Supero)

               10/11/2014 - Alterado tamanho do nmrescop de 11 posições para 20
                            (Lucas R./Gielow Softdesk #6850)

               27/02/2015 - Retirado 9 posições da geração do arquivo 314 para 305
                            na parte final do arquivo (Lucas R.)
                            
               17/09/2015 - Ajustes referente impressão de cheque com empresa RRD
                            (Daniel)             
                            
               22/01/2016 - Inclusao do CNPJ da Cooperativa no resumo de Pedido
                            (Daniel)      
							
			         01/09/2016 - Geração de arquivos de formularios continuos para
                            RRD (Elton - SD 511158)			                   
                            
               25/10/2016 - #524279 Ajustado para que os pedidos sejam acumulados e enviados ao fornecedor 
                            quinzenalmente (todo dia 1º e todo dia 15 de cada mês, quando se tratar de finais 
                            de semana ou feriados devem ser enviados no primeiro dia útil posterior). (Carlos)

			   21/03/2017 - Ajuste para gerar número de pedido distinto por tipo de requisição (Rafael Monteiro)

               24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).


               24/07/2017 - Alterar cdoedptl para idorgexp.
                            PRJ339-CRM  (Odirlei-AMcom)

			   26/09/2017 - Ajuste para alimentar corretamente a vr_nmsegtal, 
			                para evitar que impacte no layout dos arquivos
							(Adriano - SD 762235).
              
              
               24/10/2017 - Buscar idorgexp apenas para PF.
                            PRJ339-CRM  (Odirlei-AMcom)
 
               30/04/2018 - Buscar descricao de situacao pela procedure pc_descricao_situacao_conta.
                            Permite talonario pela procedure pc_ind_impede_talonario. PRJ366 (Lombardi).
 
               21/05/2018 - Utilizar dtvigencia no subselect da tabela tbcc_produtos_coop. 
                            PRJ366 (Lombardi).
                            
               11/07/2018 - Ajuste feito para tratar requisicoes com agencia zerada. (INC0019189 - Kelvin/Wagner)                            

			   01/08/2018 - Adaptar a regra que envia o literal6 para impressão da frase "Cheque especial"
                            no talonário, para verificar se o cooperado possui limite de crédito habilitado
                            na conta. (Renato Darosci)

               18/07/2018 - Validação de sucesso no envio de talonário para RR Donnelley
                            SCTASK0017339
                            Paulo Martins (Mout´s)       
               19/07/2018 - Alterar a atualizacao da gnsequt para trabalhar com pragma
                            evitando dessa forma as ocorrencias constantes de locks
                            que aparecem rapidamente no BD no inicio do batch.
                            (SCTASK0015571) - (Fabricio)

			   28/08/2081 - Ajuste no cursor cr_crapreq (Andrey Formigari - Mouts) #PRB0040295	

			   24/01/2019 - Retirado o ajuste no cursor cr_crapreq. 
                            Acelera - Entrega de Talonarios no Ayllos (Lombardi)
                            
         20/05/2019 - Substitui toda a logica anterior do programa pela chamada da rotina 
                      cheq0003.pc_gera_arq_grafica_cheque
                      Renato Cordeiro - AMcom
 
............................................................................. */

  -- Codigo do programa
  vr_cdprogra      crapprg.cdprogra%type;
  
  -- Tratamento de erros
  vr_exc_fimprg    EXCEPTION;
  vr_exc_saida     EXCEPTION;

/*------------------------------------
-- INICIO DA ROTINA PRINCIPAL
--------------------------------------*/
BEGIN
  -- Nome do programa
  vr_cdprogra := 'CRPS408';
  -- Validacões iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => pr_cdcritic);
  -- Se retornou algum erro
  IF pr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  -- Incluir nome do modulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS408',
                             pr_action => vr_cdprogra);

  cheq0003.pc_gera_crapfdc(pr_cdcooper => pr_cdcooper, 
                           pr_flgresta => pr_flgresta, 
                           pr_stprogra => pr_stprogra, 
                           pr_infimsol => pr_infimsol, 
                           pr_cdcritic => pr_cdcritic, 
                           pr_dscritic => pr_dscritic);

  -- Testar se houve erro
  IF nvl(pr_cdcritic,0) <> 0 or pr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  --
  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
END;
/
