-- Programa: pc_log_internal_exception
-- Autor   : Carlos Henrique Weinhold
-- Data    : Janeiro/2017.                 Ultima atualizacao:
-- Objetivo: Verificar e criar log de exceções internas do oracle, tais como: 
--           tamanho do valor maior que o limite do tipo da variável, divisão por zero e outras.
--           Deve ser usado apenas na exception OTHERS. 
-- Referencia: http://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#LNPLS848
--             Invoke another procedure, declared with PRAGMA AUTONOMOUS_TRANSACTION, to insert information about errors.
-- Obs: Chamado #551569 -> Criação da tabela tbgen_erro_sistema
CREATE OR REPLACE PROCEDURE 
  CECRED.pc_internal_exception(pr_cdcooper IN crapcop.cdcooper%type DEFAULT 0,       -- Código da cooperativa
                               pr_compleme IN VARCHAR2              DEFAULT NULL) IS -- Complemento
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    DECLARE
    vr_sqlcode NUMBER := SQLCODE;

    BEGIN     
      IF vr_sqlcode < 0 THEN

        BEGIN
          INSERT INTO cecred.tbgen_erro_sistema e
            (e.cdcooper            
            ,e.dherro
            ,e.dserro
            ,e.nrsqlcode)
          VALUES
            (pr_cdcooper
            ,SYSDATE
            ,dbms_utility.format_error_backtrace || ' - ' ||
             dbms_utility.format_error_stack || 
             DECODE(pr_compleme, NULL, '', ' Complemento: ' || pr_compleme)
            ,ABS(vr_sqlcode));
          COMMIT;
        END;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        COMMIT;      
    END;
END pc_internal_exception;
/
