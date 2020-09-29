PL/SQL Developer Test script 3.0
109
-- Created on 25/09/2020 by T0032500 
declare 
  -- Local variables here
  i integer;
  
  -- CURSOR GENÉRICO DE CALENDÁRIO
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  CURSOR cr_crapcop  IS
        SELECT crapcop.cdcooper
              ,crapcop.nmrescop
              ,crapcop.cdagesic
          FROM crapcop
          WHERE crapcop.cdcooper <> 3;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Cursor de lançamentos automáticos
  CURSOR cr_crapatr (pr_cdcooper IN crapatr.cdcooper%TYPE) IS
        SELECT crapatr.*
        FROM   crapatr, crapass
        WHERE crapass.cdcooper = crapatr.cdcooper
          AND crapass.nrdconta = crapatr.nrdconta
          AND crapatr.cdcooper = pr_cdcooper
          AND crapatr.dtfimatr = '25/09/2020'  -- 25/09/2020
          AND crapatr.cdopeexc = '1'
          AND crapatr.cdhistor = 1019
          AND ((crapatr.dtultdeb is not null  
          AND trunc(months_between(sysdate,crapatr.dtultdeb)) <= 3) 
           OR (crapatr.dtultdeb is null
          AND trunc(months_between(sysdate,crapatr.dtiniatr)) <= 3));	
  rw_crapatr cr_crapatr%ROWTYPE;


  CURSOR cr_tbconv_arrecadacao (pr_cdempcon  IN tbconv_arrecadacao.cdempcon%TYPE,
                                pr_cdsegmto  IN tbconv_arrecadacao.cdsegmto%TYPE) IS
       SELECT tbconv_arrecadacao.cdempres
         FROM tbconv_arrecadacao
        WHERE tbconv_arrecadacao.cdempcon = pr_cdempcon
          AND tbconv_arrecadacao.cdsegmto = pr_cdsegmto;
  rw_tbconv_arrecadacao cr_tbconv_arrecadacao%ROWTYPE;

  
  -- VARIAVEIS DE EXCECAO
  vr_exc_erro EXCEPTION;  
  
begin
  -- Test statements here
    OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
         FETCH btch0001.cr_crapdat
         INTO rw_crapdat;
    -- SE NÃO ENCONTRAR
    IF btch0001.cr_crapdat%NOTFOUND THEN
        -- FECHAR O CURSOR POIS EFETUAREMOS RAISE
       CLOSE btch0001.cr_crapdat;
       -- MONTAR MENSAGEM DE CRITICA
        RAISE vr_exc_erro;
    ELSE
       -- APENAS FECHAR O CURSOR
       CLOSE btch0001.cr_crapdat;
    END IF;
               
    FOR rw_crapcop IN cr_crapcop LOOP
   
       dbms_output.put_line('Criando na coop: -> '||rw_crapcop.cdcooper);  
      
          FOR rw_crapatr IN cr_crapatr ( pr_cdcooper => rw_crapcop.cdcooper) LOOP

              OPEN cr_tbconv_arrecadacao(rw_crapatr.cdempcon, rw_crapatr.cdsegmto);
               
              FETCH cr_tbconv_arrecadacao INTO rw_tbconv_arrecadacao;
               
              IF cr_tbconv_arrecadacao%FOUND THEN
            
                BEGIN

                    INSERT INTO crapatr (NRDCONTA, CDHISTOR, DTINIATR, DTFIMATR, DTULTDEB, DDVENCTO, NMFATURA, CDDDDTEL, CDSEQTEL, 
                                         CDREFERE, CDCOOPER, NMEMPRES, CDBARRAS, CDEMPCON, CDSEGMTO, CDEMPRES, VLRMAXDB, FLGMAXDB, 
				                              	 DSHISEXT, TPAUTORI, DTINISUS, DTFIMSUS, INASSELE, CDOPEORI, CDAGEORI, DTINSORI, CDOPEEXC, 
					                               CDAGEEXC, DTINSEXC)
                    VALUES (rw_crapatr.nrdconta, 3292, to_date('29-09-2020', 'dd-mm-yyyy'), null, null, rw_crapatr.ddvencto, rw_crapatr.nmfatura, rw_crapatr.cddddtel, rw_crapatr.cdseqtel, 
                            rw_crapatr.cdrefere, rw_crapatr.cdcooper, rw_crapatr.nmempres, rw_crapatr.cdbarras, rw_crapatr.cdempcon, rw_crapatr.cdsegmto, rw_tbconv_arrecadacao.cdempres, rw_crapatr.vlrmaxdb, rw_crapatr.flgmaxdb, 
                            rw_crapatr.dshisext, rw_crapatr.tpautori, rw_crapatr.dtinisus, rw_crapatr.dtfimsus, rw_crapatr.inassele, rw_crapatr.cdopeori, rw_crapatr.cdageori, rw_crapatr.dtinsori, '1', 
                            rw_crapatr.cdageexc, rw_crapatr.dtinsexc);

                 EXCEPTION
                   WHEN others THEN
                        dbms_output.put_line('Nao foi possivel criar o ATR : '||rw_crapcop.cdcooper||'->'||rw_crapatr.nrdconta||'->'||SQLERRM);
                        RAISE vr_exc_erro;
                 END;

              END IF;
              
              CLOSE cr_tbconv_arrecadacao;
              
           END LOOP;   

      commit; 

      END LOOP; -- Crapcop

    EXCEPTION

      WHEN vr_exc_erro THEN
        dbms_output.put_line('Erro na execução : vr_exc_erro '||SQLERRM);
        rollback;
      WHEN OTHERS THEN
        dbms_output.put_line('Erro na execução : '||SQLERRM);
        rollback;
end;
0
0
