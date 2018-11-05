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
 */

?>

<?

	$msg['inicio'] = "O(s) ve&iacute;culo(s) ser&aacute;(&atilde;o) automaticamente baixado(s) do contrato antigo e alienado(s) no novo contrato.<br/><br/>Foi verificado se este(s) ve&iacute;culo(s) n&atilde;o possui(em) restri&ccedil&otilde;es para aliena&ccedil&atilde;o?";
	$msg['erro_baixa_vi'] = "Proposta n&atilde;o efetivada, houve cr&iacute;tica na baixa de gravame do contrato sendo liquidado";
	$msg['erro_inclusao_vi'] = "Proposta n&atilde;o efetivada, houve cr&iacute;tica na inclus&atilde;o do gravame";
	$msg['erro_baixa_vd'] = "Proposta n&atilde;o efetivada, houve cr&iacute;tica na inclus&atilde;o do gravame";
	$msg['erro_inclusao_vd'] = "Proposta efetivada, mas houve cr&iacute;tica na baixa do gravame do contrato sendo liquidado - verifique";
	$msg['erro_inclusao_vi'] = "Proposta n&atilde;o efetivada, houve cr&iacute;tica na inclus&atilde;o do gravame";
	$msg['efetivar_proposta'] = "Deseja efetivar proposta?";
	$msg['veiculos_alienados'] = "Ve&iacute;culo(s) alienado(s). ";

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

	// Guardo os par�metos do POST em vari�veis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
	$insitapv = (isset($_POST['insitapv'])) ? $_POST['insitapv'] : '';
	$dsobscmt = (isset($_POST['dsobscmt'])) ? $_POST['dsobscmt'] : '';
	$dtdpagto = (isset($_POST['dtdpagto'])) ? $_POST['dtdpagto'] : '';
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$idcobope = (isset($_POST['idcobope'])) ? $_POST['idcobope'] : '';
	$flliquid = (isset($_POST['flliquid'])) ? $_POST['flliquid'] : 0;
	$continuaEfetivacao = false;
	$errorQtd = 0;

	if ($idcobope > 0 && $flliquid == 0 && $operacao == ''){
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
			echo "showConfirmacao('Garantia de aplica&ccedil;&atilde;o resgatada/bloqueada. Deseja alterar a proposta?', 'Confirma&ccedil;&atilde;o - Ayllos', 'controlaOperacao(\'A_NOVA_PROP\');', 'hideMsgAguardo(); bloqueiaFundo($(\'#divRotina\'))', 'sim.gif', 'nao.gif');";
			exit();
		}

	} else if ( $operacao == 'GRVEFEPROP' ) {

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
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo($(\'#divRotina\'));',false);
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
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo($(\'#divRotina\'));',false);
		} else {
			$mensagem = $xmlObj->roottag->tags[0]->cdata;
			if ($mensagem != '' && $operacao == '') {
				echo "showConfirmacao('$mensagem', 'Confirma&ccedil;&atilde;o - Ayllos', 'efetivaProposta(\'EFE_PRP\');', 'hideMsgAguardo(); bloqueiaFundo($(\'#divRotina\'));', 'sim.gif', 'nao.gif');";
				exit();
			}
			$exibeErro = "";

			$qtdGravameB3 = 0;
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
						$flgobrig = $gravameAttr['FLOBRIGA'];

						$xmlstr = new SimpleXMLElement($xmlResult);
						$sistNac = json_encode( $xmlstr->gravameB3[$qtdGravameB3]->gravame[$qtdGravame]->sistemaNacionalGravames );
						$objContr = json_encode( $xmlstr->gravameB3[$qtdGravameB3]->gravame[$qtdGravame]->objetoContratoCredito );
						$propostaContratoCredito = json_encode( $xmlstr->gravameB3[$qtdGravameB3]->gravame[$qtdGravame]->propostaContratoCredito );

						if ($cdoperac == 1) { //Alienação

							$representanteVendas = json_encode( $xmlstr->gravameB3[$qtdGravameB3]->gravame[$qtdGravame]->representanteVendas );
							$estabelecimentoComercial = json_encode( $xmlstr->gravameB3[$qtdGravameB3]->gravame[$qtdGravame]->estabelecimentoComercial );
							$data = '{"sistemaNacionalGravames": '.$sistNac.',
										"objetoContratoCredito": '.$objContr.',
									  "propostaContratoCredito": '.$propostaContratoCredito.',
										  "representanteVendas": '.$representanteVendas.',
									 "estabelecimentoComercial": '.$estabelecimentoComercial.'}';

						} else if ($cdoperac == 3) { //Baixa Gravame

							$data = '{"sistemaNacionalGravames": '.$sistNac.',
										"objetoContratoCredito": '.$objContr.',
									  "propostaContratoCredito": '.$propostaContratoCredito.'}';

						}

						$xmlStr = postGravame('', $data, $Url_SOA.$iduriservico, $Auth_SOA);
						//var_dump( $GLOBALS["httpcode"] );die;
						$xmlRet = getObjectXML($xmlStr);
						$errorMessage = $dataInteracao = $idRegistro = $retGravame = $retContr = $identificador = '';

						$code = $xmlRet->roottag->tags[1]->cdata; //código retorno
						if ( $GLOBALS["httpcode"] == 200 ) {
							$retContr = $xmlRet->roottag->tags[0]->tags[0]->cdata;
							$retGravame = $xmlRet->roottag->tags[0]->tags[1]->cdata;
							$identificador = $xmlRet->roottag->tags[0]->tags[3]->cdata;
							$dataInteracao = timestampParaDateTime($xmlRet->roottag->tags[0]->tags[2]->cdata);
							$idRegistro = $xmlRet->roottag->tags[0]->tags[3]->cdata;
						} else {
							$errorMessage = retornarMensagemErro($xmlRet);
							$errorQtd++;

							if ( $flgobrig == "S" && $flgaborta == "S" ) {
								exibirErro('error',$msg['erro_baixa_vi'],'Alerta - Ayllos','bloqueiaFundo($(\'#divRotina\'));',false);
								exit;
							} else if ( $flgobrig == "S" && $flgaborta == "N" ) {
								$exibeErro = 'grupo';
							}

						}
						//echo $GLOBALS["postDate"] . " - " . $GLOBALS["getDate"] . " - " . $errorMessage . " - " . $dataInteracao . " - " . $idRegistro . " - S - " . $cdoperac . " - " . $retGravame . " - " . $retContr . " - " . $identificador;

						gravarAuditoria($GLOBALS["postDate"], $GLOBALS["getDate"], $errorMessage, $dataInteracao, $idRegistro, 'S', $cdoperac, $retGravame, $retContr, $identificador);
						//gravarAuditoria($postDate, $getDate, $errorMessage, $dataInteracao, $idRegistro, $flsituac, $cdoperac, $retGravame, $retContr, $identificador)

						$qtdGravame++;
					}

					if ( $exibeErro == 'grupo' ) {
						exibirErro('error',$msg['erro_inclusao_vi'],'Alerta - Ayllos','bloqueiaFundo($(\'#divRotina\'));',false);
						exit;
					}

					$qtdGravameB3++;
				}
			}

			if ($qtdGravame) {
				$msgProposta = $msg['veiculos_alienados'];
			}

		}

		$msgProposta .= $msg['efetivar_proposta'];
		$retorno = "showConfirmacao('$msgProposta', 'Confirma&ccedil;&atilde;o - Ayllos', 'efetivaProposta(\'GRVEFEPROP\');', 'hideMsgAguardo(); bloqueiaFundo($(\'#divRotina\'));', 'sim.gif', 'nao.gif');";

	}

	echo $retorno;