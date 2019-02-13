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
									  ,'contratoNumero'
									  ,'contratoSituacao');
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
		$xml .= "	<dsresposta_requisicao>".json_encode($aRetorno, JSON_FORCE_OBJECT)."</dsresposta_requisicao>";
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

			$xml  = "<Root>";
			$xml .= " <Dados>";
			$xml .= "	<cdcooper>".$oDados->cooperativaCodigo."</cdcooper>";
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
			
			$dsoperacao = 'INTEGRACAO CDC - NOTIFICA SITUACAO PROPOSTA';
			$nrctremp = str_replace('.', '', trim($oDados->contratoNumero));

            // Gravar acionamento do serviço
            $xml  = "<Root>";
            $xml .= " <Dados>";
			$xml .= "	<cdcooper>".$oDados->cooperativaCodigo."</cdcooper>";
			$xml .= "	<cdagenci>1</cdagenci>";
			$xml .= "	<cdoperad>AUTOCDC</cdoperad>";
			$xml .= "	<cdorigem>5</cdorigem>";			
			$xml .= "	<nrctrprp>".$nrctremp."</nrctrprp>";
			$xml .= "	<nrdconta>".$oDados->contaNumero.$oDados->contaDV."</nrdconta>";
			$xml .= "	<cdcliente>1</cdcliente>";
			$xml .= "	<tpacionamento>1</tpacionamento>";
			$xml .= "	<dsoperacao>".$dsoperacao."</dsoperacao>";
			$xml .= "	<dsuriservico><![CDATA[".$this->getURI()."]]></dsuriservico>";
			$xml .= "	<dsmetodo>".$this->getMetodoRequisitado()."</dsmetodo>";
			$xml .= "	<dtmvtolt></dtmvtolt>";			
			$xml .= "	<cdstatus_http></cdstatus_http>";
			$xml .= "	<dsconteudo_requisicao>".$this->getFileContents()."</dsconteudo_requisicao>";
			$xml .= "	<dsresposta_requisicao></dsresposta_requisicao>";
			$xml .= "	<dsprotocolo></dsprotocolo>";
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

			// Processa a informacao do banco de dados        
			$xml  = "<Root>";
			$xml .= " <Dados>";
			$xml .= "   <cdcooper>".$oDados->cooperativaCodigo."</cdcooper>";
			$xml .= "   <nrdconta>".$oDados->contaNumero.$oDados->contaDV."</nrdconta>";
			$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";
			$xml .= "   <insitpro>".$oDados->contratoSituacao."</insitpro>";
			$xml .= " </Dados>";
			$xml .= "</Root>";
			$sXmlResult = mensageria($xml, "EMPR0012", "REGISTRA_PUSH_PRP_CDC", 0, 0, 0, 5, 0, "</Root>");
            $oRetorno   = simplexml_load_string($sXmlResult);
			
            // Vamos verificar se veio retorno 
            if (isset($oRetorno->Erro->Registro->dscritic)){
				$dscritic = $oRetorno->Erro->Registro->dscritic;
				if (strpos($dscritic, 'Erro geral') !== false){
					$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.',$dscritic,$idacionamento);
				}elseif(strpos($dscritic, 'Nao Cooperado') !== false){
					$this->processaRetornoErro(404,'Consulta de cooperado realizada com restricao!',$dscritic,$idacionamento);
				}else{
					$this->processaRetornoErro(400,$dscritic,'',$idacionamento);
				}
                return false;
            }

            //Retorna a resposta para o servico
            $this->processaRetornoSucesso(200,
                                          'Situacao proposta atualizada com sucesso',
                                          $idacionamento,
										  '',
                                          0,
                                          '');
            
										  
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