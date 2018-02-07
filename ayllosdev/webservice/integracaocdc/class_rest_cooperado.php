<?php
/* 
 * Classe Responsavel da requisicao REST do cooperado
 * 
 * @autor: Lucas Reinert
 */
require_once('../class/class_rest_server_json.php');

class RestCDC extends RestServerJson{
    
    private $aParamsRequired;
    
    public function __construct(){
        $this->aParamsRequired = array('cooperativaLojista','pessoaTipo','CPFCNPJNumero');
    }
    
    public function __destruct(){
        unset($this->aParamsRequired);
    }
	
    // Classe sobrescrita
    protected function getDados() {
        return (object) $_GET;
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
									 $contas = '',
									 $cdcritic = '0', 
									 $dscritic = ''){
		// Transformar XML de contas em array
		$jContas = json_encode($contas);
		$aContas = json_decode($jContas, true);
		$contas = is_array($aContas) ? (array_key_exists('conta', $aContas) ? $aContas['conta'] : '') : '';
		$islist = is_array($contas) && ( empty($contas) || array_keys($contas) === range(0,count($contas)-1) );
		
        $aRetorno = array();
        $aRetorno['status']      = $status;
        $aRetorno['nrtransacao'] = $numeroTransacao;
		if ($islist || !(is_array($aContas))){
			$aRetorno['contas'] 	 = $contas;
		}else{
			$aRetorno['contas'][0] 	 = $contas;
		}
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
    private function processaRetornoErro($status, $mensagemDetalhe, $dscritic = '', $idacionamento = ''){
        // Grava o erro no arquivo TEXTO
        $xml  = "<Root>";
        $xml .= " <Dados>";
		$xml .= "   <dsrequis><![CDATA[".$this->getURI()."]]></dsrequis>";		
        $xml .= "   <dsmessag>".$mensagemDetalhe."</dsmessag>";
        $xml .= "   <nmarqlog>integracaocdc</nmarqlog>";
        $xml .= " </Dados>";
        $xml .= "</Root>";
        mensageria($xml, "WEBS0003", "GRAVA_REQUISICAO_ERRO", 0, 0, 0, 5, 0, "</Root>");
        // Retorna a mensagem de critica
        return $this->processaRetorno((string) $status,(string) $mensagemDetalhe,(string) $idacionamento, '', '0', (string) $dscritic);
    }
    
    /**
     * Método responsavel por enviar de sucesso
     * @param String $status
     * @param String $mensagemDetalhe
     * @param String $numeroTransacao
     * @param String $contas
     * @param String $cdcritic
     * @param String $dscritic
     * @return boolean
     */
    private function processaRetornoSucesso($status,$mensagemDetalhe,$numeroTransacao,$contas,$cdcritic,$dscritic){
        return $this->processaRetorno((string) $status,(string) $mensagemDetalhe,(string) $numeroTransacao, $contas,(string) $cdcritic,(string) $dscritic);
    }

    /**
     * Valida se todos os parametros recebidos estão corretos
     * @param Object $oDados
     * @return boolean
     */
    private function validaParametrosRecebidos($oDados){
        // Condicao para verificar se eh um objeto
        if (!is_object($oDados)){
            $this->processaRetornoErro(400,'Parametro invalido.');
            return false;
        }
		
        // Verifica se todos os parametros foram recebidos
        foreach ($this->aParamsRequired as $sPametro){
			if (!array_key_exists($sPametro,get_object_vars($oDados))){
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
            $this->setMetodoRequisitado($_SERVER['REQUEST_METHOD']);
            
            // // Valida os dados da requisicao
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
			$xml .= "	<cdcooper>".$oDados->cooperativaLojista."</cdcooper>";
			$xml .= "	<cdcoploj>".$oDados->cooperativaLojista."</cdcoploj>";
			$xml .= "   <dsusuari>".$this->getUsuario()."</dsusuari>";
			$xml .= "   <dsdsenha>".$this->getSenha()."</dsdsenha>";			
			$xml .= "   <cdcliente>1</cdcliente>";
			$xml .= " </Dados>";
			$xml .= "</Root>";
			$sXmlResult = mensageria($xml, "EMPR0012", "VALIDA_INTEGRACAO", 0, 0, 0, 5, 0, "</Root>");
			$oRetorno  = simplexml_load_string($sXmlResult);
			
			// Vamos verificar se veio retorno de erro
			if (isset($oRetorno->Erro->Registro->dscritic)){
				$dscritic = $oRetorno->Erro->Registro->dscritic;
				if (strpos($dscritic, 'Erro geral') !== false){
					$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.',$dscritic,$idacionamento);
				}else{
					$this->processaRetornoErro(400,$dscritic,'',$idacionamento);
				}
				return false;
			}			
            // Gravar acionamento do serviço
            $xml  = "<Root>";
            $xml .= " <Dados>";
			$xml .= "	<cdcooper>".$oDados->cooperativaLojista."</cdcooper>";
			$xml .= "	<cdagenci></cdagenci>";
			$xml .= "	<cdoperad>AUTOCDC</cdoperad>";
			$xml .= "	<cdorigem>5</cdorigem>";			
			$xml .= "	<nrctrprp>0</nrctrprp>";
			$xml .= "	<nrdconta></nrdconta>";
			$xml .= "	<cdcliente>1</cdcliente>";
			$xml .= "	<tpacionamento>1</tpacionamento>";
			$xml .= "	<dsoperacao>INTEGRACAO CDC - CONSULTA COOPERADO</dsoperacao>";
			$xml .= "	<dsuriservico><![CDATA[".$this->getURI()."]]></dsuriservico>";
			$xml .= "	<dsmetodo>".$this->getMetodoRequisitado()."</dsmetodo>";
			$xml .= "	<dtmvtolt></dtmvtolt>";			
			$xml .= "	<cdstatus_http></cdstatus_http>";
			$xml .= "	<dsconteudo_requisicao><![CDATA[".$this->getURI()."]]></dsconteudo_requisicao>";
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
			
            // Vamos verificar se veio retorno 
            if (isset($oRetorno->Erro->Registro->dscritic)){
				$dscritic = $oRetorno->Erro->Registro->dscritic;
				if (strpos($dscritic, 'Erro geral') !== false){
					$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.',$dscritic);
				}else{
					$this->processaRetornoErro(400,$dscritic);
				}
                return false;
            }
			// Capturar o identificador de acionamento
			$idacionamento = $oRetorno->idacionamento;
			
			if ($oDados->pessoaTipo == 'F'){
				$inpessoa = 1;
			}else{
				$inpessoa = 2;
			}
			
			// Remover formato e manter apenas caracteres numéricos
			$nrcpfcgc = preg_replace("/[^0-9]/", "", $oDados->CPFCNPJNumero);

            // Processa a informacao do banco de dados        
            $xml  = "<Root>";
            $xml .= " <Dados>";
            $xml .= "   <cdcooper>".$oDados->cooperativaLojista."</cdcooper>";
            $xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
            $xml .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
            $xml .= " </Dados>";
            $xml .= "</Root>";
            $sXmlResult = mensageria($xml, "EMPR0012", "CONSULTA_COOPERADO", 0, 0, 0, 5, 0, "</Root>");
            $oRetorno  = simplexml_load_string($sXmlResult);
			
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
                                          'Consulta de cooperado realizada com sucesso',
                                          $idacionamento,
										  $oRetorno->inf->contas,
                                          0,
                                          '');

        } catch(RestException $oException){
            $this->processaRetornoErro($oException->getCode(), $oException->getMessage());
            return false;            
        } catch (Exception $oException){
            $this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.');
            return false;
        }
        return true;
    }
}
?>