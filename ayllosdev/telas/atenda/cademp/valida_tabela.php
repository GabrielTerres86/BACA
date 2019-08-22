<?php
/*!
 * FONTE        : valida_tabela.php
 * CRIAÇÃO      : Michel Candido Gati Tecnologia
 * DATA CRIAÇÃO : 21/08/2013 
 *
 * ALTERAÇÕES   : 11/06/2014 - Tratar valor do dtfchfol para formatar com dois dígitos (Douglas - Chamado 122814)
 *
 *                19/01/2015 - Retirando a atualizacao do campo dtfchfol pois o mesmo nao retornava registro
 *                             e substitua o valor atual da exibicao do campo (Andre Santos - SUPERO)
 *
 *				  28/07/2016 - Corrigi a utilizacao da variavel cdbccxlt. SD 491925. (Carlos R.)
 */
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	
    
    $cddopcao = $_POST['cddopcao'];
    
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	
	function dadosCampos($cdacesso,$glbvars, $tpTabela =  'GENERI'){
		
		$cdbccxlt = ( isset($glbvars["cdbccxlt"]) ) ? $glbvars["cdbccxlt"] : '';
		$cdcooper = ( isset($glbvars["cdcooper"]) ) ? $glbvars["cdcooper"] : '';
		$cdagenci = ( isset($glbvars["cdagenci"]) ) ? $glbvars["cdagenci"] : '';
		$nrdcaixa = ( isset($glbvars["nrdcaixa"]) ) ? $glbvars["nrdcaixa"] : '';
		$cdoperad = ( isset($glbvars["cdoperad"]) ) ? $glbvars["cdoperad"] : '';
		$dtmvtolt = ( isset($glbvars["dtmvtolt"]) ) ? $glbvars["dtmvtolt"] : '';
		$idorigem = ( isset($glbvars["idorigem"]) ) ? $glbvars["idorigem"] : '';
		$nmdatela = ( isset($glbvars["nmdatela"]) ) ? $glbvars["nmdatela"] : '';
		$cdprogra = ( isset($glbvars["cdprogra"]) ) ? $glbvars["cdprogra"] : '';

		if($tpTabela ==  'GENERI'){
			$xml  = "";
			$xml .= "<Root>";
			$xml .= "  <Cabecalho>";
			$xml .= "	    <Bo>b1wgen0166.p</Bo>";
			$xml .= "        <Proc>Busca_tabela</Proc>";
			$xml .= "  </Cabecalho>";
			$xml .= "  <Dados>";
			$xml .= "        <cdcooper>".$cdcooper."</cdcooper>";
			$xml .= "        <cdagenci>".$cdagenci."</cdagenci>";
			$xml .= "        <nrdcaixa>".$nrdcaixa."</nrdcaixa>";
			$xml .= "        <cdoperad>".$cdoperad."</cdoperad>";
			$xml .= "        <dtmvtolt>".$dtmvtolt."</dtmvtolt>";
			$xml .= "        <idorigem>".$idorigem."</idorigem>";
			$xml .= "        <nmdatela>".$nmdatela."</nmdatela>";
			$xml .= "        <cdprogra>".$cdprogra."</cdprogra>";
			$xml .= "        <cdbccxlt>".$cdbccxlt."</cdbccxlt>";
			$xml .= '       <nmsistem>CRED</nmsistem>';
			$xml .= '       <tptabela>GENERI</tptabela>';
			$xml .= '       <cdempres>00</cdempres>';
			$xml .= '       <cdacesso>'.$cdacesso.'</cdacesso>';
			$xml .= '       <tpregist>'.$_POST['cdempres'].'</tpregist>';
			$xml .= "  </Dados>";
			$xml .= "</Root>";
		}else{
			$xml  = "";
			$xml .= "<Root>";
			$xml .= "  <Cabecalho>";
			$xml .= "	    <Bo>b1wgen0166.p</Bo>";
			$xml .= "        <Proc>Busca_tabela</Proc>";
			$xml .= "  </Cabecalho>";
			$xml .= "  <Dados>";
			$xml .= "        <cdcooper>".$cdcooper."</cdcooper>";
			$xml .= "        <cdagenci>".$cdagenci."</cdagenci>";
			$xml .= "        <nrdcaixa>".$nrdcaixa."</nrdcaixa>";
			$xml .= "        <cdoperad>".$cdoperad."</cdoperad>";
			$xml .= "        <dtmvtolt>".$dtmvtolt."</dtmvtolt>";
			$xml .= "        <idorigem>".$idorigem."</idorigem>";
			$xml .= "        <nmdatela>".$nmdatela."</nmdatela>";
			$xml .= "        <cdprogra>".$cdprogra."</cdprogra>";
			$xml .= "        <cdbccxlt>".$cdbccxlt."</cdbccxlt>";
			$xml .= '       <nmsistem>CRED</nmsistem>';
			$xml .= '       <tptabela>USUARI</tptabela>';
			$xml .= '       <cdempres>'.$_POST['cdempres'].'</cdempres>';
			$xml .= '       <cdacesso>'.$cdacesso.'</cdacesso>';
			$xml .= '       <tpregist>001</tpregist>';
			$xml .= "  </Dados>";
			$xml .= "</Root>";
		}
		
		
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xml);
		
				
		// Cria objeto para classe de tratamento de XML
		$xmlObj = getObjectXML($xmlResult);
		
		
		if ( isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
		}

		$registros = ( isset($xmlObj->roottag->tags[0]->tags) ) ? $xmlObj->roottag->tags[0]->tags : array();
		
		return $registros;
	}
	 
	if(isset($_POST['cdempres'])){
		
		
		$registros = dadosCampos('DIADOPAGTO',$glbvars);
		
		foreach($registros as $r){
			$field = getByTagName($r->tags,'dstextab');
			$ddmesnov = substr($field,0,2);
			$ddpgtmes = substr($field,3,2);
			$ddpgthor = substr($field,6,2);
		}
		
		$registros = dadosCampos('NUMLOTEFOL',$glbvars);
		
		foreach($registros as $r){
			$nrlotfol  = getByTagName($r->tags,'dstextab');
		}
		
		
		
		$registros = dadosCampos('NUMLOTEEMP',$glbvars);
		
		foreach($registros as $r){
			$nrlotemp    = getByTagName($r->tags,'dstextab');
		}
		
		
		$registros = dadosCampos('NUMLOTECOT',$glbvars);
		
		foreach($registros as $r){
			$nrlotcot     = getByTagName($r->tags,'dstextab');
		}
		
		$registros = dadosCampos('VLTARIF008',$glbvars, 'USUARI');
		
		foreach($registros as $r){;
			$vltrfsal   = str_replace(array(',','.'),'',getByTagName($r->tags,'dstextab'));
			$vltrfsal    = substr($vltrfsal,0,-2).','.substr($vltrfsal,-2);
		
		}
	}
		// Recebe as mensagens de erro
	$avisos = '';
	if (!isset($vltrfsal)) {
		$avisos .= 'Falta tabela com a tarifa para credito de sal&aacute;rio.<br>';
	}
	if (!isset($ddpgtmes)){
		$avisos .= 'Falta tabela referente aos dias de pagamento.<br>';
	} 

	if (!isset($nrlotfol)){
		$avisos .= 'Falta tabela com numero de lote para folha.<br>';
	}

	if (!isset($nrlotemp)){
		$avisos .= 'Falta tabela com n&uacute;mero de lote para empr&eacute;stimo.<br>';
	}
	
	if (!isset($nrlotcot)){
		$avisos .= 'Falta tabela com n&uacute;mero de lote para cotas.';
	}
	
	if($avisos){
		$avisos = '<p align="left">'.$avisos.'</p>';
		echo "blockBackground();";
		echo "showError('error', '{$avisos}','Alerta - Ayllos','unblockBackground()');";
	}

	echo "
		cDdmesnov.val('{$ddmesnov}');
		cDdpgtmes.val('{$ddpgtmes}');
		cDdpgthor.val('{$ddpgthor}');
		cNrlotfol.val('{$nrlotfol}');
		cNrlotemp.val('{$nrlotemp}');
		cNrlotcot.val('{$nrlotcot}');
		cVltrfsal.val('{$vltrfsal}');
		old_cDdmesnov = '{$ddmesnov}';
		old_cDdpgtmes = '{$ddpgtmes}';
		old_cDdpgthor = '{$ddpgthor}';
		old_cNrlotfol = '{$nrlotfol}';
		old_cNrlotemp = '{$nrlotemp}';
		old_cNrlotcot = '{$nrlotcot}';
		old_cVltrfsal = '{$vltrfsal}';
				
	";

?>