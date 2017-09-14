/* ..............................................................................

   Programa: var_taa.i
   Sistema : TAA - Cooperativa de Credito
   Sigla   : TAA
   Autor   : Edson/Evandro
   Data    : Janeiro/2010                         Ultima atualizacao: 03/07/2017
   
   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Criar variaveis globais para o TAA.

   Alteracoes: 01/10/2010 - Adicionada variavel para agencia da cooperativa na
                            central (Evandro).
                            
               23/02/2011 - Incluidas variaveis para controle de reboot e de
                            atualizacao do sistema (Evandro).
                            
               08/08/2011 - Incluidas variaveis para controle do PAINOP e
                            versao do sistema (Evandro).
                            
               08/11/2012 - Atualização para versão 5.7 (Evandro).
               
               17/01/2013 - Atualização para versão 5.8 e inclusão da variável
                            para indicação de conta migrada (Evandro).
                            
               05/02/2013 - Atualização para versão 5.9 e inclusão da variável
                            para indicação Prova de Vida INSS (Evandro).
							
			   18/04/2013 - Atualização para versão 6.0 (Evandro).
               
               31/05/2013 - Atualização para versão 6.1 (Evandro).
               
               04/07/2013 - Atualização para versão 6.2 (Evandro).
               
               26/08/2013 - Atualização para versão 6.3 (Evandro).
               
               28/08/2013 - Atualização para versão 6.4 (Evandro).
               
               29/08/2013 - Atualização para versão 6.5 (Evandro).
               
               05/09/2013 - Atualização para versão 6.6 (Evandro).
               
               04/10/2013 - Atualização para versão 6.7 (Jorge).
               
               06/12/2013 - Atualização para versão 6.8 (Evandro).
			   
			   09/04/2014 - Atualização para versão 6.9 (David).
               
               06/06/2014 - Atualização para versão 7.0 (Rafael)
			   
			   04/08/2014 - Atualização para versão 7.1 (David).
			   
			   07/10/2014 - Adicionada variavel xfs_imppapelsaida.
			                Atualização para versão 7.2 (David).
                            
               27/10/2014 - Incluido a variavel glb_tpusucar. (James)

               13/11/2014 - Atualização para versão 7.3 (David).			   
               
               08/12/2014 - Declaração de novo handle de frame para melhor
                            controle de navegação de tela em caso de erros
                            (Lunelli)
							
			   18/03/2015 - Atualização para versão 7.5 (David).
			   
			   24/04/2015 - Atualização para versão 7.6 (David).
               
               28/05/2015 - Criado variavel glb_flmsgtaa, referente a mensagem
                            de atraso em operacao de credito. (Jorge/Rodrigo)
							
			   27/08/2015 - Incluido a variavel glb_idtipcar. (James)
							
			   16/09/2015 - Atualização para versão 7.8 (David).
			   
			   30/09/2015 - Atualização para versão 7.9 (David).
			   
			   14/10/2015 - Atualização para versão 8.0 (David).
			   
			   17/11/2015 - Atualização para versão 8.1 (David).
                            
			   27/01/2016 - Adicionado variavel global glb_flgbinss. (Reinert)
                            
			   10/02/2016 - Atualização para versão 8.2 (David).

			   22/03/2016 - Atualização para versão 8.3 (Paulo Samuel).

			   22/04/2016 - Atualização para versão 8.4 (Paulo Samuel).

			   19/05/2016 - Atualização para versão 8.5 (Paulo Samuel).
			   
			   15/06/2016 - Atualização para versão 8.6 (Paulo Samuel).

			   17/08/2016 - Atualização para versão 8.7 (Paulo Samuel).

			   14/11/2016 - Atualização para versão 8.8 (Paulo Samuel).

			   23/11/2016 - Atualização para versão Emergencial 8.9 (Paulo Samuel).

			   08/12/2016 - Atualização para versão 9.0 (Paulo Samuel).

               19/01/2017 - Atualização para versão 9.1 (Paulo Samuel).

			   19/04/2017 - Atualização para versão 9.2 (Paulo Samuel).

			   18/05/2017 - Atualização para versão 9.3 (Paulo Samuel).

			   30/06/2017 - Atualização para versão 9.4 (Paulo Samuel).
			   
			   03/07/2017 - Atualização para versão 9.5 (David).

			   17/07/2017 - Atualização para versão 9.6 (Paulo Samuel).

			   17/08/2017 - Atualização para versão 9.7 (Paulo Samuel).

			   14/09/2017 - Atualização para versão 9.8 (Paulo Samuel).
.............................................................................. */

                            
/* Configuracoes do Terminal */
DEF {1} SHARED VAR glb_cdcoptfn AS INT                                   NO-UNDO. /* Coop do terminal */
DEF {1} SHARED VAR glb_nmcoptfn AS CHAR                                  NO-UNDO. /* Nome da Coop do terminal */
DEF {1} SHARED VAR glb_agctltfn AS INT                                   NO-UNDO. /* Agencia da Coop do terminal na Central */
DEF {1} SHARED VAR glb_nrterfin AS INT                                   NO-UNDO.
DEF {1} SHARED VAR glb_cdagetfn AS INT                                   NO-UNDO.
DEF {1} SHARED VAR glb_ipterfin AS CHAR                                  NO-UNDO.
DEF {1} SHARED VAR glb_nmserver AS CHAR                                  NO-UNDO. /* Servidor */
DEF {1} SHARED VAR glb_nmservic AS CHAR                                  NO-UNDO. /* Serviço WebSpeed */
DEF {1} SHARED VAR glb_dsvertaa AS CHAR     INIT "  v9.8"                NO-UNDO.

/* Temporizador */
DEF {1} SHARED VAR glb_nrtempor AS INT                                   NO-UNDO.
DEF {1} SHARED VAR glb_flreboot AS LOGICAL                               NO-UNDO.
DEF {1} SHARED VAR glb_flupdate AS LOGICAL                               NO-UNDO.

/* Saque Noturno */
DEF {1} SHARED VAR glb_hrininot AS INT                                   NO-UNDO.
DEF {1} SHARED VAR glb_hrfimnot AS INT                                   NO-UNDO.
DEF {1} SHARED VAR glb_vlsaqnot AS DEC                                   NO-UNDO.

/* Depositário */
DEF {1} SHARED VAR glb_tpenvelo AS INT                                   NO-UNDO.
DEF {1} SHARED VAR glb_qtenvelo AS INT                                   NO-UNDO.

/* Leitora de Cartão */
DEF {1} SHARED VAR glb_tpleitor AS INT                                   NO-UNDO.

/* Datas de Movimento */
DEF {1} SHARED VAR glb_dtmvtoan AS DATE                                  NO-UNDO.
DEF {1} SHARED VAR glb_dtmvtolt AS DATE                                  NO-UNDO.
DEF {1} SHARED VAR glb_dtmvtopr AS DATE                                  NO-UNDO.
DEF {1} SHARED VAR glb_dtmvtocd AS DATE                                  NO-UNDO.

/* Dados do Associado */
DEF {1} SHARED VAR glb_cdcooper AS INT                                   NO-UNDO. /* Coop do Associado */
DEF {1} SHARED VAR glb_cdagectl AS INT                                   NO-UNDO. /* Agencia na Central da Coop do Associado */
DEF {1} SHARED VAR glb_nmrescop AS CHAR                                  NO-UNDO. /* Nome da Coop do Associado */
DEF {1} SHARED VAR glb_nrcartao AS DEC                                   NO-UNDO.
DEF {1} SHARED VAR glb_nrdconta AS INT                                   NO-UNDO.
DEF {1} SHARED VAR glb_nmtitula AS CHAR         EXTENT 2                 NO-UNDO.
DEF {1} SHARED VAR glb_inpessoa AS INT                                   NO-UNDO.
DEF {1} SHARED VAR glb_idsenlet AS LOG                                   NO-UNDO.
DEF {1} SHARED VAR glb_flgmigra AS LOG                                   NO-UNDO.
DEF {1} SHARED VAR glb_flgdinss AS LOG                                   NO-UNDO.
DEF {1} SHARED VAR glb_flgbinss AS LOG                                   NO-UNDO.
DEF {1} SHARED VAR glb_tpusucar AS INT                                   NO-UNDO.
DEF {1} SHARED VAR glb_idtipcar AS INT                                   NO-UNDO.

/* Handle para a mensagem ao usuario */
DEF {1} SHARED VAR h_mensagem   AS HANDLE                                NO-UNDO.

/* Handle para o frame principal */
DEF {1} SHARED VAR h_principal  AS HANDLE                                NO-UNDO.
DEF {1} SHARED VAR h_inicializando  AS HANDLE                                NO-UNDO.


/* variavel de controle de mensagem atraso em operacao de credito */
DEF {1} SHARED VAR glb_flmsgtaa AS LOG                                   NO-UNDO.

/* Situacao do TAA:
   1 - Aberto
   2 - Fechado
   3 - Bloqueado
   4 - Suprido
   5 - Recolhido
*/
DEF {1} SHARED VAR glb_cdsittfn AS INTEGER                               NO-UNDO.

/* O TAA pode estar em outras situacoes e ao mesmo tempo estar suprido,
   por exemplo, o operador supriu o TAA e fechou (para bloquear saques)
   entao a situacao eh FECHADO mas tambem esta SUPRIDO */
DEF {1} SHARED VAR glb_flgsupri AS LOGICAL                               NO-UNDO.


/* Controles do TAA */
DEF {1} SHARED VAR glb_cdstaimp AS INT     EXTENT 8                      NO-UNDO.
/* status do cassete - informado pelo hardware */
DEF {1} SHARED VAR glb_cassetes AS LOGICAL EXTENT 5                      NO-UNDO.

/* status do cassete - informado pelo sistema - habilitado ou nao */
DEF {1} SHARED VAR sis_cassetes AS LOGICAL EXTENT 5                      NO-UNDO.

DEF {1} SHARED VAR glb_qtnotk7A AS INTEGER                               NO-UNDO.
DEF {1} SHARED VAR glb_qtnotk7B AS INTEGER                               NO-UNDO.
DEF {1} SHARED VAR glb_qtnotk7C AS INTEGER                               NO-UNDO.
DEF {1} SHARED VAR glb_qtnotk7D AS INTEGER                               NO-UNDO.
DEF {1} SHARED VAR glb_qtnotk7R AS INTEGER                               NO-UNDO.

DEF {1} SHARED VAR glb_vlnotk7A AS INTEGER                               NO-UNDO.
DEF {1} SHARED VAR glb_vlnotk7B AS INTEGER                               NO-UNDO.
DEF {1} SHARED VAR glb_vlnotk7C AS INTEGER                               NO-UNDO.
DEF {1} SHARED VAR glb_vlnotk7D AS INTEGER                               NO-UNDO.
DEF {1} SHARED VAR glb_vlnotk7R AS INTEGER                               NO-UNDO.

/* Variáveis do WOSA */
DEF {1} SHARED VAR aux_xfsliteh         AS HANDLE                        NO-UNDO.
                               
DEF {1} SHARED VAR xfs_wosa_ativa       AS LOGICAL                       NO-UNDO.
DEF {1} SHARED VAR xfs_impressora       AS LOGICAL                       NO-UNDO.
DEF {1} SHARED VAR xfs_impsempapel      AS LOGICAL                       NO-UNDO.
DEF {1} SHARED VAR xfs_imppapelsaida    AS LOGICAL                       NO-UNDO.
DEF {1} SHARED VAR xfs_dispensador      AS LOGICAL                       NO-UNDO.
DEF {1} SHARED VAR xfs_lcbarras         AS LOGICAL                       NO-UNDO.
DEF {1} SHARED VAR xfs_sensores         AS LOGICAL                       NO-UNDO.
DEF {1} SHARED VAR xfs_leitoraDIP       AS LOGICAL                       NO-UNDO.
DEF {1} SHARED VAR xfs_leitoraPASS      AS LOGICAL                       NO-UNDO.
DEF {1} SHARED VAR xfs_envelope         AS LOGICAL                       NO-UNDO.
DEF {1} SHARED VAR xfs_painop           AS LOGICAL                       NO-UNDO.
DEF {1} SHARED VAR xfs_painop_em_uso    AS LOGICAL                       NO-UNDO.

DEF {1} SHARED VAR aux_flgshutd         AS LOGICAL                       NO-UNDO.

/* .............................................................................. */
