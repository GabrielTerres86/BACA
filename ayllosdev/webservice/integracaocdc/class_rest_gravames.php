<?php
/* 
 * Classe Responsavel da requisicao REST da proposta
 * 
 * @autor: Lucas Reinert
 */
require_once('../class/class_rest_server_json.php');

class RestCDC extends RestServerJson{
    
    private $aParamsRequired;
    
    public function __construct(){
		// Parâmetros obrigatórios Inclusão
        $this->aParamsRequired = array('contratoNumero',
									  'cooperativaAssociadoCodigo',
									  'contaAssociadoNumero',
									  'contaAssociadoDV',
									  'categoriaBem',
									  'descricaoBem',
									  'tipoBem',
									  'corBem',
									  'valorMercadoBem',
									  'anoModeloBem',
									  'anoFabricaoBem');        										
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
									 $dsjsonan = '',
									 $cdcritic = '0', 
									 $dscritic = ''){		
        $aRetorno = array();
        $aRetorno['status']      = $status;
        $aRetorno['nrtransacao'] = $numeroTransacao;
		if (is_array($dsjsonan)){
			// Percorrer cada item retornado do json
			foreach($dsjsonan as $key => $val){
				$aRetorno[$key] = $val;
			}
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
        // Retorna a mensagem de critica
        return $this->processaRetorno((string) $status,(string) $mensagemDetalhe,(string) $idacionamento, '', '0', (string) $dscritic);
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
    private function processaRetornoSucesso($status,$mensagemDetalhe,$numeroTransacao,$dsjsonan,$cdcritic,$dscritic){
        return $this->processaRetorno((string) $status,(string) $mensagemDetalhe,(string) $numeroTransacao, $dsjsonan,(string) $cdcritic,(string) $dscritic);
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
			if (array_search($sPametro,$aKeys, true) === false){
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
            $this->setMetodoRequisitado(strtoupper($_SERVER["HTTP_METHOD"]));
            
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
			
			switch (strtoupper($_SERVER["HTTP_METHOD"])) {
				case 'POST': // Inclusão
					$cddopcao = 'I';
					break;
				case 'PUT': // Alteração
					$cddopcao = 'A';
					break;
				case 'DELETE': // Cancelamento
					$cddopcao = 'E';
					break;
			}
			
            // Gravar acionamento do serviço
            $xml  = "<Root>";
            $xml .= " <Dados>";
			$xml .= "	<cdcooper>".$oDados->cooperativaAssociadoCodigo."</cdcooper>";
			$xml .= "	<cdagenci>1</cdagenci>";
			$xml .= "	<cdoperad>AUTOCDC</cdoperad>";
			$xml .= "	<cdorigem>5</cdorigem>";			
			$xml .= "	<nrctrprp>".$oDados->contratoNumero."</nrctrprp>";
			$xml .= "	<nrdconta>".$oDados->contaAssociadoNumero.$oDados->contaAssociadoDV."</nrdconta>";
			$xml .= "	<cdcliente>0</cdcliente>";
			$xml .= "	<tpacionamento>1</tpacionamento>";
			$xml .= "	<dsoperacao>INTEGRACAO CDC - INCLUSAO PROPOSTA</dsoperacao>";
			$xml .= "	<dsuriservico>".$this->getNameHost()."</dsuriservico>";
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
				$dscritic = $oRetorno->Erro->Registro->dscritic;
				if (strpos($dscritic, 'Erro geral') >= 0){
					$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.',$dscritic);
				}else{
					$this->processaRetornoErro(400,$dscritic);
				}
                return false;
            }
			// Capturar o identificador de acionamento
			$idacionamento = $oRetorno->idacionamento;
			
			$jbens = json_encode($oDados->bensAlienacao);
			$abens = json_decode($jbens, true);
			$sbens = '';
			for ($i = 0; $i < sizeof($abens); $i++) {
				$sbens = $sbens . implode("; " , $abens[$i]) . '#' . implode("; ", array_keys($abens[$i])) . '|';
			}
			// Monta retorno da proposta a partir do motor de crédito
			$xml  = "<Root>";
			$xml .= " <Dados>";
			$xml .= "	<cdcopass>".$oDados->cooperativaAssociadoCodigo."</cdcopass>";
			$xml .= "	<nrctaass>".$oDados->contaAssociadoNumero.$oDados->contaAssociadoDV."</nrctaass>";
			$xml .= "	<nrctremp>".$oDados->contratoNumero."</nrctremp>";
			$xml .= "	<dsbensal>".$sbens."</dsbensal>";
			$xml .= " </Dados>";
			$xml .= "</Root>";
			$sXmlResult = mensageria($xml, "EMPR0012", "VALIDA_GRAVAMES", 0, 0, 0, 5, 0, "</Root>");
			$oRetorno  = simplexml_load_string($sXmlResult);
			
			// Vamos verificar se veio retorno de erro
			if (isset($oRetorno->Erro->Registro->dscritic)){
				$dscritic = $oRetorno->Erro->Registro->dscritic;
				if (strpos($dscritic, 'Erro geral') >= 0){
					$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.',$dscritic,$idacionamento);
				}else{
					$this->processaRetornoErro(400,$dscritic,'',$idacionamento);
				}
				return false;
			}
			
			$xml  = '';
			$xml .= '<Root>';
			$xml .= '	<Cabecalho>';
			$xml .= '		<Bo>b1wgen0171.p</Bo>';
			$xml .= '		<Proc>registrar_gravames</Proc>';
			$xml .= '	</Cabecalho>';
			$xml .= '	<Dados>';
			$xml .= '		<cdcooper>'.$oDados->cooperativaAssociadoCodigo.'</cdcooper>';
			$xml .= '		<nrdconta>'.$oDados->contaAssociadoNumero.$oDados->contaAssociadoDV.'</nrdconta>';			
			$xml .= '		<nrctremp>'.$oDados->contratoNumero.'</nrctremp>';
			$xml .= '		<dtmvtolt></dtmvtolt>';
			$xml .= '		<cddopcao>E</cddopcao>';
			$xml .= '	</Dados>';
			$xml .= '</Root>';

			$xmlResult = getDataXML($xml);
			$xmlObjeto = getObjectXML($xmlResult);

			// Vamos verificar se veio retorno de erro
			if (sizeof($xmlObjeto->roottag->tags) > 0){
				if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
					$dscritic = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
					if (strpos($dscritic, 'Nao foi possivel concluir') >= 0){
						$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.',$dscritic,$idacionamento);
					}else{
						$this->processaRetornoErro(400,$dscritic,'',$idacionamento);
					}
					return false;
				}
			}

			
			// Capturar numero do contrato
			$nrctremp = $xmlObjeto->roottag->tags[0]->attributes['NRCTREMP'];
			// Monta retorno da proposta a partir do motor de crédito
			$xml  = "<Root>";
			$xml .= " <Dados>";
			$xml .= "	<cdcooper>".$oDados->cooperativaAssociadoCodigo."</cdcooper>";
			$xml .= "	<cdagenci>".$cdagenci."</cdagenci>";
			$xml .= "	<nrdconta>".$oDados->contaAssociadoNumero.$oDados->contaAssociadoDV."</nrdconta>";
			$xml .= "	<nrctremp>".$nrctremp."</nrctremp>";
			$xml .= " </Dados>";
			$xml .= "</Root>";
			$sXmlResult = mensageria($xml, "EMPR0012", "RETORNA_PROPOSTA", 0, 0, 0, 5, 0, "</Root>");
			$oRetorno  = simplexml_load_string($sXmlResult);
			
			// Vamos verificar se veio retorno de erro
			if (isset($oRetorno->Erro->Registro->dscritic)){
				$dscritic = $oRetorno->Erro->Registro->dscritic;
				if (strpos($dscritic, 'Erro geral') >= 0){
					$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.',$dscritic,$idacionamento);
				}else{
					$this->processaRetornoErro(400,$dscritic,'',$idacionamento);
				}
				return false;
			}
			// Repassar retorno do motor para variável
			$dsjsonan = json_decode($oRetorno->Dados->dsjsonan, TRUE);
			
            //Retorna a resposta para o servico
            $this->processaRetornoSucesso(200,
                                          'Solicitação de gravames realizada com sucesso!',
                                          $idacionamento,
										  $dsjsonan,
                                          0,
                                          '');

        } catch(RestException $oException){
            $this->processaRetornoErro($oException->getCode(), $oException->getMessage());
            return false;            
        } catch (Exception $oException){
            $this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.', 'Erro geral do sistema.');
            return false;
        }
        return true;
    }
}
?>