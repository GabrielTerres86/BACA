/* .............................................................................

   Programa: Includes/var_seguro.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/96.                           Ultima atualizacao: 03/02/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criacao das variaveis para tratamento do seguro

   Alteracoes: 22/04/97 - Alterado para tratar automacao das propostas de seguro
                          auto/casa (Edson).

               22/07/97 - Alterado para tratar substituicao de seguro (Edson).

               05/11/97 - Alterado para tratar coberturas extras e substituicao
                          de seguro com pagto unico (Edson).
 
               06/04/1999 - Alterar format do campo bonus (Deborah).

               02/08/1999 - Tratar seguro de vida em grupo (Deborah).

               10/11/1999 - Seguro de vida para conjuge (Deborah).

               20/01/2000 - Tratar seguro prestamista (Deborah).   

               16/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
                
               02/05/2001 - Permitir o cadastramento de seguro auto parcelados.
                            (Ze Eduardo).
                            
               21/09/2001 - Seguro Residencial (Ze Eduardo).
               
               03/01/2002 - Acertos no seguro residencial (Ze Eduardo).

               22/03/2005 - Acertos para novo modelo de cadastramento de
                            seguro (Unibanco), escolher tipo e seguradora
                            atraves de listas (Julio)
                            
               14/04/2005 - Nao deixar a data de inicio de vigencia ser menor
                            que a data atual e a data de fim da vigencia nao
                            pode ser menor que o inicio da vigencia - novo
                            modelo de seguro UNIBANCO, tipo 11 (Evandro).
                                           
               24/11/2005 - Nao deixar mais fixo o controle de dia max. para 
                            debito do seguro. (Julio)
                            
               01/12/2005 - Tratamento para seguro SUL AMERICA-CASA (Evandro).

               07/12/2005 - Controle para o inicio da vigencia ser menor 
                            que 45 dias comparado a data atual (Julio)

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando
                    
               21/06/2006 - Acrescentados campos referente Local do Risco
                            na Frame f_seg_simples_mens (Diego).

               10/07/2006 - Criacao de frames separados para informacao de 
                            dias de debito de seguro casa (Julio).
                            
               05/11/2008 - Retirar tipo AUTO da inclusao (Selec.List) (Gabriel)

               19/11/2008 - Incluida variavel aux_dtinivig (Diego).

               22/04/2009 - Retirar tudo o que for do seguro AUTO (Gabriel). 
               
               14/07/2009 - Incluido HELP no campo seg_cdsexosg (Guilherme).
               
               30/03/2010 - Incluir variavel para a BO de seguro.
                            Passar para um browse dinamico. (Gabriel).
                            
               27/04/2011 - Aumentar formato do bairro (Gabriel).             
               
               25/08/2011 - Retirado campo Garantia, craptsg.dsgarant, do
                            browse do zoom do Plano.
                            Aos campos "Dia Primeiro Débito", "Inicio Vigencia"
                            e "Final Vigencia" é atribuido valor fixo.
                            Incluidos campos "Clausula Beneficiaria" e
                            "Nome Benef". Incluidos campos referentes ao
                            Endereco de Correspondencia. (Gati - Oliver)
                
               25/07/2013 - Incluido o campo Complemento no endereco. (James)             
               
               16/12/2013 - Alterado label da variavel seg_nrcpfcgc de "CPF/CGC"
                            para "CPF/CNPJ". (Reinert)
                            
               03/02/2015 - Tratamento no layout do formulario f_seguro_3
                            para permitir um campo variavel, entre formato de data
                            e somente o dia SD235552 (Odirlei-AMcom)             
                            
............................................................................. */

 { sistema/generico/includes/b1wgen0033tt.i }     
      
DEFINE BUFFER crabseg FOR crapseg.

DEF {1} SHARED VAR aux_ultlinha AS INTE                                 NO-UNDO.
DEF {1} SHARED VAR aux_flgsaida AS LOGI                                 NO-UNDO.


DEF            VAR tel_dspesseg AS CHAR                                 NO-UNDO.
DEF            VAR tel_dssitseg AS CHAR                                 NO-UNDO.
DEF            VAR tel_dsseguro AS CHAR                                 NO-UNDO.
DEF            VAR tel_dsevento AS CHAR                                 NO-UNDO.
DEF            VAR aux_nmdcampo AS CHAR                                 NO-UNDO.

DEF            VAR tel_vlpreseg AS DECI                                 NO-UNDO.
DEF            VAR tel_vlcapseg AS DECI FORMAT "zzz,zzz,zzz9.99"        NO-UNDO.
DEF            VAR tel_txpartic AS DECI FORMAT "zz9.99" EXTENT 5        NO-UNDO.
DEF            VAR tel_qtpreseg AS INT                                  NO-UNDO.
DEF            VAR tel_tpplaseg AS INT  FORMAT "zz9"                    NO-UNDO.
DEF            VAR tel_vlprepag AS DECI                                 NO-UNDO.
DEF            VAR tel_dtinivig AS DATE                                 NO-UNDO.
DEF            VAR tel_dtfimvig AS DATE                                 NO-UNDO.
DEF            VAR tel_dtdebito AS DATE                                 NO-UNDO.
DEF            VAR tel_dtcancel AS DATE                                 NO-UNDO.

DEF            VAR tel_dsgarant AS CHAR                                 NO-UNDO.
DEF            VAR tel_dsmorada AS CHAR                                 NO-UNDO.
DEF            VAR tel_dsocupac AS CHAR                                 NO-UNDO.
DEF            VAR tel_dscobert AS CHAR FORMAT "x(050)"                 NO-UNDO.
DEF            VAR tel_nmbenefi AS CHAR FORMAT "x(040)" EXTENT 5        NO-UNDO.
DEF            VAR tel_dsgraupr AS CHAR FORMAT "x(025)" EXTENT 5        NO-UNDO.
                                        

DEF            VAR seg_cdsegura AS INT                                  NO-UNDO.
DEF            VAR seg_nrctrseg AS INT                                  NO-UNDO.
DEF            VAR seg_nrctrato AS INT                                  NO-UNDO.
DEF            VAR seg_vlpreseg AS DECI                                 NO-UNDO.
DEF            VAR seg_qtpreseg AS INT                                  NO-UNDO.
DEF            VAR seg_vltotpre AS DECI                                 NO-UNDO.
DEF            VAR seg_qtparseg AS INT                                  NO-UNDO.
DEF            VAR seg_vlprepag AS DECI                                 NO-UNDO.
DEF            VAR seg_vlcobext AS DECI EXTENT 5                        NO-UNDO.
DEF            VAR seg_dtinivig AS DATE                                 NO-UNDO.
DEF            VAR seg_dtfimvig AS DATE                                 NO-UNDO.
DEF            VAR seg_flgclabe LIKE    crapseg.flgclabe                NO-UNDO.
DEF            VAR seg_nmbenvid LIKE    crapseg.nmbenvid                NO-UNDO.
DEF            VAR seg_dtdebito AS DATE                                 NO-UNDO.
DEF            VAR seg_dtcancel AS DATE                                 NO-UNDO.
DEF            VAR seg_dsmotcan AS CHAR FORMAT "x(40)"                  NO-UNDO.
DEF            VAR seg_dtnasctl AS DATE                                 NO-UNDO.
DEF            VAR aux_crawseg  AS RECID                                NO-UNDO.


DEF            VAR seg_dsgarant AS CHAR                                 NO-UNDO.
DEF            VAR seg_dsmorada AS CHAR                                 NO-UNDO.
DEF            VAR seg_dsocupac AS CHAR                                 NO-UNDO.
DEF            VAR seg_dscobext AS CHAR EXTENT 5                        NO-UNDO.
DEF            VAR seg_dsestcvl AS CHAR FORMAT "x(12)"                  NO-UNDO.
DEF            VAR seg_dssexotl AS CHAR FORMAT "x(020)"                 NO-UNDO.
DEF            VAR seg_cdsexosg AS INT                                  NO-UNDO.

DEF            VAR seg_cdtipseg AS INT                                  NO-UNDO.
DEF            VAR seg_tpseguro AS INT                                  NO-UNDO.
DEF            VAR seg_dstipseg AS CHAR FORMAT "x(004)"                 NO-UNDO.
DEF            VAR aux_lstipseg AS CHAR FORMAT "x(004)" EXTENT 4 
                                        INIT "CASA,AUTO,VIDA,PRST"      NO-UNDO.

DEF            VAR aux_qtparcel LIKE crawseg.qtparcel                   NO-UNDO.

DEF            VAR seg_flgunica AS LOGI                                 NO-UNDO.
DEF            VAR seg_flgvisto AS LOGI                                 NO-UNDO.
DEF            VAR seg_flgreduz AS LOGI                                 NO-UNDO.
DEF            VAR seg_flgtpseg AS LOGI                                 NO-UNDO.

DEF            VAR seg_tpendcor   LIKE crapseg.tpendcor                 NO-UNDO.
DEF            VAR seg_dsendres_2 LIKE crawseg.dsendres                 NO-UNDO.
DEF            VAR seg_nrendere_2 LIKE crawseg.nrendres                 NO-UNDO.
DEF            VAR seg_nmbairro_2 LIKE crawseg.nmbairro                 NO-UNDO.
DEF            VAR seg_nrcepend_2 LIKE crawseg.nrcepend                 NO-UNDO.
DEF            VAR seg_nmcidade_2 LIKE crawseg.nmcidade                 NO-UNDO.
DEF            VAR seg_cdufresd_2 LIKE crawseg.cdufresd                 NO-UNDO.
DEF            VAR seg_complend_2 LIKE crawseg.complend                 NO-UNDO.

DEF            VAR seg_nrcxapst AS INTE FORMAT "zz,zz9"                 NO-UNDO.

DEF            VAR seg_nmresseg AS CHAR                                 NO-UNDO.
DEF            VAR seg_nmbenefi AS CHAR                                 NO-UNDO.
DEF            VAR seg_nmcpveic AS CHAR                                 NO-UNDO.
DEF            VAR seg_vlbenefi AS DECI                                 NO-UNDO.
DEF            VAR seg_nmempres AS CHAR                                 NO-UNDO.
DEF            VAR seg_nrcadast AS INT                                  NO-UNDO.
DEF            VAR seg_nmdsecao AS CHAR                                 NO-UNDO.
DEF            VAR seg_nrfonemp AS CHAR                                 NO-UNDO.
DEF            VAR seg_dsendres AS CHAR                                 NO-UNDO.
DEF            VAR seg_nrfonres AS CHAR                                 NO-UNDO.
DEF            VAR seg_nmbairro AS CHAR                                 NO-UNDO.
DEF            VAR seg_nmcidade AS CHAR                                 NO-UNDO.
DEF            VAR seg_cdufresd AS CHAR                                 NO-UNDO.
DEF            VAR seg_nrcepend AS INT                                  NO-UNDO.
DEF            VAR seg_dsmarvei AS CHAR                                 NO-UNDO.
DEF            VAR seg_dstipvei AS CHAR                                 NO-UNDO.
DEF            VAR seg_nmdsegur AS CHAR                                 NO-UNDO.
DEF            VAR seg_nrcpfcgc AS CHAR                                 NO-UNDO.
DEF            VAR seg_nranovei AS INT                                  NO-UNDO.
DEF            VAR seg_nrmodvei AS INT                                  NO-UNDO.
DEF            VAR seg_nrdplaca AS CHAR                                 NO-UNDO.
DEF            VAR seg_qtpassag AS INT                                  NO-UNDO.
DEF            VAR seg_dschassi AS CHAR                                 NO-UNDO.
DEF            VAR seg_ppdbonus AS DECI                                 NO-UNDO.
DEF            VAR seg_flgdnovo AS LOGI                                 NO-UNDO.
DEF            VAR seg_flgrenov AS LOGI                                 NO-UNDO.
DEF            VAR seg_nmsegant AS CHAR                                 NO-UNDO.
DEF            VAR seg_flgdutil AS LOGI                                 NO-UNDO.
DEF            VAR seg_flgnotaf AS LOGI                                 NO-UNDO.
DEF            VAR seg_flgapant AS LOGI                                 NO-UNDO.
DEF            VAR seg_flgrepgr AS LOGI                                 NO-UNDO.
DEF            VAR seg_ddvencto AS INT   INIT 1                         NO-UNDO.
DEF            VAR seg_cdcalcul AS INT                                  NO-UNDO.
DEF            VAR seg_tpplaseg AS INT                                  NO-UNDO.
DEF            VAR seg_cdapoant AS CHAR                                 NO-UNDO.
DEF            VAR seg_vlseguro AS DECI                                 NO-UNDO.
DEF            VAR seg_vldfranq AS DECI                                 NO-UNDO.
DEF            VAR seg_vldcasco AS DECI                                 NO-UNDO.
DEF            VAR seg_vlverbae AS DECI                                 NO-UNDO.
DEF            VAR seg_flgassis AS LOGI                                 NO-UNDO.
DEF            VAR seg_vldanmat AS DECI                                 NO-UNDO.
DEF            VAR seg_vldanpes AS DECI                                 NO-UNDO.
DEF            VAR seg_vldanmor AS DECI                                 NO-UNDO.
DEF            VAR seg_vlappmor AS DECI                                 NO-UNDO.
DEF            VAR seg_vlappinv AS DECI                                 NO-UNDO.
DEF            VAR seg_vldifseg AS DECI                                 NO-UNDO.
DEF            VAR seg_vlfrqobr AS DECI                                 NO-UNDO.
DEF            VAR seg_flgcurso AS LOGI                                 NO-UNDO.
DEF            VAR seg_nrendere AS INT                                  NO-UNDO.
DEF            VAR seg_complend AS CHAR FORMAT "x(40)"                  NO-UNDO.

DEF            VAR aux_dtdebito AS DATE                                 NO-UNDO.
DEF            VAR aux_dtvigaux AS DATE                                 NO-UNDO.
DEF            VAR aux_dtprideb AS DATE                                 NO-UNDO.

DEF            VAR aux_dscritic AS CHAR                                 NO-UNDO.

DEF            VAR aux_dstitseg AS CHAR INIT "Primeiro Titular,Conjuge" NO-UNDO.
DEF            VAR aux_dstipseg AS CHAR INIT "Vida,Prst"                NO-UNDO.
DEF            VAR aux_cdtitseg AS CHAR INIT "1,2"                      NO-UNDO.
DEF            VAR aux_cdtipseg AS CHAR INIT "1,2,3,4"                  NO-UNDO.

DEF            VAR aux_indposic AS INT                                  NO-UNDO.
DEF            VAR aux_indpostp AS INT                                  NO-UNDO.
DEF            VAR seg_dstitseg AS CHAR                                 NO-UNDO.
DEF            VAR seg_dtnascsg AS DATE                                 NO-UNDO.
DEF            VAR aux_dssegvid AS CHAR FORMAT "x(12)"                  NO-UNDO.
DEF            VAR aux_vldebseg AS DECI                                 NO-UNDO.
DEF            VAR aux_dtinivig AS DATE                                 NO-UNDO.
DEF            VAR aux_confirma AS CHAR FORMAT "!"                      NO-UNDO.


DEF            VAR tel_vlacipes AS DECI FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF            VAR tel_vldanele AS DECI FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF            VAR tel_vldesmor AS DECI FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF            VAR tel_vldiaria AS DECI FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF            VAR tel_vldrcfam AS DECI FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF            VAR tel_vldvento AS DECI FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF            VAR tel_vlmorada AS DECI FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF            VAR tel_vlrouboe AS DECI FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF            VAR tel_vlroubop AS DECI FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF            VAR tel_vlrouboq AS DECI FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF            VAR tel_vlvidros AS DECI FORMAT "zzz,zzz,zz9.99"         NO-UNDO.

DEF            VAR seg_ddpripag AS INTE                                 NO-UNDO.
DEF            VAR seg_dtpripag AS DATE                                 NO-UNDO.
DEF            VAR seg_qtmaxpar AS INTE                                 NO-UNDO.

DEF            VAR aux_tpseguro AS CHAR                                 NO-UNDO.
DEF            VAR aux2_tpseguro AS INTEGER                             NO-UNDO.

DEF            VAR tel_tpseguro AS CHAR VIEW-AS SELECTION-LIST
                                        INNER-LINES 3 INNER-CHARS 20   NO-UNDO.

DEF            VAR h-b1wgen0033 AS HANDLE                               NO-UNDO.

DEF QUERY  q_seguros FOR tt-seguros.
DEF BROWSE b_seguros QUERY q_seguros
    DISPLAY dtiniseg COLUMN-LABEL "Inicio"     
            nrctrseg COLUMN-LABEL "Proposta"
            dtdebito COLUMN-LABEL "Dia"        
            dsseguro COLUMN-LABEL "Tipo"
            vlpreseg COLUMN-LABEL "Prestacao"  FORMAT "zzz,zz9.99"
            dtinivig COLUMN-LABEL "Inicio Vig" 
            dsstatus COLUMN-LABEL "Situacao"   FORMAT "x(10)"
            
            WITH 6 DOWN WIDTH 76 OVERLAY NO-BOX.

DEF QUERY  q_motivos FOR tt-mot-can.
DEF BROWSE b_motivos QUERY q_motivos
    DISPLAY tt-mot-can.cdmotcan NO-LABEL 
            tt-mot-can.dsmotcan NO-LABEL FORMAT "x(40)"
    WITH 9 DOWN TITLE ("Motivos do Cancelamento") OVERLAY.
FORM b_motivos  AT 1 HELP "Use as setas para navegar / F4 para sair"
    WITH OVERLAY CENTERED ROW 8 SIZE 48 BY 11 SIDE-LABELS
    NO-BOX FRAME f_motivos.

DEF QUERY  q_planos FOR tt-plano-seg.
DEF BROWSE b_planos QUERY q_planos
    DISPLAY tt-plano-seg.tpplaseg  COLUMN-LABEL "Plano"
            tt-plano-seg.dsmorada  COLUMN-LABEL "Moradia"  FORMAT "x(18)"
            tt-plano-seg.dsocupac  COLUMN-LABEL "Ocupacao" FORMAT "x(18)"
            WITH 4 DOWN OVERLAY NO-BOX.

FORM tel_tpseguro AT 3 LABEL "Escolha o tipo de seguro"
                       HELP "Pressione ENTER para selecionar / F4 para sair"
     WITH CENTERED ROW 8 OVERLAY SIZE 30 BY 10 FRAME f_tipo.


FORM
     seg_nmresseg  AT 16  LABEL "Seguradora"          FORMAT "x(30)"
     SKIP
     seg_nrctrseg  AT 15  LABEL "Nr.Proposta"         FORMAT "zz,zzz,zz9"
                          HELP "Informe o numero da proposta"
     " "
     seg_tpplaseg         LABEL "Plano"               FORMAT "zz9"
                          HELP "Informe o Plano / F7 para listar"" "
     seg_dstipseg         LABEL "Tipo"
     SKIP(12)
     WITH OVERLAY CENTERED ROW 5 WIDTH 78 SIDE-LABELS FRAME f_seg_simples.

FORM SKIP(1)                      
     seg_ddpripag  AT  1  LABEL "Dia Primeiro Debito"   FORMAT "z9"
                          HELP "Informe o dia do primeiro pagamento" 
     seg_ddvencto  AT 36  LABEL "Debito demais Parcelas"  FORMAT "z9"
                          HELP "Informe o dia do debito das parcelas mensais"
     WITH OVERLAY CENTERED ROW 8 WIDTH 76 SIDE-LABELS NO-BOX
          FRAME f_seg_simples_ddpripag.

FORM SKIP(1)                      
     seg_ddvencto  AT 12  LABEL "Dia do Debito"  FORMAT "z9"
                          HELP "Informe o dia do debito das parcelas mensais"
     WITH OVERLAY CENTERED ROW 10 WIDTH 70 SIDE-LABELS NO-BOX
          FRAME f_seg_simples_ddpagto_car.

FORM SKIP(1)                      
     "Endereco de Correspondencia" AT 21
     SKIP(1)
     seg_tpendcor   AT  9  LABEL "Tipo de Endereco" FORMAT "9"
                           HELP "1-Local do risco, 2-Residencial, 3-Comercial"
     SKIP
     seg_dsendres_2 AT  6  FORMAT "x(40)"      LABEL "Rua"
     seg_nrendere_2        FORMAT "zz,zz9"     LABEL "Numero"
     seg_complend_2 AT  3  FORMAT "x(40)"      LABEL "Compl."
     seg_nmbairro_2 AT  3  FORMAT "x(40)"      LABEL "Bairro"
     seg_nrcepend_2 AT 55  FORMAT "99,999,999" LABEL "CEP"
     seg_nmcidade_2 AT  3  FORMAT "x(25)"      LABEL "Cidade"
     seg_cdufresd_2 AT 54  FORMAT "!!"         LABEL "U.F."
     SKIP(5)
     WITH OVERLAY CENTERED ROW 7 WIDTH 70 SIDE-LABELS NO-BOX
          FRAME f_seg_simples_end_corr.

FORM seg_vlpreseg  AT 2   LABEL "Valor das Parcelas"     FORMAT "zzz,zz9.99"
                          HELP "Informe o valor do debito"
     SKIP
     seg_dtinivig  AT 5   LABEL "Inicio Vigencia"  FORMAT "99/99/9999"
                          HELP "Entre com a data de inicio da vigencia"
     " "                              
     seg_dtfimvig         LABEL "Final Vigencia"   FORMAT "99/99/9999"
                          HELP "Entre com a data do fim da vigencia"
     SKIP
     seg_flgclabe  AT 6   LABEL "Clausula Benef" FORMAT "S/N"
                          HELP "Habilitar clausula beneficiaria ? (S/N)"
     SKIP
     seg_nmbenvid[1] AT 3 LABEL "Nome Beneficiario" FORMAT "x(38)"
                          HELP "Entre com o nome do beneficiario"
     SKIP
     seg_dtcancel  AT 8   LABEL "Cancelado em"        FORMAT "99/99/9999"
                          HELP "Entre com a data de cancelamento"

     " "
     seg_dsmotcan         LABEL "Mot" FORMAT "x(37)"

     SKIP(1)
     "Local do Risco"  AT 30
     seg_nrcepend AT 05 LABEL "CEP"          FORMAT "99999,999"
         HELP "Informe o Cep do endereco ou pressione F7 para pesquisar"
     seg_dsendres AT 21 LABEL "Rua"          FORMAT "x(36)"
         HELP "Informe o Endereco do imovel"
     seg_nrendere AT 63 LABEL "Nr"           FORMAT "zzz,zz9"
         HELP  "Informe o numero da residencia"
     SKIP
     seg_complend AT 02 LABEL "Compl."
         HELP  "Informe o complemento do endereco"
     SKIP
     seg_nmbairro AT 02 LABEL "Bairro"  FORMAT "x(28)"
         HELP "Informe o nome do bairro"
     seg_nmcidade LABEL "Cidade"  FORMAT "x(20)"
         HELP "Informe o nome da cidade"
     seg_cdufresd LABEL "U.F."    FORMAT "!(2)"
         HELP "Informe a Sigla do Estado"
     WITH OVERLAY CENTERED ROW 10 WIDTH 76 SIDE-LABELS NO-BOX
          FRAME f_seg_simples_mens.    

FORM SKIP
     seg_ddpripag  AT  6  LABEL "Dia Primeiro Debito"   FORMAT "z9"
                          HELP "Informe o dia do primeiro pagamento" 
     SKIP
     seg_ddvencto  AT  3  LABEL "Debito demais Parcelas"  FORMAT "z9"
                          HELP "Informe o dia do debito das parcelas mensais"
     seg_vltotpre  AT 13  LABEL "Premio Total"      FORMAT "zzz,zz9.99"
     seg_qtmaxpar  AT  9  LABEL "Qtd. de Parcelas"  FORMAT "z9"
                          HELP "Informe a quantidade de parcelas"
     SKIP                      
     seg_vlpreseg  AT  7  LABEL "Valor das Parcelas"     FORMAT "zzz,zz9.99"
                          HELP "Informe o valor do debito"
                          VALIDATE(INPUT seg_vlpreseg = aux_vldebseg       OR
                                   INPUT seg_vlpreseg = TRUNCATE(aux_vldebseg /
                                                     INPUT seg_qtmaxpar,2) OR
                                   aux_vldebseg = 0,
                                   "208 - Valor da Prestacao Errado.")
         
     SKIP(1)
     seg_dtinivig  AT  7  LABEL "Inicio da Vigencia"  FORMAT "99/99/9999"
                          HELP "Entre com a data de inicio da vigencia"
     seg_dtfimvig  AT  8  LABEL "Final da Vigencia"   FORMAT "99/99/9999"
                          HELP "Entre com a data do fim da vigencia"
     SKIP
     seg_dtcancel  AT 13  LABEL "Cancelado em"        FORMAT "99/99/9999"
                          HELP "Entre com a data de cancelamento"
     SKIP
     WITH OVERLAY CENTERED ROW 11 WIDTH 70 SIDE-LABELS NO-BOX
          FRAME f_seg_simples_var.


FORM b_planos  AT 4 HELP "Use as setas para navegar / F4 para sair"
     SKIP(1)
     tt-plano-seg.vlplaseg  AT  4 LABEL "Premio"           FORMAT "zzz,zz9.99"
     tt-plano-seg.flgunica  AT 40 LABEL "Tipo Parcela"     
     SKIP
     tt-plano-seg.qtmaxpar  AT  4 LABEL "Quantidade Maxima de Parcelas     "
                             FORMAT "z9"
     SKIP
     tt-plano-seg.mmpripag  AT  4 LABEL "Meses carencia Primeiro Pagamento "
                             FORMAT "z9"
     SKIP
     tt-plano-seg.qtdiacar  AT  4 LABEL "Dias carencia primeiro pagamento  "
                             FORMAT "z9"
     SKIP
     tt-plano-seg.ddmaxpag  AT  4 LABEL "Debitar parcela ate o dia         " 
                             FORMAT "z9"  "de cada mes"
     SKIP
     WITH OVERLAY CENTERED ROW 8 SIDE-LABELS FRAME f_planos.

FORM SKIP(1)
     tel_vlpreseg AT  4 FORMAT "zzz,zzz,zz9.99"  LABEL "Valor do Premio"
     tel_dtinivig AT 46 FORMAT "99/99/9999"      LABEL "Inicio da Vigencia"
     SKIP
     tel_vlprepag AT  9 FORMAT "zzz,zzz,zz9.99"  LABEL "Total Pago"
     tel_dtfimvig AT 49 FORMAT "99/99/9999"      LABEL "Fim da Vigencia"
     SKIP
     tel_qtpreseg AT  2 FORMAT "           zz9"  LABEL "Qtd. Prest. Pagas"
     tel_dtcancel AT 52 FORMAT "99/99/9999"      LABEL "Cancelado em"
     SKIP
     tel_dtdebito AT 50 FORMAT "99/99/9999"      LABEL "Proximo Debito"
     SKIP
     tel_dsmorada AT  4 FORMAT "x(50)"           LABEL "Tipo de Moradia"
     SKIP
     tel_dsgarant AT 11 FORMAT "x(20)"           LABEL "Garantia"
     tel_dsocupac AT 42 FORMAT "x(25)"           LABEL "Ocupacao"
     SKIP(1)
     tel_dspesseg AT  2 FORMAT "x(27)"           LABEL "Pesquisa"
     tel_dssitseg AT 42 FORMAT "x(10)"           LABEL "Situacao"
     tel_dsevento AT 68 FORMAT "x(8)"            NO-LABEL
     HELP "Tecle <Entra> para CANCELAR o seguro ou <FIM> para retornar."
     WITH ROW 10 CENTERED SIDE-LABELS NO-LABELS OVERLAY TITLE COLOR NORMAL
          tel_dsseguro WIDTH 78 FRAME f_seguro.

FORM SKIP(1)
     seg_dstipseg AT  6                          LABEL "Seguro"
                  HELP "Escolha com as setas de direcao"

     seg_nmresseg AT 22 FORMAT "x(20)"           LABEL "Seguradora"

     SKIP(1)
     seg_dstitseg AT  5 FORMAT "x(20)"           LABEL "Titular"
                        HELP "Escolha com as setas de direcao"
     SKIP(1)
     seg_nmdsegur AT  4 FORMAT "x(40)"           LABEL "Segurado"
                        HELP "Entre com o nome do segurado."
     SKIP(1)
     seg_nrcpfcgc AT  4 FORMAT "x(18)"           LABEL "CPF/CNPJ"
                        HELP "Entre com o CPF do segurado."
     SKIP(1)
     seg_dtnascsg AT 2  FORMAT "99/99/9999"       LABEL "Nascimento"
     seg_cdsexosg AT 28 FORMAT "9"                LABEL "Sexo"
                        HELP "Informe 1-Masculino 2-Feminino"
                            
     WITH ROW 10 CENTERED SIDE-LABELS NO-LABELS OVERLAY FRAME f_seguro_1.

FORM seg_dtinivig AT  3 FORMAT "99/99/9999" LABEL "Vigencia: Inicio"
                        HELP "Entre com a data de inicio da vigencia do seguro."
     seg_dtfimvig AT 43 FORMAT "99/99/9999" LABEL "Final"
                        HELP "Entre com a data final da vigencia do seguro." " "
     SKIP(1)
     seg_vlpreseg AT  3 FORMAT "zzz,zz9.99" LABEL "Valor da Parcela"
                        HELP "Entre com o valor da parcela mensal/unica."

     seg_ddvencto AT 36 FORMAT "99" LABEL "Dia do Debito Mensal"
                        HELP "Entre com o dia do debito mensal."
     SKIP(1)
     seg_cdcalcul AT  3 FORMAT "zzzzz,zz9" LABEL "Codigo de Calculo"
                        HELP "Entre com o codigo do calculo."
                        VALIDATE(seg_cdcalcul > 0,
                                 "375 - O campo deve ser preenchido.")

     seg_tpplaseg AT 39 FORMAT "999" LABEL "Plano contratado"
                        HELP "Entre com o codigo do plano contratado."
                        VALIDATE(seg_tpplaseg > 0,
                                 "375 - O campo deve ser preenchido.")
     SKIP(1)
     seg_vlseguro AT 24 FORMAT "zzz,zzz,zz9.99"
                        LABEL "Importancia segurada"
                        HELP "Entre com a importancia segurada."
     SKIP
     seg_vldfranq AT 36 FORMAT "zzz,zzz,zz9.99" LABEL "Franquia"
                        HELP "Entre com o valor da franquia."
     WITH ROW 10 CENTERED SIDE-LABELS NO-LABELS OVERLAY FRAME f_seguro_casa.

FORM SKIP(1)
     seg_nmbenefi AT 10  LABEL "Beneficiario"  FORMAT "x(40)"
                         HELP "Entre com o nome do beneficiario."
     SKIP
     seg_vlbenefi AT  4  LABEL "Valor do Beneficio"  FORMAT "zzz,zzz,zz9.99"
                         HELP "Entre com o valor do beneficio."
     SKIP(1)
     "Endereco Residencial/Local do Risco:"  AT 3
     SKIP(1)
     seg_dsendres FORMAT "x(57)" LABEL "Rua"  AT 03
                        HELP "Entre com o endereco residencial/local do risco."
                        VALIDATE(TRIM(seg_dsendres) <> "",
                                 "375 - O campo deve ser preenchido.")
     seg_nrfonres AT 03  LABEL "Tel."  FORMAT "x(20)"
                  HELP "Entre com o telefone residencial."
     seg_nmbairro AT 32  LABEL "Bairro" FORMAT "x(20)"
                  HELP "Entre com o nome do bairro."
                  VALIDATE(TRIM(seg_nmbairro) <> "",
                           "375 - O campo deve ser preenchido.")
     seg_nmcidade AT 03  LABEL "Cidade" FORMAT "x(25)"
                  HELP "Entre com o nome da cidade."
                  VALIDATE(TRIM(seg_nmcidade) <> "",
                           "375 - O campo deve ser preenchido.")
     seg_cdufresd AT 45  LABEL "U.F." FORMAT "!!"
                  HELP "Entre com a Unidade da Federacao."
     seg_nrcepend AT 56  LABEL "CEP"  FORMAT "99,999,999"
                  HELP "Entre com o CEP do endereco."
     SKIP(1)
     WITH ROW 8 CENTERED SIDE-LABELS NO-LABELS OVERLAY FRAME f_seguro_casa_2.
 
FORM SKIP(1)
     "Imovel:"    AT 03
     SKIP(1)
     seg_flgapant LABEL "Casa/Apartamento" AT 05 FORMAT "Casa/Apartamento"
     seg_flgassis LABEL "Terreo/Andar Superior" AT 40
                  FORMAT "Terreo/Andar Superior"
     SKIP
     seg_flgcurso LABEL "Proprio/Alugado" AT 06 FORMAT "Proprio/Alugado"
     seg_flgdnovo LABEL "Alvenaria/Madeira ou Mista" AT 35 
                  FORMAT "Alvenaria/Madeira ou Mista"
     SKIP
     seg_flgnotaf LABEL "Veraneio/Habitual" AT 04 FORMAT "Veraneio/Habitual"
     SKIP(1)
     "Cobertura do Seguro:" AT 03
     SKIP(1)
     seg_flgrenov LABEL "Conteudo (Sim/Nao)" AT 05  FORMAT "Sim/Nao"
     seg_flgrepgr LABEL "Predio (Sim/Nao)" AT 45  FORMAT "Sim/Nao"
     SKIP(1)
     WITH ROW 5 CENTERED SIDE-LABELS NO-LABELS OVERLAY FRAME f_seguro_casa_3.


FORM seg_tpplaseg LABEL "Plano contrato"  FORMAT "zz9"                AT 30
     SKIP
     "Garantias"                                                      AT 02
     "Valores Segurados "                                             AT 59
     SKIP(1)
     "Incendio, explosao (qualquer causa), raio e tumultos"           AT 02
     tel_vldesmor             FORMAT "zz,zzz,zz9.99"                  AT 63
     "Roubo ou furto resid. de objetos pessoais ou domesticos"        AT 02
     tel_vlroubop             FORMAT "zz,zzz,zz9.99"                  AT 63
     "Roubo ou furto resid. de aparelhos eletronicos"                 AT 02
     tel_vlrouboe             FORMAT "zz,zzz,zz9.99"                  AT 63
     "Vento forte, granizo, fumaca e colisao de veiculos"             AT 02
     tel_vldvento             FORMAT "zz,zzz,zz9.99"                  AT 63
     "Quebra de vidro"                                                AT 02
     tel_vlvidros             FORMAT "zz,zzz,zz9.99"                  AT 63
     "Danos eletricos"                                                AT 02
     tel_vldanele             FORMAT "zz,zzz,zz9.99"                  AT 63
     "Diarias de indisponibilidade e despesas com mudanca"            AT 02
     tel_vldiaria             FORMAT "zz,zzz,zz9.99"                  AT 63
     "Roubo ou furto qualificado em residencias de veraneio"          AT 02
     tel_vlrouboq             FORMAT "zz,zzz,zz9.99"                  AT 63
     "Responsabilidade civil familiar"                                AT 02
     tel_vldrcfam             FORMAT "zz,zzz,zz9.99"                  AT 63
     "Acidentes pessoais"                                             AT 02
     tel_vlacipes             FORMAT "zz,zzz,zz9.99"                  AT 63
     "Valor da cobertura do seguro"                                   AT 02
     tel_vlmorada             FORMAT "zz,zzz,zz9.99"                  AT 63
     WITH ROW 5 CENTERED SIDE-LABELS NO-LABELS OVERLAY FRAME f_seguro_casa_4.
                      
FORM SKIP(1)
     seg_dtcancel AT  5 FORMAT "99/99/9999"      LABEL "Cancelado em"
     SKIP(1)
     seg_dtinivig AT  5 FORMAT "99/99/9999" LABEL "Inicio da vigencia"
                        HELP "Entre com a data de inicio da vigencia do seguro."
     SKIP(1)
     seg_ddvencto AT  5 FORMAT "99" LABEL "Dia do Debito Mensal"
                        HELP "Entre com o dia do debito mensal."
     SKIP(1)
     seg_vlpreseg AT  5 FORMAT "zzz,zzz,zz9.99       " LABEL "Valor da Premio"
                        HELP "Entre com o valor da premio."
     SKIP(1)
     WITH ROW 08 CENTERED SIDE-LABELS NO-LABELS OVERLAY FRAME f_seguro_casa_5.


FORM SKIP(1) " "
     seg_nrctrseg LABEL "Confirme o codigo do Calculo/Proposta" FORMAT "zzz,zz9"
                  VALIDATE(seg_nrctrseg > 0,
                           "375 - O campo deve ser preenchido.")
     " " SKIP(1)
     WITH ROW 12 CENTERED SIDE-LABELS OVERLAY FRAME f_conf_proposta.

FORM SKIP(1)
     seg_nmdsegur AT 11 FORMAT "x(40)"           LABEL "Segurado"
     seg_vlpreseg AT  4 FORMAT "zzz,zzz,zz9.99"  LABEL "Valor do Premio"
     tel_dtinivig AT 46 FORMAT "99/99/9999"      LABEL "Inicio da Vigencia"
     SKIP
     tel_vlcapseg AT  3 FORMAT "zzz,zzz,zz9.99"  LABEL "Capital segurado"
     tel_dtfimvig AT 49 FORMAT "99/99/9999"      LABEL "Fim da Vigencia"
     SKIP
     tel_qtpreseg AT  2 FORMAT "           zz9"  LABEL "Qtd. Prest. Pagas"
     tel_dtcancel AT 52 FORMAT "99/99/9999"      LABEL "Cancelado em"
     SKIP
     tel_vlprepag AT  9 FORMAT "zzz,zzz,zz9.99"  LABEL "Total Pago"
     tel_dtdebito AT 50 FORMAT "99/99/9999"      LABEL "Proximo Debito"
     SKIP
     tel_dscobert AT 10 FORMAT "x(037)"          LABEL "Cobertura"
     seg_tpplaseg       FORMAT "999"             LABEL "Plano"
     SKIP(1)
     "Beneficiarios "  AT 2
     "Parentesco                % Part" AT 43
     tel_nmbenefi[1]  AT 2                       NO-LABEL
     tel_dsgraupr[1]  AT 43                      NO-LABEL
     tel_txpartic[1]                             NO-LABEL
     SKIP
     tel_nmbenefi[2]  AT 2                       NO-LABEL
     tel_dsgraupr[2]  AT 43                      NO-LABEL
     tel_txpartic[2]                             NO-LABEL
     SKIP
     tel_nmbenefi[3]  AT 2                       NO-LABEL
     tel_dsgraupr[3]  AT 43                      NO-LABEL
     tel_txpartic[3]                             NO-LABEL
     SKIP
     tel_nmbenefi[4]  AT 2                       NO-LABEL
     tel_dsgraupr[4]  AT 43                      NO-LABEL
     tel_txpartic[4]                             NO-LABEL
     SKIP
     tel_nmbenefi[5]  AT 2                       NO-LABEL
     tel_dsgraupr[5]  AT 43                      NO-LABEL
     tel_txpartic[5]                             NO-LABEL
     SKIP(1)
     tel_dspesseg AT  2 FORMAT "x(27)"           LABEL "Pesquisa"
     tel_dssitseg AT 43 FORMAT "x(10)"           LABEL "Situacao"
     tel_dsevento AT 68 FORMAT "x(8)"            NO-LABEL
     HELP "Tecle <Entra> para CANCELAR o seguro ou <FIM> para retornar."
     WITH ROW 4 CENTERED SIDE-LABELS NO-LABELS OVERLAY TITLE COLOR NORMAL
          tel_dsseguro WIDTH 78 FRAME f_seguro_3.


FORM SKIP(1)
     seg_nmdsegur AT 11 FORMAT "x(40)"           LABEL "Segurado"
     seg_vlpreseg AT  4 FORMAT "zzz,zzz,zz9.99"  LABEL "Valor do Premio"
     tel_dtinivig AT 46 FORMAT "99/99/9999"      LABEL "Inicio da Vigencia"
     SKIP
     tel_vlcapseg AT  3 FORMAT "zzz,zzz,zz9.99"  LABEL "Capital segurado"
     tel_dtfimvig AT 49 FORMAT "99/99/9999"      LABEL "Fim da Vigencia"
     SKIP
     tel_qtpreseg AT  2 FORMAT "           zz9"  LABEL "Qtd. Prest. Pagas"
     tel_dtcancel AT 52 FORMAT "99/99/9999"      LABEL "Cancelado em"
     SKIP
     tel_vlprepag AT  9 FORMAT "zzz,zzz,zz9.99"  LABEL "Total Pago"
     seg_ddvencto AT 44 FORMAT "99"              LABEL "Dia Proximos Debitos"  
                         HELP "Informe o dia do debito das parcelas mensais"
                         VALIDATE( seg_ddvencto > 0 AND seg_ddvencto < 29,
                                     "Data invalida, permitido ate o dia 28!")
     SKIP
     tel_dscobert AT 10 FORMAT "x(037)"          LABEL "Cobertura"
     seg_tpplaseg       FORMAT "999"             LABEL "Plano"
     SKIP(1)
     "Beneficiarios "  AT 2
     "Parentesco                % Part" AT 43
     tel_nmbenefi[1]  AT 2                       NO-LABEL
     tel_dsgraupr[1]  AT 43                      NO-LABEL
     tel_txpartic[1]                             NO-LABEL
     SKIP
     tel_nmbenefi[2]  AT 2                       NO-LABEL
     tel_dsgraupr[2]  AT 43                      NO-LABEL
     tel_txpartic[2]                             NO-LABEL
     SKIP
     tel_nmbenefi[3]  AT 2                       NO-LABEL
     tel_dsgraupr[3]  AT 43                      NO-LABEL
     tel_txpartic[3]                             NO-LABEL
     SKIP
     tel_nmbenefi[4]  AT 2                       NO-LABEL
     tel_dsgraupr[4]  AT 43                      NO-LABEL
     tel_txpartic[4]                             NO-LABEL
     SKIP
     tel_nmbenefi[5]  AT 2                       NO-LABEL
     tel_dsgraupr[5]  AT 43                      NO-LABEL
     tel_txpartic[5]                             NO-LABEL
     SKIP(1)
     tel_dspesseg AT  2 FORMAT "x(27)"           LABEL "Pesquisa"
     tel_dssitseg AT 43 FORMAT "x(10)"           LABEL "Situacao"
     tel_dsevento AT 68 FORMAT "x(8)"            NO-LABEL
     HELP "Tecle <Entra> para CANCELAR o seguro ou <FIM> para retornar."
     WITH ROW 4 CENTERED SIDE-LABELS NO-LABELS OVERLAY TITLE COLOR NORMAL
          tel_dsseguro WIDTH 78 FRAME f_seguro_3_i.


/* .......................................................................... */
