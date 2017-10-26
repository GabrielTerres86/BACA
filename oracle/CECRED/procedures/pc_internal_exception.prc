CREATE OR REPLACE PROCEDURE CECRED.pc_internal_exception(pr_cdcooper IN crapcop.cdcooper%type DEFAULT 0,       -- Código da cooperativa
                                                         pr_compleme IN VARCHAR2              DEFAULT NULL) IS -- Complemento
--
-- Programa: pc_log_internal_exception
-- Autor   : Carlos Henrique Weinhold
-- Data    : Janeiro/2017.                 Ultima atualizacao: 26/10/2017
-- Objetivo: Verificar e criar log de exceções internas do oracle, tais como: 
--           tamanho do valor maior que o limite do tipo da variável, divisão por zero e outras.
--           Deve ser usado apenas na exception OTHERS. 
-- Referencia: http://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#LNPLS848
--             Invoke another procedure, declared with PRAGMA AUTONOMOUS_TRANSACTION, to insert information about errors.
-- Obs: Chamado #551569 -> Criação da tabela tbgen_erro_sistema
--
--      Chamado 736463 - 26/10/2017 - (Belli - Envolti) Tratamento de cooperativa chegando com NULL  
--                 
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    DECLARE
      vr_idprglog tbgen_prglog.idprglog%type;
      vr_sqlcode  NUMBER := SQLCODE;
      vr_dsmensagem VARCHAR2(4000)  := SQLERRM;

    BEGIN     
      IF vr_sqlcode < 0 THEN        
        BEGIN
          INSERT INTO cecred.tbgen_erro_sistema e
            (e.cdcooper            
            ,e.dherro
            ,e.dserro
            ,e.nrsqlcode)
          VALUES
            (NVL(pr_cdcooper,0) -- Chamado 736463 - 26/10/2017
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
        -- Chamado 736463 - 26/10/2017
        -- Retirado commit sem função e uma tentaiva de gerar um Log do tratamento de erro/log
        -- Não pode chamar a procedure pc_log_programa porque ela já chama está propria pc_internal_exception                                             
        vr_dsmensagem  := SQLERRM;
        ROLLBACK;
        INSERT INTO cecred.tbgen_prglog p
          (p.cdcooper
          ,p.tpexecucao
          ,p.cdprograma
          ,p.nrexecucao
          ,p.dhinicio
          ,p.flgsucesso)
        VALUES
          (pr_cdcooper
          ,1 
          ,'pc_internal_exception'
          ,1
          ,SYSDATE
          ,1)
        RETURNING p.idprglog INTO vr_idprglog;
        INSERT INTO cecred.tbgen_prglog_ocorrencia o
        (o.idprglog
        ,o.dhocorrencia
        ,o.tpocorrencia
        ,o.cdcriticidade
        ,o.cdmensagem
        ,o.dsmensagem
        ,o.nrchamado)
      VALUES
        (vr_idprglog
        ,SYSDATE
        ,2
        ,0
        ,NULL
        ,vr_dsmensagem
        ,NULL);
      COMMIT;                                                 
    END;
END pc_internal_exception;
/
