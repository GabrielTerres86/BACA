/* .........................................................................

   Programa: includes/var_cnab.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Agosto/2004.                        Ultima atualizacao: 10/10/2012

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Declaracao da tabela de parametros para construcao de arquivos
               padrao CNAB.

   Alteracoes: 10/10/2012 - Tratamento para substituição do 'dshistor' por
                            'dsextrat' (Lucas) [Projeto Tarifas].

............................................................................ */

DEFINE {1} SHARED TEMP-TABLE  cratarq  
                  FIELD  vlsldini LIKE crapsld.vlsddisp        /*E002*/
                  FIELD  vlsldfin LIKE crapsld.vlsddisp        /*E020*/
                  FIELD  vlmais24 LIKE crapsld.vlsddisp        /*E016*/
                         /*Saldo bloqueado mais de 24h*/    
                  FIELD  vlmeno24 LIKE crapsld.vlsddisp        /*E018*/
                         /*Saldo bloqueado ate 24h*/

                  FIELD  cdbccxlt LIKE crapban.cdbccxlt        /*G001*/
                  FIELD  nrdolote LIKE craplot.nrdolote        /*G002*/
                  FIELD  tpregist AS INT                       /*G003*/
                  FIELD  inpessoa LIKE crapass.inpessoa        /*G005*/
                  FIELD  nrcpfcgc LIKE crapass.nrcpfcgc        /*G006*/
                  FIELD  cdconven AS CHARACTER  FORMAT "x(20)" /*G007*/
                  FIELD  cdagenci LIKE crapass.cdagenci        /*G008*/
                  FIELD  nrdconta LIKE crapass.nrdconta        /*G010*/
                  FIELD  nrdigcta AS INT                       /*G011*/
                  FIELD  nmresemp LIKE crapemp.nmresemp        /*G013*/
                  FIELD  nmprimtl LIKE crapass.nmprimtl        /*G013*/
                  FIELD  nmrescop LIKE crapcop.nmrescop        /*G014*/
                  FIELD  cdremess AS INT                       /*G015*/
                  FIELD  dtmvtolt LIKE craplcm.dtmvtolt        /*G016*/
                  FIELD  hrtransa AS INTEGER                   /*G017*/
                  FIELD  nrseqarq AS INTEGER                   /*G018*/
                  FIELD  tpservco AS INTEGER                   /*G025*/
                  FIELD  cdsegmto AS CHARACTER                 /*G039*/
                  FIELD  tpmovmto AS INTEGER                   /*G060*/
                  FIELD  dtsldini LIKE craplcm.dtmvtolt        /*G080*/
                  FIELD  insldini LIKE craphis.indebcre        /*G081*/
                  FIELD  iniscpmf AS CHAR   FORMAT "x(1)"      /*G087*/
                  FIELD  dtliblan LIKE crapdpb.dtliblan        /*G088*/
                  FIELD  dtlanmto LIKE craplcm.dtmvtolt        /*G089*/
                  FIELD  vllanmto LIKE craplcm.vllanmto        /*G090*/
                  FIELD  indebcre LIKE craphis.indebcre        /*G091*/
                  FIELD  cdhistor LIKE craphis.cdhistor        /*G093*/
                  FIELD  dsextrat LIKE craphis.dsextrat        /*G094*/
                  FIELD  nrdocmto AS CHAR                      /*G095*/
                  FIELD  vllimite LIKE craplim.vllimite        /*G096*/
                  FIELD  dtsldfin LIKE craplcm.dtmvtolt        /*G097*/
                  FIELD  insldfin LIKE craphis.indebcre        /*G098*/

                  FIELD  dtmesref AS INTEGER                   /*H002*/
                  FIELD  dtanoref AS INTEGER                   /*H003*/
                  FIELD  cdempres AS INTEGER                   /*H004*/
                  FIELD  nrcadast LIKE crapass.nrcadast        /*H007*/
                  FIELD  tpoperac AS INTEGER                   /*H015*/
                  FIELD  dtdiavec AS INTEGER                   /*H016*/
                  FIELD  dtmesvec AS INTEGER                   /*H017*/
                  FIELD  dtanovec AS INTEGER                   /*H018*/
                  FIELD  qtprepag LIKE crapepr.qtprepag        /*H019*/
                  FIELD  qtpreemp LIKE crapepr.qtpreemp        /*H020*/
                  FIELD  dtdpagto LIKE crawepr.dtdpagto        /*H021*/
                  FIELD  dtultpag LIKE crapepr.dtultpag        /*H022*/
                  FIELD  vlemprst LIKE crapepr.vlemprst        /*H023*/
                  FIELD  vlpreemp LIKE crapepr.vlpreemp        /*H025*/
                  FIELD  vlsdeved LIKE crapepr.vlsdeved        /*H026*/
                  FIELD  nrctremp LIKE crapepr.nrctremp        /*H027*/
                  FIELD  qtdcrato AS INTEGER.                  /*H028*/

/* ......................................................................... */
