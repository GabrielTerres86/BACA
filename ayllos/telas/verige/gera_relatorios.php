<? 
/*!
 * FONTE        : gera_relatorios.php
 * CRIAÇÃO      : Carlos        
 * DATA CRIAÇÃO : Novembro/2013
 * OBJETIVO     : Rotina para geração de relatorios da tela VERIGE.
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
	
	// Inicializa
	$retornoAposErro = '';
	
	
	// Recebe a operação que está sendo realizada
	$cddopcao      = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$cdagenci      = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0  ;
	$nrdconta      = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	
	$sidlogin      = (isset($_POST['sidlogin'])) ? $_POST['sidlogin'] : 0  ;
	
	$retornoAposErro = 'focaCampoErro(\'nrdconta\', \'frmCab\');';
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0138.p</Bo>';
	$xml .= '		<Proc>relatorio_gp</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<tprelato>'.$tprelato.'</tprelato>';
	$xml .= '		<telcdage>'.$telcdage.'</telcdage>';
	$xml .= '		<dtiniper>'.$dtiniper.'</dtiniper>';
	$xml .= '		<dtfimper>'.$dtfimper.'</dtfimper>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if ( !empty($nmdcampo) ) { $mtdErro = $mtdErro . " $('#".$nmdcampo."').focus();";  } ?>
		<script language="javascript">
			alert("<?php echo $msgErro ?>");
		</script><?php
		exit();
	}	

	$nmarqpdf = $xmlObjeto->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	
?>