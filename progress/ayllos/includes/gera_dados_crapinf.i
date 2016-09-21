/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | includes/gera_dados_crapinf.i   | FORM0001.pc_atualiza_crapinf      |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/




/* ............................................................................

   Programa: includes/gera_dados_crapinf.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : GATI - Eder
   Data    : Setembro/2011                     Ultima atualizacao: 12/12/2013

   Dados referentes ao programa:

   Frequencia: Sempre que chamada por outros programas.
   Objetivo  : Gerar os dados dos informativos na tabela crapinf.
               Chamada na include gera_dados_inform.i.

   Alteracoes: 12/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
.............................................................................*/

FIND LAST crapinf WHERE
          crapinf.cdcooper = glb_cdcooper         AND
          crapinf.dtmvtolt = glb_dtmvtolt         AND
          crapinf.tpdocmto = cratext.tpdocmto     AND 
          crapinf.nrdconta = {&NRDCONTA}          NO-LOCK NO-ERROR.
IF   AVAIL crapinf   THEN 
     ASSIGN aux_nrseqenv = crapinf.nrseqenv + 1. 
ELSE
     ASSIGN aux_nrseqenv = 1. 

RELEASE crapinf.

DO TRANSACTION:

    CREATE crapinf.
    ASSIGN crapinf.cdagenci = cratext.cdagenci
           crapinf.cdcooper = glb_cdcooper
           crapinf.dtmvtolt = glb_dtmvtolt
           crapinf.indespac = cratext.indespac
           crapinf.nrdconta = {&NRDCONTA}
           crapinf.nrseqenv = aux_nrseqenv
           crapinf.tpdocmto = cratext.tpdocmto.
    
    IF    CAN-DO("1,2,4",STRING(glb_cdcooper)) THEN
          ASSIGN crapinf.cdfornec = 2. /* ENGECOPY */ 
    ELSE
          ASSIGN crapinf.cdfornec = 1.  /* POSTMIX */ 
    VALIDATE crapinf.

END.

