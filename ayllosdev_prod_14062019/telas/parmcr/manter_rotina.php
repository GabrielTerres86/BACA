<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jonata Cardoso (RKAM)       
 * DATA CRIAÇÃO : 10/12/2014
 * OBJETIVO     : Rotina para alteracao, exclusao e inclusao da tela PARMCR
 * --------------
 * ALTERAÇÕES   : 
 */
?> 

<?	
	session_cache_limiter("private");
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	// Recebe os parametros
	$cddopcao      = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$operacao      = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ; 
	$nrversao      = (isset($_POST['nrversao'])) ? $_POST['nrversao'] : 0  ; 	
	$nrseqtit      = (isset($_POST['nrseqtit'])) ? $_POST['nrseqtit'] : 0  ; 
	$nrseqper      = (isset($_POST['nrseqper'])) ? $_POST['nrseqper'] : 0  ; 
	$nrseqres      = (isset($_POST['nrseqres'])) ? $_POST['nrseqres'] : 0  ; 
	$dsversao      = (isset($_POST['dsversao'])) ? $_POST['dsversao'] : 0  ; 
	$dtinivig      = (isset($_POST['dtinivig'])) ? $_POST['dtinivig'] : 0  ; 
	$nrordtit      = (isset($_POST['nrordtit'])) ? $_POST['nrordtit'] : 0  ; 
	$dstitulo      = (isset($_POST['dstitulo'])) ? $_POST['dstitulo'] : 0  ; 
	$nrordper      = (isset($_POST['nrordper'])) ? $_POST['nrordper'] : 0  ; 
	$dspergun      = (isset($_POST['dspergun'])) ? $_POST['dspergun'] : 0  ; 
	$inobriga      = (isset($_POST['inobriga'])) ? $_POST['inobriga'] : 0  ;
	$intipres      = (isset($_POST['intipres'])) ? $_POST['intipres'] : 0  ; 
	$nrregcal      = (isset($_POST['nrregcal'])) ? $_POST['nrregcal'] : 0  ; 
	$dsregexi      = (isset($_POST['dsregexi'])) ? $_POST['dsregexi'] : 0  ; 
	$nrordres      = (isset($_POST['nrordres'])) ? $_POST['nrordres'] : 0  ; 
	$dsrespos      = (isset($_POST['dsrespos'])) ? $_POST['dsrespos'] : 0  ; 
	
	$dsversao = retiraAcentos($dsversao);
	$dstitulo = retiraAcentos($dstitulo);
	$dspergun = retiraAcentos($dspergun);
	$dsrespos = retiraAcentos($dsrespos);
	

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Setar a rotina a chamar no Oracle
	if (in_array($operacao,array("I_crapvqs_3","A_crapvqs_3","E_crapvqs_2"))) {
		$strnomacao = 'CRAPVQS'; 
		$operacao = 'C1';
	}
	else
	if (in_array($operacao,array("I_craptqs_3","A_craptqs_3","E_craptqs_2"))) {
		$strnomacao = 'CRAPTQS'; 
		$operacao = 'C2';
	}
	else
	if (in_array($operacao,array("I_crappqs_3","A_crappqs_3","E_crappqs_2"))) {
		$strnomacao = 'CRAPPQS'; 
		$operacao = 'C3';
	}
	else
	if (in_array($operacao,array("I_craprqs_3","A_craprqs_3","E_craprqs_2"))) {
		$strnomacao = 'CRAPRQS'; 
		$operacao = 'C4';
	}
	else
	if ($operacao == 'D_crapvqs_3') {
		$strnomacao = 'CRIA_VERSAO_CRAPVQS';
		$operacao = 'C1';
	}
	else if ($operacao == 'C_crappqs_1') {
		$strnomacao = 'CRAPPQS'; 
	}
	else if ($operacao == 'C_craprqs_1') {
		$strnomacao = 'CRAPRQS';
	}
	
	
	// Montar o xml para requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "    <cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xml .= "    <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "    <nrversao>".$nrversao."</nrversao>";
	$xml .= "    <nrseqtit>".$nrseqtit."</nrseqtit>";
	$xml .= "    <nrseqper>".$nrseqper."</nrseqper>";
	$xml .= "    <nrseqres>".$nrseqres."</nrseqres>";
	$xml .= "    <dsversao>".$dsversao."</dsversao>";
	$xml .= "    <dtinivig>".$dtinivig."</dtinivig>";
	$xml .= "    <nrordtit>".$nrordtit."</nrordtit>";
	$xml .= "    <dstitulo>".$dstitulo."</dstitulo>";
	$xml .= "    <nrordper>".$nrordper."</nrordper>";
	$xml .= "    <dspergun>".$dspergun."</dspergun>";
	$xml .= "    <inobriga>".$inobriga."</inobriga>";
	$xml .= "    <intipres>".$intipres."</intipres>";
	$xml .= "    <nrregcal>".$nrregcal."</nrregcal>";
	$xml .= "    <dsregexi>".$dsregexi."</dsregexi>";
	$xml .= "    <nrordres>".$nrordres."</nrordres>";
	$xml .= "    <dsrespos>".$dsrespos."</dsrespos>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
 
	$xmlResult = mensageria($xml, "PARMCR", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	$xml_dados = simplexml_load_string($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
 	if ($xml_dados->Erro != "") {
	    exibirErro('error',$xml_dados->Erro,'Alerta - Ayllos','',false);		 
    }
		
	if ($cddopcao == "I") 
		$dsmensag = "Inclus&atilde;o ";
	else 
	if ($cddopcao == 'E')
		$dsmensag = 'Exclus&atilde;o ';
	else	
	if ($cddopcao == 'D')
		$dsmensag = 'Duplica&ccedil;&atilde;o ';
		
	if ($dsmensag != '' || $cddopcao == 'A') {
		
		echo "fechaOpcao();";
		
		if ($dsmensag != '') {
			$dsmensag .= 'efetuada com sucesso!';		
			exibirErro('inform',$dsmensag,'Alerta - Ayllos','unblockBackground();',false);
		}
	}
		
	if ($operacao == 'C1') {
		echo "controlaOperacao('$operacao','0','0','0','true');";
	}
	else if ($operacao == 'C2') {
		echo "controlaOperacao('$operacao','$nrversao','0','0','true');";
	}
	else if ($operacao == 'C3') {
		echo "controlaOperacao('$operacao','0','$nrseqtit','0','true');";
	}
	else if ($operacao == 'C4') {
		echo "controlaOperacao('$operacao','0','0','$nrseqper','true');";
	}
	else if ($operacao == 'C_crappqs_1') {
		
		$crappqs      = $xml_dados->inf;
		$sel_nrseqper = substr($dsregexi,8, strpos($dsregexi,'=') - 8 ); 
		
		echo "$('#dsfiltro','#frmExistencia').append('<option>Selecione uma pergunta</option>');";
						
		for ($i= 0; $i < count($crappqs); $i++) {
				
			$inf_nrordper = $crappqs[$i]->nrordper;
			$inf_nrseqper = $crappqs[$i]->nrseqper;
			$inf_dspergun = $crappqs[$i]->dspergun;
									
			// So exibir as perguntas anteriores a atual
			if ($inf_nrordper >= $nrordper) {
				continue;
			}
					
			$selected = ($inf_nrseqper == $sel_nrseqper ) ? 'selected' : '';
				
			echo "$('#dsfiltro','#frmExistencia').append('<option $selected value=$inf_nrseqper>$inf_dspergun</option>');";
		}
		
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	}
	else if ($operacao == 'C_craprqs_1') {
	
		$crapprs      = $xml_dados->inf;
		$sel_nrseqres = substr($dsregexi,strpos($dsregexi,'=') + 9);  // 
		
		echo "$('#dsrespos','#frmExistencia').html('');";
		
		for ($i= 0; $i < count($crapprs); $i++) {
		
			$inf_nrseqres = $crapprs[$i]->nrseqres;
			$inf_dsrespos = $crapprs[$i]->dsrespos;
			
			$selected = ($inf_nrseqres == $sel_nrseqres ) ? 'selected' : '  ';
				
			echo "$('#dsrespos','#frmExistencia').append('<option $selected value=$inf_nrseqres>$inf_dsrespos</option>');";
		}
		
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	}
	
?>