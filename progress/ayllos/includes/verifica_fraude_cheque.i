/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-----------------------------------+-----------------------------------+
  | Rotina Progress                   | Rotina Oracle PLSQL               |
  +-----------------------------------+-----------------------------------+
  | includes/verifica_fraude_cheque.i | CHEQ0001.pc_verifica_fraude_cheque|
  +-----------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/


/* .............................................................................

   Programa: Includes/verifica_fraude_cheque.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fabricio           
   Data    : Agosto/2012                          Ultima alteracao: 10/03/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Verificar possivel fraude dos cheques das contas listadas abaixo.
   
   Alteracoes:  22/08/2012 - Ajustado para zerar o glb_cdcritic apos a criacao
                             do craprej (Ze).
                             
                09/01/2014 - Removido verificacao de contas dos cheques
                             roubados do Safra e adicionado verificao de contas
                             dos cheques roubados do Itau de Balneario
                             Camboriu e do Bradesco. (Fabricio)
                             
                19/02/2014 - Incluso validate (Daniel).
                
                10/03/2014 - Adicionado contas relacionados ao roubo de cheques do
                             Bradesco e Itau em Joinville 21/02/2014. (Jorge) 
............................................................................. */

IF aux_cdagectl = 101 THEN
DO:
    IF CAN-DO("945200,1889850,2300710,3078540,3842355,3948358,6173101,7189389,
               6765955,1255029,836966,2799499,3054934,3893138,6409970,6446442,
               6945775,2277719,7102321,1500880,2121883,2268116,2360250",
               STRING(aux_nrctachq)) THEN /* Itau */

        ASSIGN glb_cdcritic = 948.
    ELSE
    IF CAN-DO("6146244,2992027,6662234,2678209,2146894,6217923,2727412,2618001,
               2482274,926400,6797229,2133644,3053881,6851568,2058685,2649063,
               2696240,3777839,3823849,6225349,6802222", 
               STRING(aux_nrctachq)) THEN /* Bradesco */

        ASSIGN glb_cdcritic = 963.
END.
ELSE
IF aux_cdagectl = 102 THEN
DO:
    IF aux_nrctachq = 206334 THEN /* Itau */
        ASSIGN glb_cdcritic = 948. 
    ELSE
    IF CAN-DO("1023,190691,294624,311189,316741,441929,60453", 
               STRING(aux_nrctachq)) THEN /* Bradesco */

        ASSIGN glb_cdcritic = 963.
END.
ELSE
IF aux_cdagectl = 103 THEN
DO:
    IF CAN-DO("34800,17973",
              STRING(aux_nrctachq)) THEN /* Itau */
        ASSIGN glb_cdcritic = 948.
    ELSE
    IF aux_nrctachq = 9580 THEN /* Bradesco */

        ASSIGN glb_cdcritic = 963.
END.
ELSE
IF aux_cdagectl = 106 THEN
DO:
    IF CAN-DO("14176,236225", STRING(aux_nrctachq)) THEN /* Itau */

        ASSIGN glb_cdcritic = 948.
    ELSE
    IF CAN-DO("235237,241008", STRING(aux_nrctachq)) THEN /* Bradesco */

        ASSIGN glb_cdcritic = 963.
END.
ELSE
IF aux_cdagectl = 108 THEN
DO:
    IF CAN-DO("2178,21776,21091,3956", 
               STRING(aux_nrctachq)) THEN /* Itau */

        ASSIGN glb_cdcritic = 948.
    ELSE
    IF CAN-DO("23841,1465,32603,7838,36706", 
               STRING(aux_nrctachq)) THEN /* Bradesco */

        ASSIGN glb_cdcritic = 963.
END.
ELSE
IF aux_cdagectl = 109 THEN
DO:
    IF CAN-DO("95567,103772,116416,4022,17370,17469", 
              STRING(aux_nrctachq)) THEN /* Itau */

        ASSIGN glb_cdcritic = 948.
END.
ELSE
IF aux_cdagectl = 115 THEN
DO:
    IF CAN-DO("244376,6276415,6060862,6520995,2375966,2211076,2958708,3611019,
               844128,3119939", 
               STRING(aux_nrctachq)) THEN /* Bradesco */

        ASSIGN glb_cdcritic = 963.
END.

IF glb_cdcritic = 948 OR glb_cdcritic = 963 THEN
DO:
    CREATE craprej.
    ASSIGN craprej.cdcooper = glb_cdcooper
           craprej.dtrefere = aux_dtauxili
           craprej.nrdconta = aux_nrdconta
           craprej.nrdocmto = aux_nrdocmto 
           craprej.vllanmto = aux_vllanmto
           craprej.nrseqdig = aux_nrseqarq
           craprej.cdcritic = glb_cdcritic
           craprej.cdpesqbb = aux_cdpesqbb.
    VALIDATE craprej.
           
    ASSIGN glb_cdcritic = 0.
END.

/* .......................................................................... */
