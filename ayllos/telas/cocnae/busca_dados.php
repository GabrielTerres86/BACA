<? 
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Tiago Machado        
 * DATA CRIAÇÃO : 08/09/2016 
 * OBJETIVO     : Rotina para buscar dados dos CNAE bloqueados
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
	$cdcnae = (isset($_POST['cdcnae'])) ? $_POST['cdcnae'] : 0;

	// Monta o xml de requisição
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml       .=		"<cdcnae>".$cdcnae."</cdcnae>";
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";		
						
	$xmlResult = mensageria($xml, "COCNAE", "BUSCA_CNAE_BLOQUEADO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes["NMDCAMPO"];

		if(empty ($nmdcampo)){ 
			$nmdcampo = "cdcnae";
		}

		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','focaCampoErro(\''.$nmdcampo.'\',\'frmCadastro\');',false);		
					
	} else {
		
		$qtregist =  $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];
		
		if( $qtregist <> 1 ){
			echo 'preencheDadosTela(" ", " ", "0", " ", " ", " ", " ");';
			exibirErro('error',utf8_encode('N&atilde;o h&aacute; registros com esse CNAE'),'Alerta - Ayllos','focaCampoErro(\'cdcnae\',\'frmCadastro\');',false);
			return false;
		}
		
		$cdcnae = $xmlObjeto->roottag->tags[0]->tags[0]->tags[0]->cdata;		
		$dscnae = $xmlObjeto->roottag->tags[0]->tags[0]->tags[1]->cdata;		
		$dsmotivo = $xmlObjeto->roottag->tags[0]->tags[0]->tags[2]->cdata;
		$tpcnae = $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata;
		$dslicenca = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$dtmvtolt = $xmlObjeto->roottag->tags[0]->tags[0]->tags[5]->cdata;
		$dtarquivo = $xmlObjeto->roottag->tags[0]->tags[0]->tags[6]->cdata;		
		
        echo 'preencheDadosTela("'.$cdcnae.'", "'.$dscnae.'", "'.$tpcnae.'", "'.$dsmotivo.'", "'.$dslicenca.'", "'.$dtmvtolt.'", "'.$dtarquivo.'");';		

	}
	
					
?>
