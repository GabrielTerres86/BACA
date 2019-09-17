/*.............................................................................

   Programa: siscaixa/web/crap020.w
   Sistema : Caixa On-Line
   Sigla   : CRED
                                                Ultima atualizacao: 02/02/2019

   Dados referentes ao programa:

   Frequencia:  Diario (on-line)
   Objetivo  :  Inclusao DOC/TED 

  
    Alteracoes:  19/03/2009 - Incluida as procedures valida-transacao e
                              verifica-abertura-boletim (Elton).
                              
                 14/12/2009 - Criado radio com TED C e TED D. Ajustado
                              fonte para tratar os TEDS - SPB (Fernando).  
                              
                 31/05/2010 - Pedir senha do coordenador se nao existir saldo
                              em conta para debito do DOC (Fernando).
                              
                 24/09/2010 - Incluir campo v_cdidtran (Guilherme).
                 
                 29/03/2011 - Inclusao parametros para validadcao do valor/senha
                              do operador (Guilherme).
                              
                 23/08/2011 - Retirar formatos nos CPF/CNPJ (Gabriel).             
                 
                 14/12/2011 - Incluido novos parametros na chamada da procedure
                              valida-saldo (Elton).

                 16/04/2013 - Adicionado verificacao de sangria de caixa no
                              REQUEST-METHOD = GET. (Fabricio)

                 13/12/2013 - Alteracao referente a integracao Progress X
                              Dataserver Oracle
                              Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                              
                 06/01/2014 - Zerado valor do documento quando transferencia
                              for em especie e cobrado apenas tarifa e
                              corrigido problema de quando não havia saldo
                              suficiente para transferencia e finalizava
                              a transação mesmo assim se houvesse mais de uma
                              tentativa (Tiago). 
                 
                 12/08/2014 - Inclusão da Obrigatoriedade do campo Histórico para TED/DOC  
                            com Finalidade "99-Outros" (Vanessa).
                            
                 20/04/2015 - Inclusão do campo ISPB SD271603 FDR041 (Vanessa)                       
                 
                 27/04/2015 - Inclusão da validação do valor de limite de ted
                              para o operador (Tiago/Elton)
                                                           
                 29/02/2016 - Tratamentos para utilizaçao do Cartao CECRED e 
                              PinPad Novo (Lucas Lunelli - [PROJ290])

				        17/02/2017 - Retirar v_dssencrd <> '' pois precisamos validar se 
							               senha esta informada (Lucas Ranghetti #597410)
                
                02/06/2017 - Ajustes referentes ao Novo Catalogo do SPB(Lucas Ranghetti #668207)

                13/06/2018 - Alteracoes para usar as rotinas mesmo com o processo 
                             norturno rodando (Douglas Pagel - AMcom).
                             
				26/10/2018 - Ajuste para tratar o "Codigo identificador" quando escolhido 
				             a finalidade 400 - Tributos Municipais ISS - LCP 157
                             (Jonata  - Mouts / INC0024119).
							  
				02/02/2019 - Correção para o tipo de documento "TED C":
							-> Ao optar por "Espécie" deve ser permitir apenas para não cooperados
						   (Jonata - Mouts PRB0040337).
						   
				02/09/2019 - Modificado o fonte progress acrescentando o SUBSTR para limitar em 
							25 caracteres o campo "Código Identificador Transferência - v_cdidtran". 
							(Diego Batista - Ailos PRB0041891).
							  
----------------------------------------------------------------------------- **/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD PessoaDe AS CHARACTER 
       FIELD PessoaPara AS CHARACTER 
       FIELD Titular AS CHARACTER 
       FIELD TpDocto AS CHARACTER 
       FIELD TpPagto AS CHARACTER
       FIELD vh_doc AS CHARACTER FORMAT "X(256)":U 
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_agencia AS CHARACTER FORMAT "X(256)":U 
       FIELD v_banco AS CHARACTER FORMAT "X(256)":U
       FIELD v_ispbif AS CHARACTER FORMAT "X(256)":U  
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_opcao AS CHARACTER FORMAT "X(256)":U       
       FIELD v_infocry     AS CHARACTER FORMAT "X(256)":U               
       FIELD v_chvcry      AS CHARACTER FORMAT "X(256)":U       
       FIELD v_nrdocard    AS CHARACTER FORMAT "X(256)":U 
       FIELD v_dsimpvia AS CHARACTER FORMAT "X(256)":U
       FIELD v_dssencrd AS CHARACTER FORMAT "X(256)":U       
       FIELD v_cartao AS CHARACTER FORMAT "X(256)":U
       FIELD v_codfin AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpfcgcde1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpfcgcde2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpfcgcpara1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpfcgcpara2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_deschistorico AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cdidtran AS CHARACTER FORMAT "X(256)":U 
       FIELD v_empconven AS CHARACTER FORMAT "X(256)":U 
       FIELD v_finalidade AS CHARACTER 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nomeagencia AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nomebanco AS CHARACTER FORMAT "X(256)":U
       FIELD v_nomeif    AS CHARACTER FORMAT "X(256)":U  
       FIELD v_nomede1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nomede2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nomepara1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nomepara2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nrocontade AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nrocontapara AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_tpctcr AS CHARACTER FORMAT "X(256)":U 
       FIELD v_tpctcredito AS CHARACTER 
       FIELD v_tpctdb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_tpctdebito AS CHARACTER 
       FIELD v_valordocumento AS CHARACTER FORMAT "X(256)":U
       FIELD v_cod AS CHARACTER FORMAT "X(256)":U 
       FIELD v_senha AS CHARACTER FORMAT "X(256)":U 
       FIELD v_btn_ok AS CHARACTER FORMAT "X(256)":U 
       FIELD v_btn_cancela AS CHARACTER FORMAT "X(256)":U        
       FIELD v_msgsaldo AS CHARACTER FORMAT "X(256)":U.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 
/*------------------------------------------------------------------------
  File: 
  Description: 
  Input Parameters: <none>
  Output Parameters: <none>
  Author: Robinson Rafael Koprowski

Possibilidades de acesso aos campos no arquivo html:
DOC Titular CtDe    InfDe   CtPara  InfPara  Complementos
--- ------- ------- ------- ------- -------  ------------
C   N       ==b     E       E       E        E
C   N       <>b     D       E       E        E
C   N       ==b     E       D       D        D
C   N       <>b     D       D       D        D
D   S       <>b     D       E       D =InfDe E
TED N       ==b     E       E       E        E
TED N       <>b     D       E       E        E
TED S       ==b     E       E       D =InfDe E
TED S       <>b     D       E       D =InfDe E

Legenda:
   E = Enabled
   D = Disabled
 ==b = campo em branco
 <>b = campo preenchido

Por exemplo:
Conforme a tabela e possivel prever:
 - para todos os DOC's D, o titular deve ser "Sim".
 - pode haver TED com o mesmo titular ou nao, mas nao havera Empresa
   conveniada.
 - sempre que a empresa conveniada for preenchida as informacoes da
   Conta Para (conta destino) serao desabilitadas para o usuario.
 - etc;
------------------------------------------------------------------------*/

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Preprocessor Definitions ---                                         */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
                                
DEF VAR i-tipo-doc      AS INTE                        NO-UNDO.
DEF VAR p-nro-docto     AS INTE                        NO-UNDO.
DEF VAR p-histor        AS INTE                        NO-UNDO.
DEF VAR aux_vllanmto    AS DECI                        NO-UNDO.
DEF VAR aux_nrdconta    AS INTE                        NO-UNDO.
DEF VAR aux_mensagem    AS CHAR                        NO-UNDO.
DEF VAR p-programa      AS CHAR INITIAL "CRAP020"      NO-UNDO.
DEF VAR p-flgdebcc      AS CHAR INITIAL TRUE           NO-UNDO.
DEF VAR c-aux1          AS CHAR. 
DEF VAR c-aux2          AS CHAR. 
DEF VAR aux_vlsddisp    AS DECI                        NO-UNDO.

DEF VAR p-literal       AS CHAR                        NO-UNDO.
DEF VAR p-ult-sequencia AS INTE                        NO-UNDO.
DEF VAR p-nro-conta-rm  AS INTE                        NO-UNDO.
DEF VAR p-nro-lote      AS INTE                        NO-UNDO.
DEF VAR i-cpfcgc-de     AS DEC FORMAT "zzzzzzzzzzzzz9" NO-UNDO.
DEF VAR i-cpfcgc-para   AS dec FORMAT "zzzzzzzzzzzzz9" NO-UNDO.
DEF VAR l-recibo        AS LOG NO-UNDO.

DEF VAR h-b1crap20      AS HANDLE                      NO-UNDO.
DEF VAR h-b1crap56      AS HANDLE                      NO-UNDO.
DEF VAR h-b1crap00      AS HANDLE                      NO-UNDO.

DEF VAR l-houve-erro    AS LOG                         NO-UNDO.
DEF VAR p-aviso-cx      AS LOG                         NO-UNDO.
DEF VAR documento       AS INT FORMAT ">>>>>>>9"       NO-UNDO.
DEF TEMP-TABLE w-craperr                               NO-UNDO
     FIELD cdagenci   LIKE craperr.cdagenc
     FIELD nrdcaixa   LIKE craperr.nrdcaixa
     FIELD nrsequen   LIKE craperr.nrsequen
     FIELD cdcritic   LIKE craperr.cdcritic
     FIELD dscritic   LIKE craperr.dscritic
     FIELD erro       LIKE craperr.erro.

DEF VAR i-pessoa-de   AS INT                           NO-UNDO.
DEF VAR i-pessoa-para AS INTE                          NO-UNDO.
DEF VAR v_banage      AS INTE                          NO-UNDO.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE crap020.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.v_tpctcr ab_unmap.v_tpctdb ab_unmap.v_codfin ab_unmap.v_nrocontapara ab_unmap.v_tpctdebito ab_unmap.v_tpctcredito ab_unmap.v_finalidade ab_unmap.v_nomede2 ab_unmap.v_nomepara1 ab_unmap.v_nomepara2 ab_unmap.TpPagto ab_unmap.v_cpfcgcde2 ab_unmap.v_cpfcgcpara1 ab_unmap.v_cpfcgcpara2 ab_unmap.PessoaDe ab_unmap.PessoaPara ab_unmap.TpDocto ab_unmap.vh_doc ab_unmap.v_cpfcgcde1 ab_unmap.v_nomede1 ab_unmap.vh_foco ab_unmap.v_agencia ab_unmap.v_banco ab_unmap.v_ispbif ab_unmap.v_caixa ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_deschistorico ab_unmap.v_cdidtran ab_unmap.v_msg ab_unmap.v_nomeagencia ab_unmap.v_dsimpvia ab_unmap.v_nrdocard ab_unmap.v_infocry ab_unmap.v_chvcry ab_unmap.v_opcao ab_unmap.v_nomeif ab_unmap.v_nomebanco ab_unmap.v_cartao ab_unmap.v_nrocontade ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_valordocumento ab_unmap.v_cod ab_unmap.v_senha ab_unmap.v_btn_ok ab_unmap.v_btn_cancela ab_unmap.v_msgsaldo ab_unmap.v_dssencrd
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_tpctcr ab_unmap.v_tpctdb ab_unmap.v_codfin ab_unmap.v_nrocontapara ab_unmap.v_tpctdebito ab_unmap.v_tpctcredito ab_unmap.v_finalidade ab_unmap.v_nomede2 ab_unmap.v_nomepara1 ab_unmap.v_nomepara2 ab_unmap.TpPagto ab_unmap.v_cpfcgcde2 ab_unmap.v_cpfcgcpara1 ab_unmap.v_cpfcgcpara2 ab_unmap.PessoaDe ab_unmap.PessoaPara ab_unmap.TpDocto ab_unmap.vh_doc ab_unmap.v_cpfcgcde1 ab_unmap.v_nomede1 ab_unmap.vh_foco ab_unmap.v_agencia ab_unmap.v_banco  ab_unmap.v_ispbif ab_unmap.v_caixa ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_deschistorico ab_unmap.v_cdidtran ab_unmap.v_msg ab_unmap.v_nomeagencia ab_unmap.v_dsimpvia ab_unmap.v_nrdocard ab_unmap.v_infocry ab_unmap.v_chvcry ab_unmap.v_opcao ab_unmap.v_nomeif ab_unmap.v_nomebanco ab_unmap.v_cartao ab_unmap.v_nrocontade ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_valordocumento ab_unmap.v_cod ab_unmap.v_senha ab_unmap.v_btn_ok ab_unmap.v_btn_cancela ab_unmap.v_msgsaldo ab_unmap.v_dssencrd

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.v_tpctcr AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_opcao AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
           "v_opcao 1", "R":U,
           "v_opcao 2", "C":U 
           SIZE 20 BY 2
     ab_unmap.v_infocry AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1          
     ab_unmap.v_nrdocard AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1                   
     ab_unmap.v_chvcry AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1                     
     ab_unmap.v_dsimpvia AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
           "v_dsimpvia 1", "S":U,
           "v_dsimpvia 2", "N":U 
           SIZE 20 BY 2                      
     ab_unmap.v_dssencrd AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1     
     ab_unmap.v_tpctdb AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_codfin AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nrocontapara AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_tpctdebito AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.v_tpctcredito AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.v_finalidade AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.v_nomede2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nomepara1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nomepara2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.TpPagto AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS 
          RADIO-SET VERTICAL
          RADIO-BUTTONS 
           "TpPagto 1", "D":U,
           "TpPagto 2", "E":U
          SIZE 20 BY 4           
     ab_unmap.v_cpfcgcde2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cpfcgcpara1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cpfcgcpara2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.PessoaDe AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
          "PessoaDe 1", "V1":U,
          "PessoaDe 2", "V2":U
          SIZE 20 BY 3
     ab_unmap.PessoaPara AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
          "PessoaPara 1", "V1":U,
          "PessoaPara 2", "V2":U
          SIZE 20 BY 3
     ab_unmap.TpDocto AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
           "TpDocto 1", "C":U,
           "TpDocto 2", "D":U,
           "TpDocto 3", "TEDC":U,
           "TpDocto 4", "TEDD":U
          SIZE 20 BY 4
     ab_unmap.vh_doc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cpfcgcde1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nomede1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 60.6 BY 14.19.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Web-Frame
     ab_unmap.vh_foco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_agencia AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_banco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     
     ab_unmap.v_ispbif AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    
     ab_unmap.v_caixa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_coop AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_data AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_deschistorico AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cdidtran AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_msg AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nomeagencia AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nomebanco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cartao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1          
     ab_unmap.v_nomeif AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nrocontade AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_operador AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_pac AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_valordocumento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cod AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_senha AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_btn_ok AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_btn_cancela AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1                    
     ab_unmap.v_msgsaldo AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1

    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 60.6 BY 14.19.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Web-Object
   Allow: Query
   Frames: 1
   Add Fields to: Neither
   Editing: Special-Events-Only
   Events: web.output,web.input
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: ab_unmap W "?" ?  
      ADDITIONAL-FIELDS:
          FIELD PessoaDe AS CHARACTER 
          FIELD PessoaPara AS CHARACTER 
          FIELD Titular AS CHARACTER 
          FIELD TpDocto AS CHARACTER 
          FIELD vh_doc AS CHARACTER FORMAT "X(256)":U 
          FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_agencia AS CHARACTER FORMAT "X(256)":U 
          FIELD v_banco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_codfin AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cpfcgcde1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cpfcgcde2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cpfcgcpara1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cpfcgcpara2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_deschistorico AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cdidtran AS CHARACTER FORMAT "X(256)":U 
          FIELD v_empconven AS CHARACTER FORMAT "X(256)":U 
          FIELD v_finalidade AS CHARACTER 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomeagencia AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomebanco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomede1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomede2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomepara1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomepara2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nrocontade AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nrocontapara AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_tpctcr AS CHARACTER FORMAT "X(256)":U 
          FIELD v_tpctcredito AS CHARACTER 
          FIELD v_tpctdb AS CHARACTER FORMAT "X(256)":U 
          FIELD v_tpctdebito AS CHARACTER 
          FIELD v_valordocumento AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cod AS CHARACTER FORMAT "X(256)":U 
          FIELD v_senha AS CHARACTER FORMAT "X(256)":U
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 14.19
         WIDTH              = 60.6.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-html 
/* *********************** Included-Libraries ************************* */

{src/web2/html-map.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-html
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME Web-Frame
   UNDERLINE                                                            */
/* SETTINGS FOR RADIO-SET ab_unmap.PessoaDe IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR RADIO-SET ab_unmap.PessoaPara IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR RADIO-SET ab_unmap.Titular IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR RADIO-SET ab_unmap.TpDocto IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.vh_doc IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_agencia IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_banco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_codfin IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cpfcgcde1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cpfcgcde2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cpfcgcpara1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cpfcgcpara2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_deschistorico IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cdidtran IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_empconven IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.v_finalidade IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomeagencia IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomebanco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomede1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomede2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomepara1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomepara2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nrocontade IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nrocontapara IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_tpctcr IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.v_tpctcredito IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.v_tpctdb IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.v_tpctdebito IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.v_valordocumento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cod IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_senha IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-html 


/* ************************  Main Code Block  ************************* */

/* Standard Main Block that runs adm-create-objects, initializeObject 
 * and process-web-request.
 * The bulk of the web processing is in the Procedure process-web-request
 * elsewhere in this Web object.
 */
{src/web2/template/hmapmain.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-html  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE carregaContaCredito w-html 
PROCEDURE carregaContaCredito :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE INPUT  PARAMETER pTpDocto AS CHARACTER  NO-UNDO.

    DEFINE VARIABLE cListAux  AS CHARACTER  NO-UNDO INITIAL ''.
    DEFINE VARIABLE cCdAcesso AS CHARACTER  NO-UNDO.

    IF pTpDocto = 'D' OR pTpDocto = 'TEDD' OR pTpDocto = 'TEDC' THEN DO:

        IF pTpDocto = 'D' THEN
            ASSIGN cCdAcesso = 'TPCTACRTRF'.
        ELSE
            ASSIGN cCdAcesso = 'TPCTACRTED'.

        FOR EACH craptab NO-LOCK
            WHERE craptab.cdcooper  = crapcop.cdcooper
              AND craptab.nmsistem  = 'CRED'
              AND craptab.tptabela  = 'GENERI'
              AND craptab.cdempres  = 00
              AND craptab.cdacesso  = cCdAcesso:

            ASSIGN cListAux = cListAux +
                              (IF cListAux = '' THEN '' ELSE ',') +
                              STRING(craptab.tpregist, "99") + ' - ' + REPLACE(craptab.dstextab, ',', ';') + ',' +
                              STRING(craptab.tpregist).
        END.

    END.

    IF cListAux = '' THEN
        ASSIGN cListAux = 'Nenhum,0'.

    ASSIGN v_tpctcredito:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = cListAux.

    RETURN 'OK'.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE carregaContaDebito w-html 
PROCEDURE carregaContaDebito :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE INPUT  PARAMETER pTpDocto AS CHARACTER  NO-UNDO.

    DEFINE VARIABLE cListAux  AS CHARACTER  NO-UNDO INITIAL ''.
    DEFINE VARIABLE cCdAcesso AS CHARACTER  NO-UNDO.

    IF pTpDocto = 'D' OR pTpDocto = 'TEDD' OR pTpDocto = 'TEDC' THEN DO:

        IF pTpDocto = 'D' THEN
            ASSIGN cCdAcesso = 'TPCTADBTRF'.
        ELSE
            ASSIGN cCdAcesso = 'TPCTADBTED'.

        FOR EACH craptab NO-LOCK
            WHERE craptab.cdcooper  = crapcop.cdcooper
              AND craptab.nmsistem  = 'CRED'
              AND craptab.tptabela  = 'GENERI'
              AND craptab.cdempres  = 00
              AND craptab.cdacesso  = cCdAcesso:

            ASSIGN cListAux = cListAux +
                              (IF cListAux = '' THEN '' ELSE ',') +
                              STRING(craptab.tpregist, "99") + ' - ' + REPLACE(craptab.dstextab, ',', ';') + ',' +
                              STRING(craptab.tpregist).
        END.

    END.

    IF cListAux = '' THEN
        ASSIGN cListAux = 'Nenhum,0'.

    ASSIGN v_tpctdebito:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = cListAux.

    RETURN 'OK'.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE carregaFinalidade w-html 
PROCEDURE carregaFinalidade :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE INPUT  PARAMETER pTpDocto AS CHARACTER  NO-UNDO.

    DEFINE VARIABLE cListAux  AS CHARACTER  NO-UNDO INITIAL ''.
    DEFINE VARIABLE cCdAcesso AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cFormat   AS CHARACTER  NO-UNDO.


    IF pTpDocto = 'C' OR pTpDocto = 'D' THEN
        ASSIGN cCdAcesso = 'FINTRFDOCS'
               cFormat   = '99'.
    ELSE
        ASSIGN cCdAcesso = 'FINTRFTEDS'
               cFormat   = '99999'.

    FOR EACH craptab NO-LOCK
        WHERE craptab.cdcooper  = crapcop.cdcooper
          AND craptab.nmsistem  = 'CRED'
          AND craptab.tptabela  = 'GENERI'
          AND craptab.cdempres  = 00
          AND craptab.cdacesso  = cCdAcesso:

        ASSIGN cListAux = cListAux +
                          (IF cListAux = '' THEN '' ELSE ',') +
                          STRING(craptab.tpregist, cFormat) + ' - ' + REPLACE(craptab.dstextab, ',', ';') + ',' +
                          STRING(craptab.tpregist).
    END.

    IF cListAux = '' THEN
        ASSIGN cListAux = 'Nenhum,0'.

    ASSIGN v_finalidade:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = cListAux.

    RETURN 'OK'.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
  RUN readOffsets ("{&WEB-FILE}":U).
  RUN htmAssociate
    ("PessoaDe":U,"ab_unmap.PessoaDe":U,ab_unmap.PessoaDe:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("PessoaPara":U,"ab_unmap.PessoaPara":U,ab_unmap.PessoaPara:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("TpDocto":U,"ab_unmap.TpDocto":U,ab_unmap.TpDocto:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("TpPagto":U,"ab_unmap.TpPagto":U,ab_unmap.TpPagto:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vh_doc":U,"ab_unmap.vh_doc":U,ab_unmap.vh_doc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vh_foco":U,"ab_unmap.vh_foco":U,ab_unmap.vh_foco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_agencia":U,"ab_unmap.v_agencia":U,ab_unmap.v_agencia:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_banco":U,"ab_unmap.v_banco":U,ab_unmap.v_banco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_ispbif":U,"ab_unmap.v_ispbif":U,ab_unmap.v_ispbif:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nomebanco":U,"ab_unmap.v_nomebanco":U,ab_unmap.v_nomebanco:HANDLE IN FRAME {&FRAME-NAME}).
 RUN htmAssociate
    ("v_cartao":U,"ab_unmap.v_cartao":U,ab_unmap.v_cartao:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_codfin":U,"ab_unmap.v_codfin":U,ab_unmap.v_codfin:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cpfcgcde1":U,"ab_unmap.v_cpfcgcde1":U,ab_unmap.v_cpfcgcde1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cpfcgcde2":U,"ab_unmap.v_cpfcgcde2":U,ab_unmap.v_cpfcgcde2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cpfcgcpara1":U,"ab_unmap.v_cpfcgcpara1":U,ab_unmap.v_cpfcgcpara1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cpfcgcpara2":U,"ab_unmap.v_cpfcgcpara2":U,ab_unmap.v_cpfcgcpara2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_deschistorico":U,"ab_unmap.v_deschistorico":U,ab_unmap.v_deschistorico:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cdidtran":U,"ab_unmap.v_cdidtran":U,ab_unmap.v_cdidtran:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_finalidade":U,"ab_unmap.v_finalidade":U,ab_unmap.v_finalidade:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nomeagencia":U,"ab_unmap.v_nomeagencia":U,ab_unmap.v_nomeagencia:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nomede1":U,"ab_unmap.v_nomede1":U,ab_unmap.v_nomede1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nomede2":U,"ab_unmap.v_nomede2":U,ab_unmap.v_nomede2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nomepara1":U,"ab_unmap.v_nomepara1":U,ab_unmap.v_nomepara1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nomepara2":U,"ab_unmap.v_nomepara2":U,ab_unmap.v_nomepara2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrocontade":U,"ab_unmap.v_nrocontade":U,ab_unmap.v_nrocontade:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrocontapara":U,"ab_unmap.v_nrocontapara":U,ab_unmap.v_nrocontapara:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tpctcr":U,"ab_unmap.v_tpctcr":U,ab_unmap.v_tpctcr:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tpctcredito":U,"ab_unmap.v_tpctcredito":U,ab_unmap.v_tpctcredito:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tpctdb":U,"ab_unmap.v_tpctdb":U,ab_unmap.v_tpctdb:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_opcao":U,"ab_unmap.v_opcao":U,ab_unmap.v_opcao:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("v_infocry":U,"ab_unmap.v_infocry":U,ab_unmap.v_infocry:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("v_chvcry":U,"ab_unmap.v_chvcry":U,ab_unmap.v_chvcry:HANDLE IN FRAME {&FRAME-NAME}).            
  RUN htmAssociate
    ("v_nrdocard":U,"ab_unmap.v_nrdocard":U,ab_unmap.v_nrdocard:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("v_dsimpvia":U,"ab_unmap.v_dsimpvia":U,ab_unmap.v_dsimpvia:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("v_dssencrd":U,"ab_unmap.v_dssencrd":U,ab_unmap.v_dssencrd:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("v_tpctdebito":U,"ab_unmap.v_tpctdebito":U,ab_unmap.v_tpctdebito:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valordocumento":U,"ab_unmap.v_valordocumento":U,ab_unmap.v_valordocumento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cod":U,"ab_unmap.v_cod":U,ab_unmap.v_cod:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_senha":U,"ab_unmap.v_senha":U,ab_unmap.v_senha:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_btn_ok":U,"ab_unmap.v_btn_ok":U,ab_unmap.v_btn_ok:HANDLE IN FRAME {&FRAME-NAME}).   
  RUN htmAssociate
    ("v_btn_cancela":U,"ab_unmap.v_btn_cancela":U,ab_unmap.v_btn_cancela:HANDLE IN FRAME {&FRAME-NAME}).       
  RUN htmAssociate
    ("v_msgsaldo":U,"ab_unmap.v_msgsaldo":U,ab_unmap.v_msgsaldo:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE outputHeader w-html 
PROCEDURE outputHeader :
/*------------------------------------------------------------------------
  Purpose:     Output the MIME header, and any "cookie" information needed 
               by this procedure.  
  Parameters:  <none>
  Notes:       In the event that this Web object is state-aware, this is 
               a good place to set the WebState and WebTimeout attributes.
------------------------------------------------------------------------*/

  /* To make this a state-aware Web object, pass in the timeout period
   * (in minutes) before running outputContentType.  If you supply a 
   * timeout period greater than 0, the Web object becomes state-aware 
   * and the following happens:
   *
   *   - 4GL variables webState and webTimeout are set
   *   - a cookie is created for the broker to id the client on the return trip
   *   - a cookie is created to id the correct procedure on the return trip
   *
   * If you supply a timeout period less than 1, the following happens:
   *
   *   - 4GL variables webState and webTimeout are set to an empty string
   *   - a cookie is killed for the broker to id the client on the return trip
   *   - a cookie is killed to id the correct procedure on the return trip
   *
   * For example, set the timeout period to 5 minutes.
   *
   *   setWebState (5.0).
   */
    
  /* Output additional cookie information here before running outputContentType.
   *   For more information about the Netscape Cookie Specification, see
   *   http://home.netscape.com/newsref/std/cookie_spec.html  
   *   
   *   Name         - name of the cookie
   *   Value        - value of the cookie
   *   Expires date - Date to expire (optional). See TODAY function.
   *   Expires time - Time to expire (optional). See TIME function.
   *   Path         - Override default URL path (optional)
   *   Domain       - Override default domain (optional)
   *   Secure       - "secure" or unknown (optional)
   * 
   *   The following example sets custNum=23 and expires tomorrow at (about)
   *   the same time but only for secure (https) connections.
   *      
   *   RUN SetCookie IN web-utilities-hdl 
   *     ("custNum":U, "23":U, TODAY + 1, TIME, ?, ?, "secure":U).
   */ 
  output-content-type ("text/html":U).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
PROCEDURE process-web-request :
/*------------------------------------------------------------------------
  Purpose:     Process the web request.
  Notes:       
------------------------------------------------------------------------*/

    DEFINE VARIABLE lOpenAutentica  AS LOGICAL      NO-UNDO INITIAL NO.
    DEFINE VARIABLE aux_valordocto  AS DECIMAL      NO-UNDO INITIAL 0.
    DEFINE VARIABLE aux_flgerro     AS LOGICAL      NO-UNDO INITIAL NO.
    DEFINE VARIABLE aux_nrcartao    AS DECIMAL      NO-UNDO .
    DEFINE VARIABLE aux_idtipcar    AS INTEGER      NO-UNDO .

    RUN outputHeader.
    {include/i-global.i}

    /*vh_doc = ''.*/
    
    IF REQUEST_METHOD = 'POST':U THEN DO:

        RUN inputFields.

        {include/assignfields.i}

        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
                       
        IF v_btn_cancela <> '' THEN DO:

            ASSIGN vh_foco          = '10'

                   v_opcao          = "R"
                   v_dsimpvia       = "S"

                   TpDocto          = 'C'
                   Titular          = ''
                   v_empconven      = ''
                   v_dssencrd       = ''
                   
                   v_nrdocard       = ""
                   v_infocry        = ""
                   v_chvcry         = ""

                   v_valordocumento = ''

                   v_nrocontade     = ''
                   v_nomede1        = ''
                   v_nomede2        = ''
                   v_cpfcgcde1      = ''
                   v_cpfcgcde2      = ''
                   PessoaDe         = 'V1'

                   v_deschistorico  = ''
                   v_cdidtran       = ''

                   v_banco          = ''
                   v_ispbif         = ''
                   v_nomebanco      = ''
                   v_cartao         = ''
                   v_agencia        = ''
                   v_nomeagencia    = ''
                   v_nrocontapara   = ''
                   v_nomepara1      = ''
                   v_nomepara2      = ''
                   v_cpfcgcpara1    = ''
                   v_cpfcgcpara2    = ''
                   v_codfin         = ''

                   PessoaPara       = 'V1'
                   v_finalidade     = ''
                   v_tpctcr         = ''
                   v_tpctcredito    = ''
                   v_tpctdb         = ''
                   v_tpctdebito     = ''

                   v_cod            = ''
                   v_senha          = ''
                   v_btn_ok         = ''
                   v_btn_cancela    = ''
                   v_msgsaldo       = ''.
           
            RUN carregaContaDebito  IN THIS-PROCEDURE ('C').
            RUN carregaContaCredito IN THIS-PROCEDURE ('C').
            RUN carregaFinalidade   IN THIS-PROCEDURE ('C').
        END.
        ELSE DO:
          RUN valida-transacao2 IN h-b1crap00(INPUT v_coop,
                                             INPUT v_pac,
                                             INPUT v_caixa).
          
          IF  RETURN-VALUE = "OK"  THEN DO:
              RUN  verifica-abertura-boletim IN h-b1crap00 (INPUT v_coop,
                                                            INPUT v_pac,
                                                            INPUT v_caixa,
                                                            INPUT v_operador).
          END.
          
          IF  RETURN-VALUE = "NOK" THEN DO:
              ASSIGN v_btn_ok = ''
                     v_btn_cancela    = ''.
              {include/i-erro.i}
          END.
          ELSE DO:
            
            ASSIGN v_nrocontade   = REPLACE(v_nrocontade,'.','')
                   v_nrocontapara = REPLACE(v_nrocontapara,'.','').

            ASSIGN v_cpfcgcde1 = REPLACE(v_cpfcgcde1,'/','')
                   v_cpfcgcde1 = REPLACE(v_cpfcgcde1,'.','')
                   v_cpfcgcde1 = REPLACE(v_cpfcgcde1,'-','').

            ASSIGN v_cpfcgcde2 = REPLACE(v_cpfcgcde2,'/','')
                   v_cpfcgcde2 = REPLACE(v_cpfcgcde2,'.','')
                   v_cpfcgcde2 = REPLACE(v_cpfcgcde2,'-','').

            ASSIGN v_cpfcgcpara1 = REPLACE(v_cpfcgcpara1,'/','')
                   v_cpfcgcpara1 = REPLACE(v_cpfcgcpara1,'.','')
                   v_cpfcgcpara1 = REPLACE(v_cpfcgcpara1,'-','').

            ASSIGN v_cpfcgcpara2 = REPLACE(v_cpfcgcpara2,'/','')
                   v_cpfcgcpara2 = REPLACE(v_cpfcgcpara2,'.','')
                   v_cpfcgcpara2 = REPLACE(v_cpfcgcpara2,'-','').
            
            IF   TpDocto = 'D' OR TpDocto = 'TEDD'   THEN
                 ASSIGN Titular = 'Y'.
            ELSE
                 ASSIGN Titular = 'N'.

            RUN carregaContaDebito  IN THIS-PROCEDURE (TpDocto).
            RUN carregaContaCredito IN THIS-PROCEDURE (TpDocto).
            RUN carregaFinalidade   IN THIS-PROCEDURE (TpDocto).

            /* os valores dos selection-lists sao armazenados em variaveis
               hidden para depois serem resgatados para as variaves originais
               pois as lista de valores sao dinamicas e seus valores acabam se
               perdendo */
            ASSIGN v_tpctdebito     = v_tpctdb
                   v_tpctcredito    = v_tpctcr
                   v_finalidade     = v_codfin.

            RUN dbo/b1crap20.p PERSISTENT SET h-b1crap20.
            
            RUN elimina-erro
                IN h-b1crap20 (INPUT v_coop,
                               INTEGER(v_agencia), INTEGER(v_caixa)).

            IF  v_cartao <> '' THEN
                DO:
                    RUN retorna-conta-cartao IN h-b1crap20 (INPUT v_coop,
                                                            INPUT v_pac,
                                                            INPUT v_caixa,
                                                            INPUT DECI(v_cartao),
                                                           OUTPUT v_nrocontade,
                                                           OUTPUT aux_nrcartao,
                                                           OUTPUT aux_idtipcar).
                                                           
                    IF  RETURN-VALUE <> "OK" THEN DO:
                    
                        ASSIGN l-houve-erro = YES
                               v_btn_ok     = ''
                               v_btn_cancela = ''
                               v_nrocontade = '' 
                               v_cartao     = ''
                               v_dssencrd   = ''
                               v_infocry    = ""
                               v_chvcry     = ""
                               v_nrdocard   = ""
                               v_opcao      = "R"
                               v_dsimpvia   = "S".
                       
                        {include/i-erro.i}
                    END.
                END.
                
            ASSIGN l-houve-erro = NO
                   v_nrdocard   = STRING(aux_nrcartao).                  
                   
            IF  v_nrocontade <> '' THEN DO:
            
                RUN dbo/b1crap20.p PERSISTENT SET h-b1crap20.
                
                RUN retorna-conta-de
                           IN h-b1crap20 (INPUT v_coop,
                                          v_pac,
                                          v_caixa,
                                          INTEGER(v_nrocontade),
                                          OUTPUT v_nomede1,
                                          OUTPUT v_cpfcgcde1,
                                          OUTPUT v_nomede2,
                                          OUTPUT v_cpfcgcde2,
                                          OUTPUT PessoaDe).

                    IF RETURN-VALUE = 'NOK' THEN DO:
                        ASSIGN l-houve-erro = YES
                               v_btn_ok     = ''
                               v_btn_cancela    = ''.
                        {include/i-erro.i}
                    END.
                    
                IF  l-houve-erro = NO THEN
                    DO:                    
                        IF  v_btn_ok <> '' THEN
                    DO:
                        RUN valida_senha_cartao IN h-b1crap20 (INPUT v_coop,
                                                               INPUT v_pac,
                                                               INPUT v_caixa,
                                                               INPUT v_nrocontade,
                                                               INPUT DECI(aux_nrcartao),
                                                               INPUT v_opcao,
                                                               INPUT v_dssencrd,
                                                               INPUT aux_idtipcar,
                                                               INPUT v_infocry,
                                                               INPUT v_chvcry). 
                                                               
                        IF  RETURN-VALUE <> "OK" THEN DO:                        
                            ASSIGN l-houve-erro = YES
                                   v_btn_ok     = ''
                                   v_btn_cancela = ''
                                   v_dssencrd   = ''
                                   v_infocry    = ""
                                   v_chvcry     = ""
                                   v_opcao      = "C".                          
                            {include/i-erro.i}
                END.
                            END.
            
                        
                    END.
                    
            END.

			IF  v_cpfcgcde1 <> '' AND 
			    TpDocto = 'TEDC'  AND 
				TpPagto = 'E'     THEN DO:
            
                RUN dbo/b1crap20.p PERSISTENT SET h-b1crap20.
                
                RUN verifica_cooperado
                           IN h-b1crap20 (INPUT v_coop,
                                          v_pac,
                                          v_caixa,
                                          v_cpfcgcde1).

                    IF RETURN-VALUE <> 'OK' THEN DO:
                        ASSIGN l-houve-erro = YES
                               v_btn_ok     = ''
                               v_btn_cancela    = ''.
                        {include/i-erro.i}
                    END.
                                    
            END.

            IF Titular = 'Y' THEN DO:
               ASSIGN v_nomepara1 = v_nomede1
                      v_nomepara2 = v_nomede2
                    v_cpfcgcpara1 = v_cpfcgcde1
                    v_cpfcgcpara2 = v_cpfcgcde2
                    PessoaPara    = PessoaDe.
                END.
                
            RUN retorna-nome-banco   
                IN h-b1crap20   (INPUT v_coop,
                                 INPUT(INTEGER(v_banco)), STRING(v_ispbif), OUTPUT v_nomebanco, OUTPUT v_ispbif, OUTPUT v_banco ).
            
           /* ASSIGN v_banco = STRING(v_banage).*/
          
       
            RUN retorna-nome-agencia
                  IN h-b1crap20   (INPUT v_coop,
                                   INTEGER(v_banco),
                                   INTEGER(v_agencia),
                                   OUTPUT v_nomeagencia).

            IF v_btn_ok <> '' AND NOT l-houve-erro THEN DO:

                CASE TpDocto :
                     WHEN 'C'    THEN ASSIGN i-tipo-doc = 1.
                     WHEN 'D'    THEN ASSIGN i-tipo-doc = 2.
                     WHEN 'TEDC' THEN ASSIGN i-tipo-doc = 3.
                     WHEN 'TEDD' THEN ASSIGN i-tipo-doc = 4.
                END CASE.

                ASSIGN i-pessoa-de   = IF PessoaDe   = 'V1' THEN 1 ELSE 2.
                ASSIGN i-pessoa-para = IF PessoaPara = 'V1' THEN 1 ELSE 2.

                RUN valida-valores IN h-b1crap20 (INPUT v_coop,
                                                  INTEGER(v_pac),
                                                  INTEGER(v_caixa),
                                                  TpDocto,
                                                  TpPagto,
                                                  DECIMAL(v_valordocumento),
                                                  INTEGER(v_banco),
                                                  INTEGER(v_agencia),
                                                  INTEGER(v_nrocontade),
                                                  v_nomede1,
                                                  v_nomede2,
                                                  v_cpfcgcde1,
                                                  v_cpfcgcde2,
                                                  i-pessoa-de,
                                                  (Titular = 'Y'),
                                                  DEC(v_nrocontapara),   
                                                  v_nomepara1,
                                                  v_nomepara2,
                                                  v_cpfcgcpara1,
                                                  v_cpfcgcpara2,
                                                  i-pessoa-para,
                                                  INTEGER(v_tpctdebito),
                                                  INTEGER(v_tpctcredito),
                                                  INTEGER(v_codfin),
                                                  v_deschistorico,
                                                  STRING(v_ispbif),
												  SUBSTR(v_cdidtran,1,25)).

                IF  RETURN-VALUE = "NOK" THEN DO:
                    ASSIGN v_btn_ok = ''
                           v_btn_cancela = ''.
                    {include/i-erro.i}
                END.
                ELSE DO:  

                  RUN valida-saldo IN h-b1crap20 (INPUT v_coop,
                                                  INPUT INTEGER(v_pac),
                                                  INPUT INTEGER(v_caixa),
                                                  INPUT INTEGER(v_nrocontade),
                                                  INPUT IF  TpPagto = 'E'   THEN
                                                            0
                                                        ELSE
                                                            DECIMAL(v_valordocumento),
                                                  INPUT 20, /** Rotina **/
                                                  INPUT "",
                                                  OUTPUT aux_mensagem,
                                                  OUTPUT aux_vlsddisp).

				  IF RETURN-VALUE <> "OK" THEN
				    DO:
					   ASSIGN v_btn_ok = ''
                             v_btn_cancela = ''.
                      {include/i-erro.i} 

				  END.
				  ELSE
				  DO:
                  /* Cooperado tem saldo */
                  IF   aux_mensagem = ' ' THEN
                       ASSIGN v_msgsaldo = 'false'.

				  IF  v_msgsaldo = ''  THEN 
				  DO:
                      ASSIGN v_msgsaldo = 'false'.

                      /* Caso o cooperado nao tenha saldo */
                      IF   aux_mensagem <> ' '  THEN
                           DO:
                              {include/i-erro.i}
                           END.
					
                  END.
                  ELSE DO:

                     ASSIGN aux_flgerro = NO.

                     /*Caso conta nao tiver saldo para operacao verifica alcada e nivel*/
                     IF  aux_mensagem <> ' '          THEN
                         DO:                              
                             RUN verifica-operador IN h-b1crap20(INPUT v_coop,
                                                                 INPUT INT(v_pac),
                                                                 INPUT INT(v_caixa),
                                                                 INPUT v_cod,
                                                                 INPUT v_senha,
                                                                 INPUT DECIMAL(v_valordocumento),
                                                                 INPUT aux_vlsddisp).
                             vh_foco = '42'.

                             IF RETURN-VALUE = 'NOK' THEN  DO:
                                 ASSIGN v_btn_ok = ''
                                        v_btn_cancela = ''
                                        aux_flgerro = YES.
                                {include/i-erro.i}
                             END.                         
                         END.
                     
                     /*Caso for um TED ver limite do operador apenas*/
                     IF  aux_flgerro   = NO      AND 
                         (TpDocto      = 'TEDC' OR 
                          TpDocto      = 'TEDD'   ) THEN
                         DO:
                             RUN verifica-operador-ted IN h-b1crap20(INPUT v_coop,
                                                                     INPUT INT(v_pac),
                                                                     INPUT INT(v_caixa),
                                                                     INPUT v_operador,
                                                                     INPUT v_cod,
                                                                     INPUT v_senha,
                                                                     INPUT DECIMAL(v_valordocumento)).

                             vh_foco = '42'.

                             IF  RETURN-VALUE = "NOK" THEN DO:
                                 ASSIGN v_btn_ok = ''
                                        v_btn_cancela = ''
                                        l-houve-erro = YES.
                                 {include/i-erro.i}
                             END.

                         END.
                     
                     IF RETURN-VALUE = 'NOK' THEN  DO:
                         ASSIGN v_btn_ok = ''
                                v_btn_cancela = ''.
                        {include/i-erro.i}
                     END.
                     ELSE DO:
                       DO TRANSACTION ON ERROR UNDO:
                            
                            ASSIGN l-houve-erro = NO
                                   aux_nrdconta = int(v_nrocontade)
                                   aux_vllanmto = dec(v_valordocumento).
                     
                            RUN atualiza-doc-ted
                                     IN  h-b1crap20(INPUT v_coop,
                                                    INPUT int(v_pac),
                                                    INPUT int(v_caixa),
                                                    INPUT v_operador,
                                                    INPUT v_cod,
                                                    INPUT i-tipo-doc,
                                                    INPUT (Titular = 'Y'),
                                                    INPUT TpPagto,
                                                    INPUT dec(v_valordocumento),
                                                    INPUT int(v_nrocontade),
                                                    INPUT int(v_banco),
                                                    INPUT int(v_agencia),
                                                    INPUT dec(v_nrocontapara),  
                                                    INPUT int(v_finalidade),
                                                    INPUT int(v_tpctdebito),
                                                    INPUT int(v_tpctcredito),
                                                    INPUT v_deschistorico,
                                                    INPUT v_nomede1,
                                                    INPUT v_nomede2,
                                                    INPUT v_cpfcgcde1,
                                                    INPUT v_cpfcgcde2,
                                                    INPUT v_nomepara1,
                                                    INPUT v_nomepara2,
                                                    INPUT v_cpfcgcpara1,
                                                    INPUT v_cpfcgcpara2,
                                                    INPUT i-pessoa-de,
                                                    INPUT i-pessoa-para,
                                                    INPUT SUBSTR(v_cdidtran,1,25),
                                                    INPUT INT(v_ispbif),
                                                    INPUT aux_idtipcar,
                                                    INPUT v_opcao,
                                                    INPUT v_dsimpvia,
                                                    INPUT DECI(aux_nrcartao),
                                                    OUTPUT p-nro-lote,
                                                    OUTPUT p-nro-docto,
                                                    OUTPUT p-literal, 
                                                    OUTPUT p-ult-sequencia,
                                                    OUTPUT p-nro-conta-rm,
                                                    OUTPUT p-aviso-cx).
                     
                            IF RETURN-VALUE = 'NOK' THEN DO:
                                
                                ASSIGN l-houve-erro = YES.
                                FOR EACH w-craperr:
                                    DELETE w-craperr.
                                END.
                                FOR EACH craperr NO-LOCK WHERE
                                       craperr.cdcooper =  crapcop.cdcooper  AND
                                       craperr.cdagenci =  INT(v_pac)        AND
                                       craperr.nrdcaixa =  INT(v_caixa):
                                    CREATE w-craperr.
                                    ASSIGN w-craperr.cdagenci   = craperr.cdagenc
                                         w-craperr.nrdcaixa   = craperr.nrdcaixa
                                         w-craperr.nrsequen   = craperr.nrsequen
                                         w-craperr.cdcritic   = craperr.cdcritic
                                         w-craperr.dscritic   = craperr.dscritic
                                         w-craperr.erro       = craperr.erro.
                                END.
                                UNDO, LEAVE.
                            END.
                            ELSE IF   p-aviso-cx   THEN DO:
                                FOR EACH w-craperr:
                                    DELETE w-craperr.
                                END.
                                FOR EACH craperr NO-LOCK WHERE
                                         craperr.cdcooper =  crapcop.cdcooper  AND
                                         craperr.cdagenci =  INT(v_pac)        AND
                                         craperr.nrdcaixa =  INT(v_caixa):
                     
                                    CREATE w-craperr.
                                    ASSIGN w-craperr.cdagenci   = craperr.cdagenc
                                           w-craperr.nrdcaixa   = craperr.nrdcaixa
                                           w-craperr.nrsequen   = craperr.nrsequen
                                           w-craperr.cdcritic   = craperr.cdcritic
                                           w-craperr.dscritic   = craperr.dscritic
                                           w-craperr.erro       = craperr.erro.
                                END.    
                            END.
                     
                        END. /*transaction*/
                        
                        IF l-houve-erro THEN DO:
                            FOR EACH w-craperr NO-LOCK:
                                CREATE craperr.
                                ASSIGN craperr.cdcooper = crapcop.cdcooper
                                     craperr.cdagenci   = w-craperr.cdagenc
                                     craperr.nrdcaixa   = w-craperr.nrdcaixa
                                     craperr.nrsequen   = w-craperr.nrsequen
                                     craperr.cdcritic   = w-craperr.cdcritic
                                     craperr.dscritic   = w-craperr.dscritic
                                     craperr.erro       = w-craperr.erro.
                                VALIDATE craperr.
                            END.
                            ASSIGN v_btn_ok = ''
                                   v_btn_cancela = ''.
                            {include/i-erro.i}
                        END.
                        ELSE DO:
                     
                            IF   p-aviso-cx  THEN
                                 DO:  /* Aviso para o cooperado - nao é erro
                                         craperr.erro = NO */
                                     FOR EACH w-craperr NO-LOCK:
                                         CREATE craperr.
                                         ASSIGN craperr.cdcooper = crapcop.cdcooper
                                                craperr.cdagenci   = w-craperr.cdagenc
                                                craperr.nrdcaixa   = w-craperr.nrdcaixa
                                                craperr.nrsequen   = w-craperr.nrsequen
                                                craperr.cdcritic   = w-craperr.cdcritic
                                                craperr.dscritic   = w-craperr.dscritic
                                                craperr.erro       = w-craperr.erro.
                                         VALIDATE craperr.   
                                     END. 
                     
                                     {include/i-erro.i}
                                 END.
                     
                            ASSIGN vh_foco          = '10'
                     
                                   v_opcao          = "R"
                                   v_dsimpvia       = "S"
                     
                                   TpDocto          = 'C'
                                   Titular          = 'Y'
                                   v_empconven      = ''
                                   v_dssencrd       = ''
                                   
                                   v_infocry        = ""
                                   v_chvcry         = ""
                                   v_nrdocard       = ""
                     
                                   v_valordocumento = ''
                     
                                   v_nrocontade     = ''
                                   v_nomede1        = ''
                                   v_nomede2        = ''
                                   v_cpfcgcde1      = ''
                                   v_cpfcgcde2      = ''
                                   PessoaDe         = 'V1'
                     
                                   v_deschistorico  = ''
                                   v_cdidtran       = ''
                     
                                   v_banco          = ''
                                   v_ispbif         = ''
                                   v_nomebanco      = ''
                                   v_cartao         = ''
                                   v_agencia        = ''
                                   v_nomeagencia    = ''
                                   v_nrocontapara   = ''
                                   v_nomepara1      = ''
                                   v_nomepara2      = ''
                                   v_cpfcgcpara1    = ''
                                   v_cpfcgcpara2    = ''
                                   v_codfin         = ''
                     
                                   PessoaPara       = 'V1'
                                   v_finalidade     = ''
                                   v_tpctcr         = ''
                                   v_tpctcredito    = ''
                                   v_tpctdb         = ''
                                   v_tpctdebito     = ''
                     
                                   v_cod            = ''
                                   v_senha          = ''
                                   v_btn_ok         = ''
                                   v_btn_cancela    = ''
                                   v_msgsaldo       = ''.
                            
                            RUN carregaContaDebito  IN THIS-PROCEDURE ('C').
                            RUN carregaContaCredito IN THIS-PROCEDURE ('C').
                            RUN carregaFinalidade   IN THIS-PROCEDURE ('C').
                     
                            ASSIGN l-recibo  = YES.
                            ASSIGN lOpenAutentica = YES.
                        END.
					   end.	 
                     END.
                  END.
                END.
            END. /*OK*/

            IF v_nrocontade <> '' THEN
                ASSIGN v_nrocontade 
                  = STRING(INTEGER(v_nrocontade), '>>>>,>>>,9').
            IF v_nrocontapara <> '' THEN
              ASSIGN v_nrocontapara =
                     STRING(dec(v_nrocontapara), '>>>>>>>>>>>>>>>>>>>9').

            DELETE PROCEDURE h-b1crap20.

          END. 
        END.
         
        DELETE PROCEDURE h-b1crap00.
        
        RUN displayFields.
        RUN enableFields.

        IF (TpDocto = 'TEDD' OR TpDocto = 'TEDC') OR aux_mensagem <> ' ' THEN
            ENABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.
        ELSE
            DISABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.
        
        RUN outputFields.

        IF lOpenAutentica THEN DO:
            ASSIGN p-literal = "".

             /* Chama autentica para exibir nr da autenticaçao, porém nao 
                disponibiliza impressao */
             IF  v_opcao    = "C"  AND
                 v_dsimpvia = "N"  THEN
                 DO:
            {&OUT}
                        "<script>           
                            alert('Operaçao Realizada com Sucesso!'); 
                        </script>". 
                 END.
             ELSE 
                 DO:
                    {&OUT}
               '<script language="JavaScript">' SKIP
               'window.open("autentica.html?v_plit=&v_pseq=' p-ult-sequencia 
               '&v_prec=' l-recibo '&v_psetcook=yes","waut","width=250,height=145,scrollbars=auto,alwaysRaised=true,left=0,top=0");' SKIP
               '</script>'.
                 END.

               /*** Incluido por Fernando 26/11/2009 ***/
               IF   aux_vllanmto <> 0   THEN
                    DO:
                       FIND craptab 
                            WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                  craptab.nmsistem = "CRED"            AND
                                  craptab.tptabela = "GENERI"          AND
                                  craptab.cdempres = 0                 AND
                                  craptab.cdacesso = "VLCTRMVESP"      AND
                                  craptab.tpregist = 0   NO-LOCK NO-ERROR.
                        
                       IF   AVAILABLE craptab   THEN             
                            DO:
                               IF (aux_vllanmto >= DEC(craptab.dstextab) AND
                                   TpPagto = 'E') OR p-nro-conta-rm = 0     THEN
                                  DO:
                                      {&OUT}
                                       '<script> window.location=
                                          "crap051f.w?v_pconta=' + 
                                             STRING(aux_nrdconta) '" + 
                                          "&v_pvalor=" + 
                                          "' aux_vllanmto '" +
                                          "&v_pnrdocmto=" + 
                                             "' p-nro-docto '" +
                                          "&v_pult_sequencia=" + 
                                             "' p-ult-sequencia '" +
                                          "&v_pconta_base=" + 
                                             "' STRING(aux_nrdconta) '" +
                                          "&v_nrdolote=" +
                                             "' STRING(p-nro-lote)'" +
                                          "&v_pprograma=" + 
                                             "' p-programa '" +
                                          "&v_flgdebcc=" +
                                             "' p-flgdebcc '" </script>'.
                                   END.
                            END.
                    END.
        END.
        
    END. /* Form has been submitted. */

    /* REQUEST-METHOD = GET */ 
    ELSE DO:

        IF GET-VALUE("v_sangria") <> "" THEN
        DO:
            RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

            RUN verifica-sangria-caixa IN h-b1crap00 (INPUT v_coop,
                                                      INPUT INT(v_pac),
                                                      INPUT INT(v_caixa),
                                                      INPUT v_operador).

            DELETE PROCEDURE h-b1crap00.

            IF RETURN-VALUE = "MAX" THEN
            DO:
                {include/i-erro.i}

                {&OUT}
                     '<script> window.location = "crap002.html" </script>'.
        
            END.

            IF RETURN-VALUE = "MIN" THEN
                {include/i-erro.i}

            IF RETURN-VALUE = "NOK" THEN
            DO:
                {include/i-erro.i}

                {&OUT}
                     '<script> window.location = "crap002.html" </script>'.
            END.
        END.

        ASSIGN vh_foco = '17'. 

        RUN carregaContaDebito  IN THIS-PROCEDURE ('C').
        RUN carregaContaCredito IN THIS-PROCEDURE ('C').
        RUN carregaFinalidade   IN THIS-PROCEDURE ('C').

        RUN displayFields.   
        RUN enableFields.

        DISABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.
        
        RUN outputFields.

    END.

    /* Show error messages. */
    IF AnyMessage() THEN DO:
       
        ShowDataMessages().
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
