PL/SQL Developer Test script 3.0
41
DECLARE
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop;

  vr_exc_erro           EXCEPTION;
  vr_dscritic           VARCHAR2(10000);
  vr_nrseqrdr           craprdr.nrseqrdr%type;
  vr_qtde_parcela_adiar varchar2(10);
  vr_qtde_parcela_pagar varchar2(10);
BEGIN
  
  delete from crapprm where cdacesso = 'LINHA_FOLHA_PGTO_BNDES';
  
  FOR rw_crapcop IN cr_crapcop LOOP
    BEGIN
      INSERT INTO crapprm(nmsistem
                         ,cdcooper
                         ,cdacesso
                         ,dstexprm
                         ,dsvlrprm
                         ) 
                   VALUES('CRED'
                         ,rw_crapcop.cdcooper
                         ,'LINHA_FOLHA_PGTO_BNDES'
                         ,'Linhas de credito de folha de pagamento do BNDES'
                         ,'1600');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := SQLERRM;
        RAISE vr_exc_erro;
    END;
  END LOOP;
  
  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    dbms_output.put_line('Erro: ' || vr_dscritic);
END;
0
0
