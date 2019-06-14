<?php
	/*!
	 * FONTE        : manter_rotina.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 30/07/2015
	 * OBJETIVO     : Rotina para manter as operações da tela CONSPB
	 * --------------
	 * ALTERAÇÕES   : 01/06/2016 - Ajustado para nao realizar o UPLOAD dos arquivos (Douglas - Chamado 443701)
	 * -------------- 
	 */		
	 
	if( !ini_get('safe_mode') ){
		set_time_limit(300);
	}
	session_cache_limiter("private");
	session_start();

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"P")) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Ler parametros passados via POST
	$dspartes = (isset($_POST['dspartes']))  ? $_POST['dspartes']  : '';
	$dsdopcao = (isset($_POST['dsdopcao']))  ? $_POST['dsdopcao']  : '';
	$nmarquiv = (isset($_POST['nmarquiv']))  ? $_POST['nmarquiv']  : '';
	
	if ( $dspartes == "" ) {
		exibirErro('error','Partes n&atilde;o selecionado.','Alerta - Ayllos','focaCampoErro(\'dspartes\',\'frmCab\');',false);
	}
	
	if ( $dsdopcao == "" ) {
		exibirErro('error','Op&ccedil;&atilde;o n&atilde;o selecionado.','Alerta - Ayllos','focaCampoErro(\'dsdopcao\',\'frmCab\');',false);
	}
	
	if ( $nmarquiv == "" ) {
		exibirErro('error','Arquivo n&atilde;o informado.','Alerta - Ayllos','focaCampoErro(\'nmarquiv\',\'frmCab\');',false);
	}
	
	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "		<dspartes>".$dspartes."</dspartes>";
	$xml .= "		<dsdopcao>".$dsdopcao."</dsdopcao>";
	$xml .= "		<nmarquiv>".$nmarquiv."</nmarquiv>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CONSPB", "CONSPB_PROCESSAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nmarquiv";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input,select\',\'#frmCab\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmCab\');',false);
	}		
	
	// Verifica mensagem de retorno
 	if ($xmlObjeto->roottag->tags[0]->name == "INFORM") {
		$qtcritic = $xmlObjeto->roottag->tags[0]->cdata;
		if($qtcritic == null || $qtcritic == ''){
			$qtcritic = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		// Armazenar a quantidade de criticas
		echo "qtdTotalRegistro = " . $qtcritic . ";";
		
		if ( $qtcritic > 0 ) {
		    $inform = "Foram identificadas " . $qtcritic . " inconsist&ecirc;ncias no arquivo de concilia&ccedil;&atilde;o." .
			          "<br>As criticas foram geradas no arquivo: <b>L:/cecred/spb/" . $nmarquiv . "_criticas.csv<b>" . 
                      "<br>Deseja visualizar as criticas em tela?";
			
			exibirConfirmacao($inform,'Confirma&ccedil;&otilde;o - Ayllos','processaCriticas();','estadoInicial();',false);	

		} else {
			$inform = "N&atilde;o foram identificadas inconsist&ecirc;ncias no arquivo de concilia&ccedil;&atilde;o.";
			exibirErro('inform',$inform,'Alerta - Ayllos',"estadoInicial();",false);
		}
	}		
?>