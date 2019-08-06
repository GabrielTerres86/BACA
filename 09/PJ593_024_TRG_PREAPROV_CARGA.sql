CREATE OR REPLACE TRIGGER TRG_TBCRD_PREAPROV_CARGA
BEFORE INSERT ON TBCRD_PREAPROV_CARGA

FOR EACH ROW
DECLARE
 -- CURSOR
 CURSOR cr_busca_cargavigente(cpr_cdcooper crapcop.cdcooper%TYPE
                , cpr_dtinivigencia tbcrd_preaprov_carga.dtinivigencia%TYPE
                , cpr_dtfinvigencia tbcrd_preaprov_carga.dtfinvigencia%TYPE) IS
    SELECT
        k.idcarga
        , k.cdcooper
        , k.dscarga
        , k.qtpfcarregados
        , k.qtpjcarregados
        , k.vlpotenpartotal
        , k.vlpotenlimtotal
        , k.idpresas
        , k.dtcarga
        , k.dtliberacao
        , k.dtinivigencia
        , k.dtfinvigencia
        , k.incarga
    FROM tbcrd_preaprov_carga k
    WHERE incarga = 1
     AND cdcooper = cpr_cdcooper
     AND trunc(dtinivigencia) <= trunc(cpr_dtfinvigencia)
     AND trunc(dtfinvigencia) >= trunc(cpr_dtinivigencia);
 rw_busca_cargavigente cr_busca_cargavigente%ROWTYPE;
 
 CURSOR cr_buscaprm(cpr_cdcooper crapcop.cdcooper%TYPE) IS
	SELECT
		p.DSVLRPRM
	FROM crapprm p
	WHERE p.cdcooper = cpr_cdcooper
	AND p.CDACESSO = 'ATIVACAOCARGAPREAPROV';
 rw_buscaprm cr_buscaprm%ROWTYPE;
 
	vr_exc_saida EXCEPTION;
 
BEGIN
	OPEN cr_buscaprm(cpr_cdcooper => :NEW.cdcooper);
	FETCH cr_buscaprm INTO rw_buscaprm;
		IF cr_buscaprm%NOTFOUND THEN
			RAISE vr_exc_saida;
		END IF;
	CLOSE cr_buscaprm;
	
	IF rw_buscaprm.DSVLRPRM = 'M' THEN
		:NEW.INCARGA := 2;
	ELSE
		OPEN cr_busca_cargavigente(cpr_cdcooper => :NEW.cdcooper
									, cpr_dtinivigencia => :NEW.dtinivigencia
									, cpr_dtfinvigencia => :NEW.dtfinvigencia);
		FETCH cr_busca_cargavigente INTO rw_busca_cargavigente;
			IF cr_busca_cargavigente%FOUND THEN
				-- bloqueia os limites para os cooperados e a carga antiga para liberar a nova.
				UPDATE tbcrd_preaprov_limite l SET l.cdstatuslim = 2 WHERE l.idcarga = rw_busca_cargavigente.idcarga;
        UPDATE tbcrd_preaprov_carga k  SET k.incarga = 2 WHERE k.idcarga = rw_busca_cargavigente.idcarga;
        :NEW.INCARGA := 1;
      END IF;
    CLOSE cr_busca_cargavigente;
  END IF;

EXCEPTION
  WHEN vr_exc_saida THEN
    RAISE_APPLICATION_ERROR(-20100, 'PARAMETRO DE ATIVACAO DE CARGA NAO ENCONTRADO.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO AO INSERIR NOVA CARGA');

END;



