/* .............................................................................

   Programa: Fontes/nome.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/95.                       Ultima atualizacao: 15/01/2009 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela NOME -- Consultar o cadastro em ordem alfabetica.

   Alteracoes: 02/04/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               23/12/98 - Colocar a empresa na tela e permitir a consulta ao
                          segundo titular (Deborah).

               18/02/99 - Incluido pequisa no nome do conjuge, dos pais e 
                          por agencia (Deborah).

               10/03/2004 - Alterado programa para melhorar a performance.
                            (Separado em procedures)(Mirtes)
                            
               05/05/2004 - Acerto de programa (Ze Eduardo).          
                  
               03/09/2004 - Tratar conta integracao (Margarete).   
               
               01/02/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               25/05/2007 - Registrar em log as pesquisas de nome (Edson).
               
               25/10/2007 - Usar campo nmdsecao a partir da crapttl(Guilherme).
               
               15/01/2009 - Excluido FRAME f_dados, pois o mesmo esta
                            declarado no fontes/zoom_associados.p (Diego).
               
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_nmpesqui AS CHAR    FORMAT "x(39)"                NO-UNDO.
DEF        VAR tel_nrcpfcgc AS CHAR    FORMAT "x(18)"                NO-UNDO.
DEF        VAR tel_dsagenci AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR tel_dsempres AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR tel_tipopesq AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR tel_nmtitula AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_dtnasctl AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_cdagenci AS INT     FORMAT "z9"                   NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_stimeout AS INT                                   NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_pesquisa AS CHAR                                  NO-UNDO.    
FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.
     
VIEW FRAME f_moldura.

PAUSE(0).

glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "nome"   THEN
                 DO:
                     HIDE FRAME f_nome.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   RUN fontes/zoom_associados.p(INPUT  glb_cdcooper,
                                OUTPUT aux_contador).

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

