<?
/*!
 * FONTE        : manter_rotina.php 
 * CRIAÇÃO      : Alex Sandro (GFT)
 * DATA CRIAÇÃO : 15/02/2018
 * OBJETIVO     : Descrição da rotina
 * --------------
 * ALTERAÇÕES   :
 * --------------

 */
?>

<?

    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();

	// parâmetos do POST em variáveis
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ;
	$nrctrlim = (isset($_POST['nrctrlim'])) ? $_POST['nrctrlim'] : 0 ;
	$insitlim = (isset($_POST['insitlim'])) ? $_POST['insitlim'] : '' ;
	$dssitest = (isset($_POST['dssitest'])) ? $_POST['dssitest'] : '' ;
	$insitapr = (isset($_POST['insitapr'])) ? $_POST['insitapr'] : '' ;
	$vllimite = (isset($_POST['vllimite'])) ? $_POST['vllimite'] : 0 ;
	$cddopera = (isset($_POST['cddopera'])) ? $_POST['cddopera'] : 0 ;
	$nrinssac = (isset($_POST['nrinssac'])) ? $_POST['nrinssac'] : '' ;
	$vltitulo = (isset($_POST['vltitulo'])) ? $_POST['vltitulo'] : '' ;
	$dtvencto = (isset($_POST['dtvencto'])) ? $_POST['dtvencto'] : '' ;
	$nrnosnum = (isset($_POST['nrnosnum'])) ? $_POST['nrnosnum'] : '' ;
	$form 	  = (isset($_POST['frmOpcao'])) ? $_POST['frmOpcao'] : '' ;
	$nrborder = (isset($_POST['nrborder'])) ? $_POST['nrborder'] : '' ;

	if ($operacao == 'ENVIAR_ANALISE' ) {
		
		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	    $xml .= "   <nrctrlim>".$nrctrlim."</nrctrlim>";
	    $xml .= "   <tpctrlim>3</tpctrlim>";
	    $xml .= "	<dtmovito>".$glbvars["dtmvtolt"]."</dtmovito>";
	    $xml .= "   <tpenvest>I</tpenvest>"; // Tipo de envio para esteira I - Inclusao (Emprestimo)
	    $xml .= " </Dados>";
	    $xml .= "</Root>";


	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","ENVIAR_ESTEIRA_DESCT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);

		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){  
           echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);carregaLimitesTitulos();");';           
           exit;
		}
		if($xmlObj->roottag->tags[0]){
			echo 'showError("inform","'.$xmlObj->roottag->tags[0]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);carregaLimitesTitulos();");';
		} else{
			echo 'showError("inform","An&aacute;lise enviada com sucesso!","Alerta - Ayllos","bloqueiaFundo(divRotina);carregaLimitesTitulos();");';
		}	
		
        exit;

	}else if ($operacao == 'ENVIAR_ESTEIRA' ) {

		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	    $xml .= "   <nrctrlim>".$nrctrlim."</nrctrlim>";
	    $xml .= "   <tpctrlim>3</tpctrlim>";
	    $xml .= "	<dtmovito>".$glbvars["dtmvtolt"]."</dtmovito>";
	    $xml .= "   <tpenvest>I</tpenvest>"; // Tipo de envio para esteira I - Inclusao (Emprestimo)
	    $xml .= " </Dados>";
	    $xml .= "</Root>";

	    // FAZER O INSERT CRAPRDR e CRAPACA
	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","SENHA_ENVIAR_ESTEIRA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);

		$registros = $xmlObj->roottag->tags[0]->tags;
		
	    // Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
           echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);carregaLimitesTitulos();");';           
		}
		else{
			if($xmlObj->roottag->tags[0]){
				echo 'showError("inform","'.$xmlObj->roottag->tags[0]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);carregaLimitesTitulos();");';
			} else{
				echo 'showError("inform","An&aacute;lise enviada com sucesso!","Alerta - Ayllos","bloqueiaFundo(divRotina);carregaLimitesTitulos();");';
			}	
		}


		exit;
		
	}else if ($operacao == 'CONFIMAR_NOVO_LIMITE' ) {

		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	    $xml .= "   <nrctrlim>".$nrctrlim."</nrctrlim>";
	    $xml .= "   <vllimite>".converteFloat($vllimite)."</vllimite>";
	    $xml .= "   <cddopera>".$cddopera."</cddopera>";
	    $xml .= " </Dados>";
	    $xml .= "</Root>";



	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","CONFIRMAR_NOVO_LIMITE_TIT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");


	    $xmlObj = getObjectXML($xmlResult);

	    // Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			if ($msgErro == "") {
				$msgErro = $xmlObj->roottag->tags[0]->cdata;
			}
			exibeErro(htmlentities($msgErro));
			exit();
		}
		
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "MSG") {
			
			$mensagem_01 = $xmlObj->roottag->tags[0]->tags[0]->cdata;
			$mensagem_02 = $xmlObj->roottag->tags[0]->tags[1]->cdata;
			$mensagem_03 = $xmlObj->roottag->tags[0]->tags[2]->cdata;
			$mensagem_04 = $xmlObj->roottag->tags[0]->tags[3]->cdata;
			$mensagem_05 = $xmlObj->roottag->tags[0]->tags[4]->cdata;
			$qtctarel    = '';
			
			if ($mensagem_03 != '') {
				$tab_grupo   = $xmlObj->roottag->tags[0]->tags[5]->tags;
				$qtctarel    = $xmlObj->roottag->tags[0]->tags[6]->cdata;
			}
			
			$grupo = '';
			if ($mensagem_03 != '') {
				foreach( $tab_grupo as $reg ) { 
					$grupo .= ($reg->cdata).";";
				}
				if ($grupo != '')
					$grupo = substr($grupo,0,-1);
			}
			
			echo 'verificaMensagens("'.$mensagem_01.'","'.$mensagem_02.'","'.$mensagem_03.'","'.$mensagem_04.'","'.$mensagem_05.'","'.$qtctarel.'","'.$grupo.'");';
			exit;
		}
		else{
			if ($xmlObj->roottag->tags[0]->cdata == 'OK') {
				echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));carregaLimitesTitulos();");';
			}
		}
		
	}else if ($operacao == 'ACEITAR_REJEICAO_LIMITE' ) {

		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	    $xml .= "   <nrctrlim>".$nrctrlim."</nrctrlim>";
	    $xml .= " </Dados>";
	    $xml .= "</Root>";

	    // FAZER O INSERT CRAPRDR e CRAPACA
	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","ACEITAR_REJEICAO_LIM_TIT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);


	    // Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			if ($msgErro == "") {
				$msgErro = $xmlObj->roottag->tags[0]->cdata;
			}
			exibeErro(htmlentities($msgErro));
			exit;
		}
		else{
			if ($xmlObj->roottag->tags[0]->cdata == 'OK') {
				echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - 	Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));carregaLimitesTitulos();");';
				exit;
			} // OK
		}// != ERROR
		
	}
	else if ($operacao == 'BUSCAR_PAGADOR'){
		if (!validaInteiro($nrdconta) || $nrdconta == 0) exibirErro('error','Informe o número da conta.','Alerta - Ayllos','$(\'#nrdconta\', \'#'.$form.'\').focus()',false);
		if (!validaInteiro($nrinssac) || $nrinssac == 0) exibirErro('error','Informe o número do CPF/CNPJ.','Alerta - Ayllos','$(\'#nrinssac\', \'#'.$form.'\').focus()',false);
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<nrinssac>".$nrinssac."</nrinssac>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		$xmlResult = mensageria($xml, "COBRAN", "COBR_OBTER_PAGADOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto 	= getObjectXML($xmlResult);		

		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
			$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
			exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#nmdsacad\', \'#'.$form.'\').val(\'\');$(\'#nrinssac\', \'#'.$form.'\').val(\'\').focus()',false);
		} 
			
		$nmdsacad	= getByTagname($xmlObjeto->roottag->tags[0]->tags,'nmdsacad');
		$vlpercen	= getByTagname($xmlObjeto->roottag->tags[0]->tags,'vlpercen');

		echo "$('#nmdsacad', '#$form').val('$nmdsacad');";
		echo "$('#vlpercen', '#$form').val('$vlpercen');";
		echo "controlaOpcao();";

	}else if ($operacao =='BUSCAR_TITULOS_BORDERO'){

		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	    $xml .= "	<nrinssac>".$nrinssac."</nrinssac>";
	    $xml .= "	<vltitulo>".converteFloat($vltitulo)."</vltitulo>";
	    $xml .= "	<dtvencto>".$dtvencto."</dtvencto>";
	    $xml .= "	<nrnosnum>".$nrnosnum."</nrnosnum>";
	    $xml .= "	<nrctrlim>".$nrctrlim."</nrctrlim>";
	    $xml .= "	<nrborder>".$nrborder."</nrborder>";
		$xml .= "	<insitlim>2</insitlim>";
		$xml .= "	<tpctrlim>3</tpctrlim>";
	    $xml .= " </Dados>";
	    $xml .= "</Root>";

	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","BUSCAR_TITULOS_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);


	    // Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			if ($msgErro == "") {
				$msgErro = $xmlObj->roottag->tags[0]->cdata;
			}
			echo '<script>';
			exibeErro(htmlentities($msgErro));
			echo '</script>';
			exit;
		}

    	$dados = $xmlObj->roottag->tags[0];
        $qtregist = $xmlObj->roottag->tags[0]->attributes['QTREGIST'];
    	if($qtregist>0){
	    	$html = "<table class='tituloRegistros'>";
			$html .= 	"<thead>
								<tr>
									<th>Conv&ecirc;nio</th>
									<th>Boleto n&ordm;</th>
									<th>Pagador</th>
									<th>Vencimento</th>
									<th>Valor</th>
									<th>Situa&ccedil;&atilde;o</th>
									<th>Selecionar</th>
								</tr>
							</thead>
							<tbody>
					";
	    	foreach($dados->tags AS $t){
	    		$html .= "<tr id='titulo_".getByTagName($t->tags,'nrnosnum')."'>";
	    		$html .=	"<td>
	    						<input type='hidden' name='vltituloselecionado' value='".formataMoeda(getByTagName($t->tags,'vltitulo'))."'/>
	    						<input type='hidden' name='selecionados' value='".getByTagName($t->tags,'nrnosnum')."'/>".getByTagName($t->tags,'nrcnvcob')."
	    					</td>";
	    		$html .=	"<td>".getByTagName($t->tags,'nrdocmto')."</td>";
	    		$html .=	"<td>".getByTagName($t->tags,'nrinssac').' - '.getByTagName($t->tags,'nmdsacad')."</td>";
	    		$html .=	"<td>".getByTagName($t->tags,'dtvencto')."</td>";
	    		$html .=	"<td><span>".converteFloat(getByTagName($t->tags,'vltitulo'))."</span>".formataMoeda(getByTagName($t->tags,'vltitulo'))."</td>";
	    		$sit = getByTagName($t->tags,'dssituac');
	    		if ($sit=="N") {
		    		$html .=	"<td><img src='../../imagens/icones/sit_ok.png'/></td>";
	    		}
	    		elseif ($sit=="S") {
		    		$html .=	"<td><img src='../../imagens/icones/sit_er.png'/></td>";
	    		}
	    		else{
		    		$html .=	"<td></td>";
	    		}
	    		$html .=	"<td class='botaoSelecionar' onclick='incluiTituloBordero(this);'><button type='button' class='botao'>Incluir</button></td>";
	    		$html .= "</tr>";
	    	}
	    	$html .= "</tbody>
	    			</table>";
	    	echo $html;
	    }
	    else{
			echo '<script>';
			exibeErro("N&atilde;o foi encontrado nenhum t&iacute;tulo utilizando esses filtros.");
			echo 'setTimeout(function(){bloqueiaFundo($("#divError"))},1)';

			echo '</script>';
	    }
    	exit();
	} else if($operacao =='INSERIR_BORDERO'){
		$selecionados = isset($_POST["selecionados"]) ? $_POST["selecionados"] : array();
		if(count($selecionados)==0){
			exibeErro("Selecione ao menos um t&iacute;tulo");
			exit;
		}
		$selecionados = implode($selecionados,",");

		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <tpctrlim>3</tpctrlim>";
	    $xml .= "   <insitlim>2</insitlim>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	    $xml .= "   <nrnosnum>".$selecionados."</nrnosnum>";
	    $xml .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	    $xml .= " </Dados>";
	    $xml .= "</Root>";


	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","INSERIR_TITULOS_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);

	    // Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
	       echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","hideMsgAguardo();bloqueiaFundo(divRotina);");';
			exit;
		}

    	$dados = $xmlObj->roottag->tags[0];

			
	    echo 'showError("inform","'.$xmlObj->roottag->tags[0]->tags[0]->cdata.'","Alerta - Ayllos","carregaTitulos();dscShowHideDiv(\'divOpcoesDaOpcao1\',\'divOpcoesDaOpcao2;divOpcoesDaOpcao3;divOpcoesDaOpcao4;divOpcoesDaOpcao5\');");';
			
	}
	else if($operacao =='ALTERAR_BORDERO'){

		$selecionados = isset($_POST["selecionados"]) ? $_POST["selecionados"] : array();
		if(count($selecionados)==0){
			exibeErro("Selecione ao menos um t&iacute;tulo");
			exit;
		}
		$selecionados = implode($selecionados,",");
		if(!$nrborder || $nrborder==''){
			exibeErro("Selecione um border&ocirc;");
			exit;
		}

		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <tpctrlim>3</tpctrlim>";
	    $xml .= "   <insitlim>2</insitlim>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	    $xml .= "   <nrnosnum>".$selecionados."</nrnosnum>";
	    $xml .= "   <nrborder>".$nrborder."</nrborder>";
	    $xml .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	    $xml .= " </Dados>";
	    $xml .= "</Root>";

	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","ALTERAR_TITULOS_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);

	    // Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
	       echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","hideMsgAguardo();bloqueiaFundo(divRotina);");';
			exit;
		}

    	$dados = $xmlObj->roottag->tags[0];

			
	    echo 'showError("inform","'.$xmlObj->roottag->tags[0]->tags[0]->cdata.'","Alerta - Ayllos","carregaBorderosTitulos();dscShowHideDiv(\'divOpcoesDaOpcao2\',\'divOpcoesDaOpcao1;divOpcoesDaOpcao3;divOpcoesDaOpcao4;divOpcoesDaOpcao5\');");';
			
	}

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		// exit();
	}

	function exibeErroNew($msgErro,$nmdcampo) {
	    echo 'hideMsgAguardo();';
	    if ($nmdcampo <> ""){
	        $nmdcampo = '$(\'#'.$nmdcampo.'\', \'#frmTab052\').focus();';
	    }
	    $msgErro = str_replace('"','',$msgErro);
	    $msgErro = preg_replace('/\s/',' ',$msgErro);
	    
	    echo 'showError("error","' .$msgErro. '","Alerta - Ayllos","liberaCampos(); '.$nmdcampo.'");'; 
	    exit();
	}

?>