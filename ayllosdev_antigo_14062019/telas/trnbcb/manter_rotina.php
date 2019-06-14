 <? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jean Michel       
 * DATA CRIAÇÃO : 09/04/2014 
 * OBJETIVO     : Rotina para manter as operações da tela TRNBCB
 * PROJETO		: Projeto de Novos Cartões Bancoob
 * --------------
 * ALTERAÇÕES   : 01/07/2014 - Inclusão do checkbox Movimenta C/C (Lucas Lunelli)
 * 				  11/08/2014 - Remoção de parâmetros (Lucas Lunelli)
 *				  02/03/2016 - Ajustes referentes ao projeto melhoria 157 (Lucas Ranghetti #330322)
 * -------------- 
 */
	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Inicializa
	$funcaoAposErro = 'btnVoltar();';
	
	if(($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos',$funcaoAposErro,false);
	}
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["cddopcao"]) || !isset($_POST["cddtrans"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}else{
		$cddopcao = $_POST["cddopcao"];
		$cddtrans = $_POST["cddtrans"];		
		$dstrnbcb = $_POST["dsctrans"];
		$flgdebcc = $_POST["flgdebcc"];
		
		$cdhistor = !isset($_POST["cdhistor"]) || is_null($_POST["cdhistor"]) || $_POST["cdhistor"] == '' ? 0 : $_POST["cdhistor"];
		
		if($cddopcao == 'A' && $cdhistor == 0){
			$cddopcao = 'C';
			$cddopcan = 'A';
		}else if($cddopcao == 'E'){
			$cddopcao = 'C';
			$cddopcan = 'E';
		}else if($cddopcao == 'E2'){
			$cddopcao = 'E';
		} else if($cddopcao == 'E3'){
			$cddopcao = 'E3';
		}
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <cdtrnbcb>".$cddtrans."</cdtrnbcb>";
	$xml .= "   <dstrnbcb>".$dstrnbcb."</dstrnbcb>";
	$xml .= "   <cdhistor>".$cdhistor."</cdhistor>";
	$xml .= "   <flgdebcc>".$flgdebcc."</flgdebcc>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TRNBCB", "TRNBCB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	 
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;		
		if($cddopcao == 'A2'){
			$funcaoAposErro = "";
		}		
		
		if ($cddopcao == "H"){
			echo "$('#cdhistor','#frmCab').val('');";
			echo "$('#dshistor','#frmCab').val('');";
			$funcaoAposErro = "$('#cdhistor','#frmCab').focus();";
		}		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$funcaoAposErro,false);			
	}else{	
		
		$flgdebcc = getByTagName($xmlObj->roottag->tags[0]->tags[0]->tags, 'flgdebcc');
		if ($cddopcao == "E3"){
			echo "$('#dsctrans','#frmCab').val('');";
		}else{
		
			echo "$('#dsctrans','#frmCab').val('".getByTagName($xmlObj->roottag->tags[0]->tags[0]->tags, 'dstrnbcb')."');";								
		}
			
		if($cddopcao == "C"){			
			
			if ($flgdebcc == 1) {				
				echo "$('#flgdebcc','#frmCab').prop('checked', true);";
			} else {
				echo "$('#flgdebcc','#frmCab').prop('checked', false);";
			}
		
			if($cddopcan == 'A'){
				echo "$('#cddtrans','#frmCab').val('".getByTagName($xmlObj->roottag->tags[0]->tags[0]->tags, 'cdtrnbcb')."');";			
				echo "$('#dsctrans','#frmCab').val('".getByTagName($xmlObj->roottag->tags[0]->tags[0]->tags, 'dstrnbcb')."');";								
								
				echo "$('#cddtrans','#frmCab').attr('readonly',true);";
				echo "$('#dsctrans','#frmCab').removeAttr('disabled');";				
								
				echo "$('#dsctrans','#frmCab').removeAttr('readonly');";								
				
				echo "$('#dsctrans','#frmCab').focus();";				
			} else {				
				echo "$('#cddtrans','#frmCab').val('".getByTagName($xmlObj->roottag->tags[0]->tags[0]->tags, 'cdtrnbcb')."');";			
				echo "$('#cddtrans','#frmCab').attr('disabled',true);";	
				echo "$('#dsctrans','#frmCab').val('".getByTagName($xmlObj->roottag->tags[0]->tags[0]->tags, 'dstrnbcb')."');";	
				echo "$('#dsctrans','#frmCab').attr('disabled',true);";								
			}
		}elseif($cddopcao == "A"){
			exibirErro('inform','Alterado com Sucesso.','Alerta - Ayllos',$funcaoAposErro,false);				
		}elseif($cddopcao == "I"){					    
			
			if($cdhistor != 0){
				exibirErro('inform','Inclu&iacute;do com Sucesso.','Alerta - Ayllos',$funcaoAposErro,false);
			}else{
				echo '$("#cddtrans","#frmCab").attr("disabled",true);';	
				echo '$("#dsctrans","#frmCab").removeAttr("disabled");';								
				
				echo '$("#dsctrans","#frmCab").removeAttr("readonly");';								
				
				echo '$("#flgdebcc","#frmCab").prop("checked", false);';
				
				echo '$("#dsctrans","#frmCab").focus();';
			}
		}elseif($cddopcao == "E"){			
			
			exibirErro('inform','Exclu&iacute;do com Sucesso.','Alerta - Ayllos',$funcaoAposErro,false);
		}elseif($cddopcao == "A2"){						
			exibirErro('inform','Transa&ccedil;&atilde;o alterada com Sucesso.','Alerta - Ayllos',$funcaoAposErro,false);
		} /*else{
			exibirErro('error','Par&acirc;metros inv&aacute;lidos.','Alerta - Ayllos',$funcaoAposErro,false);
		}*/
	}
	

?>