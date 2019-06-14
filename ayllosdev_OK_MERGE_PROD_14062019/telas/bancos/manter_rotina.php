<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jéssica (DB1)      
 * DATA CRIAÇAO : 27/07/2015
 * OBJETIVO     : Rotina para alteração e inserção cadastral da tela BANCOS
 * --------------
 * ALTERAÇÕES   : Alterado layout e incluido novos campos: flgoppag, dtaltstr e dtaltpag. 
 *                PRJ-312 (Reinert)
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

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$cdbccxlt = (isset($_POST["cdbccxlt"])) ? $_POST["cdbccxlt"] : 0;
	$nrispbif = (isset($_POST["nrispbif"])) ? $_POST["nrispbif"] : 0;
	$nmresbcc = (isset($_POST["nmresbcc"])) ? $_POST["nmresbcc"] : '';
	$nmextbcc = (isset($_POST["nmextbcc"])) ? $_POST["nmextbcc"] : '';
	$flgdispb = (isset($_POST["flgdispb"])) ? $_POST["flgdispb"] : '';
	$dtinispb = (isset($_POST["dtinispb"])) ? $_POST["dtinispb"] : '';
	$flgoppag = (isset($_POST["flgoppag"])) ? $_POST["flgoppag"] : '';
	$nrcnpjif = (isset($_POST["nrcnpjif"])) ? $_POST["nrcnpjif"] : 0;
		
	$xmlBanco  = "";
	$xmlBanco .= "<Root>";
	$xmlBanco .= " <Dados>";
	$xmlBanco .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlBanco .= "	<cdbccxlt>".$cdbccxlt."</cdbccxlt>";
	$xmlBanco .= "  	<nrispbif>".$nrispbif."</nrispbif>";
	$xmlBanco .= "  	<cddopcao>".$cddopcao."</cddopcao>";
	$xmlBanco .= "  	<nmresbcc>".$nmresbcc."</nmresbcc>";
	$xmlBanco .= "  	<nmextbcc>".$nmextbcc."</nmextbcc>";
	$xmlBanco .= "  	<flgdispb>".$flgdispb."</flgdispb>";
	$xmlBanco .= "  	<dtinispb>".$dtinispb."</dtinispb>";
	$xmlBanco .= "  	<flgoppag>".$flgoppag."</flgoppag>";
	$xmlBanco .= "  	<nrcnpjif>".$nrcnpjif."</nrcnpjif>";
	$xmlBanco .= " </Dados>";
	$xmlBanco .= "</Root>";

	// Executa script para envio do XML	
	if($cddopcao == 'A'){
		$xmlResult = mensageria($xmlBanco, "BANCOS", "ALTERABANCO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	}else if($cddopcao == 'I'){
		$xmlResult = mensageria($xmlBanco, "BANCOS", "INCLUIBANCO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	}else if($cddopcao == 'M'){
		$xmlResult = mensageria($xmlBanco, "BANCOS", "ALTERACNPJBANCO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	}else{
		exibirErro('error','Op&ccedil;&atilde;o inv&aacute;lida.','Alerta - Ayllos','$(\'#nmresbcc\',\'#frmConsulta\').addClass(\'campoErro\').habilitaCampo().focus(); $(\'#frmConsulta\').css(\'display\',\'block\'); $(\'#btSalvar\',\'#divBotoes\').show(); $(\'#btVoltar\',\'#divBotoes\').show();',false);
	}
	
	$xmlObjBanco = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjBanco->roottag->tags[0]->name) == 'ERRO') {
		
		$campo = $xmlObjBanco->roottag->tags[0]->attributes['NMDCAMPO'];			
								
		if($campo != '' and ($campo != 'nmresbcc' and $campo != 'nmextbcc' and $campo != 'dtinispb' and $campo != 'flgdispb' and $campo != 'flgoppag')){ 
			$retornoAposErro .= '$(\'#'.$campo.'\',\'#frmEntrada\').addClass(\'campoErro\'); btnVoltar();';
		}else {
			$retornoAposErro .= '$(\'#nmresbcc\',\'#frmConsulta\').addClass(\'campoErro\').habilitaCampo().focus(); $(\'#frmConsulta\').css(\'display\',\'block\'); $(\'#btSalvar\',\'#divBotoes\').show(); $(\'#btVoltar\',\'#divBotoes\').show();';
		}
		
		$msgErro  = utf8_encode($xmlObjBanco->roottag->tags[0]->tags[0]->tags[4]->cdata);
						
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
		
	}
	if($cddopcao == 'A' || $cddopcao == 'M'){
		exibirErro('inform','Registro alterado com sucesso.','Notifica&ccedil;&atilde;o - Ayllos','estadoInicial();',false);	
	}else{
		exibirErro('inform','Registro inclu&iacute;do com sucesso.','Notifica&ccedil;&atilde;o - Ayllos','estadoInicial();',false);
	}
	
?>
