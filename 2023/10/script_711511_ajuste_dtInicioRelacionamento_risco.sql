DECLARE

  TYPE typ_reg_cooperado IS RECORD(
       idcooperativa creditogestao.tb_cooperado_conta.idcooperativa%TYPE,
       nrconta creditogestao.tb_cooperado_conta.nrconta%TYPE,
       dtinicio_relacionamento creditogestao.tb_cooperado_conta.dtinicio_relacionamento%TYPE,
       dtadmiss creditogestao.tb_cooperado_conta.dtinicio_relacionamento%TYPE);
  TYPE typ_tab_coop IS TABLE OF typ_reg_cooperado INDEX BY PLS_INTEGER;
  
  vr_tab_coop typ_tab_coop;
  vr_qtregistro number(10) := 0;
             
BEGIN

  vr_tab_coop.delete;

             SELECT idcooperativa,
                    nrconta,
                    dtinicio_relacionamento,
                    dtadmiss
  BULK COLLECT INTO vr_tab_coop 
               FROM (SELECT a.idcooperativa,
                            a.nrconta,
                            a.dtinicio_relacionamento,
                            c.dtadmiss
                       FROM creditogestao.tb_cooperado_conta a,
                            cecred.craptco@aillosb1 b,
                            cecred.crapass@aillosb1 c
                      WHERE a.idcooperativa = b.cdcooper
                        AND a.nrconta = b.nrdconta 
                        AND b.cdcopant = c.cdcooper
                        AND b.nrctaant = c.nrdconta  
                        AND b.cdcooper IN (1, 9, 13, 16));

   IF NVL(vr_tab_coop.count,0) > 0 THEN 
      FOR i IN vr_tab_coop.first .. vr_tab_coop.last
      LOOP
        vr_qtregistro := vr_qtregistro + 1;

        UPDATE creditogestao.tb_cooperado_conta a
           SET a.dtinicio_relacionamento = NVL(vr_tab_coop(i).dtadmiss, a.dtinicio_relacionamento)
         WHERE a.idcooperativa = vr_tab_coop(i).idcooperativa
           AND a.nrconta = vr_tab_coop(i).nrconta;

        IF MOD(vr_qtregistro,100) = 0 THEN
          COMMIT;
        END IF; 
      END LOOP;  
   END IF;
  
   COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20001,'Erro ao atualizar dtinicio_relacionamento',true);
END;
