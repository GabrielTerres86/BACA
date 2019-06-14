<?php
	/*!
	 * FONTE        : buscar_lancamento_excluir.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 29/09/2015
	 * OBJETIVO     : Rotina para buscar o último lançamento de pagamento de benefício de INSS para exclusão manual
	 * --------------
	 * ALTERAÇÕES   : 16/10/2010 - Ajustes para liberação (Adriano).
	 * -------------- 
	                  16/02/2016 - Ajustes para corrigir o problema de não conseguir carregar
                                   corretamente as informações para opção "E"
                                  (Adriano - SD 402006)
	 */		

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$cddotipo = isset($_POST["cddotipo"]) ? $_POST["cddotipo"] : "";
	$cdcooper = isset($_POST["cdcooper"]) ? $_POST["cdcooper"] : "";
	$nrdconta = isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : "";
	
	if ( $cddotipo == "E" ) {
		if ( $cdcooper == "" || $cdcooper == 0) {
			exibirErro('error','Cooperativa n&atilde;o informada.','Alerta - Ayllos','$(\'input,select\',\'#frmExcluirLancamento\').habilitaCampo();focaCampoErro(\'cdcooper\',\'frmExcluirLancamento\');',false);
		}

		if ( $nrdconta == "" || $nrdconta == 0) {
			exibirErro('error','Conta n&atilde;o informada.','Alerta - Ayllos','$(\'input,select\',\'#frmExcluirLancamento\').habilitaCampo();focaCampoErro(\'nrdconta\',\'frmExcluirLancamento\');',false);
		}
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcopcon>" . $cdcooper . "</cdcopcon>";
	$xml .= "    <nrdconta>" . $nrdconta . "</nrdconta>";
	$xml .= "    <cddotipo>" . $cddotipo . "</cddotipo>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PRCINS", "BUSCAR_LANCAMENTO_EXCLUIR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		

	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "cddotipo";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		if ( $cddotipo == "E" ){
			exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input,select\',\'#frmExcluirLancamento\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmExcluirLancamento\');',false);
			
		}else{
			exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'select\',\'#frmExcluirLancamento\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmExcluirLancamento\');',false);
		}
	}
		 	
	if ( $cddotipo == "T" ){
		
		// Se for a exclusão de TODOS os lançamento
		// Mostra mensagem de quantidade e solicita confirmação
		echo "showConfirmacao('Deseja excluir os \'". getByTagName($xmlObj->roottag->tags[0]->tags,'qtlanmto')."\' lan&ccedil;amentos de pagamento dos beneficios do dia de hoje?','Confirma&ccedil;&atilde;o - Ayllos','processaExcluirLancamento();','$(\'select\',\'#frmExcluirLancamento\').habilitaCampo();','sim.gif','nao.gif');";
	
	} else {
		
		$qtdtotal = number_format(str_replace(',','',$xmlObj->roottag->tags[0]->attributes['QTDTOTAL']),0,',','.');	
		$vlrtotal = number_format(str_replace(',','',$xmlObj->roottag->tags[0]->attributes['VLRTOTAL']),0,',','.');	
	
		echo "strHTML  = '<div class=\"divRegistros\">';";
		echo "strHTML += '  <table>';";
		echo "strHTML += '     <thead>';";
		echo "strHTML += '       <tr>';";		
		echo "strHTML += '	    	<th>Cooperativa</th>';";
		echo "strHTML += '	    	<th>Conta</th>';";
		echo "strHTML += '	    	<th>Data</th>';";
		echo "strHTML += '	    	<th>Historico</th>';";
		echo "strHTML += '	    	<th>N&ordm; Documento</th>';";
		echo "strHTML += '	    	<th>Valor</th>';";
		echo "strHTML += '	   </tr>';";
		echo "strHTML += '     </thead>';";
		echo "strHTML += '     <tbody>';";		
		
		// Percorrer todos os lançamentos
		foreach($xmlObj->roottag->tags[0]->tags as $lanmto){
			
			echo "strHTML += '<tr>';";	
			echo "strHTML += '   <td><span>".getByTagName($lanmto->tags,'nmrescop')."</span>".getByTagName($lanmto->tags,'nmrescop')."</td>';";
			echo "strHTML += '   <td><span>".getByTagName($lanmto->tags,'nrdconta')."</span>".getByTagName($lanmto->tags,'nrdconta')."</td>';";
			echo "strHTML += '   <td><span>".getByTagName($lanmto->tags,'dtmvtolt')."</span>".getByTagName($lanmto->tags,'dtmvtolt')."</td>';";			
			echo "strHTML += '   <td><span>".getByTagName($lanmto->tags,'dshistor')."</span>".getByTagName($lanmto->tags,'dshistor')."</td>';";
			echo "strHTML += '   <td><span>".getByTagName($lanmto->tags,'nrdocmto')."</span>".getByTagName($lanmto->tags,'nrdocmto')."</td>';";
			echo "strHTML += '   <td><span>".number_format(str_replace(',','',getByTagName($lanmto->tags,'vllanmto')),2,',','.')."</span>".number_format(str_replace(',','',getByTagName($lanmto->tags,'vllanmto')),2,',','.')."</td>';";
			
			echo "strHTML += '   <input type=\'hidden\' id=\'cdcooper\' name=\'cdcooper\' value=\'".getByTagName($lanmto->tags,'cdcooper')."\' />   ';";
			echo "strHTML += '   <input type=\'hidden\' id=\'nrdconta\' name=\'nrdconta\' value=\'".getByTagName($lanmto->tags,'nrdconta')."\' />   ';";
			echo "strHTML += '   <input type=\'hidden\' id=\'nrdocmto\' name=\'nrdocmto\' value=\'".getByTagName($lanmto->tags,'nrdocmto')."\' />   ';";
			echo "strHTML += '</tr>';";
			
		}
		
		echo "strHTML += '    </tbody>';";
		echo "strHTML += '  </table>';";
		echo "strHTML += '</div>';";
		echo "strHTML += '<div id=\"divRegistrosRodape\" class=\"divRegistrosRodape\">';";
		echo "strHTML += '   <table>';";	
		echo "strHTML += '     <tr>';";
		echo "strHTML += '        <td>';";
		echo "strHTML += '		  </td>';";
		echo "strHTML += '	      <td>';";
		echo "strHTML += '	         Total: ".$qtdtotal." - R$ ".$vlrtotal."';";
		echo "strHTML += '        </td>';";
		echo "strHTML += '        <td>';";
		echo "strHTML += '        </td>';";
		echo "strHTML += '     </tr>';";
		echo "strHTML += '   </table>';";
		echo "strHTML += '</div>';";
		
		echo "$('#divExcluir','#frmExcluirLancamento').html(strHTML);";
		echo "$('#divExcluir','#frmExcluirLancamento').css('display','block');"; 
		echo "$('#fsetExcluirLancamentos','#frmExcluirLancamento').css('display','block');";
		echo "$('#btProsseguir', '#divBotoes').css({ 'display': 'none' });";
		echo "$('#btConcluir', '#divBotoes').css({ 'display': 'inline' });";
		echo "formataTabelaExcluirLancamento();";						
				
	}
	
?>