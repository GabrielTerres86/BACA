<? 
/*!
 * FONTE        : dossie.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 24/03/2017
 * OBJETIVO     : Rotina responsável por chamar view externa do digidoc com a 
 *				  respectiva chave de acesso.
   ALTERAÇÕES   : 25/07/2019 - Alteração para novo viewer do Smartshare (PRB0041878 - Joao Mannes - Mouts) 
 */  
?>
 
<?	
    session_start();
	require_once('../includes/config.php');
	require_once('../includes/funcoes.php');
	require_once('../includes/controla_secao.php');
	require_once('../class/xmlfile.php');
	isPostMethod();		
	
	// Verifica parâmetros necessários
	if ( !isset($_POST['nrdconta']) || 
	     !isset($_POST['cdproduto']) ||
		 !isset($_POST['nmdatela'])) exibirErro('error','Par&acirc;metros incorretos!','Alerta - Ayllos','bloqueiaFundo(divRotina)');
	
	// Guardo os parâmetos do POST em variáveis
	$nrdconta  = (isset($_POST['nrdconta']))  ? $_POST['nrdconta'] : '' ;
	$cdproduto = (isset($_POST['cdproduto'])) ? $_POST['cdproduto'] : '' ;
	$nmdatela  = (isset($_POST['nmdatela'])) ? $_POST['nmdatela'] : '' ;
	
	$xmlimpres = new XmlMensageria();
	$xmlimpres->add('nrdconta',$nrdconta)
			  ->add('cdproduto',$cdproduto)
			  ->add('nmdatela_log',$nmdatela); 

	$xmlResult = mensageria($xmlimpres, "DIGI0001", "ACESSA_DOSSIE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	   $xmlObj = getObjectXML($xmlResult);	
	   
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msg = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		exibirErro('error',$msg,'Alerta - Ayllos','bloqueiaFundo(divRotina)');
		exit();
	}
	$key = $xmlObj->roottag->tags[0]->tags[0]->cdata;
	$inpessoa = $xmlObj->roottag->tags[0]->tags[1]->cdata;
	$nrcpfcgc = $xmlObj->roottag->tags[0]->tags[2]->cdata;
	if ($inpessoa == 1 && $cdproduto == 8) {
		echo 'window.open("http://'.$GEDServidor.'/smartshare/Clientes/ViewerExterno.aspx?pkey='.$key.'&CPF='.$nrcpfcgc.'","_blank");';
	} else {
	echo 'window.open("http://'.$GEDServidor.'/smartshare/Clientes/ViewerExterno.aspx?pkey='.$key.'&conta='.formataNumericos("zzzz.zzz.9",$nrdconta,".-").'&cooperativa='.$glbvars["cdcooper"].'","_blank");';
	}
?>