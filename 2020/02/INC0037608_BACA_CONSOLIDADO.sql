-- Parametro para valor de cartao credito
DECLARE
    CURSOR cr_crapcop IS
        SELECT cdcooper
              ,flgativo
          FROM crapcop
         WHERE cdcooper <> 3
         ORDER BY cdcooper DESC;

  vr_dtinicial tbcrd_limoper.dtaltera%TYPE;
   
   ------> CURSORES <------
            
   CURSOR cr_limop(cpr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT
          lp.idlimop
          , lp.vllimoutorg
          , lp.vllimconsumd
          , lp.vllimdisp
          , lp.nrpercseg        -- percentual de seguranca
          , lp.nrpercdispmajor  -- percentual de majoracao
          , lp.nrpercdisppa     -- percentual de pre-aprovado
          , lp.nrpercdispopnorm -- percentual disponivel normal
          , lp.dsemails
          , lp.dtcadastro
      FROM tbcrd_limoper lp
      WHERE lp.idlimop = (SELECT MAX(idlimop) FROM tbcrd_limoper WHERE cdcooper = cpr_cdcooper); 
   rw_limop cr_limop%ROWTYPE; 

   -- Soma dos valores operacionais pre-aprovado.        
   CURSOR cr_limitepa(cpr_cdcooper crapcop.cdcooper%TYPE,
                        cpr_dtcadastro tbcrd_limoper.dtcadastro%TYPE) IS
      SELECT sum(w.vllimcrd) vltotal
        FROM crawcrd w
       WHERE w.cdcooper = cpr_cdcooper
         AND nvl(w.idlimite, 0) > 0
         AND w.dtmvtolt >= cpr_dtcadastro
         AND w.insitcrd NOT IN (5,6); 
   rw_limitepa cr_limitepa%ROWTYPE;
       
   -- Soma dos valores operacionais normais. 
   CURSOR cr_limitenorm(cpr_cdcooper crapcop.cdcooper%TYPE,
                        cpr_dtcadastro tbcrd_limoper.dtcadastro%TYPE) IS    
      SELECT sum(w.vllimcrd) vltotal
        FROM crawcrd w
       WHERE w.cdcooper = cpr_cdcooper
         AND w.dtmvtolt >= cpr_dtcadastro
         AND w.insitcrd NOT IN (5,6)
         AND nvl(w.idlimite, 0) = 0;
   rw_limitenorm cr_limitenorm%ROWTYPE;

   -- Soma dos valores operacionais de majoracao. 
   CURSOR cr_limitemajor(cpr_cdcooper crapcop.cdcooper%TYPE
                        , cpr_dtmvtolt crawcrd.dtmvtolt%TYPE) IS    
      SELECT sum(maj.vllimite) vltotal
        FROM integradados.sasf_majoracaocartao@sasd1 maj
       WHERE maj.cdcooper = cpr_cdcooper
         AND trunc(maj.dtmajoracaocartao) >= trunc(cpr_dtmvtolt); 
   rw_limitemajor cr_limitemajor%ROWTYPE;          

BEGIN

    --Limpa registros
    DELETE FROM TBCARTAO_LIMITE_OPERACIONAL prm WHERE prm.cdacesso = 'VLPROPCORRENTEMAJORADO'; --  majorado
    DELETE FROM TBCARTAO_LIMITE_OPERACIONAL prm WHERE prm.cdacesso = 'VLPROPCORRENTECRD';      --  normal
    DELETE FROM TBCARTAO_LIMITE_OPERACIONAL prm WHERE prm.cdacesso = 'VLPROPCORRENTEPREAPROV'; -- pre aprovado
    DELETE FROM crapprm prm WHERE prm.cdacesso = 'PRAZO_EXP_CRD';
	DELETE FROM tbcrd_limoper lo WHERE lo.vllimconsumd IS NULL OR lo.vllimdisp IS NULL; -- limpa os registros errados 

    FOR rw_crapcop IN cr_crapcop LOOP
    
        INSERT INTO TBCARTAO_LIMITE_OPERACIONAL
            (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
        VALUES
            ('CRED'
            ,rw_crapcop.cdcooper
            ,'VLPROPCORRENTEMAJORADO'
            ,'Guardar o valor total de propostas de majoracao geradas a partir da data de alteracao do limite operacional'
            ,'105315017');

        INSERT INTO TBCARTAO_LIMITE_OPERACIONAL
            (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
        VALUES
            ('CRED'
            ,rw_crapcop.cdcooper
            ,'VLPROPCORRENTECRD'
            ,'Guardar o valor total de propostas geradas a partir da data de alteracao do limite operacional'
            ,rw_crapcop.flgativo);    

        INSERT INTO TBCARTAO_LIMITE_OPERACIONAL
            (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
        VALUES
            ('CRED'
            ,rw_crapcop.cdcooper
            ,'VLPROPCORRENTEPREAPROV'
            ,'Guardar o valor total de propostas de pre aprovado geradas a partir da data de alteracao do limite operacional'
            ,'0');   

        INSERT INTO crapprm 
            (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) 
        values ('CRED', rw_crapcop.cdcooper, 'PRAZO_EXP_CRD', 'Prazo em quantidade de dias para que as propostas expirem', '10');                             
    
    END LOOP;



    -- Inserir carga inicial
    FOR coop IN cr_crapcop LOOP
          --
          -- Busca data de comparacao
          OPEN  cr_limop(coop.cdcooper);
          FETCH cr_limop INTO rw_limop;
          CLOSE cr_limop;
          
          vr_dtinicial := nvl(rw_limop.dtcadastro, trunc(SYSDATE));
          
          -- Carrega carga inicial do limite normal
          -- VLPROPCORRENTECRD
          OPEN  cr_limitenorm(coop.cdcooper, vr_dtinicial);
          FETCH cr_limitenorm INTO rw_limitenorm;
          CLOSE cr_limitenorm;
          -- Atualiza parametro de valor de cartao de credito para proposta normal.
          BEGIN 
             UPDATE TBCARTAO_LIMITE_OPERACIONAL p
                SET p.dsvlrprm = nvl(rw_limitenorm.vltotal, 0)
              WHERE p.cdacesso IN ('VLPROPCORRENTECRD')
                AND p.cdcooper = coop.cdcooper;        
          EXCEPTION
            WHEN OTHERS THEN
              raise_application_error(-20001, 'Erro ao inserir registro para valor de cartoes normais');
          END;
          --
          
          -- Carrega carga inicial do limite pre aprovado
          -- VLPROPCORRENTEPREAPROV
          OPEN  cr_limitepa(coop.cdcooper, vr_dtinicial);
          FETCH cr_limitepa INTO rw_limitepa;
          CLOSE cr_limitepa;
          -- Atualiza parametro de valor de cartao de credito para proposta normal.
          BEGIN 
             UPDATE TBCARTAO_LIMITE_OPERACIONAL p
                SET p.dsvlrprm = nvl(rw_limitepa.vltotal, 0)
              WHERE p.cdacesso IN ('VLPROPCORRENTEPREAPROV')
                AND p.cdcooper = coop.cdcooper;        
          EXCEPTION
            WHEN OTHERS THEN
              raise_application_error(-20001, 'Erro ao inserir registro para valor de cartoes normais');
          END;
          --      
          
          -- VLPROPCORRENTEMAJORADO
          OPEN  cr_limitemajor(coop.cdcooper, vr_dtinicial);
          FETCH cr_limitemajor INTO rw_limitemajor;
          CLOSE cr_limitemajor;
          -- Atualiza parametro de valor de cartao de credito para proposta normal.
          BEGIN 
             UPDATE TBCARTAO_LIMITE_OPERACIONAL p
                SET p.dsvlrprm = nvl(rw_limitemajor.vltotal, 0)
              WHERE p.cdacesso IN ('VLPROPCORRENTEMAJORADO')
                AND p.cdcooper = coop.cdcooper;        
          EXCEPTION
            WHEN OTHERS THEN
              raise_application_error(-20001, 'Erro ao inserir registro para valor de cartoes normais');
          END;
          --    
          
          COMMIT;  
      END LOOP;    
    COMMIT;
END;

