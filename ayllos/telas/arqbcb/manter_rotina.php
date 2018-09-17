<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Lucas Lunelli         
 * DATA CRIAÇÃO : 13/03/2014 
 * OBJETIVO     : Rotina para manter as operações da tela ARQBCB
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
	
	
	
	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	set_time_limit(900);
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cddarqui		= (isset($_POST['cddarqui'])) ? $_POST['cddarqui'] : ''  ; 

	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'E': 
			if ($cddarqui == 'A'){
				$cdprogra = 'CRPS669';
			} else if ($cddarqui == 'C'){
				$cdprogra = 'CRPS671';
			}			
		break;
		
		case 'R':
			if ($cddarqui == 'D'){
				$cdprogra = 'CRPS670';
			}
		break;
	}
	
	$retornoAposErro = 'focaCampoErro(\'cddarqui\', \'frmBcb\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
		
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= " </Dados>";
	$xml .= "</Root>";	
		
	$xmlResult = mensageria($xml, "ARQBCB", $cdprogra, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");        
	
	$xmlObj = getObjectXML($xmlResult);
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
		
	if(strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){		
		$msgErro = str_replace(PHP_EOL, ' ', $xmlObj->roottag->tags[0]->cdata);		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
		exit();
	} else {		
		if($cddopcao == "E"){
			echo 'showError("inform","Arquivo para envio gerado com sucesso.","Alerta - Ayllos","btnVoltar();");';
		} else {
			echo 'showError("inform","Arquivo recebido com sucesso.","Alerta - Ayllos","btnVoltar();");';
		}		
	}
?>
