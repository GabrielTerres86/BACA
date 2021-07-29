 
begin

  INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) VALUES('HISTOR_SALVA_EMPRESA', 'TELA_HISTOR', 'pc_salva_empresa', 
         'pr_dsvlrprm,pr_cdcooper', 1884);


  INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) VALUES('HISTOR_SALVA_CENTROCUSTO', 'TELA_HISTOR', 'pc_salva_centrocusto', 
         'pr_agenci,pr_nrctrcusto', 1884);

  INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) VALUES('HISTOR_CONSULTA_AGENCIAS', 'TELA_HISTOR', 'pc_consulta_agencias', 
         null, 1884);
         

  INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) VALUES('HISTOR_CONSULTA_EMPRESA', 'TELA_HISTOR', 'pc_consulta_empresa', 
         null, 1884);
         
         
  INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) VALUES('HISTOR_CONSULTA_TRANSACOES_CDT', 'TELA_HISTOR', 'pc_consulta_transacoes_conductor', 
         null, 1884);
       commit
         
  INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) VALUES('HISTOR_SALVA_TRANSACAO_CDT', 'TELA_HISTOR', 'pc_salva_transacao_conductor', 
         'pr_cdtransacao,pr_dstransacao,pr_nrdctadeb,pr_nrdctacred,pr_flgerdeb,pr_flgercred,pr_operacao', 1884);
    commit;       

  INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) VALUES('HISTOR_EXCLUI_TRANSACAO_CDT', 'TELA_HISTOR', 'pc_exclui_transacao_conductor', 
         'pr_cdtransacao', 1884);
         
  commit;
end;                               
