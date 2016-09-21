/* ............................................................................
 
   Programa: includes/var_movgps_r.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Janeiro/2009                   Ultima alteracao: 09/08/2013

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Criar as variaveis e form's do relatorio gerado pela opcao "R" 
               da tela "MOVGPS" e do programa batch "crps523".
               
               
   Alteracoes: 15/07/2009 - Alteracao CDOPERAD (Diego).
               
               09/08/2013 - 0Modificado o termo "PAC" para "PA" (Douglas). 

............................................................................. */
 
 DEFINE TEMP-TABLE crawlgp                                            NO-UNDO
       FIELD  cdagenci  LIKE craplgp.cdagenci
       FIELD  nrdcaixa  LIKE craplgp.nrdcaixa
       FIELD  nmoperad  LIKE crapope.nmoperad
       FIELD  cdbccxlt  LIKE craplgp.cdbccxlt
       FIELD  nrdolote  LIKE craplgp.nrdolote
       FIELD  vlrdinss  LIKE craplgp.vlrdinss
       FIELD  vlrtotal  LIKE craplgp.vlrtotal
       FIELD  cdidenti  LIKE craplgp.cdidenti
       FIELD  vlrouent  LIKE craplgp.vlrouent
       FIELD  vlrjuros  LIKE craplgp.vlrjuros
       FIELD  mmaacomp  LIKE craplgp.mmaacomp
       FIELD  nrdconta  LIKE crapcgp.nrdconta
       FIELD  nmprimtl  LIKE crapcgp.nmprimtl
       FIELD  cddpagto  LIKE craplgp.cddpagto
       FIELD  tpcontri  LIKE crapcgp.tpcontri
       INDEX crawlgp1 cdagenci nrdolote vlrdinss.


DEF     VAR aux_cdagefim    LIKE   craplgp.cdagenci                  NO-UNDO.
DEF     VAR aux_nrdcaixa    LIKE   craplgp.nrdcaixa                  NO-UNDO.
DEF     VAR aux_nmarqimp    AS CHAR                                  NO-UNDO.

/* totais */
DEF     VAR rel_vltotpag    AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF     VAR rel_vltotpag_cx AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF     VAR rel_vltotpag_tt AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF     VAR rel_contagui    AS INTEGER                               NO-UNDO.
DEF     VAR rel_contavlr    AS DECIMAL                               NO-UNDO.
DEF     VAR rel_totguias    AS INTEGER                               NO-UNDO.
DEF     VAR rel_totalvlr    AS DECIMAL                               NO-UNDO.

/* variaveis cabecalho */
DEF     VAR rel_nmempres    AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF     VAR rel_nmrelato    AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF     VAR rel_nrmodulo    AS INT     FORMAT "9"                    NO-UNDO.
DEF     VAR rel_nmmodulo    AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.
DEF     VAR rel_nmmesref    AS CHAR    FORMAT "x(014)"               NO-UNDO.
DEF     VAR rel_nmresemp    AS CHAR    FORMAT "x(15)"                NO-UNDO.
     
/* variaveis para impressao */
DEF        VAR par_flgrodar AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_nmoperad AS CHAR    FORMAT "x(24)"                NO-UNDO.
DEF        VAR tel_hrtransa AS CHAR                                  NO-UNDO.

FORM "PA - " craplgp.cdagenci
     SKIP(1)
     WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_pac.
     
FORM "CAIXA - " craplgp.nrdcaixa
     "LOTE  - " craplgp.nrdolote
     SKIP(1)
     WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_caixa.
     
FORM tel_hrtransa       COLUMN-LABEL "Hora"             
     craplgp.cddpagto   COLUMN-LABEL "Cd.Pto"        
     craplgp.mmaacomp   COLUMN-LABEL "Compete."
     craplgp.cdidenti   COLUMN-LABEL "Cd.Identificador"
     craplgp.vlrdinss   COLUMN-LABEL "Valor INSS"       FORMAT "z,zzz,zz9.99" 
     craplgp.vlrouent   COLUMN-LABEL "Valor Outros"     FORMAT "z,zzz,zz9.99"
     craplgp.vlrjuros   COLUMN-LABEL "Valor Juros"      FORMAT "z,zzz,zz9.99" 
     craplgp.vlrtotal   COLUMN-LABEL "Valor Total"      FORMAT "z,zzz,zz9.99" 
     craplgp.nrautdoc   COLUMN-LABEL "Autent."
     aux_nmoperad       COLUMN-LABEL "Operador"
     craplgp.flgenvio   COLUMN-LABEL "Env."             FORMAT "Sim/Nao"
     SKIP
     WITH DOWN NO-BOX  WIDTH 132 FRAME f_valores.

FORM craplgp.cdagenci          AT 24  LABEL "PA"        FORMAT "zz9"
     rel_contagui              AT 31  LABEL "QTD.GUIAS" FORMAT "zzz,zz9"
     rel_contavlr              AT 43  LABEL "VALOR"     FORMAT "zzz,zzz,zz9.99"
     WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_guias.

FORM SKIP(1)
     "TOTAL GERAL"             AT 18
     rel_totguias              AT 33  FORMAT "zzz,zz9"
     rel_totalvlr              AT 43  FORMAT "zzz,zzz,zz9.99"
     WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_geral_guias.

FORM "Aguarde... Imprimindo..."
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

/* .......................................................................... */
 
