<? 
/*!
 * FONTE        : remove_lote.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 03/02/2012 
 * OBJETIVO     : Remove o protocolo da listagem
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$indice		= (!empty($_POST['indice']))	? $_POST['indice'] : 0 ;				
	$protocolo 	= (!empty($_POST['protocolo']))	? unserialize($_POST['protocolo']) : array() ;

	// Pega o total de protocolo 
	$total = count($protocolo) - 1;
	
	// Armazena os cheques em custodia/desconto
	for ( $i = $indice; $i < $total; $i++ ) {
		$protocolo[$i]['indrelat'] = $protocolo[$i+1]['indrelat'];
		$protocolo[$i]['dtmvtolt'] = $protocolo[$i+1]['dtmvtolt'];
		$protocolo[$i]['cdagenci'] = $protocolo[$i+1]['cdagenci'];
		$protocolo[$i]['nrdconta'] = $protocolo[$i+1]['nrdconta'];
		$protocolo[$i]['nrborder'] = $protocolo[$i+1]['nrborder'];
		$protocolo[$i]['nrdolote'] = $protocolo[$i+1]['nrdolote'];
		$protocolo[$i]['qtchqcop'] = $protocolo[$i+1]['qtchqcop'];
		$protocolo[$i]['qtchqmen'] = $protocolo[$i+1]['qtchqmen'];
		$protocolo[$i]['qtchqmai'] = $protocolo[$i+1]['qtchqmai'];
		$protocolo[$i]['qtchqtot'] = $protocolo[$i+1]['qtchqtot'];
		$protocolo[$i]['vlchqcop'] = $protocolo[$i+1]['vlchqcop'];
		$protocolo[$i]['vlchqmen'] = $protocolo[$i+1]['vlchqmen'];
		$protocolo[$i]['vlchqmai'] = $protocolo[$i+1]['vlchqmai'];
		$protocolo[$i]['vlchqtot'] = $protocolo[$i+1]['vlchqtot'];
		$protocolo[$i]['nmoperad'] = $protocolo[$i+1]['nmoperad'];
		$protocolo[$i]['dtlibera'] = $protocolo[$i+1]['dtlibera'];
		$protocolo[$i]['cdbccxlt'] = $protocolo[$i+1]['cdbccxlt'];
		$protocolo[$i]['qtcompln'] = $protocolo[$i+1]['qtcompln'];
		$protocolo[$i]['vlcompdb'] = $protocolo[$i+1]['vlcompdb'];
	}
	
	array_pop($protocolo);
	
	if ( count($protocolo) > 0 ) {
		echo "protocolo='".serialize($protocolo)."';";
	} else {
		echo "protocolo='';";
	}
		

?>