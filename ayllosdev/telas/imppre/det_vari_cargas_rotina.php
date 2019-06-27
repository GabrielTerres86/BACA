 <?php
/* !
 * FONTE        : det_vari_cargas_rotina.php
 * CRIAÇÃO      : Christian Grauppe - ENVOLTI
 * DATA CRIAÇÃO : Fevereiro/2019
 * OBJETIVO     : Rotina para buscar os detalhes da carga
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

	global $eval;

	// Ler parametros passados via POST
	$operacao		= (isset($_POST["operacao"])) ? $_POST["operacao"] : '';
	$idcarga 		= (isset($_POST["idcarga"])) ? $_POST["idcarga"] : '';
	$cdcooper 		= (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;
	$tpcarga 		= (isset($_POST["tpcarga"])) ? $_POST["tpcarga"] : '';
	$indsitua 		= (isset($_POST["indsitua"])) ? $_POST["indsitua"] : '';
	$dtlibera 		= (isset($_POST["dtlibera"])) ? $_POST["dtlibera"] : '';
	$dtliberafim	= (isset($_POST["dtliberafim"])) ? $_POST["dtliberafim"] : '';
	$dtvigencia		= (isset($_POST["dtvigencia"])) ? $_POST["dtvigencia"] : '';
	$dtvigenciafim	= (isset($_POST["dtvigenciafim"])) ? $_POST["dtvigenciafim"] : '';
	$skcarga 		= (isset($_POST["skcarga"])) ? $_POST["skcarga"] : '';
	$dscarga 		= (isset($_POST["dscarga"])) ? $_POST["dscarga"] : '';
	$nrregist 		= (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 20;
	$nriniseq 		= (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;

	if ($operacao == "B") {

		// Monta o xml de requisição
		$xml  		= "";
		$xml 	   .= "<Root>";
		$xml 	   .= "  <Dados>";
		$xml 	   .= "		<idcarga>".$idcarga."</idcarga>";
		$xml 	   .= "  </Dados>";
		$xml 	   .= "</Root>";

		// Executa script para envio do XML
		$xmlResult = mensageria($xml, "TELA_IMPPRE", "EXEC_BLOQ_CARGA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);

		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			gerarErro($msgErro);
		} else {
			gerarErro(utf8ToHtml('Operação realizada com sucesso!'), 'hideMsgAguardo();buscaDetVariCargas();', 'inform');
			//exibirErro('inform',utf8ToHtml('Operação realizada com sucesso!'),'Alerta - Aimaro','hideMsgAguardo();',false);
			exit;
		}

	} else {

		// Monta o xml
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Dados>";

		if ($operacao == "CSV") {

			$xml .= "		<tpretorn>CSV</tpretorn>";
			$xml .= "		<idcarga>".$idcarga."</idcarga>";

		} else {

			$xml .= "		<tpretorn>TELA</tpretorn>";
			$xml .= "		<nrregist>".$nrregist."</nrregist>";
			$xml .= "		<nriniseq>".$nriniseq."</nriniseq>";
			$xml .= "		<cdcooper>".$cdcooper."</cdcooper>";
			$xml .= "		<tpcarga>".$tpcarga."</tpcarga>";
			$xml .= "		<indsitua>".$indsitua."</indsitua>";
			$xml .= "		<dtlibera>".$dtlibera."</dtlibera>";
			$xml .= "		<dtliberafim>".$dtliberafim."</dtliberafim>";
			$xml .= "		<dtvigencia>".$dtvigencia."</dtvigencia>";
			$xml .= "		<dtvigenciafim>".$dtvigenciafim."</dtvigenciafim>";
			$xml .= "		<skcarga>".$skcarga."</skcarga>";
			$xml .= "		<dscarga>".$dscarga."</dscarga>";

			$arrCoop = array();

			// Monta o xml de requisição
			$xmlCoop	 = "";
			$xmlCoop	.= "<Root>";
			$xmlCoop	.= "  <Dados>";
			$xmlCoop	.= "	<flcecred>1</flcecred>";
			$xmlCoop	.= "	<flgtodas>0</flgtodas>";
			$xmlCoop	.= "  </Dados>";
			$xmlCoop	.= "</Root>";

			// Executa script para envio do XML
			$xmlResultCoop = mensageria($xmlCoop, "TELA_GRAVAM", "BUSCACOOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObjCoop = getObjectXML($xmlResultCoop);

			// Se ocorrer um erro, mostra crítica
			if (strtoupper($xmlObjCoop->roottag->tags[0]->name) == "ERRO") {
				$msgErro = $xmlObjCoop->roottag->tags[0]->tags[0]->tags[4]->cdata;
				gerarErro($msgErro);
			}

			$cooperativas = $xmlObjCoop->roottag->tags[0]->tags;

			foreach ( $cooperativas as $coop ) {
			   $arrCoop[getByTagName($coop->tags,'cdcooper')] = getByTagName($coop->tags,'nmrescop');
			}
		}

		$xml .= "  </Dados>";
		$xml .= "</Root>";

		// Executa script para envio do XML
		$xmlResult = mensageria($xml, "TELA_IMPPRE", "LISTA_DETALHE_CARGAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

		// Cria objeto para classe de tratamento de XML
		$xmlObjeto = getObjectXML(utf8_encode($xmlResult));

		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
			gerarErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,"","error");
			exit;
		} else {
			if ($operacao == "CSV") {

				$nmarquivo = $xmlObjeto->roottag->tags[0]->tags[0]->tags[0]->cdata;

				if (!$eval) {
					$tagant = "<script>";
					$tagdep = "</script>";
				}

				echo $tagant;
				echo 'Gera_Impressao(\''.$nmarquivo.'\',\'\');';
				echo $tagdep;

				exit; //termina processamento para exportar arquivo.

			} else {

				$registros = $xmlObjeto->roottag->tags[0]->tags;
				$atrib = $xmlObjeto->roottag->tags[0]->attributes; //returns an array
				$qtregist = $atrib['QTDREGIS'];

			}
			//echo count($registros); die;

			// Monta a tabela de retorno
			$tabela  = "<div id='divRegistrosHistorCargas'><br />";
			$tabela .=	"<div class='divRegistros'>";
			$tabela .= 	"<table>";
			$tabela .=		"<thead>";
			$tabela .=			"<tr>";
			$tabela .=				"<th>Coop.</th>";
			$tabela .=				"<th>Tipo</th>";
			$tabela .=				"<th>Num. Carga</th>";
			$tabela .=				"<th>Descri&ccedil;&atilde;o da Carga</th>";
			$tabela .=				"<th>Situa&ccedil;&atilde;o</th>";
			$tabela .=				"<th>Data Lib.</th>";
			$tabela .=				"<th>Vig. Final</th>";
			$tabela .=				"<th>Qtd. Reg.</th>";
			$tabela .=				"<th>Valor Total</th>";
			$tabela .=			"</tr>";
			$tabela .=		"</thead>";

			$tabela .=		"<tbody>";

			// Se encontrar registros para exibir
			if (count($registros) > 0) {
				$totalValorParc = $totalValorLim = 0;
				foreach( $registros as $critic ) {
					$idcarga = getByTagName($critic->tags,'idcarga');
					$cdcooper = getByTagName($critic->tags,'cdcooper');
					$tpcarga = getByTagName($critic->tags,'tpcarga');
					$skcarga = getByTagName($critic->tags,'skcarga');
					$dscarga = getByTagName($critic->tags,'dscarga');
					$dssitua = getByTagName($critic->tags,'dssitua');
					$dtvigencia = getByTagName($critic->tags,'dtvigencia');
					$dtliberacao = getByTagName($critic->tags,'dtliberacao');
					$qtregistros = getByTagName($critic->tags,'qtregistros');
					$vlrtotal = getByTagName($critic->tags,'vlrtotalsp');
					$vlrmediapar = getByTagName($critic->tags,'vlrmediapar');
					$qtregispf = getByTagName($critic->tags,'qtregispf');
					$qtregispj = getByTagName($critic->tags,'qtregispj');
					$vlrparmax = getByTagName($critic->tags,'vlrparmax');
					$vlmincarga = getByTagName($critic->tags,'vlmincarga');
					$qtdregcarga = getByTagName($critic->tags,'qtdregcarga'); //somente pre-aprovados
					$qtdregcargapf = getByTagName($critic->tags,'qtdregcargapf'); //somente pre-aprovados
					$qtdregcargapj = getByTagName($critic->tags,'qtdregcargapj'); //somente pre-aprovados
					$qtremovman = getByTagName($critic->tags,'qtremovman');
					$pervariault = getByTagName($critic->tags,'pervariault');
					$pervarapri = getByTagName($critic->tags,'pervarapri');
					$cdCarga = getByTagName($critic->tags,'cdCarga');

					$tabela .=		"<tr id='".$idcarga."'>";
					$tabela .=			"<input type='hidden' name='idcarga' value='".$idcarga."' />";
					$tabela .=			"<input type='hidden' name='vlrmediapar' value='".$vlrmediapar."' />";
					$tabela .=			"<input type='hidden' name='qtregispf' value='".$qtdregcargapf."' />";
					$tabela .=			"<input type='hidden' name='qtregispj' value='".$qtdregcargapj."' />";
					$tabela .=			"<input type='hidden' name='vlrparmax' value='".$vlrparmax."' />";
					$tabela .=			"<input type='hidden' name='vlmincarga' value='".$vlmincarga."' />";
					$tabela .=			"<input type='hidden' name='qtremovman' value='".$qtremovman."' />";
					$tabela .=			"<input type='hidden' name='pervariault' value='".$pervariault."' />";
					$tabela .=			"<input type='hidden' name='pervarapri' value='".$pervarapri."' />";
					$tabela .=			"<input type='hidden' name='cdcooper' value='".$cdcooper."' />";
					$tabela .=			"<input type='hidden' name='qtregistros' value='".$qtdregcarga."' />";
					$tabela .=			"<input type='hidden' name='tpcarga' value='".$tpcarga."' />";
					$tabela .=			"<input type='hidden' name='glbcoop' value='".$glbvars["cdcooper"]."' />";
					$tabela .=			"<td>";
					$tabela .=				"<span>".$cdcooper." ".$arrCoop[$cdcooper]."</span>".$cdcooper." ".$arrCoop[$cdcooper];
					$tabela .=			"</td>";
					$tabela .=			"<td>";
					$tabela .=				"<span>".$tpcarga."</span>".$tpcarga;
					$tabela .=			"</td>";
					$tabela .=			"<td>";
					$tabela .=				"<span>".$cdCarga."</span>".$cdCarga;
					$tabela .=			"</td>";
					$tabela .=			"<td>";
					$tabela .=				"<span>".$dscarga."</span>".$dscarga;
					$tabela .=			"</td>";
					$tabela .=			"<td class='dssitua'>";
					$tabela .=				"<span>".$dssitua."</span>".$dssitua;
					$tabela .=			"</td>";
					$tabela .=			"<td>";
					$tabela .=				"<span>".ordenacaoData($dtliberacao)."</span>".$dtliberacao;
					$tabela .=			"</td>";
					$tabela .=			"<td>";
					$tabela .=				"<span>".ordenacaoData($dtvigencia)."</span>".$dtvigencia;
					$tabela .=			"</td>";
					$tabela .=			"<td>";
					$tabela .=				"<span>".ordenacaoNumero($qtdregcarga)."</span>".$qtdregcarga;
					$tabela .=			"</td>";
					$tabela .=			"<td>";
					$tabela .=				"<span>".ordenacaoNumero($vlrtotal)."</span>".$vlrtotal;
					$tabela .=			"</td>";
					$tabela .=		"</tr>";
				}
			} else {
				$tabela .= 		"<tr id='nada'><td colspan='9'>Nenhum cadastro de mensagem encontrado!</td></tr>";
				$class = " adisabled";
			}

			$tabela .=		"</tbody>";
			$tabela .=	"</table>";
			$tabela .=	"</div>";
			
			$tabela .=	"<div id='divPesquisaRodape' class='divPesquisaRodape'>";
			$tabela .=	"<table>";
			$tabela .=	"<tr>";
			$tabela .=	"<td>";
							if ($qtregist == 0 || $qtregist == "") $nriniseq = 0;
							if ($nriniseq > 1) {
			$tabela .=	" <a class='paginacaoAnterior'><<< Anterior</a>";
							}
			$tabela .=	"</td>";
			$tabela .=	"<td>";
							if ($nriniseq) {
			$tabela .=	" Exibindo $nriniseq at&eacute; " . ( (($nriniseq + $nrregist) > $qtregist) ? $qtregist : ($nriniseq + $nrregist - 1) ) . " de $qtregist ";
							}
			$tabela .=	"</td>";
			$tabela .=	"<td>";
							if ($qtregist > ($nriniseq + $nrregist - 1)) {
			$tabela .=	" <a class='paginacaoProximo'>Pr&oacute;ximo >>></a>";
							}
			$tabela .=	"</td>";
			$tabela .=	"</tr>";
			$tabela .=	"</table>";
			$tabela .=	"</div>";

			$tabela .=	"</div>";

			$tabela .=	"<div id='divBotoes' style='text-align:center; margin-bottom: 10px;' >";
			$tabela .=	"	<a href='#' class='botao".$class."' id='btBloquear' name='btBloquear' onClick='btnBloquear();return false;' style='float:none;'>Bloquear/Desbloquear</a>";
			$tabela .=	"	<a href='#' class='botao".$class."' id='btDetalhes' name='btDetalhes' onClick='btnDetalhes();return false;' style='float:none;'>Detalhes</a>";
			$tabela .=	"	<a href='#' class='botao".$class."' id='btExportar' name='btExportar' onClick='btnExportar();return false;' style='float:none;'>Exportar CSV</a>";
			$tabela .=	"</div>";
			$tabela .=	"<style type=\"text/css\" media=\"all\">";
			$tabela .=	"	.adisabled {";
			$tabela .=	"		pointer-events: none;";
			$tabela .=	"		cursor: default;";
			$tabela .=	"		opacity: 0.6;";
			$tabela .=	"	}";
			$tabela .=	"</style>";

			$tagant = "";
			$tagdep = "";
			if (!$eval) {
				$tagant = "<script>";
				$tagdep = "</script>";
			}

			$tabela = str_replace("'","\\\'",$tabela);
			$tabela = str_replace('"','\"',$tabela);
			echo $tagant;
			echo "parent.framePrincipal.eval(\"divListDetVariCargas.html('".$tabela."');formataListDetVariCargas(".$nriniseq.",".$nrregist.");divListDetVariCargas.show();\");";
			echo $tagdep;

			if ($msg != "") {
				gerarErro($msg,"","inform");
			}
			retornoEval("hideMsgAguardo();");
		}
	}

	function gerarErro($dserro,$callback='',$tipo='error'){
		global $eval;
		$dserro = str_replace("'","\\\'",$dserro);
		$dserro = str_replace('"','\\"',$dserro);
		$dserro = str_replace("\n","",$dserro);
		$callback = str_replace("'","\\\'",$callback);
		$callback = str_replace('"','\\"',$callback);
		$tagant = "";
		$tagdep = "";
		if(!$eval){
			$tagant = "<script>";
			$tagdep = "</script>";
		}

		echo $tagant."parent.framePrincipal.eval(\"msgError('".$tipo."','".utf8ToHtml($dserro)."','hideMsgAguardo();".$callback."');\");".$tagdep;
		exit();
	}

	function retornoEval($dseval){
		global $eval;
		$dseval = str_replace('"','\"',$dseval);
		$tagantes = "";
		$tagdepos = "";
		if(!$eval){
			$tagantes = "<script>";
			$tagdepos = "</script>";
		}
		echo $tagantes."parent.framePrincipal.eval(\"".$dseval."\");".$tagdepos;
		exit();
	}

	function ordenacaoNumero($str_num){
		$resultado = str_replace('.', '', $str_num);
		$resultado = str_replace(',', '', $resultado);
		return $resultado;
	}

	function ordenacaoData($str_num){
		$resultado = explode("/", $str_num);
		return $resultado[2].$resultado[1].$resultado[0];
	}