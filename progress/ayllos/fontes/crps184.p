/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps184.p                | pc_crps184                        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/










/* ..........................................................................

   Programa: fontes/crps184.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Fevereiro/2006                  Ultima atualizacao: 02/08/2013

   Dados referentes ao programa:

   Frequencia: Tela.
   Objetivo  : Atende a solicitacao 104.
               Emite relatorio da provisao para creditos de liquidacao duvidosa
               (227).

   Alteracoes: 16/02/2006 - Criadas variaveis p/ listagem de Riscos por PAC
                            (Diego).
                            
               04/12/2009 - Retirar o nao uso mais do buffer crabass 
                            e aux_recid (Gabriel).             

               24/08/2010 - Incluir w-crapris.qtatraso (Magui).
               
               25/08/2010 - Inclusao das variaveis aux_rel1725, aux_rel1726,
                            aux_rel1725_v, aux_rel1726_v. Devido a alteracao
                            na includes crps280.i (Adriano).
                            
               19/10/2012 - Incluido variaveis aux_rel1724 devido as alteracoes
                            na include crps280.i (Rafael).
                            
               22/04/2013 - Incluido os campos cdorigem, qtdiaatr na criacao 
                            da temp-table w-crapris (Adriano).   
                            
               21/06/2013 - Adicionado campo w-crapris.nrseqctr (Lucas)
               
               02/08/2013 - Removido a declaracao da temp-table w-crapris.
                            (Fabricio)
                            
............................................................................. */

DEF STREAM str_1.     /*  Relatorio da provisao  */
DEF STREAM str_2.     /*  Relatorio Auditoria    */
DEF STREAM str_3.     /*  Arquivo Texto operacoes credito em dia */

{ includes/var_batch.i "NEW" }

DEF        VAR rel_dsagenci     AS CHAR    FORMAT "x(21)"            NO-UNDO.

DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR tot_qtctremp AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tot_qtctrato AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tot_qttotal  AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tot_vlpreatr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tot_vldespes AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tot_vltotal  AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tot_vlsdvatr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tot_vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.

DEF        VAR ger_qtctremp AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR ger_qtctrato AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR ger_vlpreatr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR ger_vldespes AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR aux_qtpreatr AS INT                                   NO-UNDO.
DEF        VAR aux_qtpresta AS INT                                   NO-UNDO.
DEF        VAR aux_vlpreatr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR aux_vltotatr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.

DEF        VAR aux_vlpercen AS DECIMAL FORMAT "zz9.9999"             NO-UNDO.
DEF        VAR aux_percentu AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR aux_percbase AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR aux_vldabase AS DECI    FORMAT "zzz,zzz,zzz,zz9.99" 
                                                         EXTENT 20   NO-UNDO.
DEF        VAR aux_qtdabase AS INT     FORMAT "zzz,zz9"  EXTENT 20   NO-UNDO.
DEF        VAR aux_vlprovis AS DECI    FORMAT "zzz,zzz,zzz,zz9.99"  
                                                         EXTENT 20   NO-UNDO.

DEF        VAR ger_vlprovis AS DECI    FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR ger_qtdabase AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR ger_vldabase AS DECI    FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.

DEF        VAR rel_dsdrisco AS CHAR    FORMAT "x(02)"    EXTENT 20   NO-UNDO.
DEF        VAR rel_percentu AS DECI    FORMAT "zz9.99"   EXTENT 20   NO-UNDO.
DEF        VAR rel_vldabase AS DECI    FORMAT "zzz,zzz,zzz,zz9.99" 
                                                         EXTENT 20   NO-UNDO.
DEF        VAR rel_qtdabase AS INT     FORMAT "zzz,zz9"  EXTENT 20   NO-UNDO.
DEF        VAR rel_vlprovis AS DECI    FORMAT "zzz,zzz,zzz,zz9.99"  
                                                         EXTENT 20   NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR tot_vlprovis AS DECI    FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tot_qtdabase AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tot_qtempres AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tot_vldabase AS DECI    FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tot_vlatraso AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tot_percentu AS DECIMAL FORMAT "zz9.99"               NO-UNDO.

DEF        VAR atr_qtctremp AS INT                                   NO-UNDO.
DEF        VAR atr_vlatraso AS DECIMAL                               NO-UNDO.
DEF        VAR atr_qtempres AS INT                                   NO-UNDO.
DEF        VAR atr_vlsdeved AS DECIMAL                               NO-UNDO.
DEF        VAR atr_percentu AS DECIMAL                               NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_vldivida LIKE crapris.vldivida                    NO-UNDO.
DEF        VAR aux_vlprejuz_conta AS DECIMAL                         NO-UNDO.
DEF        VAR aux_vlprejuz  AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.

DEF        VAR aux_rel1721   AS  DECI   FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1723   AS  DECI   FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1724   AS  DECI   FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1731_1 AS  DECI   FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1731_2 AS  DECI   FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1722_0101 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1722_0299 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1722_0201 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
   
DEF        VAR aux_rel1721_v   AS  DECI   FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1724_v   AS  DECI   FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1724_c    AS  DECI  FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1724_v_c  AS  DECI  FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1724_sr   AS  DECI  FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1724_v_sr AS  DECI  FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1724_cr   AS  DECI  FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1724_v_cr AS  DECI  FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1731_1_v AS  DECI   FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1731_2_v AS  DECI   FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1723_v   AS  DECI   FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1722_0101_v AS DECI FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1722_0299_v AS DECI FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_rel1722_0201_v AS DECI FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_cdorigem       AS CHAR FORMAT "x(01)"               NO-UNDO.
DEF        VAR aux_ttprovis       AS DECI FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_ttdivida       AS DECI FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF        VAR aux_qtmesdec       AS DEC                               NO-UNDO.
DEF        VAR aux_nmarqimp       AS CHAR                              NO-UNDO.
DEF        VAR aux_arq_excell     AS CHAR                              NO-UNDO.
DEF        VAR aux_diarating      AS INT                               NO-UNDO.
DEF        VAR aux_dtmvtolt       AS DATE                              NO-UNDO.
DEF        VAR aux_atualiz_rating AS CHAR FORMAT "x(01)"               NO-UNDO.

DEF SHARED VAR tel_dtrefere       AS DATE    FORMAT "99/99/9999"       NO-UNDO.


ASSIGN glb_cdprogra = "crps184"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

       /* Data informada na tela */
ASSIGN aux_dtrefere = tel_dtrefere
       
       /* Variavel criada como local ("NEW") e alterada somente para data de
          referencia do relatorio. Sera destruida ao fim do programa */
       glb_dtmvtolt = tel_dtrefere.

{ includes/crps280.i }

RUN fontes/fimprg.p.  
/* .......................................................................... */

