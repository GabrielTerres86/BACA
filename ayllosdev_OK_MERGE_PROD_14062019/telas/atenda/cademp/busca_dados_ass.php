<?php
	/*!
	* FONTE        : busca_contas_ass.php
	* CRIAÇÃO      : Andre Santos - SUPERO
	* DATA CRIAÇÃO : 17/07/2015
	* OBJETIVO     : Tela de Pesquisa de Associados
	* 
	* ALTERACAO    : 28/07/2016 - Corrigi o uso de variaveis do array $glbvars. SD 491925 (Carlos R.)
	*/	 

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$nrdconta	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '0';
	
	$retornoAposErro = '';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0166.p</Bo>';
	$xml .= '		<Proc>busca_dados_associado</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<cdprogra>'.$glbvars['cdprogra'].'</cdprogra>';
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);	
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	

		$msgErro	= ( isset($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata) ) ? $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata : '';
		$nmdcampo	= ( isset($xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO']) ) ? $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'] : '';

		if (!empty($nmdcampo)) { $mtdErro = " $('#nrdconta','#frmInfEmpresa').focus();$('#nrdconta','#frmInfEmpresa').val('');$('#nmextttl','#frmInfEmpresa').val('');"; }

		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);		
	} 
	
	$associado = ( isset($xmlObjeto->roottag->tags[0]->tags) ) ? $xmlObjeto->roottag->tags[0]->tags : array();
	
	echo "hideMsgAguardo();";
    
    echo "if (($('#nmextemp','#frmInfEmpresa').val()=='' && opcao=='C') || opcao=='S') { $('#nmextemp','#frmInfEmpresa').val('".getByTagName($associado[0]->tags,'nmrazsoc')."'); }";
    echo "if (($('#nmresemp','#frmInfEmpresa').val()=='' && opcao=='C') || opcao=='S') { $('#nmresemp','#frmInfEmpresa').val('".substr(getByTagName($associado[0]->tags,'nmfansia'),0,15)."'); }";
	echo "if (($('#nmcontat','#frmInfEmpresa').val()=='' && opcao=='C') || opcao=='S') { $('#nmcontat','#frmInfEmpresa').val('".getByTagName($associado[0]->tags,'nmcontat')."'); }";
	echo "if ((($('#nrdocnpj','#frmInfEmpresa').val()=='' || normalizaNumero($('#nrdocnpj','#frmInfEmpresa').val())==0) && opcao=='C') || opcao=='S') { $('#nrdocnpj','#frmInfEmpresa').val('".formatar(getByTagName($associado[0]->tags,'nrcpfcgc'), 'cnpj')."'); }";
	echo "if (($('#dsendemp','#frmInfEmpresa').val()=='' && opcao=='C') || opcao=='S') { $('#dsendemp','#frmInfEmpresa').val('".getByTagName($associado[0]->tags,'dsendere')."'); }";
	echo "if (($('#nrendemp','#frmInfEmpresa').val()=='' && opcao=='C') || opcao=='S') { $('#nrendemp','#frmInfEmpresa').val('".getByTagName($associado[0]->tags,'nrendere')."'); }";
	echo "if (($('#dscomple','#frmInfEmpresa').val()=='' && opcao=='C') || opcao=='S') { $('#dscomple','#frmInfEmpresa').val('".getByTagName($associado[0]->tags,'complend')."'); }";
	echo "if (($('#nmbairro','#frmInfEmpresa').val()=='' && opcao=='C') || opcao=='S') { $('#nmbairro','#frmInfEmpresa').val('".substr(getByTagName($associado[0]->tags,'nmbairro'),0,15)."'); }";
	echo "if (($('#nmcidade','#frmInfEmpresa').val()=='' && opcao=='C') || opcao=='S') { $('#nmcidade','#frmInfEmpresa').val('".getByTagName($associado[0]->tags,'nmcidade')."'); }";
	echo "if (($('#cdufdemp','#frmInfEmpresa').val()=='' && opcao=='C') || opcao=='S') { $('#cdufdemp','#frmInfEmpresa').val('".getByTagName($associado[0]->tags,'cdufende')."'); }";
	echo "if (($('#nrcepend','#frmInfEmpresa').val()=='' && opcao=='C') || opcao=='S') { $('#nrcepend','#frmInfEmpresa').val('".getByTagName($associado[0]->tags,'nrcepend')."'); }";
	echo "if (($('#dsdemail','#frmInfEmpresa').val()=='' && opcao=='C') || opcao=='S') { $('#dsdemail','#frmInfEmpresa').val('".getByTagName($associado[0]->tags,'dsdemail')."'); }";
?>
