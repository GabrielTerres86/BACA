<?php
/* 
 * Classe Responsavel da requisicao REST da análise
 * 
 * @autor: Lucas Reinert
 */
require_once('../class/class_rest_server_json.php');

class RestCDC extends RestServerJson{
	
	private $aParamsRequired;
	
	public function __construct(){
		// Parâmetros obrigatórios Inclusão
		$this->aParamsRequired = array('cooperativaCodigo'
									  ,'contaNumero'
									  ,'contaDV'
									  ,'proposta'
									  ,'patrimonioPessoalLivre'
									  ,'dataScoreBVS'
									  ,'liquidez'
									  ,'notaRating'
									  ,'nivelRisco'
									  ,'descricaoScoreBVS'
									  ,'informacaoCadastral'
									  ,'percepcaoGeralEmpresa'
									  ,'garantia'
									  ,'protocolo'
									  ,'resultadoAnaliseRegra'
									  ,'scoreRating');
	}
	
	public function __destruct(){
		unset($this->aParamsRequired);
	}
	
	/**
	 * Método responsavel por enviar a mensagem de resposta a requisicao
	 * @param String $status
	 * @param String $mensagemDetalhe
	 * @param String $numeroTransacao
	 * @param String $contas
	 * @param String $cdcritic
	 * @param String $dscritic
	 * @return boolean
	 */
	private function processaRetorno($status, 
									 $mensagemDetalhe, 
									 $numeroTransacao = '00000000000000000000', 
									 $cdcritic = '0', 
									 $dscritic = ''){		
		$aRetorno = array();
		$aRetorno['status']      = $status;
		$aRetorno['nrtransacao'] = $numeroTransacao;
		$aRetorno['cdcritic']    = $cdcritic;
		$aRetorno['dscritic']    = $dscritic;
		$aRetorno['msg_detalhe'] = $mensagemDetalhe;
		
		// Atualizar acionamento do serviço
		$xml  = "<Root>";
		$xml .= " <Dados>";
		$xml .= "	<cdstatus_http>".$status."</cdstatus_http>";
		$xml .= "	<flgreenvia>0</flgreenvia>";
		$xml .= "	<idacionamento>".$numeroTransacao."</idacionamento>";
		$xml .= "	<dsresposta_requisicao>".json_encode($aRetorno)."</dsresposta_requisicao>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		$sXmlResult = mensageria($xml, "WEBS0003", "ATUALIZA_ACIONAMENTO", 0, 0, 0, 5, 0, "</Root>");		
	
		// Setando o codigo do status no Header da resposta
		header("Cache-Control: no-cache, must-revalidate");
		header("Expires: 0");
		header('Content-Type: ' . RestFormat::$aRestFormat[$this->getTypeFormato()]);
		header('Status-Code: '.$status, true, $status);
		
		// Enviando a resposta para o servico
		return $this->processaRetornoFormato($aRetorno);
	}
	
	/**
	 * Método responsavel por enviar a mensagem de Exception
	 * @param String Status
	 * @param String Mensagem de detalhe
	 * @return boolean
	 */
	private function processaRetornoErro($status, $mensagemDetalhe, $cdcritic, $dscritic = '', $idacionamento = ''){		
		// Grava o erro no arquivo TEXTO
		$xml  = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <dsmessag>".$mensagemDetalhe."</dsmessag>";
		$xml .= "   <dsrequis>".$this->getFileContents()."</dsrequis>";
		$xml .= "   <nmarqlog>integracaocdc</nmarqlog>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		mensageria($xml, "WEBS0003", "GRAVA_REQUISICAO_ERRO", 0, 0, 0, 5, 0, "</Root>");
		// Retorna a mensagem de critica
		return $this->processaRetorno((string) $status,(string) $mensagemDetalhe,(string) $idacionamento, $cdcritic, (string) $dscritic);
	}
	
	/**
	 * Método responsavel por enviar de sucesso
	 * @param String $status
	 * @param String $mensagemDetalhe
	 * @param String $numeroTransacao
	 * @param json $dsjsonan
	 * @param String $cdcritic
	 * @param String $dscritic
	 * @return boolean
	 */
	private function processaRetornoSucesso($status,$mensagemDetalhe,$numeroTransacao,$cdcritic,$dscritic){
		return $this->processaRetorno((string) $status,(string) $mensagemDetalhe,(string) $numeroTransacao, (string) $cdcritic,(string) $dscritic);
	}

	/**
	 * Retorna todas as keys de um array
	 * @param Array
	 * @return boolean
	 */	
	public function multiarray_keys($array) {
		if(!isset($keys) || !is_array($keys)) {
			$keys = array();
		}
		foreach($array as $key => $value) {
			$keys[] = $key;
			if(is_array($value)) {
				$keys = array_merge($keys,$this->multiarray_keys($value));
			}
		}
		return $keys;

	}
	
	/**
	 * Valida se todos os parametros recebidos estão corretos
	 * @param Object $oDados
	 * @return boolean
	 */
	private function validaParametrosRecebidos($oDados){
		
		// Transformar dados recebidos em array
		$jDados = json_encode($oDados);
		$aDados = json_decode($jDados, true);

		// Condicao para verificar se eh um objeto
		if (!is_object($oDados)){
            $this->processaRetornoErro(400,'Parametro invalido.');
			return false;
		}

		$aKeys = $this->multiarray_keys($aDados);

		// Verifica se todos os parametros foram recebidos
		foreach ($this->aParamsRequired as $sPametro){
			if (array_search($sPametro, $aKeys, true) === false){
				$this->processaRetornoErro(400,'Parametro invalido.');
				return false;
			}
		}
		
		return true;
	}
	
	/**
	 * Processa os dados da Requisicao
	 */
	public function processaRequisicao(){
		try{
			$this->setMetodoRequisitado(strtoupper($_SERVER['REQUEST_METHOD']));
			
			// Valida os dados da requisicao
			if (!$this->validaRequisicao()){
				return false;
			}

			// Busca os dados da requisicao
			$oDados = $this->getDados();
			
			// Valida se veio todos os parametros obrigatorios
			if (!$this->validaParametrosRecebidos($oDados)){
				return false;
			}
			
			// Monta retorno da proposta a partir do motor de crédito
			$xml  = "<Root>";
			$xml .= " <Dados>";
			$xml .= "	<cdcooper>".$oDados->indicadoresGeradosRegra->cooperativaCodigo."</cdcooper>";
			$xml .= "   <dsusuari>".$this->getUsuario()."</dsusuari>";
			$xml .= "   <dsdsenha>".$this->getSenha()."</dsdsenha>";
			$xml .= "   <cdcliente>1</cdcliente>";
			$xml .= " </Dados>";
			$xml .= "</Root>";
			$sXmlResult = mensageria($xml, "EMPR0012", "VALIDA_INTEGRACAO", 0, 0, 0, 5, 0, "</Root>");
			$oRetorno  = simplexml_load_string($sXmlResult);
			
			// Vamos verificar se veio retorno de erro
			if (isset($oRetorno->Erro->Registro->dscritic)){
				$cdcritic = $oRetorno->Erro->Registro->cdcritic;
				$dscritic = $oRetorno->Erro->Registro->dscritic;
				if (strpos($dscritic, 'Erro geral') !== false){
					$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.',$cdcritic,$dscritic,$idacionamento);
				}else{
					$this->processaRetornoErro(400,'Erro na validacao do negocio',$cdcritic,$dscritic,$idacionamento);
				}
				return false;
			}
			
			$dsoperacao = 'INTEGRACAO CDC - ANALISE PROPOSTA';
			$nrctremp = str_replace('.', '', trim($oDados->proposta));

			// Gravar acionamento do serviço
			$xml  = "<Root>";
			$xml .= " <Dados>";
			$xml .= "	<cdcooper>".$oDados->indicadoresGeradosRegra->cooperativaCodigo."</cdcooper>";
			$xml .= "	<cdagenci>1</cdagenci>";
			$xml .= "	<cdoperad>AUTOCDC</cdoperad>";
			$xml .= "	<cdorigem>5</cdorigem>";
			$xml .= "	<nrctrprp>".$nrctremp."</nrctrprp>";
			$xml .= "	<nrdconta>".$oDados->indicadoresGeradosRegra->contaNumero.$oDados->indicadoresGeradosRegra->contaDV."</nrdconta>";
			$xml .= "	<cdcliente>1</cdcliente>";
			$xml .= "	<tpacionamento>1</tpacionamento>";
			$xml .= "	<dsoperacao>".$dsoperacao."</dsoperacao>";
			$xml .= "	<dsuriservico><![CDATA[".$this->getURI()."]]></dsuriservico>";
			$xml .= "	<dsmetodo>".$this->getMetodoRequisitado()."</dsmetodo>";
			$xml .= "	<dtmvtolt></dtmvtolt>";
			$xml .= "	<cdstatus_http></cdstatus_http>";
			$xml .= "	<dsconteudo_requisicao>".$this->getFileContents()."</dsconteudo_requisicao>";
			$xml .= "	<dsresposta_requisicao></dsresposta_requisicao>";
			$xml .= "	<dsprotocolo>".$oDados->protocolo."</dsprotocolo>";
			$xml .= "	<flgreenvia>0</flgreenvia>";
			$xml .= "	<nrreenvio>0</nrreenvio>";
			$xml .= "	<tpconteudo>1</tpconteudo>";
			$xml .= "	<tpproduto>0</tpproduto>";
			$xml .= " </Dados>";
			$xml .= "</Root>";
			$sXmlResult = mensageria($xml, "WEBS0003", "GRAVA_ACIONAMENTO", 0, 0, 0, 5, 0, "</Root>");
			$oRetorno  = simplexml_load_string($sXmlResult);
			
			// Vamos verificar se veio retorno de erro
			if (isset($oRetorno->Erro->Registro->dscritic)){
				$cdcritic = $oRetorno->Erro->Registro->cdcritic;
				$dscritic = $oRetorno->Erro->Registro->dscritic;
				if (strpos($dscritic, 'Erro geral') !== false){
					$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.',$cdcritic,$dscritic);
				}else{
					$this->processaRetornoErro(400,$dscritic);
				}
				return false;
			}
			// Capturar o identificador de acionamento
			$idacionamento = $oRetorno->idacionamento;
			$segueFluxoAtacado = (isset($oDados->indicadoresGeradosRegra->segueFluxoAtacado))? $oDados->indicadoresGeradosRegra->segueFluxoAtacado : FALSE;

			// Processa a informacao do banco de dados
			$xml  = "<Root>";
			$xml .= " <Dados>";
			$xml .= "   <cdorigem>5</cdorigem>";
			$xml .= "   <dsprotoc>".$oDados->protocolo."</dsprotoc>";
			$xml .= "   <cdcooper>".$oDados->indicadoresGeradosRegra->cooperativaCodigo."</cdcooper>";
			$xml .= "   <nrdconta>".$oDados->indicadoresGeradosRegra->contaNumero.$oDados->indicadoresGeradosRegra->contaDV."</nrdconta>";
			$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";
			$xml .= "   <nrtransa>".$idacionamento."</nrtransa>";
			$xml .= "   <dsresana>".$oDados->resultadoAnaliseRegra."</dsresana>";
			$xml .= "   <indrisco>".$oDados->indicadoresGeradosRegra->nivelRisco."</indrisco>";
			$xml .= "   <nrnotrat>".$oDados->indicadoresGeradosRegra->notaRating."</nrnotrat>";
			$xml .= "   <nrinfcad>".$oDados->indicadoresGeradosRegra->informacaoCadastral."</nrinfcad>";
			$xml .= "   <nrliquid>".$oDados->indicadoresGeradosRegra->liquidez."</nrliquid>";
			$xml .= "   <nrgarope>".$oDados->indicadoresGeradosRegra->garantia."</nrgarope>";
			$xml .= "   <nrparlvr>".$oDados->indicadoresGeradosRegra->patrimonioPessoalLivre."</nrparlvr>";
			$xml .= "   <nrperger>".$oDados->indicadoresGeradosRegra->percepcaoGeralEmpresa."</nrperger>";
			$xml .= "   <desscore>".$oDados->indicadoresGeradosRegra->descricaoScoreBVS."</desscore>";
			$xml .= "   <datscore>".$oDados->indicadoresGeradosRegra->dataScoreBVS."</datscore>";
			$xml .= "   <flgpreap>".$oDados->indicadoresGeradosRegra->preAprovado."</flgpreap>";
			$xml .= "   <idfluata>".$segueFluxoAtacado."</idfluata>";
			$xml .= "   <dsrequis>".$this->getFileContents()."</dsrequis>";
			$xml .= "   <namehost>".$this->getNameHost()."</namehost>";
			$xml .= "   <scorerat>".$oDados->indicadoresGeradosRegra->scoreRating."</scorerat>";
			$xml .= " </Dados>";
			$xml .= "</Root>";
			$sXmlResult = mensageria($xml, "EMPR0012", "PROCESSA_ANALISE", 0, 0, 0, 5, 0, "</Root>");
			$oRetorno   = simplexml_load_string($sXmlResult);
			
			// Vamos verificar se veio retorno 
			if ((!isset($oRetorno->inf->status)) || ($oRetorno->inf->status == 0) || ($oRetorno->inf->status == '')){
				$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.','0','Erro geral do sistema');
				return false;
			}elseif ($oRetorno->inf->retorno_proc == 'OK') {
				// se tiver OK retornamos 200 para manter o padrao da integracaocdc
				$this->processaRetornoSucesso(200,
											  $oRetorno->inf->msg_detalhe,
											  $idacionamento,
											  $oRetorno->inf->cdcritic,
											  $oRetorno->inf->dscritic);
			}else{
				// Retornar o status tratado dentro dos programas
			$this->processaRetornoSucesso($oRetorno->inf->status,
										  $oRetorno->inf->msg_detalhe,
										  $idacionamento,
										  $oRetorno->inf->cdcritic,
										  $oRetorno->inf->dscritic);
			}
            

		} catch(RestException $oException){
			$this->processaRetornoErro($oException->getCode(), $oException->getMessage());
			return false;            
		} catch (Exception $oException){
			$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.', '0', 'Erro geral do sistema.');
			return false;
		}
		return true;
	}
}
?>