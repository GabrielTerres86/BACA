<?
/*!
 * FONTE        : manter_rotina.php 
 * CRIAÇÃO      : Alex Sandro (GFT)
 * DATA CRIAÇÃO : 15/02/2018
 * OBJETIVO     : Descrição da rotina
 * --------------
 * ALTERAÇÕES   : 12/04/2018 - Inclusão da rotina 'REALIZAR_MANUTENCAO_LIMITE'. (Leonardo Oliveira - GFT)
 *				  15/04/2018 - Inclusão da rotina 'BUSCAR_ACIONAMENTOS_PROPOSTA'. (Leonardo Oliveira - GFT)
 *				  19/04/2018 - Correção das funções para voltar para a tela anterior, utilizando a função 'fecharRotinaGenerico'que verifica se é um contrato ou proposta em questão. (Leonardo Oliveira - GFT)
 *				  24/04/2018 - Mensagem de retorno da análise. (Leonardo Oliveira - GFT)
 *				  25/04/2018 - Adicionada variável $inctrmnt em REALIZAR_MANUTENCAO_LIMITE. (Andre Avila - GFT)
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

	require_once("../../../includes/carrega_permissoes.php");
	
	setVarSession("opcoesTela",$opcoesTela);

	//operacao VER QUAIS SERÃO ENVIADAS.

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	

		switch ($_POST['operacao']){

		case 'ACEITAR_REJEICAO_LIMITE': 

			if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X")) <> "") {

				exibeErro($msgError);		
			}	
	
		break; 

	
		case 'ENVIAR_ANALISE': 

			if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {

				exibeErro($msgError);		
			}	
	
		break; 

		
		case 'CONFIMAR_NOVO_LIMITE': 

			if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"F")) <> "") {

				exibeErro($msgError);		
			}	
	
		break; 

		}


	// parâmetos do POST em variáveis
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ;
	$nrctrlim = (isset($_POST['nrctrlim'])) ? $_POST['nrctrlim'] : 0 ;
	$nrctrmnt = (isset($_POST['nrctrmnt'])) ? $_POST['nrctrmnt'] : 0 ;
	$insitlim = (isset($_POST['insitlim'])) ? $_POST['insitlim'] : '' ;
	$dssitest = (isset($_POST['dssitest'])) ? $_POST['dssitest'] : '' ;
	$insitapr = (isset($_POST['insitapr'])) ? $_POST['insitapr'] : '' ;
	$vllimite = (isset($_POST['vllimite'])) ? $_POST['vllimite'] : 0 ;
	$cddopera = (isset($_POST['cddopera'])) ? $_POST['cddopera'] : 0 ;
	$nrinssac = (isset($_POST['nrinssac'])) ? $_POST['nrinssac'] : '' ;
	$vltitulo = (isset($_POST['vltitulo'])) ? $_POST['vltitulo'] : '' ;
	$dtvencto = (isset($_POST['dtvencto'])) ? $_POST['dtvencto'] : '' ;
	$nrnosnum = (isset($_POST['nrnosnum'])) ? $_POST['nrnosnum'] : '' ;
	$cddlinha = (isset($_POST['cddlinha'])) ? $_POST['cddlinha'] : 0  ;
	$form 	  = (isset($_POST['frmOpcao'])) ? $_POST['frmOpcao'] : '' ;
	$nrborder = (isset($_POST['nrborder'])) ? $_POST['nrborder'] : '' ;
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : '1' ;
	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : '50' ;

	$tipo = (isset($_POST['tipo'])) ? $_POST['tipo'] : 'CONTRATO' ;

	$inctrmnt = (isset($_POST['inctrmnt'])) ? $_POST['inctrmnt'] : 0;






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


	    /****/
	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","ENVIAR_ESTEIRA_DESCT", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);

		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){  
           echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Aimaro","bloqueiaFundo(divRotina); fecharRotinaGenerico(\'PROPOSTA\');");';           
           exit;
		}
		
		$oMensagem = getByTagName($xmlObj->roottag->tags,'dsmensag');
        $arMessage = explode("###", $oMensagem);
        //dsmensag1
        $dsmensag1 = $arMessage[0];
        $dsmensag1 = '<div style=\"text-align:left;\">'.$dsmensag1.'</div>';
        //dsmensag2
        $dsmensag2 = '';
        if (count($arMessage) > 1) {
            $dsmensag2 = $arMessage[1];
            $dsmensag2 = str_replace('[APROVAR]',  '<img src=\"../../../imagens/geral/motor_APROVAR.png\"  height=\"20\" width=\"20\" style=\"vertical-align:middle;margin-bottom:2px;\">', $dsmensag2);
            $dsmensag2 = str_replace('[DERIVAR]',  '<img src=\"../../../imagens/geral/motor_DERIVAR.png\"  height=\"20\" width=\"20\" style=\"vertical-align:middle;margin-bottom:2px;\">', $dsmensag2);
            $dsmensag2 = str_replace('[INFORMAR]', '<img src=\"../../../imagens/geral/motor_INFORMAR.png\" height=\"20\" width=\"20\" style=\"vertical-align:middle;margin-bottom:2px;\">', $dsmensag2);
            $dsmensag2 = str_replace('[REPROVAR]', '<img src=\"../../../imagens/geral/motor_REPROVAR.png\" height=\"20\" width=\"20\" style=\"vertical-align:middle;margin-bottom:2px;\">', $dsmensag2);
            $dsmensag2 = '<div style=\"text-align:left; height:100px; overflow-x:hidden; padding-right:25px; font-size:11px; font-weight:normal;\">'.$dsmensag2.'</div>';
        }

        echo 'showError("inform","'.$dsmensag1.$dsmensag2.'","Alerta - Aimaro","bloqueiaFundo(divRotina); fecharRotinaGenerico(\'PROPOSTA\');");';
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
	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","SENHA_ENVIAR_ESTEIRA", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);

		$registros = $xmlObj->roottag->tags[0]->tags;
		
	    // Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){  
           echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Aimaro","bloqueiaFundo(divRotina);fecharRotinaGenerico(\'PROPOSTA\');");';           
           exit;
		}
		if($xmlObj->roottag->tags[0]){
			echo 'showError("inform","'.$xmlObj->roottag->tags[0]->cdata.'","Alerta - Aimaro","bloqueiaFundo(divRotina);fecharRotinaGenerico(\'PROPOSTA\');");';
		} else{
			echo 'showError("inform","An&aacute;lise enviada com sucesso!","Alerta - Aimaro","bloqueiaFundo(divRotina);fecharRotinaGenerico(\'PROPOSTA\');");';
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



	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","CONFIRMAR_NOVO_LIMITE_TIT", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");


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
				echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); fecharRotinaGenerico(\'PROPOSTA\');");';
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
	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","ACEITAR_REJEICAO_LIM_TIT", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
				echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - 	Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); fecharRotinaGenerico(\'PROPOSTA\');");';
				exit;
			} // OK
		}// != ERROR
		
	}else if ($operacao == 'BUSCAR_PAGADOR'){
		if (!validaInteiro($nrdconta) || $nrdconta == 0) exibirErro('error','Informe o número da conta.','Alerta - Aimaro','$(\'#nrdconta\', \'#'.$form.'\').focus()',false);
		if (!validaInteiro($nrinssac) || $nrinssac == 0) exibirErro('error','Informe o número do CPF/CNPJ.','Alerta - Aimaro','$(\'#nrinssac\', \'#'.$form.'\').focus()',false);
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<nrinssac>".$nrinssac."</nrinssac>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		$xmlResult = mensageria($xml, "COBRAN", "COBR_OBTER_PAGADOR", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto 	= getObjectXML($xmlResult);		

		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
			$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
			exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'#nmdsacad\', \'#'.$form.'\').val(\'\');$(\'#nrinssac\', \'#'.$form.'\').val(\'\').focus()',false);
		} 
			
		$nmdsacad	= getByTagname($xmlObjeto->roottag->tags[0]->tags,'nmdsacad');
		$vlpercen	= getByTagname($xmlObjeto->roottag->tags[0]->tags,'vlpercen');

		echo "$('#nmdsacad', '#$form').val('$nmdsacad');";
		echo "$('#vlpercen', '#$form').val('$vlpercen');";
		echo "controlaOpcao();";

	}else if ($operacao == 'BUSCAR_TITULOS_BORDERO'){

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
	    $xml .= "	<nriniseq>".$nriniseq."</nriniseq>";
	    $xml .= "	<nrregist>".$nrregist."</nrregist>";
		$xml .= "	<insitlim>2</insitlim>";
		$xml .= "	<tpctrlim>3</tpctrlim>";
	    $xml .= " </Dados>";
	    $xml .= "</Root>";

	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","BUSCAR_TITULOS_BORDERO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getClassXML($xmlResult);
    	$root = $xmlObj->roottag;

	    // Se ocorrer um erro, mostra crítica
		if ($root->erro){
			echo '<script>';
			exibeErro(htmlentities($root->erro->registro->dscritic));
			echo '</script>';
			exit;
		}
    	$dados = $root->dados;
    	
        $qtregist = $dados->getAttribute('QTREGIST');
    	if($qtregist>0){
	    	$html = "<table class='tituloRegistros'>";
			$html .= 	"<thead>
								<tr>
									<th>Conv&ecirc;nio</th>
									<th>Boleto n&ordm;</th>
									<th>Pagador</th>
									<th>Vencimento</th>
									<th>Valor</th>
									<th>Cr&iacute;ticas</th>
									<th>Selecionar</th>
								</tr>
							</thead>
							<tbody>
					";
	    	foreach($dados->find("inf") AS $t){
	    		$html .= "<tr id='titulo_".$t->nrnosnum."'>";
	    		$html .=	"<td>
	    						<input type='hidden' name='vltituloselecionado' value='".formataMoeda($t->vltitulo)."'/>
	    						<input type='hidden' name='selecionados' value='".$t->cdbandoc.";".$t->nrdctabb.";".$t->nrcnvcob.";".$t->nrdocmto."'/>".$t->nrcnvcob."
	    					</td>";
	    		$html .=	"<td>".$t->nrdocmto."</td>";
	    		$html .=	"<td>".$t->nrinssac.' - '.$t->nmdsacad."</td>";
	    		$html .=	"<td>".$t->dtvencto."</td>";
	    		$html .=	"<td><span>".converteFloat($t->vltitulo)."</span>".formataMoeda($t->vltitulo)."</td>";
	    		$sit = $t->dssituac;
	    		if ($sit=="N") {
		    		$html .=	"<td>N&atilde;o</td>";
	    		}
	    		elseif ($sit=="S") {
		    		$html .=	"<td>Sim</td>";
	    		}
	    		else{
		    		$html .=	"<td class='titulo-nao-analisado'>N&atilde;o Analisado</td>";
	    		}
	    		$html .=	"<td class='botaoSelecionar' onclick='incluiTituloBordero(this);'><button type='button' class='botao'>Incluir</button></td>";
	    		$html .= "</tr>";
	    	}
	    	$html .= "</tbody>
	    			</table>";

	    	//Rodape paginação
	    	$html .= "<div id='divPesquisaRodape' class='divPesquisaRodape'>
						<table>	
							<tr>
								<td>";
			//Cria o botão de voltar								
			if ($nriniseq > 1) { 
			 	$html .= "         <a class='paginacaoAnt'><<< Anterior</a>";
			} else {
				$html .=           "&nbsp;";
			}
			$html .=            "</td>
			      			 	 <td>";
			//De - Até      			 	 
			if (isset($nriniseq)) { 
				if (($nriniseq + $nrregist) > $qtregist){
					$qtnumregist = $qtregist;
				}else{
					$qtnumregist .= ($nriniseq + $nrregist - 1);
				}
				$html .=          "Exibindo ".$nriniseq." at&eacute ".$qtnumregist." de ".$qtregist;
			}
			$html .=           "</td>
								<td>";

			//Cria o botão de Avançar									
			if ($qtregist > ($nriniseq + $nrregist - 1)) {
				$html .= "<a class='paginacaoProx'>Pr&oacute;ximo >>></a>";
			}else{
				$html .=           "&nbsp;";
			}
			$html .=            "</td>
						    </tr>
						</table>
					</div>";

			//Javascript da paginação		
	        $html .= "<script>";
	        $html .= "$('a.paginacaoAnt').unbind('click').bind('click', function() {
						buscarTitulosBorderoPaginacao(".($nriniseq - $nrregist).",".$nrregist.");
					  });";
			$html .= "$('a.paginacaoProx').unbind('click').bind('click', function() {
						buscarTitulosBorderoPaginacao(".($nriniseq + $nrregist).",".$nrregist.");
					  });";
			$html .= "</script>";
	    	echo $html;
	    }
	    else{
			echo '<script>';
			exibeErro("N&atilde;o foi encontrado nenhum t&iacute;tulo utilizando esses filtros.");
			echo 'setTimeout(function(){bloqueiaFundo($("#divError"))},1)';

			echo '</script>';
	    }
    	exit();
	
	}else if ($operacao == 'INSERIR_BORDERO'){
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
	    $xml .= "   <chave>".$selecionados."</chave>";
	    $xml .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	    $xml .= " </Dados>";
	    $xml .= "</Root>";

	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","INSERIR_TITULOS_BORDERO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);

	    // Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
	       echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Aimaro","hideMsgAguardo();bloqueiaFundo(divRotina);");';
			exit;
		}

    	$dados = $xmlObj->roottag->tags[0];
    	$nrborder = $dados->tags[1]->cdata;
    	$flrestricao = $dados->tags[2]->cdata;
    	$arrInsert['msg'] = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->cdata);
    	$arrInsert['nrborder'] = $nrborder;
    	$arrInsert['flrestricao'] = $flrestricao;

		echo json_encode($arrInsert);
			
	}else if ($operacao == 'REALIZAR_MANUTENCAO_LIMITE'){

		// Verifica se a proposta é maior ou menor que o contrato vigente.
		if( isset($inctrmnt) && $inctrmnt != 1 ){

			// Monta o xml de requisição
			$xmlGetDados = "";
			$xmlGetDados .= "<Root>";
			$xmlGetDados .= "	<Cabecalho>";
			$xmlGetDados .= "		<Bo>b1wgen0030.p</Bo>";
			$xmlGetDados .= "		<Proc>realizar_manutencao_contrato</Proc>";
			$xmlGetDados .= "	</Cabecalho>";
			$xmlGetDados .= "	<Dados>";
			$xmlGetDados .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
			$xmlGetDados .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
			$xmlGetDados .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
			$xmlGetDados .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
			$xmlGetDados .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
			$xmlGetDados .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
			$xmlGetDados .= "		<nrdconta>".$nrdconta."</nrdconta>";
			$xmlGetDados .= "		<idseqttl>1</idseqttl>";
			$xmlGetDados .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
			$xmlGetDados .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
			$xmlGetDados .= "		<vllimite>".$vllimite."</vllimite>";
			$xmlGetDados .= "		<cddlinha>".$cddlinha."</cddlinha>";
			$xmlGetDados .= "	</Dados>";
			$xmlGetDados .= "</Root>";

			// Executa script para envio do XML
			$xmlResult = getDataXML($xmlGetDados);

			// Cria objeto para classe de tratamento de XML
			$xmlObjDados = getObjectXML(retiraAcentos(removeCaracteresInvalidos($xmlResult)));
			
		    // Se ocorrer um erro, mostra mensagem
			if (strtoupper($xmlObjDados->roottag->tags[0]->name) == 'ERRO') {
		       echo 'showError("error","'.$xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Aimaro","mostrarBorderoResumo();hideMsgAguardo();bloqueiaFundo(divRotina);");';
				exit;
			}
			$dados = $xmlObjDados->roottag->tags[0]->tags[0]->tags;

			$per_vllimite = number_format(str_replace(",",".",$dados[15]->cdata),2,",","");
			$per_cddlinha = formataNumericos('zz9',$dados[17]->cdata,'.');

			if($vllimite > $per_vllimite){
				echo 'showError("inform","Proposta de majora&ccedil;&atilde;o criada com sucesso","Alerta - Aimaro","'
		    	.'voltaDiv(2,1,4,\'DESCONTO DE T&Iacute;TULOS\',\'DSC TITS\');'
		    	.'carregaTitulos();");';
			} else {
				echo 'showError("inform","Manuten&ccedil;&atilde;o do contrato realizada com sucesso","Alerta - Aimaro","'
		    	.'voltaDiv(2,1,4,\'DESCONTO DE T&Iacute;TULOS\',\'DSC TITS\');'
		    	.'carregaTitulos();");';
			}


		} else {

			$xml = "<Root>";
		    $xml .= " <Dados>";
		    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	   	    $xml .= "	<nrctrlim>".$nrctrlim."</nrctrlim>";
	   	    $xml .= "   <tpctrlim>3</tpctrlim>";
		    $xml .= "   <vllimite>".converteFloat($vllimite)."</vllimite>";
			$xml .= "	<cddlinha>".$cddlinha."</cddlinha>";
		    $xml .= " </Dados>";
		    $xml .= "</Root>";

		    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","ALTERAR_PROPOSTA_MANUTENCAO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

		    $xmlObj = getObjectXML($xmlResult);

		    // Se ocorrer um erro, mostra mensagem
			if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
		       echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Aimaro","hideMsgAguardo();bloqueiaFundo(divRotina);");';
				exit;

			} else {

		    	echo 'showError("inform","'.$xmlObj->roottag->tags[0]->cdata.'","Alerta - Aimaro","bloqueiaFundo(divRotina); fecharRotinaGenerico(\'PROPOSTA\');");';
			}
		}
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
	    $xml .= "   <chave>".$selecionados."</chave>";
	    $xml .= "   <nrborder>".$nrborder."</nrborder>";
	    $xml .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	    $xml .= " </Dados>";
	    $xml .= "</Root>";

	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","ALTERAR_TITULOS_BORDERO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);

	    // Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
	       echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Aimaro","hideMsgAguardo();bloqueiaFundo(divRotina);");';
			exit;
		}

    	$dados = $xmlObj->roottag->tags[0];
    	$arrAlterar['msg'] = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->cdata);

		echo json_encode($arrAlterar);	
	}else if ($operacao =='BUSCAR_TITULOS_RESGATE'){

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

	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","BUSCAR_TITULOS_RESGATE", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getClassXML($xmlResult);
	    $root = $xmlObj->roottag;
	    // Se ocorrer um erro, mostra crítica
		if ($root->erro){
			echo '<script>';
			exibeErro(htmlentities($root->erro->registro->dscritic));
			echo '</script>';
			exit;
		}

    	$dados = $root->dados;
        $qtregist = $dados->getAttribute("QTREGIST");
    	if($qtregist>0){
	    	$html = "<table class='tituloRegistros'>";
			$html .= 	"<thead>
								<tr>
									<th>Conv&ecirc;nio</th>
									<th>Boleto n&ordm;</th>
									<th>Pagador</th>
									<th>Vencimento</th>
									<th>Valor</th>
									<th>Border&ocirc;</th>
									<th>Selecionar</th>
								</tr>
							</thead>
							<tbody>
					";
	    	foreach($dados->tags AS $t){
	    		$html .= "<tr id='titulo_".$t->nrnosnum."'>";
	    		$html .=	"<td>
	    						<input type='hidden' name='vltituloselecionado' value='".formataMoeda($t->vltitulo)."'/>
	    						<input type='hidden' name='selecionados' value='".$t->cdbandoc.";".$t->nrdctabb.";".$t->nrcnvcob.";".$t->nrdocmto."'/>".$t->nrcnvcob."
	    					</td>";
	    		$html .=	"<td>".$t->nrdocmto."</td>";
	    		$html .=	"<td>".$t->nrinssac.' - '.$t->nmdsacad."</td>";
	    		$html .=	"<td>".$t->dtvencto."</td>";
	    		$html .=	"<td><span>".converteFloat($t->vltitulo)."</span>".formataMoeda($t->vltitulo)."</td>";
	    		$html .=	"<td>".$t->nrborder."</td>";
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
	}
	else if($operacao =='RESGATAR_TITULOS'){

		$selecionados = isset($_POST["selecionados"]) ? $_POST["selecionados"] : array();
		if(count($selecionados)==0){
			exibeErro("Selecione ao menos um t&iacute;tulo");
			exit;
		}
		$selecionados = implode($selecionados,",");

		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <nrctrlim>".$nrctrlim."</nrctrlim>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	    $xml .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	    $xml .= "	<dtmvtoan>".$glbvars["dtmvtoan"]."</dtmvtoan>";
	    $xml .= "	<dtresgat>".$glbvars["dtmvtolt"]."</dtresgat>";
	    $xml .= "	<inproces>".$glbvars["inproces"]."</inproces>";
	    $xml .= "   <chave>".$selecionados."</chave>";
	    $xml .= " </Dados>";
	    $xml .= "</Root>";

	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","RESGATAR_TITULOS_BORDERO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getClassXML($xmlResult);
	    $root = $xmlObj->roottag;
	    // Se ocorrer um erro, mostra crítica
		if ($root->erro){
			exibeErro(htmlentities($root->erro->registro->dscritic));
			exit;
		}

    	$dados = $root->dados;

			
	    echo 'showError("inform","'.$dados.'","Alerta - Aimaro","carregaTitulos();voltaDiv(3,1,5,\'DESCONTO DE T&Iacute;TULOS - BORDEROS\');");';
			
	}else if($operacao =='BUSCAR_ACIONAMENTOS_PROPOSTA'){


    	$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
		$xml .= "   <nrctrmnt>" . $nrctrmnt . "</nrctrmnt>";
		$xml .= "   <nrctremp>" . $nrctrlim . "</nrctremp>";
		$xml .= "   <tpproduto>3</tpproduto>";
		$xml .= "   <dtinicio>01/01/0001</dtinicio>";
		$xml .= "   <dtafinal>31/12/9999</dtafinal>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "CONPRO", "CONPRO_ACIONAMENTO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
		$html = '';

		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
			//SE FOR UMA PROPOSA CASO NÃO RETORNE ACIONAMENTOS ELE VOLTA 
			if($tipo == 'PROPOSTA'){
				$html .= '<script type="text/javascript">';
				$html .= '    hideMsgAguardo();';
				$html .= '    bloqueiaFundo(divRotina);';
				$html .= '    showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Aimaro","bloqueiaFundo(divRotina);fecharRotinaGenerico(\''.$tipo.'\');");';
				$html .='</script>';
			} else { // CASO SEJA CONTRATO E NÃO TENHA ACIONAMENTO ELE PERMANECE NA TELA 
				$html .= '<script type="text/javascript">';
				$html .= '    hideMsgAguardo();';
				$html .= '    bloqueiaFundo(divRotina);';
				$html .= '    showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Aimaro","bloqueiaFundo(divRotina);");';
				$html .= '</script>';
			}
			$html .=  '<legend id="tabConteudoLegend" ><b>'. utf8ToHtml('Detalhes Proposta: ').formataNumericos("zzz.zz9",$nrctrlim,".").'</b></legend>';
			$html .= '<div id="divAcionamento" class="divRegistros">';
			$html .= '<table class="tituloRegistros">';
	      	$html .= '    <thead>';
	        $html .= '        <tr>';
	        $html .= '            <th>'.utf8ToHtml('Acionamento').'</th>';
	        $html .= '            <th>'.utf8ToHtml('PA').'</th>';
	        $html .= '            <th>'.utf8ToHtml('Operador').'</th>';
	        $html .= '            <th>'.utf8ToHtml('Operação').'</th>';
	        $html .= '            <th>'.utf8ToHtml('Data e Hora').'</th>';
	        $html .= '            <th>'.utf8ToHtml('Retorno').'</th>';
	        $html .= '        </tr>';
	        $html .= '    </thead>';
	     	$html .= '    <tbody>';
	     	$html .= '   </tbody>';
		    $html .= '</table>';
		    $html .= '</div>';
		    echo $html;
		    exit;
		}

		$registros = $xmlObj->roottag->tags[0]->tags;
		$qtregist = $xmlObj->roottag->tags[1]->cdata;

		$html .= '<script type="text/javascript">';
		$html .= '    hideMsgAguardo();';
		$html .= '    bloqueiaFundo(divRotina);';
		$html .= '</script>';

		$html .= '<legend id="tabConteudoLegend" ><b>'. utf8ToHtml('Detalhes Proposta: ').formataNumericos("zzz.zz9",$nrctrlim,".").'</b></legend>';
		$html .= '<div id="divAcionamento" class="divRegistros">';
		$html .= '<table class="tituloRegistros">';
      	$html .= '    <thead>';
        $html .= '        <tr>';
        $html .= '            <th>'.utf8ToHtml('Acionamento').'</th>';
        $html .= '            <th>'.utf8ToHtml('PA').'</th>';
        $html .= '            <th>'.utf8ToHtml('Operador').'</th>';
        $html .= '            <th>'.utf8ToHtml('Operação').'</th>';
        $html .= '            <th>'.utf8ToHtml('Data e Hora').'</th>';
        $html .= '            <th>'.utf8ToHtml('Retorno').'</th>';
        $html .= '        </tr>';
        $html .= '    </thead>';
     	$html .= '    <tbody>';
     	 
	    foreach ($registros as $r) {
	            $dsoperacao = wordwrap(getByTagName($r->tags, 'operacao'),40, "<br />\n");
	            $dsprotocolo = getByTagName($r->tags, 'dsprotocolo');
	            if ($dsprotocolo) {
	                $dsoperacao = '<a href="#" onclick="abreProtocoloAcionamento(\''.$dsprotocolo.'\');" style="font-size: inherit">'.$dsoperacao.'</a>';
	             }

	            $html .= '    <tr>';
	            $html .= '        <td>'. getByTagName($r->tags, 'acionamento') .'</td>';
	            $html .= '        <td>'. getByTagName($r->tags, 'nmagenci') .'</td>';
	            $html .= '        <td>'. getByTagName($r->tags, 'cdoperad') .'</td>';
	            $html .= '        <td>'.$dsoperacao.'</td>';
	            $html .= '        <td>'. getByTagName($r->tags, 'dtmvtolt') .'</td>';
	            $html .= '        <td>'.wordwrap(getByTagName($r->tags, 'retorno'),40, "<br />\n").'</td>';
	            $html .= '    </tr>';
	    }

	    $html .= '   </tbody>';
	    $html .= '</table>';
	    $html .= '</div>';
	    //$html .= '<input type="hidden" name="qtregist" id="qtregist" value="'.$qtregist.'" />';

	    echo $html;
	}else if($operacao == 'CALCULAR_SALDO_TITULOS_VENCIDOS'){
		$nrdconta     = $_POST['nrdconta'];
		$nrborder    = $_POST['nrborder'];
		$arr_nrdocmto = implode(',', $_POST['arr_nrdocmto']);

		$xml =  "<Root>";
		$xml .= " <Dados>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<nrborder>".$nrborder."</nrborder>";
		$xml .= "		<arrtitulo>".$arr_nrdocmto."</arrtitulo>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "TELA_ATENDA_DESCTO", "CALCULA_POSSUI_SALDO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getClassXML($xmlResult);
	    $root = $xmlObj->roottag;
	    // Se ocorrer um erro, mostra crítica
		if ($root->erro){
			exibeErro(htmlentities($root->erro->registro->dscritic));
			exit;
		}
		$dados = $root->dados;

		//Pega o saldo de retorno
		foreach($dados->find("inf") as $t){
			$possui_saldo = $t->possui_saldo;
		}
		
		//Se possuir saldo positivo o retorno é 1 senão 0
		echo $possui_saldo;

	}else if($operacao == 'CALCULAR_SALDO_TITULOS_PREJUIZO'){
		$nrdconta    = $_POST['nrdconta'];
		$nrborder    = $_POST['nrborder'];
		$vlaboprj    = isset($_POST['vlaboprj']) ? converteFloat($_POST['vlaboprj']) : 0;
		$vlpagmto    = isset($_POST['vlpagmto']) ? converteFloat($_POST['vlpagmto']) : 0;

		$xml =  "<Root>";
		$xml .= " <Dados>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<nrborder>".$nrborder."</nrborder>";
		$xml .= "		<vlaboprj>".$vlaboprj."</vlaboprj>";
		$xml .= "		<vlpagmto>".$vlpagmto."</vlpagmto>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "DSCT0003", "CALCULA_POSSUI_SALDO_PREJUIZO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getClassXML($xmlResult);
	    $root = $xmlObj->roottag;
	    // Se ocorrer um erro, mostra crítica
		if ($root->erro){
			exibeErro(htmlentities($root->erro->registro->dscritic));
			exit;
		}
		$dados = $root->dados;

		$json = array();
		$json["possui_saldo"] = $dados->inf->possui_saldo->cdata;
		
		//Se possuir saldo positivo o retorno é 1 senão 0
		echo json_encode($json);

	}else if($operacao == 'PAGAR_PREJUIZO'){
		$nrdconta    = $_POST['nrdconta'];
		$nrborder    = $_POST['nrborder'];
		$vlaboprj    = isset($_POST['vlaboprj']) ? converteFloat($_POST['vlaboprj']) : 0;
		$vlpagmto    = isset($_POST['vlpagmto']) ? converteFloat($_POST['vlpagmto']) : 0;

		$xml =  "<Root>";
		$xml .= " <Dados>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<nrborder>".$nrborder."</nrborder>";
		$xml .= "		<vlaboprj>".$vlaboprj."</vlaboprj>";
		$xml .= "		<vlpagmto>".$vlpagmto."</vlpagmto>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "DSCT0003", "PAGAR_PREJUIZO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getClassXML($xmlResult);
	    $root = $xmlObj->roottag;
	    // Se ocorrer um erro, mostra crítica
		if ($root->erro){
			exibeErro(htmlentities($root->erro->registro->dscritic));
			exit;
		}
		$dados = $root->dados;

		$json = array();
		$json["mensagem"] = $dados->cdata;
		
		//Se possuir saldo positivo o retorno é 1 senão 0
		echo json_encode($json);

	}else if($operacao == 'PAGAR_TITULOS_VENCIDOS'){
		$nrdconta     = $_POST['nrdconta'];
		$nrborder     = $_POST['nrborder'];
		$fl_avalista  = $_POST['fl_avalista'];
		$arr_nrdocmto = implode(',', $_POST['arr_nrdocmto']);

		$xml =  "<Root>";
		$xml .= " <Dados>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<nrborder>".$nrborder."</nrborder>";
		$xml .= "		<flavalista>".$fl_avalista."</flavalista>";
		$xml .= "		<arrtitulo>".$arr_nrdocmto."</arrtitulo>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "TELA_ATENDA_DESCTO", "PAGAR_TITULOS_VENCIDOS", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getClassXML($xmlResult);
	    $root = $xmlObj->roottag;
	    // Se ocorrer um erro, mostra crítica
		if ($root->erro){
			exibeErro(htmlentities($root->erro->registro->dscritic));
			exit;
		}

		//OK caso retorne com sucesso
		echo $root->dsmensag;
	}

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 

		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

	function exibeErroNew($msgErro,$nmdcampo) {
	    echo 'hideMsgAguardo();';
	    if ($nmdcampo <> ""){
	        $nmdcampo = '$(\'#'.$nmdcampo.'\', \'#frmTab052\').focus();';
	    }
	    $msgErro = str_replace('"','',$msgErro);
	    $msgErro = preg_replace('/\s/',' ',$msgErro);
	    
	    echo 'showError("error","' .$msgErro. '","Alerta - Aimaro","liberaCampos(); '.$nmdcampo.'");'; 
	    exit();
	}

?>