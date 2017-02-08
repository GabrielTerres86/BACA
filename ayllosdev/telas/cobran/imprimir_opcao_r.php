<?
/*!
 * FONTE        : imprimir_opcao_r.php
 * CRIA��O      : Rog�rius Milit�o (DB1)
 * DATA CRIA��O : 29/02/2012
 * OBJETIVO     : Faz as impress�es da tela COBRAN	
 * --------------
 * ALTERA��ES   : 30/12/2015 - Altera��es Referente Projeto Negativa��o Serasa (Daniel)	
 *				  
 *				  04/08/2016 - Adicionado parametro cddemail na chamada da procedure gera_relatorio. (Reinert)
 * 
 *                17/01/2016 - Alterado para incluir campo Status SMS. PRJ319 - SMS Cobran�a (Odirlei-AMcom)  
 * -------------- 
 */
?>

<? 
	
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$_POST['cddopcao'])) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	
	
	$c 			= array('.', '-'); 
	
	// Recebe as variaveis
	$dsiduser 	= session_id();	
	$cddopcao	= $_POST['cddopcao'];
	$tprelato	= $_POST['tprelato'];
	$inidtmvt	= $_POST['inidtmvt'];
	$fimdtmvt	= $_POST['fimdtmvt'];
	$cdstatus	= $_POST['cdstatus'];
	$nrdconta	= str_ireplace($c, '',$_POST['nrdconta']);	
	$nmprimtl	= $_POST['nmprimtl'];
	$cdagencx	= $_POST['cdagenci'];
	$inserasa	= $_POST['inserasa'];

        $xml = new XmlMensageria();
        $xml->add('nrdconta',$nrdconta);
        $xml->add('dtiniper',$inidtmvt);
        $xml->add('dtfimper',$fimdtmvt);
        $xml->add('dsiduser',$dsiduser);
        $xml->add('instatus',$instatussms);

        $xmlResult = mensageria($xml, "COBRAN", "RELAT_ENVIO_SMS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObject = getObjectXML($xmlResult);

        if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
			$msg = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
			?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
			exit();
		}

        // Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
        $nmarqpdf = $xmlObject->roottag->tags[0]->tags[0]->cdata;

    }else {    
     
	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0010.p</Bo>';
	$xml .= '		<Proc>gera_relatorio</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<cdprogra>'.$glbvars['cdprogra'].'</cdprogra>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<nmprimtl>'.$nmprimtl.'</nmprimtl>';
	$xml .= '		<tprelato>'.$tprelato.'</tprelato>';
	$xml .= '		<inidtper>'.$inidtmvt.'</inidtper>';
	$xml .= '		<fimdtper>'.$fimdtmvt.'</fimdtper>';
	$xml .= '		<cdstatus>'.$cdstatus.'</cdstatus>';
	$xml .= '		<cdagencx>'.$cdagencx.'</cdagencx>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<inserasa>'.$inserasa.'</inserasa>';
	$xml .= '		<cddemail>0</cddemail>';
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
    
	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);
	
		// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	} 
	
	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjDados->roottag->tags[0]->attributes["NMARQPDF"];
	}
	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	
?>