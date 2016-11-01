<script type="text/php">
	if ( isset($pdf) ) {
		// Insere Rodapé
		$font  = Font_Metrics::get_font("verdana");;
		$size  = 6;
		$color = array(0,0,0);
		$text_height = Font_Metrics::get_font_height($font, $size);

		$foot = $pdf->open_object();

		$w = $pdf->get_width();
		$h = $pdf->get_height();

		$y = $h - $text_height-10;
		$pdf->line(16, $y, $w - 16, $y, $color, 0.5);

		$pdf->close_object();
		$pdf->add_object($foot, "all");

		$text = "Page {PAGE_NUM} of {PAGE_COUNT}";  

		// Center the text
		$width = Font_Metrics::get_text_width("Page 1 of 2", $font, $size);
		$pdf->page_text($w / 2 - $width / 2, $y, $text, $font, $size, $color);
	}
</script>