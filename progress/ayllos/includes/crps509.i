/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+---------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                   |
  +---------------------------------+---------------------------------------+
  | includes/crps509.i              | AGEN0001                              |
  | obtem-agendamentos-debito       | AGEN0001.pc_obtem_agend_debito        |
  | efetua-debitos                  | AGEN0001.pc_efetua_debitos            |
  | gera-relatorio                  | AGEN0001.pc_gera_relatorio            |  
  +---------------------------------+---------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/








/*..............................................................................

   Programa: includes/crps509.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Maio/2008                        Ultima atualizacao: 15/07/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Procedimentos para o debito de agendamentos feitos na Internet. 

   Alteracoes: 22/07/2008 - Mostrar critica quando debito nao efetuado (David).
   
               17/07/2009 - Tratamento para o parametro "cdoperad" nas 
                            procedures de debito (David).

               27/08/2009 - Alteracoes do Projeto de Transferencia para 
                            Credito de Salario (David).

              28/06/2010 - Funcao obtem-agendamentos-debito alterada para tratar
                           crapcop.cdcooper ao inves de glb_cdcooper e funcao
                           efetua-debitos alterado parametro passado para a BO16
                           de glb_cdcooper para w_agendamentos.cdcooper
                           (Guilherme/Supero)
                           
              23/03/2011 - Feito ajuste devido o agendamento no sistema TAA
                           (Henrique).
                           
              12/04/2011 - Alterado para realizar os débitos utilizando somente
                           o operador 996 (Henrique).
                           
              09/05/2011 - Adicionado titular que efetuou o agendamento
                           (Evandro).
                           
              01/06/2011 - Melhoria de Performance (Evandro).
              
              17/06/2011 - Alterado para gerar relatorio separado para da coop
                           quando rodar pela tela debnet (Henrique).
                           
              04/11/2011 - Alterar origem internet de 1 para 3 (Guilherme).
              
              23/11/2012 - Bloquear execucao do programa no processo anual de
                           2012 da Viacredi devido a migracao da Alto Vale,
                           pois esse processo sera executado antes da migracao.
                           Agendamentos para o dia 02/01/2013 deverão ser
                           lancados na nova cooperativa (David).
                           
              18/04/2013 - Restringir consulta por histórico, evitando
                           abranger lançamentos de Conv. SICREDI (Lucas).
                           
              19/04/2013 - Transferencia intercooperativa (Gabriel).             
              
              27/04/2013 - Ajuste tratamento Sicredi (Elton).
              
              11/07/2013 - Alterada procedure 'obtem-agendamentos-debito' para
                           informar cooperativa de origem da conta da transferencia
                           (Lucas).
                           
              26/08/2013 - Bloquear execucao do programa no processo anual de
                           2013 da Acredi devido migracao para Viacredi (David).
              
              07/10/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).


              29/01/2014 - Chamar rotina de debito de pagamento do PL/SQL
                           (Gabriel).
                           
              30/04/2014 - Ajustado parametros da procedure pc_debita_agendto_pagto
                           (Daniel).            
                           
              07/08/2014 - Bloquear execucao do programa no processo mensal de
                           novembro de 2014 da Concredi devido migracao para 
                           Viacredi (David).
                           
              03/09/2014 - Inclusao de tratamento para migracao CREDIMILSUL => SCRCRED,
                           CONCREDI => VIACREDI (Jean Michel).
                           
              12/01/2015 - Passar a considerar convenios nossos (CECRED) para
                           realizar o debito atraves da DEBNET; quando for
                           executado fora do processo noturno.
                           (Chamado 229249 # PRJ Melhoria) - (Fabricio)
              
              27/03/2015 - Criado novo campo para temp table w_agendamento
                           "dsdocmto" para nao estourar format na hora
                           de mostrar na tela debnet do Progress
                           (SD270304 - Tiago).
                           
              30/03/2015 - Alterado na leitura da craplau para quando for
                           Debito automatico (DEBAUT), buscar as datas de
                           pagamentos tambem menores que a data atual, isto
                           para os casos de pagamentos com data no final de
                           semana. (Ajustes pos-liberacao # PRJ Melhoria) - 
                           (Fabricio)
                           
              15/07/2015 - O crps509 já está convertido para Oracle. Eliminar
                           as procedures do fonte e utilizar as convertidas em 
                           oracle. (Douglas - Chamado 285228 obtem-saldo-dia)

..............................................................................*/

