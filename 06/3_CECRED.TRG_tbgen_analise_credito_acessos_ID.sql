CREATE OR REPLACE TRIGGER CECRED.TRG_tbgen_analise_credito_acessos_ID BEFORE
    INSERT ON tbgen_analise_credito_acessos
    FOR EACH ROW
    WHEN ( new.idanalise_contrato_acesso IS NULL )
BEGIN
    :new.idanalise_contrato_acesso := tbgen_analise_credito_acessos_SEQ.nextval;
END;
commit;