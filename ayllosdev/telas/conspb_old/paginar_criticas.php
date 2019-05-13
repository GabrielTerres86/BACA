<?php
	/*!
	 * FONTE        : paginar_criticas.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 02/06/2016
	 * OBJETIVO     : Rotina para paginar as criticas da conciliacao
	 * --------------
	 * ALTERAÇÕES   : 
	 * -------------- 
	 */		
	 
	session_cache_limiter("private");
	session_start();

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"P")) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Ler parametros passados via POST
	$nmarquiv = (isset($_POST['nmarquiv']))  ? $_POST['nmarquiv']  : '';
	$nrinicri = (isset($_POST['nrinicri']))  ? $_POST['nrinicri']  :  1;
	$nrqtdcri = (isset($_POST['nrqtdcri']))  ? $_POST['nrqtdcri']  : 50;
	
	if ( $nmarquiv == "" ) {
		exibirErro('error','Arquivo n&atilde;o informado.','Alerta - Ayllos','focaCampoErro(\'nmarquiv\',\'frmCab\');',false);
	}
	
	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "		<nmarquiv>".$nmarquiv."</nmarquiv>";
	$xml .= "		<nrinicri>".$nrinicri."</nrinicri>";
	$xml .= "		<nrqtdcri>".$nrqtdcri."</nrqtdcri>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CONSPB", "CONSPB_PAGINAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nmarquiv";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input,select\',\'#frmCab\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmCab\');',false);
	}		
	
	// Verifica mensagem de retorno
 	if ($xmlObjeto->roottag->tags[0]->name == "CRITICAS") {

		echo "aCriticas = Array();";
		
		foreach($xmlObjeto->roottag->tags[0]->tags as $critica){
			$command = "var objCritica = new Object();" .
					   "objCritica.nrdlinha = '" . getByTagName($critica->tags,'nrdlinha') . "';" .
					   "objCritica.cdtiperr = '" . getByTagName($critica->tags,'cdtiperr') . "';" .
					   "objCritica.cddotipo = '" . getByTagName($critica->tags,'cddotipo') . "';" .
					   "objCritica.nrcontro = '" . getByTagName($critica->tags,'nrcontro') . "';" .
					   "objCritica.nrctrlif = '" . getByTagName($critica->tags,'nrctrlif') . "';" .
					   "objCritica.vlconcil = '" . getByTagName($critica->tags,'vlconcil') . "';" .
					   "objCritica.dtmensag = '" . getByTagName($critica->tags,'dtmensag') . "';" .
					   "objCritica.dsdahora = '" . getByTagName($critica->tags,'dsdahora') . "';" .
					   "objCritica.dscritic = '" . getByTagName($critica->tags,'dscritic') . "';" .
					   "objCritica.dsorigem = '" . getByTagName($critica->tags,'dsorigem') . "';" .
					   "objCritica.dsorigemerro = '" . getByTagName($critica->tags,'dsorigemerro') . "';" .
					   "objCritica.dsespeci = '" . getByTagName($critica->tags,'dsespeci') . "';" .
					   
					   "objCritica.cddbanco_deb = '" . getByTagName($critica->tags,'cddbanco_deb') . "';" .
					   "objCritica.cdagenci_deb = '" . getByTagName($critica->tags,'cdagenci_deb') . "';" .
					   "objCritica.nrdconta_deb = '" . getByTagName($critica->tags,'nrdconta_deb') . "';" .
					   "objCritica.nrcpfcgc_deb = '" . getByTagName($critica->tags,'nrcpfcgc_deb') . "';" .
					   "objCritica.nmcooper_deb = '" . getByTagName($critica->tags,'nmcooper_deb') . "';" .
					   "objCritica.cddbanco_cre = '" . getByTagName($critica->tags,'cddbanco_cre') . "';" .
					   "objCritica.cdagenci_cre = '" . getByTagName($critica->tags,'cdagenci_cre') . "';" .
					   "objCritica.nrdconta_cre = '" . getByTagName($critica->tags,'nrdconta_cre') . "';" .
					   "objCritica.nrcpfcgc_cre = '" . getByTagName($critica->tags,'nrcpfcgc_cre') . "';" .
					   "objCritica.nmcooper_cre = '" . getByTagName($critica->tags,'nmcooper_cre') . "';" .
					   
					   "adicionaCritica(objCritica);";
			echo $command;
		}
		
		echo "mostrarCriticas();";

	}
?>