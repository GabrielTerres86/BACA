/* ..........................................................................

   Programa: Includes/var_crps005.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Agosto/2004.                       Ultima atualizacao: 25/10/2013
      

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Definicao das variaveis utilizadas pelo programa crps005.p.

   Alteracoes: 11/08/2005 - Criada FRAME para exibir titulo de ESTOUROS(Diego).
   
               14/10/2005 - Criada FRAME de aviso caso nao ocorram registros
                            na RELACAO DE ESTOUROS(FUNCION./ESTAGIAR./CONSELH.)
                            (Diego).
                            
               08/07/2013 - Criar variaveis para listar valor bloqueado 
                            judicialmente - Passig
                            
               21/10/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme F. Gielow).                            
                            
               25/10/2013 - Alterados Arrays para o tamanho 999. (Reinert)             
............................................................................ */

DEF {1} SHARED VAR rel_nrmodulo AS INT     FORMAT "9"                NO-UNDO.
DEF {1} SHARED VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                   INIT ["DEP. A VISTA   ","CAPITAL        ",
                                         "EMPRESTIMOS    ","DIGITACAO      ",
                                         "GENERICO       "]          NO-UNDO.
DEF {1} SHARED VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
DEF {1} SHARED VAR rel_nmempres AS CHAR                              NO-UNDO.

DEF {1} SHARED VAR rel_vlmaidep AS DECIMAL                           NO-UNDO.
DEF {1} SHARED VAR rel_vlestour AS DECIMAL                           NO-UNDO.
DEF {1} SHARED VAR rel_vlsldneg AS DECIMAL                           NO-UNDO.


DEF {1} SHARED VAR rel_dsagenci AS CHAR    FORMAT "x(21)"            NO-UNDO.
DEF {1} SHARED VAR rel_dsdacstp AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR aux_vlsaqmax AS DECIMAL                           NO-UNDO.

DEF {1} SHARED VAR rel_vlsldliq AS DECIMAL EXTENT 3                  NO-UNDO.

DEF {1} SHARED VAR rel_vlsdbltl AS DECIMAL                           NO-UNDO.
DEF {1} SHARED VAR rel_vlstotal AS DECIMAL                           NO-UNDO.
DEF {1} SHARED VAR rel_dslimite AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR rel_nrcpfcgc AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR rel_titestou AS CHAR                              NO-UNDO.

DEF {1} SHARED VAR aux_nmarquiv AS CHAR                              NO-UNDO.

DEF {1} SHARED VAR lis_agnsddis AS DECIMAL EXTENT 999                NO-UNDO.
DEF {1} SHARED VAR lis_agnvllim AS DECIMAL EXTENT 999                NO-UNDO.
DEF {1} SHARED VAR lis_agnsdbtl AS DECIMAL EXTENT 999                NO-UNDO.
DEF {1} SHARED VAR lis_agnsdchs AS DECIMAL EXTENT 999                NO-UNDO.
DEF {1} SHARED VAR lis_agnsdstl AS DECIMAL EXTENT 999                NO-UNDO.
DEF {1} SHARED VAR lis_agnvlbjd AS DECIMAL EXTENT 999                NO-UNDO.
                                                    
DEF {1} SHARED VAR tot_agnsddis AS DECIMAL EXTENT 999                NO-UNDO.
DEF {1} SHARED VAR tot_agnvllim AS DECIMAL EXTENT 999                NO-UNDO.
DEF {1} SHARED VAR tot_agnsdbtl AS DECIMAL EXTENT 999                NO-UNDO.
DEF {1} SHARED VAR tot_agnsdchs AS DECIMAL EXTENT 999                NO-UNDO.
DEF {1} SHARED VAR tot_agnsdstl AS DECIMAL EXTENT 999                NO-UNDO.
DEF {1} SHARED VAR tot_agnvlbjd AS DECIMAL EXTENT 999                NO-UNDO.
                                                    
DEF {1} SHARED VAR dem_agpsdmax AS DECIMAL EXTENT 999                NO-UNDO.
DEF {1} SHARED VAR dem_agpsddis AS DECIMAL EXTENT 999                NO-UNDO.
DEF {1} SHARED VAR dem_agpvllim AS DECIMAL EXTENT 999                NO-UNDO.
DEF {1} SHARED VAR dem_agpsdbtl AS DECIMAL EXTENT 999                NO-UNDO.
DEF {1} SHARED VAR dem_agpsdchs AS DECIMAL EXTENT 999                NO-UNDO.
DEF {1} SHARED VAR dem_agpsdstl AS DECIMAL EXTENT 999                NO-UNDO.
DEF {1} SHARED VAR dem_agpvlbjd AS DECIMAL EXTENT 999                NO-UNDO.


DEF {1} SHARED VAR tot_vlutiliz AS DECIMAL                           NO-UNDO.
DEF {1} SHARED VAR tot_vlsaqblq AS DECIMAL                           NO-UNDO.
DEF {1} SHARED VAR tot_vladiant AS DECIMAL                           NO-UNDO.



DEF {1} SHARED VAR rel_agpsdmax AS DECIMAL  EXTENT 4                 NO-UNDO.
DEF {1} SHARED VAR rel_agpsddis AS DECIMAL  EXTENT 4                 NO-UNDO.
DEF {1} SHARED VAR rel_agpvllim AS DECIMAL  EXTENT 4                 NO-UNDO.
DEF {1} SHARED VAR rel_agpsdbtl AS DECIMAL  EXTENT 4                 NO-UNDO.
DEF {1} SHARED VAR rel_agpsdchs AS DECIMAL  EXTENT 4                 NO-UNDO.
DEF {1} SHARED VAR rel_agpsdstl AS DECIMAL  EXTENT 4                 NO-UNDO.
DEF {1} SHARED VAR rel_agpvlbjd AS DECIMAL  EXTENT 4                 NO-UNDO.


DEF {1} SHARED VAR rel_vlsaqblq AS DECIMAL  EXTENT 3                 NO-UNDO. 
DEF {1} SHARED VAR rel_vlbloque AS DECIMAL  EXTENT 3                 NO-UNDO.
DEF {1} SHARED VAR rel_vldisneg AS DECIMAL  EXTENT 3                 NO-UNDO.
DEF {1} SHARED VAR rel_vldispos AS DECIMAL  EXTENT 3                 NO-UNDO. 
DEF {1} SHARED VAR rel_vlsutili AS DECIMAL  EXTENT 3                 NO-UNDO.
DEF {1} SHARED VAR rel_vlsadian AS DECIMAL  EXTENT 3                 NO-UNDO.
DEF {1} SHARED VAR rel_vladiclq AS DECIMAL  EXTENT 3                 NO-UNDO.

                                
DEF {1} SHARED VAR rel_vlblqjud AS DECIMAL  EXTENT 4                 NO-UNDO.
DEF {1} SHARED VAR rel_agpsdbjd AS DECIMAL  EXTENT 4                 NO-UNDO.

DEF {1} SHARED VAR rel_agnsddis AS DECIMAL  EXTENT 4                 NO-UNDO.
DEF {1} SHARED VAR rel_agnvllim AS DECIMAL  EXTENT 4                 NO-UNDO.
DEF {1} SHARED VAR rel_agnsdbtl AS DECIMAL  EXTENT 4                 NO-UNDO.
DEF {1} SHARED VAR rel_agnsdchs AS DECIMAL  EXTENT 4                 NO-UNDO.
DEF {1} SHARED VAR rel_agnsdstl AS DECIMAL  EXTENT 4                 NO-UNDO.
DEF {1} SHARED VAR rel_agnvlbjd AS DECIMAL  EXTENT 4                 NO-UNDO.

DEF {1} SHARED VAR aux_linhadet AS CHAR                              NO-UNDO.

DEF {1} SHARED VAR aux_flgfirst AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_descrica AS CHAR     FORMAT "x(15)"           NO-UNDO.

DEF {1} SHARED VAR aux_flgnegat AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgimprm AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_cdagenci AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_vlbloque AS DECIMAL                           NO-UNDO.

DEF {1} SHARED VAR aux_flgdemit AS LOGICAL                           NO-UNDO.


DEF {1} SHARED VAR rel_nrdofone AS CHAR                              NO-UNDO.


/* UTILIZADOS PARA CONTABILIDADE */

DEF {1} SHARED VAR con_dtmvtolt AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR con_dtmvtopr AS CHAR                              NO-UNDO.

DEF {1} SHARED VAR aux_nmarqsai AS CHAR                              NO-UNDO.

DEF {1} SHARED VAR aux_qttotass AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_totsddis AS DEC                               NO-UNDO.
DEF {1} SHARED VAR aux_totvllim AS DEC                               NO-UNDO.
DEF {1} SHARED VAR aux_totsdbtl AS DEC                               NO-UNDO.
DEF {1} SHARED VAR aux_totsdchs AS DEC                               NO-UNDO.
DEF {1} SHARED VAR aux_totsdstl AS DEC                               NO-UNDO.


FORM SKIP(1) WITH NO-BOX NO-ATTR-SPACE WIDTH 80 FRAME f_linha.

FORM "PA: " 
     rel_dsagenci AT  6 FORMAT "x(21)" 
     rel_dslimite AT 50 FORMAT "x(70)" 
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_agencia.
     
FORM rel_titestou AT 1  FORMAT "x(51)"
     rel_dslimite AT 55 FORMAT "x(70)"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_esttouro.
     
FORM SKIP(1)
     "RELACAO DE ESTOUROS(FUNCION./ESTAGIAR./CONSELH.)"  AT 1 SKIP(2)
     "   ==>  NAO APRESENTOU NENHUM REGISTRO  <=="  
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS SIDE-LABELS WIDTH 132
     FRAME f_estouro226.

FORM SKIP(1)
     "TOTAL"
     aux_qttotass AT  16         FORMAT "zzz9"
     aux_totsddis AT  26         FORMAT "zzz,zzz,zz9.99-"
     aux_totvllim AT  47         FORMAT "zzzz,zzz"
     aux_totsdbtl AT  61         FORMAT "zzz,zzz,zz9.99-"
     aux_totsdchs AT  82         FORMAT "zzz,zzz,zz9.99-"
     aux_totsdstl AT 103         FORMAT "zzz,zzz,zz9.99-"
     WITH NO-BOX DOWN NO-LABEL WIDTH 132 FRAME f_TotalGeral.

/* .......................................................................... */

