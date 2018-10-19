CREATE OR REPLACE PACKAGE CECRED.PREJ0003 AS

/*..............................................................................

   Programa: PREJ0003                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Rangel Decker - AMCom
   Data    : Maio/2018                      Ultima atualizacao: 25/09/2018

   Dados referentes ao programa:

   Frequencia: Diária (sempre que chamada)
   Objetivo  : Move  C.C. para prejuízo

   Alteracoes: 

..............................................................................*/

  -- Verifica se a conta corrente se encontra em prejuízo
  FUNCTION fn_verifica_preju_conta(pr_cdcooper craplcm.cdcooper%TYPE
                                 , pr_nrdconta craplcm.nrdconta%TYPE) RETURN BOOLEAN;
																 

end PREJ0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PREJ0003 AS
/*..............................................................................

   Programa: PREJ0003                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   :Rangel Decker - AMCom
   Data    : Maio/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diária (sempre que chamada)
   Objetivo  : Transferencia do prejuizo de conta corrente

   Alteracoes: 

..............................................................................*/

  -- clob para conter o dados do excel/csv
   vr_clobarq   CLOB;
   vr_texto_completo  VARCHAR2(32600);
   vr_mailprej  VARCHAR2(1000);

   -- Código do programa
   vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'PREJU';
   vr_exc_saida exception;

   vr_cdcritic  NUMBER(3);
   vr_dscritic  VARCHAR2(1000);


  -- Verifica se a conta está em prejuízo
  FUNCTION fn_verifica_preju_conta(pr_cdcooper craplcm.cdcooper%TYPE
                                  , pr_nrdconta craplcm.nrdconta%TYPE)
    RETURN BOOLEAN AS vr_conta_em_prejuizo BOOLEAN;

    CURSOR cr_conta IS
    SELECT ass.inprejuz
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;

    vr_inprejuz  crapass.inprejuz%TYPE;
  BEGIN
    OPEN cr_conta;
    FETCH cr_conta INTO vr_inprejuz;
    CLOSE cr_conta;

    vr_conta_em_prejuizo := vr_inprejuz = 1;

    RETURN vr_conta_em_prejuizo;
  END fn_verifica_preju_conta;
	
END PREJ0003;
-- Teste (Reginaldo/AMcom)
/
