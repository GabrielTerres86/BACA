<?php
/*!
 * FONTE        : download.php
 * CRIA��O      : Tiago Machado         
 * DATA CRIA��O : 08/09/2016
 * OBJETIVO     : realizar o download do arquivo
 * --------------
 * ALTERA��ES   : 
 * --------------
 */
 ?>
<?    
	$file = '/var/www/ayllos/documentos/cecred/temp/CNAES_BLOQ.txt';
	
	if (file_exists($file)) {
		
		$nmarquiv = 'CNAES_BLOQ.txt';
		
		$fp = fopen($file,"r");
		$strPDF = fread($fp,filesize($file));
		fclose($fp);

	//	unlink($file); 
		
		header('Content-Type: application/x-download'); 
		header('Content-disposition: attachment; filename="'.$nmarquiv.'"'); 
		header("Expires: 0"); 
		header("Cache-Control: no-cache");
		header('Cache-Control: private, max-age=0, must-revalidate');
		header("Pragma: public");
 
		echo $strPDF;

	}

?>