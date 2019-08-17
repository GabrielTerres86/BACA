  /*---------------------------------------------------------------------------------------------------------------------
    Programa    : JOB renovação automática LIMI0002
    Projeto     : 403 - Desconto de Títulos - Release 6
    Autor       : (Paulo Penteado GFT) 
    Data        : 01/02/2019
    Objetivo    : Realiza delete nos históricos de situação vigênte repetidos que foram gerados na rotina de renovação 
                  automática do contrato de limite quando o mesmo está vencido.                  
  ---------------------------------------------------------------------------------------------------------------------*/ 
BEGIN
  --dbms_output.put_line('idhistaltlim;cdcooper;nrdconta;tpctrlim;nrctrlim;dtinivig;dtfimvig;vllimite;insitlim;dhalteracao;dsmotivo;nrdlinha;acao'); 
  FOR rw_his IN (SELECT his.*
                       ,row_number() OVER(PARTITION BY his.cdcooper, his.nrdconta, his.nrctrlim ORDER BY his.cdcooper, his.nrdconta, his.nrctrlim) nrdlinha
                   FROM tbdsct_hist_alteracao_limite his
                  INNER JOIN crapcop cop ON cop.cdcooper = his.cdcooper
                  WHERE his.dsmotivo LIKE '%VIGÊNCIA%'
                    AND cop.flgativo = 1
                  ORDER BY his.cdcooper, his.nrdconta, his.nrctrlim, his.dhalteracao)
  LOOP
    IF rw_his.nrdlinha = 1 THEN
      /*dbms_output.put_line(rw_his.idhistaltlim||';'||rw_his.cdcooper||';'||rw_his.nrdconta||';'||rw_his.tpctrlim||';'||rw_his.nrctrlim||';'||
                           to_char(rw_his.dtinivig,'DD/MM/RRRR')||';'||to_char(rw_his.dtfimvig,'DD/MM/RRRR')||';'||
                           trim(to_char(rw_his.vllimite,'99999999D99','NLS_NUMERIC_CHARACTERS='',.'''))||';'||rw_his.insitlim||';'||
                           to_char(rw_his.dhalteracao,'DD/MM/RRRR')||';'||rw_his.dsmotivo||';'||rw_his.nrdlinha||';pular');*/
      CONTINUE;
    ELSE
      DELETE tbdsct_hist_alteracao_limite his
       WHERE his.idhistaltlim = rw_his.idhistaltlim;
      /*dbms_output.put_line(rw_his.idhistaltlim||';'||rw_his.cdcooper||';'||rw_his.nrdconta||';'||rw_his.tpctrlim||';'||rw_his.nrctrlim||';'||
                           to_char(rw_his.dtinivig,'DD/MM/RRRR')||';'||to_char(rw_his.dtfimvig,'DD/MM/RRRR')||';'||
                           trim(to_char(rw_his.vllimite,'99999999D99','NLS_NUMERIC_CHARACTERS='',.'''))||';'||rw_his.insitlim||';'||
                           to_char(rw_his.dhalteracao,'DD/MM/RRRR')||';'||rw_his.dsmotivo||';'||rw_his.nrdlinha||';deletar'); */
    END IF;
  END LOOP;
  COMMIT;
END;
