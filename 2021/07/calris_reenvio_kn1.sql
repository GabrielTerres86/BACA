DECLARE

  CURSOR c01 IS
    SELECT b.idcalris_tanque, a.idcalris_pessoa
      FROM tbcalris_pessoa a, tbcalris_tanque b
     WHERE a.cdclasrisco_final > 2
       AND trunc(a.dhcalculofinal) > '04/06/2021'
       AND a.cdstatus = 1
       AND a.cdclasrisco_kn1 is not null
       AND b.nrcpfcgc = a.nrcpfcgc
       AND b.tpcalculadora = a.tpcalculadora
       AND NOT EXISTS
     (SELECT 1
              FROM tbgen_req_webservice x
             WHERE x.dhrequis between a.dhcalculofinal - (1 / 24 / 60) AND
                   a.dhcalculofinal + (1 / 24 / 60)
               AND upper(x.dsservico) =
                   'HTTP://EGUARDIAN.CECRED.COOP.BR/WSINTEGRACAORISC/WSINTEGRACAORISC.ASMX?OP=WSREQUISICAOINICIALKN1'
               AND x.dsconteudo_requis like '%' || a.nrcpfcgc || '%');

BEGIN

  for r01 in c01 loop
  
    UPDATE tbcalris_tanque
       SET cdstatus = 7
     WHERE idcalris_tanque = r01.idcalris_tanque;
  
    UPDATE tbcalris_pessoa
       SET dhkn1 = null, cdclasrisco_kn1 = null
     WHERE idcalris_pessoa = r01.idcalris_pessoa;
  end loop;

  commit;

END;
/
