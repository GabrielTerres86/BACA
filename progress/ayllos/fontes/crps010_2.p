/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps010_2.p              | pc_crps010.pc_crps010_2           |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/



/* ..........................................................................

   Programa: Fontes/crps010_2.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Abril/95.                           Ultima atualizacao: 13/09/2013 

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Rotina do resumo do capital.
               Emite resumo mensal do capital (031).

   Alteracoes: 05/05/2004 - Tratar eliminados (Edson).
   
               18/08/2005 - Detalhar os admitidos de cada PAC;
                            Mudado o termo "AGENCIA" por "PAC" (Evandro).
                            
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder             

               22/07/2008 - Alterado para listar debitos a serem efetuados de
                            (Gabriel).
                            
               13/09/2013 - Alterada coluna do FORM f_capital de PAC para PA. 
                            (Reinert)

............................................................................. */

DEF STREAM str_2.     /* Para resumo mensal do capital  */

{ includes/var_batch.i }

{ includes/var_crps010.i }

{ includes/cabrel132_2.i }

/* para listar debitos a serem efetuados de capital a integralizar */
DEF SHARED TEMP-TABLE w_debitos
           FIELD cdagenci LIKE crapass.cdagenci
           FIELD nrdconta LIKE crapass.nrdconta
           FIELD nmprimtl LIKE crapass.nmprimtl
           FIELD dtadmiss LIKE crapass.dtadmiss
           FIELD dtrefere LIKE crapsdc.dtrefere
           FIELD vllanmto LIKE crapsdc.vllanmto
           FIELD tplanmto AS CHAR FORMAT "x(15)"
           INDEX w_debitos1 AS PRIMARY cdagenci nrdconta.

FORM SKIP(1)
     "ATIVOS"        AT  53
     "INATIVOS"      AT  75
     "EXCLUIDOS"     AT  98
     "TOTAL"         AT 126
     SKIP(1)
     /*
     "CAPITAL:" AT 27
     res_vlcapcrz_ati        AT  36 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     res_vlcapcrz_dem        AT  60 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     res_vlcapcrz_exc        AT  84 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     res_vlcapcrz_tot        AT 108 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     SKIP(1)
     "CAPITAL EM MOEDA FIXA:" AT 13
     res_vlcapmfx_ati         AT  36 FORMAT "zz,zzz,zzz,zzz,zz9.9999-"
     res_vlcapmfx_dem         AT  60 FORMAT "zz,zzz,zzz,zzz,zz9.9999-"
     res_vlcapmfx_exc         AT  84 FORMAT "zz,zzz,zzz,zzz,zz9.9999-"
     res_vlcapmfx_tot         AT 108 FORMAT "zz,zzz,zzz,zzz,zz9.9999-"
     SKIP(1)
     "CORRECAO MONETARIA DO EXERCICIO:" AT 3
     res_vlcmicot_ati      AT  36 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     res_vlcmicot_dem      AT  60 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     res_vlcmicot_exc      AT  84 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     res_vlcmicot_tot      AT 108 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     SKIP(1)
     "CORRECAO MONETARIA DO TRIMESTRE:" AT 3
     res_vlcmmcot_ati      AT  36 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     res_vlcmmcot_dem      AT  60 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     res_vlcmmcot_exc      AT  84 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     res_vlcmmcot_tot      AT 108 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     */
     "CAPITAL INTEGRALIZADO::" AT 13
     int_vlcapcrz_ati        AT  36 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     int_vlcapcrz_dem        AT  60 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     int_vlcapcrz_exc        AT  84 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     int_vlcapcrz_tot        AT 108 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     SKIP(1)
     "CAPITAL A INTEGRALIZAR::" AT 12
     sub_vlcapcrz_ati        AT  36 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     sub_vlcapcrz_dem        AT  60 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     sub_vlcapcrz_exc        AT  84 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     sub_vlcapcrz_tot        AT 108 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     SKIP(1) 
     "TOTAL DO CAPITAL SUBSCRITO::" AT 8
     tcs_vlcapcrz_ati        AT  36 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     tcs_vlcapcrz_dem        AT  60 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     tcs_vlcapcrz_exc        AT  84 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     tcs_vlcapcrz_tot        AT 108 FORMAT "zzzz,zzz,zzz,zzz,zz9.99-"
     SKIP(1)
     "COTISTAS:" AT 26
     res_qtcotist_ati      AT  52 FORMAT "zzz,zz9"
     res_qtcotist_dem      AT  76 FORMAT "zzz,zz9"
     res_qtcotist_exc      AT 100 FORMAT "zzz,zz9"
     res_qtcotist_tot      AT 124 FORMAT "zzz,zz9"
     SKIP(1)
     "MATRICULAS DUPLICADAS:" AT 13
     dup_qtcotist_ati      AT  52 FORMAT "zzz,zz9"
     dup_qtcotist_dem      AT  76 FORMAT "zzz,zz9"
     dup_qtcotist_exc      AT 100 FORMAT "zzz,zz9"
     dup_qtcotist_tot      AT 124 FORMAT "zzz,zz9"
     SKIP(2)
     "EVOLUCAO MENSAL DOS ASSOCIADOS" AT 77
     SKIP(1)
     "ATIVOS"   AT 77
     "INATIVOS" AT 99
     SKIP(1)
     "QTD. ASSOCIADOS MES ANTERIOR:" AT 30
     res_qtassati          AT  76 FORMAT "zzz,zz9"
     res_qtassdem          AT 100 FORMAT "zzz,zz9"
     SKIP(1)
     "QTD. ADMISSOES NO MES:" AT 37
     res_qtassmes             AT 76 FORMAT "zzz,zz9" " +"
     SKIP(1)
     "QTD. ASSOC. TRANSF. P/ INATIVOS:" AT 27
     res_qtdemmes_ati      AT  76 FORMAT "zzz,zz9" " -"
     res_qtdemmes_dem      AT 100 FORMAT "zzz,zz9" " +"
     SKIP(1)
     "QTD. ASSOC. EXCLUIDOS NO MES:" AT 30
     res_qtassbai          AT 100 FORMAT "zzz,zz9" " -"
     SKIP(1)
     "QTD. ASSOC. READMITIDOS NO MES:" AT 28
     res_qtdesmes_ati      AT  76 FORMAT "zzz,zz9" " +"
     res_qtdesmes_dem      AT 100 FORMAT "zzz,zz9" " -"
     SKIP(1)
     "QTD. ASSOCIADOS NO FINAL DO MES:" AT 27
     tot_qtassati          AT  76 FORMAT "zzz,zz9" " ="
     tot_qtassdem          AT 100 FORMAT "zzz,zz9" " ="
     SKIP(1)
     "PA"                  AT  38
     "ADMITIDOS"           AT 123
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_capital.

FORM age_dsagenci                   AT  38 FORMAT "x(21)"
     age_qtcotist_ati[aux_contador] AT  76 FORMAT "zzz,zz9"
     age_qtcotist_dem[aux_contador] AT 100 FORMAT "zzz,zz9"
     age_qtassmes_adm[aux_contador] AT 125 FORMAT "zzz,zz9"
     WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABEL WIDTH 132 FRAME f_agencias.

FORM w_debitos.cdagenci     
     w_debitos.nrdconta COLUMN-LABEL "CONTA/DV"
     w_debitos.nmprimtl COLUMN-LABEL "NOME" 
     w_debitos.dtadmiss COLUMN-LABEL "ADMITIDO"
     w_debitos.dtrefere COLUMN-LABEL "REFERENTE"
     w_debitos.vllanmto COLUMN-LABEL "VALOR"
     w_debitos.tplanmto COLUMN-LABEL "TIPO"
     WITH NO-BOX DOWN WIDTH 132 FRAME f_debitos.

OUTPUT STREAM str_2 TO VALUE(glb_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_2 FRAME f_cabrel132_2.

/* Imprime resumo mensal do capital */

IF   CAN-DO("1,2,4,5,7,8,10,11",STRING(MONTH(glb_dtmvtolt)))   THEN
     DO:
         ASSIGN res_vlcmicot_ati = 0
                res_vlcmicot_dem = 0
                res_vlcmicot_exc = 0
                res_vlcmicot_tot = 0
                res_vlcapmfx_ati = 0
                res_vlcapmfx_dem = 0
                res_vlcapmfx_exc = 0
                res_vlcapmfx_tot = 0
                res_vlcmmcot_ati = 0
                res_vlcmmcot_dem = 0
                res_vlcmmcot_exc = 0
                res_vlcmmcot_tot = 0.
     END.

dup_qtcotist_tot = dup_qtcotist_ati + dup_qtcotist_dem + dup_qtcotist_exc.

ASSIGN int_vlcapcrz_ati = res_vlcapcrz_ati
       int_vlcapcrz_dem = res_vlcapcrz_dem
       int_vlcapcrz_exc = res_vlcapcrz_exc
       int_vlcapcrz_tot = res_vlcapcrz_tot

       tcs_vlcapcrz_ati = res_vlcapcrz_ati + sub_vlcapcrz_ati
       tcs_vlcapcrz_dem = res_vlcapcrz_dem + sub_vlcapcrz_dem
       tcs_vlcapcrz_exc = res_vlcapcrz_exc + sub_vlcapcrz_exc
       tcs_vlcapcrz_tot = res_vlcapcrz_tot + sub_vlcapcrz_tot.

DISPLAY STREAM str_2
        /*
        res_vlcapcrz_ati  res_vlcapcrz_dem  res_vlcapcrz_exc  res_vlcapcrz_tot
        res_vlcapmfx_ati  res_vlcapmfx_dem  res_vlcapmfx_exc  res_vlcapmfx_tot
        res_vlcmicot_ati  res_vlcmicot_dem  res_vlcmicot_exc  res_vlcmicot_tot
        res_vlcmmcot_ati  res_vlcmmcot_dem  res_vlcmmcot_exc  res_vlcmmcot_tot
        */
        res_qtcotist_ati  res_qtcotist_dem  res_qtcotist_exc  res_qtcotist_tot
        dup_qtcotist_ati  dup_qtcotist_dem  dup_qtcotist_exc  dup_qtcotist_tot
        
        tcs_vlcapcrz_ati  int_vlcapcrz_ati  sub_vlcapcrz_ati
        tcs_vlcapcrz_dem  int_vlcapcrz_dem  sub_vlcapcrz_dem
        tcs_vlcapcrz_exc  int_vlcapcrz_exc  sub_vlcapcrz_exc
        tcs_vlcapcrz_tot  int_vlcapcrz_tot  sub_vlcapcrz_tot

        res_qtassati      res_qtassdem      res_qtassmes
        res_qtdemmes_ati  res_qtdemmes_dem  res_qtassbai
        res_qtdesmes_ati  res_qtdesmes_dem
        tot_qtassati      tot_qtassdem
        WITH FRAME f_capital.

DO aux_contador = 1 TO 599:

   IF   age_qtcotist_ati[aux_contador] = 0   AND
        age_qtcotist_dem[aux_contador] = 0   AND
        age_qtassmes_adm[aux_contador] = 0   THEN
        NEXT.
       FIND crapage WHERE crapage.cdcooper = glb_cdcooper   AND
                      crapage.cdagenci = aux_contador   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapage   THEN
        age_dsagenci = STRING(aux_contador,"999") + " - NAO CADASTRADA".
   ELSE
        age_dsagenci = STRING(crapage.cdagenci,"999") + " - " +
                       crapage.nmresage.

   /* TOTAL */
   IF   aux_contador = 559   THEN
        DO:
            /* pula 1 linha */
            DOWN 1 STREAM str_2 WITH FRAME f_agencias.

            DISPLAY STREAM str_2
                    "TOTAIS" @ age_dsagenci
                    age_qtcotist_ati[aux_contador] 
                    age_qtcotist_dem[aux_contador]
                    age_qtassmes_adm[aux_contador]
                    WITH FRAME f_agencias.
        END.
   ELSE                
        DO:
            DISPLAY STREAM str_2
                    age_dsagenci
                    age_qtcotist_ati[aux_contador] 
                    age_qtcotist_dem[aux_contador]
                    age_qtassmes_adm[aux_contador]
                    WITH FRAME f_agencias.

            /* acumula o total no indice 559 */
            ASSIGN age_qtcotist_ati[559] = age_qtcotist_ati[559] + 
                                           age_qtcotist_ati[aux_contador]
                   age_qtcotist_dem[559] = age_qtcotist_dem[559] + 
                                           age_qtcotist_dem[aux_contador]
                   age_qtassmes_adm[559] = age_qtassmes_adm[559] + 
                                           age_qtassmes_adm[aux_contador].
        END.
        
   DOWN STREAM str_2 WITH FRAME f_agencias.


END.  /*  Fim do DO .. TO  */

DISPLAY STREAM str_2 SKIP(1).

PAGE STREAM str_2.

FOR EACH w_debitos NO-LOCK:

    DISPLAY STREAM str_2 w_debitos WITH FRAME f_debitos.

    DOWN STREAM str_2 WITH FRAME f_debitos.

END.

DISPLAY STREAM str_2 
               tot_lancamen AT 09 NO-LABEL
               tot_vllanmto AT 83 NO-LABEL WITH WIDTH 132.
                     
OUTPUT STREAM str_2 CLOSE.

/* .......................................................................... */
