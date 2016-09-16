<? 
/*!
 * FONTE        : busca_dados_parametro.php
 * CRIAÇÃO      : Tiago          
 * DATA CRIAÇÃO : 24/07/2015 
 * OBJETIVO     : Rotina para inicializar variaveis de sistema para o js
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
	
	$cdcooper = $glbvars["cdcooper"];
	$dtmvtolt = $glbvars['dtmvtolt'];	
	
	echo "glbCdcooper = '$cdcooper';";
	echo "glbDtmvtolt = '$dtmvtolt';";
	
			
?>
