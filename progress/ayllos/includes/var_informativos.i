/* ...........................................................................

   Programa: includes/var_informativos.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2006                     Ultima atualizacao: 12/07/2011

   Dados referentes ao programa:

   Frequencia:
   Objetivo  : Definir variaveis para ser utilizada na geracao dos Formularios
               FormPrint.              

   ASSIGN cratext.nmagenci =                       
          cratext.nmsecext = 
          cratext.nrdconta =
          cratext.nmprimtl = 
          cratext.nmempres =
          cratext.nrsequen =
          cratext.indespac = 
          cratext.nrpagina =
          cratext.nrseqint =
          cratext.dsladopg =
          cratext.dsender1 =
          cratext.dsender2 =
          cratext.nrcepend =
          cratext.dtemissa =
          cratext.nrdordem =
          cratext.tpdocmto =
          cratext.dsintern =

   Alteracoes: 03/01/2007 - Inclusao das variaveis aux_qtmaxarq e aux_nrarquiv
                            (Julio)
                            
               22/08/2007 - Inclusao do campo cratext.numeroar (Diego).
               
               07/02/2008 - Inclusao do campo cratext.complend (Diego).
              
               27/03/2008 - Incluida variaveis aux_numerseq, aux_nomedarq, 
                            aux_numberdc (Gabriel).
                            
               06/02/2009 - Incluida variavel aux_nmdatspt (Diego).
               
               19/04/2010 - Incluir nome de faixa de CEP e PAC na tabela 
                            cratext. Alterar indices (Gabriel).
                            
               06/05/2011 - Incluido os campos nrcepcdd e dscentra na 
                            Temp-Table cratext (Elton).
                            
               12/07/2011 - Incluida a variavel aux_nrseqenv para calculo 
                            de sequencial (crapinf.nrseqenv) no include 
                            gera_dados_inform.i (GATI - Eder).
............................................................................ */
 
DEF    STREAM str_1.
DEF    VAR aux_imlogoex  AS CHAR                                    NO-UNDO.
DEF    VAR aux_imlogoin  AS CHAR                                    NO-UNDO.
DEF    VAR aux_imcorre2  AS CHAR  
       INIT "laser/imagens/reintegracao_correio.pcx"                NO-UNDO.
DEF    VAR aux_imcorre1  AS CHAR  
       INIT "laser/imagens/reintegracao_correio_grande.pcx"         NO-UNDO.
DEF    VAR aux_impostal  AS CHAR
       INIT "laser/imagens/chancela_ect_cecred.pcx"                 NO-UNDO.
DEF    VAR aux_imgvazio  AS CHAR 
       INIT "laser/imagens/vazio.pcx"                               NO-UNDO.
DEF    VAR aux_cdacesso  AS CHAR                                    NO-UNDO.
DEF    VAR aux_dsultlin  AS CHAR                                    NO-UNDO.
DEF    VAR aux_dsmsgext  AS CHAR   EXTENT 7                         NO-UNDO.
DEF    VAR aux_qtintern  AS INTEGER                                 NO-UNDO.
DEF    VAR aux_nmarqimp  AS CHAR                                    NO-UNDO.
DEF    VAR aux_nmarqdat  AS CHAR                                    NO-UNDO.
DEF    VAR aux_nomedarq  AS CHAR                                    NO-UNDO.
DEF    VAR aux_nrsequen  AS INT                                     NO-UNDO.
DEF    VAR aux_nrseqesq  AS INT                                     NO-UNDO.
DEF    VAR aux_nrseqdir  AS INT                                     NO-UNDO.
DEF    VAR aux_nrpagina  AS INT                                     NO-UNDO.
DEF    VAR aux_qtmaxarq  AS INT    INITIAL 0                        NO-UNDO.
DEF    VAR aux_nrarquiv  AS INT    INITIAL 1                        NO-UNDO.
DEF    VAR aux_numberdc  AS INT                                     NO-UNDO.  
DEF    VAR aux_numerseq  AS INT                                     NO-UNDO. 
DEF    VAR aux_nmdatspt  AS CHAR                                    NO-UNDO.
DEF    VAR aux_nrseqenv  AS INTE                                    NO-UNDO.

DEF TEMP-TABLE cratext                                              NO-UNDO 
               FIELD cdagenci  AS  INTE 
               FIELD nmagenci  AS  CHAR   FORMAT "x(24)"
               FIELD nmsecext  AS  CHAR   FORMAT "x(25)"
               FIELD nrdconta  AS  INT    FORMAT "zzzz,zz9,9"
               FIELD nmprimtl  AS  CHAR   FORMAT "x(40)"
               FIELD nmempres  AS  CHAR   FORMAT "x(20)"
               FIELD nrsequen  AS  INT    FORMAT "999,999"
               FIELD indespac  AS  INT  /* 1-Correio / 2-Secao */
               FIELD nrpagina  AS  INT
               FIELD nrseqint  AS  INT
               FIELD dsladopg  AS  CHAR   /* "D" ou "E" */
               FIELD dsender1  LIKE crapenc.dsendere
               FIELD dsender2  LIKE crapenc.dsendere              
               FIELD nrcepend  LIKE crapenc.nrcepend
               FIELD complend  LIKE crapenc.complend
               FIELD dtemissa  AS  DATE
               FIELD nrdordem  AS  INTEGER
               FIELD tpdocmto  AS  INTEGER
               FIELD numeroar  AS  INTEGER
               FIELD dsintern  AS  CHAR   EXTENT 100 FORMAT "x(80)"
               FIELD nomedcdd  AS  CHAR FORMAT "x(35)"
               FIELD nrcepcdd  AS  CHAR FORMAT "x(23)" 
               FIELD dscentra  AS  CHAR FORMAT "x(35)" 
               INDEX cratext1  nrseqint nmagenci nmsecext nrdconta
               INDEX cratext2  nomedcdd nrcepend
               INDEX cratext3  cdagenci nrdconta.

DEFINE BUFFER cratext_dir FOR cratext.

/* ......................................................................... */
