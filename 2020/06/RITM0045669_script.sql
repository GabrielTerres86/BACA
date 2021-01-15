begin  
 
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Script da RITM0045669';
    begin
	
     UPDATE crapaca c SET 
	 c.LSTPARAM = 'pr_nrdconta, pr_nrcrcard, pr_nrcctitg, pr_nrcpftit, pr_cdadmcrd, pr_flgdebit, pr_nmtitcrd, pr_insitcrd, pr_insitdec, pr_flgprcrd, pr_nrctrcrd, pr_nmempres, pr_cdmotivo' 
	 WHERE c.nmpackag = 'TELA_MANCRD' 
	   AND upper(c.NMDEACAO) = UPPER('pc_atualiza_cartao');
	   
	 UPDATE tbcrd_situacao
	SET CDMOTIVO = 11
	WHERE CDSITADM = 11;

	UPDATE tbcrd_situacao
	SET CDSITCRD = 5, CDMOTIVO = 16
	WHERE CDSITADM = 16;
	
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;

