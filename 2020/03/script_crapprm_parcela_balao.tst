PL/SQL Developer Test script 3.0
140
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
  
  delete from crapprm where cdacesso = 'LINHA_FOLEGO_PREAPROVADO';
  delete from crapprm where cdacesso = 'COVID_QTDE_PARCELA_ADIAR';
  delete from crapprm where cdacesso = 'COVID_QTDE_PARCELA_PAGAR';  
  delete from crapaca where nmdeacao = 'BUSCAR_PARCELAS_ADIAR';  
  delete from crapaca where nmdeacao = 'ALTERAR_VENCIMENTOS_PARCELA_BALAO';  
  delete from craprdr where nmprogra = 'PARCELA_BALAO';
  delete from crapace where nmdatela = 'ATENDA' and crapace.cddopcao = 'V' and nmrotina = 'PRESTACOES' and idambace = 2;

  insert into craprdr(nmprogra, dtsolici) values ('PARCELA_BALAO',trunc(sysdate)) returning nrseqrdr into vr_nrseqrdr;  
  insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) values ('BUSCAR_PARCELAS_ADIAR','EMPR0023','pc_retorna_parcelas_adiar_web','pr_nrdconta,pr_nrctremp',vr_nrseqrdr);
  insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) values ('ALTERAR_VENCIMENTOS_PARCELA_BALAO','EMPR0023','pc_altera_vencimento_adiar_web','pr_nrdconta,pr_nrctremp,pr_parcelas',vr_nrseqrdr);  
  
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
                         ,'LINHA_FOLEGO_PREAPROVADO'
                         ,'Linhas de credito de folego'
                         ,'1500');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    vr_qtde_parcela_adiar := '3';
    IF rw_crapcop.cdcooper IN (2,5,6,12,14,16) then
      vr_qtde_parcela_adiar := '0';
    ELSIF rw_crapcop.cdcooper IN (7,13) then
      vr_qtde_parcela_adiar := '4';
    ELSIF rw_crapcop.cdcooper IN (9) then
      vr_qtde_parcela_adiar := '6';
    end if;
      
    BEGIN
      INSERT INTO crapprm(nmsistem
                         ,cdcooper
                         ,cdacesso
                         ,dstexprm
                         ,dsvlrprm
                         ) 
                   VALUES('CRED'
                         ,rw_crapcop.cdcooper
                         ,'COVID_QTDE_PARCELA_ADIAR'
                         ,'Quantidade de parcelas que sera avancado os vencimentos'
                         ,vr_qtde_parcela_adiar);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    vr_qtde_parcela_pagar := '3';
    IF rw_crapcop.cdcooper IN (7) then
      vr_qtde_parcela_pagar := '4';
    end if; 
    
    BEGIN
      INSERT INTO crapprm(nmsistem
                         ,cdcooper
                         ,cdacesso
                         ,dstexprm
                         ,dsvlrprm
                         ) 
                   VALUES('CRED'
                         ,rw_crapcop.cdcooper
                         ,'COVID_QTDE_PARCELA_PAGAR'
                         ,'Quantidade de parcelas que serao pagas no pre-aprovado'
                         ,vr_qtde_parcela_pagar);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    BEGIN
      UPDATE craptel SET
             cdopptel = '@,C,P,D,U,Q,X,A,R,V'
            ,lsopptel = 'ACESSO,CONSULTA,PAGAR,DESFAZER EFET.,PREJUIZO,DESFAZER PREJUIZO,CONTROLE QUALIFICACAO,ABONO,RECEBIMENTO BENS,ADIAR VENCIMENTOS'
       where UPPER(nmdatela) = 'ATENDA'
         and nmrotina        = 'PRESTACOES'
         and cdcooper        = rw_crapcop.cdcooper;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := SQLERRM;
        RAISE vr_exc_erro;
    END;    
        
  END LOOP;
  
  BEGIN
      INSERT INTO crapace
                  (nmdatela,
                   cddopcao,
                   cdoperad,
                   nmrotina,
                   cdcooper,
                   nrmodulo,
                   idevento,
                   idambace)
                  select DISTINCT nmdatela,
                         'V' cddopcao,
                         UPPER(cdoperad),
                         nmrotina,
                         cdcooper,
                         nrmodulo,
                         0 idevento,
                         idambace 
                    from crapace where nmdatela = 'ATENDA' and crapace.cddopcao = 'P' and nmrotina = 'PRESTACOES' and idambace = 2;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := SQLERRM;
      RAISE vr_exc_erro;
  END;

  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    dbms_output.put_line('Erro: ' || vr_dscritic);
END;
0
0
