/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | includes/crps280.i              | pc_crps280_i                      |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/




/* ..........................................................................

   Programa: includes/crps280.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro      
   Data    : Fevereiro/2006                  Ultima atualizacao: 17/10/2014

   Dados referentes ao programa:

   Frequencia: Mensal ou Tela.
   Objetivo  : Atende a solicitacao 4 ou 104.
               Emite relatorio da provisao para creditos de liquidacao duvidosa
               (227).

   Alteracoes: 16/02/2006 - Alterado p/ listar Riscos por PAC (Diego).
   
               22/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               27/06/2006 - Alterado para liberar Arquivo PDF do relatorio 354
                            (Diego).
               
               25/07/2006 - Alterado numero de copias do relatorio 227 para 
                            Viacredi (Elton).             

               04/09/2006 - Envio do rel.227 por e_mail(substituido rel.354)
                            (Mirtes)
               
               08/12/2006 - Alterado para 3 o numero de copias do relatorio 227
                            para Viacredi (Elton).

               08/04/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
                          
                          - Enviar email para creditextil@creditextil.coop.br
                            (Gabriel).

               01/09/2008 - Alteracao cdempres (Kbase IT).
                             
                          - Incluir coluna com o pac , incluir email
                            convenios@viacredi.coop.br (Gabriel)

               23/10/2008 - Incluir prejuizo a +48M ate 60M (Magui).
               
               04/12/2008 - Tratamento para desconto de titulos somando com o
                            desconto de cheques (Evandro).
               
               19/05/2009 - Adicionado e-mail cdc@viacredi.coop.br para o
                            relatorio 227 com glb_cdcooper = 1 (Fernando).

               20/06/2009 - Adicionado e-mail controle@viacredi.coop.br para o
                            relatorio 227 com glb_cdcooper = 1 (Mirtes).
                            
               19/10/2009 - Enviado relatorio 35354.lst da viacredi para 
                            diretorio micros/viacredi/Tiago exceto quando 
                            executa fontes/crps184.p (Elton). 
                            
               04/12/2009 - Retirar campos relacianados ao Rating na crapass.
                            Utilizar a crapnrc (Gabriel).             
                            
               09/03/2010 - Gera arquivo texto para ser aberto no excel se
                            cooperativa for Viacredi ou Creditextil (Elton).
                            
                          - Nao listar os Rating que nao podem ser atualizados
                            no relatorio "Operacoes_credito_em_dia".
                            Este mesmo relatorio esta sendo disponibilizado
                            na intranet para todas as coopes (rel 552) (Gabriel).
                                                        
               02/06/2010 - Desconsiderar quando estouros em conta pra central
                            e emprestimos com menos de 6 meses (Gabriel).                                                            
               
               29/06/2010 - Tratamento para calculo da quantidade de meses 
                            decorridos (Elton).
               
               27/07/2010 - Gera relatorio crrl552.lst mesmo quando nao possuir
                            movimentos, mostrando somente o cabecalho (Elton).
                            
               09/08/2010 - Incluida coluna "MESES/DIAS ATR." para os relatorios 
                            crrl227.lst e crrl354.lst (Elton).
                            
               23/08/2010 - Feito tratamento de Emprestimos (0299),
                            Financiamento (0499) (Adriano).             
                            
               30/08/2010 - Modificada posicao da coluna "MESES/DIAS ATR." no
                            arquivo crrl354.txt (Evandro/Elton).         
                                               
               29/10/2010 - Correcao Parcelas em Atraso(Mirtes)
               
               13/12/2010 - Criado relatorio de contas em risco H por mais de
                            6 meses (Henrique).
               
               04/01/2011 - Incluido as colunas "Risco, Data Risco, Dias em 
                            Risco" (Adriano).
               
               02/02/2011 - Voltado qtdade parcela para inte. Impacto na
                            provisao das coopes muito grande (Magui).
                            
               02/03/2011 - Valores maiores que 5 milhoes devem ser informados
                            Ha uma alteracao no 3020 (Magui).
                            
               04/03/2011 - Ajuste para gerar o PDF do relatorio 581 (Henrique).
               
               22/03/2011 - Inserida informacao de dias de atraso no relatorio
                            crrl581 (Henrique).
                            
               08/04/2011 - Retirado os pontos dos campos numéricos e decimais
                            que são exportados para o arquivo crrl354.txt.
                            (Isara - RKAM)                            
                                                              
               29/04/2011 - Ajustado para multiplicar par_qtatraso por 30 
                            somente quando a origem for igual a 3 (Adriano).
                            Ajustes no campo qtdiaris (Magui).               
                               
               02/05/2011 - Substituido codigo por descricao no campo origem,
                            relatorio 581 (Adriano).
                            
               15/08/2011 - Copia relatorio crrl354.lst para o diretorio 
                            /micros/cecred/auditoria/"cooperativa".
                          - Copia relatorio crrl354.txt para diretorio
                            /micros/credifoz (Elton).                      
                            
               31/10/2011 - Alterado o format do campo aux_qtdiaris para "zzz9"
                            (Adriano).             
                            
               01/06/2012 - Exibir juros atraso + 60 e considerar este valor
                            no calculo da provisao (Gabriel).        
                            
               15/06/2012 - Ajuste no arquivo 354.txt (Gabriel)         
               
               17/09/2012 - Ajuste no campo risco Atual (Gabriel).  
               
               26/09/2012 - Ajuste no display do 354.txt (Gabriel).
               
               03/10/2012 - Disponibilizar arquivo crrl264.txt para
                            Alto Vale (David Kruger).
                           
               09/10/2012 - Ajuste no relatorio 227 referente ao desconto
                            de titulos da cob. registrada (Rafael).
                            
               07/12/2012 - Realizado a inclusao de um carecter * nas colunas: 
                             - "Risco", do relatório 354 (exeto o que eh gerado 
                               para envio ao radar).
                             - "Risco atual", do relatorio 227.
                            Para indicar que a conta faz parte de algum 
                            grupo economico (Adriano).
                            
               04/01/2013 - Criada procedure verifica_conta_altovale_280
                            para desprezar as contas migradas (Tiago).
                            
               11/01/2013 - Incluida condicao (craptco.tpctatrf <> 3) na
                            consulta da craptco (Tiago).             
                            
               07/02/2013 - Ajustes para o novo tipo de emprestimo (Gabriel).   
               
               27/03/2013 - Ajuste para usar o nrcpfcgc para verificar se o
                            mesmo esta em algum grupo economico (Adriano).
                            
               18/04/2013 - Ajustes realizados:
                             - Alterado "FIND crabris" para "FIND LAST crabris"
                               na procedure risco_h;
                             - Incluido "w-crapris.cdorigem = crapris.cdorigem"
                               no "FIRST w-crapris" da linha 643;
                             - Alimentado o campo cdorigem no create da 
                               w-crapris (Adriano).
               
               24/04/2013 - Ajustes referente ao acrescimo de uma coluna nos 
                            relatorios 354.lst, 354.txt, 227.lst com os dias em 
                            atraso dos emprestimos (Adriano).
                         
               30/04/2013 - Alimentado a "aux_qtprecal_deci = crapepr.qtprecal"
                            para quando for mensal (Adriano).
                            
               17/06/2013 - Alterado condição crabris.dtrefere >= aux_dtrefere
                           para crabris.dtrefere = aux_dtrefere.
                           Utilizado no relat. 552.(Irlan)
                           
               19/06/2013 - Tratar os dias de atraso da mesma maneira que a
                            includes crps398.i (Gabriel).          
                            
               21/06/2013 - Tratamento para criação do campo
                            w-crapris.nrseqctr (Lucas).  
                            
               09/07/2013 - Salva o crrl354 da CREDCREA no /micros (Ze).
               
               26/07/2013 - Incluido uma coluna ao final do arquivo crrl354.txt 
                            com o valor total do atraso atualizado do dia da 
                            geração do arquivo é o mesmo valor que vem da tela 
                            atenda (Oscar).
                            
               30/07/2013 - Leitura da crapebn quando crapris.cdorigem = 3
                            para verificar se eh emprestimo do BNDES. (Fabricio)
                            
               02/08/2013 - Definicao da temp-table w-crapris, pois dessa
                            forma, os fontes que chamam esta include nao
                            precisam mais declara-la.
                            Atribuicao do conteudo 'BNDES' para a coluna LC,
                            quando este for emprestimo do BNDES. Para isso,
                            alterado o tipo do campo w-crapris.cdlcremp, de
                            INTE para CHAR. (Fabricio)
               
               06/08/2013 - Incluido caminhos para geracao do arquiv crrl354.txt
                            para todas cooperativas (Tiago).  
                            
               21/08/2013 - Incluido a chamada da procedure 
                            "atualiza_dados_gerais_emprestimo"
                            "atualiza_dados_gerais_conta" para os contratos
                            que nao ocorreram debito (James).
                            
               12/09/2013 - Alteradas Strings de PAC para PA. (Reinert)
               
               26/09/2013 - Atualizar o campo dtatufin da tabela crapcyb.(James)
               
               02/10/2013 - Adicionado FORMAT para variável rel_vljura60.
                            (Reinert)
                            
               29/10/2013 - Ajustado para nao atualizar a data de atualizacao
                            financeira no cyber, quando o valor a regularizar
                            for igual 0. (James)
                            
               19/11/2013 - Ajuste para tratar quantidade de parcelas negativas
                            para os emprestimos "Price Prefixados"
                            (Adriano).    
                            
               02/12/2013 - Atualizar o campo tt-crapcyb.dtdpagto dos contratos
                            de emprestimos que estão no Cyber. (Oscar)          

               05/12/2013 - Alterada procedure verifica_conta_altovale_280
                            para verifica_conta_migracao_280 que despreza
                            as contas migradas (Tiago).
                          
               12/12/2013 - Alterado forma de calculo da inadimplencia nos 
                            relatorios 354 e 227, deduzido da variavel 
                            tot_vlropera o valor total de juros atraso +60.
                            (Reinert)             
                            
               17/12/2013 - Inserido PAs da migracao na condicao da craptco
                            na procedure verifica_conta_migracao_280 (Tiago).
                           
               07/01/2014 - Ajuste para melhorar performance (James).
               
               03/02/2014 - Remover a chamada da procedure 
                            "obtem-dados-emprestimo" (James)
                            
               11/02/2014 - Ajuste para criar os registros no CYBER (James)
               
               21/02/2014 - Ajuste para rodar na mensal (James)
               
               02/04/2014 - Ajuste para calcular o campo "w-crapris.nroprest"
                            para o novo tipo de emprestimo. (James)
                            
               25/06/2014 - Ajuste leitura CRAPRIS (Daniel) SoftDesk 137892.  
                            
               17/10/2014 - Inserido tratamento para migracao da 
                            Concredi -> Viacredi e Credimilsul -> Scrcred na 
                            procedure verifica_conta_migracao_280. (Jaison)
............................................................................. */
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0027tt.i }
{ sistema/generico/includes/b1wgen0168tt.i }
{ sistema/generico/includes/var_internet.i }

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.
DEF   VAR aux_nmarquiv AS CHAR                                       NO-UNDO.
DEF   VAR aux_cdlcremp AS CHAR                                       NO-UNDO.
DEF   VAR aux_risco    AS CHAR                                       NO-UNDO.
DEF   VAR aux_qtdmeses AS INTE                                       NO-UNDO.
DEF   VAR aux_qtprecal_retorno AS INTE                               NO-UNDO.
DEF   VAR aux_vlsdeved AS DECIMAL FORMAT "zzz,zzz,zz9.99-"           NO-UNDO.
DEF   VAR aux_vlsdeved_atual AS DECIMAL FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
DEF   VAR aux_qtatraso AS DECI                                       NO-UNDO.
DEF   VAR aux_dsdrisco AS CHAR FORMAT "x(20)" EXTENT 20              NO-UNDO.
DEF   VAR aux_nivrisco AS CHAR                                       NO-UNDO.
DEF   VAR aux_qtdiaris AS INTE                                       NO-UNDO.
DEF   VAR aux_vlr_arrasto AS DECIMAL                                 NO-UNDO.
DEF   VAR aux_dtdrisco AS DATE                                       NO-UNDO.
DEF   VAR aux_ddatraso AS INTE                                       NO-UNDO.
DEF   VAR aux_dsorigem AS CHAR FORMAT "x(1)"                         NO-UNDO.
DEF   VAR aux_vljura60 AS DECI EXTENT 20                             NO-UNDO.
DEF   VAR aux_vllimite AS DECI                                       NO-UNDO.
DEF   VAR aux_vlsalmin AS DECI                                       NO-UNDO.
DEF   VAR aux_diasatrs AS INTE                                       NO-UNDO.
DEF   VAR aux_dsnivris AS CHAR                                       NO-UNDO.
DEF   VAR aux_pertenge AS CHAR FORMAT "X(1)"                         NO-UNDO.

DEF   VAR aux_qtdiaatr AS INT                                        NO-UNDO.
DEF   VAR aux_qtprecal_deci AS DEC                                   NO-UNDO.
DEF   VAR aux_qtdopera AS INT FORMAT "zzz,zzz,zz9"                   NO-UNDO.
DEF   VAR aux_vlropera AS DEC FORMAT "zzz,zzz,zzz,zz9.99"            NO-UNDO.
DEF   VAR tot_qtdopera AS INT FORMAT "zzz,zzz,zz9"                   NO-UNDO.
DEF   VAR tot_vlropera AS DEC FORMAT "zzz,zzz,zzz,zz9.99"            NO-UNDO.
DEF   VAR aux_qtatrasa AS INT FORMAT "zzz,zzz,zz9"                   NO-UNDO.
DEF   VAR aux_vlatrasa AS DEC FORMAT "zzz,zzz,zzz,zz9.99"            NO-UNDO.
DEF   VAR tot_qtatrasa AS INT FORMAT "zzz,zzz,zz9"                   NO-UNDO.
DEF   VAR tot_vlatrasa AS DEC FORMAT "zzz,zzz,zzz,zz9.99"            NO-UNDO.
DEF   VAR aux_atrsinad AS INT FORMAT "zzz9"                          NO-UNDO.
DEF   VAR aux_prcntatr AS DEC FORMAT "zz9.99"                        NO-UNDO.
DEF   VAR tot_prcntatr AS DEC FORMAT "zz9.99"                        NO-UNDO.

DEF   VAR rel_vljura60 AS DECI FORMAT "zzz,zzz,zz9.99" EXTENT 20     NO-UNDO.

DEF   VAR ger_vljura60 AS DECI FORMAT "z,zzz,zzz,zz9.99"             NO-UNDO.

DEF   VAR tot_vljura60 AS DECI FORMAT "z,zzz,zzz,zz9.99"             NO-UNDO.

DEF   VAR h-b1wgen0129 AS HANDLE                                     NO-UNDO.
DEF   VAR h-b1wgen0002 AS HANDLE                                     NO-UNDO.
DEF   VAR h-b1wgen0168 AS HANDLE                                     NO-UNDO.
DEF   VAR aux_vlpreapg AS DEC  FORMAT "zzz,zzz,zzz,zz9.99-"          NO-UNDO.
DEF   VAR aux_txmensal AS DEC INIT 0 FORMAT "zz9.999999"             NO-UNDO.
DEF   VAR aux_txmenemp LIKE crapepr.txmensal                         NO-UNDO.
DEF   VAR aux_txdjuros AS DECI DECIMALS 7                            NO-UNDO.
DEF   VAR tab_indpagto AS INTE                                       NO-UNDO.
DEF   VAR tab_diapagto AS INTE                                       NO-UNDO.
DEF   VAR tab_dtcalcul AS DATE                                       NO-UNDO.
DEF   VAR tab_inusatab AS LOGI                                       NO-UNDO.
DEF   VAR tab_flgfolha AS LOGI                                       NO-UNDO.

DEF   VAR aux_dtcalcul AS DATE                                       NO-UNDO.   

DEF   BUFFER crabris     FOR crapris.
DEF   BUFFER b-crapris   FOR crapris.
DEF   BUFFER b-2-crapris FOR crapris.
DEF   BUFFER crabnrc     FOR crapnrc.

DEF   STREAM str_4.
DEF   STREAM str_5. 

DEF TEMP-TABLE w-crapris
    FIELD nrdconta LIKE crapris.nrdconta
    FIELD dtrefere LIKE crapris.dtrefere
    FIELD innivris LIKE crapris.innivris
    FIELD nrctremp LIKE crapris.nrctremp 
    FIELD nrseqctr LIKE crapris.nrseqctr 
    FIELD nroprest   AS dec
    FIELD vlpreemp LIKE crapepr.vlpreemp
    FIELD cdlcremp AS CHAR
    FIELD qtatraso AS DECI
    FIELD qtdiaatr AS INT
    FIELD cdorigem LIKE crapris.cdorigem
    INDEX nrdconta
          dtrefere
          innivris
          nrctremp.

DEF TEMP-TABLE tt-emprestimo
    FIELD cdcooper LIKE crapepr.cdcooper
    FIELD nrdconta LIKE crapepr.nrdconta
    FIELD nrctremp LIKE crapepr.nrctremp
    FIELD vlpapgat LIKE crapepr.vlpapgat
    FIELD flgpagto LIKE crapepr.flgpagto
    FIELD dtdpagto LIKE crapepr.dtdpagto
    FIELD vlsdevat LIKE crapepr.vlsdevat
    FIELD qtpcalat LIKE crapepr.qtpcalat
    FIELD txmensal LIKE crapepr.txmensal
    FIELD txjuremp LIKE crapepr.txjuremp
    FIELD vlppagat LIKE crapepr.vlppagat
    FIELD qtmdecat LIKE crapepr.qtmdecat
    FIELD inprejuz LIKE crapepr.inprejuz
    FIELD inliquid LIKE crapepr.inliquid
    FIELD qtpreemp LIKE crapepr.qtpreemp
    FIELD cdlcremp LIKE crapepr.cdlcremp
    FIELD cdfinemp LIKE crapepr.cdfinemp
    FIELD dtmvtolt LIKE crapepr.dtmvtolt
    FIELD vlemprst LIKE crapepr.vlemprst
    FIELD tpdescto LIKE crapepr.tpdescto
    INDEX cdcooper 
          nrdconta 
          nrctremp.

FORM rel_dsagenci     AT   1 FORMAT "x(21)" LABEL "PA"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS WIDTH 234 FRAME f_agencia.

FORM "CONTA/DV TITULAR"                                      AT   3
     "ORG "                                                  AT  48 
     "CONTRATO    LC    SALDO DEVEDOR  JUR.ATRASO+60"        AT  54   
     "PARCELA  QT. PARC. MESES/DIAS ATR.    TOT.ATRASO"      AT 107
     "DESPESA        %  PA  RIS ATU  RIS ANT DATA RISCO ANT" AT 162
     "DIAS RIS DIAS ATR"                                     AT 216   
     SKIP(1)
     WITH NO-BOX WIDTH 234 FRAME f_label.   

FORM crapass.nrdconta    AT    1 FORMAT "zzzz,zzz,9"
     crapass.nmprimtl    AT   12 FORMAT "x(35)" 
     aux_cdorigem        AT   50  
     crapris.nrctremp    AT   54 FORMAT "zzzzzzz9"
     w-crapris.cdlcremp  AT   65 FORMAT "x(05)"
     aux_vldivida        AT   71 FORMAT "zzz,zzz,zz9.99"  
     crapris.vljura60    AT   90 FORMAT "zzz,zz9.99-"
     w-crapris.vlpreemp  AT  103 FORMAT "zzzz,zz9.99" 
     w-crapris.nroprest  AT  119 FORMAT "zz9.99" 
     w-crapris.qtatraso  AT  135 FORMAT "zz9.99"  
     aux_vltotatr        AT  142 FORMAT "zz,zzz,zz9.99" 
     aux_vlpreatr        AT  157 FORMAT "z,zzz,zz9.99" 
     aux_percentu        AT  172 FORMAT "zz9.99"
     crapass.cdagenci    AT  179 FORMAT "zz9" 
     aux_dsnivris        AT  188 FORMAT "x(2)"
     aux_pertenge        AT  190 FORMAT "X(1)"
     aux_nivrisco        AT  199 FORMAT "x(2)" 
     aux_dtdrisco        AT  207 FORMAT "99/99/99"
     aux_qtdiaris        AT  220 FORMAT "zzz9"       
     w-crapris.qtdiaatr  AT  229 FORMAT "zzz9" 
     WITH NO-BOX NO-LABELS DOWN WIDTH 234 FRAME f_atraso.

FORM SKIP(1)
     "TOTAIS (EM ATRASO)   ==>" 
     tot_qtctremp AT  28 FORMAT "zzz,zz9"
     tot_vlsdvatr AT  71 FORMAT "zzz,zzz,zz9.99"
     tot_vlatraso AT 141 FORMAT "zzz,zzz,zz9.99"
     tot_vlpreatr AT 156 FORMAT "zz,zzz,zz9.99"
     SKIP(1)
     "TOTAIS (DA CARTEIRA) ==>" 
     tot_qtempres AT  28 FORMAT "zzz,zz9"
     tot_vlsdeved AT  71 FORMAT "zzz,zzz,zz9.99"
     tot_percentu AT 172 FORMAT "zz9.99"
     WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_totais.

FORM SKIP(1)
     "EMPR/FINANCIAMENTOS (E)      QTDE         SALDO DEVEDOR"
     SKIP(1)
     "TOTAL"               
     aux_qtdopera AT 23 
     aux_vlropera AT 38
     SKIP
     "ATRASO MAIOR" aux_atrsinad AT 14 "DIAS" 
     aux_qtatrasa AT 23 
     aux_vlatrasa AT 38
     SKIP
     "INADIMPLENCIA" aux_prcntatr AT 49
     "%" AT 55
     WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_epr_finan.
     
FORM SKIP(1)
     tot_qtctremp AT  12 LABEL "CONTRATOS EM ATRASO"
     tot_vlpreatr AT  59 LABEL "DESPESA PROVISIONADA"
     SKIP
     tot_qtctrato AT  15 LABEL "CONTRATOS EM DIA"
     tot_vldespes AT  59 LABEL "DESPESA PROVISIONADA"
     aux_percbase AT 115 FORMAT "zz9.99" NO-LABEL
     SKIP
     "-------"    AT  33  
     "------------------" AT 81 
     SKIP
     tot_qttotal  AT 33 FORMAT "zzz,zz9" NO-LABEL
     tot_vltotal  AT 81 FORMAT "zzz,zzz,zzz,zz9.99" NO-LABEL
     SKIP(1)
     WITH NO-BOX SIDE-LABELS WIDTH 234 FRAME f_resumo.
     
FORM rel_dsdrisco[aux_contador] LABEL "RISCO"    AT 20
     rel_percentu[aux_contador] LABEL "%   " 
     rel_qtdabase[aux_contador] LABEL "QUANT. CONTRATOS" 
     rel_vldabase[aux_contador] LABEL "SALDO DEVEDOR"  
     rel_vljura60[aux_contador] LABEL "JUROS ATRASO +60"
     rel_vlprovis[aux_contador] LABEL "DESPESA"
     WITH DOWN NO-BOX WIDTH 234 FRAME f_tabrisco.

FORM rel_dsdrisco[aux_contador] LABEL "RISCO"    AT 20
     rel_percentu[aux_contador] LABEL "%   " 
     aux_qtdabase[aux_contador] LABEL "QUANT. CONTRATOS" 
     aux_vldabase[aux_contador] LABEL "SALDO DEVEDOR"  
     aux_vljura60[aux_contador] LABEL "JUROS ATRASO +60"
     aux_vlprovis[aux_contador] LABEL "DESPESA"
     WITH DOWN NO-BOX WIDTH 234 FRAME f_tabrisco_pac.

FORM SKIP(1)
     "TOTAIS --- >"        AT 20
     tot_qtdabase NO-LABEL AT 41
     tot_vldabase NO-LABEL
     tot_vljura60 NO-LABEL    
     tot_vlprovis NO-LABEL 
     WITH DOWN NO-BOX WIDTH 234 FRAME f_tottab.
     
FORM SKIP(2)
     "--------- EM ATRASO ---------"       AT 29
     "------------- CARTEIRA ------------" AT 64
     SKIP
     "QTD.                    VALOR"       AT 29
     "QTD.                   VALOR      %" AT 64
     SKIP(1)
     atr_qtctremp AT 29 FORMAT "zzz,zz9"
     atr_vlatraso AT 42 FORMAT "z,zzz,zzz,zz9.99"
     atr_qtempres AT 64 FORMAT "zzz,zz9"
     atr_vlsdeved AT 76 FORMAT "z,zzz,zzz,zz9.99"
     atr_percentu AT 93 FORMAT "zz9.99"
     WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_geral.

FORM 
 " "                        AT 1
 " "                        AT 1
 "DADOS PARA CONTABILIDADE" AT 1 
 "                                   Provisao          Divida(S/Prejuizo)"  AT 1
 "Financiamentos Pessoais " AT 1 aux_rel1731_1  "       "  aux_rel1731_1_v
 "Financiamentos Empresas " AT 1 aux_rel1731_2  "       "  aux_rel1731_2_v
 "Emprestimos Pessoais    " AT 1 aux_rel1721    "       "  aux_rel1721_v
 "Emprestimos Empresas    " AT 1 aux_rel1723    "       "  aux_rel1723_v
 "Cheques Descontados     " AT 1 aux_rel1724_c  "       "  aux_rel1724_v_c
 "Titulos Desc. C/Registro" AT 1 aux_rel1724_cr "       "  aux_rel1724_v_cr
 "Titulos Desc. S/Registro" AT 1 aux_rel1724_sr "       "  aux_rel1724_v_sr
 "Adiant.Depositante      " AT 1 aux_rel1722_0101 "       "  aux_rel1722_0101_v
 "Outros Emprestimos      " AT 1 aux_rel1722_0299 "       "  aux_rel1722_0299_v
 "Cheque Especial         " AT 1 aux_rel1722_0201 "       "  aux_rel1722_0201_v
  WITH  NO-BOX NO-LABELS WIDTH 234 FRAME f_contabiliza.

FORM SKIP(1)
     "TOTAIS" aux_ttprovis AT 26 aux_ttdivida AT 53
     WITH  NO-BOX NO-LABELS WIDTH 234 FRAME f_total_geral.

FORM SKIP(2)
     "DADOS P/ CONTROLES INTERNOS"
     SKIP(1)
     "EMPR/FINANCIAMENTOS (E)      QTDE         SALDO DEVEDOR"
     SKIP(1)
     "TOTAL"               
     tot_qtdopera AT 23 
     tot_vlropera AT 38
     SKIP
     "ATRASO MAIOR" aux_atrsinad AT 14 "DIAS" 
     tot_qtatrasa AT 23 
     tot_vlatrasa AT 38
     SKIP
     "INADIMPLENCIA" tot_prcntatr AT 49
     "%" AT 55
     WITH  NO-BOX NO-LABELS WIDTH 234 FRAME f_epr_finan_geral.

                                                             
FORM crapass.cdagenci    COLUMN-LABEL "PA"              FORMAT "zz9"   
     crapass.nrdconta    COLUMN-LABEL "Conta"           FORMAT "zzzz,zzz,9"
     crapris.nrctremp    COLUMN-LABEL "Contrato"        FORMAT "z,zzz,zz9"
     w-crapris.cdlcremp  COLUMN-LABEL "LC"              FORMAT "X(05)"
     aux_vldivida        COLUMN-LABEL "S. Devedor"      FORMAT "z,zzz,zz9.99"
     aux_vlpreatr        COLUMN-LABEL "Vl.Provisao"     FORMAT "z,zzz,zz9.99"        
     w-crapris.vlpreemp  COLUMN-LABEL "Vl.Parcelas"     FORMAT "z,zzz,zz9.99"
     aux_percentu        COLUMN-LABEL "%"              
     aux_risco           COLUMN-LABEL "Risco"     
     WITH DOWN WIDTH 132 FRAME f_operacoes_credito.                       
   
FORM  "Conta/dv"                 AT 3
      "Nome"                     AT 12
      "Pa"                       AT 53
      "Origem"                   AT 57
      "Contrato"                 AT 66
      "LC"                       AT 77
      "Vlr. Divida"              AT 83
      "Dias de atraso"           AT 95
      SKIP
      "----------"
      "----------------------------------------" AT 12
      "---"                                      AT 53
      "------"                                   AT 57
      "----------"                               AT 64
      "----"                                     AT 75
      "--------------"                           AT 80
      "--------------"                           AT 95
      WITH NO-BOX WIDTH 132 FRAME f_cab_risco_h.     


FORM crapris.nrdconta NO-LABEL AT 1 
     crapass.nmprimtl NO-LABEL AT 12 FORMAT "x(40)" 
     crapass.cdagenci NO-LABEL AT 53 
     aux_dsorigem     NO-LABEL AT 62 
     crapris.nrctremp NO-LABEL AT 64 FORMAT "zz,zzz,zz9" 
     crapris.cdmodali NO-LABEL AT 75 
     crapris.vldivida NO-LABEL AT 80 FORMAT "zzz,zzz,zz9.99" 
     aux_ddatraso     NO-LABEL AT 102 FORMAT "zzz,zz9" 
     WITH DOWN NO-BOX WIDTH 132 FRAME f_risco_h.     

RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

/* Leitura das descricoes de risco A,B,C etc e percentuais */
ASSIGN aux_diarating = 0.

FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND 
                       craptab.tptabela = "GENERI"      AND 
                       craptab.cdempres = 00            AND
                       craptab.cdacesso = "PROVISAOCL"  
                       NO-LOCK:
                             
    ASSIGN aux_contador = INT(SUBSTR(craptab.dstextab,12,2))
           rel_dsdrisco[aux_contador] = TRIM(SUBSTR(craptab.dstextab,8,3))
           rel_percentu[aux_contador] = DECIMAL(SUBSTR(craptab.dstextab,1,6)).
         
    IF  craptab.tpregist = 999 THEN   
        ASSIGN  aux_diarating = INT(SUBSTR(craptab.dstextab,87,3)).

END.


ASSIGN  aux_dtmvtolt = (glb_dtmvtolt - aux_diarating). /* 180 dias */

FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                         craptab.nmsistem = "CRED"          AND 
                         craptab.tptabela = "GENERI"        AND 
                         craptab.cdempres = 00              AND
                         craptab.cdacesso = "PROVISAOCL"    AND
                         craptab.tpregist >= 0              
                         NO-LOCK NO-ERROR.
                             
IF NOT AVAILABLE craptab THEN
   ASSIGN aux_percbase = 100.
ELSE
   ASSIGN aux_percbase = DECIMAL(SUBSTR(craptab.dstextab,1,6)).
     
OUTPUT STREAM str_1 TO rl/crrl227.lst PAGED PAGE-SIZE 84.
OUTPUT STREAM str_2 TO rl/crrl354.lst PAGED PAGE-SIZE 84.

ASSIGN glb_cdrelato[1] = 227
       glb_cdrelato[2] = 354.

{ includes/cabrel234_1.i }
{ includes/cabrel234_2.i }

VIEW STREAM str_1 FRAME f_cabrel234_1.
VIEW STREAM str_2 FRAME f_cabrel234_2.


ASSIGN aux_rel1721        = 0
       aux_rel1723        = 0
       aux_rel1724_c      = 0
       aux_rel1724_sr     = 0
       aux_rel1724_cr     = 0
       aux_rel1731_1      = 0
       aux_rel1731_2      = 0
       aux_rel1722_0101   = 0
       aux_rel1722_0299   = 0
       aux_rel1722_0201   = 0
       aux_ttprovis       = 0
       aux_ttdivida       = 0
       aux_rel1721_v      = 0
       aux_rel1723_v      = 0
       aux_rel1724_v_c    = 0
       aux_rel1724_v_sr   = 0
       aux_rel1724_v_cr   = 0
       aux_rel1731_1_v    = 0
       aux_rel1731_2_v    = 0
       aux_rel1722_0101_v = 0
       aux_rel1722_0299_v = 0
       aux_rel1722_0201_v = 0.

EMPTY TEMP-TABLE w-crapris.


FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper AND 
                       crapris.dtrefere = aux_dtrefere AND
                       crapris.inddocto = 1   /* Docto 3020 */ 
                       NO-LOCK:

    RUN verifica_conta_migracao_280(INPUT glb_cdcooper,
                                    INPUT crapris.nrdconta,
                                    INPUT crapris.dtrefere,
                                    INPUT TODAY).

    IF RETURN-VALUE = "NOK" THEN
       NEXT.
    
    IF crapris.vldivida = 0   THEN 
       NEXT.
       
    CREATE w-crapris.

    ASSIGN w-crapris.nrdconta = crapris.nrdconta
           w-crapris.dtrefere = crapris.dtrefere
           w-crapris.innivris = crapris.innivris
           w-crapris.nrctremp = crapris.nrctremp
           w-crapris.cdorigem = crapris.cdorigem
           w-crapris.nrseqctr = crapris.nrseqctr.
    
    IF crapris.cdorigem = 3 THEN  /* Emprestimos/Financiamentos */
       DO: 
          FIND crapebn WHERE crapebn.cdcooper = glb_cdcooper     AND
                             crapebn.nrdconta = crapris.nrdconta AND
                             crapebn.nrctremp = crapris.nrctremp
                             NO-LOCK NO-ERROR.

          IF AVAIL crapebn THEN
          DO:
              ASSIGN w-crapris.vlpreemp = crapebn.vlparepr
                     w-crapris.cdlcremp = "BNDES"

                     w-crapris.qtatraso = IF crapris.qtdiaatr > 0 THEN
                                              TRUNCATE(crapris.qtdiaatr / 30,
                                                       0) + 1
                                          ELSE
                                              0

                     /* BNDES - Enquanto nao tivermos campo no arquivo de
                        OPERACOES da TOTVS com a quantidade
                        de parcelas em atraso, iremos utilizar a quantidade de
                        meses em atraso. Enquanto nao ultrapassar a da final
                        do contrato nao teremos problema, pois a quantidade de
                        meses em atraso vai bater com a quantidade de parcelas
                        em atraso. Porem, se ultrapassar, a quantidade de
                        meses continuara aumentando, e a quantidade de
                        parcelas nao, e este campo nao podera ser igual.
                        */
                      w-crapris.nroprest = w-crapris.qtatraso.
          END.
          ELSE
          DO:
              FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper      AND
                                 crapepr.nrdconta = crapris.nrdconta  AND
                                 crapepr.nrctremp = crapris.nrctremp 
                                 NO-LOCK NO-ERROR.
    
              IF AVAIL crapepr THEN
                 DO:
                    ASSIGN aux_qtmesdec = crapepr.qtmesdec
                           /* Efetuar correcao quantidade parcelas em atraso */
                           aux_qtprecal_retorno = crapepr.qtprecal.
    
                    IF crapepr.dtdpagto <> ? THEN          
                       DO:
                          IF DAY(crapepr.dtdpagto) > DAY(glb_dtmvtolt)     AND
                             MONTH(crapepr.dtdpagto) = MONTH(glb_dtmvtolt) AND
                             YEAR(crapepr.dtdpagto)  = YEAR(glb_dtmvtolt)  OR
                            (MONTH(glb_dtmvtolt) = MONTH(glb_dtmvtopr)     AND /*proc.semanal*/
                             crapepr.dtdpagto > glb_dtmvtolt)              THEN
                             DO:
                                ASSIGN  aux_qtmesdec = aux_qtmesdec - 1.
                             END.
                       END.

                    FIND crapass WHERE crapass.cdcooper = crapepr.cdcooper AND
                                       crapass.nrdconta = crapepr.nrdconta
                                       NO-LOCK.

                    FIND craplcr WHERE craplcr.cdcooper = crapepr.cdcooper AND
                                       craplcr.cdlcremp = crapepr.cdlcremp
                                       NO-LOCK NO-ERROR.
        
                    IF NOT AVAIL craplcr THEN
                       DO:
                           ASSIGN glb_cdcritic = 363.
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           ASSIGN glb_cdcritic = 0.
                           LEAVE.
                       END.

                    IF crapepr.tpemprst = 0 THEN
                       DO:
                           ASSIGN aux_txmenemp = craplcr.txmensal.
                       END.
                    ELSE
                       DO:
                           ASSIGN aux_txmenemp = crapepr.txmensal.
                       END.

                    /* Diario */
                    IF (MONTH(glb_dtmvtolt) = MONTH(glb_dtmvtopr)) THEN
                       DO: 
                           IF crapepr.tpemprst = 0 THEN
                              ASSIGN aux_qtprecal_deci = crapepr.qtlcalat.
                           ELSE 
                              ASSIGN aux_qtprecal_deci = crapepr.qtpcalat.
                              
                           ASSIGN aux_qtprecal_retorno = aux_qtprecal_deci
                                  aux_qtprecal_retorno = aux_qtprecal_retorno + 
                                                         crapepr.qtprecal
                                  aux_qtprecal_deci    = aux_qtprecal_deci + 
                                                         crapepr.qtprecal
                                  aux_vlsdeved_atual   = crapepr.vlsdevat.

                       END. /* END Diario  */
                    ELSE /* Mensal */
                       DO:
                           ASSIGN aux_qtprecal_retorno = crapepr.qtprecal
                                  aux_vlsdeved_atual   = crapepr.vlsdeved
                                  aux_qtprecal_deci    = crapepr.qtprecal.
                       END.

                    EMPTY TEMP-TABLE tt-erro.

                    RUN obtem-parametros-tabs-emprestimo (INPUT crapass.cdcooper,
                                                          INPUT crapass.cdagenci,
                                                          INPUT crapass.nrdconta,
                                                          INPUT glb_dtmvtolt,
                                                          OUTPUT tab_indpagto,
                                                          OUTPUT tab_diapagto,
                                                          OUTPUT tab_dtcalcul,
                                                          OUTPUT tab_flgfolha,
                                                          OUTPUT tab_inusatab,
                                                          OUTPUT TABLE tt-erro).
                        
                    IF tab_inusatab AND crapepr.inliquid = 0 THEN
                       ASSIGN aux_txdjuros = craplcr.txdiaria.
                    ELSE
                       ASSIGN aux_txdjuros = crapepr.txjuremp.

                    CREATE tt-emprestimo.
                    ASSIGN tt-emprestimo.cdcooper = crapepr.cdcooper
                           tt-emprestimo.nrdconta = crapepr.nrdconta
                           tt-emprestimo.nrctremp = crapepr.nrctremp
                           tt-emprestimo.vlpapgat = crapepr.vlpapgat
                           tt-emprestimo.flgpagto = crapepr.flgpagto 
                           tt-emprestimo.dtdpagto = crapepr.dtdpagto
                           tt-emprestimo.vlsdevat = crapepr.vlsdevat
                           tt-emprestimo.qtpcalat = crapepr.qtpcalat
                           tt-emprestimo.txmensal = aux_txmenemp
                           tt-emprestimo.txjuremp = aux_txdjuros
                           tt-emprestimo.vlppagat = crapepr.vlppagat
                           tt-emprestimo.qtmdecat = crapepr.qtmdecat
                           tt-emprestimo.inprejuz = crapepr.inprejuz
                           tt-emprestimo.inliquid = crapepr.inliquid
                           tt-emprestimo.qtpreemp = crapepr.qtpreemp
                           tt-emprestimo.cdlcremp = crapepr.cdlcremp
                           tt-emprestimo.cdfinemp = crapepr.cdfinemp
                           tt-emprestimo.dtmvtolt = crapepr.dtmvtolt
                           tt-emprestimo.vlemprst = crapepr.vlemprst
                           tt-emprestimo.tpdescto = crapepr.tpdescto.
                    VALIDATE tt-emprestimo.

                    ASSIGN aux_qtdiaatr = (aux_qtmesdec - aux_qtprecal_deci) * 30.
                     
                    IF   aux_qtdiaatr <= 0       AND 
                         crapepr.flgpagto = NO   THEN   /* Conta corrente */
                         DO:
                             ASSIGN aux_qtdiaatr = glb_dtmvtolt - crapepr.dtdpagto.
                         END.
    
                    IF  aux_qtdiaatr < 0 THEN
                        ASSIGN aux_qtdiaatr = 0.
    
                    IF crapepr.tpemprst = 1 then
                       ASSIGN w-crapris.qtdiaatr = crapris.qtdiaatr.        
                    ELSE
                       ASSIGN w-crapris.qtdiaatr = aux_qtdiaatr.
    
                    ASSIGN aux_qtmesdec = (aux_qtmesdec - aux_qtprecal_retorno).
                
                    IF aux_qtmesdec < 0 THEN
                       ASSIGN aux_qtmesdec = 0.
                    
                    ASSIGN aux_qtatraso = aux_qtmesdec. 
                    
                    IF aux_qtmesdec > crapepr.qtpreemp  THEN          
                       ASSIGN aux_qtmesdec = crapepr.qtpreemp.  
                    
                    ASSIGN w-crapris.vlpreemp = crapepr.vlpreemp
                           w-crapris.cdlcremp = STRING(crapepr.cdlcremp).
    
                    IF crapepr.tpemprst = 1   THEN
                       ASSIGN w-crapris.nroprest = (IF (crapepr.qtmesdec - 
                                                        crapepr.qtpcalat) < 0 THEN
                                                        0
                                                    ELSE
                                                      (crapepr.qtmesdec - 
                                                       crapepr.qtpcalat))
                              w-crapris.qtatraso = IF crapris.qtdiaatr > 0
                                                         THEN
                                                 TRUNCATE(crapris.qtdiaatr 
                                                     / 30 , 0) + 1
                                                   ELSE
                                                      0.
                    ELSE
                       ASSIGN w-crapris.nroprest = aux_qtmesdec
                              w-crapris.qtatraso = aux_qtatraso.
    
                 END.
          END.
       END.
    ELSE 
       IF crapris.cdorigem = 1 THEN  /* Conta Corrente */
          DO:
              FIND crapsld WHERE crapsld.cdcooper = crapris.cdcooper AND
                                 crapsld.nrdconta = crapris.nrdconta
                                 NO-LOCK NO-ERROR.
              
              IF AVAIL crapsld THEN
                 ASSIGN w-crapris.qtatraso = crapsld.qtdriclq.

          END.

END.

/* So o programa 280 gera este relatorio (Operacoes em dia ) */
IF glb_cdprogra = "crps280"   THEN
   DO:
       /* Operacoes em dia */
       OUTPUT STREAM str_3 TO VALUE("rl/crrl552.lst") PAGED PAGE-SIZE 84.
       
       ASSIGN glb_cdrelato[3] = 552.
           
       { includes/cabrel132_3.i }
       
       VIEW STREAM str_3 FRAME f_cabrel132_3.      
                                 
       /** Necessario para mostrar cabecalho quando nao houver movimentos **/
       DISPLAY STREAM str_3 WITH FRAME f_mostra_cabecalho.
                     
   END.

ASSIGN aux_nmarquiv = "crrl354.txt".

IF  glb_cdprogra <> "crps184"  THEN
    DO:
        OUTPUT STREAM str_4 TO VALUE("arq/" + aux_nmarquiv).
        
        PUT  STREAM str_4                        
             "CONTA/DV"         ";"  
             "TITULAR"          ";"
             "ORG"              ";" 
             "CONTRATO"         ";" 
             "LC"               ";" 
             "SALDO DEVEDOR"    ";"
             "JUR.ATRASO+60"    ";"
             "PARCELA"          ";" 
             "QT.PARC."         ";" 
             "TOT.ATRASO"       ";" 
             "DESPESA"          ";"      
             "%"                ";" 
             "PA"               ";"
             "MESES/DIAS ATR."  ";"
             "RIS ATU"          ";"
             "RIS ANT"          ";"
             "DATA RISCO ANT"   ";"
             "DIAS RIS"         ";"
             "DIAS ATR"          ";"
             "TOT.ATRASO ATENDA" SKIP.

    END.

OUTPUT STREAM str_5 TO VALUE ("rl/crrl581.lst") PAGED PAGE-SIZE 84.

ASSIGN glb_cdrelato[5] = 581.

{ includes/cabrel132_5.i }

VIEW STREAM str_5 FRAME f_cabrel132_5.

RUN sistema/generico/procedures/b1wgen0129.p PERSISTENT SET h-b1wgen0129.
RUN sistema/generico/procedures/b1wgen0168.p PERSISTENT SET h-b1wgen0168.

RUN busca_tab030 IN h-b1wgen0129 (INPUT glb_cdcooper,
                                  INPUT 0,
                                  INPUT 0,
                                  INPUT glb_cdoperad,
                                 OUTPUT aux_vllimite,
                                 OUTPUT aux_vlsalmin,
                                 OUTPUT aux_diasatrs,
                                 OUTPUT aux_atrsinad,
                                 OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0129.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND 
                   craptab.tptabela = "USUARI"     AND
                   craptab.cdempres = 11           AND
                   craptab.cdacesso = "JUROSNEGAT" AND
                   craptab.tpregist = 001          NO-LOCK NO-ERROR.
IF AVAIL craptab THEN
   ASSIGN aux_txmensal = DECIMAL(SUBSTRING(craptab.dstextab,1,10)).

FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper            AND
                       crapris.dtrefere = aux_dtrefere            AND
                       crapris.inddocto = 1  /* Docto 3020 */     
                       NO-LOCK,

    FIRST w-crapris WHERE w-crapris.dtrefere = crapris.dtrefere    AND
                          w-crapris.nrdconta = crapris.nrdconta    AND
                          w-crapris.innivris = crapris.innivris    AND
                          w-crapris.nrctremp = crapris.nrctremp    AND
                          w-crapris.nrseqctr = crapris.nrseqctr    AND
                          w-crapris.cdorigem = crapris.cdorigem,

     EACH crapass NO-LOCK WHERE crapass.cdcooper = glb_cdcooper    AND
                                crapass.nrdconta = crapris.nrdconta    
                                BREAK BY crapass.cdagenci 
                                       BY w-crapris.nroprest DESCENDING
                                        BY crapass.nmprimtl
                                         BY w-crapris.nrctremp
                                          BY w-crapris.nrseqctr:
                              
     RUN verifica_conta_migracao_280(INPUT glb_cdcooper,
                                     INPUT crapris.nrdconta,
                                     INPUT crapris.dtrefere,
                                     INPUT TODAY).

     IF RETURN-VALUE = "NOK" THEN
        NEXT.
            
     ASSIGN aux_qtpreatr       = 0
            aux_vltotatr       = 0
            aux_vlprejuz_conta = 0
            aux_vldivida       = 0.
            aux_cdlcremp       = "". 

     IF crapris.innivris = 9 THEN
        DO:
            RUN risco_h (INPUT  glb_cdcooper, 
                         INPUT  crapris.nrdconta, 
                         INPUT  aux_dtrefere,
                         INPUT  w-crapris.qtatraso).
        END.

     FOR EACH crapvri WHERE crapvri.cdcooper = glb_cdcooper     AND
                            crapvri.nrdconta = crapris.nrdconta AND
                            crapvri.dtrefere = crapris.dtrefere AND
                            crapvri.innivris = crapris.innivris AND
                            crapvri.cdmodali = crapris.cdmodali AND
                            crapvri.nrctremp = crapris.nrctremp AND 
                            crapvri.nrseqctr = crapris.nrseqctr     
                            NO-LOCK:
              
        IF crapvri.cdvencto >= 110 AND crapvri.cdvencto <= 290 THEN
           ASSIGN aux_vldivida = aux_vldivida + crapvri.vldivida.
           
        IF crapvri.cdvencto >= 205 AND crapvri.cdvencto <= 290 THEN 
           ASSIGN  aux_qtpreatr = 1
                   aux_vltotatr = aux_vltotatr + crapvri.vldivida.
           
        IF crapvri.cdvencto = 310 OR
           crapvri.cdvencto = 320 OR
           crapvri.cdvencto = 330 THEN
           ASSIGN aux_vlprejuz       = aux_vlprejuz + crapvri.vldivida
                  aux_vlprejuz_conta = aux_vlprejuz_conta + crapvri.vldivida.

     END.
           
     /* Nao provisionar/considerar prejuizo */   
     /* Se igual - somente prejuizo */           
     IF aux_vlprejuz_conta <> crapris.vldivida THEN 
        DO:                                                  
           ASSIGN aux_contador = crapris.innivris
                  aux_percentu = rel_percentu[aux_contador] 
                  aux_vlpercen = rel_percentu[aux_contador] / 100
                  aux_vlpreatr = ROUND( (aux_vldivida - crapris.vljura60 ) *
                                                aux_vlpercen ,2)
                  rel_qtdabase[aux_contador] = rel_qtdabase[aux_contador] + 1
                  aux_qtdabase[aux_contador] = aux_qtdabase[aux_contador] + 1
                  rel_vljura60[aux_contador] = rel_vljura60[aux_contador] +
                                               crapris.vljura60         
                  rel_vlprovis[aux_contador] = rel_vlprovis[aux_contador] + 
                                               aux_vlpreatr
                  aux_vljura60[aux_contador] = aux_vljura60[aux_contador] +
                                               crapris.vljura60
                  aux_vlprovis[aux_contador] = aux_vlprovis[aux_contador] +
                                               aux_vlpreatr
                  rel_vldabase[aux_contador] = rel_vldabase[aux_contador] + 
                                               aux_vldivida
                  aux_vldabase[aux_contador] = aux_vldabase[aux_contador] +
                                               aux_vldivida
                  aux_ttprovis = aux_ttprovis + aux_vlpreatr
                  aux_ttdivida = aux_ttdivida + aux_vldivida.
    
           IF crapris.cdorigem = 3 AND
              crapris.cdmodali = 0299 THEN 
              DO:
                 IF crapris.inpessoa = 1 THEN
                    ASSIGN aux_rel1721   = aux_rel1721   + aux_vlpreatr
                           aux_rel1721_v = aux_rel1721_v + aux_vldivida.
                 ELSE
                    ASSIGN aux_rel1723   = aux_rel1723   + aux_vlpreatr
                           aux_rel1723_v = aux_rel1723_v + aux_vldivida.

              END.

           IF crapris.cdorigem = 3 AND
              crapris.cdmodali = 0499 THEN 
              DO:
                 IF crapris.inpessoa = 1 THEN
                    ASSIGN aux_rel1731_1 = aux_rel1731_1 + aux_vlpreatr
                            aux_rel1731_1_v = aux_rel1731_1_v + aux_vldivida.
                 ELSE
                    ASSIGN aux_rel1731_2 = aux_rel1731_2 + aux_vlpreatr
                           aux_rel1731_2_v = aux_rel1731_2_v + aux_vldivida.

              END.
              
           IF crapris.cdorigem = 2 OR    /* Desconto de Cheques */
              crapris.cdorigem = 4 OR    /* Desconto de Titulos S/ Registro */
              crapris.cdorigem = 5 THEN  /* Desconto de Titulos C/ Registro */
              DO:
                 IF crapris.cdorigem = 2 THEN
                    ASSIGN aux_rel1724_v_c = aux_rel1724_v_c + aux_vldivida
                           aux_rel1724_c   = aux_rel1724_c   + aux_vlpreatr.

                 IF crapris.cdorigem = 4 THEN
                    ASSIGN aux_rel1724_v_sr = aux_rel1724_v_sr + aux_vldivida
                           aux_rel1724_sr   = aux_rel1724_sr   + aux_vlpreatr.

                 IF crapris.cdorigem = 5 THEN
                    ASSIGN aux_rel1724_v_cr = aux_rel1724_v_cr + aux_vldivida
                           aux_rel1724_cr   = aux_rel1724_cr   + aux_vlpreatr.

              END.

           IF crapris.cdorigem = 1 THEN
              DO:
                IF crapris.cdmodali = 0201 THEN
                   ASSIGN
                   aux_rel1722_0201 = aux_rel1722_0201 + aux_vlpreatr
                   aux_rel1722_0201_v = aux_rel1722_0201_v + aux_vldivida. 
                ELSE           
                   IF crapris.cdmodali = 0299 THEN
                      ASSIGN 
                      aux_rel1722_0299 = aux_rel1722_0299   + aux_vlpreatr  
                      aux_rel1722_0299_v = aux_rel1722_0299_v + aux_vldivida.
                   ELSE
                      ASSIGN 
                      aux_rel1722_0101   = aux_rel1722_0101   + aux_vlpreatr
                      aux_rel1722_0101_v = aux_rel1722_0101_v + aux_vldivida.

               END.      

           ASSIGN tot_qtdabase = tot_qtdabase + 1  /* Quantidade de Contratos */
                  ger_qtdabase = ger_qtdabase + 1
    
                  tot_qtempres = tot_qtempres + 1
                  tot_vlprovis = tot_vlprovis + aux_vlpreatr
                  tot_vldabase = tot_vldabase + aux_vldivida
                  ger_vlprovis = ger_vlprovis + aux_vlpreatr
                  ger_vldabase = ger_vldabase + aux_vldivida
                  ger_vljura60 = ger_vljura60 + crapris.vljura60 
                  tot_vlsdeved = tot_vlsdeved + aux_vldivida.
     
          IF aux_qtpreatr > 0 THEN 
             DO:
                ASSIGN tot_qtctremp = tot_qtctremp + 1
                       tot_vlpreatr = tot_vlpreatr + aux_vlpreatr.
             END.
          ELSE
             DO:
                ASSIGN tot_qtctrato = tot_qtctrato + 1
                       tot_vldespes = tot_vldespes + aux_vlpreatr.
             END.

            
          IF crapris.cdorigem = 3 THEN
             DO:
                ASSIGN aux_vlropera = aux_vlropera + aux_vldivida
                       aux_qtdopera = aux_qtdopera + 1
                       tot_qtdopera = tot_qtdopera + 1
                       tot_vlropera = tot_vlropera + (aux_vldivida - crapris.vljura60).
         
                IF w-crapris.qtdiaatr > aux_atrsinad THEN
                   ASSIGN aux_vlatrasa = aux_vlatrasa + aux_vldivida
                          aux_qtatrasa = aux_qtatrasa + 1
                          tot_qtatrasa = tot_qtatrasa + 1
                          tot_vlatrasa = tot_vlatrasa + aux_vldivida.

                ASSIGN aux_prcntatr = TRUNC(((aux_vlatrasa / aux_vlropera) * 100),2)
                       tot_prcntatr = TRUNC(((tot_vlatrasa / tot_vlropera) * 100),2).
                      
             END.
    
        END.     /* Somente considerar se nao prejuizo */
     
    IF FIRST-OF (crapass.cdagenci) THEN
       DO:
          PAGE STREAM str_1.
          PAGE STREAM str_2.
       
          FIND crapage WHERE crapage.cdcooper = glb_cdcooper      AND
                             crapage.cdagenci = crapass.cdagenci
                             NO-LOCK NO-ERROR.

          IF NOT AVAILABLE crapage   THEN
             ASSIGN rel_dsagenci = STRING(crapass.cdagenci,"zz9") +
                                   " - PA NAO CADASTRADO.".
          ELSE
             ASSIGN rel_dsagenci = STRING(crapass.cdagenci,"zz9") + " - " +
                                   crapage.nmresage.

          DISPLAY STREAM str_1 rel_dsagenci 
                               WITH FRAME f_agencia.

          VIEW STREAM str_1 FRAME f_label.

          DISPLAY STREAM str_2 rel_dsagenci 
                               WITH FRAME f_agencia.

          VIEW STREAM str_2 FRAME f_label.
          
       END.
    
    IF aux_qtpreatr > 0 THEN
       ASSIGN tot_vlsdvatr = tot_vlsdvatr + aux_vldivida.
           
    IF crapris.cdorigem = 1   THEN
       ASSIGN aux_cdorigem = "C".  /* Conta Corrente */
    ELSE
       IF  crapris.cdorigem = 2   OR
           crapris.cdorigem = 4   OR 
           crapris.cdorigem = 5   THEN
           ASSIGN aux_cdorigem = "D".  /* Desconto Cheques/Titulos */
       ELSE
           ASSIGN aux_cdorigem = "E". /* Emprestimo */
     
    IF aux_qtpreatr <= 0    AND  /* Em dia*/
       aux_percentu <> 0.5  AND  /* Risco "A" */
       aux_vldivida > 0     AND  /* Nao listar Prejuizo */
       aux_cdorigem = "E"   THEN /* So emprestimo */
       DO:    
          /* Rating efetivo */
          FIND crapnrc WHERE crapnrc.cdcooper = glb_cdcooper     AND
                             crapnrc.nrdconta = crapass.nrdconta AND
                             crapnrc.insitrat = 2
                             NO-LOCK NO-ERROR.
          
          FIND crapebn WHERE crapebn.cdcooper = glb_cdcooper     AND
                             crapebn.nrdconta = crapass.nrdconta AND
                             crapebn.nrctremp = crapris.nrctremp
                             NO-LOCK NO-ERROR.

          IF AVAIL crapebn THEN
          DO:
              FIND crabnrc WHERE crabnrc.cdcooper = glb_cdcooper     AND
                                 crabnrc.nrdconta = crapebn.nrdconta AND
                                 crabnrc.nrctrrat = crapebn.nrctremp AND
                                 crabnrc.tpctrrat = 90
                                 NO-LOCK NO-ERROR.

              IF AVAIL crabnrc THEN
                  ASSIGN aux_dsnivris = crabnrc.indrisco.
              ELSE
                  ASSIGN aux_dsnivris = rel_dsdrisco[w-crapris.innivris].
          END.
          ELSE
          DO:
              FIND crawepr WHERE crawepr.cdcooper = glb_cdcooper     AND
                                 crawepr.nrdconta = crapass.nrdconta AND
                                 crawepr.nrctremp = crapris.nrctremp 
                                 NO-LOCK NO-ERROR.

              IF AVAIL crawepr THEN
                  ASSIGN aux_dsnivris = crawepr.dsnivris.
          END.


          ASSIGN aux_dtcalcul = glb_dtmvtolt - 1.

          DO  WHILE TRUE:
            IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtcalcul)))             OR
                CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND
                                       crapfer.dtferiad = aux_dtcalcul) THEN
                DO:
                    aux_dtcalcul = aux_dtcalcul - 1.
                    NEXT.             
                END.
            LEAVE.
          END.  /*  Fim do DO WHILE TRUE  */

          IF MONTH(aux_dtcalcul) <> MONTH(glb_dtmvtolt) THEN
            ASSIGN aux_dtcalcul = ?. 
          

          ASSIGN aux_qtdmeses = 0.

          /* Quantidade de meses */
          FOR EACH crabris WHERE crabris.cdcooper = glb_cdcooper       AND
                                 crabris.nrdconta = crapris.nrdconta   AND
                                 crabris.nrctremp = crapris.nrctremp   AND 
                                 crabris.cdorigem = 3                  AND
                                 crabris.dtrefere <> aux_dtcalcul
                                 NO-LOCK:
         
              ASSIGN aux_qtdmeses = aux_qtdmeses + 1.
         
          END.

          /* Estouro de conta */
          FIND LAST crabris WHERE  crabris.cdcooper = glb_cdcooper       AND
                                   crabris.nrdconta = crapris.nrdconta   AND
                                   crabris.dtrefere = aux_dtrefere       AND
                                   crabris.inddocto = 1                  AND /* Dcto 3020*/
                                   crabris.cdmodali = 0101               AND /*Adiant. a Depos*/
                                   crabris.cdorigem = 1                     /* Conta */             
                                   NO-LOCK NO-ERROR.                                                         
           
          /* Niveis com risco A, nao podem ser melhorados, entao sao
             ignorados no relatorio */

          /* Nao pode ter estouro de Conta */

          /* Emprestimo com igual/mais de 6 meses */

          /* Somente quem nao tem Rating */
          
          IF NOT AVAIL crapnrc         AND
             NOT AVAIL crabris         AND
             aux_qtdmeses     >= 6     AND
             aux_dsnivris    <> "A"    THEN         
             DO:
                 ASSIGN aux_risco = rel_dsdrisco[w-crapris.innivris].
                                                 
                 /* So este programa gera este relatorio */
                 IF glb_cdprogra = "crps280"   THEN
                    DO:
                        
                        DISPLAY STREAM str_3 crapass.cdagenci 
                                             crapass.nrdconta 
                                             crapris.nrctremp 
                                             w-crapris.cdlcremp 
                                             aux_vldivida 
                                             aux_vlpreatr  
                                             w-crapris.vlpreemp  
                                             aux_percentu
                                             aux_risco 
                                             WITH FRAME f_operacoes_credito.
             
                        DOWN WITH FRAME f_operacoes_credito.
                                                    
                    END.

             END.
                         
       END.  

    /* Obtem risco */
    FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper AND
                           craptab.nmsistem = "CRED"       AND 
                           craptab.tptabela = "GENERI"     AND 
                           craptab.cdempres = 00           AND
                           craptab.cdacesso = "PROVISAOCL" 
                           NO-LOCK:
                                       
        ASSIGN aux_contador = INT(SUBSTR(craptab.dstextab,12,2))
               aux_dsdrisco[aux_contador] = TRIM(SUBSTR(craptab.dstextab,8,3)).

    END.
                              
    /* Alimentar variavel para nao ser preciso criar registro na PROVISAOCL */
    ASSIGN aux_dsdrisco[10] = "H"
           aux_nivrisco = ""
           aux_dtdrisco = ?   
           aux_qtdiaris = 0. 

    FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = "RISCOBACEN" AND
                       craptab.tpregist = 000 
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL craptab   THEN 
       DO:
           ASSIGN glb_cdcritic = 55.
           RUN fontes/critic.p.
           BELL.
           MESSAGE glb_dscritic.
           ASSIGN glb_cdcritic = 0.
           LEAVE. 

       END.
        
    ASSIGN aux_vlr_arrasto = DEC(SUBSTRING(craptab.dstextab,3,9)).
    
    FIND LAST b-crapris WHERE b-crapris.cdcooper = crapass.cdcooper AND
                              b-crapris.nrdconta = crapass.nrdconta AND 
                              b-crapris.dtrefere = glb_dtultdma     AND 
                              b-crapris.inddocto = 1                AND 
                              b-crapris.vldivida > aux_vlr_arrasto /*Valor arrasto*/
                              NO-LOCK NO-ERROR.
                            
    IF NOT AVAIL b-crapris THEN
       FIND LAST b-crapris WHERE b-crapris.cdcooper = crapass.cdcooper AND
                                 b-crapris.nrdconta = crapass.nrdconta AND 
                                 b-crapris.dtrefere = aux_dtrefere     AND 
                                 b-crapris.inddocto = 1 
                                 NO-LOCK NO-ERROR.

    IF AVAIL b-crapris THEN
       DO:
          ASSIGN aux_nivrisco = aux_dsdrisco[b-crapris.innivris]
                 aux_dtdrisco = b-crapris.dtdrisco     
                 aux_qtdiaris = IF  glb_dtmvtolt > b-crapris.dtdrisco
                                    THEN 
                                       glb_dtmvtolt - b-crapris.dtdrisco
                                    ELSE 
                                       0.
       END.                               
    ELSE
       ASSIGN aux_nivrisco = "A". 

    FIND LAST b-2-crapris WHERE b-2-crapris.cdcooper = crapass.cdcooper AND
                                b-2-crapris.nrdconta = crapass.nrdconta AND 
                                b-2-crapris.dtrefere = aux_dtrefere     AND 
                                b-2-crapris.inddocto = 1                AND 
                                b-2-crapris.vldivida > aux_vlr_arrasto /*Valor arrasto*/
                                NO-LOCK NO-ERROR.

    IF NOT AVAIL b-2-crapris THEN
       FIND LAST b-2-crapris WHERE 
                 b-2-crapris.cdcooper = crapass.cdcooper AND
                 b-2-crapris.nrdconta = crapass.nrdconta AND 
                 b-2-crapris.dtrefere = aux_dtrefere     AND 
                 b-2-crapris.inddocto = 1 
                 NO-LOCK NO-ERROR.

    IF AVAIL b-2-crapris THEN
       ASSIGN aux_dsnivris = aux_dsdrisco[b-2-crapris.innivris].                               
    ELSE
       ASSIGN aux_dsnivris = "A". 


    ASSIGN aux_pertenge = "".

    /*Verifica se o cpf em questao pertence a algum grupo economico*/
    FIND FIRST crapgrp WHERE crapgrp.cdcooper = crapris.cdcooper AND
                             crapgrp.nrcpfcgc = crapris.nrcpfcgc
                             NO-LOCK NO-ERROR.

    IF AVAIL crapgrp THEN
       ASSIGN aux_pertenge = "*".

    IF aux_qtpreatr > 0             AND 
       ((crapris.cdmodali = 101     AND    /* Adiantamento a depositante */
         crapris.qtdriclq >= aux_diasatrs) OR 
         crapris.cdmodali <> 101   )   THEN
       DO: 
          DISPLAY STREAM str_1 crapass.nrdconta 
                               crapass.nmprimtl 
                               aux_cdorigem
                               crapris.nrctremp
                               w-crapris.cdlcremp WHEN aux_cdorigem = "E"
                               aux_vlpreatr
                               aux_vldivida   
                               crapris.vljura60
                               w-crapris.vlpreemp
                               aux_vltotatr
                               w-crapris.nroprest  
                               w-crapris.qtatraso 
                               aux_percentu 
                               crapass.cdagenci 
                               aux_dsnivris WHEN aux_dsnivris <> "AA"
                               aux_pertenge
                               aux_nivrisco 
                               aux_dtdrisco 
                               aux_qtdiaris 
                               w-crapris.qtdiaatr
                               WITH FRAME f_atraso. 

          DOWN  STREAM str_1 WITH FRAME f_atraso. 

          IF LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
             DO:
                PAGE STREAM str_1.
                DISPLAY STREAM str_1 rel_dsagenci 
                                     WITH FRAME f_agencia.

                VIEW STREAM str_1 FRAME f_label.

             END.
            
       END. 

    IF aux_vldivida > 0   THEN /* Nao listar prejuizo total */      
       DO:                
           
           DISPLAY STREAM str_2 crapass.nrdconta 
                                crapass.nmprimtl 
                                aux_cdorigem
                                w-crapris.cdlcremp WHEN aux_cdorigem = "E"
                                crapris.nrctremp  
                                aux_vlpreatr
                                aux_vldivida   
                                crapris.vljura60  
                                w-crapris.vlpreemp
                                aux_vltotatr
                                w-crapris.nroprest  
                                w-crapris.qtatraso 
                                aux_percentu
                                crapass.cdagenci 
                                aux_dsnivris WHEN aux_dsnivris <> "AA" 
                                aux_pertenge
                                aux_nivrisco 
                                aux_dtdrisco 
                                aux_qtdiaris 
                                w-crapris.qtdiaatr
                                WITH FRAME f_atraso. 
           
           DOWN STREAM str_2 WITH FRAME f_atraso.       
           
           IF LINE-COUNTER(str_2) > 81   THEN
              DO:
                 PAGE STREAM str_2.
                 DISPLAY STREAM str_2 rel_dsagenci 
                                      WITH FRAME f_agencia.

                 VIEW STREAM str_2 FRAME f_label.

              END.
          
          IF  glb_cdprogra <> "crps184"   THEN
              DO:

                  ASSIGN aux_cdlcremp = "".

                  IF aux_cdorigem = "E"   THEN
                     DO:
                       ASSIGN aux_cdlcremp = w-crapris.cdlcremp. 

                       EMPTY TEMP-TABLE tt-crapcyb.
                  
                       FIND tt-emprestimo
                            WHERE tt-emprestimo.cdcooper = crapris.cdcooper AND
                                  tt-emprestimo.nrdconta = crapris.nrdconta AND
                                  tt-emprestimo.nrctremp = crapris.nrctremp
                                  NO-LOCK NO-ERROR.

                       ASSIGN aux_vlpreapg = 0.
                       IF AVAIL tt-emprestimo THEN
                          DO:
                              ASSIGN aux_vlpreapg = tt-emprestimo.vlpapgat.

                              IF ((tt-emprestimo.cdcooper = 2)  AND 
                                  (tt-emprestimo.cdlcremp = 850 OR 
                                   tt-emprestimo.cdlcremp = 900)) THEN
                                 DO:
                                     CREATE tt-crapcyb.
                                     ASSIGN tt-crapcyb.cdorigem = 2.
                                 END.
                              ELSE 
                                 IF ((tt-emprestimo.cdcooper <> 2) AND 
                                     (tt-emprestimo.cdlcremp = 800 OR 
                                      tt-emprestimo.cdlcremp = 900)) THEN
                                    DO:
                                        CREATE tt-crapcyb.
                                        ASSIGN tt-crapcyb.cdorigem = 2.
                                    END.
                              ELSE
                                 DO:
                                     CREATE tt-crapcyb.
                                     ASSIGN tt-crapcyb.cdorigem = 3.
                                 END.

                          END. /* END IF AVAIL tt-emprestimo */

                       IF TEMP-TABLE tt-crapcyb:HAS-RECORDS THEN
                          DO:
                              ASSIGN tt-crapcyb.cdcooper = crapris.cdcooper
                                     tt-crapcyb.nrdconta = crapris.nrdconta
                                     tt-crapcyb.nrctremp = crapris.nrctremp
                                     tt-crapcyb.dtmvtolt = glb_dtmvtolt
                                     tt-crapcyb.vlsdeved = tt-emprestimo.vlsdevat
                                     tt-crapcyb.vlpreapg = tt-emprestimo.vlpapgat
                                     tt-crapcyb.qtprepag = tt-emprestimo.qtpcalat
                                     tt-crapcyb.txmensal = tt-emprestimo.txmensal
                                     tt-crapcyb.txdiaria = tt-emprestimo.txjuremp
                                     tt-crapcyb.vlprepag = tt-emprestimo.vlppagat
                                     tt-crapcyb.qtmesdec = tt-emprestimo.qtmdecat
                                     tt-crapcyb.dtdpagto = tt-emprestimo.dtdpagto
                                     tt-crapcyb.cdlcremp = tt-emprestimo.cdlcremp
                                     tt-crapcyb.cdfinemp = tt-emprestimo.cdfinemp
                                     tt-crapcyb.dtefetiv = tt-emprestimo.dtmvtolt
                                     tt-crapcyb.vlemprst = tt-emprestimo.vlemprst
                                     tt-crapcyb.qtpreemp = tt-emprestimo.qtpreemp
                                     tt-crapcyb.flgfolha = tt-emprestimo.flgpagto
                                     tt-crapcyb.vljura60 = crapris.vljura60
                                     tt-crapcyb.vlpreemp = w-crapris.vlpreemp
                                     tt-crapcyb.qtpreatr = w-crapris.nroprest
                                     tt-crapcyb.vldespes = aux_vlpreatr
                                     tt-crapcyb.vlperris = aux_percentu
                                     tt-crapcyb.nivrisat = aux_dsnivris
                                     tt-crapcyb.nivrisan = aux_nivrisco
                                     tt-crapcyb.dtdrisan = aux_dtdrisco
                                     tt-crapcyb.qtdiaris = aux_qtdiaris
                                     tt-crapcyb.qtdiaatr = w-crapris.qtdiaatr
                                     tt-crapcyb.flgrpeco = (aux_pertenge = "*")
                                     tt-crapcyb.flgpreju = 
                                                 LOGICAL(tt-emprestimo.inprejuz)
                                     tt-crapcyb.flgconsg = 
                                                 (tt-emprestimo.tpdescto = 2)
                                     tt-crapcyb.flgresid =
                                                 (tt-emprestimo.inprejuz  = 0 AND
                                                  tt-emprestimo.inliquid  = 0 AND
                                                  tt-emprestimo.vlsdevat >= 0 AND
                                                  tt-emprestimo.qtpcalat >= 
                                                  tt-emprestimo.qtpreemp).
                                                 
                              TRANS_CYBER:
                              DO TRANSACTION ON ERROR UNDO TRANS_CYBER:
                                 RUN atualiza_dados_financeiro
                                  IN h-b1wgen0168(INPUT TABLE tt-crapcyb,
                                                  OUTPUT aux_cderr168,
                                                  OUTPUT aux_dserr168).
                
                                 IF RETURN-VALUE <> "OK" THEN
                                    DO:
                                        RUN busca_descricao_critica
                                         IN h-b1wgen0168(INPUT aux_cderr168,
                                                         OUTPUT aux_dserr168).
                                        
                                        BELL.
                                        MESSAGE aux_dserr168.
                                        UNDO TRANS_CYBER.
                                    END.
                 
                              END. /* TRANS_CYBER */

                          END. /* TEMP-TABLE tt-crapcyb:HAS-RECORDS */
                     END.
                  ELSE
                     IF aux_cdorigem = "C" THEN
                        DO:
                           /* Adiant. a Depos */
                           IF crapris.cdmodali = 0101 THEN
                              DO:
                                  EMPTY TEMP-TABLE tt-crapcyb.
            
                                  CREATE tt-crapcyb.
                                  ASSIGN tt-crapcyb.cdcooper = crapris.cdcooper
                                         tt-crapcyb.cdorigem = 1
                                         tt-crapcyb.nrdconta = crapris.nrdconta
                                         tt-crapcyb.nrctremp = crapris.nrctremp
                                         tt-crapcyb.dtmvtolt = glb_dtmvtolt
                                         tt-crapcyb.dtdpagto = glb_dtmvtolt
                                         tt-crapcyb.dtefetiv = glb_dtmvtolt
                                         tt-crapcyb.qtpreemp = 1
                                         tt-crapcyb.vlemprst = aux_vldivida
                                         tt-crapcyb.vlsdeved = aux_vldivida
                                         tt-crapcyb.vljura60 = crapris.vljura60
                                         tt-crapcyb.vlpreemp = w-crapris.vlpreemp
                                         tt-crapcyb.qtpreatr = w-crapris.nroprest
                                         tt-crapcyb.vlpreapg = aux_vldivida
                                         tt-crapcyb.vldespes = aux_vlpreatr
                                         tt-crapcyb.vlperris = aux_percentu
                                         tt-crapcyb.nivrisat = aux_dsnivris
                                         tt-crapcyb.nivrisan = aux_nivrisco
                                         tt-crapcyb.dtdrisan = aux_dtdrisco
                                         tt-crapcyb.qtdiaris = aux_qtdiaris
                                         tt-crapcyb.qtdiaatr = w-crapris.qtatraso
                                         tt-crapcyb.flgrpeco = (aux_pertenge = "*")
                                         tt-crapcyb.txmensal = aux_txmensal.
                                  
                                  TRANS_CYBER:
                                  DO TRANSACTION ON ERROR UNDO TRANS_CYBER:
                                  
                                     RUN atualiza_dados_financeiro
                                         IN h-b1wgen0168(INPUT TABLE tt-crapcyb,
                                                         OUTPUT aux_cderr168,
                                                         OUTPUT aux_dserr168).
                                     
                                     IF RETURN-VALUE <> "OK" THEN
                                        DO:
                                            RUN busca_descricao_critica
                                             IN h-b1wgen0168 
                                                (INPUT aux_cderr168,
                                                 OUTPUT aux_dserr168).
                                           
                                            BELL.
                                            MESSAGE aux_dserr168.
                
                                            UNDO TRANS_CYBER.
                                        END.
                                  
                                  END. /* END - TRANS_CYBER */

                              END. /* END - Adiant. a Depos */

                        END. /* END - aux_cdorigem = C */
                      
                  PUT STREAM  str_4 STRING(crapass.nrdconta)   ";"
                                    crapass.nmprimtl           ";"
                                    aux_cdorigem               ";" 
                                    crapris.nrctremp           ";"
                                    aux_cdlcremp               ";"
                                    STRING(aux_vldivida)       ";"   
                                    STRING(crapris.vljura60)   ";"
                                    STRING(w-crapris.vlpreemp) ";"
                                    w-crapris.nroprest         ";"       
                                    STRING(aux_vltotatr)       ";"    
                                    STRING(aux_vlpreatr)       ";"
                                    aux_percentu               ";"  
                                    crapass.cdagenci           ";"
                                    w-crapris.qtatraso         ";"
                                    aux_dsnivris               ";"
                                    aux_nivrisco               ";"
                                    aux_dtdrisco               ";"
                                    STRING(aux_qtdiaris)       ";"
                                    w-crapris.qtdiaatr         ";"
                                    aux_vlpreapg SKIP. 

              END.

       END.
    
    ASSIGN  tot_vlatraso = tot_vlatraso + aux_vltotatr.
    
    
    IF LAST-OF (crapass.cdagenci) THEN
       DO:
         IF LINE-COUNTER(str_1) > (PAGE-SIZE(str_1) - 4)   THEN
             DO:
                 PAGE STREAM str_1.

                 VIEW STREAM str_1 FRAME f_label.
                 
                 DISPLAY STREAM str_1 rel_dsagenci 
                                      WITH FRAME f_agencia.

             END.

          IF LINE-COUNTER(str_2) > (PAGE-SIZE(str_2) - 4)   THEN
             DO:
                 PAGE STREAM str_2.

                 VIEW STREAM str_2 FRAME f_label.
                 
                 DISPLAY STREAM str_2 rel_dsagenci 
                                      WITH FRAME f_agencia.

             END.
 
          ASSIGN tot_qttotal  = tot_qtctremp + tot_qtctrato
                 tot_vltotal  = tot_vlpreatr + tot_vldespes
                 tot_percentu = (tot_vlatraso / tot_vlsdeved) * 100.
                          
          DISPLAY STREAM str_1 tot_qtctremp  
                               tot_vlsdvatr  
                               tot_vlatraso  
                               tot_vlpreatr
                               tot_qtempres  
                               tot_vlsdeved  
                               tot_percentu 
                               WITH FRAME f_totais.
                      

          DISPLAY STREAM str_1 tot_qtctremp 
                               tot_vlpreatr
                               tot_qtctrato 
                               tot_vldespes
                               tot_qttotal  
                               tot_vltotal
                               aux_percbase 
                               WITH FRAME f_resumo.
          
          DO aux_contador = 1 TO 9:
            
             IF rel_dsdrisco[aux_contador] <> " " THEN
                DO: 
                    DISPLAY STREAM str_1 rel_dsdrisco[aux_contador]
                                         rel_percentu[aux_contador]
                                         aux_qtdabase[aux_contador] 
                                         aux_vldabase[aux_contador]
                                         aux_vljura60[aux_contador]
                                         aux_vlprovis[aux_contador] 
                                         WITH FRAME f_tabrisco_pac.
                   
                    DOWN STREAM str_1 WITH FRAME f_tabrisco_pac. 

                END.

          END.

          DISPLAY STREAM str_1 ger_qtdabase @ tot_qtdabase
                               ger_vldabase @ tot_vldabase
                               ger_vljura60 @ tot_vljura60
                               ger_vlprovis @ tot_vlprovis
                               WITH FRAME f_tottab.

          DISPLAY STREAM str_1 aux_qtdopera 
                               aux_vlropera 
                               aux_qtatrasa 
                               aux_vlatrasa 
                               aux_prcntatr
                               aux_atrsinad
                               WITH FRAME f_epr_finan.
                          
          DISPLAY STREAM str_2 tot_qtctremp  
                               tot_vlsdvatr  
                               tot_vlatraso  
                               tot_vlpreatr
                               tot_qtempres   
                               tot_vlsdeved  
                               tot_percentu
                               WITH FRAME f_totais. 
                      
          DISPLAY STREAM str_2 tot_qtctremp 
                               tot_vlpreatr
                               tot_qtctrato 
                               tot_vldespes
                               tot_qttotal  
                               tot_vltotal
                               aux_percbase 
                               WITH FRAME f_resumo.

           DISPLAY STREAM str_2 aux_qtdopera 
                                aux_vlropera 
                                aux_qtatrasa 
                                aux_vlatrasa 
                                aux_prcntatr
                                aux_atrsinad
                                WITH FRAME f_epr_finan.
                
          ASSIGN ger_qtctremp = ger_qtctremp + tot_qtctremp
                 ger_qtctrato = ger_qtctrato + tot_qtctrato
                 ger_vlpreatr = ger_vlpreatr + tot_vlpreatr
                 ger_vldespes = ger_vldespes + tot_vldespes

                 atr_qtctremp = atr_qtctremp + tot_qtctremp
                 atr_vlatraso = atr_vlatraso + tot_vlatraso
                 atr_qtempres = atr_qtempres + tot_qtempres
                 atr_vlsdeved = atr_vlsdeved + tot_vlsdeved
                 
                 atr_percentu = (atr_vlatraso / atr_vlsdeved) * 100
                  
                 tot_vljura60 = tot_vljura60 + ger_vljura60

                 tot_qtctremp = 0
                 tot_qtctrato = 0
                 tot_vlpreatr = 0
                 tot_vldespes = 0
                 tot_vlsdeved = 0
                 tot_qtempres = 0
            
                 tot_qtctremp = 0
                 tot_vlsdvatr = 0
                 tot_vlatraso = 0
                 tot_vlpreatr = 0
                 tot_qtempres = 0
                 tot_vlsdeved = 0
                 tot_percentu = 0
                            
                 aux_qtdabase = 0
                 aux_vldabase = 0
                 aux_vlprovis = 0
                 aux_vljura60 = 0

                 ger_qtdabase = 0
                 ger_vldabase = 0
                 ger_vlprovis = 0
                 ger_vljura60 = 0
                
                 aux_qtdopera = 0    
                 aux_vlropera = 0
                 aux_qtatrasa = 0
                 aux_vlatrasa = 0
                 aux_prcntatr = 0.
                  
          PAGE STREAM str_1.
          PAGE STREAm str_2.

       END.
 
END.  /*  Fim do DO WHILE TRUE - leitura do crapepr  */

DELETE OBJECT h-b1wgen0002.

IF VALID-HANDLE(h-b1wgen0168) THEN
   DELETE PROCEDURE(h-b1wgen0168).

ASSIGN tot_qtctremp = ger_qtctremp
       tot_qtctrato = ger_qtctrato
       tot_vlpreatr = ger_vlpreatr
       tot_vldespes = ger_vldespes
       tot_qttotal  = tot_qtctremp + tot_qtctrato
       tot_vltotal  = tot_vlpreatr + tot_vldespes.
       
DISPLAY STREAM str_1 tot_qtctremp 
                     tot_qtctrato 
                     tot_vlpreatr 
                     tot_vldespes 
                     tot_qttotal  
                     tot_vltotal 
                     aux_percbase 
                     WITH FRAME f_resumo.

DISPLAY STREAM str_1 atr_qtctremp  
                     atr_vlatraso  
                     atr_qtempres
                     atr_vlsdeved  
                     atr_percentu
                     WITH FRAME f_geral.
  
PAGE STREAM str_1.

DISPLAY STREAM str_2 tot_qtctremp 
                     tot_qtctrato 
                     tot_vlpreatr 
                     tot_vldespes 
                     tot_qttotal  
                     tot_vltotal 
                     aux_percbase 
                     WITH FRAME f_resumo.

DISPLAY STREAM str_2 atr_qtctremp  
                     atr_vlatraso  
                     atr_qtempres
                     atr_vlsdeved  
                     atr_percentu
                     WITH FRAME f_geral.
  
PAGE STREAM str_2.


DO aux_contador = 1 TO 20:

   IF rel_dsdrisco[aux_contador] <> " " THEN
      DO: 
          DISPLAY STREAM str_1 rel_dsdrisco[aux_contador] 
                               rel_percentu[aux_contador]  
                               rel_qtdabase[aux_contador] 
                               rel_vldabase[aux_contador]
                               rel_vljura60[aux_contador]    
                               rel_vlprovis[aux_contador] 
                               WITH FRAME f_tabrisco.

          DOWN STREAM str_1 WITH FRAME f_tabrisco.

          DISPLAY STREAM str_2 rel_dsdrisco[aux_contador] 
                               rel_percentu[aux_contador]  
                               rel_qtdabase[aux_contador] 
                               rel_vldabase[aux_contador]
                               rel_vljura60[aux_contador]
                               rel_vlprovis[aux_contador] 
                               WITH FRAME f_tabrisco.

          DOWN STREAM str_2 WITH FRAME f_tabrisco.
            
      END.

END.


DISPLAY STREAM str_1 tot_qtdabase
                     tot_vldabase 
                     tot_vljura60 
                     tot_vlprovis 
                     WITH FRAME f_tottab.

DOWN STREAM str_1 WITH FRAME f_tottab.

DISPLAY STREAM str_2 tot_qtdabase 
                     tot_vldabase
                     tot_vljura60
                     tot_vlprovis 
                     WITH FRAME f_tottab.

DOWN STREAM str_2 WITH FRAME f_tottab.


ASSIGN  tot_vldabase = aux_vlprejuz
        tot_vlprovis = 0.
        
DISPLAY STREAM str_1 "Prejuizo"   @ tot_qtdabase
                     aux_vlprejuz @ tot_vldabase
                     " "          @ tot_vlprovis 
                     WITH FRAME f_tottab.

DOWN STREAM str_1 WITH FRAME f_tottab.
 
DISPLAY STREAM  str_1 aux_rel1721
                      aux_rel1721_v
                      aux_rel1723
                      aux_rel1723_v
                      aux_rel1724_c
                      aux_rel1724_v_c
                      aux_rel1724_cr
                      aux_rel1724_v_cr
                      aux_rel1724_sr
                      aux_rel1724_v_sr
                      aux_rel1731_1
                      aux_rel1731_1_v
                      aux_rel1731_2
                      aux_rel1731_2_v
                      aux_rel1722_0101
                      aux_rel1722_0101_v
                      aux_rel1722_0299
                      aux_rel1722_0299_v
                      aux_rel1722_0201
                      aux_rel1722_0201_v
                      WITH FRAME f_contabiliza.

DOWN STREAM str_1 WITH FRAME f_contabiliza.
 
DISPLAY STREAM  str_1 aux_ttprovis
                      aux_ttdivida
                      WITH FRAME f_total_geral.

DOWN STREAM str_1 WITH FRAME f_total_geral.

DISPLAY STREAM str_1 tot_qtdopera 
                     tot_vlropera
                     tot_qtatrasa 
                     tot_vlatrasa
                     tot_prcntatr
                     aux_atrsinad
                     WITH FRAME f_epr_finan_geral.

DOWN STREAM str_1 WITH FRAME f_epr_finan_geral.
         
DISPLAY STREAM str_2 "Prejuizo"   @ tot_qtdabase
                     aux_vlprejuz @ tot_vldabase
                     " "          @ tot_vlprovis 
                     WITH FRAME f_tottab.

DOWN STREAM str_2 WITH FRAME f_tottab.
 
DISPLAY STREAM  str_2 aux_rel1721
                      aux_rel1721_v
                      aux_rel1723
                      aux_rel1723_v
                      aux_rel1724_c
                      aux_rel1724_v_c
                      aux_rel1724_cr
                      aux_rel1724_v_cr
                      aux_rel1724_sr
                      aux_rel1724_v_sr
                      aux_rel1731_1
                      aux_rel1731_1_v
                      aux_rel1731_2
                      aux_rel1731_2_v
                      aux_rel1722_0101
                      aux_rel1722_0101_v
                      aux_rel1722_0299
                      aux_rel1722_0299_v
                      aux_rel1722_0201
                      aux_rel1722_0201_v
                      WITH FRAME f_contabiliza.


DOWN STREAM str_2 WITH FRAME f_contabiliza.
 
DISPLAY STREAM  str_2 aux_ttprovis
                      aux_ttdivida
                      WITH FRAME f_total_geral.

DOWN STREAM str_2 WITH FRAME f_total_geral.

DISPLAY STREAM str_2 tot_qtdopera 
                     tot_vlropera
                     tot_qtatrasa 
                     tot_vlatrasa
                     tot_prcntatr
                     aux_atrsinad
                     WITH FRAME f_epr_finan_geral.

DOWN STREAM str_2 WITH FRAME f_epr_finan_geral.

OUTPUT STREAM str_1 CLOSE.
OUTPUT STREAM str_2 CLOSE.
OUTPUT STREAM str_4 CLOSE.
OUTPUT STREAM str_5 CLOSE.

/* Gera Arquivo PDF */
ASSIGN glb_nmarqimp = "rl/crrl581.lst"
       glb_nrcopias = 1
       glb_nmformul = "132col".
       
RUN fontes/imprim.p.
                    
ASSIGN glb_nmarqimp = "rl/crrl354.lst"  
       glb_nrcopias = 1
       glb_nmformul = "234dh".
                 
RUN fontes/imprim.p.                       

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
   
IF  glb_cdprogra <> "crps184" THEN
    DO: 
        IF  glb_cdcooper <> 1  AND
            glb_cdcooper <> 7  AND
            glb_cdcooper <> 11 THEN
            DO:
                UNIX SILENT VALUE("ux2dos arq/" + aux_nmarquiv     + 
                                  " > /micros/" + crapcop.dsdircop +
                                  "/corvu/Dados_p_Relatorios/"     + 
                                  aux_nmarquiv).
            END.
        
        /*Copia relatorio crrl354.lst da viacredi para diretorio micros/viacredi/Tiago*/
        IF glb_cdcooper = 1 THEN
           DO:
                UNIX SILENT VALUE("cp " + glb_nmarqimp + " /micros/viacredi/Tiago").
                
                UNIX SILENT VALUE("ux2dos arq/" + aux_nmarquiv + 
                                  " > /micros/viacredi/Tiago/" + aux_nmarquiv). 
           END.    
        
           /** CredCrea **/               
        IF glb_cdcooper = 7 THEN
           UNIX SILENT VALUE("ux2dos arq/" + aux_nmarquiv + 
                             " > /micros/credcrea/" + aux_nmarquiv). 
        
           /** Credifoz **/               
        IF glb_cdcooper = 11 THEN
           UNIX SILENT VALUE("ux2dos arq/" + aux_nmarquiv + 
                             " > /micros/credifoz/" + aux_nmarquiv). 
                                                                  
    END.
/*---- Programa crps400 efetua copia --- disponibilizar apenas mensal
IF   glb_cdprogra <> "crps184"  THEN
     UNIX SILENT VALUE("ux2dos " + glb_nmarqimp + 
                       " > /micros/cecred/auditoria/" + crapcop.dsdircop + 
                       "/" + SUBSTR(glb_nmarqimp,3)).
*/

ASSIGN glb_nrcopias = 3
       glb_nmformul = "234dh"  
       glb_nmarqimp = "rl/crrl227.lst".
               
RUN fontes/imprim.p.  
                              
/* So este programa gera este relatorio */
IF glb_cdprogra = "crps280"   THEN
   OUTPUT STREAM str_3 CLOSE.  


ASSIGN glb_nrcopias = 1
       glb_nmformul = "132col"
       glb_nmarqimp = "rl/crrl552.lst".
            
RUN fontes/imprim.p.
              
IF (glb_cdcooper = 1           OR
    glb_cdcooper = 2)          AND
    glb_cdprogra <> "crps184"  THEN 
    UNIX SILENT VALUE("mv arq/" + aux_nmarquiv + " salvar").  
             
IF glb_cdcooper = 1   OR
   glb_cdcooper = 2   THEN
   DO: 
       /* Move para diretorio converte para utilizar na BO */
       UNIX SILENT VALUE("cp " + glb_nmarqimp + " /usr/coop/" +
                         crapcop.dsdircop + "/converte"       +
                          " 2> /dev/null").
          
       /* envio de email */ 
       RUN sistema/generico/procedures/b1wgen0011.p
           PERSISTENT SET b1wgen0011.
       
       IF glb_cdcooper = 1   THEN
          DO: 
              RUN enviar_email IN b1wgen0011
                                 (INPUT glb_cdcooper,
                                  INPUT glb_cdprogra,
                                  INPUT "daniela@viacredi.coop.br,"   +
                                        "convenios@viacredi.coop.br," +
                                        "controle@viacredi.coop.br," + 
                                        "cdc@viacredi.coop.br",
                                  INPUT '"Provisao para creditos de " +
                                         "liquidacao duvidosa" ',
                                  INPUT SUBSTRING(glb_nmarqimp, 4),
                                  INPUT FALSE).                                                   
          END.
       ELSE
          RUN enviar_email IN b1wgen0011
                             (INPUT glb_cdcooper,
                              INPUT glb_cdprogra,
                              INPUT "creditextil@creditextil.coop.br",
                              INPUT '"Provisao para creditos de " +
                                     "liquidacao duvidosa" ',
                              INPUT SUBSTRING(glb_nmarqimp, 4),
                              INPUT FALSE).

       DELETE PROCEDURE b1wgen0011. 
         
   END. 
               
/* ............................... PROCEDURES ............................... */
PROCEDURE risco_h:

    DEF INPUT  PARAM par_cdcooper AS INT  NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INT  NO-UNDO.
    DEF INPUT  PARAM par_dtrefere AS DATE NO-UNDO.
    DEF INPUT  PARAM par_qtatraso AS INT  NO-UNDO.

    DEF VAR          aux_dtfimmes AS DATE NO-UNDO.
    DEF VAR          aux_contdata AS INT  NO-UNDO.
    DEF VAR          aux_flgrisco AS LOGI NO-UNDO.


    ASSIGN aux_dtfimmes = par_dtrefere - DAY(par_dtrefere)
           aux_contdata = 1
           aux_flgrisco = TRUE
           aux_dsorigem = "".
           
    IF crapris.cdorigem = 3 THEN
       ASSIGN aux_ddatraso = par_qtatraso * 30.
    ELSE
       ASSIGN aux_ddatraso = par_qtatraso.

    REPEAT WHILE aux_contdata <= 6:

        FIND LAST crabris WHERE crabris.cdcooper = par_cdcooper     AND
                                crabris.nrdconta = par_nrdconta     AND
                                crabris.innivris = 9                AND
                                crabris.dtrefere = aux_dtfimmes     AND
                                crabris.inddocto = 1   /* Docto 3020 */
                                NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crabris THEN
            DO:
                ASSIGN aux_flgrisco = FALSE.
                LEAVE.
            END.

        ASSIGN aux_dtfimmes = aux_dtfimmes - DAY(aux_dtfimmes)
               aux_contdata = aux_contdata + 1.

    END. /* Fim repeat */

    IF aux_flgrisco THEN
       DO:
          IF crapris.cdorigem = 1 THEN
             ASSIGN aux_dsorigem = "C".
          ELSE
             IF (crapris.cdorigem = 2 OR 
                 crapris.cdorigem = 4 OR 
                 crapris.cdorigem = 5) THEN
                 ASSIGN aux_dsorigem = "D".
             ELSE
               ASSIGN aux_dsorigem = "E".
        
          IF LINE-COUNTER(str_5) = 1 THEN
             DO:
                VIEW STREAM str_5 FRAME f_cab_risco_h.

             END.

          DISP STREAM str_5 crapris.nrdconta
                            crapass.nmprimtl
                            crapass.cdagenci
                            aux_dsorigem
                            crapris.nrctremp
                            crapris.cdmodali
                            crapris.vldivida
                            aux_ddatraso
                            WITH FRAME f_risco_h.

           DOWN STREAM str_5 WITH FRAME f_risco_h.
           
           IF LINE-COUNTER(str_5) > PAGE-SIZE(str_5) THEN
              DO:
                 VIEW STREAM str_5 FRAME f_cab_risco_h.

              END. 
       END.

END PROCEDURE.

PROCEDURE verifica_conta_migracao_280:

    DEF INPUT PARAM  par_cdcooper   LIKE    crapass.cdcooper        NO-UNDO.
    DEF INPUT PARAM  par_nrdconta   LIKE    crapass.nrdconta        NO-UNDO.
    DEF INPUT PARAM  par_dtrefere   AS      DATE                    NO-UNDO.
    DEF INPUT PARAM  par_dtmvtolt   AS      DATE                    NO-UNDO.

    /*Migracao Concredi -> Viacredi*/ 
    IF  par_cdcooper  = 1          AND 
        par_dtrefere <= 11/30/2014 THEN
        DO: 
            FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
                               craptco.cdcopant = 4            AND
                               craptco.nrdconta = par_nrdconta AND
                               craptco.tpctatrf <> 3
                               NO-LOCK NO-ERROR.

            IF  AVAIL craptco THEN 
                RETURN "NOK".
        END.

    /*Migracao Credimilsul -> Scrcred */ 
    IF  par_cdcooper  = 13         AND 
        par_dtrefere <= 11/30/2014 THEN
        DO: 
            FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
                               craptco.cdcopant = 15           AND
                               craptco.nrdconta = par_nrdconta AND
                               craptco.tpctatrf <> 3
                               NO-LOCK NO-ERROR.

            IF  AVAIL craptco THEN
                RETURN "NOK".
        END.
   
    /*Migracao Viacredi -> Altovale*/
    IF  par_cdcooper  = 16         AND
        par_dtrefere <= 12/31/2012 THEN
        DO: 
    
            FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
                               craptco.cdcopant = 1            AND
                               craptco.nrdconta = par_nrdconta AND 
                               craptco.tpctatrf <> 3           
                               NO-LOCK NO-ERROR.

            IF  AVAIL craptco THEN        
                RETURN "NOK".
            
        END.

    /*Migracao Acredicop -> Viacredi*/
    IF  par_cdcooper  = 1          AND
        par_dtrefere <= 12/31/2013 THEN
        DO: 

            FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
                               craptco.cdcopant = 2            AND
                               craptco.nrdconta = par_nrdconta AND 
                               craptco.tpctatrf <> 3           AND
                              (craptco.cdageant = 2            OR
                               craptco.cdageant = 4            OR
                               craptco.cdageant = 6            OR
                               craptco.cdageant = 7            OR
                               craptco.cdageant = 11)
                               NO-LOCK NO-ERROR.

            IF  AVAIL craptco THEN        
                RETURN "NOK".

        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE obtem-parametros-tabs-emprestimo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_indpagto AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_diapagto AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dtcalcul AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_flgfolha AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_inusatab AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    RUN obtem-parametros-tabs IN h-b1wgen0002 (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT 0,
                                               INPUT par_nrdconta,
                                               INPUT par_dtmvtolt,
                                               OUTPUT par_indpagto,
                                               OUTPUT par_diapagto,
                                               OUTPUT par_dtcalcul,
                                               OUTPUT par_flgfolha,
                                               OUTPUT par_inusatab,
                                               OUTPUT TABLE tt-erro).

    RETURN "OK".

END PROCEDURE. /* obtem-parametros-tabs-emprestimo */
/*............................................................................*/
