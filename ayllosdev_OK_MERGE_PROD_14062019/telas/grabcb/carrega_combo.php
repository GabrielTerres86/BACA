<? 
/*!
 * FONTE        : carrega_combo.php
 * CRIAÇÃO      : Jean Michel       
 * DATA CRIAÇÃO : 13/05/2014 
 * OBJETIVO     : Rotina para carregar informações do combo de administradoras da tela GRABCB
 * PROJETO		: Projeto de Novos Cartões Bancoob
 * --------------
 * ALTERAÇÕES   : 04/08/2014 - Adicionado parametro de Cod. Cooperativa (Lunelli)
 * -------------- 
 */	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$cdcopaux = !isset($_POST["cdcopaux"]) || is_null($_POST["cdcopaux"]) || $_POST["cdcopaux"] == '' ? 0 : $_POST["cdcopaux"];
		
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdadmcrd>0</cdadmcrd>";
	$xml .= "   <cdcopaux>".$cdcopaux."</cdcopaux>";
	$xml .= " </Dados>";
	$xml .= "</Root>";	
	
	$xmlResult = mensageria($xml, "GRABCB", "CARADM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		exit();
	}else{			
		$registros = $xmlObj->roottag->tags;				
		echo "$('#slcadmin','#frmCab').empty();";		
		foreach($registros as $registro) {
			echo "$('#slcadmin','#frmCab').append($('<option>').attr('value',".str_replace(PHP_EOL, '', $registro->tags[0]->cdata).").text('".$registro->tags[1]->cdata ."'));";
		}					
	}
?>