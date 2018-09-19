<?php
/*!
 * FONTE        : busca_poderes.php
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 04/07/2013 
 * OBJETIVO     : Busca dados referente aos poderes de Representantes/Procuradores
 *
 * ALTERACOES   :  15/02/2018 - Ajustado problema que não deixava a tela de poderes abrir pois
 *								havia um FIND retorando mais de um registro. Para solucionar
 *								fiz o filtro com a chave correta. (SD 841137 - Kelvin). 
 *
 */
	if (!isset($idseqttl)) 
		$idseqttl = 0;
	
	// Monta o xml de requisição
	$xmlBuscaDadosPoderes  = '';
	$xmlBuscaDadosPoderes .= '<Root>';
	$xmlBuscaDadosPoderes .= '	<Cabecalho>';
	$xmlBuscaDadosPoderes .= '		<Bo>b1wgen0058.p</Bo>';
	$xmlBuscaDadosPoderes .= '		<Proc>busca_dados_poderes</Proc>';
	$xmlBuscaDadosPoderes .= '	</Cabecalho>';
	$xmlBuscaDadosPoderes .= '	<Dados>';
	$xmlBuscaDadosPoderes .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xmlBuscaDadosPoderes .= '		<tpctrato>6</tpctrato>';
	$xmlBuscaDadosPoderes .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xmlBuscaDadosPoderes .= '		<nrdctpro>'.$nrdctato.'</nrdctpro>';
	$xmlBuscaDadosPoderes .= '		<cpfprocu>'.$nrcpfcgc.'</cpfprocu>';		
	$xmlBuscaDadosPoderes .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xmlBuscaDadosPoderes .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xmlBuscaDadosPoderes .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xmlBuscaDadosPoderes .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xmlBuscaDadosPoderes .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xmlBuscaDadosPoderes .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xmlBuscaDadosPoderes .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xmlBuscaDadosPoderes .= '	</Dados>';
	$xmlBuscaDadosPoderes .= '</Root>';	
	
	$xmlResultBuscaDadosPoderes = getDataXML($xmlBuscaDadosPoderes);
	$xmlObjetoBuscaDadosPoderes = getObjectXML($xmlResultBuscaDadosPoderes);	
	
	$registros = $xmlObjetoBuscaDadosPoderes->roottag->tags[1]->tags;	
	$inpessoa = $xmlObjetoBuscaDadosPoderes->roottag->tags[0]->attributes['INPESSOA'];
	$idastcjt = $xmlObjetoBuscaDadosPoderes->roottag->tags[0]->attributes['IDASTCJT'];
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjetoBuscaDadosPoderes->roottag->tags[0]->name) == 'ERRO') {

		if ( $operacao_proc == 'IB' ) { 
			$metodo = 'bloqueiaFundo(divRotina);controlaOperacaoProc(\'TI\');';
		} else {
			$metodo = 'bloqueiaFundo(divRotina);controlaOperacaoProcuradores();';
		}		
		
		exibirErro('error',$xmlObjetoBuscaDadosPoderes->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$metodo,false);
		
	}
	
	// Monta o xml de requisição
	$xmlBuscaListaPoderes  = '';
	$xmlBuscaListaPoderes .= '<Root>';
	$xmlBuscaListaPoderes .= '	<Cabecalho>';
	$xmlBuscaListaPoderes .= '		<Bo>b1wgen0058.p</Bo>';
	$xmlBuscaListaPoderes .= '			<Proc>lista_poderes</Proc>';
	$xmlBuscaListaPoderes .= '	</Cabecalho>';
	$xmlBuscaListaPoderes .= "  <Dados>";
	$xmlBuscaListaPoderes .= "       <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xmlBuscaListaPoderes .= "  </Dados>";
	$xmlBuscaListaPoderes .= '</Root>';

	
	$xmlResultBuscaListaPoderes = getDataXML($xmlBuscaListaPoderes);
	$xmlObjetoBuscaListaPoderes = getObjectXML($xmlResultBuscaListaPoderes);	
	$listaPoderes = $xmlObjetoBuscaListaPoderes->roottag->tags[0]->attributes['LSTPODER'];
	
	$arrPoderes = explode(",",$listaPoderes);
	
	include('formulario_poderes.php');
		
?> 