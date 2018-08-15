<?php 

	    /*!
     * FONTE        : obtem_pessoa.php
     * CRIA��O      : Odirlei Busana(AMcom)
     * DATA CRIA��O : Novembro/2017 
     * OBJETIVO     : Retorna dados dos titulares e tipo de contas
     * --------------
     * ALTERA��ES   :
     * --------------
     *
     */	     
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (!isset($_POST["nrcpfcgc"]))  {
		exibeErro("Par�metros incorretos.");
	}	
			
	$nrcpfcgc = $_POST["nrcpfcgc"] == "" ? 0 : $_POST["nrcpfcgc"];
    $cdcooper = $_POST["cdcooper"] == "" ? 0 : $_POST["cdcooper"];
    $nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
    $idseqttl = $_POST["idseqttl"] == "" ? 0 : $_POST["idseqttl"];
    
	
	// Se conta informada n�o for um n�mero inteiro v�lido
	if (!validaInteiro($nrcpfcgc)) {
		exibeErro("Conta/dv inv�lida.");
	}	
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";    
    $xml .= "   <cdcoptel>".$cdcooper."</cdcoptel>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <idseqttl>".$idseqttl."</idseqttl>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_HISPES", "BUSCAR_PESSOA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }

        exibeErroNew($msgErro);
        exit();
    }

    $registros = $xmlObj->roottag->tags[0]->tags;

    function exibeErroNew($msgErro) {
        echo 'hideMsgAguardo();';
        echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
        exit();
    }	
    
    foreach ($registros as $r) {
        $nmpessoa = getByTagName($r->tags, 'nmpessoa');
        $idpessoa = getByTagName($r->tags, 'idpessoa');
        $tppessoa = getByTagName($r->tags, 'tppessoa');    
        $nrcpfcgc = getByTagName($r->tags, 'nrcpfcgc');    
            
        echo '$("#nmpessoa","#frmCab").val("'.$nmpessoa.'");';
        echo '$("#idpessoa","#frmCab").val("'.$idpessoa.'");';
        echo '$("#tppessoa","#frmCab").val("'.$tppessoa.'");';
        echo '$("#nrcpfcgc","#frmCab").val("'.$nrcpfcgc.'");';        
    }
    
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
		
?>
