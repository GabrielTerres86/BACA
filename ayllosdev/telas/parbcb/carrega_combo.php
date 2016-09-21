<? 
/*!
 * FONTE        : carrega_combo.php
 * CRIAÇÃO      : Jean Michel       
 * DATA CRIAÇÃO : 13/05/2014 
 * OBJETIVO     : Rotina para carregar informações do combo da tela PARBCB
 * PROJETO		: Projeto de Novos Cartões Bancoob
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Inicializa
	$retornoAposErro= '';
	
	$retornoAposErro = 'focaCampoErro(\'cddopcao\', \'frmCab\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <tparquiv>0</tparquiv>";
	$xml .= " </Dados>";
	$xml .= "</Root>";	
	
	$xmlResult = mensageria($xml, "PARBCB", "TPARQI", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
		
		echo "$('#tparquiv','#frmCab').empty();";
		
		foreach($registros as $registro) {
			echo "$('#tparquiv','#frmCab').append($('<option>').attr('value',".str_replace(PHP_EOL, '', $registro->tags[0]->cdata).").text('".$registro->tags[1]->cdata ."'));";
		}					
	}
?>