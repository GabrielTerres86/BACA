-- P441_mvp_DML_script_unificado
--p441_mvp

-- Alterar linhas para tpprodut = 0-TR
update craplcr a 
set a.tpprodut = 0 -- TR
where a.cdcooper = 1
and a.cdlcremp in (1541, 1645);

update craplcr a 
set a.tpprodut = 0 -- TR
where a.cdcooper = 16
and a.cdlcremp in (1079);

update craplcr a 
set a.tpprodut = 0 -- TR
where a.cdcooper = 3
and a.cdlcremp in (1, 2, 3, 4, 5, 6, 7);
--
Commit;

--- Atualizar propostas e emprestimos que estão com taxa mensal ou diária zerada.
declare
  -- busca as proposta com taxa mensal ou taxa diaria
  -- nula ou zerada
  cursor c_crawepr is
  select  a.cdcooper,
         a.nrdconta,
         a.nrctremp, 
         a.tpemprst,
         a.cdlcremp,
         a.txmensal txmensal_emprest,
         a.txdiaria txdiaria_emprest,
         b.txmensal txmensal_linha,
         b.txdiaria txdiaria_linha
   from crawepr a,
        craplcr b
  where a.cdcooper = b.cdcooper
    and a.cdlcremp = b.cdlcremp
    and a.cdcooper = 1
    and (nvl(a.txmensal,0) = 0   -- taxa mensal
     or  nvl(a.txdiaria,0) = 0)  -- taxa diaria
    and a.dtinclus+0 >= '01/01/2019'
    and not exists (select 1 from crapepr c
                    where  a.cdcooper = c.cdcooper
                    and    a.nrdconta = c.nrdconta
                    and    a.nrctremp = c.nrctremp);
     
  -- busca contrato om taxa mensal ou taxa diaria
  -- nula ou zerada,  não liquidado
  cursor c_crapepr is
  select a.cdcooper,
         a.nrdconta,
         a.nrctremp, 
         a.tpemprst,
         a.cdlcremp,
         a.txmensal txmensal_emprest,
         a.txjuremp txdiaria_emprest,
         b.txmensal txmensal_linha,
         b.txdiaria txdiaria_linha
   from crapepr a,
        craplcr b
  where a.cdcooper = b.cdcooper
    and a.cdlcremp = b.cdlcremp
    and a.inliquid = 0 -- não liquidado
    and (nvl(a.txmensal,0) = 0   -- taxa mensal
     or  nvl(a.txjuremp,0) = 0)  -- taxa diaria
    and (a.vlsdeved > 0  -- saldo devedor
     or a.vlsdprej > 0);  -- saldo prejuizo   

  -- busca contrato om taxa mensal ou taxa diaria
  -- nula ou zerada,  liquidado     
  cursor c_crapepr_1 is
   select a.cdcooper,
         a.nrdconta,
         a.nrctremp, 
         a.tpemprst,
         a.cdlcremp,
         a.txmensal txmensal_emprest,
         a.txjuremp txdiaria_emprest,
         b.txmensal txmensal_linha,
         b.txdiaria txdiaria_linha
   from crapepr a,
        craplcr b,
        crapcop c
  where a.cdcooper = b.cdcooper
    and a.cdlcremp = b.cdlcremp
    and a.inliquid = 0 -- não liquidado
    and (nvl(a.txmensal,0) = 0   -- taxa mensal
     or  nvl(a.txjuremp,0) = 0)  -- taxa diaria
    and (a.vlsdeved > 0  -- saldo devedor
     or a.vlsdprej >0 )  -- saldo prejuizo  
   and a.cdcooper = c.cdcooper
    and c.flgativo = 1;          
     
begin
    -- atualiza a taxa mensal e/ou taxa diaria das
    -- propostas 
    for r_crawepr in c_crawepr
    loop
      update crawepr w
         set w.txmensal = decode(nvl(w.txmensal,0),0, r_crawepr.txmensal_linha, w.txmensal),
             w.txdiaria = decode(nvl(w.txdiaria,0),0, r_crawepr.txdiaria_linha, w.txdiaria)
       where w.cdcooper = r_crawepr.cdcooper
         and w.nrdconta = r_crawepr.nrdconta
         and w.nrctremp = r_crawepr.nrctremp;
    end loop;
    
    -- Atualiza a taxa mensal e/ou taxa diaria dos
    -- contratos não liquidados
    for r_crapepr in c_crapepr
    loop 
      update crapepr p
         set p.txmensal = decode(nvl(p.txmensal,0),0, r_crapepr.txmensal_linha, p.txmensal),
             p.txjuremp = decode(nvl(p.txjuremp,0),0, r_crapepr.txdiaria_linha, p.txjuremp)
       where p.cdcooper = r_crapepr.cdcooper
         and p.nrdconta = r_crapepr.nrdconta
         and p.nrctremp = r_crapepr.nrctremp;
    end loop;
    
    -- Atualiza a taxa mensal e/ou taxa diaria dos
    -- contratos liquidados
    for r_crapepr_1 in c_crapepr_1
    loop 
      update crapepr p
         set p.txmensal = decode(nvl(p.txmensal,0),0, r_crapepr_1.txmensal_linha, p.txmensal),
             p.txjuremp = decode(nvl(p.txjuremp,0),0, r_crapepr_1.txdiaria_linha, p.txjuremp)
       where p.cdcooper = r_crapepr_1.cdcooper
         and p.nrdconta = r_crapepr_1.nrdconta
         and p.nrctremp = r_crapepr_1.nrctremp;
    end loop;
    Commit;
    
end;
/    

--- Garga R45 nos pre-aprovados com dsfaixa_risco vazia
declare 
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;   

    -- busca coop ativas   
    CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop a
     WHERE a.flgativo = 1;

    -- busca cargas ativas   
    CURSOR cr_crapcpa( pr_cdcooper in number) IS
    SELECT distinct cpa.iddcarga
            FROM crapcpa              cpa
                ,tbepr_carga_pre_aprv car
           WHERE car.cdcooper = cpa.cdcooper
             AND cpa.iddcarga = car.idcarga
             AND NVL(car.dtfinal_vigencia,TRUNC(rw_crapdat.dtmvtolt)) >= TRUNC(rw_crapdat.dtmvtolt)             
             AND cpa.cdsituacao IN ('A','B')
             and cpa.cdcooper = pr_cdcooper;

begin
  
   --busca a data
   OPEN BTCH0001.cr_crapdat(pr_cdcooper => 1);
   FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

   for rw_crapcop in cr_crapcop loop
     for rw_crapcpa in cr_crapcpa(pr_cdcooper => rw_crapcop.cdcooper)
     loop
        update crapcpa w
           set w.dsfaixa_risco = 'R45'
         where w.cdcooper = rw_crapcop.cdcooper
           and w.iddcarga = rw_crapcpa.iddcarga
           and w.dsfaixa_risco is null
           and w.tppessoa in (1,2);

     end loop;
   end loop;             
   commit;  
end;
/

--- estoria 27191
update crapaca 
   set lstparam = lstparam||', pr_pcalttax'
where nmdeacao='TAB089_ALTERAR';   

-- p441_mvp    
UPDATE craptab
   SET DSTEXTAB = DSTEXTAB || ' 000,00'        --pealttax
where 1  = 1   AND
    craptab.nmsistem = 'CRED'       AND
    craptab.tptabela = 'USUARI'     AND
    craptab.cdempres = 11           AND
    craptab.cdacesso = 'PAREMPREST' AND
    craptab.tpregist = 01           AND
    craptab.cdcooper  not in (4,15,17); --desativadas             

--fim estoria 27191

-- p441_mvp
UPDATE CRAPTEL
   SET CDOPPTEL = '@,A,B,C,E,F,I,L,P,T'
 WHERE NMDATELA = 'LCREDI';

commit;
 
-- Realizar cadastro de permissoes para a opção importar e exportar arquivo na tela lcredi
DECLARE
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17);

  pr_cdcooper INTEGER;
BEGIN

  FOR i IN coop.FIRST .. coop.LAST LOOP
    pr_cdcooper := coop(i);

  -- Permissões de consulta para os usuários pré-definidos pela CECRED                      
    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace)
     SELECT 'LCREDI',
                 'T',
                 ope.cdoperad,
                 NULL,
                 cop.cdcooper,
                 1,
                 1,
                 1
            FROM crapcop cop, crapope ope
           WHERE cop.cdcooper IN (pr_cdcooper)
             AND ope.cdsitope = 1
             AND cop.cdcooper = ope.cdcooper
             AND trim(upper(ope.cdoperad)) IN ('F0030517','F0032113','F0031090','F0030689','F0032714','F0031803'
                                              ,'F0030566','F0031401');

  END LOOP;

 COMMIT;
END;
/ 

INSERT INTO CRAPRDR (NMPROGRA, DTSOLICI) VALUES ('LCRE0001', SYSDATE); 
COMMIT;

UPDATE CRAPACA
   SET LSTPARAM = 'pr_nrdconta ,pr_idseqttl ,pr_dtmvtolt ,pr_cddopcao ,pr_nrsimula ,pr_cdlcremp ,pr_vlemprst ,pr_qtparepr ,pr_dtlibera ,pr_dtdpagto ,pr_percetop ,pr_cdfinemp ,pr_idfiniof ,pr_flggrava ,pr_idpessoa ,pr_nrseq_email ,pr_nrseq_telefone ,pr_idsegmento ,pr_tpemprst ,pr_idcarenc ,pr_dtcarenc, pr_flgerlog,pr_vlparepr,pr_vliofepr,pr_riscovariavel'
 WHERE NMDEACAO = 'SIMULA_GRAVA_SIMULACAO';

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('VERIFICA_CONTINGENCIA', 'LCRE0001', 'pc_contingencia_taxa_web', 'pr_cdcooper, pr_tpoperac', (SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LCRE0001' AND ROWNUM = 1));
COMMIT;

--- estoria 27186
-- carga_taxa.sql
DECLARE
  vr_contador INTEGER := 0;
BEGIN

  FOR rw_crapcop IN (SELECT c.cdcooper
                       FROM crapcop c
                      WHERE c.flgativo = 1
                      ORDER BY c.cdcooper) LOOP
  
    vr_contador := 0;
  
    FOR rw_craplcr IN (SELECT l.txmensal, l.cdcooper, l.cdlcremp
                         FROM craplcr l
                        WHERE l.cdcooper = rw_crapcop.cdcooper
                        AND   l.tpprodut <> 0) --não tratar TR
                        LOOP

      vr_contador := vr_contador + 1;
    
      BEGIN
        INSERT INTO tbcred_taxa_risco
          (cdcooper,
           cdlcremp,
           tpproduto,
           perisco_r1,
           perisco_r2,
           perisco_r3,
           perisco_r4,
           perisco_r5,
           perisco_r6,
           perisco_r7,
           perisco_r8,
           perisco_r9,
           perisco_r10,
           perisco_r11,
           perisco_r12,
           perisco_r13,
           perisco_r14,
           perisco_r15,
           perisco_r16,
           perisco_r17,
           perisco_r18,
           perisco_r19,
           perisco_r20,
           perisco_r21,
           perisco_r22,
           perisco_r23,
           perisco_r24,
           perisco_r25,
           perisco_r26,
           perisco_r27,
           perisco_r28,
           perisco_r29,
           perisco_r30,
           perisco_r31,
           perisco_r32,
           perisco_r33,
           perisco_r34,
           perisco_r35,
           perisco_r36,
           perisco_r37,
           perisco_r38,
           perisco_r39,
           perisco_r40,
           perisco_r41,
           perisco_r42,
           perisco_r43,
           perisco_r44,
           perisco_r45,
           cdoperad,
           dtalteracao)
        VALUES
          (rw_craplcr.cdcooper,
           rw_craplcr.cdlcremp,
           0,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           '1',
           SYSDATE);
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line(rw_crapcop.cdcooper || ' - ' ||
                               rw_craplcr.cdlcremp || ' - Erro Taxa.');
      END;
    
      BEGIN
        INSERT INTO tbcred_taxa_risco_his
          (cdcooper,
           cdlcremp,
           tpproduto,
           perisco_r1,
           perisco_r2,
           perisco_r3,
           perisco_r4,
           perisco_r5,
           perisco_r6,
           perisco_r7,
           perisco_r8,
           perisco_r9,
           perisco_r10,
           perisco_r11,
           perisco_r12,
           perisco_r13,
           perisco_r14,
           perisco_r15,
           perisco_r16,
           perisco_r17,
           perisco_r18,
           perisco_r19,
           perisco_r20,
           perisco_r21,
           perisco_r22,
           perisco_r23,
           perisco_r24,
           perisco_r25,
           perisco_r26,
           perisco_r27,
           perisco_r28,
           perisco_r29,
           perisco_r30,
           perisco_r31,
           perisco_r32,
           perisco_r33,
           perisco_r34,
           perisco_r35,
           perisco_r36,
           perisco_r37,
           perisco_r38,
           perisco_r39,
           perisco_r40,
           perisco_r41,
           perisco_r42,
           perisco_r43,
           perisco_r44,
           perisco_r45,
           cdoperad,
           dtalteracao)
        VALUES
          (rw_craplcr.cdcooper,
           rw_craplcr.cdlcremp,
           0,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           rw_craplcr.txmensal,
           '1',
           SYSDATE);
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line(rw_crapcop.cdcooper || ' - ' ||
                               rw_craplcr.cdlcremp || ' - Erro Historico.');
      END;
          
    END LOOP;
  
    dbms_output.put_line(rw_crapcop.cdcooper || ' - ' || vr_contador);
  
   COMMIT;
  
  END LOOP;

END;
/

--p441_mvp -- TELA_LCREDI.PCK
UPDATE crapaca  -- tirar prm nrgrupo
SET   LSTPARAM = 'pr_cdlcremp,pr_dslcremp,pr_tpctrato,pr_txjurfix,pr_txjurvar,pr_txpresta,pr_qtdcasas,pr_nrinipre,pr_nrfimpre,pr_txbaspre,pr_qtcarenc,pr_vlmaxass,pr_vlmaxasj,pr_txminima,pr_txmaxima,pr_perjurmo,pr_tpdescto,pr_nrdevias,pr_cdusolcr,pr_flgtarif,pr_flgtaiof,pr_vltrfesp,pr_flgcrcta,pr_dsoperac,pr_dsorgrec,pr_manterpo,pr_flgimpde,pr_flglispr,pr_tplcremp,pr_cdmodali,pr_cdsubmod,pr_flgrefin,pr_flgreneg,pr_qtrecpro,pr_consaut,pr_flgdisap,pr_flgcobmu,pr_flgsegpr,pr_cdhistor,pr_flprapol,pr_tpprodut,pr_cddindex,pr_permingr,pr_vlperidx,pr_tpmodcon,pr_vlmaxopr' where NMDEACAO IN ('ALTLINHA');

UPDATE crapaca -- tirar prm nrgrupo
SET   LSTPARAM = 'pr_cdlcremp,pr_dslcremp,pr_tpctrato,pr_txjurfix,pr_txjurvar,pr_txpresta,pr_qtdcasas,pr_nrinipre,pr_nrfimpre,pr_txbaspre,pr_qtcarenc,pr_vlmaxass,pr_vlmaxasj,pr_txminima,pr_txmaxima,pr_perjurmo,pr_tpdescto,pr_nrdevias,pr_cdusolcr,pr_flgtarif,pr_flgtaiof,pr_vltrfesp,pr_flgcrcta,pr_dsoperac,pr_dsorgrec,pr_manterpo,pr_flgimpde,pr_flglispr,pr_tplcremp,pr_cdmodali,pr_cdsubmod,pr_flgrefin,pr_flgreneg,pr_qtrecpro,pr_consaut,pr_flgdisap,pr_flgcobmu,pr_flgsegpr,pr_cdhistor,pr_flprapol,pr_cdfinali,pr_tpprodut,pr_cddindex,pr_permingr,pr_vlperidx,pr_tpmodcon,pr_vlmaxopr' where NMDEACAO IN ('INCLINHA');

UPDATE crapaca
SET   LSTPARAM = LSTPARAM||',pr_perisco_r1,pr_perisco_r2,pr_perisco_r3,pr_perisco_r4,pr_perisco_r5,pr_perisco_r6,pr_perisco_r7,pr_perisco_r8,pr_perisco_r9,pr_perisco_r10,pr_perisco_r11,pr_perisco_r12,pr_perisco_r13,pr_perisco_r14,pr_perisco_r15,pr_perisco_r16,pr_perisco_r17,pr_perisco_r18,pr_perisco_r19,pr_perisco_r20,pr_perisco_r21,pr_perisco_r22,pr_perisco_r23,pr_perisco_r24,pr_perisco_r25,pr_perisco_r26,pr_perisco_r27,pr_perisco_r28,pr_perisco_r29,pr_perisco_r30,pr_perisco_r31,pr_perisco_r32,pr_perisco_r33,pr_perisco_r34,pr_perisco_r35,pr_perisco_r36,pr_perisco_r37,pr_perisco_r38,pr_perisco_r39,pr_perisco_r40,pr_perisco_r41,pr_perisco_r42,pr_perisco_r43,pr_perisco_r44,pr_perisco_r45' where NMDEACAO IN ('ALTLINHA','INCLINHA');

commit;

insert into crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA)
values (4515, '4515 - Valor da taxa nao pode ser vazio.', 1, 0);

insert into crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA)
values (4516, '4516 - Valor da taxa nao pode ser zero para produto PP.', 1, 0);

insert into crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA)
values (4517, '4517 - Linha de credito invalida.', 1, 0);

insert into crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA)
values (4518, '4518 - Taxa informada invalida.', 1, 0);

insert into crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA)
values (4519, '4519 - Nome do arquivo invalido.', 1, 0);

Commit;

--- fim estoria 27186

-- estoria 27188
INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('IMPORTAXASLCREDI','TELA_LCREDI','pc_importar_taxas','pr_nmarquiv',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_LCREDI' AND ROWNUM = 1));        

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('EXPORTAXASLCREDI','TELA_LCREDI','pc_exportar_taxas','',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_LCREDI' AND ROWNUM = 1));   

COMMIT;

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'DIR_IMP_TAXAS_LINHA', 'Diretório para importação das taxas', '/usr/sistemas/Ayllos/Produtos/Credito/Taxas/Importar/');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'DIR_IMP_PROC_TAXAS_LINHA', 'Diretório para arq. processados na importação das taxas', '/usr/sistemas/Ayllos/Produtos/Credito/Taxas/Importar/Processados/');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'DIR_EXP_TAXAS_LINHA', 'Diretório para exportação das taxas', '/usr/sistemas/Ayllos/Produtos/Credito/Taxas/Exportar/');

COMMIT;
--fim estoria 2718

-- estoria 27194

update crapaca set lstparam= lstparam||' ,pr_incalris' 
where nmdeacao='PAREST_ALTERA_PARAM';

commit;

DECLARE
/*
    Autor   : Elton (AMcom)
    Data    : Outubro/2019                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Especifico

    Objetivo  : Gravar novas linhas  de parametro  para tela PAREST
*/

    -- Variáveis
    vr_qtcooper NUMBER;
    vr_dscritic VARCHAR2(10000);


    -- Selecionar ooperativa
    CURSOR cr_crapcop IS
      SELECT *
        FROM crapcop  c
       WHERE c.flgativo  = 1
    ORDER BY c.cdcooper;    
    rw_crapcop cr_crapcop%ROWTYPE;

  BEGIN
    vr_qtcooper := 0;


    -- Abre cursor de cooperativas
    OPEN cr_crapcop;
    LOOP
      FETCH cr_crapcop
       INTO rw_crapcop;
      IF cr_crapcop%NOTFOUND THEN
         EXIT;
      END IF;

      vr_qtcooper := vr_qtcooper + 1;

      -- Grava linha com as Cooperativas
      BEGIN
        INSERT INTO crapprm (
                NMSISTEM,
                CDCOOPER,
                CDACESSO,
                DSTEXPRM,
                DSVLRPRM)
        VALUES('CRED'
               ,rw_crapcop.cdcooper
               ,'CALCULA_NIVELRISCO_TAXA'
               ,'Calcular Nível de Risco (Taxa) 1-Sim 0-Nao'
               ,'1'
               );
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não inseriu linha na tab CRAPPRM';
          DBMS_OUTPUT.PUT_LINE (vr_dscritic);
 
          EXIT;
      END;

    END LOOP;
    CLOSE cr_crapcop;

    DBMS_OUTPUT.PUT_LINE (
      'Incluiu ' || vr_qtcooper || ' cooperativas na tab parametros');

    commit;

end;
/

DECLARE
/*
  Autor   : Elton (AMcom)
  Data    : Outubro/2019

  Frequencia: Especifico

  Objetivo  : Rotina para popular nova tabela de parametros TBCRED_PARAMETRO_ANALISE, com tipo de produto 2 (Simulador Emp/Fin),
              baseada na tipo de produto 0 - Emprestimo.
*/

  -- Variáveis
  vr_qtcooper NUMBER;
  vr_dscritic VARCHAR2(10000);

  CURSOR cr_crapcop IS
    SELECT DECODE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                            pr_cdcooper => cop.cdcooper,
                                            pr_cdacesso => 'CONTIGENCIA_ESTEIRA_IBRA'),
                  1,
                  'SIM',
                  0,'NAO') contigencia,
          GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                            pr_cdcooper => cop.cdcooper,
                                            pr_cdacesso => 'CONTIGENCIA_ESTEIRA_IBRA') incontigen,

           DECODE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                            pr_cdcooper => cop.cdcooper,
                                            pr_cdacesso => 'ENVIA_EMAIL_COMITE'),
                  1,
                  'SIM',
                  0,'NAO') comite,
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                            pr_cdcooper => cop.cdcooper,
                                            pr_cdacesso => 'ENVIA_EMAIL_COMITE')  incomite,

           DECODE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                            pr_cdcooper => cop.cdcooper,
                                            pr_cdacesso => 'ANALISE_OBRIG_MOTOR_CRED'),
                  1,
                  'SIM',
                  0,'NAO') analise_autom,

           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                            pr_cdcooper => cop.cdcooper,
                                            pr_cdacesso => 'ANALISE_OBRIG_MOTOR_CRED') inanlautom,
           'PoliticaNivelRiscoPFSimulacao' nmregmpf,
           'PoliticaNivelRiscoPJSimulacao' nmregmpj,
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'TIME_RESP_MOTOR_IBRA') qtsstime,
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'QTD_MES_HIST_DEV_CHEQUES') qtmeschq,
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'QTD_MES_HIST_DEV_CH_AL11') qtmeschqal11,
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'QTD_MES_HIST_DEV_CH_AL12') qtmeschqal12,
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'QTD_MES_HIST_ESTOUROS') qtmesest,
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'QTD_MES_HIST_EMPREST') qtmesemp,
           --441
          GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'CALCULA_NIVELRISCO_TAXA') incalris,
           --
           cdcooper,
           Initcap(nmrescop) nmrescop

      FROM crapcop cop
     WHERE 1  = 1
       and cop.flgativo = 1
     ORDER BY cop.cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

begin
  FOR rw_crapcop  in cr_crapcop  LOOP
      -- Grava linha para as cooperativas
      BEGIN
        INSERT INTO CECRED.TBCRED_PARAMETRO_ANALISE (
              cdcooper,
              tpproduto,
              incomite,
              incontigen,
              inanlautom,
              nmregmpf,
              nmregmpj,
              qtsstime,
              qtmeschq,
              qtmeschqal11,
              qtmeschqal12,
              qtmesest,
              qtmesemp,
              incalris)        
        VALUES(
             rw_crapcop.cdcooper,  -- cdcooper,
             2,  -- tpproduto,
             rw_crapcop.incomite, -- incomite,
             rw_crapcop.incontigen, -- incontigen,
             rw_crapcop.inanlautom,  -- inanlautom,
             rw_crapcop.nmregmpf,  -- nmregmpf,
             rw_crapcop.nmregmpj, -- nmregmpj,
             rw_crapcop.qtsstime,  -- qtsstime,
             rw_crapcop.qtmeschq,  -- qtmeschq,
             NVL(rw_crapcop.qtmeschqal11,0), -- qtmeschqal11,
             NVL(rw_crapcop.qtmeschqal12,0), -- qtmeschqal12,
             rw_crapcop.qtmesest,  -- qtmesest,
             rw_crapcop.qtmesemp,  -- qtmesemp,
             rw_crapcop.incalris-- incalris
             )  ;     
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não inseriu linha na tab TBCRED_PARAMETRO_ANALISE - ' || SQLERRM;
          DBMS_OUTPUT.PUT_LINE (vr_dscritic);
          EXIT;
      END;
  END LOOP;
  Commit;
END;
/
-- fim estoria 27194

--
insert into crapprm
  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values
  ('CRED',
   1,
   'ATUALIZA_TAXA_TR',
   'Contratos que devem ser atualizados quando alterado taxa de linha TR',
   '972431');
commit;


--p441_mvp
--- estoria 27195
DECLARE 
BEGIN
  INSERT INTO crapprm (
          NMSISTEM,
          CDCOOPER,
          CDACESSO,
          DSTEXPRM,
          DSVLRPRM)
  VALUES('CRED'
         ,0---indicando para todas
         ,'PEFAIXA_RISCO_TAXA'
         ,'Percentual da faixa de risco da taxa - padrao.'
         ,'R45');
         
  commit;         
EXCEPTION
  WHEN OTHERS THEN

    DBMS_OUTPUT.PUT_LINE ('Não inseriu linha na tab CRAPPRM');

END;
/


insert into crapcri (cdcritic,dscritic,tpcritic,flgchama) values
                    (4511,'Simulacao Emprestimo nao encontrada!',4,0);

insert into crapcri (cdcritic,dscritic,tpcritic,flgchama) values
                    (4512,'Nao foi possivel retornar Protocolo Taxa Simulação!',4,0);

insert into crapcri (cdcritic,dscritic,tpcritic,flgchama) values
                    (4513,'Retorno Risco Motor Simulacao nao foi processado.',4,0);

insert into crapcri (cdcritic,dscritic,tpcritic,flgchama) values
                    (4514,'Risco Simulacao nao foi solicitado para o Motor.',4,0);

Commit;

DECLARE 
BEGIN
  INSERT INTO crapprm (
          NMSISTEM,
          CDCOOPER,
          CDACESSO,
          DSTEXPRM,
          DSVLRPRM)
  VALUES('CRED'
         ,0---indicando para todas
         ,'URI_WEBSRV_RET_MOTOR_SIM'
         ,'URI de retorno do Motor Simulação do Web Service Ibratan.'
         ,'https://wayllos.cecred.coop.br/taxa');
         
  commit;         
EXCEPTION
  WHEN OTHERS THEN

    DBMS_OUTPUT.PUT_LINE ('Não inseriu linha na tab CRAPPRM');

END;
/

-- motivo: comunicação da class_rest_taxa.php com a pc_retorno_motor_sim_aut, quando retorno automatica do motor simulação.
declare 

 
  -- ALTERAR
  NOME_DA_ACAO VARCHAR2(40) := 'WEBS0004_RET_MOTOR_SIMULA_AUT';
  PROCEDURE_DA_ACAO VARCHAR2(100) := 'pc_retorno_motor_sim_aut';
  PACKAGE_DA_ACAO VARCHAR2(100) := 'WEBS0004';
  PARAMETROS_DA_ACAO VARCHAR2(1000):= 'pr_cdorigem,pr_dsprotoc,pr_nrtransa,pr_dsresana,pr_indrisco,pr_vlmultipli,pr_indsemclass,pr_dsrequis,pr_namehost';
 -- FIM ALTERAR

  CURSOR cr_craprdr(pr_nmprogra IN craprdr.nmprogra%TYPE) IS
  SELECT * FROM craprdr
   WHERE craprdr.nmprogra = pr_nmprogra;
  rw_craprdr cr_craprdr%ROWTYPE;

  CURSOR cr_crapaca(pr_nmdeacao IN crapaca.nmdeacao%TYPE
                   ,pr_nmpackag IN crapaca.nmpackag%TYPE
                   ,pr_nmproced IN crapaca.nmproced%TYPE
                   ,pr_nrseqrdr IN crapaca.nrseqrdr%TYPE) IS
  SELECT * FROM crapaca
   WHERE UPPER(crapaca.nmdeacao) = UPPER(pr_nmdeacao)
     AND UPPER(crapaca.nmpackag) = UPPER(pr_nmpackag)
     AND UPPER(crapaca.nmproced) = UPPER(pr_nmproced)
     AND crapaca.nrseqrdr = pr_nrseqrdr;
  rw_crapaca cr_crapaca%ROWTYPE;
  
  vr_exec_erro EXCEPTION;
  vr_dscritic  VARCHAR2(1000);  

begin
  
  dbms_output.put_line('Inicio do programa');
  
  -- Mensageria
  OPEN cr_craprdr(pr_nmprogra => PACKAGE_DA_ACAO);
  FETCH cr_craprdr INTO rw_craprdr;
    
  -- Verifica se existe a tela do ayllos web
  IF cr_craprdr%NOTFOUND THEN
   
    -- Se não encontrar
    CLOSE cr_craprdr;

    -- Insere ação da tela do aylloas web
    INSERT INTO craprdr(nmprogra
                       ,dtsolici) 
                 values(PACKAGE_DA_ACAO
                       ,SYSDATE);
    -- Posiciona no registro criado
    OPEN cr_craprdr(pr_nmprogra => PACKAGE_DA_ACAO);
    FETCH cr_craprdr INTO rw_craprdr;

    dbms_output.put_line('Insere CRAPRDR -> '||PACKAGE_DA_ACAO||': ' || rw_craprdr.nrseqrdr);

  END IF;  
  
  -- Fecha o cursor
  CLOSE cr_craprdr;

  -- INICIO MENSAGERIA   
  
  OPEN cr_crapaca(pr_nmdeacao => NOME_DA_ACAO
                 ,pr_nmpackag => PACKAGE_DA_ACAO
                 ,pr_nmproced => PROCEDURE_DA_ACAO
                 ,pr_nrseqrdr => rw_craprdr.nrseqrdr);
                   
  FETCH cr_crapaca INTO rw_crapaca;
    
  -- Verifica se existe a ação tela do ayllos web
  IF cr_crapaca%NOTFOUND THEN
    
    -- Insere ação da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES(NOME_DA_ACAO,
                        PACKAGE_DA_ACAO,
                        PROCEDURE_DA_ACAO,
                        PARAMETROS_DA_ACAO,
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> '||NOME_DA_ACAO||' -> '||PACKAGE_DA_ACAO||'.'||PROCEDURE_DA_ACAO);
    
  END IF;
  
  CLOSE cr_crapaca;  
  
  dbms_output.put_line('Fim do programa');
   
  COMMIT;
  
EXCEPTION 
  WHEN vr_exec_erro THEN
    
    dbms_output.put_line('Erro:' || vr_dscritic);
    ROLLBACK;
   
  WHEN OTHERS THEN
        
    dbms_output.put_line('Erro a executar o programa:' || SQLERRM);

    ROLLBACK;
    
end;
/
-- fim estoria 27195



-- motivo: para chamada na tela Atenda, Emprestimo, Ao incluir uma negociação da taxa.
declare 
 
  -- ALTERAR
  NOME_DA_ACAO VARCHAR2(40) := 'INCLUIR_NEG_TAXA';
  PROCEDURE_DA_ACAO VARCHAR2(100) := 'pc_incluir_negociacao_taxa';
  PACKAGE_DA_ACAO VARCHAR2(100) := 'EMPR0022';
  PARAMETROS_DA_ACAO VARCHAR2(1000):= 'pr_nrdconta ,pr_nrctremp ,pr_txnegoci';
  
 -- FIM ALTERAR

  CURSOR cr_craprdr(pr_nmprogra IN craprdr.nmprogra%TYPE) IS
  SELECT * FROM craprdr
   WHERE craprdr.nmprogra = pr_nmprogra;
  rw_craprdr cr_craprdr%ROWTYPE;

  CURSOR cr_crapaca(pr_nmdeacao IN crapaca.nmdeacao%TYPE
                   ,pr_nmpackag IN crapaca.nmpackag%TYPE
                   ,pr_nmproced IN crapaca.nmproced%TYPE
                   ,pr_nrseqrdr IN crapaca.nrseqrdr%TYPE) IS
  SELECT * FROM crapaca
   WHERE UPPER(crapaca.nmdeacao) = UPPER(pr_nmdeacao)
     AND UPPER(crapaca.nmpackag) = UPPER(pr_nmpackag)
     AND UPPER(crapaca.nmproced) = UPPER(pr_nmproced)
     AND crapaca.nrseqrdr = pr_nrseqrdr;
  rw_crapaca cr_crapaca%ROWTYPE;
  
  vr_exec_erro EXCEPTION;
  vr_dscritic  VARCHAR2(1000);  

begin
  
  dbms_output.put_line('Inicio do programa');
  
  -- Mensageria
  OPEN cr_craprdr(pr_nmprogra => PACKAGE_DA_ACAO);
  FETCH cr_craprdr INTO rw_craprdr;
    
  -- Verifica se existe a tela do ayllos web
  IF cr_craprdr%NOTFOUND THEN
   
    -- Se não encontrar
    CLOSE cr_craprdr;

    -- Insere ação da tela do aylloas web
    INSERT INTO craprdr(nmprogra
                       ,dtsolici) 
                 values(PACKAGE_DA_ACAO
                       ,SYSDATE);
    -- Posiciona no registro criado
    OPEN cr_craprdr(pr_nmprogra => PACKAGE_DA_ACAO);
    FETCH cr_craprdr INTO rw_craprdr;

    dbms_output.put_line('Insere CRAPRDR -> '||PACKAGE_DA_ACAO||': ' || rw_craprdr.nrseqrdr);

  END IF;  
  
  -- Fecha o cursor
  CLOSE cr_craprdr;

  -- INICIO MENSAGERIA   
  
  OPEN cr_crapaca(pr_nmdeacao => NOME_DA_ACAO
                 ,pr_nmpackag => PACKAGE_DA_ACAO
                 ,pr_nmproced => PROCEDURE_DA_ACAO
                 ,pr_nrseqrdr => rw_craprdr.nrseqrdr);
                   
  FETCH cr_crapaca INTO rw_crapaca;
    
  -- Verifica se existe a ação tela do ayllos web
  IF cr_crapaca%NOTFOUND THEN
    
    -- Insere ação da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES(NOME_DA_ACAO,
                        PACKAGE_DA_ACAO,
                        PROCEDURE_DA_ACAO,
                        PARAMETROS_DA_ACAO,
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> '||NOME_DA_ACAO||' -> '||PACKAGE_DA_ACAO||'.'||PROCEDURE_DA_ACAO);
    
  END IF;
  
  CLOSE cr_crapaca;  
  
  dbms_output.put_line('Fim do programa');
   
  COMMIT;
  
EXCEPTION 
  WHEN vr_exec_erro THEN
    
    dbms_output.put_line('Erro:' || vr_dscritic);
    ROLLBACK;
   
  WHEN OTHERS THEN
        
    dbms_output.put_line('Erro a executar o programa:' || SQLERRM);

    ROLLBACK;
    
end;
/


-- Realizar cadastro de permissoes para botão alterar taxa
DECLARE
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17);

  pr_cdcooper INTEGER;
BEGIN

  FOR i IN coop.FIRST .. coop.LAST LOOP
    pr_cdcooper := coop(i);
  
    -- Adicionar a opção para o botão alterar taxa 'T'
    UPDATE craptel
       SET cdopptel = cdopptel || ',T',
           lsopptel = lsopptel || ',ALTERAR TAXA'
     WHERE cdcooper = pr_cdcooper
       AND nmdatela = 'ATENDA' 
       AND nmrotina = 'EMPRESTIMOS';
  
    -- Permissões de consulta para os usuários pré-definidos pela CECRED                      
    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace)
      SELECT 'ATENDA',
             'T',
             ope.cdoperad,
             'EMPRESTIMOS',
             cop.cdcooper,
             1,
             0,
             2
        FROM crapcop cop, crapope ope
       WHERE cop.cdcooper IN (pr_cdcooper)
         AND ope.cdsitope = 1
         AND cop.cdcooper = ope.cdcooper
         AND trim(upper(ope.cdoperad)) IN ('F0030517', 'F0032113', 'F0031090', 'F0030689', 'F0032714', 'F0031803', 'F0030566', 'F0031401'); -- operadores habilitados
  
  END LOOP;

  COMMIT;
END;
/



-- motivo: para chamada na tela Atenda, Emprestimo, Verificar excessão para alterar taxa.
declare 
 
  -- ALTERAR
  NOME_DA_ACAO VARCHAR2(40) := 'VERIFICA_OPERAC_CALC_RISCO';
  PROCEDURE_DA_ACAO VARCHAR2(100) := 'pc_verif_operac_calc_risco_web';
  PACKAGE_DA_ACAO VARCHAR2(100) := 'EMPR0022';
  PARAMETROS_DA_ACAO VARCHAR2(1000):= 'pr_nrdconta ,pr_nrctremp';
  
 -- FIM ALTERAR

  CURSOR cr_craprdr(pr_nmprogra IN craprdr.nmprogra%TYPE) IS
  SELECT * FROM craprdr
   WHERE craprdr.nmprogra = pr_nmprogra;
  rw_craprdr cr_craprdr%ROWTYPE;

  CURSOR cr_crapaca(pr_nmdeacao IN crapaca.nmdeacao%TYPE
                   ,pr_nmpackag IN crapaca.nmpackag%TYPE
                   ,pr_nmproced IN crapaca.nmproced%TYPE
                   ,pr_nrseqrdr IN crapaca.nrseqrdr%TYPE) IS
  SELECT * FROM crapaca
   WHERE UPPER(crapaca.nmdeacao) = UPPER(pr_nmdeacao)
     AND UPPER(crapaca.nmpackag) = UPPER(pr_nmpackag)
     AND UPPER(crapaca.nmproced) = UPPER(pr_nmproced)
     AND crapaca.nrseqrdr = pr_nrseqrdr;
  rw_crapaca cr_crapaca%ROWTYPE;
  
  vr_exec_erro EXCEPTION;
  vr_dscritic  VARCHAR2(1000);  

begin
  
  dbms_output.put_line('Inicio do programa');
  
  -- Mensageria
  OPEN cr_craprdr(pr_nmprogra => PACKAGE_DA_ACAO);
  FETCH cr_craprdr INTO rw_craprdr;
    
  -- Verifica se existe a tela do ayllos web
  IF cr_craprdr%NOTFOUND THEN
   
    -- Se não encontrar
    CLOSE cr_craprdr;

    -- Insere ação da tela do aylloas web
    INSERT INTO craprdr(nmprogra
                       ,dtsolici) 
                 values(PACKAGE_DA_ACAO
                       ,SYSDATE);
    -- Posiciona no registro criado
    OPEN cr_craprdr(pr_nmprogra => PACKAGE_DA_ACAO);
    FETCH cr_craprdr INTO rw_craprdr;

    dbms_output.put_line('Insere CRAPRDR -> '||PACKAGE_DA_ACAO||': ' || rw_craprdr.nrseqrdr);

  END IF;  
  
  -- Fecha o cursor
  CLOSE cr_craprdr;

  -- INICIO MENSAGERIA   
  
  OPEN cr_crapaca(pr_nmdeacao => NOME_DA_ACAO
                 ,pr_nmpackag => PACKAGE_DA_ACAO
                 ,pr_nmproced => PROCEDURE_DA_ACAO
                 ,pr_nrseqrdr => rw_craprdr.nrseqrdr);
                   
  FETCH cr_crapaca INTO rw_crapaca;
    
  -- Verifica se existe a ação tela do ayllos web
  IF cr_crapaca%NOTFOUND THEN
    
    -- Insere ação da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES(NOME_DA_ACAO,
                        PACKAGE_DA_ACAO,
                        PROCEDURE_DA_ACAO,
                        PARAMETROS_DA_ACAO,
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> '||NOME_DA_ACAO||' -> '||PACKAGE_DA_ACAO||'.'||PROCEDURE_DA_ACAO);
    
  END IF;
  
  CLOSE cr_crapaca;  
  
  dbms_output.put_line('Fim do programa');
   
  COMMIT;
  
EXCEPTION 
  WHEN vr_exec_erro THEN
    
    dbms_output.put_line('Erro:' || vr_dscritic);
    ROLLBACK;
   
  WHEN OTHERS THEN
        
    dbms_output.put_line('Erro a executar o programa:' || SQLERRM);

    ROLLBACK;
    
END;
/

--- estoria 28142
insert into crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA)
values (4521, '4521 - Risco da Operacao nao localizado! Os Riscos devem ser entre R1 e R45.', 1, 0);

insert into crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA)
values (4520, '4520 - Risco da Operacao nao pode ser nulo.', 1, 0);

Commit;
--- fim estoria 28142

-- estoria 27206
insert into crapcri (cdcritic,dscritic,tpcritic,flgchama) values
                    (4522,'Erro ao buscar taxa mensal do pre-aprovado.',4,0);

Commit;

-- fim estoria 27206

INSERT INTO crapprm
  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
VALUES
  ('CRED',
   0,
   'FIN_IGNORADAS_VLMAXOPR',
   'Finalidades sem resticao de valor de operacao',
   '58,59,68,77');
   
Commit;

