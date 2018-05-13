/* ............................................................................

   Programa: Fontes/cash.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/99                            Ultima alteracao: 22/04/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CASH - Saldo nos cash dispensers.

   Alteracoes: 26/05/1999 - Incluidas as opcoes Configuracao e Saldos 
                            Anteriores (Edson).

               11/06/2002 - Mostrar numero de lacres (Edson).
               
               14/10/2004 - Mostrar o numero do Cartao permitindo "rolagem"
                            lateral da frame f_saques (Evandro).

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               13/02/2006 - Inclusao do parametro glb_cdcooper na chamada do 
                            programa fontes/zoom_cash.p - SQLWorks - Fernando

               30/05/2006 - Tratar rotina de entrega de envelopes nos ATMs
                            (Edson).

               10/07/2006 - Tratar opcao LOG - visualizacao do log dos cashes
                            (Edson).
                            
               14/12/2006 - Incluido tratamento referente deposito de envelopes
                            (Diego).

               27/09/2007 - Mostrar a situacao do caixa (Edson).

               28/11/2007 - Incluidas opcoes de Abertura e Fechamento do Cash
                            (Diego).
                            
               11/12/2007 - Incluida opcao Envelopes para listagem dos
                            Recolhimentos (Diego).

               28/12/2007 - Tratar estorno de saque (Edson).
               
               02/01/2008 - Tratar totalizacao de Lanctos Estorno (Ze).
               
               07/11/2008 - Troca do Histor. 359 p/ 767 (Estorno Debito) (Ze).
               
               20/02/2009 - Incluir Opcao de Inclusao e Alteracao (Ze/Fernando).

               17/06/2009 - Alterar nome do campo "Agencia" para "PAC" no frame
                            f_config.
                            Alterar funcao CAPS por LC ao criar/alterar o campo
                            craptfn.nmnarede (Fernando).
                            
               30/06/2009 - ALteracao CDOPERAD (Diego).
               
               02/10/2009 - Aumento do campo nrterfin (Diego).
               
               31/03/2010 - Adequacoes para o novo sistema do cash (Evandro).
               
               24/06/2010 - Acerto para mostrar envelopes depositados no
                            sistema antigo (Evandro).
                            
               09/08/2010 - Corrigida a rotina de desbloqueio e incluida
                            mensagem de confirmacao para bloqueio e para
                            desbloqueio (Evandro).
                            
               24/08/2010 - Desconsiderar o valor rejeitado na exibicao do
                            recolhimento (Evandro).
                            
               28/10/2010 - Incluisão dos históricos 918(Saque) e 920(Estorno)
                            devido ao TAA compartilhado (Henrique).

               29/10/2010 - Incluisão da Opcao "R" (Guilherme/Supero)
               
               09/12/2010 - Aumento o campo de descricao do cash (Henrique).
               
               13/12/2010 - Ajustado contabilizacao do saldo e adicionada
                            situacao 3-recolhido nos envelopes (Evandro).
                            
               06/01/2011 - Alterada a opcao de inclusao para que seja definido
                            o campo craptfn.flsistaa como TRUE (Henrique).

               24/01/2011 - No relat Sintetico, alterado para que some sempre 
                            a qntde da TT e nao apenas +1 como estava antes
                            (Guilherme/Supero)
                            
               08/02/2011 - Retirado conexoes com o banco farol e os campos 
                            de data e hora do cash (Elton).
                            
               09/03/2011 - Adicionada opcao "B" para controle de Bloqueios 
                            dos TAAs;
                          - Quando inclusao de TAA, iniciar com
                            flag bloqueada
                          - Novas operacoes na opcao "R" (Evandro).
                          
               13/06/2011 - Incluida opcao "M" para monitoramento TAA
                           (Evandro).
                     
               15/07/2011 - Criado opcao "L" para o recolhimento de 
                            envelopes e numerarios (Adriano).      
                            
               22/08/2011 - Incluir tarifa de impressao de comprovantes
                            (Gabriel).
                          - Incluido horario de deposito na listagem de
                            envelopes (Evandro).
                            
               10/11/2011 - Adaptado para o uso de BO. (Gabriel Capoia - DB1).
               
               19/10/2012 - Incluido include b1wgen0025tt.i (Oscar).
               
               16/07/2013 - Adicionado a possibilidade de imprimir o relatorio 
                            de cartoes magneticos disponiveis para entrega. 
                            (James)
                            
               31/10/2013 - Adicionado opcao "Bloquear/Desbloquear Saque" em 
                            "Transacao". (Jorge). 
                            
               28/02/2014 - Liberação do campo PA para alteração. (Jean Michel)
               
               27/05/2014 - Incluido a informação de espécie de deposito e
                            relatório do mesmo. (Andre Santos - SUPERO)
                            
               03/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               11/08/2014 - Adicionado informacao de cooperativa de destino
                            da conta a receber deposito na temp-table 
                            tt-envelopes. (Reinert)                            
                            
               22/04/2015 - Alteracao na formatacao do campo tt-envelopes.nrseqenv 
                            de 6 para 10 caracteres. (Jaison/Elton - SD: 276984)
                            
............................................................................... */

{ sistema/generico/includes/b1wgen0025tt.i }
{ sistema/generico/includes/b1wgen0123tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }

DEF STREAM str_1.

DEF VAR h-b1wgen0123 AS HANDLE                                         NO-UNDO.
DEF VAR tel_flsistaa LIKE craptfn.flsistaa                             NO-UNDO.
DEF VAR tel_mmtramax AS INTE      INIT 10                              NO-UNDO.
DEF VAR aux_cddoptrs AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
        
DEF VAR tel_nrterfin AS INT     FORMAT "zzz9"                          NO-UNDO.
DEF VAR tel_lgagetfn AS LOG     FORMAT "Sim/Nao"                       NO-UNDO.

DEF VAR tel_opcaorel AS CHAR    FORMAT "x(18)" 
                     VIEW-AS COMBO-BOX LIST-ITEMS "Movimentacoes",
                                                  "Cartoes Magneticos",
                                                  "Depositos" NO-UNDO.

DEF VAR tel_tiprelat AS LOG     FORMAT "Analitico/Sintetico"        
                                INITIAL TRUE                           NO-UNDO.
DEF VAR tel_dtmvtini AS DATE    FORMAT "99/99/9999"                    NO-UNDO.
DEF VAR tel_dtmvtfim AS DATE    FORMAT "99/99/9999"                    NO-UNDO.
                                                                   
DEF VAR tel_cdagenci AS INT     FORMAT "zz9"                           NO-UNDO.
DEF VAR tel_cdagetfn AS INT     FORMAT "zz9"                           NO-UNDO.
DEF VAR tel_dsagetfn AS CHAR    FORMAT "x(15)"                         NO-UNDO.
DEF VAR tel_qtcasset AS INT     FORMAT "9"                             NO-UNDO.
DEF VAR tel_qtdnotaA AS INT     FORMAT "z,zz9"                         NO-UNDO.
DEF VAR tel_qtdnotaB AS INT     FORMAT "z,zz9"                         NO-UNDO.
DEF VAR tel_qtdnotaC AS INT     FORMAT "z,zz9"                         NO-UNDO.
DEF VAR tel_qtdnotaD AS INT     FORMAT "z,zz9"                         NO-UNDO.
DEF VAR tel_qtdnotaR AS INT     FORMAT "z,zz9"                         NO-UNDO.
DEF VAR tel_qtdnotaG AS INT     FORMAT "z,zz9"                         NO-UNDO.
DEF VAR tel_qttotalP AS INT     FORMAT "z,zz9"                         NO-UNDO.
                                                                   
DEF VAR tel_nrlacreA AS INT     FORMAT "zzz,zz9"                       NO-UNDO.
DEF VAR tel_nrlacreB AS INT     FORMAT "zzz,zz9"                       NO-UNDO.
DEF VAR tel_nrlacreC AS INT     FORMAT "zzz,zz9"                       NO-UNDO.
DEF VAR tel_nrlacreD AS INT     FORMAT "zzz,zz9"                       NO-UNDO.
DEF VAR tel_nrlacreR AS INT     FORMAT "zzz,zz9"                       NO-UNDO.
                                                                   
DEF VAR tel_cdsitfin AS INT                                            NO-UNDO.
DEF VAR tel_cdsitenv AS INT                                   INIT 0   NO-UNDO.
                                                                   
DEF VAR tel_dsterfin AS CHAR    FORMAT "x(30)"                         NO-UNDO.
DEF VAR tel_nmoperad AS CHAR    FORMAT "x(35)"                         NO-UNDO.
DEF VAR tel_dsfabtfn AS CHAR    FORMAT "x(25)"                         NO-UNDO.
DEF VAR tel_dsmodelo AS CHAR    FORMAT "x(25)"                         NO-UNDO.
DEF VAR tel_dsdserie AS CHAR    FORMAT "x(25)"                         NO-UNDO.
                                                                   
DEF VAR tel_nmnarede AS CHAR    FORMAT "x(14)"                         NO-UNDO.
DEF VAR tel_nrdendip AS CHAR    FORMAT "x(14)"                         NO-UNDO.
                                                                   
DEF VAR tel_vldnotaA AS DECIMAL FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR tel_vldnotaB AS DECIMAL FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR tel_vldnotaC AS DECIMAL FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR tel_vldnotaD AS DECIMAL FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR tel_vltotalA AS DECIMAL FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR tel_vltotalB AS DECIMAL FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR tel_vltotalC AS DECIMAL FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR tel_vltotalD AS DECIMAL FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR tel_vltotalR AS DECIMAL FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR tel_vltotalG AS DECIMAL FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR tel_vltotalP AS DECIMAL FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
                                                                   
DEF VAR tel_vldsdini AS DECIMAL                                        NO-UNDO.
DEF VAR tel_vldsdfin AS DECIMAL                                        NO-UNDO.
DEF VAR tel_vlrecolh AS DECIMAL                                        NO-UNDO.
DEF VAR tel_vlsuprim AS DECIMAL                                        NO-UNDO.
DEF VAR tel_vldsaque AS DECIMAL                                        NO-UNDO.
DEF VAR tel_vlestorn AS DECIMAL                                        NO-UNDO.
DEF VAR tel_vlrejeit AS DECIMAL                                        NO-UNDO.
DEF VAR tel_dsobserv AS CHAR                                           NO-UNDO.
                                                                   
DEF VAR tel_dstempor AS CHAR                                           NO-UNDO.
DEF VAR tel_dsdispen AS CHAR                                           NO-UNDO.
DEF VAR tel_dsininot AS CHAR                                           NO-UNDO.
DEF VAR tel_dsfimnot AS CHAR                                           NO-UNDO.
DEF VAR tel_dssaqnot AS CHAR                                           NO-UNDO.
DEF VAR tel_dssittfn AS CHAR                                           NO-UNDO.
DEF VAR tel_cddopcao AS CHAR    FORMAT "!"                             NO-UNDO.
DEF VAR tel_tprecolh AS LOG     FORMAT "E/N" INIT "E"                  NO-UNDO.

DEF VAR tel_dsdopcao AS CHAR    EXTENT 6  
                                       INIT ["Transacao",
                                             "Operacao",
                                             "Sensores",
                                             "Configuracao",
                                             "Saldos Anteriores",
                                             "Log"]                    NO-UNDO.
                     
DEF VAR tel_dtlimite AS DATE    FORMAT "99/99/9999"                    NO-UNDO.
DEF VAR tel_listatrn AS CHAR    FORMAT "x(20)"                    
                                INIT "Lista das Transacoes"            NO-UNDO.
DEF VAR tel_bloqueio AS CHAR    FORMAT "x(16)"                         NO-UNDO.
DEF VAR tel_bloqdsaq AS CHAR    FORMAT "x(18)"                         NO-UNDO.
DEF VAR tel_deposito AS CHAR    FORMAT "x(9)"                       
                                INIT "Depositos"                       NO-UNDO.
DEF VAR tel_dtinicio AS DATE    FORMAT "99/99/9999"                    NO-UNDO.
DEF VAR tel_dtdfinal AS DATE    FORMAT "99/99/9999"                    NO-UNDO.
DEF VAR lis_tldatela AS CHAR                                           NO-UNDO.

/* Variaveis impressao */
DEF VAR aux_nmendter AS CHAR    FORMAT "x(20)"                         NO-UNDO.
DEF VAR par_flgrodar AS LOGICAL      INIT TRUE                         NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                        NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL      INIT TRUE                         NO-UNDO.
DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"          NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"          NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                        NO-UNDO.
                                                                   
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
                                                                   
DEF VAR aux_qtsaques AS INT                                            NO-UNDO.
DEF VAR aux_qtestorn AS INT                                            NO-UNDO.
DEF VAR aux_contador AS INT                                            NO-UNDO.
                                                                   
DEF VAR aux_vlsaques AS DECIMAL                                        NO-UNDO.
DEF VAR aux_vlestorn AS DECIMAL                                        NO-UNDO.
                                                                   
DEF VAR aux_confirma AS CHAR   FORMAT "!(1)"                           NO-UNDO.
                                                                   
DEF VAR tel_nmarquiv AS CHAR   FORMAT "x(25)"                          NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR tel_nmdireto AS CHAR   FORMAT "x(29)"                          NO-UNDO.
DEF VAR aux_opcaorel AS CHAR                                           NO-UNDO.

DEF VAR aux_flgblsaq AS LOGICAL                                        NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.
     
FORM glb_cddopcao  LABEL "Opcao" AUTO-RETURN AT 3
        HELP "Entre com a opcao desejada (A, B, C, I, L, M ou R)"
        VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "B" OR
                  glb_cddopcao = "C" OR glb_cddopcao = "I" OR 
                  glb_cddopcao = "M" OR glb_cddopcao = "R" OR
                  glb_cddopcao = "L",
                  "014 - Opcao errada.")
    WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao.

FORM tel_nrterfin AT 2 LABEL "Numero do Terminal de Saque"
     tel_dsterfin AT 36 NO-LABEL  FORMAT "x(30)"
        HELP "Informe a descricao do cash."
     WITH OVERLAY ROW 6 COLUMN 13 SIDE-LABEL NO-BOX FRAME f_param_1.

FORM tel_opcaorel AT 1  LABEL "Tipo de Relatório" 
                        HELP "Selecione Movimentacoes ou Cartoes Magnetico"
     WITH OVERLAY ROW 6 COLUMN 13 SIDE-LABEL NO-BOX FRAME f_param_2.

FORM tel_lgagetfn AT 16 LABEL "PA"
     tel_cdagetfn AT 26 LABEL "Nr."
     HELP "Pressione <F7> para Zoom ou '0' para Todos PAs"
     tel_dsagetfn AT 36 NO-LABEL
     WITH OVERLAY ROW 7 COLUMN 13 SIDE-LABEL NO-BOX FRAME f_param_3.

FORM tel_dtmvtini AT 14 LABEL "Data"   FORMAT "99/99/9999"
     tel_dtmvtfim AT 31 LABEL "ate"    FORMAT "99/99/9999"
     tel_tiprelat AT 11 LABEL "Formato" HELP "(A)nalitico ou (S)intetico" 
     WITH OVERLAY ROW 8 COLUMN 13 SIDE-LABEL NO-BOX FRAME f_param_4.
     
FORM tel_nrterfin AT 6 LABEL "Numero do Terminal de Saque"
     tel_dsterfin AT 39 NO-LABEL
     SKIP
     tel_dtmvtini AT 6 LABEL "Data"   FORMAT "99/99/9999"
     tel_dtmvtfim AT 23 LABEL "ate"    FORMAT "99/99/9999"
        HELP "Informe a descricao do cash."
     SKIP
     tel_cdsitenv AT 6 LABEL "Situacao"    FORMAT "9"
     HELP "Informe a Situacao (0-Nao Lib,1-Lib,2-Descart,3-Recolh,9-TODOS)"
                        VALIDATE(tel_cdsitenv = 0 OR tel_cdsitenv = 1 OR
                                 tel_cdsitenv = 2 OR tel_cdsitenv = 3 OR
                                 tel_cdsitenv = 9, "Situacao invalida")
     WITH OVERLAY ROW 8 COLUMN 2 SIDE-LABEL NO-BOX FRAME f_rel_deposito.

FORM SKIP
     "Lacre"         AT 22
     "Qtd. Notas"    AT 30
     "Valor da Nota" AT 45
     "Valor Total"   AT 64
     SKIP
     "Cassete A:" AT 07
     tel_nrlacreA AT 20 NO-LABEL
     tel_qtdnotaA AT 35 NO-LABEL
     tel_vldnotaA AT 44 NO-LABEL
     tel_vltotalA AT 61 NO-LABEL
     SKIP
     "Cassete B:" AT 07
     tel_nrlacreB AT 20 NO-LABEL
     tel_qtdnotaB AT 35 NO-LABEL
     tel_vldnotaB AT 44 NO-LABEL
     tel_vltotalB AT 61 NO-LABEL
     SKIP
     "Cassete C:" AT 07
     tel_nrlacreC AT 20 NO-LABEL
     tel_qtdnotaC AT 35 NO-LABEL
     tel_vldnotaC AT 44 NO-LABEL
     tel_vltotalC AT 61 NO-LABEL
     SKIP
     "Cassete D:" AT 07
     tel_nrlacreD AT 20 NO-LABEL
     tel_qtdnotaD AT 35 NO-LABEL
     tel_vldnotaD AT 44 NO-LABEL
     tel_vltotalD AT 61 NO-LABEL
     SKIP
     "Rejeitados:" AT 06
     tel_nrlacreR AT 20 NO-LABEL
     tel_qtdnotaR AT 35 NO-LABEL
     tel_vltotalR AT 61 NO-LABEL
     SKIP
     "Total:" AT 11 
     tel_qtdnotaG AT 35 NO-LABEL
     tel_vltotalG AT 61 NO-LABEL
     SKIP(1)
     "Envelopes:" AT 07
     tel_qttotalP AT 35 NO-LABEL
     "Situacao:"  AT 54
     tel_dssittfn NO-LABEL FORMAT "x(15)"
     SKIP(1)
     tel_nmoperad AT 08 LABEL "Operador"
     SKIP(1)
     tel_dsdopcao[1] AT 05 NO-LABEL FORMAT "x(9)"
     tel_dsdopcao[2] AT 17 NO-LABEL FORMAT "x(8)"
     tel_dsdopcao[3] AT 28 NO-LABEL FORMAT "x(8)"
     tel_dsdopcao[4] AT 39 NO-LABEL FORMAT "x(12)"
     tel_dsdopcao[5] AT 54 NO-LABEL FORMAT "x(17)"
     tel_dsdopcao[6] AT 73 NO-LABEL FORMAT "x(3)"   
     WITH ROW 8 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_cash.
          
FORM SKIP(1)      " "
     tel_listatrn " " 
     tel_bloqueio " "
     tel_bloqdsaq " "
     tel_deposito " "
     SKIP(1)
     WITH ROW 14 COLUMN 2 NO-LABELS CENTERED OVERLAY FRAME f_opcoes_trn.

FORM SKIP(1)
     "Saldo Inicial     " AT 2
     tel_vldsdini       FORMAT "zzz,zzz,zz9.99-" 
     SKIP(1)
     "Suprimento       +" AT 2
     tel_vlsuprim       FORMAT "zzz,zzz,zz9.99"
     SKIP
     "Recolhimento     -" AT 2
     tel_vlrecolh       FORMAT "zzz,zzz,zz9.99"
     SKIP
     "Saques           -" AT 2
     tel_vldsaque       FORMAT "zzz,zzz,zz9.99"
     SKIP
     "Estornos         +" AT 2
     tel_vlestorn       FORMAT "zzz,zzz,zz9.99"
     SKIP(1)
     "Saldo Final       " AT 2
     tel_vldsdfin       FORMAT "zzz,zzz,zz9.99-" 
     SKIP
     "(Rejeitados        " AT 1
     tel_vlrejeit       FORMAT "zzz,zzz,zz9.99"
     ")"                  AT 35
     SKIP(1)
     tel_dsobserv AT 6  FORMAT "x(25)"
     SKIP(1)
     WITH ROW 07 CENTERED OVERLAY NO-LABEL
          TITLE lis_tldatela FRAME f_saldos.
   
FORM SKIP(1)
     tel_cdagenci  LABEL "PA.............." AT 02 FORMAT "zz9" 
       HELP "Informe o PA."
     tel_dsfabtfn   LABEL "Fabricante......" AT 02 FORMAT "x(25)"
       HELP "Informe o fabricante do cash."
     tel_dsmodelo   LABEL "Modelo.........." AT 02 FORMAT "x(25)"
       HELP "Informe o modelo do cash."
     tel_dsdserie   LABEL "Numero de Serie." AT 02 FORMAT "x(20)"
       HELP "Informe o numero de serie do cash."    
     tel_nmnarede LABEL "Ident. na rede.."   AT 02 FORMAT "x(14)" 
        HELP "Informe o nome do cash."
     "-" AT 34
     tel_nrdendip NO-LABEL                   AT 36 FORMAT "x(14)"
        HELP "Informe o IP do cash."
     tel_cdsitfin   LABEL "Situacao........" AT 02 FORMAT "9"
       HELP "2- Fechado, 8- Desativado."
     tel_dssittfn NO-LABEL                   AT 22 FORMAT "x(20)"
     tel_qtcasset   LABEL "Nro de Cassetes." AT 02 FORMAT "9"   AUTO-RETURN
       HELP "Informe a quantidade de cassetes do cash."
     tel_dstempor   LABEL "Temporizador...." AT 02 FORMAT "x(21)" 
     tel_dsdispen   LABEL "Dispensador....." AT 02 FORMAT "x(21)" 

     "Noturno.........:" AT 02
     tel_dsininot   LABEL "Inicio" AT 20 FORMAT "x(8)"  "HORAS"
     tel_dsfimnot   LABEL "Final " AT 20 FORMAT "x(8)"  "HORAS"
     tel_dssaqnot   LABEL "Saque Maximo"   AT 14 FORMAT "x(25)" 
     WITH ROW 07 CENTERED OVERLAY SIDE-LABELS 
     TITLE lis_tldatela FRAME f_config.

FORM SPACE(1)
 tt-transacao.dttransa FORMAT "99/99/9999"          LABEL "Data"
 tt-transacao.hrtransa FORMAT "x(8)"                LABEL "Horario"   
 tt-transacao.nrdconta FORMAT "zzzz,zzz,9"          LABEL "Conta/dv"  
 tt-transacao.nrdocmto FORMAT "zzz,zz9"             LABEL "Docmto"
 tt-transacao.vllanmto FORMAT "zzz,zz9.99"          LABEL "Valor"
 tt-transacao.dstransa FORMAT "x(17)"               LABEL "Operacao"
 tt-transacao.nrcartao FORMAT "9999,9999,9999,9999" LABEL "Cartao             "
 tt-transacao.nrsequni FORMAT "zzz,zz9"             LABEL "Seq."
 SPACE(1)
 WITH ROW 07 CENTERED OVERLAY 11 DOWN NO-LABEL WIDTH 99
      TITLE lis_tldatela FRAME f_saques.

FORM tt-transacao.dttransa AT  2 FORMAT "99/99/9999" LABEL "Data"
     tt-transacao.hrtransa AT 14 FORMAT "x(8)"       LABEL "Horario"
     tt-transacao.dsoperad AT 24 FORMAT "x(25)"      LABEL "Operador"
     tt-transacao.dstarefa AT 51 FORMAT "x(13)"      LABEL "Tarefa" 
     tt-transacao.vllanmto AT 66 FORMAT "zzz,zz9.99" LABEL "Valor"
      " "
     WITH ROW 07 CENTERED OVERLAY 11 DOWN NO-LABEL
          TITLE lis_tldatela FRAME f_operacao.

FORM tt-sensores.dslocali AT  3 FORMAT "x(28)" LABEL "Localizacao"
     tt-sensores.dssensor AT 33 FORMAT "x(26)" LABEL "Situacao" " "
     WITH ROW 07 CENTERED OVERLAY 11 DOWN NO-LABEL
          TITLE lis_tldatela FRAME f_sensores.

FORM tel_dtinicio AT 10 LABEL "Inicio"
                        HELP "Informe a data de inicio."
     
     tel_dtdfinal AT 35 LABEL "Fim"
                        HELP "Informe a data final."
     
     tel_cdsitenv AT 55 LABEL "Situacao"    FORMAT "9"
     HELP "Informe a Situacao (0-Nao Lib,1-Lib,2-Descart,3-Recolh,9-TODOS)"
                        VALIDATE(tel_cdsitenv = 0 OR tel_cdsitenv = 1 OR
                                 tel_cdsitenv = 2 OR tel_cdsitenv = 3 OR
                                 tel_cdsitenv = 9, "Situacao invalida")
     WITH ROW 8 COLUMN 2 SIZE 78 BY 13 OVERLAY SIDE-LABELS NO-BOX 
                                                            FRAME f_envelopes.

FORM  tt-envelopes.dtmvtolt   COLUMN-LABEL "Data"         FORMAT "x(8)"
      tt-envelopes.hrtransa   COLUMN-LABEL "Hora"
      tt-envelopes.nrdconta   COLUMN-LABEL "Conta Fav."   FORMAT "x(18)"
      tt-envelopes.nrseqenv   COLUMN-LABEL "Envelope"     FORMAT "x(10)"
      tt-envelopes.dsespeci   COLUMN-LABEL "ESP"          FORMAT "x(3)"
      tt-envelopes.vlenvinf   COLUMN-LABEL "Valor Inf"    FORMAT "x(12)"
      tt-envelopes.vlenvcmp   COLUMN-LABEL "Valor Comp"   FORMAT "x(12)"
      tt-envelopes.dssitenv   COLUMN-LABEL "Situacao"     FORMAT "x(14)"
     WITH ROW 10 COLUMN 3 SIZE 76 BY 11 OVERLAY DOWN NO-BOX 
                                                       FRAME f_lista_envelopes.
FORM SKIP(1)
     "Diretorio:   "     AT 5
     tel_nmdireto
     tel_nmarquiv        HELP "Informe o nome do arquivo."
     SKIP(1)
     WITH OVERLAY CENTERED NO-LABEL WIDTH 76 ROW 10 FRAME f_diretorio.

ON LEAVE OF tel_cdsitfin DO:

    IF  INPUT tel_cdsitfin = 2 THEN
        ASSIGN tel_dssittfn = "- FECHADO".
    ELSE
    IF  INPUT tel_cdsitfin = 8 THEN
        ASSIGN tel_dssittfn = "- DESATIVADO".
    
    DISPLAY tel_dssittfn WITH FRAME f_config.
END.

ON RETURN OF tel_opcaorel IN FRAME f_param_2 
   DO: 
       APPLY "GO".
   END.

VIEW FRAME f_moldura.

PAUSE(0).
ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       tel_dtmvtini = glb_dtmvtolt
       tel_dtmvtfim = glb_dtmvtolt.

DO WHILE TRUE:

    RUN fontes/inicia.p.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        CLEAR FRAME f_opcao         NO-PAUSE.
        CLEAR FRAME f_param_1       NO-PAUSE.
        CLEAR FRAME f_rel_deposito  NO-PAUSE.
        CLEAR FRAME f_param_2       NO-PAUSE.
        CLEAR FRAME f_param_3       NO-PAUSE.
        CLEAR FRAME f_param_4       NO-PAUSE.
        CLEAR FRAME f_cash          NO-PAUSE.
        HIDE  FRAME f_diretorio     NO-PAUSE.
        HIDE  FRAME f_param_1       NO-PAUSE.
        HIDE  FRAME f_rel_deposito  NO-PAUSE.
        HIDE  FRAME f_param_2       NO-PAUSE.
        HIDE  FRAME f_param_3       NO-PAUSE.
        HIDE  FRAME f_param_4       NO-PAUSE.
        HIDE  FRAME f_cash          NO-PAUSE.
        UPDATE glb_cddopcao WITH FRAME f_opcao.
        LEAVE.

    END.
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "CASH" THEN
                DO:
                    IF  VALID-HANDLE(h-b1wgen0123)  THEN
                        DELETE PROCEDURE h-b1wgen0123.

                    HIDE FRAME f_saques       NO-PAUSE.
                    HIDE FRAME f_operacao     NO-PAUSE.
                    HIDE FRAME f_sensores     NO-PAUSE.
                    HIDE FRAME f_cash         NO-PAUSE.
                    HIDE FRAME f_opcao        NO-PAUSE.
                    HIDE FRAME f_param_1      NO-PAUSE.
                    HIDE FRAME f_rel_deposito NO-PAUSE.
                    HIDE FRAME f_param_2      NO-PAUSE.
                    HIDE FRAME f_param_3      NO-PAUSE.
                    HIDE FRAME f_param_4      NO-PAUSE.
                    HIDE FRAME f_diretorio    NO-PAUSE.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao.
        END.

    tel_cdsitfin:VISIBLE IN FRAME f_config = FALSE.
   
    IF  glb_cddopcao = "A" THEN
        DO:
            tel_nrterfin:HELP = "Informe o numero ou tecle <F7>" +
                                " para listar os cashes.".
            RUN proc_opcaoa.
            NEXT.
        END.
    ELSE
    IF  glb_cddopcao = "B" THEN
        DO:
            tel_nrterfin:HELP = 
                              "Informe o numero / <F7> listar / 0 - ver todos".
            RUN proc_opcaob.
            NEXT.
        END.
    ELSE
    IF  glb_cddopcao = "I" THEN
        DO:
            tel_nrterfin:HELP = "Informe o numero do cash.".
            RUN proc_opcaoi.
            NEXT.
        END.
    ELSE
    IF  glb_cddopcao = "M" THEN
        DO: 
            RUN proc_opcaom.
            NEXT.
        END.
    ELSE
    IF  glb_cddopcao = "R" THEN
        DO:
            tel_nrterfin:HELP = "Tecle <F7> para listar os cashes".
            RUN proc_opcaor.
            NEXT.
        END.
    ELSE
    IF  glb_cddopcao = "L" THEN
        DO:
            tel_nrterfin:HELP = "Tecle <F7> para listar os cashes".

            RUN proc_opcaol.

            NEXT.
        END.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN tel_nrterfin = 0    tel_dsterfin = ""
               tel_nrlacreA = 0    tel_qtdnotaA = 0 
               tel_vldnotaA = 0    tel_vltotalA = 0
               tel_nrlacreB = 0    tel_qtdnotaB = 0 
               tel_vldnotaB = 0    tel_vltotalB = 0
               tel_nrlacreC = 0    tel_qtdnotaC = 0
               tel_vldnotaC = 0    tel_vltotalC = 0
               tel_nrlacreD = 0    tel_qtdnotaD = 0
               tel_vldnotaD = 0    tel_vltotalD = 0
               tel_nrlacreR = 0    tel_qtdnotaR = 0
               tel_vltotalR = 0    tel_qttotalP = 0
               tel_qtdnotaG = 0    tel_vltotalG = 0
               tel_nmoperad = ""   tel_dstempor = ""
               tel_dsdispen = ""   tel_cdagenci = 0
               tel_cdsitfin = 0    tel_dsfabtfn = ""
               tel_dsmodelo = ""   tel_dsdserie = ""
               tel_nmnarede = ""   tel_nrdendip = ""
               tel_qtcasset = 0    tel_dsininot = ""
               tel_dsfimnot = ""   tel_dssaqnot = "".

        CLEAR FRAME f_cash NO-PAUSE.

        VIEW FRAME f_cash.

        /* Para retirar a selecao do CHOOSE apos "END" */
        CHOOSE FIELD tel_dsdopcao COLOR NORMAL PAUSE 0 WITH FRAME f_cash.

                    tel_nrterfin:HELP = "Informe o numero ou tecle <F7>" +
                                        " para listar os cashes.".
            
                    UPDATE tel_nrterfin WITH FRAME f_param_1
                    EDITING:
                        READKEY.
            
                        IF  LASTKEY = KEYCODE("F7") THEN
                            DO:
                                IF  FRAME-FIELD = "tel_nrterfin" THEN
                                    DO:
                                        RUN fontes/zoom_cash.p ( INPUT  glb_cdcooper,
                                                                OUTPUT tel_nrterfin).
                                        DISPLAY tel_nrterfin WITH FRAME f_param_1.
                                        IF  tel_nrterfin > 0   THEN
                                            APPLY "RETURN".
                                        ELSE
                                            CLEAR FRAME f_cash NO-PAUSE.  
                                    END.
                            END.
                        ELSE
                            APPLY LASTKEY.
            
                    END.  /*  Fim do EDITING  */

                    RUN Busca_Dados.
            
                    IF  RETURN-VALUE <> "OK" THEN
                        NEXT.

        FIND FIRST tt-terminal NO-ERROR.

        IF  NOT AVAIL tt-terminal THEN
            NEXT.

        ASSIGN tel_nmoperad = tt-terminal.nmoperad
               tel_dsterfin = tt-terminal.dsterfin
               tel_dssittfn = tt-terminal.dssittfn
               tel_dsdispen = tt-terminal.dsdispen
               tel_dstempor = tt-terminal.dstempor

               tel_cdagenci = tt-terminal.cdagenci
               tel_cdsitfin = tt-terminal.cdsitfin
               tel_dsfabtfn = tt-terminal.dsfabtfn
               tel_dsmodelo = tt-terminal.dsmodelo
               tel_dsdserie = tt-terminal.dsdserie
               tel_nmnarede = tt-terminal.nmnarede
               tel_nrdendip = tt-terminal.nrdendip
               tel_qtcasset = tt-terminal.qtcasset
               tel_dsininot = tt-terminal.dsininot
               tel_dsfimnot = tt-terminal.dsfimnot
               tel_dssaqnot = tt-terminal.dssaqnot

               tel_nrlacreA = tt-terminal.nrdlacre[1]
               tel_qtdnotaA = tt-terminal.qtnotcas[1]
               tel_vldnotaA = tt-terminal.vlnotcas[1]
               tel_vltotalA = tt-terminal.vltotcas[1]
               
               tel_nrlacreB = tt-terminal.nrdlacre[2]
               tel_qtdnotaB = tt-terminal.qtnotcas[2]
               tel_vldnotaB = tt-terminal.vlnotcas[2]
               tel_vltotalB = tt-terminal.vltotcas[2]

               tel_nrlacreC = tt-terminal.nrdlacre[3]
               tel_qtdnotaC = tt-terminal.qtnotcas[3]
               tel_vldnotaC = tt-terminal.vlnotcas[3]
               tel_vltotalC = tt-terminal.vltotcas[3]

               tel_nrlacreD = tt-terminal.nrdlacre[4]
               tel_qtdnotaD = tt-terminal.qtnotcas[4]
               tel_vldnotaD = tt-terminal.vlnotcas[4]
               tel_vltotalD = tt-terminal.vltotcas[4]

               tel_nrlacreR = tt-terminal.nrdlacre[5]
               tel_qtdnotaR = tt-terminal.qtnotcas[5]
               tel_vltotalR = tt-terminal.vltotcas[5]
               
               tel_qttotalP = tt-terminal.qtenvelo
               tel_qtdnotaG = tt-terminal.qtdnotag
               tel_vltotalG = tt-terminal.vltotalg
               tel_dssittfn = tt-terminal.dssittfn.

        COLOR DISPLAY INPUT tel_qtdnotaR tel_vltotalR WITH FRAME f_cash.

        DISPLAY tel_qtdnotaA tel_qtdnotaB tel_qtdnotaC tel_qtdnotaD
                tel_vldnotaA tel_vldnotaB tel_vldnotaC tel_vldnotaD
                tel_vltotalA tel_vltotalB tel_vltotalC tel_vltotalD
                tel_qtdnotaR tel_vltotalR
                tel_qtdnotaG tel_vltotalG
                tel_nrlacreA tel_nrlacreB tel_nrlacreC tel_nrlacreD
                tel_nrlacreR tel_qttotalP tel_dssittfn
                tel_nmoperad tel_dsdopcao 
                WITH FRAME f_cash.
      
        DISPLAY tel_dsterfin WITH FRAME f_param_1.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            CHOOSE FIELD tel_dsdopcao
               HELP "Tecle <Entra> para maiores detalhes ou <Fim> para voltar."
               PAUSE 60 WITH FRAME f_cash.

            IF  LASTKEY = -1   THEN
                LEAVE.

            HIDE MESSAGE NO-PAUSE.

            ASSIGN aux_dsdopcao = FRAME-VALUE

                   tel_dtlimite = IF aux_dsdopcao = tel_dsdopcao[6]
                                  THEN glb_dtmvtoan
                                  ELSE glb_dtmvtolt.

            IF  (aux_dsdopcao <> tel_dsdopcao[1]   AND
                 aux_dsdopcao <> tel_dsdopcao[3]   AND
                 aux_dsdopcao <> tel_dsdopcao[4])  THEN
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    MESSAGE COLOR NORMAL
                        "Entre com a data de referencia:" UPDATE tel_dtlimite.
                    
                        LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

            IF  KEYFUNCTION(LASTKEY)= "END-ERROR"   THEN
                NEXT.

            IF  aux_dsdopcao = tel_dsdopcao[1]   THEN
                DO: 
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        /* Cash Bloqueado */
                        IF  tel_cdsitfin = 3  THEN
                            ASSIGN tel_bloqueio = "Desbloquear Cash".
                        ELSE
                            ASSIGN tel_bloqueio = " Bloquear Cash".
                        
                        RUN conecta_handle.
                        RUN status_saque IN h-b1wgen0123 (INPUT glb_cdcooper,
                                                          INPUT tel_nrterfin,
                                                         OUTPUT aux_flgblsaq).
                        
                        IF  VALID-HANDLE(h-b1wgen0123)  THEN
                            DELETE PROCEDURE h-b1wgen0123.

                        /* Saque Bloqueado */
                        IF  aux_flgblsaq = TRUE  THEN
                            ASSIGN tel_bloqdsaq = "Desbloquear Saque".
                        ELSE
                            ASSIGN tel_bloqdsaq = "Bloquear Saque".

                        DISPLAY tel_listatrn tel_bloqueio tel_bloqdsaq 
                                tel_deposito WITH FRAME f_opcoes_trn.

                        CHOOSE FIELD tel_listatrn tel_bloqueio 
                                     tel_bloqdsaq tel_deposito
                                     WITH FRAME f_opcoes_trn.

                        IF  FRAME-VALUE = tel_listatrn  THEN
                            DO:
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                    MESSAGE COLOR NORMAL 
                                        "Entre com a data de referencia:" 
                                        UPDATE tel_dtlimite.
                                    LEAVE.

                                END.  /*  Fim do DO WHILE TRUE  */

                                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                    NEXT.

                                RUN lista_trn.

                                HIDE FRAME f_saques.
                            END.
                        ELSE
                        IF  FRAME-VALUE = tel_bloqueio  THEN
                            DO:
                                RUN proc_confirma.

                                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                                    aux_confirma = "N"   THEN
                                    NEXT.

                                RUN bloqueio.

                                HIDE FRAME f_opcoes_trn.
                            END.       
                        ELSE
                        IF  FRAME-VALUE = tel_bloqdsaq  THEN
                            DO:
                                RUN proc_confirma.

                                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                                    aux_confirma = "N"   THEN
                                    NEXT.

                                RUN bloqdsaq.

                                HIDE FRAME f_opcoes_trn.
                            END.       
                        ELSE
                        IF  FRAME-VALUE = tel_deposito  THEN
                            DO:
                                DO  WHILE TRUE ON END-KEY UNDO, LEAVE:

                                    /* limpa os campos */
                                    ASSIGN tel_dtinicio = ?
                                           tel_dtdfinal = ?
                                           tel_cdsitenv = 9.

                                    UPDATE tel_dtinicio
                                           tel_dtdfinal
                                           tel_cdsitenv
                                           WITH FRAME f_envelopes.

                                    RUN lista_envelopes.

                                    IF  RETURN-VALUE <> "OK" THEN
                                        NEXT.

                                    LEAVE.
                                END.

                                HIDE FRAME f_opcoes_trn.
                            END.
                        
                        LEAVE.

                    END.

                END.
            ELSE
            IF  aux_dsdopcao = tel_dsdopcao[2] THEN
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    RUN Opcao_Operacao.
    
                    IF  RETURN-VALUE <> "OK" THEN
                        LEAVE.

                    ASSIGN lis_tldatela = " Operacao do Terminal de Saques" +
                             " em " + STRING(tel_dtlimite,"99/99/9999") + " "
                           aux_contador = 0.

                    HIDE FRAME f_operacao NO-PAUSE.
                    CLEAR FRAME f_operacao ALL NO-PAUSE.

                    FOR EACH tt-transacao:

                        ASSIGN aux_contador = aux_contador + 1.

                        DISPLAY tt-transacao.dttransa
                                tt-transacao.hrtransa
                                tt-transacao.dsoperad
                                tt-transacao.dstarefa
                                tt-transacao.vllanmto
                                WITH FRAME f_operacao.

                        IF  aux_contador = 11   THEN
                            DO:
                                ASSIGN aux_contador = 0.
                                PAUSE MESSAGE "Tecle algo para continuar...".
                                CLEAR FRAME f_operacao ALL NO-PAUSE.
                                NEXT.
                            END.

                        DOWN WITH FRAME f_operacao.

                    END. /* FOR EACH tt-transacao */

                    PAUSE MESSAGE "Tecle algo para continuar...". 

                    HIDE FRAME f_operacao.

                    LEAVE.

                END.
            ELSE
            IF  aux_dsdopcao = tel_dsdopcao[3] THEN
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    ASSIGN lis_tldatela = " Sensores do Terminal de Saques ".

                    HIDE FRAME f_sensores NO-PAUSE.

                    CLEAR FRAME f_sensores ALL NO-PAUSE.

                    RUN Opcao_Sensores.

                    IF  RETURN-VALUE <> "OK" THEN
                        LEAVE.

                    FOR EACH tt-sensores:

                        DISPLAY tt-sensores.dslocali tt-sensores.dssensor
                            WITH FRAME f_sensores.

                        IF  aux_contador = 11 THEN
                            DO:
                                PAUSE MESSAGE "Tecle algo para continuar...".
                                CLEAR FRAME f_sensores ALL NO-PAUSE.
                                NEXT.
                            END.

                        DOWN WITH FRAME f_sensores.

                    END. /* FOR EACH tt-sensores: */

                    PAUSE MESSAGE "Tecle algo para continuar...".
                  
                    HIDE FRAME f_sensores.
                  
                    LEAVE.
                    
                END.
            ELSE
            IF  aux_dsdopcao = tel_dsdopcao[4]   THEN
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    ASSIGN lis_tldatela = " Configuracao ".

                    DISPLAY tel_cdagenci tel_dsfabtfn tel_dsmodelo 
                            tel_dsdserie tel_nmnarede tel_nrdendip
                            tel_qtcasset tel_dstempor tel_dsdispen 
                            tel_dsininot tel_dsfimnot tel_dssaqnot
                            WITH FRAME f_config.

                    PAUSE MESSAGE "Tecle algo para continuar...".

                    HIDE FRAME f_config.
                    
                    LEAVE.
                END.
            ELSE
            IF  aux_dsdopcao = tel_dsdopcao[5] THEN
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    RUN Opcao_Saldos.
    
                    IF  RETURN-VALUE <> "OK" THEN
                        LEAVE.

                    ASSIGN lis_tldatela = " Saldo do dia " +
                                 STRING(tel_dtlimite,"99/99/9999") + " ".

                    FIND FIRST tt-saldos NO-ERROR.

                    IF  NOT AVAIL tt-saldos THEN
                        LEAVE.

                    ASSIGN tel_vldsdini = tt-saldos.vldsdini
                           tel_vlrecolh = tt-saldos.vlrecolh
                           tel_vlsuprim = tt-saldos.vlsuprim
                           tel_vldsaque = tt-saldos.vldsaque
                           tel_vlestorn = tt-saldos.vlestorn
                           tel_vlrejeit = tt-saldos.vlrejeit
                           tel_vldsdfin = tt-saldos.vldsdfin
                           tel_dsobserv = tt-saldos.dsobserv.

                    DISPLAY tel_vldsdini tel_vlrecolh tel_vlsuprim
                            tel_vldsaque tel_vlestorn tel_vlrejeit
                            tel_vldsdfin tel_dsobserv WITH FRAME f_saldos.

                    PAUSE MESSAGE "Tecle algo para continuar...".

                    HIDE FRAME f_saldos.

                    LEAVE.

                END.
            ELSE               
            IF  aux_dsdopcao = tel_dsdopcao[6]   THEN
                DO:

                    HIDE MESSAGE NO-PAUSE.

                    RUN Opcao_Log.

                    IF  RETURN-VALUE <> "OK" THEN
                        LEAVE.

                    ASSIGN aux_nmarqlog = aux_nmarqimp.

                    RUN proc_log_cash.

                    LEAVE.
                END.

            IF  KEYFUNCTION(LASTKEY)= "END-ERROR"   THEN
                DO:
                    HIDE FRAME f_saldos   NO-PAUSE.
                    HIDE FRAME f_config   NO-PAUSE.
                    HIDE FRAME f_sensores NO-PAUSE.
                    HIDE FRAME f_operacao NO-PAUSE.
                     
                    NEXT.
                END.

        END.  /*  Fim do DO WHILE TRUE  -  CHOOSE  */ 

    END.  /*  Fim do DO WHILE TRUE  */

END.  /*  Fim do DO WHILE TRUE  */

/* ......................................................................... */

PROCEDURE proc_log_cash:

    DEF BUTTON btn-ok     LABEL "Sair".
    DEF VAR edi_logcash   AS CHAR VIEW-AS EDITOR SIZE 225 BY 15 PFCOLOR 0.

    DEF FRAME fra_logcash 
              edi_logcash  HELP "Pressione <F4> ou <END> para finalizar" 
              WITH SIZE 76 BY 15 ROW 6 COLUMN 3 USE-TEXT NO-BOX
                   NO-LABELS OVERLAY.

    HIDE MESSAGE NO-PAUSE.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ENABLE edi_logcash  WITH FRAME fra_logcash.
        DISPLAY edi_logcash WITH FRAME fra_logcash.
        ASSIGN edi_logcash:READ-ONLY IN FRAME fra_logcash = YES.

        IF  edi_logcash:INSERT-FILE(aux_nmarqlog)   THEN
            DO:
                ASSIGN edi_logcash:CURSOR-LINE IN FRAME fra_logcash = 1.
                WAIT-FOR GO OF edi_logcash IN FRAME fra_logcash. 
            END.
        ELSE   
            RETURN.
    END.  /*  Fim do DO WHILE TRUE  */

    ASSIGN edi_logcash:SCREEN-VALUE = "".
    CLEAR FRAME fra_logcash ALL.
    HIDE FRAME fra_logcash NO-PAUSE.

END PROCEDURE.

PROCEDURE lista_trn.

    ASSIGN aux_cddoptrs = "L"
           aux_qtsaques = 0  
           aux_vlsaques = 0 
           aux_qtestorn = 0 
           aux_vlestorn = 0 
           aux_contador = 0. 

    RUN Opcao_Transacao.

    IF  RETURN-VALUE <> "OK" THEN
        RETURN.

    ASSIGN lis_tldatela = " Lista das transacoes efetuadas em " +
                          STRING(tel_dtlimite,"99/99/9999") +
                          " ".
    HIDE FRAME f_saques NO-PAUSE.
                  
    CLEAR FRAME f_saques ALL NO-PAUSE.

    FOR EACH tt-transacao NO-LOCK BREAK BY tt-transacao.dtmvtolt:

        ASSIGN aux_contador = aux_contador + 1.
        
        DISPLAY tt-transacao.dttransa tt-transacao.hrtransa
                tt-transacao.nrdconta tt-transacao.nrdocmto
                tt-transacao.nrsequni tt-transacao.vllanmto
                tt-transacao.dstransa tt-transacao.nrcartao 
                WITH FRAME f_saques.
        
         IF  aux_contador = 10   THEN
             DO: 
                 ASSIGN aux_contador = 0.
                 MESSAGE COLOR NORMAL 
        "Use as setas <- e -> para ver toda a linha e ENTER para continuar...".
                 WAIT-FOR ENTER OF CURRENT-WINDOW.
                 HIDE MESSAGE.   
                 CLEAR FRAME f_saques ALL NO-PAUSE.
                 NEXT.
             END.
        
         IF  LAST-OF(tt-transacao.dtmvtolt) THEN
             DOWN 2 WITH FRAME f_saques.
         ELSE
             DOWN WITH FRAME f_saques.
    END.
   
    DISPLAY " "         @ tt-transacao.dttransa
            "Total de"  @ tt-transacao.hrtransa
            "Saques:"   @ tt-transacao.nrdconta
            " "         @ tt-transacao.nrsequni
            " "         @ tt-transacao.dstransa
            " "         @ tt-transacao.nrcartao
            aux_qtsaques FORMAT "zzz,zz9"  @ tt-transacao.nrdocmto
            aux_vlsaques FORMAT "zzz,zz9.99"  @ tt-transacao.vllanmto
            WITH FRAME f_saques.
    
    DOWN WITH FRAME f_saques.
    
    DISPLAY " "         @ tt-transacao.dttransa
            "Total de"  @ tt-transacao.hrtransa
            "Estornos:" @ tt-transacao.nrdconta
            " "         @ tt-transacao.nrsequni
            " "         @ tt-transacao.dstransa
            " "         @ tt-transacao.nrcartao
            aux_qtestorn FORMAT "zzz,zz9"  @ tt-transacao.nrdocmto
            aux_vlestorn FORMAT "zzz,zz9.99"  @ tt-transacao.vllanmto
            WITH FRAME f_saques.
            
    DOWN WITH FRAME f_saques.
    
    PAUSE MESSAGE "Tecle algo para continuar...".
    
END PROCEDURE.

PROCEDURE proc_opcaoa:

    HIDE FRAME f_cash.
    HIDE FRAME f_config.
    HIDE FRAME f_opcoes_trn.
    
    ASSIGN lis_tldatela = "Alterar dados do terminal".

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN tel_nrterfin = 0.

        UPDATE tel_nrterfin WITH FRAME f_param_1
        EDITING:
            READKEY.

            IF  LASTKEY = KEYCODE("F7") THEN
                DO:
                    IF  FRAME-FIELD = "tel_nrterfin" THEN
                        DO:
                            RUN fontes/zoom_cash.p ( INPUT  glb_cdcooper,
                                                         OUTPUT tel_nrterfin).
                                DISPLAY tel_nrterfin WITH FRAME f_param_1.
                                IF   tel_nrterfin > 0   THEN
                                     APPLY "RETURN".
                        END.
                    END. 
                ELSE 
                    APPLY LASTKEY.
        END. /*** Fim EDITING ***/

        RUN Busca_Dados.

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.
    
        LEAVE.                                   

    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            HIDE FRAME f_config NO-PAUSE.
            LEAVE.
        END.

    ASSIGN tel_dsterfin = tt-terminal.dsterfin
           tel_dstempor = tt-terminal.dstempor
           tel_dsdispen = tt-terminal.dsdispen
           tel_cdagenci = tt-terminal.cdagenci
           tel_dsfabtfn = tt-terminal.dsfabtfn
           tel_dsmodelo = tt-terminal.dsmodelo
           tel_dsdserie = tt-terminal.dsdserie
           tel_nmnarede = tt-terminal.nmnarede
           tel_nrdendip = tt-terminal.nrdendip
           tel_qtcasset = tt-terminal.qtcasset
           tel_cdsitfin = tt-terminal.cdsitfin
           tel_dssittfn = "- " + tt-terminal.dssittfn 
           tel_dsininot = tt-terminal.dsininot
           tel_dsfimnot = tt-terminal.dsfimnot
           tel_dssaqnot = tt-terminal.dssaqnot.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        DISPLAY tel_dsterfin WITH FRAME f_param_1.

        DISPLAY tel_cdagenci tel_qtcasset tel_dstempor tel_dsdispen tel_dsininot
                tel_dsfimnot tel_dssaqnot tel_cdagenci tel_dssittfn WITH FRAME f_config.

        UPDATE  tel_cdagenci tel_dsfabtfn tel_dsmodelo tel_dsdserie
                tel_nmnarede tel_nrdendip tel_cdsitfin WITH FRAME f_config.

        RUN Valida_Dados.

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.
        ELSE
            DO:
                RUN proc_confirma.
                LEAVE.         
            END.

    END.  /*  Fim do DO WHILE TRUE  */


    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma = "N"   THEN
        DO:
            HIDE FRAME f_config NO-PAUSE.
            LEAVE.
        END.

    RUN Grava_Dados.

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    HIDE FRAME f_config NO-PAUSE.

    MESSAGE "Alteracao efetuada com sucesso!".
    PAUSE 2 NO-MESSAGE.
   
END PROCEDURE.

/* ......................................................................... */

PROCEDURE proc_opcaoi:

    HIDE FRAME f_cash.
    HIDE FRAME f_config.
    HIDE FRAME f_opcoes_trn.

    ASSIGN lis_tldatela = "Incluir Terminal".

    ASSIGN tel_nrterfin = 0
           tel_qtcasset = 0
           tel_cdagenci = 0
           tel_dsterfin = ""
           tel_dsfabtfn = ""
           tel_dsmodelo = ""                                  
           tel_dsdserie = ""
           tel_nmnarede = ""
           tel_nrdendip = ""
           tel_dstempor = ""
           tel_dsininot = ""
           tel_dsfimnot = ""
           tel_dssaqnot = ""
           tel_dsdispen = "".

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        /* busca o proximo nro de TAA para incluir */
        RUN Busca_Dados.

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.

        FIND FIRST crattfn NO-LOCK.
        tel_nrterfin = crattfn.nrterfin.
            
        DISPLAY tel_nrterfin WITH FRAME f_param_1.
        
        UPDATE tel_dsterfin WITH FRAME f_param_1.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
            DISPLAY tel_dstempor tel_dsininot tel_dsfimnot 
                    tel_dssaqnot tel_dsdispen WITH FRAME f_config.
    
            UPDATE tel_cdagenci tel_dsfabtfn tel_dsmodelo
                   tel_dsdserie tel_nmnarede tel_nrdendip
                   tel_qtcasset WITH FRAME f_config.
    
            RUN Valida_Dados.
    
            IF  RETURN-VALUE <> "OK" THEN
                NEXT.
            
            RUN proc_confirma.
            LEAVE.
                
        END.

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                ASSIGN tel_nrterfin = 0
                       tel_dsterfin = "". 

                DISPLAY tel_nrterfin tel_dsterfin WITH FRAME f_param_1.

                CLEAR FRAME f_config NO-PAUSE.
                HIDE  FRAME f_config NO-PAUSE.
                NEXT.
            END.
        ELSE
            LEAVE. 

    END.  /*  Fim do DO WHILE TRUE  */
    

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma = "N"   THEN
        DO:
            HIDE FRAME f_config NO-PAUSE.
            LEAVE.
        END.

    RUN Grava_Dados.

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    HIDE FRAME f_config NO-PAUSE.

    MESSAGE "Terminal incluido com sucesso!".
    PAUSE 2 NO-MESSAGE.

END.

/* ......................................................................... */

PROCEDURE proc_opcaor:

    EMPTY TEMP-TABLE tt-lancamentos.
    EMPTY TEMP-TABLE tt-lanctos.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
       CLEAR FRAME f_param_3       NO-PAUSE.
       CLEAR FRAME f_param_4       NO-PAUSE.
       CLEAR FRAME f_rel_deposito  NO-PAUSE.

       HIDE FRAME f_param_3.
       HIDE FRAME f_param_4.
       HIDE FRAME f_rel_deposito.

       UPDATE tel_opcaorel 
              WITH FRAME f_param_2.

       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
          
          CLEAR FRAME f_param_3       NO-PAUSE.
          CLEAR FRAME f_param_4       NO-PAUSE.
          CLEAR FRAME f_rel_deposito  NO-PAUSE.

          HIDE FRAME f_param_3.
          HIDE FRAME f_param_4. 
          HIDE FRAME f_rel_deposito.
          HIDE tel_tiprelat IN FRAME f_param_4.

          ASSIGN tel_dsagetfn = ""
                 aux_opcaorel = ""
                 tel_cdagetfn = 0
                 tel_nrterfin = 0
                 tel_cdsitenv = 9
                 tel_dtmvtini = glb_dtmvtolt
                 tel_dtmvtfim = glb_dtmvtolt
                 tel_cddopcao = "T".

          IF  tel_opcaorel:SCREEN-VALUE = "Depositos" THEN DO:

              ASSIGN aux_opcaorel = "Depositos".

              UPDATE tel_nrterfin WITH FRAME f_rel_deposito
              EDITING:
                  READKEY.
              
                  IF  LASTKEY = KEYCODE("F7") THEN
                      DO:
                          IF  FRAME-FIELD = "tel_nrterfin" THEN
                              DO:
                                  RUN fontes/zoom_cash.p ( INPUT  glb_cdcooper,
                                                          OUTPUT tel_nrterfin).
                                  DISPLAY tel_nrterfin WITH FRAME f_rel_deposito.
                                  IF  tel_nrterfin > 0   THEN
                                      APPLY "RETURN".
                                  ELSE
                                      CLEAR FRAME f_cash NO-PAUSE.  
                              END.
                      END.
                  ELSE
                      APPLY LASTKEY.
              
              END.  /*  Fim do EDITING  */

              FIND FIRST craptfn WHERE craptfn.cdcooper = glb_cdcooper
                                   AND craptfn.nrterfin = tel_nrterfin
                                   NO-LOCK NO-ERROR.
        
              IF  AVAIL craptfn THEN
                  ASSIGN tel_dsterfin = " - " + craptfn.nmterfin.

              DISPLAY tel_dsterfin WITH FRAME f_rel_deposito.

              UPDATE tel_dtmvtini
                     tel_dtmvtfim
                     tel_cdsitenv
                     WITH FRAME f_rel_deposito.
          END.
          ELSE DO:
          
              UPDATE tel_lgagetfn 
                     WITH FRAME f_param_3.
    
              IF tel_lgagetfn THEN 
                 DO:
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      
                        UPDATE tel_cdagetfn 
                               WITH FRAME f_param_3
                      
                        EDITING:
                      
                             READKEY.
                      
                             IF LASTKEY = KEYCODE("F7") THEN
                                DO:
                                    IF FRAME-FIELD = "tel_cdagetfn" THEN
                                       DO:
                                           RUN fontes/zoom_pac.p
                                               (OUTPUT tel_cdagetfn).
    
                                           DISPLAY tel_cdagetfn 
                                                   WITH FRAME f_param_3.
                                       END.
                                END. 
                             ELSE 
                                APPLY LASTKEY.
                      
                        END. /*** Fim EDITING ***/
                          
                        RUN Valida_Pac.
                      
                        IF RETURN-VALUE <> "OK" THEN
                           NEXT.
    
                        LEAVE.
                     END.
    
                     IF KEYFUNCTIO(LAST-KEY) = "END-ERROR" THEN
                        NEXT.
    
                     DISP tel_cdagetfn
                          tel_dsagetfn 
                          WITH FRAME f_param_3.
            
                     /* Caso o Relatorio for Movimentacoes vamos mostrar os
                        campos referente a data */
                     IF tel_opcaorel:SCREEN-VALUE = "Movimentacoes" THEN
                        DO:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                
                               UPDATE tel_dtmvtini
                                      tel_dtmvtfim
                                      WITH FRAME f_param_4.
                               LEAVE.
            
                            END.
            
                            IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                               DO:
                                   HIDE FRAME f_param_4.
                                   CLEAR FRAME f_param_4 NO-PAUSE.
                                   NEXT.
                               END.
            
                        END.
                 END.
              ELSE
                 DO:
                     DISP tel_cdagetfn
                          tel_dsagetfn 
                          WITH FRAME f_param_3.
            
                     /* Caso o Relatorio for Movimentacoes vamos mostrar os
                        campos referente a data */
                     IF tel_opcaorel:SCREEN-VALUE = "Movimentacoes" THEN
                        DO:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                
                               UPDATE tel_dtmvtini
                                      tel_dtmvtfim
                                      tel_tiprelat
                                      WITH FRAME f_param_4.
                               LEAVE.
            
                            END.
            
                            IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                               DO:
                                   HIDE FRAME f_param_4.
                                   CLEAR FRAME f_param_4 NO-PAUSE.
                                   NEXT.
                               END.
                        END.
                 END.

          END. /* Fim do IF tipo de Relatorio */
          
          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
             MESSAGE "(T)erminal ou (A)rquivo: " UPDATE tel_cddopcao.
             LEAVE.
           
          END.
           
          IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
             DO:
                 HIDE FRAME f_param_3 
                      FRAME f_param_4.

                 CLEAR FRAME f_param_3      NO-PAUSE.
                 CLEAR FRAME f_param_4      NO-PAUSE.
                 CLEAR FRAME f_rel_deposito NO-PAUSE.
                  
                 NEXT.

             END.

          IF tel_cddopcao = "T" THEN 
             DO:
                 INPUT THROUGH basename `tty` NO-ECHO.
                       SET tel_nmarquiv WITH FRAME f_terminal.
                       INPUT CLOSE. 

                       aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                             aux_nmendter.

                 RUN imprime_relatorio (INPUT tel_opcaorel).

                 IF RETURN-VALUE <> "OK" THEN
                    LEAVE.

                 RUN fontes/visrel.p (INPUT aux_nmarqimp).
                 RUN fontes/confirma.p ( INPUT "Deseja efetuar a impressao?",
                                         OUTPUT aux_confirma).
           
                 IF aux_confirma = "S" THEN 
                    DO:
                        ASSIGN glb_cdempres = 11
                               glb_nrdevias = 1
                               glb_nmformul = "132col"
                               glb_nmarqimp = aux_nmarqimp
                               glb_nrcopias = 1.
              
                        FIND FIRST crapass 
                             WHERE crapass.cdcooper = glb_cdcooper 
                                   NO-LOCK NO-ERROR.
           
                        { includes/impressao.i }
                         
                    END.
             END.
          ELSE
             IF tel_cddopcao = "A" THEN
                DO:
                    FIND FIRST crapcop 
                             WHERE crapcop.cdcooper = glb_cdcooper 
                                   NO-LOCK NO-ERROR.

                    ASSIGN tel_nmarquiv = ""
                           tel_nmdireto = "micros/" + crapcop.dsdircop + "/".
                  
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       DISPLAY tel_nmdireto 
                               WITH FRAME f_diretorio.
                         
                       UPDATE tel_nmarquiv 
                              WITH FRAME f_diretorio.
                         
                       LEAVE.
                    END.

                    IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                       DO:
                           HIDE FRAME  f_diretorio.
                           CLEAR FRAME f_diretorio NO-PAUSE.
                           NEXT.
                       END.

                    RUN imprime_relatorio (INPUT tel_opcaorel).

                    IF RETURN-VALUE <> "OK" THEN
                       LEAVE.
                END.

          LEAVE.

       END.

       /* F4 ou FIM. */
       IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
           NEXT.

       LEAVE.

    END.

    /* F4 ou FIM. */
    IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
       LEAVE.

END PROCEDURE.

/* ......................................................................... */

PROCEDURE proc_opcaol:

    ASSIGN aux_confirma = "N"  tel_dsterfin = ""   
           tel_nrlacreA = 0    tel_qtdnotaA = 0   
           tel_vldnotaA = 0    tel_vltotalA = 0   
           tel_nrlacreB = 0    tel_qtdnotaB = 0 
           tel_vldnotaB = 0    tel_vltotalB = 0
           tel_nrlacreC = 0    tel_qtdnotaC = 0    
           tel_vldnotaC = 0    tel_vltotalC = 0  
           tel_nrlacreD = 0    tel_qtdnotaD = 0   
           tel_vldnotaD = 0    tel_vltotalD = 0  
           tel_nrlacreR = 0    tel_qtdnotaR = 0  
           tel_vltotalR = 0    tel_qttotalP = 0  
           tel_qtdnotaG = 0    tel_vltotalG = 0.    

    CLEAR FRAME f_cash NO-PAUSE.

    VIEW FRAME f_cash.

    tel_dsdopcao[1]:VISIBLE IN FRAME f_cash = FALSE.
    tel_dsdopcao[2]:VISIBLE IN FRAME f_cash = FALSE.
    tel_dsdopcao[3]:VISIBLE IN FRAME f_cash = FALSE.
    tel_dsdopcao[4]:VISIBLE IN FRAME f_cash = FALSE.
    tel_dsdopcao[5]:VISIBLE IN FRAME f_cash = FALSE.
    tel_dsdopcao[6]:VISIBLE IN FRAME f_cash = FALSE.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN tel_nrterfin = 0.

        UPDATE tel_nrterfin WITH FRAME f_param_1
        EDITING:
            
            READKEY.

            IF  LASTKEY = KEYCODE("F7") THEN
                DO:
                    IF  FRAME-FIELD = "tel_nrterfin" THEN
                        DO:
                            RUN fontes/zoom_cash.p ( INPUT  glb_cdcooper,
                                                    OUTPUT tel_nrterfin).

                            DISPLAY tel_nrterfin WITH FRAME f_param_1.

                            IF  tel_nrterfin > 0   THEN
                                APPLY "RETURN".
                            ELSE
                                CLEAR FRAME f_cash NO-PAUSE.  
                        END.

                END.
            ELSE
                APPLY LASTKEY.

        END.  /*  Fim do EDITING  */

        RUN Busca_Dados.

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.
     
        FIND FIRST tt-terminal NO-ERROR.

        IF  NOT AVAIL tt-terminal THEN
            NEXT.

        ASSIGN tel_dsterfin = tt-terminal.dsterfin

               tel_nrlacreA = tt-terminal.nrdlacre[1]
               tel_qtdnotaA = tt-terminal.qtnotcas[1]
               tel_vldnotaA = tt-terminal.vlnotcas[1]
               tel_vltotalA = tt-terminal.vltotcas[1]
               
               tel_nrlacreB = tt-terminal.nrdlacre[2]
               tel_qtdnotaB = tt-terminal.qtnotcas[2]
               tel_vldnotaB = tt-terminal.vlnotcas[2]
               tel_vltotalB = tt-terminal.vltotcas[2]

               tel_nrlacreC = tt-terminal.nrdlacre[3]
               tel_qtdnotaC = tt-terminal.qtnotcas[3]
               tel_vldnotaC = tt-terminal.vlnotcas[3]
               tel_vltotalC = tt-terminal.vltotcas[3]

               tel_nrlacreD = tt-terminal.nrdlacre[4]
               tel_qtdnotaD = tt-terminal.qtnotcas[4]
               tel_vldnotaD = tt-terminal.vlnotcas[4]
               tel_vltotalD = tt-terminal.vltotcas[4]

               tel_nrlacreR = tt-terminal.nrdlacre[5]
               tel_qtdnotaR = tt-terminal.qtnotcas[5]
               tel_vltotalR = tt-terminal.vltotcas[5]
               
               tel_qttotalP = tt-terminal.qtenvelo
               tel_qtdnotaG = tt-terminal.qtdnotag
               tel_vltotalG = tt-terminal.vltotalg
               tel_dssittfn = tt-terminal.dssittfn
            
               tel_nmoperad = tt-terminal.nmoperad.
             
        COLOR DISPLAY INPUT tel_qtdnotaR tel_vltotalR
            WITH FRAME f_cash.
        
        DISPLAY tel_nrlacreA tel_nrlacreB tel_nrlacreC tel_nrlacreD
                tel_qtdnotaA tel_qtdnotaB tel_qtdnotaC tel_qtdnotaD
                tel_vldnotaA tel_vldnotaB tel_vldnotaC tel_vldnotaD
                tel_vltotalA tel_vltotalB tel_vltotalC tel_vltotalD
                tel_qtdnotaR tel_vltotalR
                tel_qtdnotaG tel_vltotalG
                tel_nrlacreR tel_qttotalP tel_dssittfn
                tel_nmoperad  
                WITH FRAME f_cash.

        DISPLAY tel_dsterfin WITH FRAME f_param_1.

        LEAVE.

    END. /* FIM DO WHILE TRUE */
    
    IF  KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
        NEXT.

    MESSAGE COLOR NORMAL "Informe (E)nvelopes ou (N)umerarios." 
        UPDATE tel_tprecolh.

    IF  KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
        NEXT.

    RUN proc_confirma.

    IF  KEYFUNCTION(LAST-KEY) = "END-ERROR" OR aux_confirma = "N" THEN
        NEXT.

    RUN Grava_Dados.

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    RETURN "OK".
    
END PROCEDURE. /* FIM proc_opcaol */

/* ......................................................................... */

PROCEDURE proc_confirma:
   
   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
      RUN fontes/critic.p.
      glb_cdcritic = 0.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
               
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
           glb_cdcritic = 79.
           RUN fontes/critic.p.
           glb_cdcritic = 0.
           MESSAGE glb_dscritic.
           PAUSE 2 NO-MESSAGE.
        END. /* Mensagem de confirmacao */

END PROCEDURE.

/* ......................................................................... */

PROCEDURE bloqueio:

    ASSIGN aux_cddoptrs = "B".

    RUN Opcao_Transacao.

    IF  RETURN-VALUE <> "OK" THEN
        RETURN.

    MESSAGE "Operacao efetuada com sucesso!".

    RETURN.
    
END PROCEDURE.
/* Fim bloqueio cash */

/* ......................................................................... */

PROCEDURE bloqdsaq:

    ASSIGN aux_cddoptrs = "S".

    RUN Opcao_Transacao.

    IF  RETURN-VALUE <> "OK" THEN
        RETURN.

    MESSAGE "Operacao efetuada com sucesso!".

    RETURN.
    
END PROCEDURE.
/* Fim bloqueio saque*/

/* ......................................................................... */

PROCEDURE lista_envelopes:

    ASSIGN aux_cddoptrs = "D".

    RUN Opcao_Transacao.

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    ASSIGN aux_contador = 0.

    PAUSE 0.
    DOWN 10 WITH FRAME f_lista_envelopes.

    FOR EACH tt-envelopes:

        ASSIGN aux_contador = aux_contador + 1.

        DISPLAY tt-envelopes.dtmvtolt tt-envelopes.hrtransa
                tt-envelopes.nrdconta tt-envelopes.nrseqenv
                tt-envelopes.dsespeci tt-envelopes.vlenvinf
                tt-envelopes.vlenvcmp tt-envelopes.dssitenv
                WITH FRAME f_lista_envelopes.

        DOWN WITH FRAME f_lista_envelopes.

    END.

    PAUSE.
    HIDE FRAME f_lista_envelopes.
    
    RETURN "OK".

END PROCEDURE.
/* Fim lista_envelopes */

/* ......................................................................... */

/* controle de bloqueios do TAA */
PROCEDURE proc_opcaob:

    FORM tel_flsistaa        LABEL "Sistema TAA"   FORMAT "Liberado/Bloqueado"
                             HELP "Informe (L)iberado ou (B)loqueado"
        WITH ROW 8 COLUMN 4 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao_b.

    FORM  tel_dsterfin COLUMN-LABEL "Terminal"
          tel_flsistaa COLUMN-LABEL "Sistema TAA" FORMAT "Liberado/Bloqueado"
 WITH DOWN ROW 10 COLUMN 20 SIZE 45 BY 11 OVERLAY NO-BOX FRAME f_opcao_b_lista.

    HIDE FRAME f_cash.
    HIDE FRAME f_config.
    HIDE FRAME f_opcoes_trn.

    ASSIGN lis_tldatela = "Bloqueios dos TAAs".

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN tel_nrterfin = 0.

        UPDATE tel_nrterfin WITH FRAME f_param_1
        EDITING:

            READKEY.

            IF  LASTKEY = KEYCODE("F7") THEN
                DO:
                    IF  FRAME-FIELD = "tel_nrterfin" THEN
                        DO:
                            RUN fontes/zoom_cash.p ( INPUT  glb_cdcooper,
                                                         OUTPUT tel_nrterfin).
                                DISPLAY tel_nrterfin WITH FRAME f_param_1.
                                IF   tel_nrterfin > 0   THEN
                                     APPLY "RETURN".
                        END.
                    END. 
                ELSE 
                    APPLY LASTKEY.                      
        END. /*** Fim EDITING ***/

        /* lista os terminais */
        IF  tel_nrterfin = 0  THEN
            DO:
                ASSIGN tel_dsterfin = " - Todos os Terminais".

                DISPLAY tel_dsterfin WITH FRAME f_param_1.

                UPDATE tel_flsistaa WITH FRAME f_opcao_b.

                RUN Busca_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

                FOR EACH tt-terminal:
                    ASSIGN tel_dsterfin = tt-terminal.dsterfin
                           tel_flsistaa = tt-terminal.flsistaa.

                    DISPLAY tel_dsterfin tel_flsistaa
                        WITH FRAME f_opcao_b_lista.

                    DOWN WITH FRAME f_opcao_b_lista.

                END.

                RETURN.

            END. /* IF  tel_nrterfin = 0 */

        RUN Busca_Dados.

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.

        FIND FIRST tt-terminal NO-ERROR.

        LEAVE.                                   

    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        LEAVE.
    
    ASSIGN tel_dsterfin = tt-terminal.dsterfin
           tel_flsistaa = tt-terminal.flsistaa.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        DISPLAY tel_dsterfin WITH FRAME f_param_1.
        UPDATE tel_flsistaa WITH FRAME f_opcao_b.
        RUN proc_confirma.
        LEAVE.         
    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma = "N" THEN
        LEAVE.

    RUN Grava_Dados.

    IF  RETURN-VALUE <> "OK" THEN
        LEAVE.

    MESSAGE "Alteracao efetuada com sucesso!".
    PAUSE 2 NO-MESSAGE.
    
END PROCEDURE.

/* Monitoramento dos TAAs */
PROCEDURE proc_opcaom:

    DEF QUERY  q_crattfn FOR crattfn.
    
    DEF BROWSE b_crattfn QUERY q_crattfn
              DISPLAY crattfn.cdcoptfn COLUMN-LABEL "COOP"      FORMAT "zz9"
                      crattfn.nmagetfn COLUMN-LABEL "PA"        FORMAT "x(15)"
                      crattfn.nrterfin COLUMN-LABEL "TAA"
                      crattfn.dstransa COLUMN-LABEL "Horario"
                      crattfn.nmnarede COLUMN-LABEL "Nome"      FORMAT "x(12)"
                      crattfn.dsdoping COLUMN-LABEL "PING"      FORMAT "x(20)"
                      WITH 8 DOWN.

    FORM "Tolerancia de:"
        tel_mmtramax    FORMAT "z9" NO-LABEL
        "minutos "
        SKIP
        b_crattfn       HELP "Utilize as SETAS para navegar / F4 para sair"
        WITH ROW 8 COLUMN 4 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao_m.

    UPDATE tel_mmtramax WITH FRAME f_opcao_m.
    
    MESSAGE "Aguarde, analisando o log... ".
    
    RUN Busca_Dados.
    
    HIDE MESSAGE NO-PAUSE.
    
    OPEN QUERY q_crattfn FOR EACH crattfn BY crattfn.dstransa.
    
    UPDATE b_crattfn WITH FRAME f_opcao_m.

END PROCEDURE.

PROCEDURE imprime_relatorio:

    DEF INPUT PARAM par_opcaorel AS CHAR                           NO-UNDO.

    IF par_opcaorel = "Movimentacoes" THEN
       RUN Busca_Dados.
    ELSE
    IF par_opcaorel = "Cartoes Magneticos" THEN
       RUN busca_dados_cartoes_magneticos.
    ELSE
    IF par_opcaorel = "Depositos" THEN
       RUN Busca_Dados.

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE Busca_Dados:
    
    EMPTY TEMP-TABLE tt-terminal.
    EMPTY TEMP-TABLE crattfn.
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Busca_Dados IN h-b1wgen0123
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_cdprogra,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT glb_nmdatela,
          INPUT glb_dsdepart,
          INPUT glb_cddopcao,
          INPUT tel_nrterfin,
          INPUT tel_flsistaa,
          INPUT tel_mmtramax,
          INPUT tel_dtmvtini,
          INPUT tel_dtmvtfim,
          INPUT tel_cddopcao,
          INPUT tel_lgagetfn,
          INPUT tel_tiprelat,
          INPUT tel_cdagetfn,
          INPUT tel_nmarquiv,
          INPUT tel_cdsitenv,
          INPUT aux_opcaorel,
          INPUT TRUE, /* flgerlog */
         OUTPUT aux_nmarqimp,
         OUTPUT aux_nmarqpdf,
         OUTPUT TABLE tt-terminal,
         OUTPUT TABLE crattfn,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0123)  THEN
        DELETE PROCEDURE h-b1wgen0123.

    FIND FIRST tt-terminal NO-ERROR.

    HIDE MESSAGE NO-PAUSE.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            PAUSE 2 NO-MESSAGE.
                   
            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE busca_dados_cartoes_magneticos:
    
    EMPTY TEMP-TABLE tt-erro.
    
    RUN conecta_handle.
    
    RUN busca_dados_cartoes_magneticos IN h-b1wgen0123
        ( INPUT glb_cdcooper,
          INPUT 0, /* cdagenci */
          INPUT 0, /* nrdcaixa */
          INPUT glb_cdoperad,
          INPUT glb_cdprogra,
          INPUT 1, /* idorigem */
          INPUT glb_nmdatela,
          INPUT glb_dtmvtolt,
          INPUT tel_lgagetfn,
          INPUT tel_cdagetfn,
          INPUT tel_nmarquiv,
          INPUT tel_cddopcao,
          
          OUTPUT aux_nmarqimp,
          OUTPUT aux_nmarqpdf,
          OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0123)  THEN
        DELETE PROCEDURE h-b1wgen0123.

    HIDE MESSAGE NO-PAUSE.

    IF RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
           FIND FIRST tt-erro NO-ERROR.
           
           IF AVAILABLE tt-erro THEN
              MESSAGE tt-erro.dscritic.

           RETURN "NOK".  
       END.

    RETURN "OK".

END PROCEDURE. /* busca_dados_cartoes_magneticos */

PROCEDURE Opcao_Transacao:

    EMPTY TEMP-TABLE tt-transacao.
    EMPTY TEMP-TABLE tt-envelopes.
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Opcao_Transacao IN h-b1wgen0123
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_cdprogra,
          INPUT glb_nmdatela,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT aux_cddoptrs,
          INPUT tel_nrterfin,
          INPUT tel_dtlimite,
          INPUT tel_cdsitfin,
          INPUT tel_dtinicio,
          INPUT tel_dtdfinal,
          INPUT tel_cdsitenv,
          INPUT TRUE, /* flgerlog */
         OUTPUT tel_dtlimite,
         OUTPUT aux_qtsaques,
         OUTPUT aux_vlsaques,
         OUTPUT aux_qtestorn,
         OUTPUT aux_vlestorn,
         OUTPUT tel_cdsitfin,
         OUTPUT aux_flgblsaq,
         OUTPUT TABLE tt-transacao,
         OUTPUT TABLE tt-envelopes,
         OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen0123)  THEN
        DELETE PROCEDURE h-b1wgen0123.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Opcao_Transacao */

PROCEDURE Opcao_Operacao:

    EMPTY TEMP-TABLE tt-transacao.
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Opcao_Operacao IN h-b1wgen0123
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_cdprogra,
          INPUT glb_nmdatela,
          INPUT glb_dtmvtopr,
          INPUT glb_dtmvtolt,
          INPUT 1, /* idorigem */
          INPUT tel_dtlimite,
          INPUT tel_nrterfin,
          INPUT TRUE, /* flgerlog */
         OUTPUT tel_dtlimite,
         OUTPUT TABLE tt-transacao,
         OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen0123)  THEN
        DELETE PROCEDURE h-b1wgen0123.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Opcao_Operacao */

PROCEDURE Opcao_Sensores:

    EMPTY TEMP-TABLE tt-sensores.
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Opcao_Sensores IN h-b1wgen0123
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_cdprogra,
          INPUT glb_nmdatela,
          INPUT 1, /* idorigem */
          INPUT tel_nrterfin,
          INPUT TRUE, /* flgerlog */
         OUTPUT TABLE tt-sensores,
         OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen0123)  THEN
        DELETE PROCEDURE h-b1wgen0123.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Opcao_Sensores */

PROCEDURE Opcao_Saldos:

    EMPTY TEMP-TABLE tt-saldos.
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Opcao_Saldos IN h-b1wgen0123
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_cdprogra,
          INPUT glb_nmdatela,
          INPUT glb_dtmvtopr,
          INPUT glb_dtmvtolt,
          INPUT 1, /* idorigem */
          INPUT tel_dtlimite,
          INPUT tel_nrterfin,
          INPUT TRUE, /* flgerlog */
         OUTPUT tel_dtlimite,
         OUTPUT TABLE tt-saldos,
         OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen0123)  THEN
        DELETE PROCEDURE h-b1wgen0123.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Opcao_Saldos */

PROCEDURE Opcao_Log:

    EMPTY TEMP-TABLE tt-erro.

    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.

    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    RUN conecta_handle.

    MESSAGE "Aguarde...atualizando log!".

    RUN Opcao_Log IN h-b1wgen0123
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_cdprogra,
          INPUT glb_nmdatela,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT aux_nmendter,
          INPUT tel_dtlimite,       
          INPUT tel_nrterfin,
          INPUT TRUE, /* flgerlog */
         OUTPUT aux_nmarqimp,
         OUTPUT aux_nmarqpdf,
         OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen0123)  THEN
        DELETE PROCEDURE h-b1wgen0123.

    HIDE MESSAGE NO-PAUSE.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Opcao_Log */

PROCEDURE Valida_Dados:

    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Valida_Dados IN h-b1wgen0123
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT glb_nmdatela,
          INPUT glb_cddopcao,
          INPUT tel_nrterfin,
          INPUT tel_cdagenci,
          INPUT tel_cdsitfin,
          INPUT tel_qtcasset,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0123)  THEN
        DELETE PROCEDURE h-b1wgen0123.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Valida_Dados */

PROCEDURE Valida_Pac:

    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Valida_Pac IN h-b1wgen0123
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT 1, /* idorigem */
          INPUT tel_cdagetfn,
          INPUT tel_lgagetfn,
         OUTPUT tel_nmdireto,
         OUTPUT tel_dsagetfn,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0123)  THEN
        DELETE PROCEDURE h-b1wgen0123.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Valida_Pac */

PROCEDURE Grava_Dados:

    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Grava_Dados IN h-b1wgen0123
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_cdprogra,
          INPUT glb_nmdatela,
          INPUT glb_dsdepart,
          INPUT 1, /* idorigem */ 
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT glb_cddopcao,
          INPUT tel_nrterfin,
          INPUT tel_dsfabtfn,
          INPUT tel_dsmodelo,
          INPUT tel_dsdserie,
          INPUT tel_nmnarede,
          INPUT tel_nrdendip,
          INPUT tel_cdsitfin,
          INPUT tel_flsistaa,
          INPUT tel_cdagenci,
          INPUT tel_dsterfin,
          INPUT tel_qtcasset,
          INPUT glb_dtmvtoan,
          INPUT glb_nmoperad,
          INPUT tel_tprecolh,
          INPUT tel_qttotalP,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0123)  THEN
        DELETE PROCEDURE h-b1wgen0123.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
            
            RETURN "NOK".  
        END.

    IF  VALID-HANDLE(h-b1wgen0123)  THEN
        DELETE PROCEDURE h-b1wgen0123.

    RETURN "OK".

END PROCEDURE. /* Grava_Dados */

PROCEDURE conecta_handle:

    IF  NOT VALID-HANDLE(h-b1wgen0123) THEN
        RUN sistema/generico/procedures/b1wgen0123.p
            PERSISTENT SET h-b1wgen0123.

END PROCEDURE.
/* ......................................................................... */




