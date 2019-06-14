<? 
/*!
 * FONTE          : manter_rotina.php
 * CRIAÇÃO      : Rodrigo Bertelli (RKAM)
 * DATA CRIAÇÃO : 16/06/2014
 * OBJETIVO       : Mantem a rotina das informacoes de inclusao, selecao e delecao na tela CBRFRA
 *
 *   16/08/2016 - #456682 Adicionados os campos tipo e nrcpfcnpj nas rotinas de manutenção da tela (Carlos)
 *   22/08/2016 - #456682 Adicionados os campos nrcpf e nrcnpj nas rotinas de manutenção da tela (Carlos)
 *   16/09/2016 - Melhoria nas mensagens, de "Código" para "Registro", para ficar genérico, conforme solicitado pelo Maicon (Carlos)
 *   15/02/2016 - Inclusão do tipo  Telefone Celular. Melhoria nas mensagens. Projeto 321 - Recarga de Celular. (Lombardi)
 */
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	$stracao  = $_POST['cddopcao'];
	$stropcao = $_POST['stropcao'];
	$tipo     = $_POST['tipo'];      // 1-boleto; 2-ted pf; 3-ted pj; 4-telefone celular;
	$dsfraude = $_POST['dsfraude'];

	$strcodexc   = $_POST['nrdcodigoexc'];
	$datinclusao = $_POST['nmdata'];
	$datinicial  = $_POST['nmdatainicial'];
	$datfinal    = $_POST['nmdatafinal'];
	$nriniseq    = isset($_POST['nriniseq']) ? $_POST['nriniseq'] : 0;
	$nrregist    = isset($_POST['nrregist']) ? $_POST['nrregist'] : 0;

	//rotina da exclusao de codigos com fraude	
	if ($stracao == 'E' && $strcodexc != '') {

		$xmlexclusao = new XmlMensageria();
		$xmlexclusao->add('cdcooper', $glbvars["cdcooper"])
		            ->add('tpfraude', $tipo)
					->add('dsfraude', $strcodexc);

		$strdisabled = '';		
		$datinicial = '';
		$datfinal = '' ;

		$xmlResultExc = mensageria($xmlexclusao, "CBRFRA", 'EXCCBRFRA', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
		$xmlObjFraudeExc = getObjectXML($xmlResultExc);

		if (strtoupper($xmlObjFraudeExc->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObjFraudeExc->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',$msgErro,'Alerta - Ayllos',false);
		} else{
			$msgOK = "Registro de fraude exclu&iacute;do com sucesso!";
			exibirErro('inform',$msgOK,'Alerta - Ayllos',false);
		}
	}
	else
	if($stracao == 'I' && $dsfraude != ''){

		$strdisabled = '';

		$xmlInclusao  = new XmlMensageria();
		$xmlInclusao->add('cdcooper',$glbvars["cdcooper"])
					->add('tpfraude',$tipo)
					->add('dsfraude',$dsfraude)
					->add('dtsolici',$datinclusao);

		$xmlResultInc = mensageria($xmlInclusao, "CBRFRA", 'INCCBRFRA', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
		$xmlObjFraudeInc = getObjectXML($xmlResultInc);
		
		if (strtoupper($xmlObjFraudeInc->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObjFraudeInc->roottag->tags[0]->tags[0]->tags[4]->cdata;			
			exibirErro('error',$msgErro,'Alerta - Ayllos',false);			
		} else{
			$msgOK = "Registro de fraude inclu&iacute;do com sucesso!";
			exibirErro('inform',$msgOK,'Alerta - Ayllos',false);
		}
		
		$tipo       = 1;
		$strcodbar  = '';
		$nrcpf      = '';
		$nrcnpj     = '';		
		$datinicial = '';
		$datfinal   = '';
	}
	else {
		//rotina da consulta de codigos com fraude	
		// caso a consulta seja no modo exclusao ativa a opcao de exclusao na tabela
		$strdisabled = ($stropcao == 'E') ? '' : 'display:none';

		if ($dsfraude == '000.000.000-00') {
			$dsfraude = '';
		}

		$xml = new XmlMensageria();
		$xml->add('cdcooper',$glbvars["cdcooper"])
		    ->add('tpfraude',$tipo)
			->add('dsfraude',$dsfraude)
			->add('dtiniper',$datinicial)
            ->add('dtfimper',$datfinal)
			->add('nriniseq',$nriniseq)
			->add('nrregist',$nrregist);

		//realiza o processo de mensageria para efetuar a transacao no banco de dados
		$xmlResult = mensageria($xml, "CBRFRA", 'CONCBRFRA', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
		$xmlObjFraude = getObjectXML($xmlResult); 

		//retorno dos registros
		$registros = $xmlObjFraude->roottag->tags;

		include 'tabela_cbrfra.php'; 		
	}

?>