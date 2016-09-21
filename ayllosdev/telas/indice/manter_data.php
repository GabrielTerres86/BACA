<?php
	/*!
	 * FONTE        : manter_data.php
	 * CRIAÇÃO      : Jean Michel       
	 * DATA CRIAÇÃO : 23/05/2014 
	 * OBJETIVO     : Rotina para validar data do indexador da tela INDICE opcao "T"
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
	
	$funcaoAposErro = "btnVoltar();";
		
	$cddopcao = !isset($_POST["cddopcao"]) ? 0 : $_POST["cddopcao"];
	$cddindex = !isset($_POST["cddindex"]) ? 0 : $_POST["cddindex"];
	$dtperiod = !isset($_POST["dtperiod"]) ? 0 : $_POST["dtperiod"];	    
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["cddindex"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}else{
				
		if (strlen($dtperiod) == 4) {
			$dtperiod = '01/01/'.$dtperiod;
		}else if(strlen($dtperiod) == 7){
			$dtperiod = '01/'.$dtperiod;
		}
		
		if (!validaInteiro($cddindex)) exibirErro('error','Per&iacute;odo inv&aacute;lido.','Alerta - Ayllos',$funcaoAposErro,false);		
	}
		
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddindex>".$cddindex."</cddindex>";
	$xml .= "   <dtperiod>".$dtperiod."</dtperiod>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	
	$xmlResult = mensageria($xml, "INDICE", "VDATA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
		
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		if ($cddopcao == 'T') {
			$funcaoAposErro = "$('#dtperiod','#frmCab').focus();";
		}
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$funcaoAposErro,false);		
		exit();
	}else{
		$cddopcao = $xmlObj->roottag->tags[0]->tags[0]->cdata;		
		
		if ($cddopcao == 0){
			/* Inserir registro */
			echo "$('#dtperiod','#frmCab').desabilitaCampo();";
			echo "cVlrdtaxa.habilitaCampo();";			
			echo "cVlrdtaxa.val('');";			
			echo "cVlrdtaxa.focus();";
			echo "auxMTaxas = 'I';";
			if ($cddopcao == 'C' || $cddopcao == 'R'){
				echo "$('#btSalvar','#frmCab').empty();";
			}
		}else{
			/* Verifica se é consulta ou relatório */
			if ($cddopcao != 'C' && $cddopcao != 'R'){
				/* Alterar registro */
				echo "$('#dtperiod','#frmCab').desabilitaCampo();";
				echo "$('#vlrdtaxa','#frmCab').habilitaCampo();";
				
				$vrlTaxas = str_replace('.',',',$xmlObj->roottag->tags[0]->tags[1]->cdata);				
				
				if($vrlTaxas == 0 || $vrlTaxas == null || $vrlTaxas == ''){
					echo "auxMTaxas = 'I';";
					echo "$('#vlrdtaxa','#frmCab').val('".$vrlTaxas."');";
				}else{
					echo "auxMTaxas = 'A';";
					echo "$('#vlrdtaxa','#frmCab').val('".$vrlTaxas."');";
				}
				
				echo "$('#vlrdtaxa','#frmCab').focus();";
			}
		}
		
	}
?>