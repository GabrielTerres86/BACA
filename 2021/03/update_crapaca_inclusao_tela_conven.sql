/*
  Update para alteração de parâmetro na tabela CRAPACA.
*/
UPDATE crapaca SET lstparam = 'pr_cddopcao,pr_tparrecd,pr_cdconven,pr_nmfantasia,pr_rzsocial,pr_cdhistor,pr_codfebraban,pr_cdsegmento,pr_vltarint,pr_vltartaa,pr_vltarcxa,pr_vltardeb,pr_vltarcor,pr_vltararq,pr_nrrenorm,pr_nrtolera,pr_dsdianor,pr_dtcancel,pr_layout_arrecadacao,pr_flgaccec,pr_flgacsic,pr_flgacbcb,pr_forma_arrecadacao,pr_nrlayout_debaut,pr_tam_optante,pr_cdmodalidade,pr_dsdsigla,pr_nrseqint,pr_nrseqatu,pr_canaisli'
WHERE nmdeacao = 'PC_GRAVA_CONV_PARCEIROS';

COMMIT;
