<?php
	/*!
	  FONTE        : manter_resultado.php
	  CRIAÇÃO      : Rodolpho Telmo (DB1)
	  DATA CRIAÇÃO : 23/06/2010 
	  OBJETIVO     : Rotina para unificar a análise do resultado do XML para as operações da tela MATRIC
	  --------------
	  ALTERAÇÕES   : 22/02/2011 - Criada tabela para mostrar os Produtos/Servicos ativos quando o cooperado for deminitdo (Jorge)
 				
 				 31/08/2011 - Realizado a chamada da procedure alerta_fraude (Adriano).
				  
				 11/04/2013 - Retirado a chamada da procedure alerta_fraude (Adriano).
				 
				 20/07/2015 - Reformulacao Cadastral (Gabriel-RKAM).
				
				 18/02/2016 - Ajuste para pedir senha do coordenador quando for duplicar conta. (Jorge/Thiago) - SD 395996

				 27/07/2016 - Corrigi o uso de indices do XML inexistentes.SD 479874 (Carlos R).
				 
				 28/08/2017 - Criando opcao de solicitar relacionamento caso cnpj informado
                              esteja cadastrado na cooperativa. (Kelvin)
					 
	*/
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
	
		$mtdErro	= '';
		$msgErro	= ( isset($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata) ) ? $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata : '';
		$nomeCampo	= ( isset($xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO']) ) ? $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'] : '';
		$nomeForm	= ( $inpessoa == 1 ) ? 'frmFisico' : 'frmJuridico';
		$nomeForm	= ( ($nomeCampo == 'nrdconta') || ($nomeCampo == 'cdagepac') ) ? 'frmCabMatric' : $nomeForm;
		
		// Limpa o sinalizador de erro em todos os campos 
		echo '$(\'input,select\',\'#'.$nomeForm.'\').removeClass(\'campoErro\');';
		
		// Se existe o atributo nome do campo, então ocorreu erro neste campo, portanto focá-lo, caso contrario somente apresentar o erro		
		if ( $nomeCampo != '' ) {
			$mtdErro = 'focaCampoErro(\''.$nomeCampo.'\',\''.$nomeForm.'\')';
		} else {
			$mtdErro = 'unblockBackground()';
		}		
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
	}	
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (isset($xmlObjeto->Erro->Registro->dscritic) && $xmlObjeto->Erro->Registro->dscritic != '') {	
		$msgErro = $xmlObjeto->Erro->Registro->dscritic;
		$mtdErro = 'unblockBackground()';
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
	}
	
	
	
	//----------------------------------------------------------------------------------------------------------------------------------
	// Controle de parcelamento	
	//----------------------------------------------------------------------------------------------------------------------------------
	
	$qtparcel = ( isset($xmlObjeto->roottag->tags[0]->attributes['QTPARCEL']) ) ? $xmlObjeto->roottag->tags[0]->attributes['QTPARCEL'] : '';	
	$vlparcel = ( isset($xmlObjeto->roottag->tags[0]->attributes['VLPARCEL']) ) ? $xmlObjeto->roottag->tags[0]->attributes['VLPARCEL'] : '';
	
	//----------------------------------------------------------------------------------------------------------------------------------
	// Controle de alertas e retornos
	//----------------------------------------------------------------------------------------------------------------------------------
	$msg 		= Array();
	$msgRetorno = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGRETOR']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'] : '';	
	$msgAlertas = ( isset($xmlObjeto->roottag->tags[1]->tags) ) ? $xmlObjeto->roottag->tags[1]->tags : array();	
		
	$msgAlertArray = Array();
	foreach( $msgAlertas as $alerta){
		$msgAlertArray[getByTagName($alerta->tags,'cdalerta')] = getByTagName($alerta->tags,'dsalerta');
	}
	
	$msgAlerta = implode( "|", $msgAlertArray);	
		
	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;
	
			
	//----------------------------------------------------------------------------------------------------------------------------------
	// Controle verificação da revisão Cadastral
	//----------------------------------------------------------------------------------------------------------------------------------	
	$msgAtCad = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGATCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'] : '';
	$msgRecad = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGRECAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGRECAD'] : '';
	$chaveAlt = ( isset($xmlObjeto->roottag->tags[0]->attributes['CHAVEALT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'] : '';
	$tpAtlCad = ( isset($xmlObjeto->roottag->tags[0]->attributes['TPATLCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'] : '';	

	//----------------------------------------------------------------------------------------------------------------------------------
	// Controle remoção da classe erro dos campos
	//----------------------------------------------------------------------------------------------------------------------------------		
	echo '$("input,select","#frmCabMatric").removeClass("campoErro");';
	echo '$("input,select","#frmJuridico").removeClass("campoErro");';		
	echo '$("input,select","#frmFisico").removeClass("campoErro");';		
		
	//----------------------------------------------------------------------------------------------------------------------------------
	// Controle das mensagens de confirmações
	//----------------------------------------------------------------------------------------------------------------------------------			
	if ( $qtparcel > 0 ) { 
		echo 'exibirMsgMatric(\''.$msgAlerta.'\',\''.$msgRetorno.'\',\''.$qtparcel.'\',\''.$vlparcel.'\');';
		return false;	
		
	}
	
	// Se for validacao da inclusao, exibir a nova conta
	if ($operacao == 'IV') {
		
		$nrctanov = ( isset($xmlObjeto->roottag->tags[0]->attributes['NRCTANOV']) ) ? $xmlObjeto->roottag->tags[0]->attributes['NRCTANOV'] : '';
				
		echo '$("#nrdconta","#frmCabMatric").val(' . $nrctanov . ');';
		
		echo "verificaResponsavelLegal();";

		die();	
		
	}
	
	if ( substr($operacao,-1) == 'V') {  
		if ( $msgAlerta != '' ) { 
			echo "hideMsgAguardo();";
			echo 'exibirMsgMatric(\''.$msgAlerta.'\',\''.$msgRetorno.'\');';
			
						
		}else{			
			if(($operacao == 'AV') and ($GLOBALS['dtdemiss'] != '') and (count($xmlObjeto->roottag->tags[2]->tags) > 0)){
				
				$tagsProdServ 	= $xmlObjeto->roottag->tags[2]->tags;	
				$prodservArray = Array();
				
				foreach( $tagsProdServ as $registros){
					$prodservArray[] = getByTagName($registros->tags,'nmproser');
				}
				
				$style 	   = "";
				$aux_table = "";
				
				$aux_table = "<table style='border:2px solid gray;background-color:white;'>";
				$aux_table.= "	<tr><td style='background-color:#E8E8E8;height:20px;'>";
				$aux_table.= "		<span style='margin-left:10px;'>Os Produtos/Servi&ccedil;os est&atilde;o ativos na conta:</span>";
				$aux_table.= "	</td></tr>";
				$aux_table.= "	<tr><td>";
				$aux_table.= "		<div style='height:129px;overflow-x:hidden;overflow-y:scroll;width:280px;text-align:left'>";
				$aux_table.= "		<table style='width:100%'>";
				foreach($prodservArray as $prodserv) {
					if ($style == " style='background-color: #FFFFFF;' ") {
						$style =  " style='background-color: #F0F0F0;' ";
					} else { 
						$style =  " style='background-color: #FFFFFF;' "; 
					}
					$aux_table.= "		<tr ".$style.">";
					$aux_table.= "			<td style='font-weight:bold;'> - ".$prodserv."</td>";
					$aux_table.= "		</tr>";
				}
				$aux_table.= "		</table>";
				$aux_table.= "		</div>";
				$aux_table.= "		</td>";
				$aux_table.= "	</tr>";
				$aux_table.= "</table>";
				
				exibirMensagens('none',$aux_table,'Notifica&ccedil;&atilde;o - MATRIC','showConfirmacao(\''.$msgRetorno.'\', \'Confirma&ccedil;&atilde;o - MATRIC\', \'controlaOperacao(\"VA\")\', \'unblockBackground()\',\'sim.gif\',\'nao.gif\')',false);
				
			}else{
				exibirConfirmacao($msgRetorno,'Confirma&ccedil;&atilde;o - MATRIC','controlaOperacao(\''.'V'.substr($operacao,0,1).'\')','unblockBackground()',false);						
			}			
		}				
	}	
		
		
	if ( substr($operacao,0,1) == 'V') {
	    
		$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '' ;
		$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ; 
		
		$stringArrayMsg = implode( "|", $msg);
		
		if ($operacao == 'VI') {
			$metodo = ($inpessoa == 1) ? "impressao_inclusao();" : "abrirProcuradores();";
		}
		else {
			$metodo = "estadoInicial();";	
		}
				
		$metodoMsg = "exibirMensagens('" . $stringArrayMsg . "','" . $metodo . "')";		
				
		if ( $msgRecad != '' ){
			if ($msgAtCad != '') {
				$metRecad = 'showConfirmacao(\''.$msgAtCad.'\',\'1Confirma&ccedil;&atilde;o - MATRIC\',\'revisaoCadastral(\"'.$chaveAlt.'\",\"'.$tpAtlCad.'\",\"b1wgen0052.p\",\"'.$stringArrayMsg.'\",\"estadoInicial();\")\',\'revisaoCadastral(\"'.$chaveAlt.'\",\"0\",\"b1wgen0052.p\",\"'.$stringArrayMsg.'\",\"estadoInicial();\")\' ,\'sim.gif\',\'nao.gif\');';
			} else {
				$metRecad = 'revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0052.p\',\''.$stringArrayMsg.'\',\'estadoInicial();\');';	
			}
						
			exibirConfirmacao($msgRecad,'Confirmação - MATRIC',$metRecad,$metodoMsg,false); 
						
		}else if ( $msgAtCad != '' ) {
			exibirConfirmacao($msgAtCad,'Confirmação - MATRIC','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0052.p\',\''.$stringArrayMsg.'\',\'estadoInicial();\');',$metodoMsg,false); 
		}else{
			echo $metodoMsg;
		}	
	} 		
	
	if ($operacao == 'LCD') { // Verificar se este CPF/CNPJ ja tem conta
	
		$nomeForm  = ( $inpessoa == 1 ) ? 'frmFisico' : 'frmJuridico';
		$metodoNao = ( $inpessoa == 1 ) ? "$('#dtnasctl','#frmFisico').focus();" : "$('#dtcnscpf','#frmJuridico').focus();";
	
		$flgdpcnt = $xmlObjeto->flgopcao[0]->flgdpcnt;
		
		//Nao fara nada e continuara a acao normalmente
		if ($flgdpcnt == 1) {
			if ($inpessoa == 1) {
				echo "$('#dtnasctl','#frmFisico').focus();";
			}
			else {
				echo "$('#dtcnscpf','#frmJuridico').focus();";
			}
		}
		//Devera solicitar a duplicacao da conta
		else if($flgdpcnt == 2) {
			// Se ja poussui uma conta, perguntar se deseja duplicar 
			if ( count ($xmlObjeto->inf) == 1) {
				$nrdconta_org = $xmlObjeto->inf[0]->nrdconta;
				echo "outconta = '".$nrdconta_org."';";
				$metodoSim = "mostrarRotina('$operacao');";
				exibirConfirmacao('CPF/CNPJ já possui a conta ' . $nrdconta_org . 
								  ' na cooperativa. Deseja efetuar a duplicação?','Confirmação - MATRIC',$metodoSim,$metodoNao,false);
			}
			else 
			if ( count ($xmlObjeto->inf) > 1) { // Se possui mais de uma conta, perguntar se deseja duplicar

				
				$XMLContas = '';
				
				// Juntar todas as contas que o cooperado ja possui
				for ($i=0; $i < count ($xmlObjeto->inf); $i++) {
					
					$XMLContas  = ($XMLContas != '') ? $XMLContas . '|' : '';			
					$XMLContas .=  $xmlObjeto->inf[$i]->nrdconta . ';' . $xmlObjeto->inf[$i]->dtadmiss ;
					
				}
				
				echo "XMLContas = '$XMLContas';";
				$metodoSim = "mostrarRotina('LCC');"; 
				exibirConfirmacao('CPF/CNPJ já possui a conta na cooperativa. Deseja efetuar a duplicação?','Confirmação - MATRIC',$metodoSim,$metodoNao,false);			
			}
		}
		//devera carregar as informacoes nos campos da matric
		else if($flgdpcnt == 3) {
			$dtconsultarfb = $xmlObjeto->infcadastro[0]->dtconsultarfb;
			$nrcpfcgc = $xmlObjeto->infcadastro[0]->nrcpfcgc;
			$cdsituacaoRfb = $xmlObjeto->infcadastro[0]->cdsituacaoRfb;
			$nmpessoa = $xmlObjeto->infcadastro[0]->nmpessoa;
			$nmpessoaReceita = $xmlObjeto->infcadastro[0]->nmpessoaReceita;
			$tpsexo = $xmlObjeto->infcadastro[0]->tpsexo;
			$dtnascimento = $xmlObjeto->infcadastro[0]->dtnascimento;
			$tpdocumento = $xmlObjeto->infcadastro[0]->tpdocumento;
			$nrdocumento = $xmlObjeto->infcadastro[0]->nrdocumento;
			$idorgaoExpedidor = $xmlObjeto->infcadastro[0]->idorgaoExpedidor;
			$cdufOrgaoExpedidor = $xmlObjeto->infcadastro[0]->cdufOrgaoExpedidor;
			$dtemissaoDocumento = $xmlObjeto->infcadastro[0]->dtemissaoDocumento;
			$tpnacionalidade = $xmlObjeto->infcadastro[0]->tpnacionalidade;
			$inhabilitacaoMenor = $xmlObjeto->infcadastro[0]->inhabilitacaoMenor;
			$dthabilitacaoMenor = $xmlObjeto->infcadastro[0]->dthabilitacaoMenor;
			$cdestadoCivil = $xmlObjeto->infcadastro[0]->cdestadoCivil;
			$nmmae = $xmlObjeto->infcadastro[0]->nmmae;
			$nmconjugue = $xmlObjeto->infcadastro[0]->nmconjugue;
			$nmpai = $xmlObjeto->infcadastro[0]->nmpai;
			$naturalidadeDsCidade = $xmlObjeto->infcadastro[0]->naturalidadeDsCidade;
			$naturalidadeCdEstado = $xmlObjeto->infcadastro[0]->naturalidadeCdEstado;
			$comercialNrddd = $xmlObjeto->infcadastro[0]->comercialNrddd;
			$comercialNrTelefone = $xmlObjeto->infcadastro[0]->comercialNrTelefone;
			$residencialNrddd = $xmlObjeto->infcadastro[0]->residencialNrddd;
			$residencialNrTelefone = $xmlObjeto->infcadastro[0]->residencialNrTelefone;
			$celularCdOperadora = $xmlObjeto->infcadastro[0]->celularCdOperadora;
			$celularNrDdd = $xmlObjeto->infcadastro[0]->celularNrDdd;
			$celularNrTelefone = $xmlObjeto->infcadastro[0]->celularNrTelefone;
			$residencialNrCep = $xmlObjeto->infcadastro[0]->residencialNrCep;
			$residencialNmLogradouro = $xmlObjeto->infcadastro[0]->residencialNmLogradouro;
			$residencialNrLogradouro = $xmlObjeto->infcadastro[0]->residencialNrLogradouro;
			$residencialDsComplemento = $xmlObjeto->infcadastro[0]->residencialDsComplemento;
			$residencialNmBairro = $xmlObjeto->infcadastro[0]->residencialNmBairro;
			$residencialCdEstado = $xmlObjeto->infcadastro[0]->residencialCdEstado;
			$residencialDsCidade = $xmlObjeto->infcadastro[0]->residencialDsCidade;
			$residencialTporigem = $xmlObjeto->infcadastro[0]->residencialTporigem;
			$correspondenciaNrCep = $xmlObjeto->infcadastro[0]->correspondenciaNrCep;
			$correspondenciaNmLogradouro = $xmlObjeto->infcadastro[0]->correspondenciaNmLogradouro;
			$correspondenciaNrLogradouro = $xmlObjeto->infcadastro[0]->correspondenciaNrLogradouro;
			$correspondenciaDsComplemento = $xmlObjeto->infcadastro[0]->correspondenciaDsComplemento;
			$correspondenciaNmBairro = $xmlObjeto->infcadastro[0]->correspondenciaNmBairro;
			$correspondenciaCdEstado = $xmlObjeto->infcadastro[0]->correspondenciaCdEstado;
			$correspondenciaDsCidade = $xmlObjeto->infcadastro[0]->correspondenciaDsCidade;
			$correspondenciaTporigem = $xmlObjeto->infcadastro[0]->correspondenciaTporigem;
			$comercialNrCep = $xmlObjeto->infcadastro[0]->comercialNrCep;
            $comercialNmLogradouro = $xmlObjeto->infcadastro[0]->comercialNmLogradouro;
            $comercialNrLogradouro = $xmlObjeto->infcadastro[0]->comercialNrLogradouro;
            $comercialDsComplemento = $xmlObjeto->infcadastro[0]->comercialDsComplemento;
            $comercialNmBairro = $xmlObjeto->infcadastro[0]->comercialNmBairro;
            $comercialCdEstado = $xmlObjeto->infcadastro[0]->comercialCdEstado;
            $comercialDsCidade = $xmlObjeto->infcadastro[0]->comercialDsCidade;
            $comercialTporigem = $xmlObjeto->infcadastro[0]->comercialTporigem;
			$dsnacion = $xmlObjeto->infcadastro[0]->dsnacion;
			$cdExpedidor = $xmlObjeto->infcadastro[0]->cdExpedidor;
			$dsdemail = $xmlObjeto->infcadastro[0]->dsdemail;
			$nmfantasia = $xmlObjeto->infcadastro[0]->nmfantasia;
			$nrInscricao = $xmlObjeto->infcadastro[0]->nrInscricao;      
			$nrLicenca = $xmlObjeto->infcadastro[0]->nrLicenca;        
			$cdNatureza = $xmlObjeto->infcadastro[0]->cdNatureza;
			$cdSetor = $xmlObjeto->infcadastro[0]->cdSetor;
			$cdRamo = $xmlObjeto->infcadastro[0]->cdRamo;
			$cdCnae = $xmlObjeto->infcadastro[0]->cdCnae;
			$dtInicioAtividade = $xmlObjeto->infcadastro[0]->dtInicioAtividade;
			$cdNaturezaOcupacao = $xmlObjeto->infcadastro[0]->cdNaturezaOcupacao;
			
			$metodoSim = str_replace("\r\n", "", "populaCamposRelacionamento('$dtconsultarfb', '$nrcpfcgc', '$cdsituacaoRfb', '$nmpessoa', '$nmpessoaReceita', '$tpsexo', '$dtnascimento',
																			 '$tpdocumento', '$nrdocumento', '$idorgaoExpedidor', '$cdufOrgaoExpedidor', '$dtemissaoDocumento', '$tpnacionalidade', 
																			 '$inhabilitacaoMenor', '$dthabilitacaoMenor', '$cdestadoCivil', '$nmmae', '$nmconjugue', '$nmpai', '$naturalidadeDsCidade', 
																			 '$naturalidadeCdEstado','$comercialNrddd', '$comercialNrTelefone', '$residencialNrddd', '$residencialNrTelefone', '$celularCdOperadora', 
																			 '$celularNrDdd', '$celularNrTelefone', '$residencialNrCep', '$residencialNmLogradouro', '$residencialNrLogradouro', '$residencialDsComplemento', 
																			 '$residencialNmBairro', '$residencialCdEstado','$residencialDsCidade', '$residencialTporigem', '$correspondenciaNrCep', 
																			 '$correspondenciaNmLogradouro', '$correspondenciaNrLogradouro', '$correspondenciaDsComplemento', '$correspondenciaNmBairro', 
																			 '$correspondenciaCdEstado', '$correspondenciaDsCidade', '$correspondenciaTporigem', '$dsnacion','$cdExpedidor', '$dsdemail',
																			 '$nmfantasia', '$comercialNrCep', '$comercialNmLogradouro', '$comercialNrLogradouro', '$comercialDsComplemento', '$comercialNmBairro',
																			 '$comercialCdEstado', '$comercialDsCidade', '$comercialTporigem', '$nrInscricao', '$nrLicenca', '$cdNatureza', '$cdSetor', '$cdRamo',
																			 '$cdCnae', '$dtInicioAtividade', '$cdNaturezaOcupacao');");
			
			exibirConfirmacao('Cadastro já existe na base, deseja iniciar relacionamento?','Confirmação - MATRIC',$metodoSim,$metodoNao,false);
			
		}
			
	}	
	else
	if ($operacao == 'BCC'){ // Buscar nova C/C
 	
		$nrctanov = ( isset($xmlObjeto->roottag->tags[0]->attributes['NRCTANOV']) ) ? $xmlObjeto->roottag->tags[0]->attributes['NRCTANOV'] : '';	

		if ($nrctanov == 0 || $nrctanov == '') {
			exibirErro('error','Não foi possivel gerar a nova C/C.','Alerta - Ayllos','',false);
		}
		
		$nomeForm = ( $inpessoa == 1 ) ? 'frmFisico' : 'frmJuridico';
			
		echo "$('#nrdconta','#frmCabMatric').val($nrctanov);";
		echo "nrdconta = '$nrctanov';";
		echo "operacao = 'DCC';";
		echo "manterOutros('$nomeForm');";
		
	}
	else 
	if ($operacao == 'DCC') { // Duplicar a C/C
		exibirErro('inform','A conta utilizada foi ' . formataContaDVsimples($nrdconta) . '.','Alerta - Ayllos','impressao_inclusao();',false);
	}
		
		
?>

