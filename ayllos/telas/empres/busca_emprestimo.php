<?php
	/*********************************************************************************************
	 Fonte: manter_rotina.php
	 Autor: Michel Candido   
	 Data : Novembro/2013    
	 Objetivo  : Executar as Procedures Referentes a tela EMPRES                             
	
	-----------
	Alterações: 11/03/2014 - Ajustes para deixar fonte no padrão, Softdesk - 130006 (Lucas R).
				
				30/12/2014 - Padronizando a mascara do campo nrctremp.
							 10 Digitos - Campos usados apenas para visualização
					         8 Digitos - Campos usados para alterar ou incluir novos contratos
					   	     (Kelvin - SD 233714)

                04/08/2017 - Nao permitir acessar tipo de emprestimo do Pos-Fixado. 
                             (Jaison/James - PRJ298)

	********************************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	// Verifica Permiss&atilde;o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);
	}	
	
	// Verifica se os par&acirc;metros necess&aacute;rios foram informados
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = (isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : '');
	$nrctremp = (isset($_POST["nrctremp"]) ? $_POST["nrctremp"] : '');
	$dtcalcul = (isset($_POST["dtcalcul"]) ? $_POST["dtcalcul"] : '');
	$busca    = (isset($_POST["busca"]) ? $_POST["busca"] : '');
	
	$procedure = null;
	switch($busca){
		case 'contrato': $procedure = 'Busca_Contrato';break; 
		case 'emprestimo':  $procedure = 'Busca_Emprestimo'; break; 
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "	    <Bo>b1wgen0165.p</Bo>";
	$xmlSetPesquisa .= "        <Proc>{$procedure}</Proc>";
	$xmlSetPesquisa .= "  </Cabecalho>";
	$xmlSetPesquisa .= "  <Dados>";
	$xmlSetPesquisa .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetPesquisa .= "        <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetPesquisa .= "        <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetPesquisa .= "        <idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetPesquisa .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetPesquisa .= "        <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetPesquisa .= "        <idseqttl>".$glbvars["idseqttl"]."</idseqttl>";
	$xmlSetPesquisa .= "        <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetPesquisa .= "        <dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";	
	$xmlSetPesquisa .= "        <cdprogra>".$glbvars["cdprogra"]."</cdprogra>";
	$xmlSetPesquisa .= "        <inproces>".$glbvars["inproces"]."</inproces>";
	$xmlSetPesquisa .= "        <flgerlog>".$glbvars["flgerlog"]."</flgerlog>";
	$xmlSetPesquisa .= "        <flgcondc>".$glbvars["flgcondc"]."</flgcondc>";
	$xmlSetPesquisa .= "        <flgempt0>YES</flgempt0>"; /* listar apenas tpemprst 0 */
	$xmlSetPesquisa .= "        <nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetPesquisa .= "        <dtcalcul>".$dtcalcul."</dtcalcul>";
	$xmlSetPesquisa .= "        <nrctremp>".$nrctremp."</nrctremp>";
	$xmlSetPesquisa .= "  </Dados>";
	$xmlSetPesquisa .= "</Root>";
	
	$xmlResult = getDataXML($xmlSetPesquisa );
	$xmlObjPesquisa = getObjectXML($xmlResult);
	
	$nomeCampo = $xmlObjPesquisa->roottag->tags[0]->attributes['NMDCAMPO'];	
	$nomeform  = 'frmCab';
	
		// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") {
		$msgErro	= $xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata;
	
		if ( $nomeCampo != '' ) {  
			$mtdErro = 'focaCampoErro(\''.$nomeCampo.'\',\''.$nomeform.'\');';
		} else {
		  $mtdErro = 'hideMsgAguardo();';
		}
		  $erros = exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
	}	
	
	$pesquisa = $xmlObjPesquisa->roottag->tags[0]->tags[0];
		
	$cdtipsfx  = getByTagName($pesquisa->tags,'cdtipsfx');
	
	$nmprimtl  = getByTagName($pesquisa->tags,'nmprimtl');
	
	/* Campos Busca Emprestimo */
	$cdpesqui  = getByTagName($pesquisa->tags,'cdpesqui');
	$vlemprst  = formataMoeda(getByTagName($pesquisa->tags,'vlemprst'));
	$txdjuros  = number_format(str_replace(',','.',getByTagName($pesquisa->tags,'txdjuros')),7,',','.');            
	$vlsdeved  = formataMoeda(getByTagName($pesquisa->tags,'vlsdeved'));
	$vljurmes  = formataMoeda(getByTagName($pesquisa->tags,'vljurmes'));
	$vlpreemp  = formataMoeda(getByTagName($pesquisa->tags,'vlpreemp'));
	$vljuracu  = formataMoeda(getByTagName($pesquisa->tags,'vljuracu'));
	$vlprepag  = formataMoeda(getByTagName($pesquisa->tags,'vlprepag'));
	$qtmesdec  = getByTagName($pesquisa->tags,'qtmesdec');
	$dsdpagto  = getByTagName($pesquisa->tags,'dsdpagto');
	$vlpreapg  = formataMoeda(getByTagName($pesquisa->tags,'vlpreapg'));
	$qtprecal  = number_format(getByTagName($pesquisa->tags,'qtprecal'), 4, ',', '');
	$dslcremp  = getByTagName($pesquisa->tags,'dslcremp');
	$qtpreapg  = number_format(getByTagName($pesquisa->tags,'qtpreapg'), 4, ',', '');
	$dsfinemp  = getByTagName($pesquisa->tags,'dsfinemp');
	$nrctaav1  = getByTagName($pesquisa->tags,'nrctaav1');
	$cpfcgc1  = getByTagName($pesquisa->tags,'cpfcgc1');
	$nmdaval1  = getByTagName($pesquisa->tags,'nmdaval1');
	$nrraval1  = getByTagName($pesquisa->tags,'nrraval1');
	$nrctaav2  = getByTagName($pesquisa->tags,'nrctaav2');
	$cpfcgc2  = getByTagName($pesquisa->tags,'cpfcgc2');
	$nmdaval2  = getByTagName($pesquisa->tags,'nmdaval2');
	$nrraval2  = getByTagName($pesquisa->tags,'nrraval2');	
	
	/* Campos Busca Emprestimo */		
	
	$registros = $xmlObjPesquisa->roottag->tags[1]->tags[0];
	$nrctremp = null;
	
	$nrctremp = mascara(getByTagName($registros->tags, 'nrctremp'),'#.###.###.###');

	/* Desabilita campo Data e Numero do Contrato */
	echo "$('#nrctremp','#frmCab').desabilitaCampo(); $('#dtAte','#frmCab').desabilitaCampo()";

	if($busca == "emprestimo") {
		echo "
			$('#cdpesqui','#frmEmprestimo').val('{$cdpesqui}');
			$('#vlemprst','#frmEmprestimo').val('{$vlemprst}');
			$('#txdjuros','#frmEmprestimo').val('{$txdjuros}');
			$('#vlsdeved','#frmEmprestimo').val('{$vlsdeved}');
			$('#vljurmes','#frmEmprestimo').val('{$vljurmes}');
			$('#vlpreemp','#frmEmprestimo').val('{$vlpreemp}');
			$('#vljuracu','#frmEmprestimo').val('{$vljuracu}');
			$('#vlprepag','#frmEmprestimo').val('{$vlprepag}');
			$('#qtmesdec','#frmEmprestimo').val('{$qtmesdec}');
			$('#dsdpagto','#frmEmprestimo').val('{$dsdpagto}');
			$('#vlpreapg','#frmEmprestimo').val('{$vlpreapg}');
			$('#qtprecal','#frmEmprestimo').val('{$qtprecal}');
			$('#dslcremp','#frmEmprestimo').val('{$dslcremp}');
			$('#qtpreapg','#frmEmprestimo').val('{$qtpreapg}');
			$('#dsfinemp','#frmEmprestimo').val('{$dsfinemp}');
			$('#nrctaav1','#frmEmprestimo').val('{$nrctaav1}');
			$('#cpfcgc1','#frmEmprestimo').val('{$cpfcgc1}');
			$('#nmdaval1','#frmEmprestimo').val('{$nmdaval1}');
			$('#nrraval1','#frmEmprestimo').val('{$nrraval1}');
			$('#nrctaav2','#frmEmprestimo').val('{$nrctaav2}');
			$('#cpfcgc2','#frmEmprestimo').val('{$cpfcgc2}');
			$('#nmdaval2','#frmEmprestimo').val('{$nmdaval2}');
			$('#nrraval2','#frmEmprestimo').val('{$nrraval2}');
			$('#btVoltar','#divBotoes').show();
			$('#frmEmprestimo').css({'display':'block'});
			$('#btSalvar','#divBotoes').hide();";
	} else {
		echo "
		$('#cdtipsfx','#frmCab').val('{$cdtipsfx}');
		$('#nmprimtl','#frmCab').val('{$nmprimtl}');
		$('#nrctremp','#frmCab').val('{$nrctremp}').habilitaCampo();
		$('#dtAte','#frmCab').habilitaCampo().focus();
		$('#nrdconta','#frmCab').desabilitaCampo();
		$('#btVoltar','#divBotoes').show();
		";
	} 
?>