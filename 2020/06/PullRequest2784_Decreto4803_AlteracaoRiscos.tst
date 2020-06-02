PL/SQL Developer Test script 3.0
266
/*
Autor: Luiz Otávio Olinger Momm / AMCOM
Analista: Wagner da Silva / AILOS
Feature 31023:Demanda 4803
Squad Riscos

Objetivo:

- Atualizar todos os riscos inclusão na crawepr e riscos rating na tbrisco_operacoes
  para alterar os riscos de contratos de empréstimos, renegociações facilitadas e 
  REFIN conforme decreto Resolução n° 4.803 de 9/4/2020 de operações efetivadas
  entre 01/03/2020 a 30/09/2020 com riscos congelados em 29/02/2020 de acordo com
  regras programadas.

- O script irá filtrar de forma mais simplificada possível para diminuir a verificação
  de qual contrato é ou não do decreto, porém, algumas validações ainda vão ser realizadas
  antes de alterar os riscos.

Configurações:
- O programa irá respeitar as configurações das tabelas de parâmetros onde o valor por
  cooperativa estará na crappco:
  SELECT * FROM crappco WHERE cdpartar IN (SELECT cdcadast FROM crapbat WHERE cdbattar = 'DEC4803LIN');
  SELECT * FROM crappco WHERE cdpartar IN (SELECT cdcadast FROM crapbat WHERE cdbattar = 'DEC4803DAT');
  SELECT * FROM crappco WHERE cdpartar IN (SELECT cdcadast FROM crapbat WHERE cdbattar = 'DEC4803SIT');
  Caso o decreto esteja desligado não será alterado o script mesmo passando por todos os
  possíveis contratos. Caso houver mais linhas cadastradas o script não irá alterar as
  demais linhas devido ao filtro no SELECT e assim por diante.
*/
DECLARE
  -- Cursor onde filtra os possíveis contratos para alteração
  -- pois existe a chamada do decreto que pode validar outros
  -- pontos não adicionados no SELECT
  CURSOR cr_decreto(pr_cdcooper  crapcop.cdcooper%TYPE) IS
    SELECT p.cdcooper
          ,p.nrdconta
          ,p.nrctremp
          ,o.inrisco_rating
          ,(SELECT MAX(DECODE(r.innivris, 1, 2, 10, 9, r.innivris))
              FROM crapris r
             WHERE r.cdmodali IN (299,499)
               AND r.dtrefere = '29/02/2020'
               AND r.cdcooper = p.cdcooper
               AND r.nrdconta = p.nrdconta) AS riscoFinal
          ,(SELECT MAX(r.qtdiaatr)
              FROM crapris r
             WHERE r.cdmodali IN (299,499)
               AND r.dtrefere = '29/02/2020'
               AND r.cdcooper = p.cdcooper
               AND r.nrdconta = p.nrdconta) AS diasAtraso
          ,p.cdlcremp
          ,DECODE((w.nrctrliq##1 +
                   w.nrctrliq##2 +
                   w.nrctrliq##3 +
                   w.nrctrliq##4 +
                   w.nrctrliq##5 +
                   w.nrctrliq##6 +
                   w.nrctrliq##7 +
                   w.nrctrliq##8 +
                   w.nrctrliq##9 +
                   w.nrctrliq##10),0,'0','1') AS REFIN
          ,NVL((SELECT 1
                  FROM tbepr_renegociacao_contrato rc
                 WHERE rc.cdcooper = w.cdcooper
                   AND rc.nrdconta = w.nrdconta
                   AND rc.nrctrepr = w.nrctremp
                   AND rownum = 1),0) RenegFacilit
-- Colunas usadas apenas para rollback
          ,w.progress_recid craweprId
          ,w.dsnivris
          ,w.dsnivori
          ,o.inrisco_inclusao
          ,o.inorigem_rating
          ,o.innivel_rating
          ,o.inpontos_rating
          ,o.insegmento_rating
-- Colunas usadas apenas para rollback
    FROM crapepr p
        ,crawepr w
        ,tbrisco_operacoes o
    WHERE p.cdcooper = pr_cdcooper
      AND p.nrdconta = w.nrdconta
      AND p.nrctremp = w.nrctremp
      AND p.inliquid = 0                            -- Contratos não liquidados
      AND p.dtmvtolt >= '01/03/2020'                -- Todas operacoes do início do decreto
      AND p.cdcooper = pr_cdcooper
      AND p.nrdconta = o.nrdconta
      AND p.nrctremp = o.nrctremp
      AND o.inorigem_rating NOT IN (8)              -- Operacoes já alteradas pelo decreto não precisa de ajuste
      AND o.tpctrato = 90
      AND (SELECT MAX(r.qtdiaatr)
              FROM crapris r
             WHERE r.cdmodali IN (299,499)
               AND r.dtrefere = '29/02/2020'
               AND r.cdcooper = p.cdcooper
               AND r.nrdconta = p.nrdconta) < 15    -- Atraso de operacoes de empréstimos menor que 15 dias
      AND (SELECT MAX(DECODE(r.innivris, 1, 2, 10, 9, r.innivris))
              FROM crapris r
             WHERE r.cdmodali IN (299,499)
               AND r.dtrefere = '29/02/2020'
               AND r.cdcooper = p.cdcooper
               AND r.nrdconta = p.nrdconta) < o.inrisco_rating
      -- Apenas linhas REFIN ou RENEGOCIAÇÃO FACILITADA ou CONTRATOS com linhas selecionadas
      AND (
                (
                   w.nrctrliq##1 > 0 OR
                   w.nrctrliq##2 > 0 OR
                   w.nrctrliq##3 > 0 OR
                   w.nrctrliq##4 > 0 OR
                   w.nrctrliq##5 > 0 OR
                   w.nrctrliq##6 > 0 OR
                   w.nrctrliq##7 > 0 OR
                   w.nrctrliq##8 > 0 OR
                   w.nrctrliq##9 > 0 OR
                   w.nrctrliq##10 > 0 OR
                   w.nrliquid > 0
                )
                OR
                (
                   EXISTS (SELECT 1
                             FROM tbepr_renegociacao_contrato rc
                            WHERE rc.cdcooper = w.cdcooper
                              AND rc.nrdconta = w.nrdconta
                              AND rc.nrctrepr = w.nrctremp)
                )
                OR
                (
                   p.tpemprst IN (1,2)
                   AND
                   (
                      (p.cdcooper = 1 AND p.cdlcremp IN (5504,9675,9677,9676,9660,9633,9632,9664,9654,9653,9679,9650,9651,9652,9655,9656,9657,43001,30000,14401,34401,14701,24401,44401,24701,42701,40000))
                      OR
                      (p.cdcooper = 2 AND p.cdlcremp IN (840,841,978,979,985,1043,1044,350,351,352,1500))
                      OR
                      (p.cdcooper = 5 AND p.cdlcremp IN (46,89,90,91,92,93,652,712,713,714,733,734))
                      OR
                      (p.cdcooper = 6 AND p.cdlcremp IN (44,43,45,46,47,48,49,50,51,72,85,87))
                      OR
                      (p.cdcooper = 7 AND p.cdlcremp IN (220,221,130,131,3678,3710,3687,195,96,197,198))
                      OR
                      (p.cdcooper = 8 AND p.cdlcremp IN (158,159,160,162,163,164,168,174,194,206,7081,74))
                      OR
                      (p.cdcooper = 9 AND p.cdlcremp IN (451,452,453,454,455,457,458,150,151,154,155,156,157,158,159,263,264))
                      OR
                      (p.cdcooper = 10 AND p.cdlcremp IN (193,194,192,195,175,122,153,123,124,250,252,251,198,199,197,201,174,159,162,220,164,163,60,250,251,252))
                      OR
                      (p.cdcooper = 11 AND p.cdlcremp IN (51,204,205,206,207,208,209,210,211,212,213,214,215,382,383))
                      OR
                      (p.cdcooper = 12 AND p.cdlcremp IN (25,26,245,246,1500,129,130,137,145,169,206,215,219,220,242,243,244))
                      OR
                      (p.cdcooper = 13 AND p.cdlcremp IN (76,184,998,999,67,171,150,57,240,241,242,281,341,342,343,344,345))
                      OR
                      (p.cdcooper = 14 AND p.cdlcremp IN (21,22,23,30,16,1600,6550,6551,6552,6553,6554,6555,6556,6557,6558,6559,6560,6561,3640,3641,3642,3643,3644,3645,3646,3647,3648,3649,3650,3651,3652,3653,3654,3655,3656,3657,3658,3659,3660,3661,3662,3663,3664,3665,3666,3667,3668,3669,3670,3671,3672,3673,3674,3575,3676,6850,6851,6852,6853,6854,6855,6856,6857,6858,6859,6860,3720,3721,3722,3723,3724,3725,3726,3727,3728,3729,3730,3731,3732,3733,3734,3735,3780,3781,3782,3783,3784,3785,3786,3787,3788,3789,3790,3791,3792,3793,3794,3795,6510,6511,6512,6513,514,6515,6516,6517,6518,6519,6520,6521,6522,6523,6524,6525,6526,6610,6611,6612,6613,6614,6615,6616,6617,6618,6619,6620,6621,6622,623,624,6625,6626,6810,6811,6812,6813,6814,6815,6816,6817,6818,6819,820,6821,822,6910,6911,6912,6913,6914,6915,6916,917,6918,6919,6920,6921,922,6923,6924,925,6710,6711,6712,6713,6714,715,716,6717,6718,6719,6720,721,5035,5036,5037,5038,5039,5040,26,5027,028,029,031))
                   )
                )
          )
    ORDER BY p.cdcooper, p.nrdconta, p.nrctremp;

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper = 6 -- Únilos
    ORDER BY 1;

  vr_flrisco_decreto      NUMBER;
  vr_risco_atualizado     crapris.innivris%TYPE;
  vr_datafinal_atualizada DATE;
  vr_dsdireto             VARCHAR2(4000);
  vr_des_xml              CLOB;
  vr_texto_completo       VARCHAR2(32600);

  vr_typ_saida            VARCHAR2(3);
  vr_dscritic             VARCHAR2(2000);
  vr_incidente            VARCHAR2(50);

  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_rollback(pr_des_dados IN VARCHAR2,
                                pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    dbms_output.put_line(pr_des_dados);
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
  END;

BEGIN

  -- Ativa para cooperativa 6 o decreto
  UPDATE crappco SET dsconteu = '1' WHERE cdpartar = 80 AND cdcooper = 6;
  COMMIT;

  vr_incidente := 'RITM0071428';
  vr_dsdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas';
  gene0001.pc_OScommand_Shell(pr_des_comando => 'mkdir ' || vr_dsdireto || '/' || vr_incidente
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

  vr_dsdireto := vr_dsdireto || '/' || vr_incidente;

  -- Inicializar o CLOB
  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  vr_texto_completo := NULL;

  FOR rw_crapcop IN cr_crapcop LOOP
    FOR rw_decreto IN cr_decreto(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      IF rw_decreto.inrisco_rating IS NOT NULL THEN
        risc0003.obterDecretoRiscos(pr_cdcooper             => rw_decreto.cdcooper,
                                    pr_nrdconta             => rw_decreto.nrdconta,
                                    pr_nrctremp             => rw_decreto.nrctremp,
                                    pr_tpctrato             => 90,
                                    pr_tiporisco            => 'RAT',
                                    pr_risco_atual          => rw_decreto.inrisco_rating,
                                    pr_registrar_verlog     => 1,
                                    pr_flrisco_decreto      => vr_flrisco_decreto,
                                    pr_risco_atualizado     => vr_risco_atualizado,
                                    pr_datafinal_atualizada => vr_datafinal_atualizada);
        IF vr_flrisco_decreto = 1 THEN
          -- tbrisco_operacoes
          UPDATE tbrisco_operacoes o
             SET o.inrisco_inclusao = vr_risco_atualizado
                ,o.inrisco_rating = vr_risco_atualizado
                ,o.inorigem_rating = 8
                ,o.innivel_rating = 0
                ,o.inpontos_rating = 0
                ,o.insegmento_rating = ''
           WHERE o.cdcooper = rw_decreto.cdcooper
             AND o.nrdconta = rw_decreto.nrdconta
             AND o.nrctremp = rw_decreto.nrctremp
             AND o.tpctrato = 90;

          -- Espacos sempre no início da string
          pc_escreve_rollback('UPDATE tbrisco_operacoes o'  ||
                              ' SET o.inrisco_inclusao = '   || rw_decreto.inrisco_inclusao  ||
                              ', o.inrisco_rating = '       || rw_decreto.inrisco_rating    ||
                              ', o.inorigem_rating = '      || rw_decreto.inorigem_rating   ||
                              ', o.innivel_rating = '       || rw_decreto.innivel_rating    ||
                              ', o.inpontos_rating = '      || rw_decreto.inpontos_rating   ||
                              ', o.insegmento_rating = '''  || rw_decreto.insegmento_rating || '''' ||
                              ' WHERE o.cdcooper = ' || rw_decreto.cdcooper ||
                              ' AND o.nrdconta = '   || rw_decreto.nrdconta ||
                              ' AND o.nrctremp = '   || rw_decreto.nrctremp ||
                              ' AND o.tpctrato = 90;'||chr(10));
          -- crawepr
          UPDATE crawepr w
             SET w.dsnivris = risc0004.fn_traduz_risco(vr_risco_atualizado)
                ,w.dsnivori = risc0004.fn_traduz_risco(vr_risco_atualizado)
           WHERE w.cdcooper = rw_decreto.cdcooper
             AND w.nrdconta = rw_decreto.nrdconta
             AND w.nrctremp = rw_decreto.nrctremp;

          pc_escreve_rollback('UPDATE crawepr w SET w.dsnivris = '''|| rw_decreto.dsnivris ||''', w.dsnivori = '''|| rw_decreto.dsnivori ||''' WHERE w.progress_recid = '|| rw_decreto.craweprId ||';'||chr(10));

        END IF;
      END IF;
    END LOOP;
    -- COMMIT;
  END LOOP;
  pc_escreve_rollback('COMMIT;');
  pc_escreve_rollback(' ',TRUE);

  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_dsdireto, 'RISCOS_ALTERADOS_DECRETO4308_'||to_char(sysdate,'ddmmyyyy_hh24miss')|| '.txt', NLS_CHARSET_ID('UTF8'));
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);

END;
1
vr_dsdireto
0
0
4
rw_crapcop.cdcooper
vr_piorrisco
pr_risco_atual
pr_nrdconta
