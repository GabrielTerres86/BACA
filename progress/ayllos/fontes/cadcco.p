/* .............................................................................

   Programa: Fontes/cadcco.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Marco/2006                           Ultima alteracao: 24/03/2016
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : CADCCO -  Cadastro Parametros Sistema de Cobranca.
   
   Alteracoes: 28/03/2006 - Acrescentado ON RETURN no browse para Consulta
                            (Diego).
               
               21/06/2006 - Alterado a opcao A para somente mostrar o campo
                            Nr.Bloqueto (David).
                            
               08/08/2006 - Acrescentar campo Convenio CECRED (Ze).
                            
               28/08/2006 - Alterado Help dos campos da tela (Elton).
               
               16/10/2006 - Incluido campos flgativo e flginter (David).
               
               30/10/2006 - Incluida validacao para campo dsorgarq nas opcoes
                            "A" e "I" (David).
                            
               20/12/2006 - Incluidos campos tel_cdtarcxa e tel_vlrtarcx, e 
                            modificados alguns Help's (Diego).

               08/08/2007 - Incluidos campos tel_cdtarnet e tel_vlrtarnt
                            (Guilherme).

               05/09/2007 - Incluidas criticas para os campos referentes aos 
                            historicos das tarifas (Elton).

               14/05/2008 - Incluido campo Nr.Var.Carteira (crapcco.nrvarcar) 
                            (Gabriel).

               30/06/2008 - Incluida a chave de acesso 
                            (craphis.cdcooper = glb_cdcooper)
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

               06/02/2009 - Alterado o layout da tela (Gabriel).

               26/02/2009 - Permitir somente operador 997 ou 1 nas
                            opcoes A,I,E.   (Fernando).

               13/05/2009 - Acerto de Tela (Ze).

               22/05/2009 - Alteracao CDOPERAD (Kbase).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               16/06/2010 - Incluido campos de tarifa e historico de TAA
                            (Elton).

               16/09/2010 - Incluido campo "Utiliza CoopCob" na tela
                            (Guilherme/Supero).
                            
               14/10/2010 - Feito correcao do campo diretorio. Quando 
                            CoopCob for = "SIM", sera obrigatorio informar
                            um diretorio.             
                            
               12/11/2010 - Criado log das transações (Adriano).  
               
               17/03/2011 - Inserido campo Cobranca Registrada e tela para 
                            manutencao das tarifas de cobranca (Henrique).
                          - Alterada validacao no momento de inclusao de
                            um novo convenio (Henrique).    
                            
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano).
                            
               29/04/2011 - Acrescentado o indice cddbanco nas clausulas do
                            FIND na crapoco.
                            RETURN apos a chamada da proc_display no modo
                            Consulta, caso LASTKEY = "END-ERROR".
                            Comentado MESSAGE ao final da opcao de Consulta. 
                            Inclusao do campo cdcartei e do item "PROTESTO"
                            no ListBox tel_dsorgarq.(Fabricio)
             
               01/06/2011 - Realizado ordenacao da temp-table tt-crapcct;
                            por tipo de ocorrencia e codigo da ocorrencia.
                            (Fabricio)
                            
               02/06/2011 - Controle para nao excluir um convenio que possui
                            boleto(s) associado(s).
                            Controle para nao realizar alteracao nos campos
                            tel_flgativo, tel_dsorgarq, tel_nrcontab,
                            tel_flgregis, tel_cddbanco; quando houver boleto(s)
                            ativo(s) para o convenio. (Fabricio)
                            
               16/06/2011 - Tanto na inclusao quanto na alteracao, se a origem
                            do arquivo for 'PROTESTO', tambem seta a flginter
                            para TRUE. (Fabricio)
                            
               22/06/2011 - Alterado FIND FIRST no crabcco tanto para alteracao
                            quanto para inclusao, para verificar se ja existe
                            outro convenio para internet. Na inclusao, incluido
                            filtro por codigo do banco e origem do arquivo =
                            'INTERNET'. Na alteracao, incluido filtro por origem
                            do arquivo(INTERNET). (Fabricio)
                            
               07/07/2011 - UPDATE dos campos tel_vlrtarif e tel_cdtarhis
                            apenas quando nao for cobranca registrada.
                            Filtrado na crapoco para alimentar a temp-table
                            tt-crapcct apenas quando o campo flgativo = TRUE.
                            (Fabricio)
                            
               10/10/2011 - Inserida tela com motivos de cada operacao (Henrique).
               
               02/05/2013 - Projeto Melhorias da Cobranca - convenio tipo
                            'IMPRESSO PELO SOFTWARE' é visivel no InternetBank
                            (flginter = true). (Rafael)
               
               28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
               
               29/11/2013 - Inclusao de VALIDATE crapcct e crapcco (Carlos)
               
               16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)
               
               08/08/2014 - Incluir novo campo "Float", no formato list-box 
                            e com valores de 0 a 5. Tabela: CRAPCCO
                            Campo: QTDFLOAT  (Renato - Supero)
                            
               03/11/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               12/03/2015 - Quando o nome do convênio for "MIGRACAO" ou "INCORPORACAO"
                            não sera mais possivel a alteração do campo dsorgarq.                            
                            (SD 263959 - Carlos Rafael Tanholi)
                           
               14/08/2015 - Alterado para tratar convenio de emprestimos. (Reinert) 

               23/11/2015 - Inclusao do indicador de negativacao pelo Serasa.
                            (Jaison/Andrino)

               
               24/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).
............................................................................. */

{ includes/var_online.i }

DEF TEMP-TABLE tt-crapcct NO-UNDO
    FIELD cdcooper LIKE crapcct.cdcooper
    FIELD cddbanco LIKE crapcct.cddbanco
    FIELD nrconven LIKE crapcct.nrconven
    FIELD cdocorre LIKE crapcct.cdocorre
    FIELD dsocorre LIKE crapoco.dsocorre
    FIELD axocorre AS CHAR FORMAT "x(3)"
    FIELD tpocorre LIKE crapcct.tpocorre
    FIELD vltarifa LIKE crapcct.vltarifa
    FIELD cdtarhis LIKE crapcct.cdtarhis
    FIELD flatuali AS LOGI.

DEF TEMP-TABLE tt-crapmot NO-UNDO
    FIELD cdmotivo LIKE crapmot.cdmotivo
    FIELD dsmotivo LIKE crapmot.dsmotivo
    FIELD vltarifa LIKE crapctm.vltarifa
    FIELD cdtarhis LIKE crapctm.cdtarhis
    FIELD flatuali AS   LOGICAL
    FIELD nrdrowid AS   ROWID. 
        
DEF        VAR tel_cddbanco LIKE crapcco.cddbanco                    NO-UNDO.
DEF        VAR tel_nrconven LIKE crapcco.nrconven                    NO-UNDO.
DEF        VAR tel_nrcontab LIKE crapcco.nrdctabb                    NO-UNDO.
DEF        VAR tel_nrvarcar LIKE crapcco.nrvarcar                    NO-UNDO.
DEF        VAR tel_cdcartei LIKE crapcco.cdcartei                    NO-UNDO.
DEF        VAR tel_cdagenci AS INT                                   NO-UNDO.
DEF        VAR tel_cdbccxlt AS INT                                   NO-UNDO.
DEF        VAR tel_nrdolote AS INT                                   NO-UNDO.
DEF        VAR tel_cdhistor AS INT                                   NO-UNDO.
DEF        VAR tel_vlrtarif AS DECI FORMAT ">>>,>>9.99"              NO-UNDO.
DEF        VAR tel_cdtarhis AS INT                                   NO-UNDO.
DEF        VAR tel_cdtarcxa AS INT                                   NO-UNDO.
DEF        VAR tel_vlrtarcx AS DECI FORMAT ">>>,>>9.99"              NO-UNDO.
DEF        VAR tel_cdtarnet AS INT                                   NO-UNDO.
DEF        VAR tel_vlrtarnt AS DECI FORMAT ">>>,>>9.99"              NO-UNDO.
DEF        VAR tel_cdhistaa AS INTE                                  NO-UNDO.
DEF        VAR tel_vltrftaa AS DECI FORMAT ">>>,>>9.99"              NO-UNDO.
DEF        VAR tel_nrlotblq AS INT                                   NO-UNDO.
DEF        VAR tel_cdhisblq AS INT                                   NO-UNDO.
DEF        VAR tel_vlrtrblq AS DECI FORMAT ">>>,>>9.99"              NO-UNDO.
DEF        VAR tel_nrbloque LIKE crapcco.nrbloque                    NO-UNDO.
DEF        VAR tel_flgregis AS LOGI FORMAT "SIM/NAO"                 NO-UNDO.
DEF        VAR tel_dsorgarq AS CHAR FORMAT "x(23)"
               VIEW-AS COMBO-BOX LIST-ITEMS "IMPRESSO PELO SOFTWARE",
                                            "PRE-IMPRESSO",
                                            "INTERNET",
                                            "PROTESTO",
                                            "EMPRESTIMO"
                                            PFCOLOR 2                NO-UNDO.
DEF        VAR tel_qtdfloat AS CHAR FORMAT "x(8)"
               VIEW-AS COMBO-BOX LIST-ITEM-PAIRS "0 dia" ,0,
                                                 "1 dia" ,1,
                                                 "2 dias",2,
                                                 "3 dias",3,
                                                 "4 dias",4,
                                                 "5 dias",5
                                            PFCOLOR 2                NO-UNDO.
DEF        VAR tel_tamannro LIKE crapcco.tamannro                    NO-UNDO.
DEF        VAR tel_nmdireto AS CHAR FORMAT "x(36)"                   NO-UNDO.
DEF        VAR tel_dtmvtolt LIKE crapcco.dtmvtolt                    NO-UNDO.
DEF        VAR tel_nmresbcc AS CHAR FORMAT "x(18)"                   NO-UNDO.
DEF        VAR tel_nmarquiv AS CHAR FORMAT "x(37)"                   NO-UNDO.
DEF        VAR tel_cdoperad AS CHAR FORMAT "x(10)"                   NO-UNDO.
DEF        VAR tel_nmoperad AS CHAR FORMAT "x(23)"                   NO-UNDO.
DEF        VAR tel_flgcnvcc AS LOGICAL
                               FORMAT "SIM/NAO"                      NO-UNDO.
DEF        VAR tel_flgativo AS LOGICAL
                               FORMAT "ATIVO/INATIVO"                NO-UNDO.
DEF        VAR tel_flcopcob AS LOGICAL
                               FORMAT "SIM/NAO"                      NO-UNDO.
DEF        VAR tel_flserasa AS LOGICAL
                               FORMAT "SIM/NAO"                      NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_flgdesat AS LOGICAL                               NO-UNDO.
DEF        VAR aux_tipdcond AS CHAR                                  NO-UNDO.
DEF        VAR aux_qtdfloat AS INT                                   NO-UNDO.

DEF        VAR log_cddbanco LIKE crapcco.cddbanco                    NO-UNDO.  
DEF        VAR log_nmdbanco LIKE crapcco.nmdbanco                    NO-UNDO.   
DEF        VAR log_nrdctabb LIKE crapcco.nrdctabb                    NO-UNDO.
DEF        VAR log_cdbccxlt LIKE crapcco.cdbccxlt                    NO-UNDO.
DEF        VAR log_cdagenci LIKE crapcco.cdagenci                    NO-UNDO.   
DEF        VAR log_nrdolote LIKE crapcco.nrdolote                    NO-UNDO.
DEF        VAR log_cdhistor LIKE crapcco.cdhistor                    NO-UNDO.
DEF        VAR log_vlrtarif AS DECI FORMAT ">>>,>>9.99"              NO-UNDO.
DEF        VAR log_cdtarhis LIKE crapcco.cdtarhis                    NO-UNDO.
DEF        VAR log_cdhiscxa LIKE crapcco.cdhiscxa                    NO-UNDO.
DEF        VAR log_vlrtarcx AS DECI FORMAT ">>>,>>9.99"              NO-UNDO.
DEF        VAR log_cdhisnet LIKE crapcco.cdhisnet                    NO-UNDO.
DEF        VAR log_vlrtarnt AS DECI FORMAT ">>>,>>9.99"              NO-UNDO.
DEF        VAR log_cdhistaa LIKE crapcco.cdhistaa                    NO-UNDO. 
DEF        VAR log_vltrftaa AS DECI FORMAT ">>>,>>9.99"              NO-UNDO.
DEF        VAR log_nrlotblq LIKE crapcco.nrlotblq                    NO-UNDO.
DEF        VAR log_vlrtrblq AS DECI FORMAT ">>>,>>9.99"              NO-UNDO.
DEF        VAR log_nrvarcar LIKE crapcco.nrvarcar                    NO-UNDO.
DEF        VAR log_cdcartei LIKE crapcco.cdcartei                    NO-UNDO.
DEF        VAR log_cdhisblq LIKE crapcco.cdhisblq                    NO-UNDO.
DEF        VAR log_nrbloque LIKE crapcco.nrbloque                    NO-UNDO.
DEF        VAR log_dsorgarq LIKE crapcco.dsorgarq                    NO-UNDO.
DEF        VAR log_tamannro LIKE crapcco.tamannro                    NO-UNDO.
DEF        VAR log_nmdireto LIKE crapcco.nmdireto                    NO-UNDO.
DEF        VAR log_nmarquiv LIKE crapcco.nmarquiv                    NO-UNDO.
DEF        VAR log_flgutceb LIKE crapcco.flgutceb                    NO-UNDO.
DEF        VAR log_flcopcob LIKE crapcco.flcopcob                    NO-UNDO.
DEF        VAR log_flgativo LIKE crapcco.flgativo                    NO-UNDO.
DEF        VAR log_dtmvtolt LIKE crapcco.dtmvtolt                    NO-UNDO.
DEF        VAR log_qtdfloat AS CHAR                    NO-UNDO.
DEF        VAR log_cdoperad LIKE glb_cdoperad                        NO-UNDO.
DEF        VAR log_flginter LIKE crapcco.flginter                    NO-UNDO.
DEF        VAR log_flgregis LIKE crapcco.flgregis                    NO-UNDO.

DEF        VAR aux_tpocorre AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgregis AS LOGI                                  NO-UNDO.

DEF BUFFER crabcco    FOR crapcco.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

DEF QUERY q_crapcco   FOR crapcco.
DEF QUERY q_crapcct   FOR tt-crapcct.
DEF QUERY q_crapmot   FOR tt-crapmot.

DEF BROWSE b_crapmot QUERY q_crapmot
    DISPLAY tt-crapmot.cdmotivo COLUMN-LABEL "Cod."        FORMAT "x(3)"  
            tt-crapmot.dsmotivo COLUMN-LABEL "Motivos"     FORMAT "x(50)"
            tt-crapmot.vltarifa COLUMN-LABEL "Valor"       FORMAT "z9.99"
            tt-crapmot.cdtarhis COLUMN-LABEL "Historico"   FORMAT " zzz9"
            WITH 8 DOWN OVERLAY.                           

DEF BROWSE b_crapcco  QUERY q_crapcco 
    DISPLAY crapcco.nrconven  COLUMN-LABEL "Convenio" 
            crapcco.nrdctabb  COLUMN-LABEL "Conta Base"
            crapcco.cddbanco  COLUMN-LABEL "Banco"
            crapcco.flgativo  COLUMN-LABEL "Situacao" FORMAT "ATIVO/INATIVO"
            crapcco.dsorgarq  COLUMN-LABEL "Origem" FORMAT "x(23)"
            WITH 8 DOWN OVERLAY.         
                      
DEF BROWSE b_crapcct QUERY q_crapcct
    DISP tt-crapcct.cdocorre    COLUMN-LABEL "Cod."       FORMAT "zz9"   
         tt-crapcct.dsocorre    COLUMN-LABEL "Descricao"  FORMAT "x(46)" 
         tt-crapcct.axocorre    COLUMN-LABEL "Tipo"       FORMAT " x(3)" 
         tt-crapcct.vltarifa    COLUMN-LABEL "Valor"      FORMAT "z9.99" 
         tt-crapcct.cdtarhis    COLUMN-LABEL "Historico"  FORMAT " zzz9" 
    WITH 10 DOWN NO-BOX.

FORM SPACE(3) tt-crapcct.cdocorre NO-LABEL 
          "-" tt-crapcct.dsocorre NO-LABEL 
     SKIP
     b_crapmot HELP "Tecle ENTER para atualizar um valor ou F4 para sair"
     SKIP
     WITH ROW 6 COLUMN 2 OVERLAY CENTERED FRAME f_cadmot.

FORM b_crapcct HELP "Tecle <M> para os Motivos da Ocorrencia"
     SKIP
     WITH ROW 7 COLUMN 2 OVERLAY CENTERED FRAME f_cadcco_dda.

FORM b_crapcco  HELP "Use as SETAS para navegar ou F4 para sair"
     SKIP
     WITH NO-BOX ROW 7 COLUMN 2 OVERLAY CENTERED FRAME f_crapcco_b.

FORM SKIP(1)
     glb_cddopcao  AT 05  LABEL "Opcao" AUTO-RETURN FORMAT "!"
        HELP "Entre com a opcao desejada (A,C,E,I)."
        VALIDATE(CAN-DO("A,C,E,I",glb_cddopcao),"014 - Opcao errada.")
  
     tel_nrconven  AT 39  LABEL "Convenio"
        HELP "Informe o numero do convenio ou  <F7>  para listar."
        VALIDATE(tel_nrconven > 0,"563 - Convenio nao cadastrado.") 
     SKIP(14)
     WITH WIDTH 80 ROW 4 SIDE-LABELS TITLE glb_tldatela FRAME f_opcao.
     
FORM tel_flgativo  AT 06  LABEL "Situacao"
        HELP "Informe 'A' para convenio Ativo ou 'I' para Inativo."
     
     tel_dsorgarq  AT 41  LABEL "Origem"  AUTO-RETURN
        HELP "Informe a origem de impressao do boleto."
     SKIP(1)
     tel_nrcontab  AT 04  LABEL "Conta Base"
        HELP "Informe o numero da conta base."
        VALIDATE (tel_nrcontab > 0, "127 - Conta errada.") 
     tel_flgregis   AT 41  LABEL "Cobranca Registrada"
     SKIP(1)              
     tel_cddbanco  AT 09  LABEL "Banco" FORMAT "z,zz9"
        HELP "Informe o numero do banco."
        VALIDATE(tel_cddbanco > 0 AND
                 CAN-FIND(crapban WHERE crapban.cdbccxlt = tel_cddbanco), 
                 "057 - Banco nao cadastrado.")
     tel_nmresbcc  AT 22  NO-LABEL
     
     tel_cdbccxlt  AT 42  LABEL "Bco/Caixa"  FORMAT "zz9"
        HELP "Informe o numero do Banco/Caixa."
        VALIDATE(tel_cdbccxlt > 0 AND
                 CAN-FIND(crapbcl WHERE crapbcl.cdbccxlt = tel_cdbccxlt),
                 "057 - Banco nao cadastrado.")
     
     tel_cdagenci  AT 69  LABEL "PA" FORMAT "zz9"
         HELP "Informe o numero do PA."
         VALIDATE (CAN-FIND (crapage WHERE crapage.cdcooper = glb_cdcooper AND 
                                           crapage.cdagenci = tel_cdagenci),
                                       "962 - PA nao cadastrado.")
     SKIP(1)
     tel_nrdolote  AT 10  LABEL "Lote" FORMAT "zzz,zz9"
         HELP "Informe o numero do lote."
         VALIDATE(tel_nrdolote > 0, "058 - Numero do lote errado.")
     
     tel_cdhistor  AT 28  LABEL "Historico Cobranca" FORMAT "zzz9"
         HELP "Informe o historico."
         VALIDATE(tel_cdhistor > 0 AND 
                  CAN-FIND(craphis WHERE craphis.cdcooper = glb_cdcooper AND 
                                         craphis.cdhistor = tel_cdhistor),
                                         "093 - Historico errado.")

     tel_flserasa  AT 57  LABEL "Integra Serasa"
         HELP  "Informe 'S' para integrar Serasa ou 'N' para Nao."

     SKIP(1)
     tel_nmarquiv  AT 07  LABEL "Arquivo"
         HELP  "Informe o nome do arquivo de retorno do Banco do Brasil."
         VALIDATE(tel_nmarquiv <> "", "182 - Arquivo nao existe.")

     tel_flcopcob  AT 56  LABEL "Utiliza CoopCob"
         HELP  "Informe 'S' para utilizacao do sistema CoopCob ou 'N' para Nao."
     
     SKIP(1)    
     tel_nmdireto  AT 05  LABEL "Diretorio"
         HELP  "Informe o diretorio onde sera integrado o arquivo de cobranca."
                 
     tel_qtdfloat  AT 53  LABEL "Float" AUTO-RETURN
         HELP "Informe a quantidade de dias de Float."
         
    SKIP(1)
     tel_nrbloque  AT 05  LABEL "Nr.Boleto"
         HELP  "Informe o numero do boleto."
 
     tel_flgcnvcc  AT 31  LABEL "Identifica Sequencia"
         HELP  "Informe 'S' para convenio com 7 digitos ou 'N' para 6 digitos."

     tel_tamannro  AT 60  LABEL "Tamanho Nro."
         HELP  "Informe a qtd de nros utilizados no campo 'Nosso numero'."
     
     WITH CENTERED WIDTH 78 ROW 7 SIDE-LABELS OVERLAY FRAME f_cadcco_1.


FORM tel_cdcartei AT 04  LABEL "Nro. Carteira/Variacao"
         HELP "Informe o numero e a variacao de carteira de cobranca."
     "/" AT 30
     tel_nrvarcar FORMAT "zz9" AT 31
     tel_nrlotblq   AT 43  LABEL "Lote Tarifa Impres.Boleto" FORMAT "zzz,zz9"
         HELP "Informe o numero do lote para tarifa de boletos."
         VALIDATE (tel_nrlotblq > 0, "058 - Numero do lote errado.")
     SKIP(1)  
     tel_vlrtarif  AT 11  LABEL "Valor Tarifa Cobranca" 
         HELP "Informe o valor da tarifa de cobranca."
      
     tel_cdtarhis  AT 50  LABEL "Hist. Tarifa Cobranca"  FORMAT "zzz9"
         HELP "Informe o historico da tarifa de cobranca."
         VALIDATE (tel_cdtarhis > 0 AND
                   CAN-FIND(craphis WHERE craphis.cdcooper = glb_cdcooper AND
                                          craphis.cdhistor = tel_cdtarhis),
                   "093 - Historico errado."  )
     SKIP(1)
     tel_vlrtarcx  AT 07  LABEL "Vlr.Tarifa Bol. pago Coop"

     tel_cdtarcxa  AT 45  LABEL "Hist.Tarifa Bol. pago Coop"   FORMAT "zzz9"
         VALIDATE (tel_cdtarcxa > 0 AND
                   CAN-FIND(craphis WHERE craphis.cdcooper = glb_cdcooper AND
                                          craphis.cdhistor = tel_cdtarcxa),
                   "093 - Historico errado.")
     SKIP(1)
     tel_vlrtarnt  AT 06  LABEL "Vlr.Tarifa Bol. pago Inter"

     tel_cdtarnet  AT 45 LABEL "Hist.Tarifa Bol. pago Inte"   FORMAT "zzz9"
         VALIDATE (tel_cdtarnet > 0 AND
                   CAN-FIND(craphis WHERE craphis.cdcooper = glb_cdcooper AND
                                          craphis.cdhistor = tel_cdtarnet),
                   "093 - Historico errado.")
     SKIP(1)

    tel_vltrftaa  AT 08  LABEL "Vlr.Tarifa Bol. pago TAA"

    tel_cdhistaa  AT 46 LABEL "Hist.Tarifa Bol. pago TAA"   FORMAT "zzz9"
         VALIDATE (tel_cdhistaa > 0 AND
                   CAN-FIND(craphis WHERE craphis.cdcooper = glb_cdcooper AND
                                          craphis.cdhistor = tel_cdhistaa),
                   "093 - Historico errado.")
     SKIP(1)

     tel_vlrtrblq  AT 08  LABEL "Vlr. Tarifa Pre-Impresso"
         HELP "Informe o valor da tarifa de cobranca da impressao do boleto."
       
     tel_cdhisblq  AT 46  LABEL "Hist. Tarifa Pre-Impresso" FORMAT "zzz9"
         HELP "Informe o historico da tarifa da impressao do pre-impresso."
         VALIDATE (tel_cdhisblq > 0 AND
                   CAN-FIND(craphis WHERE craphis.cdcooper = glb_cdcooper AND
                                          craphis.cdhistor = tel_cdhisblq),
                   "093 - Historico errado.")
     SKIP(1)
     tel_dtmvtolt  AT 04  LABEL "Dt.Alteracao"
         HELP  "Informe a Data da Alteracao"

     " Operador: " AT 28  
     tel_cdoperad  FORMAT "x(10)" NO-LABEL
     "-" 
     tel_nmoperad  FORMAT "x(23)" NO-LABEL
     WITH NO-LABEL CENTERED WIDTH 78 ROW 7 OVERLAY SIDE-LABELS FRAME f_cadcco_2.

FORM "    Valor:" tt-crapcct.vltarifa      FORMAT "z9.99" 
     SKIP
     "Historico:" tt-crapcct.cdtarhis  FORMAT "zzz9"
     WITH NO-LABEL  CENTERED ROW 10 OVERLAY TITLE " Tarifas " FRAME f_tarifa.

FORM "    Valor:" tt-crapmot.vltarifa      FORMAT "z9.99" 
     SKIP
     "Historico:" tt-crapmot.cdtarhis  FORMAT "zzz9"
     WITH NO-LABEL  CENTERED ROW 10 OVERLAY TITLE " Tarifas " FRAME f_tarifa_mot.

/* Retorna Convenio */    
ON RETURN OF b_crapcco  DO:

   ASSIGN tel_nrconven = crapcco.nrconven.

   DISPLAY tel_nrconven WITH FRAME f_opcao.
       
   PAUSE 0. 

   APPLY "GO". 

END.

/* Atualizacao de tarifa e historico */
ON RETURN OF b_crapcct DO:

   IF  glb_cddopcao = "A" OR glb_cddopcao = "I" THEN
       DO:
           DO WHILE TRUE:

               UPDATE tt-crapcct.vltarifa 
                      tt-crapcct.cdtarhis
                      WITH FRAME f_tarifa. 

               IF  tt-crapcct.vltarifa > 0 THEN
                   DO:
                       IF  tt-crapcct.cdtarhis > 0 THEN
                           DO:
                                IF CAN-FIND(craphis 
                                   WHERE craphis.cdcooper = glb_cdcooper
                                     AND craphis.cdhistor = tt-crapcct.cdtarhis) 
                                   THEN
                                DO:
                                    ASSIGN tt-crapcct.flatuali = TRUE.
                                    LEAVE.
                                END.
                                ELSE
                                DO:
                                    MESSAGE "093 - Historico errado.".
                                    PAUSE 3 NO-MESSAGE.
                                    NEXT.
                                END.
                           END.
                       ELSE
                           DO:
                               MESSAGE "093 - Historico errado.".
                               PAUSE 3 NO-MESSAGE.
                               NEXT.
                           END.
                   END.
                ELSE
                   DO:
                       ASSIGN tt-crapcct.vltarifa = 0
                              tt-crapcct.cdtarhis = 0
                              tt-crapcct.flatuali = TRUE.
                       LEAVE.
                   END.
               
           END.
           b_crapcct:REFRESH().
         
       END.
END.

ON ANY-KEY OF b_crapcct DO:

    IF  CAPS(KEYFUNCTION(LASTKEY)) = "M" THEN
        DO:
            HIDE MESSAGE.    

            EMPTY TEMP-TABLE tt-crapmot.
            
            FOR EACH crapctm WHERE crapctm.cdcooper = tt-crapcct.cdcooper
                                             AND crapctm.cddbanco = tt-crapcct.cddbanco
                                             AND crapctm.nrconven = tt-crapcct.nrconven
                                             AND crapctm.cdocorre = tt-crapcct.cdocorre
                                             AND crapctm.tpocorre = 2,
                EACH crapmot WHERE crapmot.cdcooper = crapctm.cdcooper
                                             AND crapmot.cddbanco = crapctm.cddbanco
                                             AND crapmot.cdocorre = crapctm.cdocorre
                                             AND crapmot.tpocorre = crapctm.tpocorre
                                             AND crapmot.cdmotivo = crapctm.cdmotivo
                                             NO-LOCK BY crapctm.cdmotivo:
                
                CREATE tt-crapmot.
                ASSIGN tt-crapmot.cdmotivo = crapmot.cdmotivo
                       tt-crapmot.dsmotivo = crapmot.dsmotivo
                       tt-crapmot.vltarifa = crapctm.vltarifa
                       tt-crapmot.cdtarhis = crapctm.cdtarhis
                       tt-crapmot.flatuali = FALSE
                       tt-crapmot.nrdrowid = ROWID(crapctm).
                   
            END. /* FIM FOR EACH crapctm */
            
            FIND FIRST tt-crapmot NO-LOCK NO-ERROR.

            IF AVAIL tt-crapmot THEN
                DO:
                    DISP tt-crapcct.cdocorre 
                         tt-crapcct.dsocorre
                         WITH FRAME f_cadmot.
                    
                    OPEN QUERY q_crapmot FOR EACH tt-crapmot.
                            
                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        UPDATE b_crapmot WITH FRAME f_cadmot.
                        LEAVE.
                    END.    
                
                END.
            ELSE
                MESSAGE "Nao foram encontrados motivos para esta ocorrencia.".
        
                
            DO TRANSACTION:
                FOR EACH tt-crapmot WHERE tt-crapmot.flatuali = TRUE NO-LOCK:
                
                    FIND crapctm WHERE ROWID(crapctm) = tt-crapmot.nrdrowid
                                 EXCLUSIVE-LOCK NO-ERROR.
                
                    IF  AVAIL crapctm THEN
                        DO:
                            ASSIGN crapctm.vltarifa = tt-crapmot.vltarifa 
                                   crapctm.cdtarhis = tt-crapmot.cdtarhis.
                        END.
                    ELSE
                        DO:
                            IF  LOCKED crapctm THEN
                                MESSAGE "Registro sendo utilizado por outro usuário".
                            ELSE
                                MESSAGE "Erro ao atualizar!".
                            PAUSE 3 NO-MESSAGE.
                        END.
                END.
            END.
        END.
END.

ON RETURN OF b_crapmot DO:

   IF  glb_cddopcao = "A" OR glb_cddopcao = "I" THEN
       DO:
           DO WHILE TRUE:

               UPDATE tt-crapmot.vltarifa  
                      tt-crapmot.cdtarhis 
                      WITH FRAME f_tarifa_mot. 

               IF  tt-crapmot.vltarifa > 0 THEN
                   DO:
                       IF  tt-crapmot.cdtarhis > 0 THEN
                           DO:
                                IF CAN-FIND(craphis 
                                   WHERE craphis.cdcooper = glb_cdcooper
                                     AND craphis.cdhistor = tt-crapmot.cdtarhis) 
                                   THEN
                                DO:
                                    ASSIGN tt-crapmot.flatuali = TRUE.
                                    LEAVE.
                                END.
                                ELSE
                                DO:
                                    MESSAGE "093 - Historico errado.".
                                    PAUSE 3 NO-MESSAGE.
                                    NEXT.
                                END.
                           END.
                       ELSE
                           DO:
                               MESSAGE "093 - Historico errado.".
                               PAUSE 3 NO-MESSAGE.
                               NEXT.
                           END.
                   END.
                ELSE
                   DO:
                       ASSIGN tt-crapmot.vltarifa = 0
                              tt-crapmot.cdtarhis = 0
                              tt-crapmot.flatuali = TRUE.
                       LEAVE.
                   END.
               
           END.
           b_crapmot:REFRESH().
         
       END.
END.

ON LEAVE OF tel_cddbanco DO:
   
   FIND crapban WHERE crapban.cdbccxlt = INPUT tel_cddbanco NO-LOCK NO-ERROR.
   
   ASSIGN tel_nmresbcc = crapban.nmresbcc WHEN AVAILABLE crapban.
   
   IF INPUT tel_cddbanco <> 85 THEN
       HIDE tel_qtdfloat IN FRAME f_cadcco_1 NO-PAUSE.
   ELSE
       DISPLAY tel_qtdfloat WITH FRAME f_cadcco_1.

   DISPLAY tel_nmresbcc WITH FRAME f_cadcco_1.

END.
   
ON RETURN OF tel_dsorgarq DO:
   APPLY "TAB".
END.

ON RETURN OF tel_qtdfloat DO:
   APPLY "TAB".
END.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       aux_flgdesat = FALSE.
             
DO WHILE TRUE:

   HIDE MESSAGE NO-PAUSE.
   
   RUN fontes/inicia.p.
    
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_crapcco NO-PAUSE.
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao WITH FRAME f_opcao.
      
      IF   glb_cddopcao <> "C"      THEN
           IF   glb_dsdepart <> "TI"      AND
                glb_dsdepart <> "SUPORTE" AND 
                glb_dsdepart <> "CANAIS" THEN
                DO:
                   glb_cdcritic = 36.
                   NEXT.
                END.  
             
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "CADCCO"   THEN
                 DO:
                     HIDE FRAME f_opcao.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            aux_cddopcao = glb_cddopcao.
            { includes/acesso.i }
        END.                                                   

   IF   glb_cddopcao = "A" THEN
        DO:

            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO WHILE TRUE:
               
                  UPDATE tel_nrconven WITH FRAME f_opcao
                  
                  EDITING:
                      
                    READKEY.
                    
                    IF   LASTKEY = KEYCODE("F7")  THEN
                         DO:
                             RUN proc_query.
   
                             HIDE FRAME f_crapcco_b.
                             
                             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                  NEXT.
                          
                             LEAVE.

                         END.
                    ELSE
                         APPLY LASTKEY.
                  
                  END.  /* Fim do EDITING */
                  
                  LEAVE.
                  
               END.
                  
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.

               DO aux_contador = 1 TO 10:

                  FIND crapcco WHERE crapcco.cdcooper = glb_cdcooper   AND
                                     crapcco.nrconven = tel_nrconven
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE crapcco   THEN
                       IF   LOCKED crapcco   THEN
                            DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapcco),
                                					 INPUT "banco",
                                					 INPUT "crapcco",
                                					 OUTPUT par_loginusr,
                                					 OUTPUT par_nmusuari,
                                					 OUTPUT par_dsdevice,
                                					 OUTPUT par_dtconnec,
                                					 OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                			  " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                glb_cdcritic = 0.
                                NEXT.

                            END.
                       ELSE
                            DO:
                                glb_cdcritic = 563.
                                NEXT.
                            END.    
                  ELSE
                       glb_cdcritic = 0.

                  LEAVE.

               END.  /*  Fim do DO .. TO  */
               
               IF   glb_cdcritic > 0 THEN
                    NEXT.

               RUN proc_assign.
                            
               ASSIGN aux_flgregis = crapcco.flgregis.

               RUN proc_nmoperad (INPUT tel_cdoperad).  
                      
               DISPLAY tel_nmresbcc tel_flserasa tel_nmarquiv
                       tel_flcopcob tel_nmdireto tel_qtdfloat
                       tel_nrbloque tel_flgcnvcc tel_tamannro WITH FRAME f_cadcco_1.
              
               RUN proc_update.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    NEXT.

               /*IF   tel_dsorgarq:SCREEN-VALUE = "INTERNET" THEN
                    DO:
                        FIND FIRST crabcco WHERE 
                                   crabcco.cdcooper =  glb_cdcooper     AND
                                   crabcco.cddbanco =  tel_cddbanco     AND
                                   crabcco.nrconven <> crapcco.nrconven AND
                                   crabcco.flgativo =  TRUE             AND
                                   crabcco.flginter =  TRUE             AND
                                   crabcco.flgregis =  tel_flgregis     AND
                                   crabcco.dsorgarq =  "INTERNET"
                                   NO-LOCK NO-ERROR.
                                   
                        IF   AVAILABLE crabcco THEN
                             DO:
                                 MESSAGE 
                                   "Ja existe outro convenio para Internet".
                                 PAUSE 2 NO-MESSAGE.
                                 NEXT.
                             END.
                    END.*/

               IF  crapcco.dsorgarq = "EMPRESTIMO" THEN
                   DO:
                        FIND FIRST crabcco WHERE 
                               crabcco.cdcooper =  glb_cdcooper     AND
                               crabcco.nrconven <> crapcco.nrconven AND
                               crabcco.flgativo =  TRUE             AND                                                              
                               crabcco.dsorgarq =  "EMPRESTIMO"
                               NO-LOCK NO-ERROR.
                               
                        IF   AVAILABLE crabcco THEN
                             DO:
                                 MESSAGE 
                                   "Ja existe outro convenio ativo para Emprestimos".
                                 PAUSE 2 NO-MESSAGE.
                                 NEXT.
                             END.
                   END.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  aux_confirma = "N".
                  glb_cdcritic = 78.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  LEAVE.

               END.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S" THEN
                    DO: 
                        glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                    END.

               glb_cdcritic = 0.
               
               /* converte string para numérico */
               ASSIGN aux_qtdfloat = INT(tel_qtdfloat:SCREEN-VALUE).

               ASSIGN log_cddbanco = crapcco.cddbanco
                      log_nmdbanco = crapcco.nmdbanco
                      log_nrdctabb = crapcco.nrdctabb
                      log_cdbccxlt = crapcco.cdbccxlt
                      log_cdagenci = crapcco.cdagenci
                      log_nrdolote = crapcco.nrdolote
                      log_cdhistor = crapcco.cdhistor
                      log_vlrtarif = crapcco.vlrtarif
                      log_cdtarhis = crapcco.cdtarhis
                      log_cdhiscxa = crapcco.cdhiscxa
                      log_vlrtarcx = crapcco.vlrtarcx
                      log_cdhisnet = crapcco.cdhisnet
                      log_vlrtarnt = crapcco.vlrtarnt
                      log_cdhistaa = crapcco.cdhistaa  
                      log_vltrftaa = crapcco.vltrftaa
                      log_nrlotblq = crapcco.nrlotblq
                      log_vlrtrblq = crapcco.vlrtrblq
                      log_nrvarcar = crapcco.nrvarcar
                      log_cdcartei = crapcco.cdcartei
                      log_cdhisblq = crapcco.cdhisblq
                      log_nrbloque = crapcco.nrbloque
                      log_dsorgarq = crapcco.dsorgarq
                      log_tamannro = crapcco.tamannro
                      log_nmdireto = crapcco.nmdireto
                      log_nmarquiv = crapcco.nmarquiv
                      log_flgutceb = crapcco.flgutceb
                      log_flcopcob = crapcco.flcopcob
                      log_flgativo = crapcco.flgativo
                      log_dtmvtolt = crapcco.dtmvtolt
                      log_flginter = crapcco.flginter
                      log_flgregis = crapcco.flgregis
                      log_cdoperad = glb_cdoperad
                      log_qtdfloat = STRING(crapcco.qtdfloat).
                    
               
               ASSIGN crapcco.cddbanco = tel_cddbanco
                      crapcco.nmdbanco = tel_nmresbcc
                      crapcco.nrdctabb = tel_nrcontab
                      crapcco.cdbccxlt = tel_cdbccxlt
                      crapcco.cdagenci = tel_cdagenci
                      crapcco.nrdolote = tel_nrdolote
                      crapcco.cdhistor = tel_cdhistor
                      crapcco.vlrtarif = tel_vlrtarif
                      crapcco.cdtarhis = tel_cdtarhis
                      crapcco.cdhiscxa = tel_cdtarcxa
                      crapcco.vlrtarcx = tel_vlrtarcx
                      crapcco.cdhisnet = tel_cdtarnet
                      crapcco.vlrtarnt = tel_vlrtarnt
                      crapcco.cdhistaa = tel_cdhistaa  
                      crapcco.vltrftaa = tel_vltrftaa
                      crapcco.nrlotblq = tel_nrlotblq
                      crapcco.vlrtrblq = tel_vlrtrblq
                      crapcco.nrvarcar = tel_nrvarcar
                      crapcco.cdcartei = tel_cdcartei
                      crapcco.cdhisblq = tel_cdhisblq
                      crapcco.nrbloque = tel_nrbloque
                      crapcco.tamannro = tel_tamannro
                      crapcco.nmdireto = tel_nmdireto
                      crapcco.nmarquiv = tel_nmarquiv
                      crapcco.flgutceb = tel_flgcnvcc
                      crapcco.flcopcob = tel_flcopcob
                      crapcco.flserasa = tel_flserasa
                      crapcco.flgativo = tel_flgativo
                      crapcco.dtmvtolt = tel_dtmvtolt
                      crapcco.cdoperad = glb_cdoperad
                      crapcco.flgregis = tel_flgregis  
                      crapcco.qtdfloat = aux_qtdfloat  .
                      /*crapcco.dsorgarq = tel_dsorgarq:SCREEN-VALUE WHEN (crapcco.dsorgarq <> "INCORPORACAO" 
                                                                     AND crapcco.dsorgarq <> "MIGRACAO").  /* SD 263959 */*/
                      
               IF   tel_dsorgarq:SCREEN-VALUE = "INTERNET" OR
                    tel_dsorgarq:SCREEN-VALUE = "PROTESTO" OR 
                    tel_dsorgarq:SCREEN-VALUE = "IMPRESSO PELO SOFTWARE" THEN
                    ASSIGN crapcco.flginter = TRUE.
               ELSE 
                    ASSIGN crapcco.flginter = FALSE.

               IF  tel_flgregis THEN
                   DO:
                        EMPTY TEMP-TABLE tt-crapcct.     

                        IF  aux_flgregis <> tel_flgregis THEN
                            DO:
                                FOR EACH crapoco WHERE crapoco.cdcooper = glb_cdcooper
                                                   AND crapoco.cddbanco = crapcco.cddbanco
                                                   NO-LOCK:
                                    CREATE crapcct.
                                    ASSIGN crapcct.cdcooper = crapcco.cdcooper
                                           crapcct.nrconven = crapcco.nrconven
                                                           crapcct.cddbanco = crapcco.cddbanco
                                                           crapcct.cdocorre = crapoco.cdocorre
                                                           crapcct.tpocorre = crapoco.tpocorre
                                                           crapcct.vltarifa = 0
                                                           crapcct.cdtarhis = 0
                                                           crapcct.cdoperad = glb_cdoperad
                                                           crapcct.dtaltera = TODAY
                                                           crapcct.hrtransa = TIME.

                                    VALIDATE crapcct.
                                END.

                            END.

                        FOR EACH crapcct WHERE crapcct.cdcooper = glb_cdcooper
                                           AND crapcct.nrconven = tel_nrconven
                                           AND crapcct.cddbanco = tel_cddbanco
                                           NO-LOCK:
                            
                            FIND crapoco WHERE crapoco.cdcooper = glb_cdcooper
                                           AND crapoco.cdocorre = crapcct.cdocorre
                                           AND crapoco.tpocorre = crapcct.tpocorre
                                           AND crapoco.cddbanco = crapcct.cddbanco
                                           AND crapoco.flgativo
                                           NO-LOCK NO-ERROR.

                            IF AVAIL crapoco THEN
                            DO:
                                CREATE tt-crapcct.
                                ASSIGN tt-crapcct.cdcooper = crapcct.cdcooper
                                       tt-crapcct.cddbanco = crapcct.cddbanco
                                       tt-crapcct.nrconven = crapcct.nrconven
                                       tt-crapcct.cdocorre = crapcct.cdocorre
                                       tt-crapcct.dsocorre = crapoco.dsocorre
                                       tt-crapcct.tpocorre = crapcct.tpocorre
                                       tt-crapcct.axocorre = 
                                       IF crapcct.tpocorre = 1 THEN
                                                                    "REM"
                                                               ELSE
                                                                    "RET"
                                   tt-crapcct.vltarifa = crapcct.vltarifa
                                   tt-crapcct.cdtarhis = crapcct.cdtarhis
                                   tt-crapcct.flatuali = FALSE.
                            END.
                  
                        END.
                  
                        OPEN QUERY q_crapcct FOR EACH tt-crapcct 
                                                    BY tt-crapcct.tpocorre
                                                    BY tt-crapcct.cdocorre.
                            
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                           UPDATE b_crapcct WITH FRAME f_cadcco_dda.
                           LEAVE.
                        END.

                        FOR EACH tt-crapcct WHERE tt-crapcct.flatuali = TRUE NO-LOCK:

                            FIND crapcct WHERE crapcct.cdcooper = glb_cdcooper        
                                          AND  crapcct.nrconven = tel_nrconven        
                                          AND  crapcct.cdocorre = tt-crapcct.cdocorre 
                                          AND  crapcct.tpocorre = tt-crapcct.tpocorre 
                                          EXCLUSIVE-LOCK NO-ERROR.
               
                            IF  AVAIL crapcct THEN
                                DO:
                                    ASSIGN crapcct.vltarifa = tt-crapcct.vltarifa 
                                           crapcct.cdtarhis = tt-crapcct.cdtarhis.
                           
                                END.
                            ELSE
                                DO:
                                    IF  LOCKED crapcct THEN
                                        MESSAGE "Registro sendo utilizado por outro usuário".
                                    ELSE
                                        MESSAGE "Erro ao atualizar!".
                                    PAUSE 3 NO-MESSAGE.
                                END.
                                
                        END.

                        MESSAGE "Operação realizada com sucesso!".
                        PAUSE 3 NO-MESSAGE.
                   END.   
               ELSE
                   DO:
                        IF  tel_flgregis <> aux_flgregis THEN
                            DO:
                                FOR EACH crapcct WHERE crapcct.cdcooper = crapcco.cdcooper AND
                                                       crapcct.nrconven = crapcco.nrconven:

                                    DELETE crapcct.

                                END.
                            END.
                   END.
               
               RUN p_gera_item_log.
            
            END. /* Fim da transacao */

            tel_dsorgarq:SCREEN-VALUE = "".
            tel_qtdfloat:SCREEN-VALUE = "0".
            
            CLEAR FRAME f_crapcco NO-PAUSE.

        END.
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            DO WHILE TRUE:
            
               UPDATE tel_nrconven WITH FRAME f_opcao
               
               EDITING:
                
                 READKEY.

                 IF   LASTKEY = KEYCODE("F7")  THEN
                      DO: 
                          RUN proc_query.    
                         
                          IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                               DO:
                                   HIDE FRAME f_crapcco_b.
                                   NEXT.
                               END.
                      
                          HIDE FRAME f_crapcco_b.
                          
                          LEAVE.
                      END.
                 ELSE
                      APPLY LASTKEY.
                         
                 END.
               
               LEAVE.
            
            END.
               
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                 NEXT.

            FIND crapcco WHERE crapcco.nrconven = tel_nrconven AND
                               crapcco.cdcooper = glb_cdcooper 
                               NO-LOCK NO-ERROR.
                               
            IF   NOT AVAILABLE crapcco  THEN
                 DO:
                     glb_cdcritic = 563.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     PAUSE 2 NO-MESSAGE.
                     glb_cdcritic = 0.
                     NEXT.       
                 END.

            RUN proc_assign.

            RUN proc_nmoperad (INPUT tel_cdoperad).

            RUN proc_display.

            IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                RETURN.

            IF  tel_flgregis THEN
                DO:
                    EMPTY TEMP-TABLE tt-crapcct.    
                
                    FOR EACH crapcct WHERE crapcct.cdcooper = glb_cdcooper
                                       AND crapcct.nrconven = tel_nrconven
                                       AND crapcct.cddbanco = tel_cddbanco
                                       NO-LOCK:
              
                        FIND crapoco WHERE crapoco.cdcooper = glb_cdcooper
                                       AND crapoco.cdocorre = crapcct.cdocorre
                                       AND crapoco.tpocorre = crapcct.tpocorre
                                       AND crapoco.cddbanco = crapcct.cddbanco
                                       AND crapoco.flgativo
                                       NO-LOCK NO-ERROR.
                    
                        IF AVAIL crapoco THEN
                        DO:
                            CREATE tt-crapcct.
                            ASSIGN tt-crapcct.cdcooper = crapcct.cdcooper
                                   tt-crapcct.cddbanco = crapcct.cddbanco
                                   tt-crapcct.nrconven = crapcct.nrconven
                                   tt-crapcct.cdocorre = crapcct.cdocorre
                                   tt-crapcct.dsocorre = crapoco.dsocorre
                                   tt-crapcct.tpocorre = crapcct.tpocorre
                                   tt-crapcct.axocorre = 
                                   IF crapcct.tpocorre = 1 THEN
                                                                "REM"
                                                           ELSE
                                                                "RET"
                               tt-crapcct.vltarifa = crapcct.vltarifa
                               tt-crapcct.cdtarhis = crapcct.cdtarhis
                               tt-crapcct.flatuali = FALSE.                                                            
                        END.
                    END.
              
                    OPEN QUERY q_crapcct FOR EACH tt-crapcct 
                                                    BY tt-crapcct.tpocorre
                                                    BY tt-crapcct.cdocorre.
              
                    DO WHILE TRUE ON END-KEY UNDO, LEAVE:
                       UPDATE b_crapcct WITH FRAME f_cadcco_dda.
                       LEAVE.
                    END.

                   /* MESSAGE "Operacao realizada com sucesso!".
                    PAUSE 3 NO-MESSAGE. */
                END.

        END.             
   ELSE     
   IF   glb_cddopcao = "I" THEN
        DO:
            ASSIGN tel_cddbanco = 0   tel_nmresbcc = ""   tel_nrcontab = 0
                   tel_cdagenci = 0   tel_cdbccxlt = 0    tel_nrdolote = 0
                   tel_cdhistor = 0   tel_vlrtarif = 0    tel_nrvarcar = 0
                   tel_cdtarhis = 0   tel_cdtarcxa = 0    tel_vlrtarcx = 0
                   tel_cdtarnet = 0   tel_vlrtarnt = 0    tel_flgregis = NO
                   tel_cdhistaa = 0   tel_vltrftaa = 0    tel_nrlotblq = 0
                   tel_vlrtrblq = 0   tel_cdhisblq = 0    tel_nrbloque = 0
                   tel_dsorgarq = ""  tel_tamannro = 0    tel_nmdireto = "" 
                   tel_nmarquiv = ""  tel_flgcnvcc = NO   tel_flgativo = YES
                   tel_dtmvtolt = glb_dtmvtolt            tel_cdoperad = ""
                   tel_nmoperad = ""  tel_flcopcob = NO   tel_cdcartei = 0    
                   tel_qtdfloat = "0" tel_flserasa = NO.

            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO WHILE TRUE:
               
                  UPDATE tel_nrconven WITH FRAME f_opcao.
                  LEAVE.
               
               END.
                  
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.
   
               FIND crapcco WHERE crapcco.nrconven = tel_nrconven  AND
                                  crapcco.cdcooper = glb_cdcooper  AND
                                  crapcco.flgregis = tel_flgregis
                                  NO-LOCK NO-ERROR.
                                  
               IF   AVAILABLE crapcco  THEN
                    DO:
                        glb_cdcritic = 793.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        PAUSE 2 NO-MESSAGE.
                        NEXT.       
                    END.

               DISPLAY tel_nmresbcc tel_flserasa WITH FRAME f_cadcco_1.

               RUN proc_update.     

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.
               
               IF   tel_dsorgarq:SCREEN-VALUE = "INTERNET" THEN
                    DO:
                        FIND FIRST crabcco WHERE 
                                   crabcco.cdcooper =  glb_cdcooper  AND
                                   crabcco.nrconven <> tel_nrconven  AND
                                   crabcco.flgativo =  TRUE          AND
                                   crapcco.flgregis =  tel_flgregis  AND
                                   crabcco.flginter =  TRUE          AND
                                   crabcco.cddbanco = tel_cddbanco   AND
                                   crabcco.dsorgarq = "INTERNET"
                                                             NO-LOCK NO-ERROR.
                                   
                        IF   AVAILABLE crabcco THEN
                             DO:
                                 MESSAGE 
                                   "Ja existe outro convenio para Internet".
                                 PAUSE 2 NO-MESSAGE.
                                 NEXT.
                             END.
                    END.

               RUN proc_nmoperad (INPUT glb_cdoperad). 

               DISPLAY tel_cdoperad tel_nmoperad WITH FRAME f_cadcco_2. 

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  aux_confirma = "N".
                  glb_cdcritic = 78.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  LEAVE.

               END.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S" THEN
                    DO:
                        glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                    END.

               glb_cdcritic = 0.
               /* converte string para numérico */
               ASSIGN aux_qtdfloat = INT(tel_qtdfloat:SCREEN-VALUE).

               IF  tel_dsorgarq:SCREEN-VALUE = "EMPRESTIMO" THEN
                   DO:
                        FOR FIRST crapcco WHERE crapcco.cdcooper = glb_cdcooper
                                            AND crapcco.dsorgarq = tel_dsorgarq:SCREEN-VALUE
                                            AND crapcco.flgativo = TRUE
                                           NO-LOCK:
                            ASSIGN glb_dscritic = "Ja possui um convenio de EMPRESTIMO ativo cadastrado.".
                            BELL.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                            PAUSE 2 NO-MESSAGE.                            
                        END.

                        IF  AVAIL crapcco THEN
                            NEXT.

                   END.

               CREATE crapcco.
               ASSIGN crapcco.nrconven = tel_nrconven
                      crapcco.cddbanco = tel_cddbanco
                      crapcco.nmdbanco = tel_nmresbcc
                      crapcco.nrdctabb = tel_nrcontab
                      crapcco.cdbccxlt = tel_cdbccxlt
                      crapcco.cdagenci = tel_cdagenci
                      crapcco.nrdolote = tel_nrdolote
                      crapcco.cdhistor = tel_cdhistor
                      crapcco.vlrtarif = tel_vlrtarif
                      crapcco.cdtarhis = tel_cdtarhis
                      crapcco.cdhiscxa = tel_cdtarcxa
                      crapcco.vlrtarcx = tel_vlrtarcx
                      crapcco.cdhisnet = tel_cdtarnet
                      crapcco.vlrtarnt = tel_vlrtarnt
                      crapcco.cdhistaa = tel_cdhistaa  
                      crapcco.vltrftaa = tel_vltrftaa
                      crapcco.nrlotblq = tel_nrlotblq
                      crapcco.nrvarcar = tel_nrvarcar
                      crapcco.cdcartei = tel_cdcartei
                      crapcco.vlrtrblq = tel_vlrtrblq
                      crapcco.cdhisblq = tel_cdhisblq
                      crapcco.nrbloque = tel_nrbloque
                      crapcco.dsorgarq = tel_dsorgarq:SCREEN-VALUE
                      crapcco.tamannro = tel_tamannro
                      crapcco.nmdireto = tel_nmdireto
                      crapcco.nmarquiv = tel_nmarquiv
                      crapcco.flgutceb = tel_flgcnvcc
                      crapcco.flcopcob = tel_flcopcob
                      crapcco.flserasa = tel_flserasa
                      crapcco.flgativo = tel_flgativo
                      crapcco.dtmvtolt = tel_dtmvtolt
                      crapcco.cdoperad = glb_cdoperad
                      crapcco.cdcooper = glb_cdcooper
                      crapcco.flgregis = tel_flgregis       
                      crapcco.qtdfloat = aux_qtdfloat.
                      
               IF   tel_dsorgarq:SCREEN-VALUE = "INTERNET" OR
                    tel_dsorgarq:SCREEN-VALUE = "PROTESTO" OR 
                    tel_dsorgarq:SCREEN-VALUE = "IMPRESSO PELO SOFTWARE" THEN
                    ASSIGN crapcco.flginter = TRUE.
               ELSE 
                    ASSIGN crapcco.flginter = FALSE.
       
               VALIDATE crapcco.

               tel_dsorgarq:SCREEN-VALUE = "".
               tel_qtdfloat:SCREEN-VALUE = "0".

               IF  tel_flgregis THEN
                   DO:
                        EMPTY TEMP-TABLE tt-crapcct.

                        FOR EACH crapoco WHERE crapoco.cdcooper = glb_cdcooper
                                           AND crapoco.cddbanco = crapcco.cddbanco
                                           NO-LOCK:
                            CREATE crapcct.
                            ASSIGN crapcct.cdcooper = crapcco.cdcooper
                                   crapcct.nrconven = crapcco.nrconven
                                                   crapcct.cddbanco = crapcco.cddbanco
                                                   crapcct.cdocorre = crapoco.cdocorre
                                                   crapcct.tpocorre = crapoco.tpocorre
                                                   crapcct.vltarifa = 0
                                                   crapcct.cdtarhis = 0
                                                   crapcct.cdoperad = glb_cdoperad
                                                   crapcct.dtaltera = TODAY
                                                   crapcct.hrtransa = TIME.

                            VALIDATE crapcct.
                        END.

                        FOR EACH crapcct WHERE crapcct.cdcooper = glb_cdcooper
                                           AND crapcct.nrconven = tel_nrconven
                                           AND crapcct.cddbanco = tel_cddbanco
                                           NO-LOCK:
                  
                            FIND crapoco WHERE crapoco.cdcooper = glb_cdcooper
                                           AND crapoco.cdocorre = crapcct.cdocorre
                                           AND crapoco.tpocorre = crapcct.tpocorre
                                           AND crapoco.cddbanco = crapcct.cddbanco
                                           AND crapoco.flgativo
                                           NO-LOCK NO-ERROR.
                        
                            IF AVAIL crapoco THEN
                            DO:
                                CREATE tt-crapcct.
                                ASSIGN tt-crapcct.cdcooper = crapcct.cdcooper
                                       tt-crapcct.cddbanco = crapcct.cddbanco
                                       tt-crapcct.nrconven = crapcct.nrconven
                                       tt-crapcct.cdocorre = crapcct.cdocorre
                                       tt-crapcct.dsocorre = crapoco.dsocorre
                                       tt-crapcct.tpocorre = crapcct.tpocorre
                                       tt-crapcct.axocorre = 
                                       IF crapcct.tpocorre = 1 THEN
                                                                    "REM"
                                                               ELSE
                                                                    "RET"
                                   tt-crapcct.vltarifa = crapcct.vltarifa
                                   tt-crapcct.cdtarhis = crapcct.cdtarhis
                                   tt-crapcct.flatuali = FALSE.
                            END.
                        END.
                  
                        OPEN QUERY q_crapcct FOR EACH tt-crapcct
                                                        BY tt-crapcct.tpocorre
                                                        BY tt-crapcct.cdocorre.
                  
                        DO WHILE TRUE ON END-KEY UNDO, LEAVE:
                            UPDATE b_crapcct WITH FRAME f_cadcco_dda.
                            LEAVE.
                        END.

                        FOR EACH tt-crapcct WHERE tt-crapcct.flatuali = TRUE NO-LOCK:

                            FIND crapcct WHERE crapcct.cdcooper = glb_cdcooper        
                                          AND  crapcct.nrconven = tel_nrconven        
                                          AND  crapcct.cdocorre = tt-crapcct.cdocorre 
                                          AND  crapcct.tpocorre = tt-crapcct.tpocorre 
                                          EXCLUSIVE-LOCK NO-ERROR.
               
                            IF  AVAIL crapcct THEN
                                DO:
                                    ASSIGN crapcct.vltarifa = tt-crapcct.vltarifa 
                                           crapcct.cdtarhis = tt-crapcct.cdtarhis.
                           
                                END.
                            ELSE
                                DO:
                                    IF  LOCKED crapcct THEN
                                        MESSAGE "Registro sendo utilizado por outro usuário".
                                    ELSE
                                        MESSAGE "Erro ao atualizar!".
                                    PAUSE 3 NO-MESSAGE.
                                END.
                                
                        END.
                            
                        MESSAGE "Operacao realizada com sucesso!".
                        PAUSE 3 NO-MESSAGE.
                  END.

               RUN p_gera_log ("","","", glb_cddopcao). 
                  
               CLEAR FRAME f_crapcco NO-PAUSE.

            END.
        END.
   ELSE
   IF   glb_cddopcao = "E" THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO WHILE TRUE:
               
                  UPDATE tel_nrconven WITH FRAME f_opcao
                  
                  EDITING:
                  
                    READKEY.
                    
                    IF   LASTKEY = KEYCODE("F7")  THEN
                         DO:
                             RUN proc_query.
   
                             HIDE FRAME f_crapcco_b.
                             
                             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                  NEXT.
                       
                             LEAVE.
                             
                          END.
                    ELSE      
                         APPLY LASTKEY.
                    
                  END.  /* Fim do EDITING */
                  
                  LEAVE.

               END.
                
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.
   
               DO aux_contador = 1 TO 10:

                  FIND crapcco WHERE crapcco.cdcooper = glb_cdcooper   AND
                                     crapcco.nrconven = tel_nrconven
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE crapcco   THEN
                       IF   LOCKED crapcco   THEN
                            DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapcco),
                                					 INPUT "banco",
                                					 INPUT "crapcco",
                                					 OUTPUT par_loginusr,
                                					 OUTPUT par_nmusuari,
                                					 OUTPUT par_dsdevice,
                                					 OUTPUT par_dtconnec,
                                					 OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                			  " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                glb_cdcritic = 0.
                                NEXT.

                            END.
                       ELSE
                            DO:
                                glb_cdcritic = 563.
                                NEXT.
                            END.    
                  ELSE
                       glb_cdcritic = 0.

                  LEAVE.

               END.  /*  Fim do DO .. TO  */

               FIND FIRST crapcob WHERE crapcob.cdcooper = glb_cdcooper     AND
                                        crapcob.cdbandoc = crapcco.cddbanco AND
                                        crapcob.nrdctabb = crapcco.nrdctabb AND
                                        crapcob.nrcnvcob = tel_nrconven     AND
                                        crapcob.nrdconta > 0                AND
                                        crapcob.nrdocmto > 0 USE-INDEX crapcob1
                                                             NO-LOCK NO-ERROR.

               IF AVAIL crapcob THEN
               DO:
                   MESSAGE "Ha boleto(s) associado(s) a este convenio!".
                   APPLY "END-ERROR".
                   RETURN.
               END.

               IF   glb_cdcritic > 0 THEN
                    NEXT.

               RUN proc_assign.

               RUN proc_nmoperad (tel_cdoperad).
                                   
               RUN proc_display. 

               HIDE MESSAGE NO-PAUSE. 
  
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    NEXT.     
                         
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  aux_confirma = "N".
                  glb_cdcritic = 78.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  LEAVE.

               END.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S" THEN
                    DO:
                        glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                    END.

               glb_cdcritic = 0.

               IF  crapcco.flgregis  THEN
                   DO:
                         FOR EACH crapcct WHERE crapcct.cdcooper = crapcco.cdcooper AND
                                                crapcct.nrconven = crapcco.nrconven:

                            DELETE crapcct.

                         END.
                    
                   END.

               DELETE crapcco.

               RUN p_gera_log ("","","", glb_cddopcao).

            END. /* Fim da transacao */

            CLEAR FRAME f_crapcco NO-PAUSE.

        END.

END.  /*  Fim do DO WHILE TRUE  */


PROCEDURE proc_query:

    OPEN QUERY q_crapcco FOR EACH crapcco WHERE 
                                  crapcco.cdcooper = glb_cdcooper   NO-LOCK
                                  BY crapcco.nmdbanco.
  
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE b_crapcco WITH FRAME f_crapcco_b.
       LEAVE.
    END.

END.

PROCEDURE proc_assign:

    ASSIGN tel_cddbanco = crapcco.cddbanco   tel_nmresbcc = crapcco.nmdbanco
           tel_nrcontab = crapcco.nrdctabb   tel_cdagenci = crapcco.cdagenci
           tel_cdbccxlt = crapcco.cdbccxlt   tel_nrdolote = crapcco.nrdolote
           tel_cdhistor = crapcco.cdhistor   tel_vlrtarif = crapcco.vlrtarif
           tel_cdtarhis = crapcco.cdtarhis   tel_cdtarcxa = crapcco.cdhiscxa
           tel_vlrtarcx = crapcco.vlrtarcx   tel_cdtarnet = crapcco.cdhisnet
           tel_vlrtarnt = crapcco.vlrtarnt   tel_cdhistaa = crapcco.cdhistaa 
           tel_vltrftaa = crapcco.vltrftaa   tel_nrlotblq = crapcco.nrlotblq
           tel_vlrtrblq = crapcco.vlrtrblq   tel_nrvarcar = crapcco.nrvarcar
           tel_cdhisblq = crapcco.cdhisblq   tel_nrbloque = crapcco.nrbloque
           tel_dsorgarq = crapcco.dsorgarq   tel_tamannro = crapcco.tamannro
           tel_nmdireto = crapcco.nmdireto   tel_nmarquiv = crapcco.nmarquiv
           tel_flgcnvcc = crapcco.flgutceb   tel_flgativo = crapcco.flgativo
           tel_dtmvtolt = crapcco.dtmvtolt   tel_cdoperad = crapcco.cdoperad
           tel_flcopcob = crapcco.flcopcob   tel_flgregis = crapcco.flgregis
           tel_cdcartei = crapcco.cdcartei   tel_qtdfloat = STRING(crapcco.qtdfloat)
           tel_flserasa = crapcco.flserasa.
    
END.

PROCEDURE proc_display:
   
    DO WHILE TRUE:

       IF tel_dsorgarq <> "IMPRESSO PELO SOFTWARE" AND
          tel_dsorgarq <> "PRE-IMPRESSO"           AND
          tel_dsorgarq <> "INTERNET"               AND
          tel_dsorgarq <> "PROTESTO"               THEN
       DO:
           HIDE tel_dsorgarq IN FRAME f_cadcco_1 NO-PAUSE.

           /* Se não for banco 085, deve ocultar o Float  */
           IF tel_cddbanco <> 85 THEN
           DO:
               HIDE tel_qtdfloat IN FRAME f_cadcco_1 NO-PAUSE.
               
               DISPLAY tel_flgativo  tel_nrcontab  tel_flgregis  
                       tel_cddbanco  tel_nmresbcc  tel_cdbccxlt  
                       tel_cdagenci  tel_nrdolote  tel_cdhistor  
                       tel_flserasa  tel_nmarquiv  tel_nmdireto  
                       tel_nrbloque  tel_flgcnvcc  tel_tamannro  
                       tel_flcopcob  WITH FRAME f_cadcco_1.
           END.
           ELSE
           DO:
               DISPLAY tel_flgativo  tel_nrcontab  tel_flgregis  
                       tel_cddbanco  tel_nmresbcc  tel_cdbccxlt  
                       tel_cdagenci  tel_nrdolote  tel_cdhistor  
                       tel_flserasa  tel_nmarquiv  tel_nmdireto
                       tel_qtdfloat  tel_nrbloque  tel_flgcnvcc  
                       tel_tamannro  tel_flcopcob  WITH FRAME f_cadcco_1.

           END.
       END.
       ELSE
       DO:
           /* Se não for banco 085, deve ocultar o Float  */
           IF tel_cddbanco <> 85 THEN
           DO:
               HIDE tel_qtdfloat IN FRAME f_cadcco_1 NO-PAUSE.
               
               DISPLAY tel_flgativo  tel_dsorgarq  tel_nrcontab
                       tel_flgregis  tel_cddbanco  tel_nmresbcc  
                       tel_cdbccxlt  tel_cdagenci  tel_nrdolote  
                       tel_cdhistor  tel_flserasa  tel_nmarquiv  
                       tel_nmdireto  tel_nrbloque  tel_flgcnvcc  
                       tel_tamannro  tel_flcopcob  WITH FRAME f_cadcco_1.
           END.
           ELSE
           DO:
               DISPLAY tel_flgativo  tel_dsorgarq  tel_nrcontab
                       tel_flgregis  tel_cddbanco  tel_nmresbcc  
                       tel_cdbccxlt  tel_cdagenci  tel_nrdolote  
                       tel_cdhistor  tel_flserasa  tel_nmarquiv  
                       tel_nmdireto  tel_qtdfloat  tel_nrbloque  
                       tel_flgcnvcc  tel_tamannro  tel_flcopcob  
                       WITH FRAME f_cadcco_1.
           END.
       END.
       MESSAGE "Tecle <Enter> para continuar ou <End> para encerrar".
       
       WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                      
       IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
            LEAVE.
                    
       DO WHILE TRUE:
          
          DISPLAY tel_cdcartei  tel_nrvarcar  tel_nrlotblq  
                  tel_vlrtarif  tel_cdtarhis  tel_vlrtarcx  
                  tel_cdtarcxa  tel_vlrtarnt  tel_cdtarnet  
                  tel_vltrftaa  tel_cdhistaa  tel_vlrtrblq  
                  tel_cdhisblq  tel_dtmvtolt  tel_cdoperad  
                  tel_nmoperad
                  
                  WITH FRAME f_cadcco_2.

          IF tel_flgregis THEN
              MESSAGE "Tecle <Enter> para continuar ou <End> para encerrar".
          ELSE
              MESSAGE "Tecle <Enter> para encerrar ou <End> para voltar".
                  
          WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.

          IF   CAN-DO("END-ERROR,RETURN",KEYFUNCTION(LASTKEY))  THEN
               LEAVE.

       END. /* Fim do DO WHILE TRUE */
       
       LEAVE.
    
    END.  /* Fim do DO WHILE TRUE */ 
         
END PROCEDURE.

PROCEDURE proc_update:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      FIND FIRST crapcob WHERE crapcob.cdcooper = glb_cdcooper     AND
                               crapcob.cdbandoc = crapcco.cddbanco AND
                               crapcob.nrdctabb = crapcco.nrdctabb AND
                               crapcob.nrcnvcob = tel_nrconven     AND
                               crapcob.nrdconta > 0                AND
                               crapcob.nrdocmto > 0                AND
                               crapcob.incobran = 0 USE-INDEX crapcob1
                                                    NO-LOCK NO-ERROR.
                                                    

      IF AVAIL crapcob THEN
      DO:
          IF tel_dsorgarq <> "IMPRESSO PELO SOFTWARE" AND
             tel_dsorgarq <> "PRE-IMPRESSO"           AND
             tel_dsorgarq <> "INTERNET"               AND
             tel_dsorgarq <> "PROTESTO"               AND 
             tel_dsorgarq <> "EMPRESTIMO"             THEN
          DO:
              HIDE tel_dsorgarq IN FRAME f_cadcco_1 NO-PAUSE.

              DISP   tel_flgativo  tel_nrcontab  tel_flgregis  
                     tel_cddbanco  WITH FRAME f_cadcco_1.
          END.
          ELSE
              DISP   tel_flgativo  tel_dsorgarq  tel_nrcontab
                     tel_flgregis  tel_cddbanco  WITH FRAME f_cadcco_1.
          
          /* Se for banco 085 */
          IF tel_cddbanco = 85 THEN
          DO:
            UPDATE tel_flgativo  tel_cdbccxlt  tel_cdagenci  tel_nrdolote  
                   tel_cdhistor  WITH FRAME f_cadcco_1.  

            UPDATE tel_flserasa  tel_nmarquiv  tel_flcopcob  
                   tel_nmdireto  tel_qtdfloat  tel_nrbloque  tel_flgcnvcc  
                   tel_tamannro  WITH FRAME f_cadcco_1.
          END.
          ELSE
          DO:
              HIDE tel_qtdfloat IN FRAME f_cadcco_1 NO-PAUSE.

              UPDATE tel_flgativo  tel_cdbccxlt  tel_cdagenci  tel_nrdolote  
                     tel_cdhistor  WITH FRAME f_cadcco_1.  

              UPDATE tel_flserasa WHEN tel_cddbanco <> 1   
                     tel_nmarquiv  tel_flcopcob  tel_nmdireto  tel_nrbloque  
                     tel_flgcnvcc  tel_tamannro  WITH FRAME f_cadcco_1.

              ASSIGN tel_qtdfloat = "0".
          END.
      END.
      ELSE
      DO: 
          /* Se for banco 085 */
          IF tel_cddbanco = 85 THEN
          DO:
            UPDATE tel_flgativo  
                   tel_dsorgarq WHEN tel_dsorgarq = "IMPRESSO PELO SOFTWARE" OR
                                     tel_dsorgarq = "PRE-IMPRESSO"           OR
                                     tel_dsorgarq = "INTERNET"               OR
                                     tel_dsorgarq = "PROTESTO"               OR
                                     glb_cddopcao = "I"
                   tel_nrcontab  tel_flgregis  tel_cddbanco  
                   tel_cdbccxlt  tel_cdagenci  tel_nrdolote  
                   tel_cdhistor  WITH FRAME f_cadcco_1.  
                                    
            UPDATE tel_flserasa  tel_nmarquiv  
                   tel_flcopcob  tel_nmdireto  tel_qtdfloat  
                   tel_qtdfloat  tel_nrbloque  tel_flgcnvcc  
                   tel_tamannro  WITH FRAME f_cadcco_1.
          END.
          ELSE
          DO:
              HIDE tel_qtdfloat IN FRAME f_cadcco_1 NO-PAUSE.
              
              UPDATE tel_flgativo  
                   tel_dsorgarq WHEN tel_dsorgarq = "IMPRESSO PELO SOFTWARE" OR
                                     tel_dsorgarq = "PRE-IMPRESSO"           OR
                                     tel_dsorgarq = "INTERNET"               OR
                                     tel_dsorgarq = "PROTESTO"               OR
                                     tel_dsorgarq = "EMPRESTIMO"             OR
                                     glb_cddopcao = "I"
                   tel_nrcontab  tel_flgregis  tel_cddbanco  
                   tel_cdbccxlt  tel_cdagenci  tel_nrdolote  
                   tel_cdhistor  WITH FRAME f_cadcco_1.

              UPDATE tel_flserasa WHEN tel_cddbanco <> 1   
                   tel_nmarquiv  
                   tel_flcopcob  tel_nmdireto  tel_qtdfloat  
                   tel_nrbloque  tel_flgcnvcc  tel_tamannro  
                   WITH FRAME f_cadcco_1.
          END.
      END.

      IF   tel_nmdireto = ""   AND   tel_flcopcob = TRUE   THEN
           DO:
                    glb_cdcritic = 375.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    NEXT-PROMPT tel_nmdireto WITH FRAME f_cadcco_1.
                    NEXT.
                   
           END.


      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
           LEAVE.
                                   /* Nao permitir inativar se existir */
      IF   NOT tel_flgativo   THEN       /* algum boleto ativo */
           DO:
               FIND FIRST crapcob WHERE crapcob.cdcooper = glb_cdcooper   AND
                                        crapcob.nrcnvcob = tel_nrconven   AND
                                        crapcob.incobran = 0              AND
                                        crapcob.dtdpagto = ?              AND 
                                        crapcob.dtdbaixa <> ?             AND
                                        crapcob.dtelimin <> ? NO-LOCK NO-ERROR.
                            
               IF  AVAILABLE crapcob   THEN
                   DO:
                       MESSAGE "Ha boleto(s) ativo(s) para este convenio!".
                       APPLY "END-ERROR".
                        RETURN.
                    END.

                PAUSE 0.
                
            END.
                                    
      DISPLAY tel_cdoperad tel_nmoperad WITH FRAME f_cadcco_2.

      DO WHILE TRUE:
                
         UPDATE tel_cdcartei  tel_nrvarcar  tel_nrlotblq  
                tel_vlrtarif  WHEN NOT tel_flgregis  
                tel_cdtarhis  WHEN NOT tel_flgregis 
                tel_vlrtarcx  tel_cdtarcxa  tel_vlrtarnt  
                tel_cdtarnet  tel_vltrftaa  tel_cdhistaa
                tel_vlrtrblq  tel_cdhisblq  WITH FRAME f_cadcco_2.
              
         IF   tel_vlrtarif > 0   AND   tel_cdtarhis = 0   THEN
              DO:
                   MESSAGE "Historico deve ser informado!".
                   NEXT-PROMPT tel_cdtarhis WITH FRAME f_cadcco_2.
                   BELL.
                   NEXT.
              END.

         IF   tel_vlrtarcx > 0   AND   tel_cdtarcxa = 0   THEN
              DO:
                   MESSAGE "Historico deve ser informado!".
                   NEXT-PROMPT tel_cdtarcxa WITH FRAME f_cadcco_2.
                   BELL.
                   NEXT.
              END.

         IF   tel_vlrtarnt > 0   AND   tel_cdtarnet = 0   THEN
              DO:
                   MESSAGE "Historico deve ser informado!".
                   NEXT-PROMPT tel_cdtarnet WITH FRAME f_cadcco_2.
                   BELL.
                   NEXT.
              END.

         IF   tel_vltrftaa > 0   AND   tel_cdhistaa = 0   THEN
              DO:
                   MESSAGE "Historico deve ser informado!".
                   NEXT-PROMPT tel_cdtarnet WITH FRAME f_cadcco_2.
                   BELL.
                   NEXT.
              END.

         IF   tel_vlrtrblq > 0   AND   tel_cdhisblq = 0   THEN
              DO:
                   MESSAGE "Historico deve ser informado!".
                   NEXT-PROMPT tel_cdhisblq WITH FRAME f_cadcco_2.
                   BELL.
                   NEXT.
              END.
          
         LEAVE.
          
      END.  /* Fim do DO WHILE TRUE */
          
      LEAVE.
       
    END. /* Fim do DO WHILE TRUE */   

END PROCEDURE.

PROCEDURE proc_nmoperad:
    
    DEF INPUT PARAM par_cdoperad AS CHAR         NO-UNDO.

    FIND crapope WHERE crapope.cdcooper = glb_cdcooper   AND
                       crapope.cdoperad = par_cdoperad   NO-LOCK.
                           
    ASSIGN tel_cdoperad = crapope.cdoperad   
           tel_nmoperad = TRIM(crapope.nmoperad).
                               
END PROCEDURE.


PROCEDURE p_gera_item_log:

   IF log_cddbanco <> tel_cddbanco   THEN
      RUN p_gera_log ("Banco",log_cddbanco,tel_cddbanco, glb_cddopcao).
   
   IF log_nmdbanco <> tel_nmresbcc   THEN
      RUN p_gera_log ("Nome do banco",log_nmdbanco,tel_nmresbcc, 
                      glb_cddopcao).
   
   IF log_nrdctabb <> tel_nrcontab   THEN
      RUN p_gera_log ("Conta base",log_nrdctabb,tel_nrcontab, 
                       glb_cddopcao).
   
   IF log_flgregis <> tel_flgregis   THEN
       RUN p_gera_log("Cobranca Registrada",log_flgregis,
                       tel_flgregis,glb_cddopcao).
   
   IF log_cdbccxlt <> tel_cdbccxlt   THEN
      RUN p_gera_log ("Banco/Caixa",log_cdbccxlt,tel_cdbccxlt, 
                      glb_cddopcao).
   
   IF log_cdagenci <> tel_cdagenci   THEN
      RUN p_gera_log ("PA",log_cdagenci,tel_cdagenci, glb_cddopcao).
   
   IF log_nrdolote <> tel_nrdolote   THEN
      RUN p_gera_log ("Lote",log_nrdolote,tel_nrdolote, glb_cddopcao).
   
   IF log_cdhistor <> tel_cdhistor   THEN
      RUN p_gera_log ("Hist. tarifa especial",log_cdhistor,tel_cdhistor,
                      glb_cddopcao).
    
   IF log_vlrtarif <> tel_vlrtarif   THEN
      RUN p_gera_log ("Valor da tarifa",TRIM(STRING(log_vlrtarif, "zzz,zz9.99")),
                      TRIM(STRING(tel_vlrtarif, "zzz,zz9.99")), glb_cddopcao).
     
   IF log_cdtarhis <> tel_cdtarhis   THEN
      RUN p_gera_log ("Hist. tarifa",log_cdtarhis,tel_cdtarhis, 
                      glb_cddopcao).
         
   IF log_cdhiscxa <> tel_cdtarcxa   THEN
      RUN p_gera_log ("Hist. tarifa boleto pago na Coop.",log_cdhiscxa,
                      tel_cdtarcxa, glb_cddopcao).
   
   IF log_vlrtarcx <> tel_vlrtarcx   THEN
      RUN p_gera_log ("Valor tarifa boleto pago na Coop.", 
                      TRIM(STRING(log_vlrtarcx, "zzz,zz9.99")),
                      TRIM(STRING(tel_vlrtarcx, "zzz,zz9.99")), glb_cddopcao).
         
   IF log_cdhisnet <> tel_cdtarnet   THEN
      RUN p_gera_log ("Hist. tarifa boleto pago na Internet",log_cdhisnet,
                      tel_cdtarnet, glb_cddopcao).
      
   IF log_vlrtarnt <> tel_vlrtarnt   THEN
      RUN p_gera_log ("Valor tarifa boleto pago na internet",
                      TRIM(STRING(log_vlrtarnt, "zzz,zz9.99")),
                      TRIM(STRING(tel_vlrtarnt, "zzz,zz9.99")), glb_cddopcao).
    
   IF log_cdhistaa <> tel_cdhistaa   THEN
      RUN p_gera_log ("Hist. tarifa TAA",log_cdhistaa,tel_cdhistaa, 
                      glb_cddopcao).
      
   IF log_vltrftaa <> tel_vltrftaa   THEN
      RUN p_gera_log ("Valor tarifa TAA", TRIM(STRING(log_vltrftaa, "zzz,zz9.99")),
                      TRIM(STRING(tel_vltrftaa, "zzz,zz9.99")), 
                      glb_cddopcao).
         
   IF log_nrlotblq <> tel_nrlotblq   THEN
      RUN p_gera_log ("Lote impresso bloq.",log_nrlotblq,tel_nrlotblq, 
                      glb_cddopcao).
      
   IF log_vlrtrblq <> tel_vlrtrblq   THEN
      RUN p_gera_log ("Tarifa impresso bloq.", TRIM(STRING(log_vlrtrblq, "zzz,zz9.99")),
                      TRIM(STRING(tel_vlrtrblq, "zzz,zz9.99")), 
                      glb_cddopcao).
      
   IF log_nrvarcar <> tel_nrvarcar   THEN
      RUN p_gera_log ("Var. carteira",log_nrvarcar,tel_nrvarcar, 
                      glb_cddopcao).

   IF log_cdcartei <> tel_cdcartei THEN
       RUN p_gera_log ("Cod. carteira",log_cdcartei,tel_cdcartei,
                       glb_cddopcao).
      
   IF log_cdhisblq <> tel_cdhisblq   THEN
      RUN p_gera_log ("Hist. impresso bloqueto",log_cdhisblq,
                         tel_cdhisblq, glb_cddopcao).
         
   IF log_nrbloque <> tel_nrbloque   THEN
      RUN p_gera_log ("Nro bloqueto",log_nrbloque,tel_nrbloque,
                      glb_cddopcao).
      
   IF log_tamannro <> tel_tamannro   THEN
      RUN p_gera_log ("Tamanho do nro",log_tamannro,tel_tamannro,
                      glb_cddopcao).
      
   IF log_nmdireto <> tel_nmdireto   THEN
      RUN p_gera_log ("Diretorio",log_nmdireto,tel_nmdireto, 
                      glb_cddopcao).
   
   IF log_nmarquiv <> tel_nmarquiv   THEN
      RUN p_gera_log ("Arquivo",log_nmarquiv,tel_nmarquiv, 
                      glb_cddopcao).
                                                 
   IF log_flgutceb <> tel_flgcnvcc   THEN
      RUN p_gera_log ("Utiliza sequncia CADCEB", (IF log_flgutceb THEN "SIM"
                      ELSE
                      "NAO"), (IF tel_flgcnvcc THEN "SIM" 
                      ELSE 
                      "NAO"), glb_cddopcao).
                                                   
   IF log_flcopcob <> tel_flcopcob   THEN
      RUN p_gera_log ("Utiliza CoopCob", (IF log_flcopcob THEN "SIM" 
                      ELSE
                      "NAO"), (IF tel_flcopcob THEN "SIM"
                      ELSE
                      "NAO"), glb_cddopcao).
        
   IF log_flgativo <> tel_flgativo   THEN
      RUN p_gera_log ("Ativo", (IF log_flgativo THEN "ATIVO" 
                      ELSE
                      "INATIVO"), 
                     (IF tel_flgativo THEN "ATIVO" 
                      ELSE
                      "INATIVO") , glb_cddopcao).
      

   IF log_dtmvtolt <> tel_dtmvtolt   THEN
      RUN p_gera_log ("Data ult. alteracao",log_dtmvtolt,tel_dtmvtolt,
                      glb_cddopcao).
        
   IF log_cdoperad <> tel_cdoperad   THEN
      RUN p_gera_log ("Operador",log_cdoperad,tel_cdoperad, glb_cddopcao).
     
   IF log_dsorgarq  <> tel_dsorgarq THEN
      RUN p_gera_log ("Origem arquivo",log_dsorgarq,tel_dsorgarq, 
                      glb_cddopcao).
    
   IF log_qtdfloat <> tel_qtdfloat THEN
      RUN p_gera_log ("Float",log_qtdfloat,tel_qtdfloat, 
                      glb_cddopcao).

   IF log_flginter <> crapcco.flginter   THEN
      RUN p_gera_log ("Convenio internet",log_flginter, crapcco.flginter,
                      glb_cddopcao).


END PROCEDURE.


PROCEDURE p_gera_log:

   DEF INPUT PARAM par_dsdcampo AS CHAR NO-UNDO.
   DEF INPUT PARAM par_vlrcampo AS CHAR NO-UNDO.
   DEF INPUT PARAM par_vlcampo2 AS CHAR NO-UNDO.
   DEF INPUT PARAM par_tipdolog AS CHAR NO-UNDO.
   

   DEF VAR aux_tipdolog AS CHAR                      NO-UNDO.
  
   IF par_tipdolog = "E" THEN
      aux_tipdolog = "Excluiu".
   ELSE
   IF par_tipdolog = "I" THEN
      aux_tipdolog = "Incluiu".
   
   IF par_tipdolog = "A" THEN 
      DO:
         UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")       +
                           " "     + STRING(TIME,"HH:MM:SS")  + "' --> '"    +
                           " Operador " + glb_cdoperad + " - " + "Alterou"   +
                           " o cadastro de cobranca " + STRING(tel_nrconven) +
                           ", campo " + par_dsdcampo + " de "                + 
                           par_vlrcampo + " para " + par_vlcampo2 + "."    +
                           " >> log/cadcco.log").
           RETURN.
        
          END.
           
   IF par_tipdolog = "E" OR par_tipdolog = "I" THEN
      DO:
         UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") 
                           + " " + STRING(TIME,"HH:MM:SS") + "' --> '"     +
                           " Operador "  + glb_cdoperad + " - "            +
                           aux_tipdolog + " o cadastro de cobranca "       +
                           STRING(tel_nrconven) + "."                      + 
                           " >> log/cadcco.log").
      END.

END PROCEDURE.

       
/* .......................................................................... */
