<?php 
   /*!
	* FONTE        : busca_contas_emp.php
	* CRIAÇÃO      : Andre Santos - SUPERO
	* DATA CRIAÇÃO : 17/07/2015
	* OBJETIVO     : Tela de Pesquisa de Associados
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
	$nmprimtl	= (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '';
	$cdempres	= (isset($_POST['cdempres'])) ? $_POST['cdempres'] : 1;
	$cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';

	//remove & (e comercial) da descricao da empresa filtrada
	$pattern = '/(&){1,}/';
	$replacement = '';
	$nmprimtl = preg_replace($pattern, $replacement, $nmprimtl);
	
	$retornoAposErro = 'estadoInicial();';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0166.p</Bo>';
	$xml .= '		<Proc>Busca_Conta_Emp</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '       <nmprimtl>'.$nmprimtl.'</nmprimtl>';
	$xml .= '       <cdempres>'.$cdempres.'</cdempres>';
	$xml .= '       <cdopcao>'.$cddopcao.'</cdopcao>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	

		$msgErro	= ( isset($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata) ) ? $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata : '';
		$nmdcampo	= ( isset($xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO']) ) ? $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'] : '';

		if ($nrdconta==0){
			if (!empty($nmdcampo)) { $mtdErro = " $('#nmprimtl','#frmContaEmp').focus();bloqueiaFundo( $(\'#divRotina\') );"; }
		}else{
			$mtdErro = " $('#nrdconta','#frmInfEmpresa').focus();$('#nrdconta','#frmInfEmpresa').val('');$('#nmextttl','#frmInfEmpresa').val('');";			
		}

		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);		
	} 
	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	
	if ($nrdconta==0){
		include ('tab_conta_emp.php');
	}else{
		echo "<script>$('#nmextttl','#frmInfEmpresa').val('".getByTagName($registros[0]->tags,'nmpesttl')."');</script>";
		echo "<script>buscaDadosCooperado();</script>";
	}

?>