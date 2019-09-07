<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 08/02/2010
 * OBJETIVO     : Mostrar opcao Principal da rotina de Emprestimos da tela ATENDA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [08/08/2011] Adicionado rotinas de obtenção de dados e aprovação de proposta. Marcelo L. Pereira (GATI)
 * 001: [10/11/2011] Adicionado rotinas da tabela de rating - Marcelo L. Pereira (GATI)
 * 002: [29/11/2011] Ajuste para a inclusao do campo Justificativa. (Adriano).
 * 003: [05/06/2011] Ajuste na alteracao e inclusao de emprestimo (Tiago).
 * 004: [09/04/2012] Incluir campo dtlibera (Gabriel)
 * 005: [12/06/2012] Mostrar tela de liquidacoes de contratos no comeco da proposta (Gabriel)
 * 006: [16/09/2013] Incluido xml para funcionamento do novo botão "Registrar Gravames" (André Euzébio / Supero).
 * 007: [26/11/2013] Incluido o parametro 'false' na funcao validaPermissao (Guilherme/SUPERO)
 * 008: [03/01/2014] Adicionado condição para desabilitar campo "Imprime/NaoImprime" de nota promissoria. (Jorge)
 * 009: [20/02/2014] Adicionado replace de caracter "'" e eubra de linha em campos "ds" (descricao) e "nm" nomes vindos da base de dados para nao ocorrer quebra de js. (Jorge)
 * 010: [25/02/2014] Criado funcao para retirar caracteres que causam quebra de js. (Jorge)
 * 011: [21/03/2014] Adicionado idseqbem no ArrayAlienacoes (Guilherme/SUPERO)
 * 012: [29/04/2014] GRAVAMES - Se operacao 'TE' direciona para o ControlaOperacao inicial (Guilherme/SUPERO)
 * 013: [15/07/2014] Incluso novos campos( inpessoa e dtnascto ) na carga avalista (Daniel).
 * 014: [08/09/2014] Projeto Automatização de Consultas em Propostas de Crédito (Jonata-RKAM).
 * 015: [16/12/2014] Retirado código lixo, titulo da mensagem de erro. (Jorge/Gielow) - SD 230769.
 * 016: [05/02/2015] Adiicionado campo dstipbem, "Tipo Veiculo". (Jorge/Gielow) - SD 241854
 * 017: [08/04/2015] Consultas automatizadas para o limite de credito (Jonata-RKAM).
 * 018: [20/05/2015] Projeto Cessão de Crédito. (James)
 * 019: [28/05/2015] Alterado para apresentar mensagem de confirmacao para cooperados menores de idade nao emancipados. (Reinert)
 * 020: [10/07/2015] Adicionado operacao PORTAB_CRED_A. (Reinert)
 * 021: [16/07/2015] Tratamento para remover caracteres especiais e acentos conforme relatado o chamado 301458. (Kelvin)
 * 022: [10/08/2015] Incluido xml para funcionamento do novo botão "Recalcular" (James).
 * 023: [15/10/2015] Alteracao no retorno da execucao do RECALCULAR_EMPRESTIMO. (Jaison/Oscar)
 * 024: [01/03/2016] PRJ Esteira de Credito. (Jaison/Oscar)
 * 025: [23/03/2016] PRJ Esteira de Credito. (Daniel/Oscar)
 * 026: [14/07/2016] Correcao na forma de recuperacao dos dados do array $_POST. SD 479874 (Carlos Rafael Tanholi).
 * 026: [19/10/2016] Incluido registro de log sobre liberacao de alienacao de bens 10x maior que o valor do emprestimo, SD-507761 (Jean Michel)
 * 027: [12/05/2017] Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
 * 028: [26/06/2017] Ajuste para rotina ser chamada através da tela ATENDA > Produtos (P364).
 * 029: [10/07/2017] Criacao do insitest no arrayProposta. (Jaison/Marcos Martini - PRJ337)
 * 030: [20/09/2017] Projeto 410 - Incluir campo Indicador de financiamento do IOF (Diogo - Mouts)
 * 031: [01/12/2017] Não permitir acesso a opção de incluir quando conta demitida (Jonata - RKAM P364).
 * 032: [17/12/2017] Inserção do campo idcobope. PRJ404 (Lombardi)
 * 033: [26/01/2018] Alteração para exibição do nível de risco original (Reginaldo - AMcom).
 * 034: [05/03/2018] Inclusão do campo idcobope no array arrayStatusApprov. PRJ404 (Reinert)
 * 035: [13/04/2018] Adicionada verificacao se Tipo de Conta permite empréstimo. PRJ366 (Lombardi).
 * 036: [12/04/2018] P410 - Melhorias/Ajustes IOF (Marcos-Envolti)
 * 037: [16/05/2018] Alterada frase de retorno da verificacao do Tipo de Conta. PRJ366 (Lombardi)
 * 038: [14/12/2017] Inclusão dos campos: flintcdc e inintegra_cont no array de propostas, Prj. 402 (Jean Michel).
 * 039: [19/10/2018] Ajestes nas regras I_PROT_CRED e A_PROT_CRED - Bruno Luiz Katzjarowski - Mout's - PRJ 438
 * 040: [24/10/2018] Remover tela de rendimentos e bens - Bruno Luiz Katzjarowski - Mout's - PRJ 438
 * 041: [18/10/2018] Adicionado novos campos nas telas Avalista e Interveniente - PRJ 438. (Mateus Z / Mouts)
 * 042: [07/11/2018] Esconder tela de Dados da Proposta - Bruno luiz K. - Mout's
 * 043: [14/02/2019] Inclusão dos campos nota do rating, origem da nota e status da análise P450 (Luiz Otávio Olinger Momm - AMCOM).
 * 044: [07/03/2019] Inclusão da consulta do parametro se a coopoerativa pode Alterar Rating P450 (Luiz Otávio Olinger Momm - AMCOM).
 * 046: [22/05/2019] Retirada do etapa Rating mantendo apenas para coop Ailos P450 (Luiz Otávio Olinger Momm - AMCOM).
 * 043: [28/06/2019] Alterado o fluxo de consulta para ao final mostrar a tela de demonstração do empréstimo PRJ 438 - Sprint 13 (Mateus Z / Mouts)
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();

	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '@';
    $nomeAcaoCall = (isset($_POST['nomeAcaoCall'])) ? $_POST['nomeAcaoCall'] : '';

    // Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Aimaro','controlaOperacao();',false);
	// Caso seja para 'Alterar Somente Avalistas' verifica a permissao para tal operacao
    } else if ($nomeAcaoCall == 'A_AVALISTA' && ($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'O',false)) <> '') {
        // Exibe o erro e Reseta a global 'nomeAcaoCall' do JS
        exibirErro('error',$msgError,'Alerta - Aimaro',"nomeAcaoCall=''; controlaOperacao();",false);
    }

	// Verifica se os parametros foram informados
	if (!isset($_POST['nrdconta']) || 
		!isset($_POST['idseqttl']) ||
		!isset($_POST["inconfir"])) 
		exibirErro('error','Parâmetros incorretos.','Alerta - Aimaro','fechaRotina(divRotina)',false);

	$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];
	$idseqttl = $_POST['idseqttl'] == '' ? 1 : $_POST['idseqttl'];
	$inconfir = $_POST["inconfir"] == '' ? 1 : $_POST["inconfir"];

	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
	$tplcremp = ( isset($_POST['tplcremp']) ) ? $_POST['tplcremp'] : '';

	// Verifica se existem informações do formulário da proposta para visualização das parcelas
	$tpemprst = (isset($_POST['tpemprst'])) ? $_POST['tpemprst'] : 0;
	$cdlcremp = (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : 0;
	$vlempres = (isset($_POST['vlempres'])) ? $_POST['vlempres'] : 0;
	$vlpreemp = (isset($_POST['vlpreemp'])) ? $_POST['vlpreemp'] : 0;
	$vlprecar = (isset($_POST['vlprecar'])) ? $_POST['vlprecar'] : 0;
	$qtparepr = (isset($_POST['qtparepr'])) ? $_POST['qtparepr'] : 0;
	$qtdialib = (isset($_POST['qtdialib'])) ? $_POST['qtdialib'] : 0;
	$dtdpagto = (isset($_POST['dtdpagto'])) ? $_POST['dtdpagto'] : 0;
	$dsctrliq = (isset($_POST['dsctrliq'])) ? $_POST['dsctrliq'] : 0;
	$executandoProdutos = $_POST['executandoProdutos'];
	$sitaucaoDaContaCrm = (isset($_POST['sitaucaoDaContaCrm'])?$_POST['sitaucaoDaContaCrm']:'');
	
	$dateArray = explode("/", $glbvars["dtmvtolt"]);
	
	// Adiciona o número de dias informado a data atual
	$dtlibera = date("d/m/Y", mktime(0, 0, 0, $dateArray[1], $dateArray[0] + $qtdialib, $dateArray[2]));

	$flgImp = 0;
	if ( $operacao == 'DIV_IMP' ) { $flgImp = 1;$operacao = ''; $nrctremp = 0;}

	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Aimaro','fechaRotina(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl inválida.','Alerta - Aimaro','fechaRotina(divRotina)',false);

	$procedure = (in_array($operacao,array('A_NOVA_PROP','A_VALOR','A_AVALISTA','A_NUMERO','TE','TI','TC','A_SOMBENS'))) ? 'obtem-dados-proposta-emprestimo' : 'obtem-propostas-emprestimo';

	if (in_array($operacao,array('A_NOVA_PROP','A_NUMERO','A_VALOR','A_AVALISTA','TI','TE','TC','','A_SOMBENS'))) {

		$xml = "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0002.p</Bo>";
		$xml .= "		<Proc>".$procedure."</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
		$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
		$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
		$xml .= "		<inconfir>".$inconfir."</inconfir>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
		$xmlResult = getDataXML($xml,true, true,0, 1);
		
		$xmlObjeto = getObjectXML(retiraAcentos(removeCaracteresInvalidos($xmlResult)));

		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {

			$mtdErro = ( $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata ) ? 'controlaOperacao();' : 'bloqueiaFundo(divRotina);';

            /** GRAVAMES - Validar exclusao **/
            if  ($operacao == 'TE') {
                $mtdErro = 'controlaOperacao();';
            }
            
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$mtdErro,false);
		}
		
		if ($operacao == "TI") {
			// Monta o xml de requisição
			$xml  = "";
			$xml .= "<Root>";
			$xml .= "	<Dados>";
			$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
			$xml .= "		<cdprodut>".   31    ."</cdprodut>";
			$xml .= "	</Dados>";
			$xml .= "</Root>";
			
			// Executa script para envio do XML
			$xmlResult = mensageria($xml, "CADA0006", "VALIDA_ADESAO_PRODUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObj = getObjectXML($xmlResult);
			
			// Se ocorrer um erro, mostra crítica
			if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") { 
				exibirErro('inform','Conta n&atilde;o permite empr&eacute;stimo. Permitido apenas inclus&atilde;o de propostas de CDC, empr&eacute;stimo consignado e linhas 100, 800, 900 e 6901.','Alerta - Aimaro',"bloqueiaFundo(divRotina);",true);
			}
		}
		
		if(in_array($operacao,array('CT','','REG_GRAVAMES','VAL_GRAVAMES'))) {
			// Montar o xml de Requisicao
			$xmlCarregaDados  = "";
			$xmlCarregaDados .= "<Root>";
			$xmlCarregaDados .= " <Dados>";
			$xmlCarregaDados .= " </Dados>";
			$xmlCarregaDados .= "</Root>";

			$xmlResult = mensageria($xmlCarregaDados
								   ,"GRVM0001"
								   ,"GRAVAME_ONLINE_HABILITADO"
								   ,$glbvars["cdcooper"]
								   ,$glbvars["cdagenci"]
								   ,$glbvars["nrdcaixa"]
								   ,$glbvars["idorigem"]
								   ,$glbvars["cdoperad"]
								   ,"</Root>");
			$xmlObject = getObjectXML($xmlResult);

			if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
				$flgGrvOnline = "ERRO";
			} else if (strtoupper($xmlObject->roottag->tags[0]->name) == "GRVONLINE") {
				$flgGrvOnline = $xmlObject->roottag->tags[0]->cdata;
			}
		}
		
		if (in_array($operacao,array(''))){

			$registros = $xmlObjeto->roottag->tags[0]->tags;
			$gerais    = $xmlObjeto->roottag->tags[1]->tags[0]->tags;

			$ddmesnov = getByTagName($gerais,'ddmesnov');
			$dtdpagt2 = getByTagName($gerais,'dtdpagto');
			$lscatbem = getByTagName($gerais,'lscatbem');
			$lscathip = getByTagName($gerais,'lscathip');

			$msgDsdidade = ( isset($xmlObjeto->roottag->tags[1]->attributes['DSDIDADE']) ) ? trim($xmlObjeto->roottag->tags[1]->attributes['DSDIDADE']) : '';

			?><script type="text/javascript">

				ddmesnov = '<? echo $ddmesnov; ?>';
				dtdpagt2 = '<? echo $dtdpagt2; ?>';
				lscatbem = '<? echo $lscatbem; ?>';
				lscathip = '<? echo $lscathip; ?>';

			</script><?php

		} else if (in_array($operacao,array('A_NOVA_PROP','A_VALOR','A_AVALISTA','A_NUMERO','TE','TI','TC','A_SOMBENS'))) {

			$cooperativa  = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
			$associado    = $xmlObjeto->roottag->tags[1]->tags[0]->tags;
			$proposta     = $xmlObjeto->roottag->tags[4]->tags[0]->tags;
			$regBensAssoc = $xmlObjeto->roottag->tags[5]->tags;
			$alienacoes	  = $xmlObjeto->roottag->tags[6]->tags;
			$rendimento   = $xmlObjeto->roottag->tags[7]->tags[0]->tags;
			$faturamentos = $xmlObjeto->roottag->tags[8]->tags;
			$analise	  = $xmlObjeto->roottag->tags[9]->tags[0]->tags;
			$intervs	  = $xmlObjeto->roottag->tags[10]->tags;
			$hipotecas    = $xmlObjeto->roottag->tags[11]->tags;
			$avalistas	  = $xmlObjeto->roottag->tags[12]->tags;
			$regBensAval  = $xmlObjeto->roottag->tags[13]->tags;
			$qtMensagens = count($xmlObjeto->roottag->tags[14]->tags);	
			$mensagem  	  = ( isset($xmlObjeto->roottag->tags[14]->tags[$qtMensagens - 1]->tags[1]->cdata) ) ? $xmlObjeto->roottag->tags[14]->tags[$qtMensagens - 1]->tags[1]->cdata : '';
			$inconfir	  = ( isset($xmlObjeto->roottag->tags[14]->tags[$qtMensagens - 1]->tags[0]->cdata) ) ? $xmlObjeto->roottag->tags[14]->tags[$qtMensagens - 1]->tags[0]->cdata : 0;
			
			if ($inconfir == 2) { ?>
				<script type="text/javascript">
				hideMsgAguardo();
				showConfirmacao("<? echo $mensagem ?>","Confirma&ccedil;&atilde;o - Aimaro","confirmaInclusaoMenor(<? echo "'".$cddopcao."','".$operacao."',".$inconfir ?>);","controlaOperacao('');metodoBlock();","sim.gif","nao.gif");
				</script>
				<?php exit();
			}

			$inpessoa 	  = getByTagName($rendimento,'inpessoa');

			// RISCO ORIGINAL
			$riscoOrig = getByTagName($proposta,'nivriori'); 
			$riscoCalc = getByTagName($proposta,'nivrisco'); 
			$nivrisori = (!empty($riscoOrig)) ? $riscoOrig : $riscoCalc;
 
  
			?><script type="text/javascript">

			var cdcooper = '<? echo $glbvars["cdcooper"];?>';
			var cdoperad = '<? echo $glbvars["cdoperad"];?>';

			var arrayAssociado = new Object();

			arrayAssociado['inpessoa'] = '<? echo getByTagName($associado,'inpessoa'); ?>';
			arrayAssociado['inmatric'] = '<? echo getByTagName($associado,'inmatric'); ?>';
			arrayAssociado['cdagenci'] = '<? echo getByTagName($associado,'cdagenci'); ?>';
			arrayAssociado['cdempres'] = '<? echo getByTagName($associado,'cdempres'); ?>';
			arrayAssociado['flgpagto'] = '<? echo getByTagName($associado,'flgpagto'); ?>';
			arrayAssociado['nrctacje'] = '<? echo getByTagName($associado,'nrctacje'); ?>';
			arrayAssociado['nrcpfcjg'] = '<? echo getByTagName($associado,'nrcpfcjg'); ?>';


			var arrayCooperativa = new Object();

			arrayCooperativa['vlmaxleg'] = '<? echo getByTagName($cooperativa,'vlmaxleg'); ?>';
			arrayCooperativa['vlmaxutl'] = '<? echo getByTagName($cooperativa,'vlmaxutl'); ?>';
			arrayCooperativa['vlcnsscr'] = '<? echo getByTagName($cooperativa,'vlcnsscr'); ?>';
			arrayCooperativa['vllimapv'] = '<? echo getByTagName($cooperativa,'vllimapv'); ?>';
			arrayCooperativa['flgcmtlc'] = '<? echo getByTagName($cooperativa,'flgcmtlc'); ?>';
			arrayCooperativa['vlminimo'] = '<? echo getByTagName($cooperativa,'vlminimo'); ?>';
			arrayCooperativa['vlemprst'] = '<? echo getByTagName($cooperativa,'vlemprst'); ?>';
			arrayCooperativa['inusatab'] = '<? echo getByTagName($cooperativa,'inusatab'); ?>';
			arrayCooperativa['nrctremp'] = '<? echo getByTagName($cooperativa,'nrctremp'); ?>';
			arrayCooperativa['nralihip'] = '<? echo getByTagName($cooperativa,'nralihip'); ?>';
			arrayCooperativa['lssemseg'] = '<? echo getByTagName($cooperativa,'lssemseg'); ?>';
			arrayCooperativa['flginter'] = '<? echo getByTagName($cooperativa,'flginter'); ?>';
			 // faria integracao cdc 
			arrayCooperativa['flintcdc'] = '<? echo getByTagName($cooperativa,'flintcdc'); ?>';
			arrayCooperativa['inintegra_cont'] = '<? echo getByTagName($cooperativa,'inintegra_cont'); ?>';

			var arrayProposta = new Object();

			arrayProposta['vlemprst'] = '<? echo getByTagName($proposta,'vlemprst'); ?>';
			arrayProposta['vlpreemp'] = '<? echo getByTagName($proposta,'vlpreemp'); ?>';
			arrayProposta['vlprecar'] = '<? echo getByTagName($proposta,'vlprecar'); ?>';
			arrayProposta['qtpreemp'] = '<? echo getByTagName($proposta,'qtpreemp'); ?>';
			arrayProposta['nivrisco'] = '<? echo getByTagName($proposta,'nivrisco'); ?>';
			arrayProposta['nivriori'] = '<? echo $nivrisori; ?>'; // nível de risco original
			arrayProposta['nivcalcu'] = '<? echo getByTagName($proposta,'nivcalcu'); ?>';
			arrayProposta['cdlcremp'] = '<? echo getByTagName($proposta,'cdlcremp'); ?>';
			arrayProposta['cdfinemp'] = '<? echo getByTagName($proposta,'cdfinemp'); ?>';
			arrayProposta['qtdialib'] = '<? echo getByTagName($proposta,'qtdialib'); ?>';
			arrayProposta['flgimppr'] = '<? echo getByTagName($proposta,'flgimppr'); ?>';
			arrayProposta['flgimpnp'] = '<? echo getByTagName($proposta,'flgimpnp'); ?>';
			arrayProposta['flgpagto'] = '<? echo getByTagName($proposta,'flgpagto'); ?>';
			arrayProposta['dtdpagto'] = '<? echo getByTagName($proposta,'dtdpagto'); ?>';
			arrayProposta['dsctrliq'] = '<? echo retiraCharEsp(getByTagName($proposta,'dsctrliq')); ?>';
			arrayProposta['qtpromis'] = '<? echo getByTagName($proposta,'qtpromis'); ?>';
			arrayProposta['nmchefia'] = '<? echo retiraCharEsp(getByTagName($proposta,'nmchefia')); ?>';
			arrayProposta['vlsalari'] = '<? echo getByTagName($proposta,'vlsalari'); ?>';
			arrayProposta['vlsalcon'] = '<? echo getByTagName($proposta,'vlsalcon'); ?>';
			arrayProposta['vldrendi'] = '<? echo getByTagName($proposta,'vldrendi'); ?>';
			arrayProposta['dsobserv'] = '<? echo retiraCharEsp(getByTagName($proposta,'dsobserv')); ?>';
			arrayProposta['dsrelbem'] = '<? echo retiraCharEsp(getByTagName($proposta,'dsrelbem')); ?>';
			arrayProposta['tplcremp'] = '<? echo getByTagName($proposta,'tplcremp'); ?>';
			arrayProposta['dslcremp'] = '<? echo retiraCharEsp(getByTagName($proposta,'dslcremp')); ?>';
			arrayProposta['dsfinemp'] = '<? echo retiraCharEsp(getByTagName($proposta,'dsfinemp')); ?>';
			arrayProposta['idquapro'] = '<? echo getByTagName($proposta,'idquapro'); ?>';
			arrayProposta['dsquapro'] = '<? echo retiraCharEsp(getByTagName($proposta,'dsquapro')); ?>';
			arrayProposta['percetop'] = '<? echo getByTagName($proposta,'percetop'); ?>';
			arrayProposta['dtmvtolt'] = '<? echo getByTagName($proposta,'dtmvtolt'); ?>';
			arrayProposta['nrctremp'] = '<? echo getByTagName($proposta,'nrctremp'); ?>';
			arrayProposta['nrdrecid'] = '<? echo getByTagName($proposta,'nrdrecid'); ?>';
			arrayProposta['cdoperad'] = '<? echo getByTagName($proposta,'cdoperad'); ?>';
			arrayProposta['flgenvio'] = '<? echo getByTagName($proposta,'flgenvio'); ?>';
			arrayProposta['dtvencto'] = '<? echo getByTagName($proposta,'dtvencto'); ?>';
			arrayProposta['dsobscmt'] = '<? echo retiraCharEsp(getByTagName($proposta,'dsobscmt')); ?>';
			arrayProposta['tpemprst'] = '<? echo getByTagName($proposta,'tpemprst'); ?>';
			arrayProposta['cdtpempr'] = '<? echo getByTagName($proposta,'cdtpempr'); ?>';
			arrayProposta['dstpempr'] = '<? echo retiraCharEsp(getByTagName($proposta,'dstpempr')); ?>';
			arrayProposta['dtlibera'] = '<? echo getByTagName($proposta,'dtlibera'); ?>';
			arrayProposta['nrseqrrq'] = '<? echo getByTagName($proposta,'nrseqrrq'); ?>';
			arrayProposta['flgcescr'] = '<? echo ((getByTagName($proposta,'flgcescr') == 'yes') ? true : false); ?>';
			arrayProposta['idcarenc'] = '<? echo getByTagName($proposta,'idcarenc'); ?>';
			arrayProposta['dtcarenc'] = '<? echo getByTagName($proposta,'dtcarenc'); ?>';
			arrayProposta['insitest'] = '<? echo getByTagName($proposta,'insitest'); ?>';
            arrayProposta['idcobope'] = '<? echo getByTagName($proposta,'idcobope'); ?>';
			arrayProposta['idfiniof'] = '<? echo getByTagName($proposta,'idfiniof') != '' ? getByTagName($proposta,'idfiniof') : '1'; ?>';
			arrayProposta['vliofepr'] = '<? echo getByTagName($proposta,'vliofepr') != '' ? getByTagName($proposta,'vliofepr') : '0'; ?>';
			arrayProposta['vlrtarif'] = '<? echo getByTagName($proposta,'vlrtarif') != '' ? getByTagName($proposta,'vlrtarif') : '0'; ?>';
			arrayProposta['vlrtotal'] = '<? echo getByTagName($proposta,'vlrtotal') != '' ? getByTagName($proposta,'vlrtotal') : '0'; ?>';
            arrayProposta['vlfinanc'] = '<? echo getByTagName($proposta,'vlfinanc') != '' ? getByTagName($proposta,'vlfinanc') : 0; ?>';
			arrayProposta['flintcdc'] = '<? echo getByTagName($proposta,'flintcdc'); ?>';
			arrayProposta['inintegra_cont'] = '<? echo getByTagName($proposta,'inintegra_cont'); ?>';
			arrayProposta['tpfinali'] = '<? echo getByTagName($proposta,'tpfinali'); ?>';

      vleprori 	 = arrayProposta['vlemprst'];
			bkp_vlpreemp = arrayProposta["vlpreemp"];
			bkp_dslcremp = arrayProposta["dslcremp"];
			bkp_dsfinemp = arrayProposta["dsfinemp"];
			bkp_tplcremp = arrayProposta["tplcremp"];
			tpemprst 	 = arrayProposta["tpemprst"];
			cdtpempr 	 = arrayProposta["cdtpempr"];
			dstpempr	 = arrayProposta["dstpempr"];

			var arrayRendimento = new Object();

			var contRend = <? echo count($rendimento[0]->tags)?>;

			<? for($i=1; $i <= count($rendimento[0]->tags); $i++) {?>

				arrayRendimento['tpdrend'+<? echo $i?>] = '<? echo getByTagName($rendimento[0]->tags,'tpdrendi.'.$i); ?>';
				arrayRendimento['dsdrend'+<? echo $i?>] = '<? echo retiraCharEsp(getByTagName($rendimento[1]->tags,'dsdrendi.'.$i)); ?>';
				arrayRendimento['vldrend'+<? echo $i?>] = '<? echo getByTagName($rendimento[2]->tags,'vldrendi.'.$i); ?>';

			<?}?>

			arrayRendimento['vlsalari'] = '<? echo getByTagName($rendimento,'vlsalari'); ?>';
			arrayRendimento['vlsalcon'] = '<? echo getByTagName($rendimento,'vlsalcon'); ?>';
			arrayRendimento['nmextemp'] = '<? echo retiraCharEsp(getByTagName($rendimento,'nmextemp')); ?>';
			arrayRendimento['perfatcl'] = '<? echo getByTagName($rendimento,'perfatcl'); ?>';
			arrayRendimento['vlmedfat'] = '<? echo getByTagName($rendimento,'vlmedfat'); ?>';
			arrayRendimento['inpessoa'] = '<? echo getByTagName($rendimento,'inpessoa'); ?>';
			arrayRendimento['flgconju'] = '<? echo getByTagName($rendimento,'flgconju'); ?>';
			arrayRendimento['nrctacje'] = '<? echo getByTagName($rendimento,'nrctacje'); ?>';
			arrayRendimento['nrcpfcjg'] = '<? echo getByTagName($rendimento,'nrcpfcjg'); ?>';
			arrayRendimento['flgdocje'] = '<? echo getByTagName($rendimento,'flgdocje'); ?>';
			arrayRendimento['vloutras'] = '<? echo getByTagName($rendimento,'vloutras'); ?>';
			arrayRendimento['vlalugue'] = '<? echo getByTagName($rendimento,'vlalugue'); ?>';
			arrayRendimento['inconcje'] = '<? echo getByTagName($rendimento,'inconcje'); ?>';
			arrayRendimento['dsjusren'] = '<? echo retiraCharEsp(getByTagName($rendimento,'dsjusren')); ?>';

			inpessoa = '<? echo $inpessoa; ?>';

			var arrayBensAss = new Array();

			<?for($i=0; $i<count($regBensAssoc); $i++) {?>

				var arrayBem<? echo $i; ?> = new Object();
				arrayBem<? echo $i; ?>['dsrelbem'] = '<? echo retiraCharEsp(getByTagName($regBensAssoc[$i]->tags,'dsrelbem')); ?>';
				arrayBem<? echo $i; ?>['cdsequen'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'cdsequen'); ?>';
				arrayBem<? echo $i; ?>['persemon'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'persemon'); ?>';
				arrayBem<? echo $i; ?>['qtprebem'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'qtprebem'); ?>';
				arrayBem<? echo $i; ?>['vlprebem'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'vlprebem'); ?>';
				arrayBem<? echo $i; ?>['vlrdobem'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'vlrdobem'); ?>';
				arrayBem<? echo $i; ?>['cdcooper'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'cdcooper'); ?>';
				arrayBem<? echo $i; ?>['nrdconta'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'nrdconta'); ?>';
				arrayBem<? echo $i; ?>['idseqttl'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'idseqttl'); ?>';
				arrayBem<? echo $i; ?>['dtmvtolt'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'dtmvtolt'); ?>';
				arrayBem<? echo $i; ?>['cdoperad'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'cdoperad'); ?>';
				arrayBem<? echo $i; ?>['dtaltbem'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'dtaltbem'); ?>';
				arrayBem<? echo $i; ?>['idseqbem'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'idseqbem'); ?>';
				arrayBem<? echo $i; ?>['nrdrowid'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'nrdrowid'); ?>';
				arrayBem<? echo $i; ?>['nrcpfcgc'] = '<? echo getByTagName($regBensAssoc[$i]->tags,'nrcpfcgc'); ?>';

				arrayBensAss[<? echo $i; ?>] = arrayBem<? echo $i; ?>;

			<?}?>

			var arrayAvalistas = new Array();
			nrAvalistas     = '<? echo count($avalistas);?>';
            nrAvalistaSalvo = '<? echo count($avalistas);?>';
			contAvalistas   = 0;

			<? for($i=0; $i<count($avalistas); $i++) {?>

				var arrayAvalista<? echo $i; ?> = new Object();

				arrayAvalista<? echo $i; ?>['nrctaava'] = '<? echo getByTagName($avalistas[$i]->tags,'nrctaava'); ?>';
				arrayAvalista<? echo $i; ?>['cdnacion'] = '<? echo getByTagName($avalistas[$i]->tags,'cdnacion'); ?>';
				arrayAvalista<? echo $i; ?>['dsnacion'] = '<? echo retiraCharEsp(getByTagName($avalistas[$i]->tags,'dsnacion')); ?>';
				arrayAvalista<? echo $i; ?>['tpdocava'] = '<? echo getByTagName($avalistas[$i]->tags,'tpdocava'); ?>';
				arrayAvalista<? echo $i; ?>['nmconjug'] = '<? echo retiraCharEsp(getByTagName($avalistas[$i]->tags,'nmconjug')); ?>';
				arrayAvalista<? echo $i; ?>['tpdoccjg'] = '<? echo getByTagName($avalistas[$i]->tags,'tpdoccjg'); ?>';
				arrayAvalista<? echo $i; ?>['dsendre1'] = '<? echo retiraCharEsp(getByTagName($avalistas[$i]->tags,'dsendre1')); ?>';
				arrayAvalista<? echo $i; ?>['nrfonres'] = '<? echo getByTagName($avalistas[$i]->tags,'nrfonres'); ?>';
				arrayAvalista<? echo $i; ?>['nmcidade'] = '<? echo retiraCharEsp(getByTagName($avalistas[$i]->tags,'nmcidade')); ?>';
				arrayAvalista<? echo $i; ?>['nrcepend'] = '<? echo getByTagName($avalistas[$i]->tags,'nrcepend'); ?>';
				arrayAvalista<? echo $i; ?>['nmdavali'] = '<? echo retiraCharEsp(getByTagName($avalistas[$i]->tags,'nmdavali')); ?>';
				arrayAvalista<? echo $i; ?>['nrcpfcgc'] = '<? echo getByTagName($avalistas[$i]->tags,'nrcpfcgc'); ?>';
				arrayAvalista<? echo $i; ?>['nrdocava'] = '<? echo getByTagName($avalistas[$i]->tags,'nrdocava'); ?>';
				arrayAvalista<? echo $i; ?>['nrcpfcjg'] = '<? echo getByTagName($avalistas[$i]->tags,'nrcpfcjg'); ?>';
				arrayAvalista<? echo $i; ?>['nrdoccjg'] = '<? echo getByTagName($avalistas[$i]->tags,'nrdoccjg'); ?>';
				arrayAvalista<? echo $i; ?>['dsendre2'] = '<? echo retiraCharEsp(getByTagName($avalistas[$i]->tags,'dsendre2')); ?>';
				arrayAvalista<? echo $i; ?>['dsdemail'] = '<? echo retiraCharEsp(getByTagName($avalistas[$i]->tags,'dsdemail')); ?>';
				arrayAvalista<? echo $i; ?>['cdufresd'] = '<? echo getByTagName($avalistas[$i]->tags,'cdufresd'); ?>';
				arrayAvalista<? echo $i; ?>['vlrenmes'] = '<? echo getByTagName($avalistas[$i]->tags,'vlrenmes'); ?>';
				arrayAvalista<? echo $i; ?>['vledvmto'] = '<? echo getByTagName($avalistas[$i]->tags,'vledvmto'); ?>';
				//Campos projeto CEP
				arrayAvalista<? echo $i; ?>['nrendere'] = '<? echo getByTagName($avalistas[$i]->tags,'nrendere'); ?>';
				arrayAvalista<? echo $i; ?>['complend'] = '<? echo getByTagName($avalistas[$i]->tags,'complend'); ?>';
				arrayAvalista<? echo $i; ?>['nrcxapst'] = '<? echo getByTagName($avalistas[$i]->tags,'nrcxapst'); ?>';
				
				//Daniel
				arrayAvalista<? echo $i; ?>['inpessoa'] = '<? echo getByTagName($avalistas[$i]->tags,'inpessoa'); ?>';
				arrayAvalista<? echo $i; ?>['dtnascto'] = '<? echo getByTagName($avalistas[$i]->tags,'dtnascto'); ?>';

				// PRJ 438
				arrayAvalista<? echo $i; ?>['nrctacjg'] = '<? echo getByTagName($avalistas[$i]->tags,'nrctacjg'); ?>';
				arrayAvalista<? echo $i; ?>['vlrencjg'] = '<? echo getByTagName($avalistas[$i]->tags,'vlrencjg'); ?>';

				var arrayBensAval<? echo $i; ?> = new Array();

				<? for($j = 0; $j<count($regBensAval); $j++){
						if( ( getByTagName($regBensAval[$j]->tags,'nrdconta') == getByTagName($avalistas[$i]->tags,'nrctaava') && getByTagName($avalistas[$i]->tags,'nrctaava') != 0 )||
						    ( getByTagName($regBensAval[$j]->tags,'nrcpfcgc') == getByTagName($avalistas[$i]->tags,'nrcpfcgc') && getByTagName($avalistas[$i]->tags,'nrcpfcgc') != 0 ) ){

						$identificador = $j.getByTagName($regBensAval[$j]->tags,'nrdconta').getByTagName($regBensAval[$j]->tags,'nrcpfcgc');

						?>

						var arrayBemAval<? echo $identificador ?> = new Object();
						arrayBemAval<? echo $identificador; ?>['cdcooper'] = '<? echo getByTagName($regBensAval[$j]->tags,'cdcooper'); ?>';
						arrayBemAval<? echo $identificador; ?>['nrdconta'] = '<? echo getByTagName($regBensAval[$j]->tags,'nrdconta'); ?>';
						arrayBemAval<? echo $identificador; ?>['idseqttl'] = '<? echo getByTagName($regBensAval[$j]->tags,'idseqttl'); ?>';
						arrayBemAval<? echo $identificador; ?>['dtmvtolt'] = '<? echo getByTagName($regBensAval[$j]->tags,'dtmvtolt'); ?>';
						arrayBemAval<? echo $identificador; ?>['cdoperad'] = '<? echo getByTagName($regBensAval[$j]->tags,'cdoperad'); ?>';
						arrayBemAval<? echo $identificador; ?>['dtaltbem'] = '<? echo getByTagName($regBensAval[$j]->tags,'dtaltbem'); ?>';
						arrayBemAval<? echo $identificador; ?>['idseqbem'] = '<? echo getByTagName($regBensAval[$j]->tags,'idseqbem'); ?>';
						arrayBemAval<? echo $identificador; ?>['dsrelbem'] = '<? echo retiraCharEsp(getByTagName($regBensAval[$j]->tags,'dsrelbem')); ?>';
						arrayBemAval<? echo $identificador; ?>['persemon'] = '<? echo getByTagName($regBensAval[$j]->tags,'persemon'); ?>';
						arrayBemAval<? echo $identificador; ?>['qtprebem'] = '<? echo getByTagName($regBensAval[$j]->tags,'qtprebem'); ?>';
						arrayBemAval<? echo $identificador; ?>['vlrdobem'] = '<? echo getByTagName($regBensAval[$j]->tags,'vlrdobem'); ?>';
						arrayBemAval<? echo $identificador; ?>['vlprebem'] = '<? echo getByTagName($regBensAval[$j]->tags,'vlprebem'); ?>';
						arrayBemAval<? echo $identificador; ?>['nrdrowid'] = '<? echo getByTagName($regBensAval[$j]->tags,'nrdrowid'); ?>';
						arrayBemAval<? echo $identificador; ?>['nrcpfcgc'] = '<? echo getByTagName($regBensAval[$j]->tags,'nrcpfcgc'); ?>';

						arrayBensAval<? echo $i; ?>[<? echo $j; ?>] = arrayBemAval<? echo $identificador; ?>;

					<? }
				} ?>

				arrayAvalista<? echo $i; ?>['bensaval'] = arrayBensAval<? echo $i; ?> ;


				arrayAvalistas[<? echo $i; ?>] = arrayAvalista<? echo $i; ?>;
			<? } ?>

			var arrayAlienacoes = new Array();
			nrAlienacao    = "<? echo count($alienacoes); ?>";
			contAlienacao  = 0;

			<? for($i=0; $i<count($alienacoes); $i++) { ?>

				var arrayAlienacao<? echo $i; ?> = new Object(); 
				arrayAlienacao<? echo $i; ?>['lsbemfin'] = '<? echo getByTagName($alienacoes[$i]->tags,'lsbemfin'); ?>';
				arrayAlienacao<? echo $i; ?>['dscatbem'] = '<? echo retiraCharEsp(getByTagName($alienacoes[$i]->tags,'dscatbem')); ?>';
				arrayAlienacao<? echo $i; ?>['dstipbem'] = '<? echo getByTagName($alienacoes[$i]->tags,'dstipbem'); ?>';
				arrayAlienacao<? echo $i; ?>['dsbemfin'] = '<? echo retiraCharEsp(getByTagName($alienacoes[$i]->tags,'dsbemfin')); ?>';
				arrayAlienacao<? echo $i; ?>['dscorbem'] = '<? echo retiraCharEsp(getByTagName($alienacoes[$i]->tags,'dscorbem')); ?>';
				arrayAlienacao<? echo $i; ?>['dschassi'] = '<? echo retiraCharEsp(getByTagName($alienacoes[$i]->tags,'dschassi')); ?>';
				arrayAlienacao<? echo $i; ?>['nranobem'] = '<? echo getByTagName($alienacoes[$i]->tags,'nranobem'); ?>';
				arrayAlienacao<? echo $i; ?>['nrmodbem'] = '<? echo getByTagName($alienacoes[$i]->tags,'nrmodbem'); ?>';
				arrayAlienacao<? echo $i; ?>['nrdplaca'] = '<? echo getByTagName($alienacoes[$i]->tags,'nrdplaca'); ?>';
				arrayAlienacao<? echo $i; ?>['nrrenava'] = '<? echo getByTagName($alienacoes[$i]->tags,'nrrenava'); ?>';
				arrayAlienacao<? echo $i; ?>['tpchassi'] = '<? echo getByTagName($alienacoes[$i]->tags,'tpchassi'); ?>';
				arrayAlienacao<? echo $i; ?>['ufdplaca'] = '<? echo getByTagName($alienacoes[$i]->tags,'ufdplaca'); ?>';
				arrayAlienacao<? echo $i; ?>['nrcpfbem'] = '<? echo getByTagName($alienacoes[$i]->tags,'nrcpfbem'); ?>';
				arrayAlienacao<? echo $i; ?>['dscpfbem'] = '<? echo retiraCharEsp(getByTagName($alienacoes[$i]->tags,'dscpfbem')); ?>';
				arrayAlienacao<? echo $i; ?>['vlmerbem'] = '<? echo getByTagName($alienacoes[$i]->tags,'vlmerbem'); ?>';
				arrayAlienacao<? echo $i; ?>['idalibem'] = '<? echo getByTagName($alienacoes[$i]->tags,'idalibem'); ?>';
                arrayAlienacao<? echo $i; ?>['idseqbem'] = '<? echo getByTagName($alienacoes[$i]->tags,'idseqbem'); ?>';
				arrayAlienacao<? echo $i; ?>['cdcoplib'] = '<? echo getByTagName($alienacoes[$i]->tags,'cdcoplib'); ?>';

				arrayAlienacao<? echo $i; ?>['dsmarbem'] = '<? echo getByTagName($alienacoes[$i]->tags,'dsmarbem'); ?>';
				arrayAlienacao<? echo $i; ?>['vlrdobem'] = '<? echo getByTagName($alienacoes[$i]->tags,'vlrdobem'); ?>';
				arrayAlienacao<? echo $i; ?>['vlfipbem'] = '<? echo getByTagName($alienacoes[$i]->tags,'vlfipbem'); ?>';
				arrayAlienacao<? echo $i; ?>['nrcpfcgc'] = '<? echo getByTagName($alienacoes[$i]->tags,'nrcpfcgc'); ?>';
				arrayAlienacao<? echo $i; ?>['cdoperad'] = '<? echo getByTagName($alienacoes[$i]->tags,'cdoperad'); ?>';
				arrayAlienacao<? echo $i; ?>['dssitgrv'] = '<? echo getByTagName($alienacoes[$i]->tags,'dssitgrv'); ?>';
				arrayAlienacao<? echo $i; ?>['dstpcomb'] = '<? echo getByTagName($alienacoes[$i]->tags,'dstpcomb'); ?>';
				arrayAlienacao<? echo $i; ?>['uflicenc'] = '<? echo getByTagName($alienacoes[$i]->tags,'uflicenc'); ?>';

				<?php //PRJ 438 - Bruno ?>
				arrayAlienacao<? echo $i; ?>['nrnotanf'] = '<? echo getByTagName($alienacoes[$i]->tags,'nrnotanf'); ?>';
				arrayAlienacao<? echo $i; ?>['dsmarceq'] = '<? echo getByTagName($alienacoes[$i]->tags,'dsmarceq'); ?>';

				arrayAlienacoes[<? echo $i; ?>] = arrayAlienacao<? echo $i; ?>;

			<?}?>

			var arrayIntervs = new Array();
			nrIntervis       = "<?echo count($intervs)?>";
			contIntervis     = 0;

			<?for($i=0; $i<count($intervs); $i++) {?>

				var arrayInterv<? echo $i; ?> = new Object();
				arrayInterv<? echo $i; ?>['nrctaava'] = '<? echo getByTagName($intervs[$i]->tags,'nrctaava'); ?>';
				arrayInterv<? echo $i; ?>['cdnacion'] = '<? echo getByTagName($intervs[$i]->tags,'cdnacion'); ?>';
				arrayInterv<? echo $i; ?>['dsnacion'] = '<? echo retiraCharEsp(getByTagName($intervs[$i]->tags,'dsnacion')); ?>';
				arrayInterv<? echo $i; ?>['tpdocava'] = '<? echo getByTagName($intervs[$i]->tags,'tpdocava'); ?>';
				arrayInterv<? echo $i; ?>['nmconjug'] = '<? echo retiraCharEsp(getByTagName($intervs[$i]->tags,'nmconjug')); ?>';
				arrayInterv<? echo $i; ?>['tpdoccjg'] = '<? echo getByTagName($intervs[$i]->tags,'tpdoccjg'); ?>';
				arrayInterv<? echo $i; ?>['dsendre1'] = '<? echo retiraCharEsp(getByTagName($intervs[$i]->tags,'dsendlog')); ?>';
				arrayInterv<? echo $i; ?>['nrfonres'] = '<? echo getByTagName($intervs[$i]->tags,'nrfonres'); ?>';
				arrayInterv<? echo $i; ?>['nmcidade'] = '<? echo retiraCharEsp(getByTagName($intervs[$i]->tags,'nmcidade')); ?>';
				arrayInterv<? echo $i; ?>['nrcepend'] = '<? echo getByTagName($intervs[$i]->tags,'nrcepend'); ?>';
				arrayInterv<? echo $i; ?>['vlrenmes'] = '<? echo getByTagName($intervs[$i]->tags,'vlrenmes'); ?>';
				arrayInterv<? echo $i; ?>['nmdavali'] = '<? echo retiraCharEsp(getByTagName($intervs[$i]->tags,'nmdavali')); ?>';
				arrayInterv<? echo $i; ?>['nrcpfcgc'] = '<? echo getByTagName($intervs[$i]->tags,'nrcpfcgc'); ?>';
				arrayInterv<? echo $i; ?>['nrdocava'] = '<? echo getByTagName($intervs[$i]->tags,'nrdocava'); ?>';
				arrayInterv<? echo $i; ?>['nrcpfcjg'] = '<? echo getByTagName($intervs[$i]->tags,'nrcpfcjg'); ?>';
				arrayInterv<? echo $i; ?>['nrdoccjg'] = '<? echo getByTagName($intervs[$i]->tags,'nrdoccjg'); ?>';
				arrayInterv<? echo $i; ?>['dsendre2'] = '<? echo retiraCharEsp(getByTagName($intervs[$i]->tags,'dsbarlog')); ?>';
				arrayInterv<? echo $i; ?>['dsdemail'] = '<? echo retiraCharEsp(getByTagName($intervs[$i]->tags,'dsdemail')); ?>';
				arrayInterv<? echo $i; ?>['cdufresd'] = '<? echo getByTagName($intervs[$i]->tags,'cdufresd'); ?>';
				arrayInterv<? echo $i; ?>['vledvmto'] = '<? echo getByTagName($intervs[$i]->tags,'vledvmto'); ?>';
				//Campos projeto CEP
				arrayInterv<? echo $i; ?>['nrendere'] = '<? echo getByTagName($intervs[$i]->tags,'nrendere'); ?>';
				arrayInterv<? echo $i; ?>['complend'] = '<? echo getByTagName($intervs[$i]->tags,'complend'); ?>';
				arrayInterv<? echo $i; ?>['nrcxapst'] = '<? echo getByTagName($intervs[$i]->tags,'nrcxapst'); ?>';

				// PRJ 438
				arrayInterv<? echo $i; ?>['inpessoa'] = '<? echo getByTagName($intervs[$i]->tags,'inpessoa'); ?>';
				arrayInterv<? echo $i; ?>['nrctacjg'] = '<? echo getByTagName($intervs[$i]->tags,'nrctacjg'); ?>';

				//bruno - prj 438 - bug 14585
				arrayInterv<? echo $i; ?>['dtnascto'] = '<? echo getByTagName($intervs[$i]->tags,'dtnascto'); ?>';

				arrayIntervs[<? echo $i; ?>] = arrayInterv<? echo $i; ?>;

			<?}?>

			var arrayProtCred = new Object();

			arrayProtCred['nrperger'] = '<? echo getByTagName($analise,'nrperger'); ?>';
			arrayProtCred['dsperger'] = '<? echo retiraCharEsp(getByTagName($analise,'dsperger')); ?>';
			arrayProtCred['dtcnsspc'] = '<? echo getByTagName($analise,'dtcnsspc'); ?>';
			arrayProtCred['nrinfcad'] = '<? echo getByTagName($analise,'nrinfcad'); ?>';
			arrayProtCred['dsinfcad'] = '<? echo retiraCharEsp(getByTagName($analise,'dsinfcad')); ?>';
			arrayProtCred['dtdrisco'] = '<? echo getByTagName($analise,'dtdrisco'); ?>';
			arrayProtCred['vltotsfn'] = '<? echo getByTagName($analise,'vltotsfn'); ?>';
			arrayProtCred['qtopescr'] = '<? echo getByTagName($analise,'qtopescr'); ?>';
			arrayProtCred['qtifoper'] = '<? echo getByTagName($analise,'qtifoper'); ?>';
			arrayProtCred['nrliquid'] = '<? echo getByTagName($analise,'nrliquid'); ?>';
			arrayProtCred['dsliquid'] = '<? echo retiraCharEsp(getByTagName($analise,'dsliquid')); ?>';
			arrayProtCred['vlopescr'] = '<? echo getByTagName($analise,'vlopescr'); ?>';
			arrayProtCred['vlrpreju'] = '<? echo getByTagName($analise,'vlrpreju'); ?>';
			arrayProtCred['nrpatlvr'] = '<? echo getByTagName($analise,'nrpatlvr'); ?>';
			arrayProtCred['dspatlvr'] = '<? echo retiraCharEsp(getByTagName($analise,'dspatlvr')); ?>';
			arrayProtCred['nrgarope'] = '<? echo getByTagName($analise,'nrgarope'); ?>';
			arrayProtCred['dsgarope'] = '<? echo retiraCharEsp(getByTagName($analise,'dsgarope')); ?>';
			arrayProtCred['dtoutspc'] = '<? echo getByTagName($analise,'dtoutspc'); ?>';
			arrayProtCred['dtoutris'] = '<? echo getByTagName($analise,'dtoutris'); ?>';
			arrayProtCred['vlsfnout'] = '<? echo getByTagName($analise,'vlsfnout'); ?>';
			arrayProtCred['flgcentr'] = '<? echo getByTagName($analise,'flgcentr'); ?>';
			arrayProtCred['flgcoout'] = '<? echo getByTagName($analise,'flgcoout'); ?>';

			var arrayHipotecas = new Array();
			nrHipotecas      = "<?echo count($hipotecas)?>";
			contHipotecas    = 0;

			<?for($i=0; $i<count($hipotecas); $i++) {?>

				var arrayHipoteca<? echo $i; ?> = new Object();
				arrayHipoteca<? echo $i; ?>['lsbemfin'] = '<? echo getByTagName($hipotecas[$i]->tags,'lsbemfin'); ?>';
				arrayHipoteca<? echo $i; ?>['dscatbem'] = '<? echo retiraCharEsp(getByTagName($hipotecas[$i]->tags,'dscatbem')); ?>';
				arrayHipoteca<? echo $i; ?>['dsbemfin'] = '<? echo retiraCharEsp(getByTagName($hipotecas[$i]->tags,'dsbemfin')); ?>';
				arrayHipoteca<? echo $i; ?>['dscorbem'] = '<? echo retiraCharEsp(getByTagName($hipotecas[$i]->tags,'dscorbem')); ?>';
				arrayHipoteca<? echo $i; ?>['idseqhip'] = '<? echo getByTagName($hipotecas[$i]->tags,'idseqhip'); ?>';
				arrayHipoteca<? echo $i; ?>['vlmerbem'] = '<? echo getByTagName($hipotecas[$i]->tags,'vlmerbem'); ?>';
				//Projeto 438 - Sprint 4 
        		arrayHipoteca<? echo $i; ?>['vlrdobem'] = '<? echo getByTagName($hipotecas[$i]->tags,'vlrdobem'); ?>';
        		arrayHipoteca<? echo $i; ?>['nrmatric'] = '<? echo getByTagName($hipotecas[$i]->tags,'nrmatric'); ?>';
        		arrayHipoteca<? echo $i; ?>['vlareuti'] = '<? echo getByTagName($hipotecas[$i]->tags,'vlareuti'); ?>';
        		arrayHipoteca<? echo $i; ?>['vlaretot'] = '<? echo getByTagName($hipotecas[$i]->tags,'vlaretot'); ?>';
        		//bruno - prj 438 - BUG 13499
        		arrayHipoteca<? echo $i; ?>['dsclassi'] = '<? echo retiraCharEsp(getByTagName($hipotecas[$i]->tags,'dsclassi')); ?>';
				arrayHipoteca<? echo $i; ?>['nrcepend'] = '<? echo getByTagName($hipotecas[$i]->tags,'nrcepend'); ?>';
				arrayHipoteca<? echo $i; ?>['dsendere'] = '<? echo retiraCharEsp(getByTagName($hipotecas[$i]->tags,'dsendere')); ?>';
				arrayHipoteca<? echo $i; ?>['nrendere'] = '<? echo getByTagName($hipotecas[$i]->tags,'nrendere'); ?>';
				arrayHipoteca<? echo $i; ?>['dscompend'] = '<? echo retiraCharEsp(getByTagName($hipotecas[$i]->tags,'dscompend')); ?>';
				arrayHipoteca<? echo $i; ?>['nmbairro'] = '<? echo retiraCharEsp(getByTagName($hipotecas[$i]->tags,'nmbairro')); ?>';
				arrayHipoteca<? echo $i; ?>['cdufende'] = '<? echo getByTagName($hipotecas[$i]->tags,'cdufende'); ?>';
				arrayHipoteca<? echo $i; ?>['nmcidade'] = '<? echo retiraCharEsp(getByTagName($hipotecas[$i]->tags,'nmcidade')); ?>';

				//bruno - prj 438 - duplicacao hipoteca
				arrayHipoteca<? echo $i; ?>['idseqbem'] = '<? echo getByTagName($hipotecas[$i]->tags,'idseqbem'); ?>';

				arrayHipotecas[<? echo $i; ?>] = arrayHipoteca<? echo $i; ?>;

			<?}?>

			var arrayFaturamentos = new Array();

			<?for($i=0; $i<count($faturamentos); $i++) {?>

				var arrayFaturamento<? echo $i; ?> = new Object();
				arrayFaturamento<? echo $i; ?>['mesftbru'] = '<? echo getByTagName($faturamentos[$i]->tags,'mesftbru'); ?>';
				arrayFaturamento<? echo $i; ?>['anoftbru'] = '<? echo getByTagName($faturamentos[$i]->tags,'anoftbru'); ?>';
				arrayFaturamento<? echo $i; ?>['vlrftbru'] = '<? echo getByTagName($faturamentos[$i]->tags,'vlrftbru'); ?>';
				arrayFaturamento<? echo $i; ?>['nrposext'] = '<? echo getByTagName($faturamentos[$i]->tags,'nrposext'); ?>';
				arrayFaturamento<? echo $i; ?>['cdoperad'] = '<? echo getByTagName($faturamentos[$i]->tags,'cdoperad'); ?>';
				arrayFaturamento<? echo $i; ?>['nmoperad'] = '<? echo retiraCharEsp(getByTagName($faturamentos[$i]->tags,'nmoperad')); ?>';
				arrayFaturamento<? echo $i; ?>['dtaltjfn'] = '<? echo getByTagName($faturamentos[$i]->tags,'dtaltjfn'); ?>';
				arrayFaturamento<? echo $i; ?>['nrdrowid'] = '<? echo getByTagName($faturamentos[$i]->tags,'nrdrowid'); ?>';

				arrayFaturamentos[<? echo $i; ?>] = arrayFaturamento<? echo $i; ?>;

			<?}?>
			<? if (in_array($operacao,array('A_SOMBENS'))) { ?>
			controlaOperacao('A_BENS');
			<? } ?>
			</script><?

		}

	} else if(in_array($operacao,array('A_PARCELAS','V_PARCELAS','C_PARCELAS','I_PARCELAS'))) { // Só exibe se for 'Novo Cálculo'

		$xml = "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0084.p</Bo>";
		$xml .= "		<Proc>busca_parcelas_proposta</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
		$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xml .= "		<flgerlog>true</flgerlog>";
		$xml .= "		<nrctremp>0</nrctremp>";
		$xml .= "		<cdlcremp>".$cdlcremp."</cdlcremp>";
		$xml .= "		<cdfinemp>".$cdfinemp."</cdfinemp>";
		$xml .= "		<vlemprst>".$vlempres."</vlemprst>";
		$xml .= "		<qtparepr>".$qtparepr."</qtparepr>";
		$xml .= "		<dtlibera>".$dtlibera."</dtlibera>";
		$xml .= "		<dtdpagto>".$dtdpagto."</dtdpagto>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";

		$xmlResult = getDataXML($xml);
		$xmlObjeto = getObjectXML($xmlResult);

		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$mtdErro,false);
		}

		$parcelas  = $xmlObjeto->roottag->tags[0]->tags;

		?>
		<script type="text/javascript">
			var arrayParcelas = new Array();

			<?for($i=0; $i<count($parcelas); $i++) {?>

				var arrayParcela<? echo $i; ?> = new Object();
				arrayParcela<? echo $i; ?>['cdcooper'] = '<? echo getByTagName($parcelas[$i]->tags,'cdcooper'); ?>';
				arrayParcela<? echo $i; ?>['nrdconta'] = '<? echo getByTagName($parcelas[$i]->tags,'nrdconta'); ?>';
				arrayParcela<? echo $i; ?>['nrctremp'] = '<? echo getByTagName($parcelas[$i]->tags,'nrctremp'); ?>';
				arrayParcela<? echo $i; ?>['nrparepr'] = '<? echo getByTagName($parcelas[$i]->tags,'nrparepr'); ?>';
				arrayParcela<? echo $i; ?>['vlparepr'] = '<? echo getByTagName($parcelas[$i]->tags,'vlparepr'); ?>';
				arrayParcela<? echo $i; ?>['dtparepr'] = '<? echo getByTagName($parcelas[$i]->tags,'dtparepr'); ?>';

				arrayParcelas[<? echo $i; ?>] = arrayParcela<? echo $i; ?>;

			<? } ?>
		</script>
		<?
	}else if(in_array($operacao,array('T_EFETIVA'))) {

	// Monta o xml de requisição
		if($operacao == 'T_EFETIVA'){
			$procedure = 'busca_dados_efetivacao_proposta';
		}else if($operacao == 'D_EFETIVA') {
			$procedure = 'busca_desfazer_efetivacao_emprestimo';
		}else if($operacao == 'TD_EFETIVA') {
			$procedure = 'desfazer_efetivacao_emprestimo';
		}

		$xml .= "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0084.p</Bo>";
		$xml .= "		<Proc>".$procedure."</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
		$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xml .= "		<flgerlog>true</flgerlog>";
		$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
		$xml .= "		<cdprogra>'ATENDA'</cdprogra>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";

		// Executa script para envio do XML
		$xmlResult = getDataXML($xml);

		// Cria objeto para classe de tratamento de XML
		$xmlObj = getObjectXML($xmlResult);

		if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo($(\'#divRotina\'));controlaOperacao()',false);
		}

		if($operacao == 'T_EFETIVA'){
			$mensagem 	   = $xmlObj->roottag->tags[0]->tags;
			$insitapv 	   = $xmlObj->roottag->tags[1]->tags;
			$mensagem_aval = $xmlObj->roottag->tags[2]->tags;
			$avalista1     = $xmlObj->roottag->tags[3]->tags;
			$avalista2     = $xmlObj->roottag->tags[4]->tags;
			$tpemprst      = getByTagName($insitapv[0]->tags,'tpemprst');

			?>
			<script>
				var arrayMensagem = new Object();
				arrayMensagem['conteudo'] = false;
			</script>
			<?

			if(!empty($mensagem))
			{
				?>
					<script>
						arrayMensagem['inconfirm'] = '<? echo getByTagName($mensagem[0]->tags,'inconfirm'); ?>';
						arrayMensagem['dsmensag'] = '<? echo retiraCharEsp(getByTagName($mensagem[0]->tags,'dsmensag')); ?>';
						arrayMensagem['conteudo'] = true;
					</script>
				<?
			}
			?>
			<script>
				var arrayStatusApprov = new Object();

				arrayStatusApprov['cdcooper'] = '<? echo getByTagName($insitapv[0]->tags,'cdcooper'); ?>';
				arrayStatusApprov['nrdconta'] = '<? echo getByTagName($insitapv[0]->tags,'nrdconta'); ?>';
				arrayStatusApprov['nrctremp'] = '<? echo getByTagName($insitapv[0]->tags,'nrctremp'); ?>';
				arrayStatusApprov['insitapr'] = '<? echo getByTagName($insitapv[0]->tags,'insitapr'); ?>';
				arrayStatusApprov['cdsitapr'] = '<? echo getByTagName($insitapv[0]->tags,'cdsitapr'); ?>';
				arrayStatusApprov['dssitapr'] = '<? echo retiraCharEsp(getByTagName($insitapv[0]->tags,'dssitapr')); ?>';
				arrayStatusApprov['dsobscmt'] = '<? echo retiraCharEsp(getByTagName($insitapv[0]->tags,'dsobscmt')); ?>';
				arrayStatusApprov['dtdpagto'] = '<? echo getByTagName($insitapv[0]->tags,'dtdpagto'); ?>';
				arrayStatusApprov['dsaprova'] = '<? echo retiraCharEsp(getByTagName($insitapv[0]->tags,'dsaprova')); ?>';
				arrayStatusApprov['flgobcmt'] = '<? echo getByTagName($insitapv[0]->tags,'flgobcmt'); ?>';
				arrayStatusApprov['cdfinemp'] = '<? echo getByTagName($insitapv[0]->tags,'cdfinemp'); ?>';
				arrayStatusApprov['cdlcremp'] = '<? echo getByTagName($insitapv[0]->tags,'cdlcremp'); ?>';
				arrayStatusApprov['nivrisco'] = '<? echo getByTagName($insitapv[0]->tags,'nivrisco'); ?>';
				arrayStatusApprov['vlemprst'] = '<? echo getByTagName($insitapv[0]->tags,'vlemprst'); ?>';
				arrayStatusApprov['vlprecar'] = '<? echo getByTagName($insitapv[0]->tags,'vlprecar'); ?>';
				arrayStatusApprov['vlpreemp'] = '<? echo getByTagName($insitapv[0]->tags,'vlpreemp'); ?>';
				arrayStatusApprov['qtpreemp'] = '<? echo getByTagName($insitapv[0]->tags,'qtpreemp'); ?>';
				arrayStatusApprov['flgpagto'] = '<? echo getByTagName($insitapv[0]->tags,'flgpagto'); ?>';
				arrayStatusApprov['nrctaav1'] = '<? echo getByTagName($insitapv[0]->tags,'nrctaav1'); ?>';
				arrayStatusApprov['nrctaav2'] = '<? echo getByTagName($insitapv[0]->tags,'nrctaav2'); ?>';
				arrayStatusApprov['avalist1'] = '<? echo getByTagName($insitapv[0]->tags,'avalist1'); ?>';
				arrayStatusApprov['avalist2'] = '<? echo getByTagName($insitapv[0]->tags,'avalist2'); ?>';
				arrayStatusApprov['altdtpgt'] = '<? echo getByTagName($insitapv[0]->tags,'altdtpgt'); ?>';
				arrayStatusApprov['idcobope'] = '<? echo getByTagName($insitapv[0]->tags,'idcobope'); ?>';
				arrayStatusApprov['vlfinanc'] = '<? echo getByTagName($insitapv[0]->tags,'vlfinanc'); ?>';				
				arrayStatusApprov['flliquid'] = '<? echo getByTagName($insitapv[0]->tags,'flliquid'); ?>';				
				arrayStatusApprov['tpemprst'] = '<? echo getByTagName($insitapv[0]->tags,'tpemprst'); ?>';				

				var arrayMensagemAval = new Array();

				<?for($i=0; $i<count($mensagem_aval); $i++) {?>
					var mensagemAval<? echo $i; ?> = new Object();
					mensagemAval<? echo $i; ?>['cdavalis'] = '<? echo getByTagName($mensagem_aval[$i]->tags,'cdavalis'); ?>';
					mensagemAval<? echo $i; ?>['dsmensag'] = '<? echo retiraCharEsp(getByTagName($mensagem_aval[$i]->tags,'dsmensag')); ?>';
					arrayMensagemAval[<? echo $i; ?>] = mensagemAval<? echo $i; ?>;
				<?}?>

				var arrayEmprestimosAvalista1 = new Array();

				<?for($i=0; $i<count($avalista1); $i++) {?>
					var dadosEmprestimoAvalista1<? echo $i; ?> = new Object();
					dadosEmprestimoAvalista1<? echo $i; ?>['nrdconta'] = '<? echo getByTagName($avalista1[$i]->tags,'nrdconta'); ?>';
					dadosEmprestimoAvalista1<? echo $i; ?>['nrctremp'] = '<? echo getByTagName($avalista1[$i]->tags,'nrctremp'); ?>';
					dadosEmprestimoAvalista1<? echo $i; ?>['dtmvtolt'] = '<? echo getByTagName($avalista1[$i]->tags,'dtmvtolt'); ?>';
					dadosEmprestimoAvalista1<? echo $i; ?>['vlemprst'] = '<? echo getByTagName($avalista1[$i]->tags,'vlemprst'); ?>';
					dadosEmprestimoAvalista1<? echo $i; ?>['qtpreemp'] = '<? echo getByTagName($avalista1[$i]->tags,'qtpreemp'); ?>';
					dadosEmprestimoAvalista1<? echo $i; ?>['vlpreemp'] = '<? echo getByTagName($avalista1[$i]->tags,'vlpreemp'); ?>';
					dadosEmprestimoAvalista1<? echo $i; ?>['vlsdeved'] = '<? echo getByTagName($avalista1[$i]->tags,'vlsdeved'); ?>';
					arrayEmprestimosAvalista1[<? echo $i; ?>] = dadosEmprestimoAvalista1<? echo $i; ?>;
				<?}?>

				var arrayEmprestimosAvalista2 = new Array();

				<?for($i=0; $i<count($avalista2); $i++) {?>
					var dadosEmprestimoAvalista2<? echo $i; ?> = new Object();
					dadosEmprestimoAvalista2<? echo $i; ?>['nrdconta'] = '<? echo getByTagName($avalista2[$i]->tags,'nrdconta'); ?>';
					dadosEmprestimoAvalista2<? echo $i; ?>['nrctremp'] = '<? echo getByTagName($avalista2[$i]->tags,'nrctremp'); ?>';
					dadosEmprestimoAvalista2<? echo $i; ?>['dtmvtolt'] = '<? echo getByTagName($avalista2[$i]->tags,'dtmvtolt'); ?>';
					dadosEmprestimoAvalista2<? echo $i; ?>['vlemprst'] = '<? echo getByTagName($avalista2[$i]->tags,'vlemprst'); ?>';
					dadosEmprestimoAvalista2<? echo $i; ?>['qtpreemp'] = '<? echo getByTagName($avalista2[$i]->tags,'qtpreemp'); ?>';
					dadosEmprestimoAvalista2<? echo $i; ?>['vlpreemp'] = '<? echo getByTagName($avalista2[$i]->tags,'vlpreemp'); ?>';
					dadosEmprestimoAvalista2<? echo $i; ?>['vlsdeved'] = '<? echo getByTagName($avalista2[$i]->tags,'vlsdeved'); ?>';
					arrayEmprestimosAvalista2[<? echo $i; ?>] = dadosEmprestimoAvalista2<? echo $i; ?>;
				<?}?>
			</script>
			<?
		}
	}
	else if(in_array($operacao,array('REG_GRAVAMES','VAL_GRAVAMES','VAL_GRAVAME'))) {

		$xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Cabecalho>";
		$xml .= "    <Bo>b1wgen0171.p</Bo>";
		$xml .= "    <Proc>registrar_gravames</Proc>";
		$xml .= "  </Cabecalho>";
		$xml .= "  <Dados>";
		$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xml .= "    <cddopcao>".$cddopcao."</cddopcao>";
		$xml .= "    <nrctrpro>".$nrctremp."</nrctrpro>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		// Executa script para envio do XML
		$xmlResult = getDataXML($xml,false);

		// Cria objeto para classe de tratamento de XML
		$xmlObj = getObjectXML($xmlResult);

		if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
            if ( $operacao == 'REG_GRAVAMES' ) {
                exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo($(\'#divRotina\'));controlaOperacao(\'\')',false);
            }else{
                exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo($(\'#divRotina\'));controlaOperacao(\'DIV_IMP\')',false);
            }
		}
	}else if(in_array($operacao,array('RECALCULAR_EMPRESTIMO'))) {
		
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Cabecalho>";
		$xml .= "    <Bo>b1wgen0002.p</Bo>";
		$xml .= "    <Proc>recalcular_emprestimo</Proc>";
		$xml .= "  </Cabecalho>";
		$xml .= "  <Dados>";
		$xml .= "     <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "	  <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xml .= "	  <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "	  <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "	  <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xml .= "	  <idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xml .= "	  <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xml .= "	  <dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
		$xml .= "	  <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "	  <idseqttl>".$idseqttl."</idseqttl>";
		$xml .= "     <nrctremp>".$nrctremp."</nrctremp>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xml,false);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObj = getObjectXML($xmlResult);

		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){
		   echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Aimaro","bloqueiaFundo(divRotina);controlaOperacao();");';
           exit;
		}
		
		$oMensagem = $xmlObj->roottag->tags[0]->tags[0];		
        echo 'showError("inform","'.getByTagName($oMensagem->tags,'dsmensag').'","Alerta - Aimaro","bloqueiaFundo(divRotina);controlaOperacao();");';
        exit;
    }else if(in_array($operacao,array('ACIONAMENTOS'))) {
	
		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
		$xml .= "   <nrctremp>" . $nrctremp . "</nrctremp>";
		$xml .= "   <dtinicio>01/01/0001</dtinicio>";
		$xml .= "   <dtafinal>31/12/9999</dtafinal>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "CONPRO", "CONPRO_ACIONAMENTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
		
		

		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
			
		   echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Aimaro","bloqueiaFundo(divRotina);controlaOperacao();");';
           exit;

		}

		$registros = $xmlObj->roottag->tags[0]->tags;
		$qtregist = $xmlObj->roottag->tags[1]->cdata;
		
	}else if (in_array($operacao, array('A_DEMONSTRATIVO_EMPRESTIMO', 'I_DEMONSTRATIVO_EMPRESTIMO'))){ 

		$inpessoa = isset($_POST['inpessoa']) ? $_POST['inpessoa'] : '0';
		$dscatbem = isset($_POST['dscatbem']) ? $_POST['dscatbem'] : '';
		$idfiniof = isset($_POST['idfiniof']) ? $_POST['idfiniof'] : '0';
		$cdfinemp = isset($_POST['cdfinemp']) ? $_POST['cdfinemp'] : '0';
		$dtlibera = isset($_POST['qtdialib']) ? $_POST['qtdialib'] : '0';
		$dsctrliq = isset($_POST['dsctrliq']) ? $_POST['dsctrliq'] : '0';	
		$dtcarenc = isset($_POST['dtcarenc']) ? $_POST['dtcarenc'] : '';	
		$idcarenc = isset($_POST['idcarenc']) ? $_POST['idcarenc'] : '0';	
		$vlprecar = isset($_POST['vlprecar']) ? $_POST['vlprecar'] : '0';

		//Busca valor da tarifa de empréstimo
		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "   <cdlcremp>".$cdlcremp."</cdlcremp>";
		$xml .= "   <cdmotivo>EM</cdmotivo>";
		$xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
		$xml .= "   <vllanmto>".str_replace(',', '.', str_replace('.', '', $vlempres))."</vllanmto>";
		$xml .= "   <dsbemgar>".$dscatbem."</dsbemgar>";
		$xml .= "   <cdprogra></cdprogra>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "ATENDA", "CALC_TARIFA_CADASTRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjTarifa = getObjectXML(retiraAcentos(removeCaracteresInvalidos($xmlResult)));

		if (strtoupper($xmlObjTarifa->roottag->tags[0]->name) == "ERRO") {			
			exibirErro('error','2 - '.$xmlObjTarifa->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
		}
		$tagTarifa = $xmlObjTarifa->roottag->tags[0]->tags;


		//Busca valor do IOF e recálculo da parcela, de acordo com o campo de financiamento de IOF, bens em garantia, etc
   		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "   <nrctremp>0</nrctremp>";
		$xml .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
		$xml .= "   <cdlcremp>".$cdlcremp."</cdlcremp>";
		$xml .= "   <cdfinemp>".$cdfinemp."</cdfinemp>";    
		$xml .= "   <qtpreemp>".$qtparepr."</qtpreemp>";
		$xml .= "   <vlpreemp>".str_replace(',', '.', str_replace('.', '', $vlpreemp))."</vlpreemp>";
		$xml .= "   <vlemprst>".str_replace(',', '.', str_replace('.', '', $vlempres))."</vlemprst>";
		$xml .= "   <dtdpagto>".$dtdpagto."</dtdpagto>";
		$xml .= "   <dtlibera>".$dtlibera."</dtlibera>";
		$xml .= "   <tpemprst>".$tpemprst."</tpemprst>";
		$xml .= "   <dtcarenc>".$dtcarenc."</dtcarenc>";
		$xml .= "   <idcarencia>".$idcarenc."</idcarencia>";
		$xml .= "   <dscatbem>".$dscatbem."</dscatbem>";
		$xml .= "   <idfiniof>".$idfiniof."</idfiniof>";
		$xml .= "   <dsctrliq>".$dsctrliq."</dsctrliq>";
		$xml .= "   <idgravar>N</idgravar>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "ATENDA", "CALC_IOF_EPR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjIOF = getObjectXML(retiraAcentos(removeCaracteresInvalidos($xmlResult)));		

		if (strtoupper($xmlObjIOF->roottag->tags[0]->name) == "ERRO") {			
		   exibirErro('error','3 - '.$xmlObjIOF->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
		}
		$tagIOF = $xmlObjIOF->roottag->tags[0]->tags;


		//Ajusta os valores retornados no XML
		$vltarifa = getByTagName($tagTarifa,'vltarifa');
		$valoriof = getByTagName($tagIOF,'valoriof');
		$vlpreemp = getByTagName($tagIOF,'vlpreemp');

		if (empty($valoriof)){
			$valoriof = 0;
	}


		$valoriofF = str_replace(',', '', $valoriof); //Valor em "float"
		$vltarifaF = str_replace(',', '', $vltarifa); //Valor em "float"
		$vlpreempF = str_replace(',', '', $vlpreemp); //Valor em "float"

		$valoriof = str_replace('.', ',', str_replace(',', '', $valoriof)); //Valor para exibir
		$vltarifa = str_replace('.', ',', str_replace(',', '', $vltarifa)); //Valor para exibir
		$vlpreemp = str_replace('.', ',', str_replace(',', '', $vlpreemp)); //Valor para exibir

		$vlrtotal = str_replace(',', '.', str_replace('.', '', $vlempres));
		if ($idfiniof > 0){				
			$vlrtotal += $vltarifaF + $valoriofF;
	}


		//Recalcula o CET, levando em consideração o valor da parcela retornado no cálculo do IOF
		$xml = "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0002.p</Bo>";
		$xml .= "		<Proc>calcula_cet_novo</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "       <cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
		$xml .= "		<cdagenci>" . $glbvars["cdpactra"] . "</cdagenci>";
		$xml .= "		<nrdcaixa>" . $glbvars["nrdcaixa"] . "</nrdcaixa>";
		$xml .= "		<cdoperad>" . $glbvars["cdoperad"] . "</cdoperad>";
		$xml .= "		<nmdatela>" . $glbvars["nmdatela"] . "</nmdatela>";
		$xml .= "		<idorigem>" . $glbvars["idorigem"] . "</idorigem>";
		$xml .= "		<dtmvtolt>" . $glbvars["dtmvtolt"] . "</dtmvtolt>";
		$xml .= "		<inpessoa>" . $inpessoa . "</inpessoa>";
		$xml .= "		<cdlcremp>" . $cdlcremp . "</cdlcremp>";
		$xml .= "		<tpemprst>" . $tpemprst . "</tpemprst>";
		$xml .= "		<nrdconta>" . $nrdconta . "</nrdconta>";
		$xml .= "		<vlemprst>" . str_replace('.', ',', $vlempres) . "</vlemprst>";
		$xml .= "		<vlpreemp>" . str_replace('.', ',', $vlpreemp) . "</vlpreemp>";
		$xml .= "		<dtdpagto>" . $dtdpagto . "</dtdpagto>";
		$xml .= "		<cdfinemp>" . $cdfinemp . "</cdfinemp>";
		$xml .= "		<dtlibera>" . $dtlibera . "</dtlibera>";
		$xml .= "		<qtpreemp>" . $qtparepr . "</qtpreemp>";
		$xml .= "		<cdusolcr>" . getByTagName($tagTarifa,'cdusolcr') . "</cdusolcr>";
		$xml .= "   	<nrctremp>".$nrctremp."</nrctremp>";
		$xml .= "   	<dscatbem>".$dscatbem."</dscatbem>";
		$xml .= "   	<idfiniof>".$idfiniof."</idfiniof>";		
		$xml .= "		<dsctrliq>" . $dsctrliq . "</dsctrliq>";
		$xml .= "   <dtcarenc>".$dtcarenc."</dtcarenc>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";

		$xmlResult = getDataXML($xml);
		$xmlCET = getObjectXML($xmlResult);

		if (strtoupper($xmlCET->roottag->tags[0]->name) == "ERRO") {			
		   exibirErro('error','4 - '.$xmlCET->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
		}

		$txcetano = $xmlCET->roottag->tags[0]->attributes['TXCETANO'];

		//Atualiza o array do javascript para exibir os valores atualizados no formulário do demonstrativo
		?>
		<script type="text/javascript">
			arrayProposta['vlrtarif'] = '<? echo number_format(str_replace(",",".",$vltarifa),2,",",""); ?>';	
			arrayProposta['vliofepr'] = '<? echo number_format(str_replace(",",".",$valoriof),2,",",""); ?>';	
			arrayProposta['vlrtotal'] = '<? echo number_format(str_replace(",",".",$vlrtotal),2,",",""); ?>';
			arrayProposta['vlpreemp'] = '<? echo number_format(str_replace(",",".",$vlpreemp),2,",",""); ?>';
			arrayProposta['vlprecar'] = '<? echo number_format(str_replace(",",".",$vlprecar),2,",",""); ?>';
			arrayProposta['percetop'] = '<? echo number_format(str_replace(",",".",$txcetano),2,",",""); ?>';
		</script>

	<?
	}else if (in_array($operacao,array('I_PROTECAO_TIT','A_PROTECAO_AVAL', 'A_PROTECAO_TIT','A_PROTECAO_CONJ',
										'C_PROTECAO_TIT','C_PROTECAO_AVAL', 'C_PROTECAO_CONJ','C_PROTECAO_SOC','A_PROTECAO_SOC'))){
		include('valida_operacao_rating.php');
		exit(); //Manter o exit para nao dar echo em nada, para o eval em emprestimo.js -> controlaOperacao() funcionar. Obrigado.
	}else if(in_array($operacao,array('C_PROT_CRED','A_PROT_CRED','E_PROT_CRED','I_PROT_CRED'))){
		
		// ********************************************
		// AMCOM - Retira Etapa Rating exceto para Ailos (coop 3)

   		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "   <cdacesso>HABILITA_RATING_NOVO</cdacesso>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "TELA_PARRAT", "CONSULTA_PARAM_CRAPPRM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjPRM = getObjectXML($xmlResult);

		$habrat = 'N';
		if (strtoupper($xmlObjPRM->roottag->tags[0]->name) == "ERRO") {
			$habrat = 'N';
		} else {
			$habrat = $xmlObjPRM->roottag->tags[0]->tags;
			$habrat = getByTagName($habrat[0]->tags, 'PR_DSVLRPRM');
		}

		if ($glbvars["cdcooper"] == 3 || $habrat == 'N') {
			$inobriga = isset($_POST['inobriga']) ? $_POST['inobriga'] : 'S';
		} else {
			$inobriga = 'S';
		}
		// ********************************************
		$insitest = isset($_POST['insitest']) ? $_POST['insitest'] : '0';
		$cdfinemp = isset($_POST['cdfinemp']) ? $_POST['cdfinemp'] : '0';
		
		/* PRJ - 438 - Rating */
		if($inobriga == "N" && !in_array($operacao,array('C_PROT_CRED'))){ //prj - 438 - bruno - rating - 4 //bug 14668 - 14652
			/* Consultar informaçoes da linha */
			include('consultar_linha.php');

			$flgdisap = getByTagName($linha->tags,'flgdisap');
			$inpessoa = isset($_POST['inpessoa']) ? $_POST['inpessoa'] : '0';
			include('form_org_prot_cred.php');
		}else{

			if($operacao == 'A_PROT_CRED')
				$operacao = "A_PROTECAO_TIT";
			else if($operacao == "I_PROT_CRED")
				$operacao = "I_PROTECAO_TIT";
			else if($operacao == "C_PROT_CRED")
				$operacao = "C_PROTECAO_TIT";

			include('valida_operacao_rating.php');
			exit;
		}	
		
	}

?>
<script type="text/javascript">
	$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
	<?
		if (in_array($operacao,array('I_PROTECAO_TIT','A_PROTECAO_AVAL','A_PROTECAO_TIT','A_PROTECAO_CONJ','C_PROTECAO_TIT','C_PROTECAO_AVAL','C_PROTECAO_CONJ','C_PROTECAO_SOC','A_PROTECAO_SOC'))) {		
	?>
		$('#divConteudoOpcao').css({'height': "550px"});
	<?
		}
	?>
</script>
<?

	// Se estiver consultando, chamar a TABELA
	if(in_array($operacao,array('CT','','REG_GRAVAMES','VAL_GRAVAMES'))) {
        
        // [044]
        $permiteAlterarRating = false;
        $oXML = new XmlMensageria();
        $oXML->add('cooperat', $glbvars["cdcooper"]);

        $xmlResult = mensageria($oXML, "TELA_PARRAT", "CONSULTA_PARAM_RATING", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        $registrosPARRAT = $xmlObj->roottag->tags[0]->tags;
        foreach ($registrosPARRAT as $r) {
            if (getByTagName($r->tags, 'pr_inpermite_alterar') == '1') {
                $permiteAlterarRating = true;
            }
        }
        // [044]
		include('tabela_emprestimos.php');
	} else if(in_array($operacao,array('A_INICIO','I_INICIO','A_FINALIZA','I_FINALIZA','A_NOVA_PROP','A_VALOR','A_AVALISTA','A_NUMERO','I_CONTRATO','TI','TE','TC','CF'))) {
		include('form_nova_prop.php');
	} else if (in_array($operacao,array('C_COMITE_APROV','A_COMITE_APROV','E_COMITE_APROV','I_COMITE_APROV'))){
		//include('form_comite_aprov.php');
		//PRJ 438 - Bruno
		$strComando = "";
		switch ($operacao) {
			case 'A_COMITE_APROV':
				$strComando = "verificaObs('A_ALIENACAO');";
				break;
			case 'C_COMITE_APROV':
				$strComando = "microcredito('C');";
				break;
			case 'E_COMITE_APROV':
				$strComando = "controlaOperacao('')";
				break;
			case 'I_COMITE_APROV':
				$strComando = "verificaObs('I_ALIENACAO')";
				break;
		}
		echo "
		<div id='frmComiteAprov' style='display: none;'>
			<textarea name='dsobserv' id='dsobserv' value=''></textarea>
			<textarea name='dsobscmt' id='dsobscmt' value=''></textarea>
		</div>
		<script type='text/javascript'>
			".$strComando."
			$('#divRotina').hide();
		</script>
		";
	}else if (in_array($operacao,array('C_DADOS_PROP','A_DADOS_PROP','E_DADOS_PROP','I_DADOS_PROP'))){
		
		$strComando = "";//"var operacao = '".$operacao."';";
		switch($operacao){
			case 'A_DADOS_PROP': //OK
				$strComando .= "validaJustificativa('A_BENS_TITULAR');";
			break;
			case 'I_DADOS_PROP': //OK
				$strComando .= "validaJustificativa('I_BENS_TITULAR');";
			break;
			case 'E_DADOS_PROP': //OK
			case 'C_DADOS_PROP':
				$strComando .= "validaJustificativa('C_BENS_ASSOC');";
			break;
		}
		//echo $strComando;
		
		echo "
		<script type='text/javascript'>
			".$strComando."
		</script>
		";
		
		include('form_dados_prop.php');
	}else if (in_array($operacao,array('C_DADOS_PROP_PJ','A_DADOS_PROP_PJ','E_DADOS_PROP_PJ','I_DADOS_PROP_PJ'))){
		//PRJ - 438 - Remoção tela Dados da Proposta
		$strComando = "";
		switch($operacao){
			case 'A_DADOS_PROP_PJ':
				$strComando = "atualizaArray('A_BENS_TITULAR')";
			break;
			case 'C_DADOS_PROP_PJ':
				$strComando = "controlaOperacao('C_BENS_ASSOC')";
			break;
			case 'E_DADOS_PROP_PJ':
				$strComando = "controlaOperacao('')";
			break;
			case 'I_DADOS_PROP_PJ':
				$strComando = "atualizaArray('I_BENS_TITULAR')";
			break;
		};
		echo "
		<script type='text/javascript'>
			".$strComando."
		</script>
		";

		include('form_dados_prop_pj.php');
	}else if (in_array($operacao,array('C_DADOS_AVAL','AI_DADOS_AVAL','A_DADOS_AVAL','I_DADOS_AVAL','IA_DADOS_AVAL','E_DADOS_AVAL'))){
		include('form_dados_aval.php');
	} else if (in_array($operacao,array('I_PROTECAO_TIT','A_PROTECAO_AVAL', 'A_PROTECAO_TIT','A_PROTECAO_CONJ', //OBS - Nunca irá entrar, mas deixei aqui por precaução
										'C_PROTECAO_TIT','C_PROTECAO_AVAL', 'C_PROTECAO_CONJ','C_PROTECAO_SOC','A_PROTECAO_SOC'))) {
		//include ('../../../includes/consultas_automatizadas/form_orgaos.php');
	} else if (in_array($operacao,array('I_MICRO_PERG','A_MICRO_PERG','C_MICRO_PERG'))) {
		include ('questionario.php');	
	} else if (in_array($operacao,array('C_ALIENACAO','AI_ALIENACAO','A_ALIENACAO','E_ALIENACAO','I_ALIENACAO','IA_ALIENACAO','A_BENS','AI_BENS'))){
		include('form_alienacao.php');
	}else if (in_array($operacao,array('C_INTEV_ANU','AI_INTEV_ANU','A_INTEV_ANU','E_INTEV_ANU','I_INTEV_ANU','IA_INTEV_ANU'))){
		include('form_intev_anuente.php');
	}else if (in_array($operacao,array('C_PROT_CRED','A_PROT_CRED','E_PROT_CRED','I_PROT_CRED'))){
		//include('form_org_prot_cred.php');
	}else if (in_array($operacao,array('C_HIPOTECA','AI_HIPOTECA','A_HIPOTECA','E_HIPOTECA','I_HIPOTECA','IA_HIPOTECA'))){
		include('form_hipoteca.php');
	}else if (in_array($operacao,array('A_PARCELAS','V_PARCELAS','C_PARCELAS','I_PARCELAS'))){
		include('tabela_parcelas.php');
	}else if (in_array($operacao,array('T_EFETIVA'))){
		include('form_efetiva_prop.php');
	}else if (in_array($operacao,array('T_AVALISTA1', 'T_AVALISTA2'))){
		include('tabela_emprestimos_avalistas.php');
	}else if (in_array($operacao,array('RATING'))){
		include('tabela_rating.php');
	} else if (in_array($operacao,array('PORTAB_CRED_I', 'PORTAB_CRED_C', 'PORTAB_CRED_A'))) {
        	include('portabilidade/portabilidade.php');
	} else if (in_array($operacao,array('ACIONAMENTOS'))) {
        	include('form_acionamentos.php');
        // PRJ 438 - Sprint 13 - Na consulta também deverá exibir a tela de demostração de empréstimo (Mateus Z)    	
	} else if (in_array($operacao,array('A_DEMONSTRATIVO_EMPRESTIMO','I_DEMONSTRATIVO_EMPRESTIMO','C_DEMONSTRATIVO_EMPRESTIMO'))) {
        	include('form_demonstracao_emprestimo.php');
	}

?>
<script type="text/javascript">

	var msgDsdidade = "<?php echo $msgDsdidade; ?>";
	var flgImp      = "<? echo $flgImp; ?>";

	dtmvtolt = "<? echo $glbvars["dtmvtolt"]; ?>";

	var operacao = "<? echo $operacao; ?>";

	atualizaTela(operacao);
	
	controlaLayout(operacao);

	if ( operacao == 'A_FINALIZA' || operacao == 'I_FINALIZA'){ verificaPropostas(); }
	else if( operacao == 'A_NUMERO' ){ mostraNumero(); }
    else if( operacao == 'A_AVALISTA' ){ controlaOperacao('A_DADOS_AVAL'); }
	else if( (operacao == 'A_NOVA_PROP' || operacao == 'TI' || operacao == 'I_INICIO' || operacao == 'A_INICIO')
			  && arrayProposta['qtpromis'] == "0"){ $('#flgimpnp','#frmNovaProp').val("no").desabilitaCampo(); }
	else if( operacao == 'I_CONTRATO' ){ mostraContrato(); }
	else if( operacao == 'E_COMITE_APROV' ){ controlaOperacao('EV'); }
	else if( flgImp == '1' ){ validaImpressao(); }
	else if( operacao == 'D_EFETIVA'){ controlaOperacao('E_EFETIVA'); }
  //BUG 14436 - rubens
  else if( operacao == 'A_DADOS_AVAL' || operacao == 'C_DADOS_AVAL'){ controlaCamposTelaAvalista(); }
  else if( operacao == 'A_INTEV_ANU' || operacao == 'C_INTEV_ANU'){ controlaCamposTelaInterveniente(); }

	//Se esta tela foi chamada através da rotina "Produtos" então acessa a opção conforme definido pelos responsáveis do projeto P364
    if (executandoProdutos && operacao == '' ) {

		controlaOperacao('I');

    }
	  

</script>

<?php
	function retiraCharEsp($valor){
		$valor = str_replace("\n", ' ',$valor);
		$valor = str_replace("\r",'',$valor);
		$valor = str_replace("'","" ,$valor);
		$valor = str_replace("\\","" ,$valor);
		return $valor;
	}
?>