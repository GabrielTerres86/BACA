CREATE OR REPLACE TRIGGER CECRED.TRG_CRAPDEP_ATLZ
  AFTER INSERT OR UPDATE OR DELETE ON CRAPDEP
  FOR EACH ROW  
  /* ..........................................................................
    
     Programa : TRG_CRAPDEP_ATLZ
     Sistema  : Conta-Corrente - Cooperativa de Credito
     Sigla    : CRED
     Autor    : Odirlei Busana(AMcom)
     Data     : Agosto/2017.                   Ultima atualizacao: 
    
     Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Trigger para registrar que informação foi alterada
    
     Alteração :
    
    
  ............................................................................*/
  
  
DECLARE

  vr_nmtabela   CONSTANT VARCHAR2(50) := 'CRAPDEP';
  vr_cdcooper   NUMBER;
  vr_nrdconta   NUMBER;
  vr_idseqttl   NUMBER;
  vr_dschave    tbcadast_pessoa_atualiza.dschave%TYPE;
  
  vr_exc_erro   EXCEPTION;
  vr_dscritic   VARCHAR2(2000);
  vr_cdcritic   NUMBER;

  vr_dsmodule   VARCHAR2(100);
  vr_dsaction   VARCHAR2(100);
  
BEGIN

  -- Guarda o nome e acao atual
  DBMS_APPLICATION_INFO.read_module(module_name => vr_dsmodule,
                                    action_name => vr_dsaction);
 
  -- Se veio da trigger da tabela PESSOA nao precisa inserir na tabela de atualizacao
  IF vr_dsmodule = 'TRIGGER_PESSOA' THEN
    RETURN;
  END IF;
 
  IF deleting THEN
    vr_cdcooper := :old.cdcooper;
    vr_nrdconta := :old.nrdconta;
    vr_idseqttl := 1;
    vr_dschave  := :old.CDCOOPER||';'||:old.NRDCONTA||';'||
                   :old.IDSEQDEP||';'||UPPER(:old.NMDEPEND);
  ELSE
    vr_cdcooper := :new.cdcooper;
    vr_nrdconta := :new.nrdconta;
    vr_idseqttl := 1;
    vr_dschave  := :new.CDCOOPER||';'||:new.NRDCONTA||';'||
                   :new.IDSEQDEP||';'||UPPER(:new.NMDEPEND);
  END IF;

  -- Incluir registro que o cadastro de pessoa foi atualizado no sistema legado
  CADA0010.pc_cadast_pessoa_atualiza ( pr_cdcooper  => vr_cdcooper  --> Codigo da cooperativa
                                      ,pr_nrdconta  => vr_nrdconta  --> Numero da conta
                                      ,pr_idseqttl  => vr_idseqttl  --> Sequencial do titular
                                      ,pr_nmtabela  => vr_nmtabela  --> Nome da tabela alteradoa
                                      ,pr_dschave   => vr_dschave   --> Dados que compoem a chave da tabela   
                                      ,pr_cdcritic  => vr_cdcritic  --> Codigo de erro
                                      ,pr_dscritic  => vr_dscritic);   

  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20500,vr_dscritic);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    vr_dscritic := 'Erro nao tratado na TRG_CRAPDEP_ATLZ: '||SQLERRM;
    raise_application_error(-20500,vr_dscritic);
END TRG_CRAPDEP_ATLZ;
/
