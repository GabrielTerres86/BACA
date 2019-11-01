CREATE OR REPLACE TRIGGER CECRED.TRG_TBCRD_PREAPROV_CARGA
BEFORE INSERT ON TBCRD_PREAPROV_CARGA

FOR EACH ROW
DECLARE
  vr_nova_carga tbcrd_preaprov_carga%ROWTYPE;
  vr_dscritic  VARCHAR2(500);
  vr_exc_saida EXCEPTION;
BEGIN
	vr_nova_carga.idcarga         := :NEW.idcarga;
	vr_nova_carga.cdcooper        := :NEW.cdcooper;
	vr_nova_carga.dscarga         := :NEW.dscarga;
	vr_nova_carga.qtpfcarregados  := :NEW.qtpfcarregados;
	vr_nova_carga.qtpjcarregados  := :NEW.qtpjcarregados;
	vr_nova_carga.vlpotenlimtotal := :NEW.vlpotenlimtotal;
	vr_nova_carga.idpresas        := :NEW.idpresas;			
	vr_nova_carga.dtcarga         := :NEW.dtcarga;
	vr_nova_carga.dtliberacao     := :NEW.dtliberacao;
	vr_nova_carga.dtinivigencia   := :NEW.dtinivigencia;
	vr_nova_carga.dtfinvigencia   := :NEW.dtfinvigencia;
	vr_nova_carga.incarga         := :NEW.incarga;	
	vr_nova_carga.dsuserconn      := :NEW.dsuserconn;	
	vr_nova_carga.dsuseruser      := :NEW.dsuseruser;			
	
	
  ccrd0009.pccrd_controla_carga_inserida(pr_carga => vr_nova_carga
	                                     ,pr_dscritic  => vr_dscritic);

	:NEW.incarga := vr_nova_carga.incarga;
	
  IF vr_dscritic IS NOT NULL THEN
		 RAISE vr_exc_saida;
	END IF;																			 
EXCEPTION
  WHEN vr_exc_saida THEN
    RAISE_APPLICATION_ERROR(-20100, vr_dscritic);
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO AO INSERIR NOVA CARGA');
END;
/
