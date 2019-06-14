<?php
	/*!
	 * FONTE        : manter_rotina.php
	 * CRIAÇÃO      : Jean Michel       
	 * DATA CRIAÇÃO : 07/05/2014 
	 * OBJETIVO     : Rotina para manter as operações da tela INDICE
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
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["cddopcao"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}else{
		$cddopcao = !isset($_POST["cddopcao"]) ? 0 : $_POST["cddopcao"];
		$cddindex = !isset($_POST["cddindex"]) ? 0 : $_POST["cddindex"];
		$nmdindex = !isset($_POST["nmdindex"]) ? 0 : $_POST["nmdindex"];
		$dtperiod = !isset($_POST["dtperiod"]) ? 0 : $_POST["dtperiod"];	    
		$idperiod = !isset($_POST["idperiod"]) ? 0 : $_POST["idperiod"];
		$idexpres = !isset($_POST["idexpres"]) ? 0 : $_POST["idexpres"];
		$idcadast = !isset($_POST["idcadast"]) ? 0 : $_POST["idcadast"];
		$dtiniper = !isset($_POST["dtiniper"]) ? 0 : $_POST["dtiniper"];
		$dtfimper = !isset($_POST["dtfimper"]) ? 0 : $_POST["dtfimper"];
		$vlrdtaxa = !isset($_POST["vlrdtaxa"]) ? 0 : $_POST["vlrdtaxa"];
		$nriniseq = !isset($_POST["nriniseq"]) ? 1 : $_POST["nriniseq"];
		$nrregist = !isset($_POST["nrregist"]) ? 50 : $_POST["nrregist"];
		$flgalter = !isset($_POST["flgalter"]) ? 0 : $_POST["flgalter"];
		
		if (!validaInteiro($idperiod)) exibirErro('error','Per&iacute;odo inv&aacute;lido.','Alerta - Ayllos',$funcaoAposErro,false);		
		if (!validaInteiro($idexpres)) exibirErro('error','Taxa Expressa inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro,false);		
		if (!validaInteiro($idcadast)) exibirErro('error','Forma de Cadastro inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro,false);		
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos',$funcaoAposErro,false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <cddindex>".$cddindex."</cddindex>";
	$xml .= "   <nmdindex>".$nmdindex."</nmdindex>";
	$xml .= "   <dtperiod>".$dtperiod."</dtperiod>";
	$xml .= "   <idperiod>".$idperiod."</idperiod>";
	$xml .= "   <idexpres>".$idexpres."</idexpres>";
	$xml .= "   <idcadast>".$idcadast."</idcadast>";
	$xml .= "   <dtiniper>".$dtiniper."</dtiniper>";
	$xml .= "   <dtfimper>".$dtfimper."</dtfimper>";
	$xml .= "   <vlrdtaxa>".$vlrdtaxa."</vlrdtaxa>";	
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "   <nrregist>".$nrregist."</nrregist>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "INDICE", "INDICE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
		
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		
		exit();
	}else{
		
		$flgAltera = false;
		
		if($cddopcao == "A"){
			if($idcadast == 0 && $flgalter == 0){
			
				$flgprodut = $xmlObj->roottag->tags[0]->tags[5]->cdata;
				
				if ($flgprodut == 0){
					echo ("$('#idperiodA','#frmCab').attr('disabled',false);");
					echo ("$('#idexpresA','#frmCab').attr('disabled',false);");
					echo ("$('#idcadastA','#frmCab').attr('disabled',false);");
					echo ("$('#idcadastA','#frmCab').focus();");
				}else{
					exibirErro('inform','Periodicidade de cadastro e expressao da taxa nao podem ser alterados.','Alerta - Ayllos','',false);
					echo ("$('#idperiodA','#frmCab').attr('disabled',true);");
					echo ("$('#idexpresA','#frmCab').attr('disabled',true);");
					echo ("$('#idcadastA','#frmCab').habilitaCampo();");
					echo ("$('#idcadastA','#frmCab').focus();");
				}
				
				echo("$('#idperiodA','#frmCab').val('".$xmlObj->roottag->tags[0]->tags[2]->cdata."');");
				echo("$('#idexpresA','#frmCab').val('".$xmlObj->roottag->tags[0]->tags[4]->cdata."');");
				
				if($xmlObj->roottag->tags[0]->tags[3]->cdata == 1){
					echo("$('input:radio[name=idcadastA][value=1]').attr('checked', true);");
				}else{				
					echo("$('input:radio[name=idcadastA][value=2]').attr('checked', true);");
				}
				echo("flgAltera = 1;");
			}else{
				echo("cCddindexA.habilitaCampo();");
				echo("flgAltera = 0;");
				echo("limpaTela();");
				echo("btnVoltar();");
			}
		}elseif($cddopcao == "C"){
			$registros = $xmlObj->roottag->tags[0]->tags;
			$qtdregist = $xmlObj->roottag->tags[2]->cdata;
			
			include('tab_consulta.php');
		}elseif($cddopcao == "I"){
			echo("btnVoltar();");
		}elseif($cddopcao == "R"){
			echo ($xmlObj->roottag->tags[0]->cdata);
		}elseif($cddopcao == "T"){
						
			$tpdata = $xmlObj->roottag->tags[0]->tags[0]->cdata;
			
			echo "$('#dtperiod','#frmCab').css('text-align','right');";
			echo "$('#dtperiod','#frmCab').attr('disabled',false);";
			echo "$('#dtperiod','#frmCab').val('');";
			
			if ($tpdata == 1){
				echo "$('#dtperiod','#frmCab').attr('maxlength','10');";
				echo "$('#dtperiod','#frmCab').setMask('INTEGER','99/99/9999','/','');";
			}elseif($tpdata == 2){
				echo "$('#dtperiod','#frmCab').attr('maxlength','7');";
				echo "$('#dtperiod','#frmCab').setMask('INTEGER','99/9999','/','');";
			}elseif($tpdata == 3){
				echo "$('#dtperiod','#frmCab').attr('maxlength','4');";
				echo "$('#dtperiod','#frmCab').setMask('INTEGER','9999','/','');";
			}	
			echo "$('#dtperiod','#frmCab').habilitaCampo();";
			echo "$('#dtperiod','#frmCab').focus();";
		}else{
			exibirErro('error','Par&acirc;metros inv&aacute;lida.','Alerta - Ayllos','',false);
		}
	}
?>