BEGIN
  --
  UPDATE crapaca aca
		 SET aca.lstparam = aca.lstparam || ', pr_tpemprst'
	 WHERE aca.nrseqaca = 3419;
  --
  COMMIT;
	--
END;
