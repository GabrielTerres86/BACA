/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps249.p                | pc_crps249                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO)

*******************************************************************************/




/* ..........................................................................

   Programa: Fontes/crps249.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/98                     Ultima atualizacao: 27/09/2013

   Dados referentes ao programa:

   Frequencia: Diario. Exclusivo.
   Objetivo  : Atende a solicitacao 76.
               Gerar arquivo para contabilidade.
               Ordem do programa na solicitacao 1.

   Alteracoes: 12/03/1999 - Diminuir a quantidade de cdestrut (Odair)

               06/01/2000 - Buscar dados da cooperativa no crapcop (Edson).
               
               11/05/2000 - Ler lancamentos de custodia (Odair)
               
               13/07/2000 - Tratar custos de cheques (Odair)

               21/08/2000 - Tratar cheque salario Banccob (Deborah). 

               15/09/2000 - Tratar os titulos compensaveis (Edson).

               11/01/2001 - Tratar IPTU, tipo de lote 21 (Deborah).

               22/01/2001 - Contabilizar receita dos lotes tipo 20 e 21 
                            (Deborah).

               03/04/2001 - Contabilizar o boletim de caixa (Edson).

               24/04/2001 - Alterado o centro de custos para apenas 2 casas 
                            (Edson).
                
               05/05/2001 - Contabilizar a comp. eletronica (Edson).

               21/05/2002 - Permitir qualquer dia para custodia(Margarete).

               12/05/2003 - Contabilizar o desconto de cheques (Edson).

               21/08/2003 - Acerto na contabilizacao da liberacao dos cheques
                            descontados (Edson).
                            
               16/10/2003 - Alteracao na contabilizacao do desconto de cheque
                            (Julio).

               17/10/2003 - Tratar resgate no desconto de cheques (Edson).

               05/11/2003 - Ler historicos para buscar conta contabil (Edson).
               
               12/11/2003 - Tratar transferencia da custodia para o desconto de 
                            cheques (Edson).

               11/12/2003 - Ajuste na contabilizacao do resgate de cheques
                            descontados (Edson).

               06/01/2004 - Ajuste na contabilizacao do resgate de cheques
                            descontados (Edson).

               12/01/2004 - Excluida a contabilizacao da tarifa sobre titulos
                            recebidos no caixa (Edson).

               11/02/2004 - Contabilizar o saldo dos limites de descontos de
                            cheques (Edson).
               
               20/02/2004 - Contabilizar Historicos(557-DOC/558-TED) - Arquivo
                            craptvl.Criado progr.crps249_4(Mirtes).

               30/03/2004 - Tratar o tipo de contabilizacao por caixa 6
                            (Edson).

               28/04/2004 - Tratar parcelamento do capital (Edson).

               12/05/2004 - Obter dados da tabela craphis para o Historico 130
                            - Prefeitura Municipal Blumenau(Mirtes).

               17/05/2004 - Alterar historico 130 para 373.

               09/06/2004 - Contabilizar a reversao da subscricao de capital
                            para planos dos demitidos (Edson).
               
               21/09/2004 - Tratar historicos da conta investimento (Edson).

               23/11/2004 - Tratar COBAN (Edson).

               02/12/2004 - Ajuste na contabilizacao do COBAN (Edson).

               09/02/2005 - Novos historicos Conta Investimento(647/648)(Mirtes)
              
               07/04/2005 - Ajuste na contabilizacao da REVERSAO da subscricao
                            de capital (Edson).

               28/06/2005 - Formato do campo craplcx.dsdcompl(Mirtes).
               
               09/08/2005 - Tratar lancamentos Tarifa CTITG (Ze Eduardo).

               26/08/2005 - Novo historico Pagto GPS(458)(Mirtes)

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               28/09/2005 - Desconsiderar lancamentos de tarifa de
                            cheques cta integracao TESTE CREDCREA. (Ze). 

               23/11/2005 - Ajustes no lancamentos de tarifas de cheques (Ze)

               02/01/2006 - Ajustes na contabilizacao da Baixa do saldo do
                            capital dos inativos no processo ANUAL (Edson).

               10/01/2006 - Tratar historico 459 - Recebimento INSS(Mirtes)
               
               25/01/2006 - Efetuar unico lancamento para CTA ITG (Ze).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               22/03/2006 - Contabilizacao Bloquetos Viacredi (Mirtes).
               
               06/04/2006 - Acerto nos lancamentos gerenciais das tarifas (Ze).

               08/06/2006 - Desenvolver o Gerencial a Credito e a Debito (Ze).
               
               12/06/2006 - Acerto no historico 459 (Ze).

               22/06/2006 - Contabilizacao do orcamento no processo mensal
                            (Edson).

               14/07/2006 - Correcao na contabilizacao do orcamento (Edson).

               17/08/2006 - Correcao na contabilizacao do orcamento (Edson).
               
               30/08/2006 - Desprezar as tarifas de Cheque ref. cta. Base (Ze).

               18/10/2006 - Correcao na contabilizacao do orcamento (Edson).
               
               13/12/2006 - Contabilizar os lancamentos da Conta Salario (Ze).
               
               26/02/2007 - Contabilizar hist. 266 atraves da conta que esta
                            cadastrado na tela HISTOR  (Ze).
               
               02/04/2007 - Tratamento hst. 542 e 549 (Bancoob) e hst. 731 (Ze)
               
               09/07/2007 - Tratar tarifa para os historicos 547 e 546 (Ze).
               
               14/11/2007 - Incluir RDCPRE e RDCPOS no orcamento (Magui).
               
               07/12/2007 - Cancelado lancamento automatico de tarifa
                            Bancoob, historico 547 (Magui).
                            
               21/01/2008 - Incluir os historicos do INSS - BANCOOB (Evandro).
               
               31/03/2008 - Inclusao do historico 582 para GUIAS GPS (Evandro).
                          - Nao utilizar mais o craphis.vltarifa usar a nova
                            estrutura de tarifas - crapthi(Guilherme)
                          - Inclusao de tarifas de pagamento de GPS (Guilherme).
                          - Nao gerar tarifas INSS com valor zerado (Evandro).
                          
               20/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               12/08/2008 - Conta 4236 para 4257 no orcamento poupanca (Magui).
               
               02/10/2008 - Falta virgula no 4257 do orcamento (Magui).

               03/10/2008 - Adaptacao para Desconto de Titulos (David).
               
               05/12/2008 - Considerar crapcdb.insitchq para cheque resgatados
                            no dia (Evandro).
                            
               18/12/2008 - A pedido da contabilidade, separar desconto de
                            titulos pagos pelo sacado dos pagos pelo cedente
                            (Evandro).
                            
               05/01/2009 - Lancar liquidacao de titulos descontados pagos pelo
                            sacado na data de pagamento e nao na data de
                            vencimento (melhoria para contabilidade) (Evandro).
                            
               12/01/2009 - Efetuar os lancamentos de liquidacao do desconto de
                            titulos (quando o titulo for pago) com valor do
                            pagamento;
                          - Separar pagamentos de desconto de titulos efetuados
                            no CAIXA e atraves da COMPE (Evandro).
                            
               13/01/2009 - Tratamento para feriado e fins de semana para o
                            desconto de titulos no caso de debito na conta do
                            cedente - idem crps517.p;
                          - Na apropriacao do desconto de titulos, deve ser
                            considerado o valor total, sem tirar o abatimento
                            (Evandro).
                            
               23/01/2009 - Evitar duplicacao de lancamento de liquidacao de
                            desconto de titulos devido as datas calculadas nos
                            feriados e fins de semana (Evandro).

               28/01/2009 - Gerar registro de tarifas de cobranca de desconto
                            de titulos (Guilherme).
                            
               10/02/2009 - Alterado a apropriacao para lancar na conta contabil
                            1644 o valor total sem tirar o abatimento.
                            craptdb.vltitulo - craptdb.vlliquid. 
                            Comentario 1 na Tarefa: 22255 
                          - Lancar liquidacao de titulos descontados pagos pelo
                            sacado via COMPE com D+1(Guilherme).
                            
               10/02/2009 - Alterar a Conta a Credito do Historico 561 (Ze).
               
               26/02/2009 - Correcao no FIND crapcob: utilizar a chave. Estava
                            sem o convenio. (Guilherme).
                            
               10/03/2009 - Se o titulo nao for pago nao soma os juros dos 
                            proximos meses caso o titulo for pago soma somente 
                            no mes - Desconto de Titulos - (Guilherme).
                            
               30/03/2009 - Tratar titulos em Desconto pagos via internet como
                            CAIXA cob.indpagto = 3 cob.indpagto = 1
                            Tarefa 23393 - (Evandro/Guilherme).
                            
               09/04/2009 - Ajuste no resgate de desconto de titulos
                            (Evandro/Guilherme).
                            
               14/04/2009 - Ajustar os lanc. do hist. 561 - Tarefa 23664 (Ze).
               
               05/05/2009 - Utilizar glb_cdcooper no FIND do crapfer (David);
                          - Ajuste na apropriacao do desconto de titulos
                            (Evandro).
                            
               13/05/2009 - Substituir a tab "ContaConve" pela gnctace (Ze).
               
               08/07/2009 - Se forem titulos resgatados nao soma os juros 
                            restituidos na apropriacao final do mes,
                            pois eles ja foram lancados a debito 
                            na 1644 no dia que o titulo eh resgatado(Guilherme).

               11/08/2009 - Incluir tarifa de Internet no craplft(Faturas) (Ze) 

               28/08/2009 - Substituicao do campo banco/agencia da COMPE/TITULO
                            para o banco/agencia - (Sidnei - Precise);
                            
                          - Tratar borderos de desconto de titulos que forem
                            liberados e liquidados no mesmo dia e nao
                            considerar a data de vencimento nos titulos em
                            aberto (sit=4) porque a liquidacao esta rodando
                            antes no processo batch (Evandro).
                            
               29/09/2009 - Tratar titulos resgatados no mesmo dia da liberacao
                            para desconsidera-los (Evandro).
                           
               15/10/2009 - Inclusao de tratamento para banco CECRED junto com
                            BB e Bancoob. (Guilherme - Precise)
                            
               02/02/2010 - Alteracao codigo historico (Diego).

               25/05/2010 - Contab. TEC nossa IF, histor 827 (Magui).
               
               27/05/2010 - Contab. Titulos nossa IF, histor 824 (Magui).
               
               10/06/2010 - Incluido tratamento para pagamento atraves de TAA
                            (Elton).
                            
               02/07/2010 - Tratar hist. 560, 561 e 562 - Gerencial (Ze).
               
               11/08/2010 - Tratar hist. 827 - Gerencial - Tarefa 34295 (Ze).
               
               20/08/2010 - Acumular o valor de desconto de titulos na crapprb,                             separado por prazo. Tarefa 34547 (Henrique)
                             
               12/09/2010 - Inserir novos prazos. (Henrique).              
               
               01/11/2010 - Tratamento para separar Emprestimos X Financiamen.
                          - Incluido Saldos Financiados. (Irlan).
                          
               11/11/2010 - Tratar historicos 918 e 920 referente TAA
                            compartilhado (Diego).
                            
               12/11/2010 - Quando virada do ano nao usar crapcot.vlcapmes,
                            usar crapcot.vlcotant. Campo crapcot.vlcapmes
                            zerado no crps011 que roda antes (Magui).
                            
               12/07/2011 - Ajuste nas contas contabeis do hist. 266 
                            - Tarefa 41091 (Ze).
                            
               19/07/2011 - Ajuste na contabilizacao dos hist. 971 e 977
                            - Tarefa 41181 e 41185 (Ze).

               22/07/2011 - Tratamento dos hist. 936,937,938,939,940,965,966 e
                            973 - Cobranca Registrada (Ze).

               25/08/2011 - Atualizar vlslfmes aqui quando ultimo dia do
                            mes para nao dar erro no orcado por Pac (Magui).
                            Criar orcado por Pac para o his 110 (Magui).
                            Orcado do desconto de cheques e de titulos
                            passar a usar o data do ultimo dia do mes (Magui).
                            Criar orcado por Pac para o his 930 (Magui).

               01/09/2011 - Tratamento do histórico 98 e 277
                            Juros e Estorno sobre EMPREST X FINANC (Irlan)
                            
               12/09/2011 - Tratamento hist 971 - Cred. Cobr. BB (Rafael).
               
               21/09/2011 - Tratamento para Rotina 66 (LANCHQ) - Desprezar hist.
                            731 (Ze).
                            
               04/11/2011 - Tratamento hist. 1018 ref. Transferencia 
                            TEC SALARIO entre cooperativas (Diego).
                            
               06/01/2012 - Tratamento hist. BB - Cob.Registrada - garantir
                            lancamentos > 0. (Rafael)
                            
               16/05/2012 - Ajuste na contabilizacao dos hist. 1088 e 1089
                            ref a liquidacao apos baixa BB e CECRED. (Rafael)
                            
               17/05/2012 - Gravacao da tabela crapopc, controle de desconto
                            e resgate de cheque e titulos (Tiago).
                            
               02/10/2012 - Ajuste nos lanctos de titulos descontados da 
                            cob. registrada (Rafael).
                            
               31/12/2012 - Gerar lanctos contabeis ref ao acerto financeiro
                            entre as contas BB Viacredi e Alto Vale (Rafael).
                            
               16/01/2013 - Ajuste no lancto de acerto financeiro BB por PAC
                            na Alto Vale ref. ao debito de tarifas (Rafael).
                            
               25/03/2013 - Tratamento para historico 1154 - Sicredi (Elton).
               
               23/04/2013 - Ajuste das tarifas de titulos descontados dos 
                            títulos migrados (Rafael).
               
               26/04/2013 - Tratamento para faturas DPVAT - Sicredi (Elton).
               
               14/05/2013 - Tratamento para DARF's sem codigo de barras e 
                            ajustes para convenios Sicredi (Elton).
                            
               28/05/2013 - Ajustes no valor total das DARF's (Elton).
               
               07/06/2013 - Desprezar operacoes do BNDES no lancamento ref.
                            'FINANCIAMENTOS REALIZADOS' (Diego).
                            
               10/06/2013 - 2da fase do Credito (Gabriel).             
               
               11/06/2013 - Incluido NO-LOCK na leitura da craplft (Elton).
               
               13/06/2013 - Incluido o registro de TEDs rejeitadas (887); apos
                            TED conta salario (Carlos).
                            
               05/07/2013 - Incluido historico 801 - TEC DEVOLVIDA (Diego). 
               
               12/08/2013 - Utilizar data de lançamento (crapafi.dtlanmto)
                            ao contabilizar lançamentos do Acerto Financeiro BB
                            entre cooperativas migradas. (Rafael)
                            
               21/08/2013 - Ajustado processo geracao arquivo contabilidade,
                            devido alteracao processo tarifa. (Daniel) 

               23/08/2013 - softdesk 82990 - Retirado do relatorio o calculo 
                            de tarifas GPS Bancoob. (Carlos)

               27/09/2013 - Ajuste no processo de debito tarifa com e sem registro
                            (Daniel).
............................................................................ */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps249"
       glb_cdcritic = 0
       glb_dscritic = "".
       
RUN fontes/iniprg.p.

IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

    RETURN.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps249 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
    INPUT INT(STRING(glb_flgresta,"1/0")),
    OUTPUT 0,
    OUTPUT 0,
    OUTPUT 0, 
    OUTPUT "").

IF  ERROR-STATUS:ERROR  THEN DO:
    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + 
                              ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
    END.
        
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao executar Stored Procedure: '" +
                      aux_msgerora + "' >> log/proc_batch.log").
    RETURN.
END.

CLOSE STORED-PROCEDURE pc_crps249 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps249.pr_cdcritic WHEN pc_crps249.pr_cdcritic <> ?
       glb_dscritic = pc_crps249.pr_dscritic WHEN pc_crps249.pr_dscritic <> ?
       glb_stprogra = IF pc_crps249.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps249.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                          "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

        RETURN.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                  
RUN fontes/fimprg.p.

