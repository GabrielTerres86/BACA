/* .............................................................................

   Programa: Fontes/cobran.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/97                       Ultima atualizacao: 04/02/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela COBRAN.

   Alteracoes: 30/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner)
        
               26/02/2004 - Alterado p/contemplar Lancamento BBrasil(Mirtes)
               
               24/09/2004 - Incluir mais duas posicoes do Nro Convenio (Ze)
               
               21/03/2005 - Aumentado o nro do documento para 17 posicoes;
                            Incluida opcao "I";
                            Gerar rel 390 - Integrados e rel 415 - Rejeitados;
                            (Evandro).
                            
               05/04/2005 - Feitos ajustes para opcao "I" (Evandro).

               27/06/2005 - Alimentado campo cdcooper da tabela crapcob        
                            (Diego).
                             
               19/08/2005 - Alterado layout FICHA CADASTRAL pessoa fisica
                            (Diego).    
                            
               16/09/2005 - Reestruturacao de toda a tela e impressao dos
                            bloquetos nao pagos (Ze Eduardo).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               30/11/2005 - Aumentar o numero do documento para 9 dig. (Ze).

               28/01/2006 - Substituicao da pesquisa no craptab pelo crapcco.
                            (Julio/Ze).
                            
               06/04/2006 - Implementacao da B.O. de Cobranca (Ze).
               
               02/06/2006 - Acerto na Importacao do Arquivo (Ze).
               
               08/04/2006 - Ajustes no layout para leitura do arquivo (Julio)
               
               04/10/2006 - Incluir BO de Inclusao dos Bloquetos (Ze).

               16/10/2006 - Gravar os campos nmdavali e nrdoccop, alteradas as
                            opcoes de busca conforme BO b1wgen0010 (David).
                            
               20/10/2006 - Incluir campo nmprimtl na temp-table tt-consulta-blt
                            (David).
                            
               09/11/2006 - Tratamento para campo CHAR - Importacao Boleto (Ze).

               22/12/2006 - Alterado os helps dos campos da tela (Elton).
               
               27/12/2006 - Tratamento dos dados do sacado e alimentar campos 
                            dsdinstr, cdimpcob, flgimpre e vldescto (David).

               13/03/2007 - Incluir parametro na BO b1wgen0010 para receber
                            nome de sacados (David).

               20/04/2007 - Incluir campo "Complemento" na temp-table (David).
               
               28/09/2007 - Incluida leitura na tabela crapass antes da 
                            includes/impressao.i, somente p/ nao gerar na
                            rotina (Diego).

               13/05/2008 - Alterar nrdoccop para dsdoccop (David).

               25/07/2008 - Mostrar situacao do boleto (David).
               
               06/08/2008 - Efetuado acerto para nao criar registro "crapcob"
                            quando o registro for rejeitado (Diego).

               20/08/2008 - Incluida remocao de arquivo do diretorio "integra"
                            (Diego).
                            
               12/09/2008 - Alterado campo cratcob.cdbccxlt -> cratcob.cdbandoc
                            (Diego).
                            
               17/02/2009 - Alteracoes para atender ao Projeto de Melhorias de
                            Cobranca (Ze).

                          - Criada opcao "R" para geracao de relatorios 
                            (Gabriel).

               16/07/2009 - Mostrar campo "dsdoccop" no lugar de "nrdocmto" no
                            relatorio francesa (David).

               13/01/2010 - Limpar TEMP-TABLE crawrej (David).
               
               14/10/2010 - Atualizacoes devido ao crps375.p (Ze).
               
               30/11/2010 - Alteracao de Format (Kbase/Willian).
                            001 - Alterado para 50 posições, valor anterior 40.

               08/02/2011 - Permitir selecionar e importacao de mais de um
                            arquivo, opc "I" (Guilherme/Supero)
                            
               17/02/2011 - Critica para verificar cadastro na crapceb
                            (Gabriel)

               18/03/2011 - Validacoes para Cobranca Registrada
                            (Guilherme/Supero)
                            
               26/05/2011 - Cob. Regis. Novos relatorios (Guilherme/Supero)
               
               30/05/2011 - Alteração layout da opcao cob. reg. (Guilherme).
               
               15/06/2011 - Alteracao de label na proc_crrl602. 
                            De: Tit(titulo) Para: Bol(boleto). (Fabricio)
                            
               16/06/2011 - FIND FIRST na crapass para os tipos de relatorios
                            2 e 6, caso nao seja informado o numero da conta;
                            isto, para nao gerar erro na rotina de impressao
                            dos mesmos(includes/impressao.i). Feito tambem para
                            o tipo de relatorio 7, pois este, nao utiliza o
                            numero da conta. (Fabricio)
                            
               21/06/2011 - Retirado, temporariamente, o relatorio 7
                          - DELETE PROCEDURE h-b1wgen0088 na 
                            pi_tela_exclusoes quando haver critica (Guilherme).
                            
               07/06/2011 - Alterado layout de impressao dos relatorios 5,6, 
                            de retrato para paisagem. No relatorio 6, sera
                            listado nome do sacado ao inves do cpf/cnpj
                            (Adriano).             
                            
               13/07/2011 - Incluido a coluna "Retorno". Ja para a coluna
                            "Motivos", sera mostrado o codigo e descricao do
                            motivo (Adriano).
                                          
               20/07/2011 - Retirado busca da descricao do motivo da procedure
                            proc_crrl601, passado para BO10.(Jorge)
                            
               22/07/2011 - Realizado alteracoes no layout do rel601
                            (Adriano).
              
               22/08/2011 - Padronizado descricao N Documetno e Nosso Numero nos
                            relatorios 600, 601. Ajustado status na tela incial
                            para ter a mesma regra de status conforme no log 
                            do boleto (Adriano).
                            
               28/09/2011 - Removido temp-table crawrej e movido para a include
                            (Rafael).
                            
               25/10/2011 - Incluido campos de juros/multa e descto (Fabricio).
                          - Retirado ordenacao por rowid no log do titulo
                            (Rafael).
                            
               14/11/2011 - Alterado ordenacao do log do titulo (Rafael).
               
               06/12/2011 - Criada a procedure 'exporta_consulta' para gerar
                            arquivo com dados da consulta efetuada (Lucas).
                            
                            
               26/01/2012 - Adaptado para o uso de BO. ( Gabriel - DB1 ).
               
               13/08/2012 - Ajuste no display - cob. registrada de titulos
                            descontados. (Rafael)
                            
               03/05/2013 - Adicionado Instrucoes 7 e 8 referentes a
                            "Concessao de Desconto", "Cancelamento de Desconto"
                            (Jorge)
              
               10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
              
               24/04/2014 - Para as opções C (Consulta) e R (Relatorio), 
                            foi setado o default de cobrança registrada como SIM
                            (Jaison).
                            
               03/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
            
               01/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).    
                            
               28/04/2015 - Ajustes referente ao projeto DP 219 - Cooperativa
                            emite e expede. (Reinert)

               02/06/2015 - Ajute no form f_det_cobranca para alterar o label
                            "Emissao" para "Data Dcto"
                            (Adriano).
                            
               17/11/2015 - Adicionado param de entrada inestcri em chamada de 
                            proc. consulta-bloqueto. (Jorge/Andrino) 

               04/02/2016 - Ajuste referente Projeto Negaticação Serasa (Daniel)
    
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0010tt.i }

DEF VAR h-b1wgen0010 AS HANDLE                                   NO-UNDO.
DEF VAR h-b1wgen0088 AS HANDLE                                   NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarqim2 AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarqpd2 AS CHAR                                     NO-UNDO.
DEF VAR aux_qtregist AS INTE                                     NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                     NO-UNDO.

DEF VAR tel_nrinssac AS CHAR FORMAT "x(18)"                      NO-UNDO.
DEF VAR tel_tpconsul AS INTE FORMAT "zz9"                        NO-UNDO.
DEF VAR tel_consulta AS INTE FORMAT "zz9"                        NO-UNDO.
DEF VAR tel_nrdconta AS INTE FORMAT "zzzz,zzz,9"                 NO-UNDO.
DEF VAR tel_nrdcont2 AS INTE FORMAT "zzzz,zzz,9"                 NO-UNDO.
DEF VAR tel_nmprimtl AS CHAR FORMAT "x(50)"                      NO-UNDO. /*001*/
DEF VAR tel_nrdctabb AS INTE FORMAT "zzzz,zz9,9"                 NO-UNDO.
DEF VAR tel_nrcnvcob AS INTE FORMAT "zzzzzzz9"                   NO-UNDO.
DEF VAR tel_dtretira AS DATE FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR tel_vllanmto AS DECI FORMAT "zzz,zzz,zz9.99"             NO-UNDO.
DEF VAR tel_vltarifa AS DECI FORMAT "z,zz9.99"                   NO-UNDO.
DEF VAR tel_cdpesqui AS CHAR FORMAT "x(26)"                      NO-UNDO.
DEF VAR tel_cdbancob AS INTE FORMAT "999"                        NO-UNDO.
DEF VAR tel_cddopcao AS CHAR FORMAT "!(1)"                       NO-UNDO.
DEF VAR tel_flgregis AS LOGI FORMAT "Sim/Nao" INIT TRUE          NO-UNDO.
DEF VAR tel_vldesabt AS DECI FORMAT "zzz,zz9.99"                 NO-UNDO.
DEF VAR tel_vljurmul AS DECI FORMAT "zzz,zz9.99"                 NO-UNDO.
DEF VAR tel_vlabatim AS DECI FORMAT "zzz,zz9.99"                 NO-UNDO.
DEF VAR tel_vldescto AS DECI FORMAT "zzz,zz9.99"                 NO-UNDO.
DEF VAR tel_dtvencto AS DATE FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR tel_vrsarqvs AS LOGI FORMAT "S/N"                        NO-UNDO.

DEF VAR aux_nmendter AS CHAR FORMAT "x(20)"                      NO-UNDO.
DEF VAR aux_dsnmarqv AS CHAR                                     NO-UNDO.

DEF VAR tel_cdagenci AS INTE FORMAT "zz9"                        NO-UNDO.
DEF VAR tel_tprelato AS INTE FORMAT "9"                          NO-UNDO.
DEF VAR tel_dsrelato AS CHAR                                     NO-UNDO.
DEF VAR tel_tpinstru AS INTE FORMAT "z9"                         NO-UNDO.
DEF VAR aux_dsinstru AS CHAR                                     NO-UNDO.
DEF VAR aux_cdinstru AS INTE                                     NO-UNDO.
DEF VAR aux_lginstru AS LOG                                      NO-UNDO.
DEF VAR tel_tpexcins AS INTE FORMAT "z9"                         NO-UNDO.
DEF VAR aux_dsexcins AS CHAR                                     NO-UNDO.
DEF VAR aux_cdexcins AS INTE                                     NO-UNDO.
DEF VAR tel_cdstatus AS INTE FORMAT "9"                          NO-UNDO.
DEF VAR tel_dsstatus AS CHAR                                     NO-UNDO.
DEF VAR aux_cdstatus AS CHAR                                     NO-UNDO.

DEF VAR tel_lsrelato AS CHAR VIEW-AS SELECTION-LIST INNER-LINES 4
                                     INNER-CHARS 65              NO-UNDO.

DEF VAR tel_lsstatus AS CHAR VIEW-AS SELECTION-LIST INNER-LINES 6
                                     INNER-CHARS 30 LIST-ITEMS
   "1 - Em Aberto",
   "2 - Baixado",
   "3 - Liquidado",
   "4 - Rejeitado",
   "5 - Cartoraria"
    NO-UNDO.

DEF VAR tel_lsinstru AS CHAR VIEW-AS SELECTION-LIST INNER-LINES 4
                 SCROLLBAR-VERTICAL  INNER-CHARS 45              NO-UNDO.
DEF VAR tel_cdinstru AS INTE FORMAT "z9"                         NO-UNDO.

DEF VAR tel_lsexcins AS CHAR VIEW-AS SELECTION-LIST INNER-LINES 4
                 SCROLLBAR-VERTICAL  INNER-CHARS 55              NO-UNDO.
DEF VAR tel_cdexcins AS INTE FORMAT "z9"                         NO-UNDO.

DEF VAR aux_dsperiod AS CHAR                                     NO-UNDO.
DEF VAR aux_dsmsgerr AS CHAR                                     NO-UNDO.

DEF VAR ini_nrdocmto AS DECI FORMAT "9999999999"                 NO-UNDO.
DEF VAR fim_nrdocmto AS DECI FORMAT "9999999999"                 NO-UNDO.
DEF VAR ini_dtvencto AS DATE FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR fim_dtvencto AS DATE FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR ini_dtdpagto AS DATE FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR fim_dtdpagto AS DATE FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR ini_dtmvtolt AS DATE FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR fim_dtmvtolt AS DATE FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR ini_dtperiod AS DATE FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR fim_dtperiod AS DATE FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR ini_dsdoccop AS CHAR FORMAT "x(12)"                      NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                     NO-UNDO.
DEF VAR aux_contador AS INTE                                     NO-UNDO.
DEF VAR tel_nmarqint AS CHAR FORMAT "x(60)"                      NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                     NO-UNDO.

/* Variaveis para a includes de impressao */
DEF VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"       NO-UNDO.
DEF VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"       NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                     NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                     NO-UNDO.
DEF VAR par_flgrodar AS LOGI                                     NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                     NO-UNDO.
DEF VAR par_flgcance AS LOGI                                     NO-UNDO.

DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                       NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  8 LABEL "Opcao"
       HELP "Informe a opcao desejada (C ,I ou R)."
       VALIDATE (CAN-DO("C,I,R",glb_cddopcao),"014 - Opcao errada.")

     tel_tpconsul AT 24 LABEL "Consulta"  AUTO-RETURN
       HELP "1-Boletos Nao Cobrados, 2-Boletos Cobrados, 3-Todos Boletos."
       VALIDATE((INPUT tel_tpconsul > 0 AND INPUT tel_tpconsul < 4),
                "329 - Tipo de consulta errado.")
     tel_flgregis AT 42 LABEL "Cob.Registrada"  AUTO-RETURN
       HELP "Cobranca Registrada ? (S)im / (N)ao"
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_cobran.

FORM tel_consulta LABEL "Tipo" AUTO-RETURN
       HELP "1 - Nro.Conta, 2 - Nro.Boleto, 8 - Conta/Nr Doc."
       VALIDATE(CAN-DO("1,2,8",STRING(tel_consulta)),
                "329 - Tipo de consulta errado.")
     WITH ROW 6 COLUMN 65 OVERLAY NO-BOX SIDE-LABELS FRAME f_consul01.

FORM tel_consulta LABEL "Tipo" AUTO-RETURN
       HELP "1-Nro.Conta, 2-Nro.Boleto, 4-Data de Pagamento, 8-Cta/Doc."
       VALIDATE(CAN-DO("1,2,4,8",STRING(tel_consulta)),
                "329 - Tipo de consulta errado.")
     WITH ROW 6 COLUMN 65 OVERLAY NO-BOX SIDE-LABELS FRAME f_consul02.

FORM tel_consulta LABEL "Tipo" AUTO-RETURN
       HELP "1-Cta 2-Boleto 3-Emissao 4-Pagto 5-Vencto 6-Pagador 8-Cta/Doc"
       VALIDATE(CAN-DO("1,2,3,4,5,6,8",STRING(tel_consulta)),
                "329 - Tipo de consulta errado.")
     WITH ROW 6 COLUMN 65 OVERLAY NO-BOX SIDE-LABELS FRAME f_consul03.
  
FORM tel_nrdconta AT 2 LABEL "Conta" 
       HELP "Informe o numero da conta ou  <F7> para pesquisar."
     tel_nmprimtl AT 19 FORMAT "x(50)" NO-LABEL /*001*/
     WITH ROW 7 COLUMN 8 NO-BOX SIDE-LABELS OVERLAY FRAME f_conta.

FORM ini_nrdocmto AT 2 LABEL "Boleto"
       HELP "Informe o numero do boleto."
       VALIDATE(ini_nrdocmto > 0,"022 - Numero do documento errado.")
     WITH ROW 7 COLUMN 7 NO-BOX SIDE-LABELS OVERLAY FRAME f_bloqueto.

FORM SKIP(1)
     tel_flgregis AT 02 LABEL "Cob.Regis." AUTO-RETURN
       HELP "Relatorios de Cobranca Registrada ? (S/N)"
     SKIP(1)
     tel_tprelato AT 03 LABEL "Relatorio"
                  HELP  "Informe o tipo de relatorio ou pressione <F7>."
                  VALIDATE ((tel_flgregis = FALSE
                             AND tel_tprelato > 0 AND tel_tprelato < 5) OR
                            (tel_flgregis = TRUE
                             /*temporariamente 21/06/2011
                             AND tel_tprelato > 4 AND tel_tprelato < 8),
                             ********************/
                             AND tel_tprelato > 4 AND tel_tprelato < 7),
                            "Tipo de relatorio invalido.")
     tel_dsrelato AT 16 FORMAT "x(61)"
     SKIP(1)
     aux_dsperiod AT 02 FORMAT "x(12)"
     ini_dtperiod AT 14 HELP "Informe a data inicial de consulta."
                              VALIDATE(ini_dtperiod <> ?,"013 - Data errada.")

     fim_dtperiod  LABEL "ate" AT 25 HELP "Informe a data final de consulta."
                             VALIDATE(fim_dtperiod >= INPUT ini_dtperiod  AND
                                      fim_dtperiod <> ?,
                                      "Data inicial maior que a data final.")
     SKIP(1)
     tel_cdstatus AT 06 LABEL "Status"
                  HELP  "Informe o tipo de Status ou pressione <F7>."
                  VALIDATE (tel_cdstatus > 0 AND tel_cdstatus < 7,
                            "Tipo de Status invalido.")
     tel_dsstatus AT 15 FORMAT "x(30)"
     SKIP(1)
     tel_nrdcont2 LABEL "Conta/dv" AT 04
       HELP "Informe a conta, <F7> p/ pesquisar ou 0 <ZERO> para o PA."
     tel_nmprimtl AT 25 FORMAT "x(50)" /*001*/
     SKIP(1)
     tel_cdagenci LABEL "PA" AT 10  HELP "Informe o PA desejado."
     WITH ROW 7 COLUMN 3 WIDTH 76 OVERLAY NO-BOX NO-LABELS SIDE-LABELS
     FRAME f_relatorio.
     
FORM tel_lsrelato NO-LABEL 
          HELP "Informe o tipo de relatorio ou pressione <END> p/ voltar."
     WITH WIDTH 69 ROW 11 COLUMN 5 OVERLAY NO-BOX FRAME f_tprelato.

FORM tel_lsstatus NO-LABEL 
          HELP "Informe o tipo de Status ou pressione <END> p/ voltar."
     WITH WIDTH 35 ROW 12 COLUMN 20 OVERLAY NO-BOX FRAME f_tpstatus.

FORM "Boleto:"    AT 2    
     ini_nrdocmto NO-LABEL HELP "Informe o numero inicial do Boleto."
                           VALIDATE(ini_nrdocmto > 0,
                                    "022 - Numero do boleto errado.")
     "ate"
     fim_nrdocmto NO-LABEL HELP "Informe o numero final do Boleto."
                           VALIDATE(fim_nrdocmto >= INPUT ini_nrdocmto   AND
                                    fim_nrdocmto > 0,
                                    "Boleto inicial maior que Boleto final.")
     WITH ROW 7 COLUMN 7 NO-BOX SIDE-LABELS OVERLAY FRAME f_documento.

FORM "Pagamento:" AT 2
     ini_dtdpagto NO-LABEL  HELP "Informe a data de pagamento inicial."
                            VALIDATE(ini_dtdpagto <> ?,"013 - Data errada.")
     "ate"
     fim_dtdpagto NO-LABEL  HELP "Informe a data de pagamento final."
                            VALIDATE(fim_dtdpagto >= INPUT ini_dtdpagto AND   
                                     fim_dtdpagto <> ?,
                                     "Data inicial maior que data final.")
     WITH ROW 7 COLUMN 4 NO-BOX SIDE-LABELS OVERLAY FRAME f_pagamento.
     
FORM "Emissao:"   AT 2    
     ini_dtmvtolt NO-LABEL  HELP "Informe a data de emissao inicial."
                            VALIDATE(ini_dtmvtolt <> ?,"013 - Data errada.")
     "ate"
     fim_dtmvtolt NO-LABEL  HELP "Informe a data de emissao final."
                           VALIDATE(fim_dtmvtolt >= INPUT ini_dtmvtolt AND
                                     fim_dtmvtolt <> ?,
                                     "Data inicial maior que data a final.")
     WITH ROW 7 COLUMN 6 NO-BOX SIDE-LABELS OVERLAY FRAME f_emissao.

FORM "Pagador:"   AT 3
     tel_nmprimtl AT 12 FORMAT "x(50)" NO-LABEL /*001*/
                  HELP "Informe o nome do Associado."
                  VALIDATE(tel_nmprimtl <> "","375 - O campo deve ser preenchido.")
     WITH ROW 7 COLUMN 6 NO-BOX SIDE-LABELS OVERLAY FRAME f_sacado.

FORM "Vencimento:" AT 2    
     ini_dtvencto  NO-LABEL HELP "Informe a data de vencimento inicial."
                            VALIDATE(ini_dtvencto <> ?,"013 - Data errada.")
     "ate"
     fim_dtvencto  NO-LABEL HELP "Informe a data de vencimento final."
                            VALIDATE(fim_dtvencto >= INPUT ini_dtvencto   AND
                                     fim_dtvencto <> ?,
                                     "Data inicial maior que a data final.")
     WITH ROW 7 COLUMN 3 NO-BOX SIDE-LABELS OVERLAY FRAME f_vencimento.
 
FORM "Nr Doc:"    AT 3    
     ini_dsdoccop NO-LABEL HELP "Informe o Nr do Docto do Cooperado."
                           VALIDATE(ini_dsdoccop <> "",
                                    "022 - Numero do Documento errado.")
     WITH ROW 8 COLUMN 6 NO-BOX SIDE-LABELS OVERLAY FRAME f_conta_docto.


FORM SKIP
     "Status       :"              
     tt-consulta-blt.dssituac  AT 16 FORMAT "x(22)"              NO-LABEL
     "Valor Boleto :"          AT 46                          
     tt-consulta-blt.vltitulo  AT 61 FORMAT "z,zzz,zzz,zz9.99"   NO-LABEL  
     SKIP
     "Pagador      :"
     tt-consulta-blt.nmdsacad  AT 16 FORMAT "x(29)"              NO-LABEL 
     "CPF/CNPJ     :"          AT 46 
     tt-consulta-blt.dsinssac  AT 61 FORMAT "x(18)"              NO-LABEL  
     SKIP
     "Dt.Pagamento :"
     tt-consulta-blt.dtdpagto  AT 16 FORMAT "99/99/9999"         NO-LABEL
     "Ds.Pagamento :"          AT 46                            
     tt-consulta-blt.dsdpagto  AT 61 FORMAT "x(11)"              NO-LABEL
     SKIP
     "Dt.Vencimento:"          
     tt-consulta-blt.dtvencto  AT 16 FORMAT "99/99/9999"         NO-LABEL 
     "Doc.Cooperado:"          AT 46                        
     tt-consulta-blt.dsdoccop  AT 61 FORMAT "x(15)"              NO-LABEL
     SKIP
     "Orig. Arquivo:"
     tt-consulta-blt.dsorgarq  AT 16 FORMAT "x(30)"              NO-LABEL 
     "Conta Base   :"          AT 46                        
     tt-consulta-blt.nrdctabb  AT 61 FORMAT "zzzz,zzz,9"         NO-LABEL 
     WITH ROW 16 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_detalhes.
    
    
FORM SKIP
     "Status       :"
     tt-consulta-blt.dssituac  AT 16 FORMAT "x(20)"              NO-LABEL
     tt-consulta-blt.dtsitcrt  AT 37 FORMAT "99/99/99"           NO-LABEL
     "Valor Boleto :"          AT 46
     tt-consulta-blt.vltitulo  AT 61 FORMAT "z,zzz,zzz,zz9.99"   NO-LABEL
     SKIP
     "Convenio     :"
     tt-consulta-blt.nrcnvcob  AT 16 FORMAT "zz,zzz,zz9"         NO-LABEL
     "Bco/Agencia  :"          AT 46
     tt-consulta-blt.cdbanpag  AT 61 FORMAT "999"                NO-LABEL
     "/"                       AT 64
     tt-consulta-blt.cdagepag  AT 66 FORMAT "9999"               NO-LABEL
     SKIP
     "Pagador      :"
     tt-consulta-blt.nmdsacad  AT 16 FORMAT "x(25)"              NO-LABEL
     "Ds.Pagamento :"          AT 46
     tt-consulta-blt.dsdpagto  AT 61 FORMAT "x(11)"              NO-LABEL
     SKIP
     "Conta/DV     :"
     tt-consulta-blt.nrdconta  AT 16 FORMAT "zzzz,zzz,9"         NO-LABEL
     "-"                       AT 27
     tt-consulta-blt.nmprimtl  AT 29 FORMAT "x(15)"              NO-LABEL
     "Nosso Num    :"          AT 46
     tt-consulta-blt.nrnosnum  AT 61 FORMAT "x(17)"              NO-LABEL /****REVER ***/
     SKIP
     "Orig. Arquivo:"
     tt-consulta-blt.dsorgarq  AT 16 FORMAT "x(30)"              NO-LABEL
     "Conta Base   :"          AT 46
     tt-consulta-blt.nrdctabb  AT 61 FORMAT "zzzz,zzz,9"         NO-LABEL
     WITH ROW 16 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_det_cob_reg.

FORM "Aguarde... Imprimindo relatorio de boletos integrados!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM "Aguarde... Imprimindo relatorio de rejeitados na integracao!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_rej.

DEF QUERY q-valor  FOR tt-consulta-blt.
DEF QUERY q-cobreg FOR tt-consulta-blt.

DEF BROWSE b-valor QUERY q-valor
    DISP tt-consulta-blt.nrdconta FORMAT "zzzz,zzz,9"     LABEL "Conta/DV"
         tt-consulta-blt.idseqttl FORMAT "zz9"            LABEL "Tit."
         tt-consulta-blt.dtmvtolt FORMAT "99/99/9999"     LABEL "Emissao"
         tt-consulta-blt.dtretcob FORMAT "99/99/9999"     LABEL "Retirada"
         tt-consulta-blt.nrcnvcob FORMAT "zz,zzz,zz9"     LABEL "Convenio"
         tt-consulta-blt.nrdocmto FORMAT "999999999"      LABEL "Boleto"
         tt-consulta-blt.vldpagto FORMAT "zzz,zzz,zz9.99" LABEL "Valor Pago"
         WITH 4 DOWN WIDTH 78 NO-LABELS OVERLAY.

FORM b-valor
       HELP "Use: SETAS para navegar <F4> para sair <E> Exp. Cons."
     WITH ROW 8 NO-LABELS NO-BOX CENTERED OVERLAY FRAME f_browse.

DEF BROWSE b-cob-reg QUERY q-cobreg
    DISP tt-consulta-blt.dsdoccop FORMAT "x(15)"          LABEL "Nro Docto" /*nrdocmto -> ? rever origem ****/
         tt-consulta-blt.nrdocmto FORMAT "999999999"      LABEL "Boleto"
         tt-consulta-blt.dtmvtolt FORMAT "99/99/9999"     LABEL "Emissao"
         tt-consulta-blt.dtvencto FORMAT "99/99/9999"     LABEL "Vencto"
         tt-consulta-blt.dtdpagto FORMAT "99/99/9999"     LABEL "Dt. Pagto"
         tt-consulta-blt.vldpagto FORMAT "zzz,zzz,zz9.99" LABEL "Valor Pago"
         WITH 4 DOWN WIDTH 78 NO-LABELS OVERLAY.

FORM b-cob-reg
       HELP "Use: <F4> Sair <ENTER> Log Boleto <I> Instrucoes <E> Exp. Cons."
     WITH ROW 8 NO-LABELS NO-BOX CENTERED OVERLAY FRAME f_browse_cob.


DEF QUERY q_w-arquivos FOR w-arquivos.

DEF BROWSE b_w-arquivos QUERY q_w-arquivos
    DISPLAY w-arquivos.flginteg COLUMN-LABEL " "       FORMAT "*/"
            w-arquivos.dsarquiv COLUMN-LABEL "ARQUIVO" FORMAT "x(35)"
    WITH 7 DOWN CENTERED WIDTH 40 TITLE "Arquivos a serem integrados".

FORM SKIP(2)
    b_w-arquivos   HELP "Use <ESPACO> para selecionar e  <F4> para encerrar." SKIP
    WITH NO-BOX CENTERED OVERLAY ROW 6 FRAME f_cobran_browse.

ON  ANY-KEY OF b_w-arquivos DO:

    IF  LASTKEY = 32 THEN /* ESPACO */
        DO:
            IF  AVAIL w-arquivos THEN
                DO:
                    IF  w-arquivos.flginteg  THEN
                        ASSIGN w-arquivos.flginteg:SCREEN-VALUE
                                   IN BROWSE b_w-arquivos = STRING(FALSE)
                               w-arquivos.flginteg = FALSE.
                    ELSE
                        ASSIGN w-arquivos.flginteg:SCREEN-VALUE 
                                   IN BROWSE b_w-arquivos = STRING(TRUE)
                               w-arquivos.flginteg = TRUE.
                END.

    END.
END.

DEF QUERY q-logcob FOR tt-logcob.

DEF BROWSE b-logcob QUERY q-logcob
    DISP tt-logcob.dsdthora FORMAT "x(14)"       LABEL "Data/Hora"
         tt-logcob.dsdeslog FORMAT "x(46)"       LABEL "Descricao"
         tt-logcob.dsoperad FORMAT "x(12)"       LABEL "Operador"
    WITH 4 DOWN CENTERED NO-BOX.

DEF FRAME f_det_cobranca
     "CPF/CNPJ:"
     tt-consulta-blt.dsinssac  AT 11 FORMAT "x(18)"              NO-LABEL
     "Nosso Nr:"               AT 31
     tt-consulta-blt.nrnosnum  AT 41 FORMAT "x(17)"              NO-LABEL
     "Nr Doc:"                 AT 59
     tt-consulta-blt.dsdoccop  AT 67 FORMAT "x(11)"              NO-LABEL
     SKIP
     "Pagador.:"
     tt-consulta-blt.nmdsacad  AT 11 FORMAT "x(30)"              NO-LABEL
     "Cob.Reg.:"               AT 57
     tt-consulta-blt.flgregis  AT 66 FORMAT "x(3)"               NO-LABEL
     "DDA:"                    AT 71
     tt-consulta-blt.flgcbdda  AT 76 FORMAT "x(1)"               NO-LABEL
     SKIP
     "Ender...:"
     tt-consulta-blt.dsendsac  AT 11 FORMAT "x(38)"              NO-LABEL
     "Complem.:"               AT 51
     tt-consulta-blt.complend  AT 61 FORMAT "x(17)"              NO-LABEL
     SKIP
     "Bairro..:"
     tt-consulta-blt.nmbaisac  AT 11 FORMAT "x(16)"              NO-LABEL
     "Cidade:"                 AT 29
     tt-consulta-blt.nmcidsac  AT 37 FORMAT "x(17)"              NO-LABEL
     "UF:"                     AT 55
     tt-consulta-blt.cdufsaca  AT 59 FORMAT "x(2)"               NO-LABEL
     "CEP:"                    AT 64
     tt-consulta-blt.nrcepsac  AT 69 FORMAT "99999,999"          NO-LABEL
     SKIP
     "Juros...:"
     tt-consulta-blt.dscjuros  AT 11 FORMAT "x(14)"              NO-LABEL
     "Multa.:"                 AT 29
     tt-consulta-blt.dscmulta  AT 37 FORMAT "x(09)"              NO-LABEL
     "Descto:"                 AT 48
     tt-consulta-blt.dscdscto  AT 57 FORMAT "x(22)"              NO-LABEL
     /*SKIP(1)*/
     SKIP
     "Data Dcto:"
     tt-consulta-blt.dtdocmto  AT 12 FORMAT "99/99/99"           NO-LABEL
     "Esp Doc:"                AT 21
     tt-consulta-blt.dsdespec  AT 30 FORMAT "x(4)"               NO-LABEL    
     "Tp Emis:"                AT 35
     tt-consulta-blt.dsemiten  AT 44 FORMAT "x(5)"               NO-LABEL
     "Status:"                 AT 50
     tt-consulta-blt.dssituac  AT 58 FORMAT "x(13)"              NO-LABEL
     tt-consulta-blt.dtsitcrt  AT 71 FORMAT "99/99/99"           NO-LABEL
     SKIP
     "Vencto.:"
     tt-consulta-blt.dtvencto  AT 11 FORMAT "99/99/99"           NO-LABEL
     "Vlr Tit:"                AT 21
     tt-consulta-blt.vltitulo  AT 30 FORMAT "zzz,zzz,zz9.99"     NO-LABEL
     "Desc/Abat:"              AT 46
     tt-consulta-blt.vldesabt  AT 57 FORMAT "zzz,zz9.99"         NO-LABEL
     "Prot:"                   AT 70
     tt-consulta-blt.qtdiaprt  AT 76 FORMAT "99"                 NO-LABEL
     SKIP
     "Pagto..:"
     tt-consulta-blt.dtdpagto  AT 11 FORMAT "99/99/99"           NO-LABEL
     "Vlr Pag:"                AT 21
     tt-consulta-blt.vldpagto  AT 30 FORMAT "zzz,zzz,zz9.99"     NO-LABEL
     "Jur/Multa:"              AT 46
     tt-consulta-blt.vljurmul  AT 57 FORMAT "zzz,zz9.99"         NO-LABEL
     "Banco:"                  AT 69
     tt-consulta-blt.cdbandoc  AT 76 FORMAT "999"                NO-LABEL
     WITH TITLE "CONSULTA DE COBRANCA" CENTERED OVERLAY ROW 4.

DEF FRAME f_log_browse
    b-logcob    HELP  "Pressione <F4> ou <END> p/finalizar"
    WITH TITLE "LOG DO PROCESSO" CENTERED OVERLAY ROW 14.


DEF FRAME f_instrucoes
    "Instrucao:" tel_cdinstru                                 NO-LABEL
    HELP "Digite codigo da Instrucao ou <ENTER> para selecionar"
    tel_lsinstru               AT 25                          NO-LABEL
    HELP "Selecione e pressione <ENTER> para executar. <F4> Voltar"
    WITH TITLE "EXECUTAR INSTRUCOES" OVERLAY ROW 14 WIDTH 80.

DEF FRAME f_excluir_instr
    "Instrucao:" tel_cdexcins                                 NO-LABEL
    tel_lsexcins              AT 17                           NO-LABEL
    WITH TITLE "EXCLUIR INSTRUCOES" OVERLAY ROW 14 WIDTH 80.

FORM "Valor Abatimento:"
     SKIP
     tel_vlabatim              AT  7                          NO-LABEL
     WITH NO-BOX OVERLAY ROW 17 COLUMN 4 WIDTH 20 FRAME f_abatimento.
    
FORM "Valor Desconto:"
     SKIP
     tel_vldescto              AT  7                          NO-LABEL
     WITH NO-BOX OVERLAY ROW 17 COLUMN 4 WIDTH 20 FRAME f_desconto.

FORM "Nova Data Vencto:"
     SKIP
     tel_dtvencto              AT  7                          NO-LABEL
     WITH NO-BOX OVERLAY ROW 17 COLUMN 4 WIDTH 20 FRAME f_dtvencto.

ON RETURN OF tel_lsrelato DO:

    IF  tel_flgregis THEN
        ASSIGN tel_tprelato = IF   SUBSTR(tel_lsrelato:SCREEN-VALUE,1,1) = ?  THEN
                               5
                          ELSE INT(SUBSTR(tel_lsrelato:SCREEN-VALUE,1,1)).
    ELSE
        ASSIGN tel_tprelato = IF   SUBSTR(tel_lsrelato:SCREEN-VALUE,1,1) = ?  THEN
                               1
                          ELSE INT(SUBSTR(tel_lsrelato:SCREEN-VALUE,1,1)).
    
    ASSIGN tel_dsrelato = " - " + SUBSTR(tel_lsrelato:SCREEN-VALUE,4,60).

    DISPLAY tel_tprelato tel_dsrelato WITH FRAME f_relatorio.

    HIDE FRAME f_tprelato.

    APPLY "GO".     

END.

ON RETURN OF tel_lsstatus DO:

    ASSIGN tel_cdstatus = IF   SUBSTR(tel_lsstatus:SCREEN-VALUE,1,1) = ?  THEN
                               1
                          ELSE INT(SUBSTR(tel_lsstatus:SCREEN-VALUE,1,1))
           tel_dsstatus = " - " + SUBSTR(tel_lsstatus:SCREEN-VALUE,5,20).

    CASE tel_cdstatus:
         WHEN 1 THEN aux_cdstatus = "A".
         WHEN 3 THEN aux_cdstatus = "L".
         WHEN 2 OR
         WHEN 4 OR
         WHEN 5 THEN aux_cdstatus = "B".
    END.

    DISPLAY tel_cdstatus tel_dsstatus WITH FRAME f_relatorio.

    HIDE FRAME f_tpstatus.

    APPLY "GO".

END.

ON RETURN OF tel_lsinstru DO:

    ASSIGN tel_tpinstru = IF   SUBSTR(tel_lsinstru:SCREEN-VALUE,1,2) = ?  THEN
                               2
                          ELSE INT(SUBSTR(tel_lsinstru:SCREEN-VALUE,1,2))
           aux_dsinstru = SUBSTR(tel_lsinstru:SCREEN-VALUE,4,45)
           aux_cdinstru = tel_tpinstru
           tel_cdinstru = aux_cdinstru. 

    DISPLAY tel_cdinstru WITH FRAME f_instrucoes.
  
    APPLY "GO".

END.

ON RETURN OF tel_lsexcins DO:

    ASSIGN tel_tpexcins = IF   SUBSTR(tel_lsexcins:SCREEN-VALUE,1,2) = ?  THEN
                               INT(SUBSTR(ENTRY(1,tel_lsexcins:LIST-ITEMS,"."),1,2))
                          ELSE INT(SUBSTR(tel_lsexcins:SCREEN-VALUE,1,2))
           aux_cdexcins = tel_tpexcins.

    APPLY "GO".

END.

ON VALUE-CHANGED, ENTRY OF b-valor
    DO:
        IF  AVAILABLE tt-consulta-blt  THEN
            DO:
                DISPLAY tt-consulta-blt.dtdpagto 
                        tt-consulta-blt.dsdpagto
                        tt-consulta-blt.dtvencto
                        tt-consulta-blt.vltitulo
                        tt-consulta-blt.dsorgarq
                        tt-consulta-blt.nrdctabb
                        tt-consulta-blt.nmdsacad
                        tt-consulta-blt.dsdoccop
                        tt-consulta-blt.dssituac
                        tt-consulta-blt.dsinssac
                        WITH FRAME f_detalhes.
            END.
    END.

ON VALUE-CHANGED, ENTRY OF b-cob-reg
DO:
    RUN detalha_dados_boleto.
END.

ON  ENTER OF b-cob-reg IN FRAME f_browse_cob
    DO:

    IF  AVAILABLE tt-consulta-blt THEN 
        DO:

            EMPTY TEMP-TABLE tt-logcob.
        
            RUN conecta_handle.
        
            RUN buca_log IN h-b1wgen0010
                       ( INPUT glb_cdcooper,
                         INPUT 0,
                         INPUT 0,
                         INPUT tt-consulta-blt.nrdconta,
                         INPUT tt-consulta-blt.nrcnvcob,
                         INPUT tt-consulta-blt.nrdocmto,
                        OUTPUT TABLE tt-logcob,
                        OUTPUT TABLE tt-erro).
        
            RUN deleta_handle.

            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    FIND FIRST tt-erro NO-ERROR.
        
                    IF  AVAIL tt-erro THEN
                        MESSAGE tt-erro.dscritic.
        
                    PAUSE NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.
        
                    RETURN.
        
                END.
        
            DISPLAY tt-consulta-blt.dsinssac
                    tt-consulta-blt.nrnosnum tt-consulta-blt.dsdoccop
                    tt-consulta-blt.nmdsacad tt-consulta-blt.flgregis
                    tt-consulta-blt.flgcbdda tt-consulta-blt.dsendsac
                    tt-consulta-blt.complend tt-consulta-blt.nmbaisac
                    tt-consulta-blt.nmcidsac tt-consulta-blt.cdufsaca
                    tt-consulta-blt.nrcepsac tt-consulta-blt.dscjuros
                    tt-consulta-blt.dscmulta tt-consulta-blt.dscdscto
                    tt-consulta-blt.dtdocmto tt-consulta-blt.dsdespec
                    tt-consulta-blt.dsemiten tt-consulta-blt.dssituac
                    tt-consulta-blt.dtsitcrt tt-consulta-blt.dtvencto
                    tt-consulta-blt.vltitulo tt-consulta-blt.vljurmul
                    tt-consulta-blt.qtdiaprt tt-consulta-blt.dtdpagto
                    tt-consulta-blt.vldpagto tt-consulta-blt.vldesabt            
                    tt-consulta-blt.cdbandoc WITH FRAME f_det_cobranca.
        
            OPEN QUERY q-logcob
              FOR EACH tt-logcob.
        
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE b-logcob WITH FRAME f_log_browse.
                LEAVE.
            END.
        
            CLOSE QUERY q-logcob.
                     
            HIDE FRAME f_det_cobranca.
            HIDE FRAME f_log_browse.
           
            HIDE MESSAGE NO-PAUSE.
        
            RETURN.
        END.

END.

ON i, I OF b-cob-reg IN FRAME f_browse_cob
   DO:
    
    /* nao apresentar instrucoes p/ cobranca baixada/liquidada */
    IF  tt-consulta-blt.cdsituac = "B"  OR
        tt-consulta-blt.cdsituac = "L"  THEN
    DO:
        MESSAGE "Opcao nao disponivel para situacao " +
                tt-consulta-blt.dssituac + "."
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
        LEAVE.
    END.

    RUN pi_tela_instrucoes.

    HIDE FRAME f_det_cobranca.
    HIDE FRAME f_instrucoes.

    HIDE MESSAGE NO-PAUSE.

    IF  aux_lginstru THEN
        RUN reload_browse_cob_reg.

    RETURN.

END.

ON e, E OF b-cob-reg IN FRAME f_browse_cob
   DO:
    HIDE FRAME f_det_cob_reg.
    HIDE FRAME f_browse_cob.
    HIDE MESSAGE NO-PAUSE.

    RUN exporta_consulta.

    VIEW FRAME f_det_cob_reg.
    VIEW FRAME f_browse_cob.

END.

ON e, E OF b-valor IN FRAME f_browse
   DO:
    HIDE FRAME f_detalhes.
    HIDE FRAME f_browse.
    HIDE MESSAGE NO-PAUSE.

    RUN exporta_consulta.

    VIEW FRAME f_detalhes.
    VIEW FRAME f_browse.

END.


ON ENTER OF b-logcob IN FRAME f_log_browse
   DO:
             
    HIDE FRAME f_det_cobranca.
    HIDE FRAME f_log_browse.
   
    HIDE MESSAGE NO-PAUSE.

    APPLY "GO".

END.

ASSIGN glb_cdcritic = 0.

VIEW FRAME f_moldura.     

PAUSE(0).

ASSIGN glb_cddopcao = "C"
       par_flgrodar = TRUE.

DO WHILE TRUE:

    HIDE FRAME f_documento  
         FRAME f_vencimento 
         FRAME f_sacado
         FRAME f_pagamento  
         FRAME f_emissao    
         FRAME f_data       
         FRAME f_bloqueto   
         FRAME f_conta      
         FRAME f_relatorio
         FRAME f_relatorio_3
         FRAME f_cobran_browse
         FRAME f_browse_cob.

    tel_tpconsul:VISIBLE IN FRAME f_cobran    = FALSE. 
    tel_flgregis:VISIBLE IN FRAME f_cobran    = FALSE.
    tel_consulta:VISIBLE IN FRAME f_consul03  = FALSE.

    RUN fontes/inicia.p.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN tel_nrdconta = 0
               tel_cdagenci = 0
               ini_dtdpagto = ?
               tel_tpconsul = 0
               tel_consulta = 0
               ini_nrdocmto = 0
               fim_nrdocmto = 0
               ini_dtvencto = ?
               fim_dtvencto = ?
               ini_dtdpagto = ?
               fim_dtdpagto = ?
               ini_dtmvtolt = ?
               fim_dtmvtolt = ?
               tel_tprelato = 0
               tel_cdstatus = 0
               tel_dsstatus = ""
               tel_dsrelato = "".

        UPDATE glb_cddopcao WITH FRAME f_cobran.

        IF  aux_cddopcao <> glb_cddopcao   THEN
            DO:
                { includes/acesso.i}
                ASSIGN aux_cddopcao = glb_cddopcao.
            END.

        IF  glb_cddopcao = "I" THEN
            DO:
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    ASSIGN aux_confirma = "N".
                    BELL.
                    MESSAGE COLOR NORMAL "Importar varios arquivos (S/N) ?"
                        UPDATE tel_vrsarqvs.
                    ASSIGN glb_cdcritic = 0.
                    LEAVE.
                END.

                IF  tel_vrsarqvs THEN
                    RUN opcao_i_varios.
                ELSE
                    RUN opcao_i_unico.

                NEXT.
            END.
        ELSE
        IF  glb_cddopcao = "C"   THEN
            DO:
                DO WHILE TRUE:
                    
                    UPDATE tel_tpconsul tel_flgregis WITH FRAME f_cobran.

                    IF  (INPUT tel_tpconsul < 1 OR INPUT tel_tpconsul > 3) THEN DO:
                        MESSAGE "329 - Tipo de consulta errado.".
                        NEXT.
                    END.

                    LEAVE.
                END.


                CASE tel_tpconsul:

                    WHEN 3 THEN UPDATE tel_consulta WITH FRAME f_consul03. 

                    WHEN 2 THEN UPDATE tel_consulta WITH FRAME f_consul02.

                    OTHERWISE UPDATE tel_consulta WITH FRAME f_consul01.

                END CASE. 
            END.

        LEAVE.     
    END. /* Fim do DO WHILE TRUE */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  glb_nmdatela <> "COBRAN" THEN
                DO:
                    HIDE FRAME f_cobran.
                    HIDE FRAME f_moldura.
                    HIDE FRAME f_cobran_browse.
                    RETURN.
                END.
            NEXT.
        END. 

    EMPTY TEMP-TABLE tt-consulta-blt.

    IF  glb_cddopcao = "R"  THEN
        DO:
            ASSIGN tel_nrdcont2 = 0
                   tel_cdagenci = 0 
                   ini_dtperiod = ?
                   fim_dtperiod = ?
                   aux_dsperiod = ""
                   tel_nmprimtl = "".

            DO WHILE TRUE:

                HIDE tel_nrdcont2 tel_cdagenci ini_dtperiod
                     fim_dtperiod aux_dsperiod tel_cdstatus
                     IN FRAME f_relatorio.

                CLEAR FRAME f_relatorio   NO-PAUSE.
                CLEAR FRAME f_conta       NO-PAUSE.
                CLEAR FRAME f_conta_docto NO-PAUSE.

                UPDATE tel_flgregis WITH FRAME f_relatorio.

                RUN carrega_listbox_relatorios.

                UPDATE tel_tprelato WITH FRAME f_relatorio

                EDITING:

                    READKEY.

                    IF  LASTKEY = KEYCODE("F7") THEN
                        DO:
                            DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                                UPDATE tel_lsrelato WITH FRAME f_tprelato.
                                LEAVE.
                            END.

                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                DO:
                                    HIDE FRAME f_tprelato.
                                    NEXT.
                                END.

                            LEAVE.

                        END.
                    ELSE
                        APPLY LASTKEY.

                END.  /* Fim do EDITING */

                LEAVE.  

            END.  /* Fim do DO WHILE TRUE */

            IF  tel_flgregis THEN
                ASSIGN tel_dsrelato = SUBSTR(ENTRY(tel_tprelato - 4,
                                       tel_lsrelato:LIST-ITEMS,","),2,61).
            ELSE
                ASSIGN tel_dsrelato = SUBSTR(ENTRY(tel_tprelato,
                                       tel_lsrelato:LIST-ITEMS,","),2,61).

            DISPLAY tel_dsrelato WITH FRAME f_relatorio.

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                DO:
                    HIDE FRAME f_tprelato.
                    NEXT.
                END.

            CASE tel_tprelato:
                WHEN 2 THEN DO:
                               DISPLAY tel_nrdcont2 WITH FRAME f_relatorio.
                               aux_dsperiod = "   Periodo:".
                            END.
                WHEN 3 THEN aux_dsperiod = "   Periodo:".
                WHEN 4 THEN DO:
                               DISPLAY tel_nrdcont2 WITH FRAME f_relatorio.
                               aux_dsperiod = " Pagamento:".
                            END.
                WHEN 5 THEN DO:
                               DISPLAY tel_nrdcont2 tel_cdstatus 
                                       WITH FRAME f_relatorio.
                               aux_dsperiod = "   Periodo:".
                            END.
                WHEN 6 THEN DO:
                               DISPLAY tel_nrdcont2 tel_cdagenci
                                       WITH FRAME f_relatorio.
                               aux_dsperiod = "   Periodo:".
                            END.
                OTHERWISE aux_dsperiod = "   Periodo:".
            END CASE.

            DISPLAY aux_dsperiod WITH FRAME f_relatorio.

            DO WHILE TRUE:
                UPDATE ini_dtperiod fim_dtperiod WITH FRAME f_relatorio.
                LEAVE.
            END. /* Fim do DO WHILE TRUE */

            IF  tel_tprelato = 2 THEN
                DO WHILE TRUE:

                    UPDATE tel_nrdcont2 WITH FRAME f_relatorio

                    EDITING:

                        READKEY.
    
                        HIDE MESSAGE NO-PAUSE.
    
                        IF  LASTKEY = KEYCODE("F7")  THEN
                            DO:
                                IF  FRAME-FIELD = "tel_nrdcont2" THEN
                                    DO:
                                        RUN fontes/zoom_associados.p 
                                            ( INPUT  glb_cdcooper,
                                              OUTPUT tel_nrdcont2 ).
        
                                IF  tel_nrdconta > 0   THEN
                                    DO:
                                         DISPLAY tel_nrdcont2 WITH FRAME f_relatorio.
                             
                                         PAUSE 0.
                                    END.
                            END.
    
                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                NEXT.
                        END.
                
                        APPLY LASTKEY.
                          
                    END. /* Fim do EDITING*/

                    ASSIGN aux_nrdconta = tel_nrdcont2.

                    RUN busca_associado.

                    HIDE MESSAGE NO-PAUSE.

                    IF  RETURN-VALUE = "OK" THEN
                        DO:
                            FIND FIRST tt-crapass NO-ERROR.
                
                            IF  AVAIL tt-crapass THEN
                                ASSIGN tel_nmprimtl = " - " + tt-crapass.nmprimtl
                                       tel_nrdconta = aux_nrdconta.
                
                            DISPLAY tel_nrdcont2 tel_nmprimtl
                                WITH FRAME f_relatorio.
                        END.

                    IF  tel_nrdcont2 > 0 THEN
                        DO:
                            IF  AVAIL tt-crapass THEN DO:
                                ASSIGN tel_cdagenci = tt-crapass.cdagenci.
                                DISPLAY tel_cdagenci WITH FRAME f_relatorio.
                            END.
                            ELSE
                                NEXT.
                        END.
                    ELSE 
                        DO:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                UPDATE tel_cdagenci WITH FRAME f_relatorio.
                                LEAVE.
                            END.

                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                NEXT.
                        END.

                    LEAVE.

                END. /* Fim do DO WHILE TRUE */
            ELSE
            IF  tel_tprelato = 4 THEN
                DO:
                    DO WHILE TRUE:

                        tel_nrdcont2:HELP = "Informe o numero da conta.".

                        UPDATE tel_nrdcont2 WITH FRAME f_relatorio.

                        ASSIGN aux_nrdconta = tel_nrdcont2.

                        RUN busca_associado.
                
                        IF  RETURN-VALUE = "OK" THEN
                            DO:
                                FIND FIRST tt-crapass NO-ERROR.
                    
                                IF  AVAIL tt-crapass THEN
                                    ASSIGN tel_nmprimtl = " - " + tt-crapass.nmprimtl.
                    
                                DISPLAY tel_nrdconta tel_nmprimtl
                                    WITH FRAME f_relatorio.
                            END.
                        ELSE
                            NEXT.

                        IF  AVAIL tt-crapass THEN DO:
                            ASSIGN tel_cdagenci = tt-crapass.cdagenci.
                            DISPLAY tel_cdagenci WITH FRAME f_relatorio.
                        END.
                        ELSE
                            NEXT.

                        LEAVE.

                    END. /* Fim do DO WHILE TRUE */

                END.  /* Fim tipo relatorio 4 */
            ELSE
            IF  tel_tprelato = 5 THEN DO:

                DO WHILE TRUE:

                    UPDATE tel_cdstatus  WITH FRAME f_relatorio
                    EDITING:
                        
                        READKEY.

                        IF  LASTKEY = KEYCODE("F7") THEN
                            DO:
                                DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                                    UPDATE tel_lsstatus WITH FRAME f_tpstatus.
                                    LEAVE.
                                END.

                                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                    DO:
                                        HIDE FRAME f_tpstatus.
                                        NEXT.
                                    END.

                                LEAVE.
                            END.
                        ELSE
                            APPLY LASTKEY.

                    END. /* FIM do EDITING */

                    LEAVE.

                END.  /* Fim do DO WHILE TRUE */

                ASSIGN tel_dsstatus = SUBSTR(ENTRY(tel_cdstatus,
                                       tel_lsstatus:LIST-ITEMS,","),2,25).

                DISPLAY tel_cdstatus tel_dsstatus WITH FRAME f_relatorio.

                DO WHILE TRUE:
                    ASSIGN tel_nrdcont2:HELP = "Informe o numero da conta.".

                    UPDATE tel_nrdcont2 WITH FRAME f_relatorio.

                    ASSIGN aux_nrdconta = tel_nrdcont2.

                    RUN busca_associado.

                    IF  RETURN-VALUE = "OK" THEN
                        DO:
                            FIND FIRST tt-crapass NO-ERROR.

                            IF  AVAIL tt-crapass THEN
                                ASSIGN tel_nmprimtl = " - " + tt-crapass.nmprimtl.

                            DISPLAY tel_nmprimtl
                                WITH FRAME f_relatorio.
                        END.
                    ELSE
                        NEXT.

                    LEAVE.
                END. /* Fim do DO WHILE TRUE */

            END. /* FIM do IF = 5 */
            ELSE
            IF  tel_tprelato = 6 THEN DO:

                DO WHILE TRUE:

                    UPDATE tel_nrdcont2 WITH FRAME f_relatorio.

                    ASSIGN aux_nrdconta = tel_nrdcont2.

                    RUN busca_associado.
            
                    IF  RETURN-VALUE = "OK" THEN
                        DO:
                            FIND FIRST tt-crapass NO-ERROR.
                
                            IF  AVAIL tt-crapass THEN
                                ASSIGN tel_nmprimtl = " - " + tt-crapass.nmprimtl.
                
                            DISPLAY tel_nrdconta tel_nmprimtl
                                WITH FRAME f_relatorio.
                        END.
                    ELSE
                        NEXT.

                    IF  tel_nrdcont2 > 0 THEN
                        DO:
                            IF  AVAIL tt-crapass THEN DO:
                                ASSIGN tel_cdagenci = tt-crapass.cdagenci.
                                DISPLAY tel_cdagenci WITH FRAME f_relatorio.
                            END.
                            ELSE
                                NEXT.
                        END.
                    ELSE 
                        DO:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                UPDATE tel_cdagenci WITH FRAME f_relatorio.
                                LEAVE.
                            END.

                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                NEXT.
                        END.

                    LEAVE.

               END. /* Fim do DO WHILE TRUE */

           END. /* FIM do IF = 6 */

           MESSAGE "Aguarde...Gerando Relatorio...".

           RUN gera_relatorio.

           IF  RETURN-VALUE <> "OK" THEN
               NEXT.

           HIDE MESSAGE NO-PAUSE.

           ASSIGN tel_cddopcao = "T".

           MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.
      
           IF   tel_cddopcao = "T"  THEN
                DO:
                    RUN fontes/visrel.p (INPUT aux_nmarqimp).
                END.
                           
           FIND FIRST crapass WHERE
                      crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

           IF  CAN-DO("4,5,6",STRING(tel_tprelato)) THEN
               ASSIGN glb_nmformul = "234dh".
        
           { includes/impressao.i }

            NEXT.

        END. /* Fim da opcao "R" */

    /* So Opcao C ... " */
    CLEAR FRAME f_conta       NO-PAUSE.
    CLEAR FRAME f_conta_docto NO-PAUSE.

    IF  tel_consulta = 1  THEN    /*  Por conta  */
        DO:
            DO WHILE TRUE:

                UPDATE tel_nrdconta WITH FRAME f_conta

                EDITING:

                    READKEY.

                    HIDE MESSAGE NO-PAUSE.

                    IF  LASTKEY = KEYCODE("F7")  THEN
                        DO:
                            IF  FRAME-FIELD = "tel_nrdconta" THEN
                                DO:
                                    RUN fontes/zoom_associados.p 
                                        ( INPUT  glb_cdcooper,
                                          OUTPUT tel_nrdconta ).
    
                            IF  tel_nrdconta > 0   THEN
                                DO:
                                     DISPLAY tel_nrdconta WITH FRAME f_conta.
                         
                                     PAUSE 0.
                                END.
                        END.

                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                            NEXT.
                    END.
            
                    APPLY LASTKEY.
                      
                END. /* Fim do EDITING*/


                ASSIGN aux_nrdconta = tel_nrdconta.

                RUN busca_associado.
            
                IF  RETURN-VALUE = "OK" THEN
                    DO:
                        FIND FIRST tt-crapass NO-ERROR.
            
                        IF  AVAIL tt-crapass THEN
                            ASSIGN tel_nmprimtl = " - " + tt-crapass.nmprimtl.
            
                        tel_nrdconta = aux_nrdconta.
            
                        DISPLAY tel_nrdconta tel_nmprimtl WITH FRAME f_conta.

                        LEAVE.
                    END.
            
            END.
        END. 
    ELSE
    IF  tel_consulta = 2 AND (tel_tpconsul = 1 OR tel_tpconsul = 2)  THEN
        DO:  
            DO WHILE TRUE:
                UPDATE ini_nrdocmto WITH FRAME f_bloqueto.
                LEAVE.
            END.

            /* a BO trabalha sempre com periodo */
            ASSIGN fim_nrdocmto = ini_nrdocmto.
        END.
    ELSE
    IF  tel_consulta = 2 AND tel_tpconsul = 3  THEN /*  Por nr.Boleto  */
        DO:
            DO WHILE TRUE:
                UPDATE ini_nrdocmto  fim_nrdocmto WITH FRAME f_documento.
                LEAVE.
            END.
        END.
    ELSE
    IF  tel_consulta = 3 THEN /* Por dt.Emissao  */
        DO:                                             
            DO WHILE TRUE:
                UPDATE ini_dtmvtolt  fim_dtmvtolt WITH FRAME f_emissao.
                LEAVE.
            END.
        END.
    IF  tel_consulta = 4 THEN   /*  Por dt.Pagamento  */
        DO:
            DO WHILE TRUE:
                UPDATE ini_dtdpagto  fim_dtdpagto WITH FRAME f_pagamento.
                LEAVE.
            END.
        END.
    ELSE
    IF  tel_consulta = 5 THEN   /*  Por dt.Vencto  */
        DO:
            DO WHILE TRUE:
                UPDATE ini_dtvencto  fim_dtvencto WITH FRAME f_vencimento.
                LEAVE.
            END.
        END.
    ELSE
    IF  tel_consulta = 6   THEN
        DO:
            ASSIGN tel_nmprimtl = "".

            DO WHILE TRUE:
                UPDATE tel_nmprimtl WITH FRAME f_sacado.
                LEAVE.
            END.
        END.
    IF  tel_consulta = 8   THEN
        DO:
            ASSIGN tel_nmprimtl = "".

            DO WHILE TRUE:
                UPDATE tel_nrdconta WITH FRAME f_conta

                EDITING:

                    READKEY.

                    HIDE MESSAGE NO-PAUSE.

                    IF  LASTKEY = KEYCODE("F7")  THEN
                        DO:
                            IF  FRAME-FIELD = "tel_nrdconta" THEN
                                DO:
                                    RUN fontes/zoom_associados.p 
                                        ( INPUT  glb_cdcooper,
                                          OUTPUT tel_nrdconta ).
    
                            IF  tel_nrdconta > 0   THEN
                                DO:
                                     DISPLAY tel_nrdconta WITH FRAME f_conta.
                         
                                     PAUSE 0.
                                END.
                        END.

                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                            NEXT.
                    END.
            
                    APPLY LASTKEY.
                      
                END. /* Fim do EDITING*/

                ASSIGN aux_nrdconta = tel_nrdconta.

                RUN busca_associado.
            
                IF  RETURN-VALUE = "OK" THEN
                    DO:
                        FIND FIRST tt-crapass NO-ERROR.
            
                        IF  AVAIL tt-crapass THEN
                            ASSIGN tel_nmprimtl = " - " + tt-crapass.nmprimtl.
            
                        tel_nrdconta = aux_nrdconta.
            
                        DISPLAY tel_nrdconta tel_nmprimtl WITH FRAME f_conta.

                        LEAVE.
                    END.
                 ELSE
                     NEXT.
               
            END.

            UPDATE ini_dsdoccop WITH FRAME f_conta_docto.

            ASSIGN tel_nmprimtl = ini_dsdoccop.
        END.

    HIDE MESSAGE NO-PAUSE.

    MESSAGE "Aguarde...".
    
    RUN proc_instancia. /* Chamar BO de boletos */

    IF  tel_consulta = 8   THEN
        ASSIGN tel_nmprimtl = "".

    IF  RETURN-VALUE = "NOK"   THEN
        NEXT.

    HIDE MESSAGE NO-PAUSE.

    IF  tel_flgregis THEN 
        DO:

            OPEN QUERY q-cobreg FOR EACH tt-consulta-blt
                                      BY tt-consulta-blt.dtvencto
                                      BY tt-consulta-blt.nrdocmto.

            ENABLE b-cob-reg WITH FRAME f_browse_cob.

        END.
    ELSE 
        DO:
            OPEN QUERY q-valor FOR EACH tt-consulta-blt.

            ENABLE b-valor WITH FRAME f_browse.
        END.

    WAIT-FOR CLOSE OF CURRENT-WINDOW.

    LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

PROCEDURE opcao_i_unico:

    DEF VAR aux_confirma AS CHARACTER FORMAT "!(1)"                  NO-UNDO.

    FORM SKIP(2)
         "Nome do arquivo a ser integrado:" AT 5
         SKIP(2)
         tel_nmarqint   AT 5  NO-LABEL
         HELP "Informe o diretorio do arquivo p/integ. as inform. dos boletos."
         VALIDATE(INPUT tel_nmarqint <> "","375 - O campo deve ser preenchido.")
         SKIP(2)
         WITH WIDTH 70 OVERLAY ROW 10 CENTERED SIDE-LABELS
              TITLE " Integracao de Arquivo " FRAME f_integra_unico.


    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_nmarqint WITH FRAME f_integra_unico.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           aux_confirma = "N".
           glb_cdcritic = 78.
           RUN fontes/critic.p.
           BELL.
           MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
           glb_cdcritic = 0.
           LEAVE.
        END.

        IF  aux_confirma <> "S" THEN
            NEXT.
        
        RUN integra_arquivo.

        MESSAGE "Operacao efetuada com sucesso!" VIEW-AS ALERT-BOX.

        LEAVE.
        
    END.

    glb_cdcritic = 0.
    HIDE FRAME f_integra_unico.

END PROCEDURE.

/* .......................................................................... */

PROCEDURE opcao_i_varios:

    DEF VAR aux_confirma AS CHARACTER FORMAT "!(1)"                  NO-UNDO.
    
    FORM SKIP(2)
         "Caminho dos arquivos que serao integrados:" AT 5
         SKIP(2)
         tel_nmarqint   AT 5  NO-LABEL
         HELP "Informe o diretorio do arquivo p/integ. as inform. dos boletos."
         VALIDATE(INPUT tel_nmarqint <> "","375 - O campo deve ser preenchido.")
         SKIP(2)
         WITH WIDTH 70 OVERLAY ROW 10 CENTERED SIDE-LABELS
              TITLE " Integracao de Arquivo " FRAME f_integra_varios.

    ASSIGN aux_dsnmarqv = "".

    /* Pede o diretorio que estao os arquivos */
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_nmarqint WITH FRAME f_integra_varios.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           aux_confirma = "N".
           glb_cdcritic = 78.
           RUN fontes/critic.p.
           BELL.
           MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
           glb_cdcritic = 0.
           LEAVE.
        END.

        IF  aux_confirma <> "S"   THEN
            NEXT.

        ASSIGN aux_dsnmarqv = tel_nmarqint.
    
        /** Carregar lista de arquivos do diretorio */
        MESSAGE "Aguarde... Listando arquivo(s)...".

        RUN carrega_arquivos.

        HIDE MESSAGE NO-PAUSE.
    
        /** Exibe browse e permite eliminar arqs. da lista */
        CLOSE QUERY q_w-arquivos.
    
        OPEN QUERY q_w-arquivos FOR EACH w-arquivos NO-LOCK
                                      BY w-arquivos.dsarquiv.
    
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            PAUSE 0.
            UPDATE b_w-arquivos WITH FRAME f_cobran_browse.
            LEAVE.
        END.

        IF  b_w-arquivos:NUM-SELECTED-ROWS = 0   THEN
            DO:
                MESSAGE "Nao foi selecionado nenhum arquivo.".
                HIDE FRAME f_cobran_browse.
                NEXT.
            END.

        HIDE FRAME f_cobran_browse
             FRAME f_integra_varios.
    
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            ASSIGN aux_confirma = "N"
                   glb_cdcritic = 78.
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.
            BELL.
            MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
            LEAVE.
        END.
    
        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
            aux_confirma <> "S"                 THEN
            DO:
                ASSIGN glb_cdcritic = 79.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                ASSIGN glb_cdcritic = 0.
                CLOSE QUERY q_w-arquivos.
                NEXT.
            END.

        RUN integra_arquivo.

        CLOSE QUERY q_w-arquivos.

        IF  RETURN-VALUE = "OK" THEN
            MESSAGE "Operacao efetuada com sucesso!" VIEW-AS ALERT-BOX.

        LEAVE.

    END.

    ASSIGN glb_cdcritic = 0.
    HIDE FRAME f_integra_varios
         FRAME f_cobran_browse.

END PROCEDURE.

/* .......................................................................... */

PROCEDURE proc_instancia:

    RUN conecta_handle.

    RUN consulta-bloqueto IN h-b1wgen0010 
                        ( INPUT glb_cdcooper,
                          INPUT tel_nrdconta,
                          INPUT ini_nrdocmto,
                          INPUT fim_nrdocmto,
                          INPUT 0,
                          INPUT tel_nmprimtl,
                          INPUT 0,
                          INPUT 999999,
                          INPUT 1,
                          INPUT ini_dtvencto,
                          INPUT fim_dtvencto,
                          INPUT ini_dtdpagto,
                          INPUT fim_dtdpagto,
                          INPUT ini_dtmvtolt,
                          INPUT fim_dtmvtolt,
                          INPUT tel_consulta, 
                          INPUT tel_tpconsul,
                          INPUT 1, /* Ayllos */
                          INPUT 0,
                          INPUT 0,
                          INPUT ini_dsdoccop,
                          INPUT tel_flgregis,
                          INPUT 0, /* inestcri 0 Nao, 1 Sim */
                          INPUT "", /* inserasa "" - Todos */
                         OUTPUT aux_qtregist,
                         OUTPUT aux_nmdcampo,
                         OUTPUT TABLE tt-erro,
                         OUTPUT TABLE tt-consulta-blt).

    RUN deleta_handle.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
/*                           + " -> Ver rotina (b1wgen0010)". */
                    RETURN "NOK".
                END.
        END.

    RETURN "OK".

END PROCEDURE. /* Chamar BO com informacoes dos boletos */

/* .......................................................................... */

PROCEDURE pi_tela_instrucoes:

    ASSIGN aux_contador = 0
           tel_vlabatim = 0
           tel_vldescto = 0
           aux_cdinstru = 0
           tel_cdinstru = 0
           tel_dtvencto = ?
           aux_lginstru = FALSE.

    ASSIGN tel_lsinstru = ""
           tel_lsinstru:SCREEN-VALUE IN FRAME f_instrucoes = ""
           tel_lsinstru:LIST-ITEMS IN FRAME f_instrucoes = "".


    RUN conecta_handle.

    RUN busca_instrucoes IN h-b1wgen0010
                       ( INPUT glb_cdcooper,
                         INPUT 0,
                         INPUT 0,
                         INPUT tt-consulta-blt.cdcooper,
                         INPUT tt-consulta-blt.cdbandoc,
                        OUTPUT TABLE tt-crapoco,
                        OUTPUT TABLE tt-erro).

    RUN deleta_handle.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAIL tt-erro THEN
                MESSAGE tt-erro.dscritic.

            PAUSE NO-MESSAGE.
            HIDE MESSAGE NO-PAUSE.

            RETURN.

        END.

    FOR EACH tt-crapoco NO-LOCK:
        tel_lsinstru:ADD-LAST(tt-crapoco.lsinstru) IN FRAME f_instrucoes.
    END.

    DISPLAY tt-consulta-blt.dsinssac
            tt-consulta-blt.nrnosnum tt-consulta-blt.dsdoccop
            tt-consulta-blt.nmdsacad tt-consulta-blt.flgregis
            tt-consulta-blt.flgcbdda tt-consulta-blt.dsendsac
            tt-consulta-blt.complend tt-consulta-blt.nmbaisac
            tt-consulta-blt.nmcidsac tt-consulta-blt.cdufsaca
            tt-consulta-blt.nrcepsac tt-consulta-blt.dscjuros
            tt-consulta-blt.dscmulta tt-consulta-blt.dscdscto
            tt-consulta-blt.dtdocmto tt-consulta-blt.dsdespec
            tt-consulta-blt.dsemiten tt-consulta-blt.dssituac
            tt-consulta-blt.dtsitcrt tt-consulta-blt.dtvencto
            tt-consulta-blt.vltitulo tt-consulta-blt.vljurmul
            tt-consulta-blt.qtdiaprt tt-consulta-blt.dtdpagto
            tt-consulta-blt.vldpagto tt-consulta-blt.vldesabt
            tt-consulta-blt.cdbandoc WITH FRAME f_det_cobranca.

    DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

        UPDATE tel_cdinstru WITH FRAME f_instrucoes.

        IF  tel_cdinstru = 0 THEN
            UPDATE tel_lsinstru WITH FRAME f_instrucoes.

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
            DO:
                HIDE FRAME f_instrucoes.
                HIDE FRAME f_det_cobranca.
                NEXT.
            END.

        IF  tel_cdinstru <> 0 THEN
            ASSIGN aux_cdinstru = tel_cdinstru.
        ELSE
            ASSIGN aux_cdinstru = INT(tel_tpinstru).

        RUN conecta_handle.

        RUN valida_instrucoes IN h-b1wgen0010
                            ( INPUT glb_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT tel_cdinstru,
                             OUTPUT TABLE tt-erro).

        RUN deleta_handle.

        IF  RETURN-VALUE <> "OK" THEN
            DO:
                FIND FIRST tt-erro NO-ERROR.
    
                IF  AVAIL tt-erro THEN
                    MESSAGE tt-erro.dscritic.
    
                PAUSE NO-MESSAGE.
                HIDE MESSAGE NO-PAUSE.
    
                NEXT.
            END.

        PAUSE 0 NO-MESSAGE.

        IF  aux_cdinstru = 4 THEN
            UPDATE tel_vlabatim WITH FRAME f_abatimento.
        ELSE
        IF  aux_cdinstru = 6 THEN
            UPDATE tel_dtvencto WITH FRAME f_dtvencto.
        ELSE
        IF  aux_cdinstru = 7 THEN
            UPDATE tel_vldescto WITH FRAME f_desconto.
        
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            ASSIGN aux_confirma = "N".
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE COLOR NORMAL "Confirma execucao Instrucao " + 
                                 STRING(aux_cdinstru,"99") + " ?"
                                 UPDATE aux_confirma.
            LEAVE.
        END. /*  Fim do DO WHILE TRUE  */

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
            DO:
                ASSIGN glb_cdcritic = 79.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                ASSIGN glb_cdcritic = 0.
                NEXT.
            END.

        IF  aux_confirma = "S" THEN DO:
            
            ASSIGN aux_lginstru = TRUE.

            /* se for intrucao de desconto, ira utilizar o campo tel_abatim 
               para passar o valor de desconto */
            IF  aux_cdinstru = 7 THEN
                ASSIGN tel_vlabatim = tel_vldescto.

            RUN conecta_handle.

            RUN grava_instrucoes IN h-b1wgen0010
                               ( INPUT glb_cdcooper,
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT glb_dtmvtolt,
                                 INPUT glb_cdoperad,
                                 INPUT aux_cdinstru,
                                 INPUT tt-consulta-blt.nrdconta,
                                 INPUT tt-consulta-blt.nrcnvcob,
                                 INPUT tt-consulta-blt.nrdocmto,
                                 INPUT tel_vlabatim,
                                 INPUT tel_dtvencto,
                                 INPUT tt-consulta-blt.cdtpinsc,
                                OUTPUT TABLE tt-erro).

            RUN deleta_handle.
    
            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    FIND FIRST tt-erro NO-ERROR.
        
                    IF  AVAIL tt-erro THEN
                        MESSAGE tt-erro.dscritic
                        VIEW-AS ALERT-BOX INFO BUTTONS OK.

                    PAUSE NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.
        
                    NEXT.
                END.

        END. /** END do IF com TRANSACTION */
        ELSE DO:
            MESSAGE "Instrucao nao executada".
            ASSIGN aux_cdinstru = 0
                   tel_cdinstru = 0
                   tel_vlabatim = 0
                   tel_vldescto = 0
                   tel_dtvencto = ?
                   aux_lginstru = FALSE.
            PAUSE 2 NO-MESSAGE.
            HIDE MESSAGE NO-PAUSE.
            NEXT.
        END.

        LEAVE.

    END. /* Fim do ELSE DO */
    
    ASSIGN tel_lsinstru = ""
           tel_lsinstru:SCREEN-VALUE IN FRAME f_instrucoes = ""
           tel_lsinstru:LIST-ITEMS IN FRAME f_instrucoes = "".

END PROCEDURE.

/* .......................................................................... */

PROCEDURE reload_browse_cob_reg:

    DEFINE VARIABLE aux_linhasel AS INTEGER     NO-UNDO.
    
    ASSIGN aux_linhasel = 0.

    IF  QUERY q-cobreg:IS-OPEN  THEN
        DO:
            ASSIGN aux_linhasel = QUERY q-cobreg:CURRENT-RESULT-ROW.
            CLOSE QUERY q-cobreg.
        END.

    DISABLE b-cob-reg WITH FRAME f_browse_cob.

    RUN proc_instancia. /* Chamar BO de boletos */

    IF  RETURN-VALUE = "NOK"   THEN
        NEXT.

    HIDE MESSAGE NO-PAUSE.

    OPEN QUERY q-cobreg FOR EACH tt-consulta-blt
                              BY tt-consulta-blt.dtvencto
                              BY tt-consulta-blt.nrdocmto.

    ENABLE b-cob-reg WITH FRAME f_browse_cob.
    
    IF  aux_linhasel > 0  THEN
        REPOSITION q-cobreg TO ROW aux_linhasel.    

    RUN detalha_dados_boleto.

END PROCEDURE.

PROCEDURE detalha_dados_boleto:

    IF  AVAILABLE tt-consulta-blt  THEN DO:

        DISPLAY tt-consulta-blt.dssituac
                tt-consulta-blt.dtsitcrt
                tt-consulta-blt.vltitulo
                tt-consulta-blt.nrcnvcob
                tt-consulta-blt.cdbanpag
                tt-consulta-blt.cdagepag
                tt-consulta-blt.nmdsacad
                tt-consulta-blt.dsdpagto
                tt-consulta-blt.nrdconta
                tt-consulta-blt.nmprimtl
                tt-consulta-blt.nrnosnum
                tt-consulta-blt.dsorgarq
                tt-consulta-blt.nrdctabb
                WITH FRAME f_det_cob_reg.
    END.

END PROCEDURE.

/* .......................................................................... */

PROCEDURE carrega_listbox_relatorios:

    tel_lsrelato = "".

    IF  NOT tel_flgregis THEN
        tel_lsrelato:LIST-ITEMS IN FRAME f_tprelato =
            "1- Gestao da carteira de cobranca sem registro - Por PA," +
            "2- Gestao da carteira de cobranca sem registro - Por Cooperado," +
            "3- Gestao da carteira de cobranca sem registro - Por Convenio," +
            "4- Relatorio Movimento de liquidacoes - Francesa(S/ Registro)".
    ELSE
        tel_lsrelato:LIST-ITEMS IN FRAME f_tprelato =
            "5- Relatorio Beneficiario," + 
            "6- Relatorio Movimento de Cobranca Registrada".
            /* temporario comentado
            "7- Resumo das Carteiras".*/

END PROCEDURE.

/* .......................................................................... */

PROCEDURE exporta_consulta:

    DEF VAR aux_nmarqint AS CHAR INITIAL "consulta.csv" FORMAT "x(60)" NO-UNDO.

    FORM SKIP(2)
         "Nome do arquivo a ser exportado:" AT 5
        SKIP(2)
         aux_nmarqint   AT 5  NO-LABEL
            HELP "Informe o nome do arquivo a ser exportado."
         VALIDATE(INPUT aux_nmarqint <> "","375 - O campo deve ser preenchido.")
         SKIP(2)
         WITH WIDTH 70 OVERLAY ROW 10 CENTERED SIDE-LABELS
              TITLE " Exportar Consulta " FRAME f_relatori.

    UPDATE aux_nmarqint WITH FRAME f_relatori NO-LABEL.

    MESSAGE "Aguarde, gerando arquivo.".

    RUN conecta_handle.

    RUN exporta_boleto IN h-b1wgen0010
                     ( INPUT glb_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /* idorigem */
                       INPUT glb_nmdatela,
                       INPUT glb_cdprogra,
                       INPUT glb_dtmvtolt,
                       INPUT tel_nrdconta,
                       INPUT ini_nrdocmto,
                       INPUT fim_nrdocmto,
                       INPUT tel_nmprimtl,
                       INPUT ini_dtvencto,
                       INPUT fim_dtvencto,
                       INPUT ini_dtdpagto,
                       INPUT fim_dtdpagto,
                       INPUT ini_dtmvtolt,
                       INPUT fim_dtmvtolt,
                       INPUT tel_consulta,
                       INPUT tel_tpconsul,
                       INPUT ini_dsdoccop,
                       INPUT tel_flgregis,
                       INPUT aux_nmarqint,
                      OUTPUT TABLE tt-erro).

    HIDE MESSAGE NO-PAUSE.

    RUN deleta_handle.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN "NOK".
                END.
        END.

    MESSAGE "Arquivo gerado com sucesso!" VIEW-AS ALERT-BOX.

    RETURN "OK".

END PROCEDURE.

PROCEDURE conecta_handle:

    IF  NOT VALID-HANDLE(h-b1wgen0010) THEN
        RUN sistema/generico/procedures/b1wgen0010.p 
            PERSISTENT SET h-b1wgen0010.

END PROCEDURE. /* conecta_handle */

PROCEDURE deleta_handle:

    IF  VALID-HANDLE(h-b1wgen0010) THEN
        DELETE PROCEDURE h-b1wgen0010.

END PROCEDURE. /* deleta_handle */

PROCEDURE busca_associado:

    EMPTY TEMP-TABLE tt-crapass.
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN busca_associado IN h-b1wgen0010
                      ( INPUT glb_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT aux_nrdconta,
                       OUTPUT TABLE tt-crapass,
                       OUTPUT TABLE tt-erro).

    RUN deleta_handle.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN "NOK".
                END.
        END.

    RETURN "OK".

END PROCEDURE. /* busca_associado */

PROCEDURE gera_relatorio:

    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.

    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    RUN conecta_handle.

    RUN gera_relatorio IN h-b1wgen0010
                     ( INPUT glb_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /* idorigem */
                       INPUT glb_nmdatela,
                       INPUT glb_cdprogra,
                       INPUT glb_dtmvtolt,
                       INPUT tel_nrdcont2,
                       INPUT tel_nmprimtl,
                       INPUT tel_tprelato,
                       INPUT ini_dtperiod,
                       INPUT fim_dtperiod,
                       INPUT tel_cdstatus,
                       INPUT tel_cdagenci,
                       INPUT aux_nmendter,
                      OUTPUT aux_nmarqimp,
                      OUTPUT aux_nmarqpdf,
                      OUTPUT TABLE tt-erro).

    RUN deleta_handle.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN "NOK".
                END.
        END.

    RETURN "OK".

END PROCEDURE. /* gera_relatorio */

PROCEDURE integra_arquivo:

    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.

    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    RUN conecta_handle.

    RUN integra_arquivo IN h-b1wgen0010
                      ( INPUT glb_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1, /* idorigem */
                        INPUT glb_nmdatela,
                        INPUT glb_cdprogra,
                        INPUT glb_dtmvtolt,
                        INPUT glb_cdoperad,
                        INPUT aux_nmendter,
                        INPUT tel_nmarqint,
                        INPUT aux_dsnmarqv,
                        INPUT tel_vrsarqvs,
                        INPUT TABLE w-arquivos,
                       OUTPUT aux_nmarqimp,
                       OUTPUT aux_nmarqpdf,
                       OUTPUT aux_nmarqim2,
                       OUTPUT aux_nmarqpd2,
                       OUTPUT TABLE tt-erro).

    RUN deleta_handle.
    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                DO:
                    MESSAGE tt-erro.dscritic VIEW-AS ALERT-BOX.
                    IF aux_nmarqim2 = "" AND aux_nmarqimp = "" THEN
                        RETURN "NOK".
                END.
        END.

    DO aux_contador = 1 TO 2:

        IF  aux_contador = 2 AND aux_nmarqim2 <> "" THEN
            DO:
                ASSIGN aux_nmarqimp = aux_nmarqim2
                       glb_nrdevias = 1
                       glb_nmformul = "132col"
                       par_flgrodar = TRUE.

                VIEW FRAME f_aguarde_rej.
                PAUSE 2 NO-MESSAGE.
                HIDE FRAME f_aguarde_rej NO-PAUSE.
            END.
        ELSE IF aux_nmarqimp <> ""  THEN
            DO:
                ASSIGN glb_nrdevias = 1
                       glb_nmformul = "80col"
                       par_flgrodar = TRUE.

                VIEW FRAME f_aguarde.
                PAUSE 2 NO-MESSAGE.
                HIDE FRAME f_aguarde NO-PAUSE.
            END.

        IF  aux_nmarqimp <> "" THEN 
            RUN impressao.
    END.

    RETURN "OK".

END PROCEDURE. /* integra_arquivo */

PROCEDURE impressao:

    IF  NOT AVAIL crapass THEN
            FIND FIRST crapass WHERE
                       crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

    { includes/impressao.i }

END PROCEDURE.

PROCEDURE carrega_arquivos:

    RUN conecta_handle.

    RUN carrega_arquivos IN h-b1wgen0010
                       ( INPUT tel_nmarqint,
                        OUTPUT TABLE w-arquivos).
    RUN deleta_handle.

END PROCEDURE. /* carrega_arquivos */
/* .......................................................................... */

