CREATE OR REPLACE TRIGGER CECRED.TRG_CRAPASS_BASE_CPFCGC
BEFORE INSERT OR UPDATE
        OF nrcpfcgc
        ON CRAPASS
  FOR EACH ROW
  /* ..........................................................................
 
     Programa : TRG_CRAPASS_BASE_CPFCGC
     Sistema  : Conta-Corrente - Cooperativa de Credito
     Sigla    : CRED
     Autor    : Mario Bernat(AMcom)
     Data     : Agosto/2018.                   Ultima atualizacao: 01/08/2018
 
     Dados referentes ao programa:
 
      Frequencia: Sempre que for chamado
      Objetivo  : Trigger para registrar que informação foi alterada
 
     Alteração : Gerar informação da base do associado quando PJ e CPF completo para PF  
                 CRAPASS (Mario-AMcom)
 
  ............................................................................*/
 
BEGIN
 
  IF :new.inpessoa = 1 then
     :new.NRCPFCNPJ_BASE := :new.nrcpfcgc;
  ELSE
     :new.NRCPFCNPJ_BASE := to_number(SUBSTR(to_char(:new.nrcpfcgc,'FM00000000000000'),1,8) );
  END IF;
   
   
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO GERACAO NRCPFCNPJ_BASE - TABELA CRAPASS!');
END TRG_CRAPASS_BASE_CPFCGC;
/