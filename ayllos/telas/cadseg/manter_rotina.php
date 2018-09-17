<?php
//*********************************************************************************************//
//*** Fonte: manter_rotina.php		                                                        ***//
//*** Autor: Cristian Filipe                                                                ***//
//*** Data : Novembro/2013                                                                  ***//
//*** Objetivo  : Rotinas da tela CADSEG		                                			***//
//***                                   					Ultima Alteracao: 29/01/2014    ***//	 
//*** Atualizacao:																			***//
//***				29/01/2014 - Adicionado parametro de envio cddopcao. (Jorge)			***//									
//*********************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
		
	// codigo da opção
    $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
    
    $cdsegura = (isset($_POST['cdsegura'])) ? $_POST['cdsegura'] : '';
    $nmsegura = (isset($_POST['nmsegura'])) ? $_POST['nmsegura'] : '';
    $flgativo = (isset($_POST['flgativo'])) ? $_POST['flgativo'] : '';
    $nmresseg = (isset($_POST['nmresseg'])) ? $_POST['nmresseg'] : '';
    $nrcgcseg = (isset($_POST['nrcgcseg'])) ? $_POST['nrcgcseg'] : '';
    $nrctrato = (isset($_POST['nrctrato'])) ? $_POST['nrctrato'] : '';
    $nrultpra = (isset($_POST['nrultpra'])) ? $_POST['nrultpra'] : '';
    $nrlimpra = (isset($_POST['nrlimpra'])) ? $_POST['nrlimpra'] : '';
    $nrultprc = (isset($_POST['nrultprc'])) ? $_POST['nrultprc'] : '';
    $nrlimprc = (isset($_POST['nrlimprc'])) ? $_POST['nrlimprc'] : '';
    $dsasauto = (isset($_POST['dsasauto'])) ? $_POST['dsasauto'] : '';
    //tela 2
    $cdhstaut1  = (isset($_POST['cdhstaut1'])) ? $_POST['cdhstaut1'] : '';
    $cdhstaut2  = (isset($_POST['cdhstaut2'])) ? $_POST['cdhstaut2'] : '';
    $cdhstaut3  = (isset($_POST['cdhstaut3'])) ? $_POST['cdhstaut3'] : '';
    $cdhstaut4  = (isset($_POST['cdhstaut4'])) ? $_POST['cdhstaut4'] : '';
    $cdhstaut5  = (isset($_POST['cdhstaut5'])) ? $_POST['cdhstaut5'] : '';
    $cdhstaut6  = (isset($_POST['cdhstaut6'])) ? $_POST['cdhstaut6'] : '';
    $cdhstaut7  = (isset($_POST['cdhstaut7'])) ? $_POST['cdhstaut7'] : '';
    $cdhstaut8  = (isset($_POST['cdhstaut8'])) ? $_POST['cdhstaut8'] : '';
    $cdhstaut9  = (isset($_POST['cdhstaut9'])) ? $_POST['cdhstaut9'] : '';
    $cdhstaut10 = (isset($_POST['cdhstaut10'])) ? $_POST['cdhstaut10'] : '';
    $cdhstcas1  = (isset($_POST['cdhstcas1'])) ? $_POST['cdhstcas1'] : '';
    $cdhstcas2  = (isset($_POST['cdhstcas2'])) ? $_POST['cdhstcas2'] : '';
    $cdhstcas3  = (isset($_POST['cdhstcas3'])) ? $_POST['cdhstcas3'] : '';
    $cdhstcas4  = (isset($_POST['cdhstcas4'])) ? $_POST['cdhstcas4'] : '';
    $cdhstcas5  = (isset($_POST['cdhstcas5'])) ? $_POST['cdhstcas5'] : '';
    $cdhstcas6  = (isset($_POST['cdhstcas6'])) ? $_POST['cdhstcas6'] : '';
    $cdhstcas7  = (isset($_POST['cdhstcas7'])) ? $_POST['cdhstcas7'] : '';
    $cdhstcas8  = (isset($_POST['cdhstcas8'])) ? $_POST['cdhstcas8'] : '';
    $cdhstcas9  = (isset($_POST['cdhstcas9'])) ? $_POST['cdhstcas9'] : '';
    $cdhstcas10 = (isset($_POST['cdhstcas10'])) ? $_POST['cdhstcas10'] : '';
    $dsmsgseg   = (isset($_POST['dsmsgseg'])) ? $_POST['dsmsgseg'] : '';
	
	$procedure = "";
	
	// Verifica Permiss&atilde;o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibeErro($msgError);		
	}
	
	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'I': $procedure = 'Grava_dados_seguradora'; break;
		case 'A': $procedure = 'Grava_dados_seguradora'; break;
		case 'E': $procedure = 'Elimina_seguradora'; break;
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "	    <Bo>b1wgen0181.p</Bo>";
	$xmlSetPesquisa .= "        <Proc>'{$procedure}'</Proc>";
	$xmlSetPesquisa .= "  </Cabecalho>";
	$xmlSetPesquisa .= "  <Dados>";
	$xmlSetPesquisa .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetPesquisa .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetPesquisa .= '        <nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xmlSetPesquisa .= '        <cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xmlSetPesquisa .= '        <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xmlSetPesquisa .= '        <idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xmlSetPesquisa .= '        <nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xmlSetPesquisa .= '        <cdprogra>'.$glbvars['cdprogra'].'</cdprogra>';	
	$xmlSetPesquisa .= '        <cddopcao>'.$cddopcao.'</cddopcao>';	
	// tela 1
	$xmlSetPesquisa .= "        <cdsegura>".$cdsegura."</cdsegura>";
	$xmlSetPesquisa .= "        <nmsegura>".$nmsegura."</nmsegura>";
	$xmlSetPesquisa .= "        <flgativo>".$flgativo."</flgativo>";
	$xmlSetPesquisa .= "        <nmresseg>".$nmresseg."</nmresseg>";
	$xmlSetPesquisa .= "        <nrcgcseg>".$nrcgcseg."</nrcgcseg>";
	$xmlSetPesquisa .= "        <nrctrato>".$nrctrato."</nrctrato>";
	$xmlSetPesquisa .= "        <nrultpra>".$nrultpra."</nrultpra>";
	$xmlSetPesquisa .= "        <nrlimpra>".$nrlimpra."</nrlimpra>";
	$xmlSetPesquisa .= "        <nrultprc>".$nrultprc."</nrultprc>";
	$xmlSetPesquisa .= "        <nrlimprc>".$nrlimprc."</nrlimprc>";
	$xmlSetPesquisa .= "        <dsasauto>".$dsasauto."</dsasauto>";
	$xmlSetPesquisa .= "        <valdtudo>NO</valdtudo>";
	//tela 2
	$xmlSetPesquisa .= "        <cdhstaut1>".$cdhstaut1."</cdhstaut1>";
	$xmlSetPesquisa .= "        <cdhstaut2>".$cdhstaut2."</cdhstaut2>";
	$xmlSetPesquisa .= "        <cdhstaut3>".$cdhstaut3."</cdhstaut3>";
	$xmlSetPesquisa .= "        <cdhstaut4>".$cdhstaut4."</cdhstaut4>";
	$xmlSetPesquisa .= "        <cdhstaut5>".$cdhstaut5."</cdhstaut5>";
	$xmlSetPesquisa .= "        <cdhstaut6>".$cdhstaut6."</cdhstaut6>";
	$xmlSetPesquisa .= "        <cdhstaut7>".$cdhstaut7."</cdhstaut7>";
	$xmlSetPesquisa .= "        <cdhstaut8>".$cdhstaut8."</cdhstaut8>";
	$xmlSetPesquisa .= "        <cdhstaut9>".$cdhstaut9."</cdhstaut9>";
	$xmlSetPesquisa .= "        <cdhstaut10>".$cdhstaut10."</cdhstaut10>";
	$xmlSetPesquisa .= "        <cdhstcas1>".$cdhstcas1."</cdhstcas1>";
	$xmlSetPesquisa .= "        <cdhstcas2>".$cdhstcas2."</cdhstcas2>";
	$xmlSetPesquisa .= "        <cdhstcas3>".$cdhstcas3."</cdhstcas3>";
	$xmlSetPesquisa .= "        <cdhstcas4>".$cdhstcas4."</cdhstcas4>";
	$xmlSetPesquisa .= "        <cdhstcas5>".$cdhstcas5."</cdhstcas5>";
	$xmlSetPesquisa .= "        <cdhstcas6>".$cdhstcas6."</cdhstcas6>";
	$xmlSetPesquisa .= "        <cdhstcas7>".$cdhstcas7."</cdhstcas7>";
	$xmlSetPesquisa .= "        <cdhstcas8>".$cdhstcas8."</cdhstcas8>";
	$xmlSetPesquisa .= "        <cdhstcas9>".$cdhstcas9."</cdhstcas9>";
	$xmlSetPesquisa .= "        <cdhstcas10>".$cdhstcas10."</cdhstcas10>";
	$xmlSetPesquisa .= "        <dsmsgseg>".$dsmsgseg."</dsmsgseg>";	
	$xmlSetPesquisa .= "  </Dados>";
	$xmlSetPesquisa .= "</Root>";
	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetPesquisa );
	$xmlObjPesquisa = getObjectXML($xmlResult);
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") {
		
		$nmdcampo = $xmlObjPesquisa->roottag->tags[0]->attributes['NMDCAMPO'];
		$retornoAposErro = "$('#btVoltar','#divBotoes').show();$('#btnContinuar','#divBotoes').show();"; 
		
		if (!empty($nmdcampo)) { 
			$nmdoform = "frmInfSeguradora";
			$retornoAposErro .= "$('#cddopcao','#frmCab').val('".$cddopcao."');focaCampoErro('".$nmdcampo."','".$nmdoform."');"; 
		}else{
			$retornoAposErro .= "$('#cddopcao','#frmCab').habilitaCampo();";
		}
		
		$retornoAposErro .= "hideMsgAguardo();";
		
		$msgErro = "<div style=\"text-align:left;\">";
		$taberros = $xmlObjPesquisa->roottag->tags[0]->tags;
		for($i=0;$i<count($taberros);$i++){
			if($i==0){
				$msgErro .= $taberros[$i]->tags[4]->cdata;
			}else{
				$msgErro .= "<br>".$taberros[$i]->tags[4]->cdata;
			}
		}	
		$msgErro .= "</div>";
		?> 
			showError('error','<?php echo $msgErro; ?>','<?php echo utf8_decode("Alerta - Ayllos"); ?>',"<?php echo $retornoAposErro; ?>");
		<?php
		exit();
	}

	if ($cddopcao == "I") {
		$msgOK = "Seguradora cadastrada com sucesso!";
	}else if ($cddopcao == "A"){
		$msgOK = "Seguradora alterada com sucesso!";
	}else if ($cddopcao == "E"){
		$msgOK = "Seguradora excluida com sucesso!";
	}
	
	exibirErro('inform',$msgOK,'Alerta - Ayllos',"estadoInicial();",false);	
?>