BEGIN
  
  UPDATE CRAPACA ACA 
     SET ACA.LSTPARAM = 'pr_cddopcao,pr_cdagenci,pr_nmextage,pr_nmresage,pr_insitage,pr_cdcxaage,pr_tpagenci,pr_cdccuage,pr_cdorgpag,pr_cdagecbn,pr_cdcomchq,pr_vercoban,pr_cdbantit,pr_cdagetit,pr_cdbanchq,pr_cdagechq,pr_cdbandoc,pr_cdagedoc,pr_flgdsede,pr_cdagepac,pr_flgutcrm,pr_dsendcop,pr_nrendere,pr_nmbairro,pr_dscomple,pr_nrcepend,pr_idcidade,pr_nmcidade,pr_cdufdcop,pr_dsdemail,pr_dsmailbd,pr_dsemailpj,pr_dsemailpf,pr_dsinform1,pr_dsinform2,pr_dsinform3,pr_hhsicini,pr_hhsicfim,pr_hhtitini,pr_hhtitfim,pr_hhcompel,pr_hhcapini,pr_hhcapfim,pr_hhdoctos,pr_hhtrfini,pr_hhtrffim,pr_hhguigps,pr_hhbolini,pr_hhbolfim,pr_hhenvelo,pr_hhcpaini,pr_hhcpafim,pr_hhlimcan,pr_hhsiccan,pr_nrtelvoz,pr_nrtelfax,pr_qtddaglf,pr_qtmesage,pr_qtddlslf,pr_flsgproc,pr_vllimapv,pr_qtchqprv,pr_flgdopgd,pr_cdageagr,pr_cddregio,pr_tpageins,pr_cdorgins,pr_vlminsgr,pr_vlmaxsgr,pr_flmajora,pr_cdagefgt,pr_cdagecai,pr_hhini_bancoob,pr_hhfim_bancoob,pr_hhcan_bancoob,pr_hhini_rfb,pr_hhfim_rfb,pr_vllimpag,pr_dtabertu,pr_dtfechto,pr_tpuniate'  
  WHERE ACA.NMPACKAG = 'TELA_CADPAC'
    AND ACA.NMDEACAO = 'CADPAC_GRAVA';
  
  UPDATE CRAPACA ACA 
     SET ACA.LSTPARAM = 'pr_cddopcao,pr_cdcooper,pr_hrsicatu,pr_hrsicini,pr_hrsicfim,pr_hrbanatu,pr_hrbanini,pr_hrbanfim,pr_hrrfbatu,pr_hrrfbini,pr_hrrfbfim,pr_hrtitatu,pr_hrtitini,pr_hrtitfim,pr_hrnetatu,pr_hrnetini,pr_hrnetfim,pr_hrtaaatu,pr_hrtaaini,pr_hrtaafim,pr_hrgpsatu,pr_hrgpsini,pr_hrgpsfim,pr_hrsiccau,pr_hrsiccan,pr_hrbancau,pr_hrbancan,pr_hrtitcau,pr_hrtitcan,pr_hrnetcau,pr_hrnetcan,pr_hrtaacau,pr_hrtaacan,pr_hrdiuatu,pr_hrdiuini,pr_hrdiufim,pr_hrnotatu,pr_hrnotini,pr_hrnotfim,pr_hrlimreprocess,pr_hrlimite'  
  WHERE ACA.NMPACKAG = 'TELA_PARHPG'
    AND ACA.NMDEACAO = 'ALTERA_HORARIO_PARHPG';

  COMMIT;
END;
