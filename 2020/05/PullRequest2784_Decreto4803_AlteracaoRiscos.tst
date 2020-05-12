PL/SQL Developer Test script 3.0
166
DECLARE

  CURSOR cr_decreto(pr_cdcooper  crapcop.cdcooper%TYPE) IS
    SELECT p.cdcooper cdcooper
          ,p.nrdconta nrdconta
          ,p.nrctremp nrctremp
          ,p.cdfinemp cdfinemp
          ,p.cdlcremp cdlcremp
          ,decode(w.dsnivris, ' ', 'A', w.dsnivris) dsnivris
          ,decode(w.dsnivori, ' ', 'A', w.dsnivori) dsnivori
          ,risc0004.fn_traduz_risco(o.inrisco_inclusao) dsopinc
          ,risc0004.fn_traduz_risco(o.inrisco_rating) dsoprat
          ,MAX(risc0004.fn_traduz_risco(DECODE(r.innivris, 1, 2, 10, 9, r.innivris))) dsriscofinal -- AA para A e HH para H
          ,risc0004.fn_traduz_nivel_risco(decode(w.dsnivris, ' ', 'A', w.dsnivris)) innivris
          ,risc0004.fn_traduz_nivel_risco(decode(w.dsnivori, ' ', 'A', w.dsnivori)) innivori
          ,o.inrisco_inclusao inopinc
          ,o.inrisco_rating inoprat
          ,MAX(DECODE(r.innivris, 1, 2, 10, 9, r.innivris)) inriscofinal -- AA para A e HH para H
          ,(SELECT MAX(rq.qtdiaatr)
              FROM crapris rq
             WHERE rq.cdcooper = p.cdcooper
               AND rq.nrdconta = p.nrdconta
               AND rq.cdmodali IN (299,499)
               AND rq.dtrefere = '29/02/2020') qtdiaatr
          ,w.flgreneg
          ,decode(w.dsnivris, ' ', 'Sem Risco Inc', 'OK') verificacao
          -- campos para rollback
          ,w.dsnivris             rbdsnivris
          ,w.dsnivori             rbdsnivori
          ,w.progress_recid       rbprogress_recid
          ,o.inrisco_inclusao     rbriscoinc
          ,o.inrisco_rating       rbriscorat
          ,o.inorigem_rating      rbriscoori
          ,o.innivel_rating       rbnivelrat
          ,o.inpontos_rating      rbpontorat
          ,o.insegmento_rating    rbsegmento
          -- campos para rollback
      FROM crapepr p
          ,crawepr w
          ,crapris r
          ,tbrisco_operacoes o
     WHERE r.cdcooper = p.cdcooper
       AND r.nrdconta = p.nrdconta
       AND r.nrctremp = p.nrctremp
       AND w.cdcooper = p.cdcooper
       AND w.nrdconta = p.nrdconta
       AND w.nrctremp = p.nrctremp
       AND o.cdcooper = p.cdcooper
       AND o.nrdconta = p.nrdconta
       AND o.nrctremp = p.nrctremp
       AND NVL(o.inorigem_rating,0) <> 8 -- Decreto operações já atualizadas
       AND qtdiaatr < 15                 -- Menos de 15 dias em atraso no dia 29/02
       AND o.tpctrato = 90               -- Tipo Empréstimo
       AND r.dtrefere = '29/02/2020'     -- Operacao deve ter no dia 29/02 operacoes 
       AND r.cdmodali IN (299, 499)      -- Operacao deve ter no dia 29/02 operacoes de empréstimos
       AND p.dtmvtolt >= '01/03/2020'    -- Data Efetivação
       AND p.inliquid = 0                -- Apenas contratos não liquidados
       AND p.cdcooper = pr_cdcooper      -- Cooperativa
    GROUP BY p.cdcooper
            ,p.nrdconta
            ,p.nrctremp
            ,p.cdfinemp
            ,p.cdlcremp
            ,w.dsnivris
            ,w.dsnivori
            ,o.inrisco_inclusao
            ,o.inrisco_rating
            ,w.flgreneg
            ,w.progress_recid
            ,o.inorigem_rating
            ,o.innivel_rating
            ,o.inpontos_rating
            ,o.insegmento_rating
            HAVING MAX(DECODE(r.innivris, 1, 2, 10, 9, r.innivris)) < o.inrisco_rating;

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
    ORDER BY 1;

  vr_flrisco_decreto      NUMBER;
  vr_risco_atualizado     crapris.innivris%TYPE;
  vr_datafinal_atualizada DATE;
  vr_dsdireto             VARCHAR2(4000);
  vr_des_xml              CLOB;
  vr_texto_completo       VARCHAR2(32600);

  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_rollback(pr_des_dados IN VARCHAR2,
                                pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
  END;

BEGIN
  vr_dsdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas';

  -- Inicializar o CLOB
  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  vr_texto_completo := NULL;

  FOR rw_crapcop IN cr_crapcop LOOP
    FOR rw_decreto IN cr_decreto(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      IF rw_decreto.inoprat IS NOT NULL THEN
        risc0003.obterDecretoRiscos(pr_cdcooper             => rw_decreto.cdcooper,
                                    pr_nrdconta             => rw_decreto.nrdconta,
                                    pr_nrctremp             => rw_decreto.nrctremp,
                                    pr_tpctrato             => 90,
                                    pr_tiporisco            => 'RAT',
                                    pr_risco_atual          => rw_decreto.inoprat,
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

          pc_escreve_rollback('UPDATE tbrisco_operacoes o ' ||
                              'SET o.inrisco_inclusao  = ' || rw_decreto.rbriscoinc ||
                              ',o.inrisco_rating = ' || rw_decreto.rbriscorat ||
                              ',o.inorigem_rating = ' || rw_decreto.rbriscoori ||
                              ',o.innivel_rating = ' || rw_decreto.rbnivelrat ||
                              ',o.inpontos_rating = ' || rw_decreto.rbpontorat ||
                              ',o.insegmento_rating = ''' || rw_decreto.rbsegmento || '''' ||
                              'WHERE o.cdcooper = ' || rw_decreto.cdcooper ||
                              'AND o.nrdconta = ' || rw_decreto.nrdconta ||
                              'AND o.nrctremp = ' || rw_decreto.nrctremp ||
                              'AND o.tpctrato = 90;'||chr(10));
          -- crawepr
          UPDATE crawepr w
             SET w.dsnivris = risc0004.fn_traduz_risco(vr_risco_atualizado)
                ,w.dsnivori = risc0004.fn_traduz_risco(vr_risco_atualizado)
           WHERE w.cdcooper = rw_decreto.cdcooper
             AND w.nrdconta = rw_decreto.nrdconta
             AND w.nrctremp = rw_decreto.nrctremp;

          pc_escreve_rollback('UPDATE crawepr w SET w.dsnivris = '''|| rw_decreto.rbdsnivris ||''', w.dsnivori = '''|| rw_decreto.rbdsnivori ||''' WHERE w.progress_recid = '|| rw_decreto.rbprogress_recid ||';'||chr(10));

        END IF;
      END IF;
    END LOOP;
    COMMIT;
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
vr_dsdireto
vr_piorrisco
pr_risco_atual
pr_nrdconta
