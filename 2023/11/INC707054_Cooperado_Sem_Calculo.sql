DECLARE
  CURSOR c_colab (p_cpf_cgc NUMBER) IS
     SELECT cpa.nrcpfcgc,
            'N' tpcooperado,
            1 cdstatus,
            tcp.tpcadastro tpcalculadora,
            MIN(cpa.cdcooper) cdcooper
       FROM cecred.crapass cpa, 
            cecred.tbcadast_pessoa tcp 
      WHERE cpa.dtdemiss IS NULL
        AND cpa.nrcpfcgc = tcp.nrcpfcgc
        AND tcp.nrcpfcgc = p_cpf_cgc
        AND NOT EXISTS (SELECT 1
                          FROM tbcalris_tanque ttq
                         WHERE ttq.nrcpfcgc      = cpa.nrcpfcgc
                           AND ttq.tpcalculadora = 1)
   GROUP BY cpa.nrcpfcgc, 
            tcp.tpcadastro
   ORDER BY MIN(cpa.cdcooper);
  --
  v_colab_scalc VARCHAR2(4000);
  v_cpf_cnpj    VARCHAR2(14);
  --
BEGIN
   v_colab_scalc := '84846267920,44125534934,12344612777,9680508919,6534197910,2840403129,11675598940,92532080825,';
   --
   FOR vpos IN 1.. LENGTH(v_colab_scalc) LOOP
      --
      IF SUBSTR(v_colab_scalc, vpos, 1) <> ',' THEN
         v_cpf_cnpj := v_cpf_cnpj || SUBSTR(v_colab_scalc, vpos, 1);
      ELSE
         --
         -- Rotina para popular tanque
         --
         FOR ROWITEM IN c_colab(TO_NUMBER(TRIM(v_cpf_cnpj))) LOOP
            --
            INSERT INTO cecred.tbcalris_tanque
                 (nrcpfcgc, 
                  tpcooperado,
                  cdstatus,
                  dsobservacao,
                  tpcalculadora)
            VALUES
                 (ROWITEM.nrcpfcgc,
                  ROWITEM.tpcooperado,
                  ROWITEM.cdstatus,
                  'Registro populado pelo script CORRIGE_INCIDENTE_707054',
                  ROWITEM.tpcalculadora);
            --
         END LOOP;
         --
         v_cpf_cnpj := NULL;
         --
      END IF;
      --
   END LOOP;
   --
   COMMIT;
   --
END;