begin

update cecred.crapaca set LSTPARAM = 'pr_cddopcao,pr_cdcooper,pr_hrsicatu,pr_hrsicini,pr_hrsicfim,pr_hrbanatu,pr_hrbanini,pr_hrbanfim,pr_hrrfbatu,pr_hrrfbini,pr_hrrfbfim,pr_hrtitatu,pr_hrtitini,pr_hrtitfim,pr_hrnetatu,pr_hrnetini,pr_hrnetfim,pr_hrtaaatu,pr_hrtaaini,pr_hrtaafim,pr_hrgpsatu,pr_hrgpsini,pr_hrgpsfim,pr_hrsiccau,pr_hrsiccan,pr_hrbancau,pr_hrbancan,pr_hrrfbcau,pr_hrrfbcan,pr_hrtitcau,pr_hrtitcan,pr_hrnetcau,pr_hrnetcan,pr_hrtaacau,pr_hrtaacan,pr_hrdiuatu,pr_hrdiuini,pr_hrdiufim,pr_hrnotatu,pr_hrnotini,pr_hrnotfim, pr_hrlimreprocess, pr_limite' where NMDEACAO = 'ALTERA_HORARIO_PARHPG';

commit;

end;