<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jean Michel       
 * DATA CRIAÇÃO : 08/04/2014 
 * OBJETIVO     : Rotina para manter as operações da tela PARBCB
 * PROJETO		: Projeto de Novos Cartões Bancoob
 * --------------
 * ALTERAÇÕES   : 05/12/2016 - P341-Automatização BACENJUD - Utilizar o código 
 *                             do departamento no lugar da descrição (R.Darosci)
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
		
	// Verifica se os parâmetros necessários foram informados	
	if(!isset($_POST["tparquiv"]) || !isset($_POST["tipoacao"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','',false);
	}else{
		$tipoacao = $_POST["tipoacao"];
		$tparquiv = $_POST["tparquiv"];
		$nrseqarq = $_POST["nrseqarq"];
        $dsdirarq = $_POST["dsdirarq"];
		$flgretpr = $_POST['flgretpr'];
		$hdndepar = $_POST["hdndepar"];
		
		// Verifica se opcao é um inteiro válido
		if (!validaInteiro($tparquiv)) exibirErro('error','Op&ccedil;&atilde;o inv&aacute;lida.','Alerta - Ayllos','',false);
	}	
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$tipoacao."</cddopcao>";
	$xml .= "   <tparquiv>".$tparquiv."</tparquiv>";
	$xml .= "   <nrseqarq>".$nrseqarq."</nrseqarq>";
	$xml .= "   <dsdirarq>".$dsdirarq."</dsdirarq>";
	$xml .= "   <flgretpr>".$flgretpr."</flgretpr>";
	$xml .= " </Dados>";
	$xml .= "</Root>";	
	
	$xmlResult = mensageria($xml, "PARBCB", "PARBCB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		exit();
	}else{		
		
		if($tipoacao == "C"){	
			
			echo '$("#nrseqarq","#frmCab").empty();';
			echo '$("#dtultint","#frmCab").empty();';
			echo '$("#dsdirarq","#frmCab").empty();';			
			echo '$("#nrseqarq","#frmCab").removeAttr("disabled");';
			echo '$("#nrseqarq","#frmCab").removeAttr("readonly");';
			
			// Se departamento for 20 - TI
			if ($hdndepar == 20){
				echo '$("#dsdirarq","#frmCab").removeAttr("disabled");';
				echo '$("#dsdirarq","#frmCab").removeAttr("readonly");';
			}
			
			echo '$("#nrseqarq","#frmCab").val("'.$xmlObj->roottag->tags[0]->tags[1]->cdata.'");';
			echo '$("#dtultint","#frmCab").val("'.$xmlObj->roottag->tags[0]->tags[2]->cdata.'");';
			echo '$("#dsdirarq","#frmCab").val("'.$xmlObj->roottag->tags[0]->tags[3]->cdata.'");';
			
			if($xmlObj->roottag->tags[0]->tags[4]->cdata == 1){
				echo '$("#flgretpr","#frmCab").prop("checked",true);';
			}else{
				echo '$("#flgretpr","#frmCab").prop("checked",false);';
			}
			
			echo '$("#tparquiv","#frmCab").focus();';
		}else if($tipoacao == "A"){
			echo 'showError("inform","Altera&ccedil;&atilde;o Efetuada com Sucesso.","Alerta - Ayllos","");';
			echo "$('#tparquiv','#'+frmCab).val('1');";
			echo "$('#flgretpr','#'+frmCab).attr('checked',false);";
			echo "$('#dsdirarq','#'+frmCab).val('');";
			echo "$('#nrseqarq','#'+frmCab).val('');";
			echo "$('#dtultint','#'+frmCab).val('');";
			echo "$('#tparquiv','#'+frmCab).focus();";	
		}
	}	
?>