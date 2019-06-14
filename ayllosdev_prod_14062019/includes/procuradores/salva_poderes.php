<?php
	/*!
	 * FONTE        : salva_poderes.php
	 * CRIAÇÃO      : Jean Michel
	 * DATA CRIAÇÃO : 08/07/2013 
	 * OBJETIVO     : Salva dados referente aos poderes de Representantes/Procuradores
	 *
	 * ALTERACOES   : 01/02/2018 - Adicionado idseqttl que estva fixo 0. (Lombardi)  
	 *
	 */
	
	session_start();
	require_once("../config.php");
	require_once("../funcoes.php");
	require_once('../controla_secao.php');
	require_once('../../class/xmlfile.php');

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '';
	$nrdctato = (isset($_POST['nrdctato'])) ? $_POST['nrdctato'] : '';
	$arrpoder = (isset($_POST['strPoderes'])) ? $_POST['strPoderes'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : 0;
	
	$arrAuxPoderes = explode("/",$arrpoder);
	
	foreach($arrAuxPoderes as $poderes){
		$arrPrincipal = explode(",", $poderes);

		$arrPoderes[$arrPrincipal[0]]['cddpoder'] = $arrPrincipal[0];
		$arrPoderes[$arrPrincipal[0]]['flgconju'] = $arrPrincipal[1];
		$arrPoderes[$arrPrincipal[0]]['flgisola'] = $arrPrincipal[2];
		$arrPoderes[$arrPrincipal[0]]['dsoutpod'] = $arrPrincipal[3];
	}
	
	/** XML p/ salvar dados **/
	
	$xmlSalvaPoderes  = "";
	$xmlSalvaPoderes .= "<Root>";
	$xmlSalvaPoderes .= "	<Cabecalho>";
	$xmlSalvaPoderes .= "		<Bo>b1wgen0058.p</Bo>";
	$xmlSalvaPoderes .= "		<Proc>grava_dados_poderes</Proc>";
	$xmlSalvaPoderes .= "	</Cabecalho>";
	$xmlSalvaPoderes .= "	<Dados>";
	$xmlSalvaPoderes .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xmlSalvaPoderes .= '		<nrdctpro>'.$nrdctato.'</nrdctpro>';
	$xmlSalvaPoderes .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xmlSalvaPoderes .= '		<cpfprocu>'.$nrcpfcgc.'</cpfprocu>';		
	$xmlSalvaPoderes .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xmlSalvaPoderes .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xmlSalvaPoderes .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xmlSalvaPoderes .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xmlSalvaPoderes .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xmlSalvaPoderes .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xmlSalvaPoderes .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	
	foreach($arrPoderes as $chave => $valor ){
		$xmlSalvaPoderes .= "<Poderes>";
		$xmlSalvaPoderes .= "	<Poder>";
		$xmlSalvaPoderes .= "		<cddpoder>".$valor['cddpoder']."</cddpoder>";
		$xmlSalvaPoderes .= "		<flgisola>".$valor['flgisola']."</flgisola>";
		$xmlSalvaPoderes .= "		<flgconju>".$valor['flgconju']."</flgconju>";
		$xmlSalvaPoderes .= "		<dsoutpod>".$valor['dsoutpod']."</dsoutpod>";
		$xmlSalvaPoderes .= "	</Poder>";
		$xmlSalvaPoderes .= "</Poderes>";
	}	
	
	$xmlSalvaPoderes .= "	</Dados>";
	$xmlSalvaPoderes .= "</Root>";	
	 
	$xmlResultSalvaPoderes = getDataXML($xmlSalvaPoderes);
	
	$xmlObjetoSalvaPoderes = getObjectXML($xmlResultSalvaPoderes);	
	
	$xmlObjeto = $xmlObjetoSalvaPoderes->roottag->tags[0]->tags;	
	
	
	// Se ocorrer um erro, mostra crítica
	if ($xmlObjeto[0]->tags[4]->cdata != "") {		
		exibirErro('error',$xmlObjeto[0]->tags[4]->cdata,'Alerta - Aimaro',$metodo,false);
	}else if(strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO'){
		
		if ( $operacao_proc == 'IB' ) { 
			$metodo = 'bloqueiaFundo(divRotina);controlaOperacaoProc(\'TI\');';
		} else {
			$metodo = 'bloqueiaFundo(divRotina);controlaOperacaoProc();';
		}
		
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$metodo,false);
	}
	
?>