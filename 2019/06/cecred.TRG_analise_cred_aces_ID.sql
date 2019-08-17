CREATE OR REPLACE TRIGGER cecred.TRG_analise_cred_aces_ID BEFORE
    INSERT ON cecred.tbgen_analise_credito_acessos
    FOR EACH ROW
    WHEN ( new.idanalise_contrato_acesso IS NULL )
BEGIN
    :new.idanalise_contrato_acesso := tbgen_analise_cred_aces_SEQ.nextval;
END;