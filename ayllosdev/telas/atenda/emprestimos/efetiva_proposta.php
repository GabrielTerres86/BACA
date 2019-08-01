<? 
/*!
 * FONTE        : grava_dados_proposta.php
 * CRIA��O      : Marcelo L. Pereira (GATI)
 * DATA CRIA��O : 29/07/2011 
 * OBJETIVO     : Rotina de grava��o da aprova��o da proposta
 *
 *---------------------
 *      ALTERACOES
 *---------------------
 *
 * 000: [06/03/2012] Tiago: Incluido cdagenci e cdpactra.
 * 001: [18/11/2014] Jaison: Inclusao do parametro nrcpfope.
         17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) 
 * 002: [05/03/2018] Reinert: Incluido validacao de bloqueio de garantia de emprestimo.
 * 003: [10/11/2018] Grauppe: implementado comunicação SOA / Gravames.
 */
 
	$msg['inicio'] = "O(s) ve&iacute;culo(s) ser&aacute;(&atilde;o) automaticamente baixado(s) do contrato antigo e alienado(s) no novo contrato.<br/><br/>Foi verificado se este(s) ve&iacute;culo(s) n&atilde;o possui(em) restri&ccedil&otilde;es para aliena&ccedil&atilde;o?";
	$msg['erro_baixa_vi'] = "Proposta n&atilde;o efetivada, houve cr&iacute;tica na baixa de gravame do contrato sendo liquidado";
	$msg['erro_inclusao_vi'] = "Proposta n&atilde;o efetivada, houve cr&iacute;tica na inclus&atilde;o do gravame";
	$msg['erro_inclusao_vd'] = "Proposta efetivada, mas houve cr&iacute;tica na baixa do gravame do contrato sendo liquidado - verifique";
	$msg['efetivar_proposta'] = "Deseja efetivar a proposta?";
	$msg['veiculos_alienados'] = "Aliena&ccedil;&otilde;es efetuadas com sucesso. ";
	$msg['veiculos_alienados_baixados'] = "Aliena&ccedil;&otilde;es e baixas efetuadas com sucesso. ";
	$msg['erro_baixa'] = "Aliena&ccedil;&otilde;es efetivadas com sucesso - houve cr&iacute;tica na baixa do ve&iacute;culo do contrato a ser liquidado. ";

	/*
	*				Obrigatorio 	Abortivo
	*	Aliena Dif		S 				N
	*	Baixa Ant		S				S
	*	Aliena Ant		S				N
	*	Baixa Dif		N				N
	*/

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	require_once('../../gravam/uteis/funcoes_gravame.php');
	isPostMethod();
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
	$insitapv = (isset($_POST['insitapv'])) ? $_POST['insitapv'] : '';
	$dsobscmt = (isset($_POST['dsobscmt'])) ? $_POST['dsobscmt'] : '';
	$dtdpagto = (isset($_POST['dtdpagto'])) ? $_POST['dtdpagto'] : '';
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$idcobope = (isset($_POST['idcobope'])) ? $_POST['idcobope'] : '';
	$flliquid = (isset($_POST['flliquid'])) ? $_POST['flliquid'] : 0;
	//$continuaEfetivacao = false;
	$errorQtd = 0;
					
	if ($idcobope > 0 && $flliquid == 0 && $operacao == '') {
		// Monta o xml dinâmico de acordo com a operação 
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <nmdatela>ATENDA</nmdatela>';
		$xml .= '       <idcobert>'.$idcobope.'</idcobert>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';

		$xmlResult = mensageria($xml, "BLOQ0001", "REVALIDA_BLOQ_GARANTIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = getObjectXML($xmlResult);

		//----------------------------------------------------------------------------------------------------------------------------------	
		// Controle de Erros
		//----------------------------------------------------------------------------------------------------------------------------------
		if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
			echo "showConfirmacao('Garantia de aplica&ccedil;&atilde;o resgatada/bloqueada. Deseja alterar a proposta?', 'Confirma&ccedil;&atilde;o - Aimaro', 'controlaOperacao(\'A_NOVA_PROP\');', 'hideMsgAguardo(); bloqueiaFundo($(\'#divRotina\'))', 'sim.gif', 'nao.gif');";
			exit();
		}

	}
					
	if ( $operacao == 'GRVEFEPROP' ) {

		// grava a proposta depois de baixar e alienar os veículos;
		// Monta o xml de requisição
	$xml  = "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0084.p</Bo>";
	$xml .= "		<Proc>grava_efetivacao_proposta</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
	$xml .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<flgerlog>true</flgerlog>";
	$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
	$xml .= "		<dtdpagto>".$dtdpagto."</dtdpagto>";
    $xml .= "		<nrcpfope>0</nrcpfope>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo($(\'#divRotina\'));',false);
	}
	
	$registros  = $xmlObj->roottag->tags[0]->tags;
	$mensagem = $xmlObj->roottag->tags[0]->attributes["MENSAGEM"];
	$retorno = "hideMsgAguardo(); $('#linkAba0').html('Principal');";
	$retorno .= "arrayRatings.length = 0;";
		foreach($registros as $indice => $registro) {
		$retorno .= 'var arrayRating'.$indice.' = new Object();
					 arrayRating'.$indice.'[\'dtmvtolt\'] = "'.getByTagName($registro->tags,'dtmvtolt').'";
					 arrayRating'.$indice.'[\'dsdopera\'] = "'.getByTagName($registro->tags,'dsdopera').'"; 
					 arrayRating'.$indice.'[\'nrctrrat\'] = "'.getByTagName($registro->tags,'nrctrrat').'"; 
					 arrayRating'.$indice.'[\'indrisco\'] = "'.getByTagName($registro->tags,'indrisco').'"; 
					 arrayRating'.$indice.'[\'nrnotrat\'] = "'.getByTagName($registro->tags,'nrnotrat').'"; 
					 arrayRating'.$indice.'[\'vlutlrat\'] = "'.getByTagName($registro->tags,'vlutlrat').'"; 
					 arrayRatings['.$indice.'] = arrayRating'.$indice.';';
	}
    
    if ($mensagem != '') {
	   $retorno .= 'exibirMensagens(\''.$mensagem.'\',\'controlaOperacao(\"RATING\")\');';
		} else {
		   $retorno .=  "controlaOperacao('T_C');";	
		}

	} else {

		// Monta o xml de requisição (P442-10.1)
		$xml  		= "";
		$xml 	   .= "<Root>";
		$xml 	   .= "  <Dados>";
		$xml 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";
		$xml 	   .= "     <nrctrpro>".$nrctremp."</nrctrpro>";
		$xml 	   .= "  </Dados>";
		$xml 	   .= "</Root>";

		// Executa script para envio do XML
		$xmlResult = mensageria($xml,"GRVM0001","PREP_ALIENAC_ATENDA",$glbvars["cdcooper"],$glbvars["cdagenci"],$glbvars["nrdcaixa"],$glbvars["idorigem"],$glbvars["cdoperad"],"</Root>");
		$xmlObj = getObjectXML($xmlResult);

		if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo($(\'#divRotina\'));',false);
		} else {
			$mensagem = $xmlObj->roottag->tags[0]->cdata;
			if ($mensagem != '' && $operacao == '') {
				echo "showConfirmacao('$mensagem', 'Confirma&ccedil;&atilde;o - Aimaro', 'efetivaProposta(\'EFE_PRP\');', 'hideMsgAguardo(); bloqueiaFundo($(\'#divRotina\'));', 'sim.gif', 'nao.gif');";
				exit();
    }
			$exibeErro = "";

			$countBaixa = $countAlienacao = $countErroBaixa = $countErroAlienacao = $qtdGravameB3 = 0;
			foreach ($xmlObj->roottag->tags AS $t) {
				if (strtoupper($t->name) == 'GRAVAMEB3') {
					$gravamesb3 = $t->attributes;
					$nomgrupo = $gravamesb3['NOMGRUPO'];
					$flgobrig = $gravamesb3['FLGOBRIG'];

					$qtdGravame = 0;

					foreach ($t->tags as $gravame) {

						$gravameAttr = $gravame->attributes;
						$iduriservico = $gravameAttr['IDURISERVICO'];
						$cdoperac = $gravameAttr['CDOPERAC'];
						$cdcooper = $gravameAttr['CDCOOPER'];
						$nrdconta = $gravameAttr['NRDCONTA'];
						$tpctrato = $gravameAttr['TPCTRATO'];
						$nrctremp = $gravameAttr['NRCTREMP'];
						$idseqbem = $gravameAttr['IDSEQBEM'];
						$flaborta = $gravameAttr['FLABORTA'];
						$flgobrig = $gravameAttr['FLGOBRIG'];

						$xmlstr = new SimpleXMLElement( $xmlResult );
						$sistNac = convertXMLtoJSONnode0( $xmlstr->gravameB3[$qtdGravameB3]->gravame[$qtdGravame]->sistemaNacionalGravames );
						$objContr = convertXMLtoJSONnode0( $xmlstr->gravameB3[$qtdGravameB3]->gravame[$qtdGravame]->objetoContratoCredito );
						$propostaContratoCredito = convertXMLtoJSONnode0( $xmlstr->gravameB3[$qtdGravameB3]->gravame[$qtdGravame]->propostaContratoCredito );

						if ($cdoperac == 1) { //Alienação

							$representanteVendas = convertXMLtoJSONnode0( $xmlstr->gravameB3[$qtdGravameB3]->gravame[$qtdGravame]->representanteVendas );
							$estabelecimentoComercial = convertXMLtoJSONnode0( $xmlstr->gravameB3[$qtdGravameB3]->gravame[$qtdGravame]->estabelecimentoComercial );
							$data = '{			"cooperativa": { "codigo": "'.$cdcooper.'" },
									"sistemaNacionalGravames": '.$sistNac.',
									  "objetoContratoCredito": '.$objContr.',
									"propostaContratoCredito": '.$propostaContratoCredito.',
										"representanteVendas": '.$representanteVendas.',
								   "estabelecimentoComercial": '.$estabelecimentoComercial.'}';

						} else if ($cdoperac == 3) { //Baixa Gravame

							$data = '{			"cooperativa": { "codigo": "'.$cdcooper.'" },
									"sistemaNacionalGravames": '.$sistNac.',
									  "objetoContratoCredito": '.$objContr.',
									"propostaContratoCredito": '.$propostaContratoCredito.'}';

						}

						$xmlStr = postGravame('', $data, $Url_SOA.$iduriservico, $Auth_SOA);
						//echo "console.log('".str_replace(array("\r\n", "\n", "\r"), "<br/>", $xmlStr)."');";
						$xmlRet = getObjectXML($xmlStr);
						$errorMessage = $dataInteracao = $idRegistro = $retGravame = $retContr = $identificador = '';

						if ( $GLOBALS["httpcode"] == 200 ) {
							$dataInteracao = timestampParaDateTime($xmlRet->roottag->tags[0]->tags[0]->cdata);

							if ($cdoperac == 1) {
							$identificador = $xmlRet->roottag->tags[0]->tags[1]->cdata;
							$idRegistro = $xmlRet->roottag->tags[0]->tags[2]->cdata;
							}

							if ($cdoperac == 3) {
								$idRegistro = $xmlRet->roottag->tags[0]->tags[1]->cdata;
								$countBaixa++; 
							}

						} else {
							$errorMessage = retornarMensagemErro($xmlRet);
							$errorQtd++;

							if ( $flgobrig == "S" && $flaborta == "S" ) {
								$exibeErro = 'abortar';
							} else if ( $flgobrig == "S" && $flaborta == "N" ) {
								$exibeErro = 'grupo';
							}

							if ($cdoperac == 1) { $countErroAlienacao++; }
							if ($cdoperac == 3) { $countErroBaixa++; }
						}

						parametrosParaAudit($glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"]); 

						gravarAuditoria($GLOBALS["postDate"], $GLOBALS["getDate"], $errorMessage, $dataInteracao, $idRegistro, 'S', $cdoperac, $identificador, $idseqbem, $nrctremp, $nrdconta);

						if ($exibeErro == "abortar") {
							exibirErro('error',$msg['erro_baixa_vi'],'Alerta - Aimaro','bloqueiaFundo($(\'#divRotina\'));',false);
							exit;
						}

						$qtdGravame++;

					}

					if ( $exibeErro == 'grupo' ) {
						//exibirErro('error',$msg['erro_inclusao_vi'],'Alerta - Aimaro','bloqueiaFundo($(\'#divRotina\'));',false);
						echo "showConfirmacao('".$msg['erro_inclusao_vi']."', 'Confirma&ccedil;&atilde;o - Aimaro', 'controlaOperacao(\'C_HISTORICO_GRAVAMES\');', 'hideMsgAguardo(); bloqueiaFundo($(\'#divRotina\'));', 'historico.gif', 'voltar.gif');";
						exit;
					}
					$qtdGravameB3++;
				}
			}

			if ($countErroAlienacao == 0) {
				if ($countErroBaixa > 0) {
					$msgProposta = $msg['erro_baixa'];
				} else {
					$msgProposta = ($countBaixa == 0) ? $msg['veiculos_alienados'] : $msg['veiculos_alienados_baixados'];
				}
				$operacao = 'GRAVAPROP';
			}

			if ($qtdGravameB3 == 0) {
				$operacao = 'EFE_PRP';
			}
		}

		if ($msgProposta && $operacao != 'EFE_PRP') {
			$msgProposta .= $msg['efetivar_proposta'];
			$retorno = "showConfirmacao('$msgProposta', 'Confirma&ccedil;&atilde;o - Aimaro', 'efetivaProposta(\'GRVEFEPROP\');', 'hideMsgAguardo(); bloqueiaFundo($(\'#divRotina\'));', 'sim.gif', 'nao.gif');";
		} else {
			$retorno = "efetivaProposta('GRVEFEPROP');";
		}

	}
    
	echo $retorno;
