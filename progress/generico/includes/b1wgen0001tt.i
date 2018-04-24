/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps217.p                | BTCH0002.pc_crps217               |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/



/*..............................................................................

   Programa: b1wgen0001tt.i                  
   Autor   : David
   Data    : Agosto/2007                      Ultima atualizacao: 10/12/2015

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0001.p

   Alteracoes: 04/10/2007 - Retirada temp-table tt-extrato_inv (David).
   
               22/11/2007 - Incluir Seg. Tit. no tt-cabec - CASH - FOTON (Ze).
               
               12/12/2007 - Incluir vllimite no tt-cabec - CASH - FOTON (Ze).
               
               07/02/2008 - Incluir tt-comp_cabec, tt-saldo_vista (Guilherme)
                            Incluir campos na tt-valores_conta (David).
                            
               24/03/2008 - Retirar campo vlsldcta (David).            
                
               19/05/2008 - Modificar format do historico do extrato (David)
               
               16/07/2008 - Incluir tt-extrato_cheque
                          - Adicionado campos cdagenci cdbccxlt nrdolote na
                            tt-extrato_conta p/ utilizar no extrat.p(Guilherme)
               
               06/08/2008 - Incluir qtcarmag na tt-valores_conta (Guilherme).
               
               11/02/2009 - Incluir temp-table`s para procedure 
                            gera_extrato_tarifas (Gabriel).
                            
               16/02/2009 - Alteracao cdempres (Diego).

               04/03/2009 - Incluir campo inpessoa na tt-cabec (David).
               
               15/07/2009 - Incluir campo dssititg na tt-cabec 
                          - Incluir INDEX tt-busca1 (Guilherme).

               24/09/2009 - Incluir campo dsidenti na tt-extrato_conta (David).
               
               14/04/2010 - Adicionado campo para saldo de envelopes que foram
                            depositados no cash na tt-saldos (Evandro).
                            
               02/09/2010 - Ajustes para rotina DEP.VISTA (David).      
               
               13/12/2010 - Incluir campo do valor da rotina de cobranca
                            (Gabriel).       
                            
               29/08/2011 - Adicionado campo numero de parcela (nrparepr)
                            na temp-table tt-extrato_conta (Diego B. - GATI).
     
               06/09/2011 - Incluir campo de qts titulares na conta
                            na temp-table do cabecalho  (Gabriel) 
                            
               15/09/2011 - Criar indice na tt-extrato_conta (David).
               
               10/10/2012 - Criação do campo 'dsextrat' na temp-table
                            'tt-extrato_conta' (Lucas) [Projeto Tarifas].
                            
               03/06/2013 - Incluido na tt-extrato-conta, tt-saldos o campo
                            FIELD vlblqjud LIKE crapblj.vlbloque
                            (Andre Santos - SUPERO)
                            
               23/08/2013 - Substituir campo crapass.dsnatura pelo campo
                            crapttl.dsnatura (David).
                            
               05/09/2014 - Incluido na tt-extrato-conta o campo nrseqlmt 
                            CHAMADO: 161899 - (Jonathan - RKAM)
                            
               05/10/2015 - Incluido na tt-valores_conta o limite de saque do TAA.
                            (James)
                            
               14/10/2015 - Adicionado novos campos média do mês atual e dias úteis decorridos.
						    SD 320300 (Kelvin).
                            
               06/11/2015 - Adicionada coluna indebcre na tt-tarifas.
............................................................................. */

DEF TEMP-TABLE tt-valores_conta NO-UNDO
    FIELD vlsldcap AS DECI 
    FIELD vlsldepr AS DECI
    FIELD vlsldapl AS DECI
    FIELD vlsldinv AS DECI
    FIELD vlsldppr AS DECI
    FIELD vlstotal AS DECI
    FIELD vllimite AS DECI
    FIELD qtfolhas AS INTE
    FIELD qtconven AS INTE
    FIELD flgocorr AS LOGI
    FIELD dssitura AS CHAR
    FIELD vllautom AS DECI
    FIELD dssitnet AS CHAR
    FIELD vltotpre AS DECI
    FIELD vltotccr AS DECI
    FIELD qtcarmag AS INTE
    FIELD vltotseg AS DECI
    FIELD vltotdsc AS DECI
    FIELD flgbloqt AS LOGI
    FIELD vllimite_saque LIKE tbtaa_limite_saque.vllimite_saque.
    
DEF TEMP-TABLE tt-extrato_conta NO-UNDO
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD nrsequen AS INTE
    FIELD cdhistor AS INTE 
    FIELD dshistor AS CHAR FORMAT "x(50)"
    FIELD nrdocmto AS CHAR FORMAT "x(11)"
    FIELD indebcre AS CHAR FORMAT " x "
    FIELD dtliblan AS CHAR FORMAT "x(5)"
    FIELD inhistor LIKE craphis.inhistor
    FIELD vllanmto LIKE craplcm.vllanmto
    FIELD vlsddisp LIKE crapsda.vlsddisp
    FIELD vlsdchsl LIKE crapsda.vlsdchsl
    FIELD vlsdbloq LIKE crapsda.vlsdbloq
    FIELD vlsdblpr LIKE crapsda.vlsdblpr
    FIELD vlsdblfp LIKE crapsda.vlsdblfp
    FIELD vlsdtota LIKE crapsda.vlsddisp
    FIELD vllimcre LIKE crapass.vllimcre
    FIELD dsagenci LIKE crapage.nmextage
    FIELD cdagenci LIKE crapage.cdagenci
    FIELD cdbccxlt AS INTE FORMAT "zz9"
    FIELD nrdolote AS INTE FORMAT "zzz,zz9"
    FIELD dsidenti LIKE craplcm.dsidenti
    FIELD nrparepr AS INTE
    FIELD dsextrat LIKE craphis.dsextrat
    FIELD vlblqjud LIKE crapsda.vlblqjud
    FIELD cdcoptfn LIKE craplcm.cdcoptfn
    FIELD nrseqlmt AS INTE
    FIELD cdtippro LIKE crappro.cdtippro
    FIELD dsprotoc LIKE crappro.dsprotoc
    FIELD flgdetal AS INTE
    INDEX tt-extrato_conta1 AS PRIMARY dtmvtolt nrsequen.

DEF TEMP-TABLE tt-dep-identificado NO-UNDO
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD dshistor AS CHAR FORMAT "x(50)"
    FIELD nrdocmto AS CHAR FORMAT "x(11)"
    FIELD indebcre AS CHAR FORMAT " x "
    FIELD vllanmto LIKE craplcm.vllanmto
    FIELD dsidenti LIKE craplcm.dsidenti
    FIELD dsextrat LIKE craphis.dsextrat.
    
DEF TEMP-TABLE tt-saldos NO-UNDO LIKE crapsda
    FIELD vlblqtaa AS DECI
    FIELD vlstotal AS DECI 
    FIELD vlsaqmax AS DECI 
    FIELD vlacerto AS DECI 
    FIELD dslimcre AS CHAR 
    FIELD vlipmfpg AS DECI 
    FIELD dtultlcr LIKE crapass.dtultlcr.

DEF TEMP-TABLE tt-cpmf NO-UNDO
    FIELD dsexcpmf AS INTEGER
    FIELD vlbscpmf AS DECIMAL
    FIELD vlpgcpmf AS DECIMAL.

DEF TEMP-TABLE tt-medias NO-UNDO
    FIELD periodo  AS CHAR
    FIELD vlsmstre AS CHAR.

DEFINE TEMP-TABLE tt-cabec NO-UNDO
    FIELD nrmatric LIKE crapass.nrmatric
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD dtadmiss LIKE crapass.dtadmiss
    FIELD nrdctitg LIKE crapass.nrdctitg
    FIELD nrctainv LIKE crapass.nrctainv
    FIELD dtadmemp LIKE crapass.dtadmemp
    FIELD nmprimtl AS   CHARACTER
    FIELD nmsegntl AS   CHARACTER
    FIELD dtaltera LIKE crapalt.dtaltera
    FIELD dsnatopc AS   CHARACTER
    FIELD nrramfon AS   CHARACTER
    FIELD dtdemiss LIKE crapass.dtdemiss
    FIELD dsnatura LIKE crapttl.dsnatura
    FIELD nrcpfcgc AS   CHARACTER
    FIELD cdsecext LIKE crapass.cdsecext
    FIELD indnivel LIKE crapass.indnivel
    FIELD dstipcta AS   CHARACTER
    FIELD dssitdct AS   CHARACTER
    FIELD cdempres LIKE crapttl.cdempres
    FIELD cdturnos LIKE crapttl.cdturnos
    FIELD cdtipsfx LIKE crapass.cdtipsfx
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD vllimcre LIKE crapass.vllimcre
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD dssititg AS   CHARACTER
    FIELD qttitula AS   INTE.

DEF TEMP-TABLE tt-comp_cabec NO-UNDO
    FIELD qtdevolu AS INTE FORMAT "zzzzz9" 
    FIELD qtddsdev AS INTE
    FIELD qtddtdev AS INTE
    FIELD dtsisfin AS DATE
    FIELD ftsalari AS CHAR
    FIELD vlprepla AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD qttalret AS INTE FORMAT "zz,zzz,zz9"
    FIELD flgdigit AS CHAR.
    
DEF TEMP-TABLE tt-busca NO-UNDO
    FIELD cdcooper LIKE crapass.cdcooper
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrdctitg LIKE crapass.nrdctitg
    INDEX tt-busca1 IS PRIMARY nmprimtl
                               cdcooper
                               nrdconta
                               ASCENDING.
    
DEF TEMP-TABLE tt-comp_medias NO-UNDO
    FIELD vlsmnmes AS DECIMAL            
    FIELD vlsmnesp AS DECIMAL            
    FIELD vlsmnblq AS DECIMAL            
    FIELD qtdiaute AS INTEGER            
    FIELD vlsmdtri AS DECIMAL            
    FIELD vlsmdsem AS DECIMAL
    FIELD qtdiauti AS INTEGER
    FIELD vltsddis AS DECIMAL.
    
DEF TEMP-TABLE tt-extrato_cheque NO-UNDO
    FIELD dtmvtolt AS CHAR
    FIELD nrdocmto LIKE crapchd.nrdocmto
    FIELD cdbanchq LIKE crapchd.cdbanchq
    FIELD cdagechq LIKE crapchd.cdagechq
    FIELD nrctachq LIKE crapchd.nrctachq
    FIELD nrcheque LIKE crapchd.nrcheque
    FIELD nrddigc3 LIKE crapchd.nrddigc3
    FIELD vlcheque LIKE crapchd.vlcheque
    FIELD vltotchq AS DECI.
    
DEF TEMP-TABLE tt-taxajuros NO-UNDO
    FIELD dslcremp LIKE craptax.dslcremp
    FIELD txmensal LIKE craptax.txmensal.

DEF TEMP-TABLE tt-dados_cooperado NO-UNDO
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc 
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nmresage LIKE crapage.nmresage
    FIELD vllimcre LIKE crapass.vllimcre.

DEF TEMP-TABLE tt-tarifas NO-UNDO
    FIELD dsexthst AS CHAR
    FIELD indebcre AS CHAR FORMAT " x "
    FIELD vlrdomes AS DECI EXTENT 13.    

DEF TEMP-TABLE tt-libera-epr NO-UNDO
    FIELD dtlibera LIKE crapdpb.dtliblan
    FIELD vllibera LIKE crapdpb.vllanmto.
                                         

/*............................................................................*/
