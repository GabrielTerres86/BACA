begin
  update crapaca a
     set a.lstparam = 'pr_idmovto_risco,pr_cdcopsel,pr_dtrefere,pr_idproduto,pr_nrdconta,pr_nrcpfcgc,pr_nrctremp,pr_idgarantia,pr_idorigem_recurso,pr_idindexador,pr_perindexador,pr_vltaxa_juros,pr_dtlib_operacao,pr_vloperacao,pr_idnat_operacao,pr_dtvenc_operacao,pr_cdclassifica_operacao,pr_qtdparcelas,pr_vlparcela,pr_dtproxima_parcela,pr_vlsaldo_pendente,pr_flsaida_operacao,pr_cddopcao'
   where a.nrseqaca = 1563 and a.nmdeacao = 'ALTERARMVTO' and a.nmpackag = 'TELA_MOVRGP';
  --
  update crapaca a
     set a.lstparam = 'pr_cdcopsel,pr_dtrefere,pr_idproduto,pr_nrdconta,pr_nrcpfcgc,pr_nrctremp,pr_idgarantia,pr_idorigem_recurso,pr_idindexador,pr_perindexador,pr_vltaxa_juros,pr_dtlib_operacao,pr_vloperacao,pr_idnat_operacao,pr_dtvenc_operacao,pr_cdclassifica_operacao,pr_qtdparcelas,pr_vlparcela,pr_dtproxima_parcela,pr_vlsaldo_pendente,pr_flsaida_operacao,pr_cddopcao'
   where a.nrseqaca = 1564 and a.nmdeacao = 'INCLUIRMOVTO' and a.nmpackag = 'TELA_MOVRGP';
  --
  commit;
end;
