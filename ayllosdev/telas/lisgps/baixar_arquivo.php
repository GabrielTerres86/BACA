<?php

    //*******************************************************************************************************************//
    //*** Fonte: baixar_arquivo.php                                                                                   ***//
    //*** Autor: Renato Darosci / SUPERO                                                                              ***//
    //*** Data : Outubro/2016                   �ltima Altera��o:                                                     ***//
    //***                                                                                                             ***//
    //*** Objetivo  : Buscar arquivos do GPS, gerar ZIP e baixar.												      ***//
    //***                                                                                                             ***//
    //*** Altera��es:                                                                                                 ***//
    //***                                                                                                             ***//
    //*******************************************************************************************************************//

    session_cache_limiter("private");
    session_start();

    // Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es
    require_once("../../includes/config.php");
    require_once("../../includes/funcoes.php");
    require_once("../../includes/controla_secao.php");

    // Verifica se tela foi chamada pelo m�todo POST
    isPostMethod();

    // Classe para leitura do xml de retorno
    require_once("../../class/xmlfile.php");

    $dtpagmto = $_POST["dtpagmto"];
    $cdidenti = $_POST["cdidenti"];
    
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'S')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars["cdcooper"].'</cdcooper>';
	$xml .= '       <dtpagmto>'.$dtpagmto.'</dtpagmto>';
	$xml .= '		<cdidenti>'.$cdidenti.'</cdidenti>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "LISGPS", "DOWNGPS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

	// Diret�rio onde se encontra o arquivo para download
    $dirdestino = "/var/www/ayllos/documentos/" . $glbvars["dsdircop"]. "/temp/";

	// Arquivo ZIP gerado 
	$nmarqzip = $xmlObjeto->roottag->cdata;
	
?>	

	nmArqZip = '<? echo $dirdestino . $nmarqzip; ?>';
    idlogin  = '<? echo base64_encode($glbvars["sidlogin"]);?>';

	var strHTML = "";

<?php
    echo 'hideMsgAguardo();';
    echo "window.open('download_zip.php?sidlogin=' + idlogin + '&src=' + nmArqZip, '_blank');";
	// Ap�s processar o arquivo voltar a situa��o da tela
	echo 'cDtpagmto.val(dtmvtolt);';
	echo 'cCdidenti.val(0);';
	echo 'configuraTela();';

    // Fun��o para exibir erros na tela atrav�s de javascript
    function exibeErro($msgErro) {
        echo 'hideMsgAguardo();';
        echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
        exit();
    }

?>
