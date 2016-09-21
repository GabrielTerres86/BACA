/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                     |
  +---------------------------------+-----------------------------------------+
  | includes/crps642.i              | SICR0001                                |
  | PROCEDURES:                     | PROCEDURES:                             |
  |   obtem-agendamentos-debito     |   sicr0001.obtem_agendamentos_debito    |
  |   efetua-debitos                |   sicr0001.pc_efetua_debitos            |
  |   gera-relatorio                |   sicr0001.pc_gera_relatorio            |
  +---------------------------------+-----------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
    - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*..............................................................................

   Programa: includes/crps642.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Lunelli
   Data    : Abril/2013                       Ultima atualizacao: 01/10/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Procedimentos para o debito de agendamentos de
               convenios SICREDI feitos na Internet. 

   Alteracoes: 24/04/2013 - Ajustes Sicredi (Elton).
               
               21/05/2013 - Ajustes para verificar se deve realizar o debito 
                            (Elton).
                            
               26/08/2013 - Bloquear execucao do programa no processo anual de
                            2013 da Acredi devido migracao para Viacredi (David)
                            
               21/01/2014 - Alterado de PAC para PA. (Reinert)                            
                                        
               21/05/2014 - Ajustes referentes ao Projeto Debito automatico
                            Softdesk 145056 (Lucas R.)
                            
               07/08/2014 - Bloquear execucao do programa no processo mensal de
                            novembro de 2014 da Concredi devido migracao para 
                            Viacredi (David).
                            
               03/09/2014 - Ajustes migracao Credimilsul -> Screcred / 
							Concredi -> Viacredi (Jean Michel).
                            
               24/09/2014 - Incluir ajustes referentes ao debito automatico,
                            incluido IF craplau.cdhistor = 1019 na procedure
                            obtem-agendamentos-debito (Lucas R./Elton)
                            
               14/01/2015 - Correção no preenchimento do nr. do documento na 
					        criação da crapndb (Lunelli)
                            
               30/03/2015 - Alterado na leitura da craplau para quando for
                           Debito automatico (1019), buscar as datas de
                           pagamentos tambem menores que a data atual, isto
                           para os casos de pagamentos com data no final de
                           semana. (Fabricio)
                           
               06/05/2015 - Atualizada data do último débito na tabela de 
                            autorizações (crapatr) (Lucas Lunelli - SD 256257)
                            
               01/10/2015 - O crps642 já está convertido para Oracle. Eliminar
                            as procedures do fonte e utilizar as convertidas em 
                            oracle. (Douglas - Chamado 285228 obtem-saldo-dia)
............................................................................ */
