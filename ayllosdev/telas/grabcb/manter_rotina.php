<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jean Michel       
 * DATA CRIAÇÃO : 09/04/2014 
 * OBJETIVO     : Rotina para manter as operações da tela GRABCB
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
	
	$funcaoAposErro = 'btnVoltar();';
		
	if(($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["cddopcao"]) || !isset($_POST["cdgrafin"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}else{
		$cddopcao = $_POST["cddopcao"];
		$cdgrafin = $_POST["cdgrafin"];
		$cdcooper = !isset($_POST["cdcooper"]) || is_null($_POST["cdcooper"]) || $_POST["cdcooper"] == '' ? 0 : $_POST["cdcooper"];
		$cdagenci = !isset($_POST["cdagenci"]) || is_null($_POST["cdagenci"]) || $_POST["cdagenci"] == '' ? 0 : $_POST["cdagenci"];
		$cdadmcrd = !isset($_POST["cdadmcrd"]) || is_null($_POST["cdadmcrd"]) || $_POST["cdadmcrd"] == '' ? 0 : $_POST["cdadmcrd"];
			
		if($cddopcao == 'A' && $cdcooper == 0){
			$cddopcao = 'C';
			$cddopcan = 'A';
		}else if($cddopcao == 'E' && $cdcooper == 0){
			$cddopcao = 'C';
			$cddopcan = 'E';
		}
		
		// Verifica se número da conta é um inteiro válido
		if (!validaInteiro($cdgrafin)) exibirErro('error','Par&acirc;metro inv&aacute;lido: C&oacute;digo da Sequ&ecirc;ncia.','Alerta - Ayllos',$funcaoAposErro,false);
		if (!validaInteiro($cdcooper)) exibirErro('error','Par&acirc;metro inv&aacute;lido: C&oacute;digo da Cooperativa.','Alerta - Ayllos',$funcaoAposErro,false);
		if (!validaInteiro($cdagenci)) exibirErro('error','Par&acirc;metro inv&aacute;lido: C&oacute;digo do PA.','Alerta - Ayllos',$funcaoAposErro,false);
		if (!validaInteiro($cdadmcrd)) exibirErro('error','Par&acirc;metro inv&aacute;lido: C&oacute;digo da Administradora.','Alerta - Ayllos',$funcaoAposErro,false);
		
	}	
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <cdcopgru>".$cdcooper."</cdcopgru>";
	$xml .= "   <cdgrafin>".$cdgrafin."</cdgrafin>";	
	$xml .= "   <cdagengr>".$cdagenci."</cdagengr>";
	$xml .= "   <cdadmcrd>".$cdadmcrd."</cdadmcrd>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "GRABCB", "GRABCB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		exit();
	}else{	
		if($cddopcao == "C"){		
			if($cddopcan == 'A'){
				echo '$("#cddtrans","#frmCab").prop("readonly", true);';			
				echo '$("#nmrescop","#frmCab").removeAttr("disabled");';
				echo '$("#cdagenci","#frmCab").removeAttr("disabled");';
				echo '$("#slcadmin","#frmCab").removeAttr("disabled");';
				
				echo "$('#cdcopaux','#frmCab').val('".$xmlObj->roottag->tags[0]->tags[1]->cdata."');";										
				echo "$('#nmrescop','#frmCab').val('".$xmlObj->roottag->tags[0]->tags[2]->cdata."');";										
				echo "$('#cdagenci','#frmCab').val('".$xmlObj->roottag->tags[0]->tags[3]->cdata."');";						
				echo "$('#slcadmin','#frmCab').val('".$xmlObj->roottag->tags[0]->tags[4]->cdata."');";
			}else{
				echo "$('#cdcopaux','#frmCab').val('".$xmlObj->roottag->tags[0]->tags[1]->cdata."');";										
				echo '$("#cddtrans","#frmCab").attr("readonly", true);';			
				echo "$('#nmrescop','#frmCab').val('".$xmlObj->roottag->tags[0]->tags[2]->cdata."');";			
				echo "$('#nmrescop','#frmCab').attr('disabled',true);";				
				echo "$('#cdagenci','#frmCab').val('".$xmlObj->roottag->tags[0]->tags[3]->cdata."');";			
				echo "$('#cdagenci','#frmCab').attr('disabled',true);";	
				echo "$('#slcadmin','#frmCab').val(".$xmlObj->roottag->tags[0]->tags[4]->cdata.");";
				echo "$('#slcadmin','#frmCab').attr('disabled',true);";	
			}	
		}elseif($cddopcao == "A"){
			exibirErro('inform','Alterado com Sucesso.','Alerta - Ayllos',$funcaoAposErro,false);
		}elseif($cddopcao == "I"){
			if($cdcooper != 0){
				exibirErro('inform','Inclu&iacute;do com Sucesso.','Alerta - Ayllos',$funcaoAposErro,false);
			}else{
				echo '$("#nmrescop","#frmCab").removeAttr("disabled");';
				echo '$("#cdagenci","#frmCab").removeAttr("disabled");';
				echo '$("#slcadmin","#frmCab").removeAttr("disabled");';
				echo '$("#nmrescop","#frmCab").focus();';
			}
		}elseif($cddopcao == "E"){
			exibirErro('inform','Exclu&iacute;do com Sucesso.','Alerta - Ayllos',$funcaoAposErro,false);
		}else{
			exibirErro('error','Par&acirc;metros inv&aacute;lidos.','Alerta - Ayllos',$funcaoAposErro,false);
		}
	}
?>