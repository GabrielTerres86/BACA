<? 
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Tiago Machado        
 * DATA CRIAÇÃO : 08/09/2016 
 * OBJETIVO     : Rotina para buscar dados dos CNPJs bloqueados
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
?> 
<?php 
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
		
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Guardo os parâmetos do POST em variáveis	
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0;

	// Monta o xml de requisição
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml       .=		"<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";		
						
	$xmlResult = mensageria($xml, "COCNPJ", "BUSCA_CNPJ_BLOQUEADO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes["NMDCAMPO"];

		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrcpfcgc";
		}

		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','focaCampoErro(\''.$nmdcampo.'\',\'frmCadastro\');',false);		
					
	} else {
		
		$qtregist =  $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];
		
		if( $qtregist <> 1 ){
			echo 'preencheDadosTela("1"," ", " ", " ", " ", " ");';
			exibirErro('error',utf8_encode('N&atilde;o h&aacute; registros com esse CNPJ'),'Alerta - Ayllos','focaCampoErro(\'nrcpfcgc\',\'frmCadastro\');',false);
			return false;
		}
		
		$nrcpfcgc = $xmlObjeto->roottag->tags[0]->tags[0]->tags[0]->cdata;		
		$dsnome = $xmlObjeto->roottag->tags[0]->tags[0]->tags[1]->cdata;		
		$dsmotivo = $xmlObjeto->roottag->tags[0]->tags[0]->tags[2]->cdata;
		$inpessoa = $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata;
		$dtmvtolt = $xmlObjeto->roottag->tags[0]->tags[0]->tags[5]->cdata;
		$dtarquivo = $xmlObjeto->roottag->tags[0]->tags[0]->tags[6]->cdata;		
		
        echo 'preencheDadosTela("'.$inpessoa.'", "'.$nrcpfcgc.'", "'.$dsnome.'", "'.$dsmotivo.'", "'.$dtmvtolt.'", "'.$dtarquivo.'");';		

	}
	
					
?>
