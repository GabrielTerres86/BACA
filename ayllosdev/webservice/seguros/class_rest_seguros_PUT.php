<?php
/*
 * Classe Responsavel da requisicao REST da /webjud
 *
 * @autor: Guilherme/SUPERO
 */
require_once('../class/class_rest_server_json.php');

class RestSeguros extends RestServerJson{

    private $aParamsRequired;
	private $idServico;

    public function __construct(){
		switch($this->idServico){
			case 2:	
				$this->aParamsRequired = array('idServico','idParceiro','cdAgeCoop','nrConta','nrProposta','nrApolice','nrCpfCnpjSegurado','nmSegurado',
											   'tpSeguro','dtIniVigen','vlCapitalFranquia','vlTotPremioLiq','vlTotPremio','qtParcelas','vlParcelas',
											   'dtDebito','cdSitSeguro','cdSegura','prComissao');
				break;
			case 3:	
				$this->aParamsRequired = array('idServico','idParceiro','cdAgeCoop','nrConta','tpSeguro','nrApolice','nrEndosso');
				break;
			case 4:	
				$this->aParamsRequired = array('idServico','idParceiro','cdAgeCoop','nrConta','tpSeguro','nrApolice','nrEndosso','dtFimVigen');
				break;
			case 5:	
				$this->aParamsRequired = array('idServico','idParceiro','cdAgeCoop','nrConta','nrProposta','nrApolice','nrApoliceAnterior','nrEndosso',
											   'nrCpfCnpjSegurado','nmSegurado','tpSeguro','tpSeguro','dtIniVigen','dtFimVigen','vlCapitalFranquia',
											   'dsPlano','vlTotPremioLiq','vlTotPremio','qtParcelas','vlParcelas','dtDebito','cdSegura','prComissao',
											   'dsObserva');
				break;
			case 6:	
				$this->aParamsRequired = array('idServico','idParceiro','cdAgeCoop','nrConta','tpSeguro','nrApolice','dsObserva');
				break;
		}
    }

    public function __destruct(){
        unset($this->aParamsRequired);
    }

    /**
     * Método responsavel por enviar a mensagem de resposta a requisicao
     * @param String $status
     * @param String $mensagemDetalhe
     * @param String $numeroTransacao
     * @param String $cdcritic
     * @param String $dscritic
     * @return boolean
     */

    private function enviaRetornoSucesso($aRetorno){
    
		$status = $aRetorno->idStatus;
    
        // Setando o codigo do status no Header da resposta
        header("Cache-Control: no-cache, must-revalidate");
        header("Expires: 0");
        header('Content-Type: ' . RestFormat::$aRestFormat[$this->getTypeFormato()]);
        header('Status-Code: '.(string) $status, true, (string) $status);

        return $this->processaRetornoFormato((array) $aRetorno);
    }
    private function enviaRetornoErro($status, $dscritic){

        $aRetorno = array();
        $aRetorno['status']   = $status;
        $aRetorno['dscritic'] = $dscritic;

        // Setando o codigo do status no Header da resposta
        header("Cache-Control: no-cache, must-revalidate");
        header("Expires: 0");
        header('Content-Type: ' . RestFormat::$aRestFormat[$this->getTypeFormato()]);
        header('Status-Code: '.(string) $status, true, (string) $status);

        //echo '</br>enviaRetornoErro';
        // Enviando a resposta para o servico
        return $this->processaRetornoFormato($aRetorno);
        return true;
    }

    private function processaRetorno($status, $mensagemDetalhe, $numeroTransacao = '00000000000000000000', $cdcritic = '0', $dscritic = ''){
        //echo '</br>processaRetorno: ' . $this->getTypeFormato();

        $aRetorno = array();
        $aRetorno['status']      = $status;
        $aRetorno['dscritic']    = $mensagemDetalhe;

        // Setando o codigo do status no Header da resposta
        header("Cache-Control: no-cache, must-revalidate");
        header("Expires: 0");
        header('Content-Type: ' . RestFormat::$aRestFormat[$this->getTypeFormato()]);
        header('Status-Code: '.(string) $status, true, (string) $status);

        // Enviando a resposta para o servico
        return $this->processaRetornoFormato($aRetorno);
        //return true;
    }

    /**
     * M�todo responsavel por enviar a mensagem de Exception
     * @param String Status
     * @param String Mensagem de detalhe
     * @return boolean
     */
    private function processaRetornoErro($status, $mensagemDetalhe){
        return $this->processaRetorno((string) $status,(string) $mensagemDetalhe);
    }

    /**
     * M�todo responsavel por enviar de sucesso
     * @param String $status
     * @param String $mensagemDetalhe
     * @param String $numeroTransacao
     * @param String $cdcritic
     * @param String $dscritic
     * @return boolean
     */
    private function processaRetornoSucesso($status,$mensagemDetalhe,$numeroTransacao,$cdcritic,$dscritic){
        return $this->processaRetorno((string) $status,(string) $mensagemDetalhe,(string) $numeroTransacao,(string) $cdcritic,(string) $dscritic);
    }

    /**
     * Valida se todos os parametros recebidos est�o corretos
     * @param Object $oDados
     * @return boolean
     */
    private function validaParametrosRecebidos($oDados){
        // Condicao para verificar se eh um objeto
        if (!is_object($oDados)){
            $this->processaRetornoErro(412,'Consulta nao foi efetuada, parametros incorretos!');
            return false;
        }

        // Verifica se todos os parametros foram recebidos
        foreach ($this->aParamsRequired as $sPametro){
            if (!isset($oDados->$sPametro)){
                $this->processaRetornoErro(413,'Consulta nao foi efetuada, parametros incorretos!');
                return false;
            }
        }
        return true;
    }
	
	// Transforma JSON de beneficiarios para XML
	function arrayToXml($array){
		
		$xml = new SimpleXMLElement('<?xml version="1.0" encoding="UTF-8"?><beneficiarios/>');
		
		foreach($array as $key => $value){
			foreach($value as $key2 => $value2){
				$xml->addChild($key2, $value2);
			}		
		}
		return $xml->asXML();
	}

    /**
     * Processa os dados da Requisicao
     */
    public function processaRequisicao(){
        try{
			$this->setMetodoRequisitado('PUT');
			
            // Busca os dados da requisicao
            $oDados = $this->getDados();	
			
      $this->idServico = $oDados->idServico;
			
            // Valida os dados da requisicao
            if (!$this->validaRequisicao()){
                return false;
            }
			
            // Valida se veio todos os parametros obrigatorios
            if (!$this->validaParametrosRecebidos($oDados)){
                return false;
            }
            
            switch ($this->idServico) {
				case 2: // Seguros - Inclusão de Seguro
						// Processa a informacao do banco de dados
						
						// Cria XML de beneficiarios
						$xml_benef = $this->arrayToXml($oDados->Beneficiarios);
						
						$xml  = "<Root>";
                        $xml .= " <Dados>";
                        $xml .= "   <dsusuari>".$this->getUsuario()."</dsusuari>";
                        $xml .= "   <dsdsenha>".$this->getSenha()."</dsdsenha>";
                        $xml .= "   <idparcei>".$oDados->idParceiro."</idparcei>";
                        $xml .= "   <cdagecop>".$oDados->cdAgeCoop."</cdagecop>";
                        $xml .= "   <nrdconta>".$oDados->nrConta."</nrdconta>";
                        $xml .= "   <nrproposta>".$oDados->nrProposta."</nrproposta>";
                        $xml .= "   <nrapolice>".$oDados->nrApolice."</nrapolice>";
                        $xml .= "   <nmsegurado>".$oDados->nmSegurado."</nmsegurado>";
                        $xml .= "   <nrcpfcnpj_segurado>".$oDados->nrCpfCnpjSegurado."</nrcpfcnpj_segurado>";
                        $xml .= "   <tpseguro>".$oDados->tpSeguro."</tpseguro>";
                        $xml .= "   <dtinivigen>".$oDados->dtIniVigen."</dtinivigen>";
                        $xml .= "   <dtfimvigen>".$oDados->dtFimVigen."</dtfimvigen>";
                        $xml .= "   <vlcapital_franquia>".$oDados->vlCapitalFranquia."</vlcapital_franquia>";
                        $xml .= "   <dsplano>".$oDados->dsPlano."</dsplano>";
                        $xml .= "   <vltot_premio_liquid>".$oDados->vlTotPremioLiq."</vltot_premio_liquid>";
                        $xml .= "   <vltot_premio>".$oDados->vlTotPremio."</vltot_premio>";
                        $xml .= "   <qtparcelas>".$oDados->qtParcelas."</qtparcelas>";
                        $xml .= "   <vlparcelas>".$oDados->vlParcelas."</vlparcelas>";
                        $xml .= "   <dtdebito>".$oDados->dtDebito."</dtdebito>";
                        $xml .= "   <cdsitseguro>".$oDados->cdSitSeguro."</cdsitseguro>";
                        $xml .= "   <cdsegura>".$oDados->cdSegura."</cdsegura>";
                        $xml .= "   <comissao>".$oDados->prComissao."</comissao>";
                        $xml .= "   <dsobserva>".$oDados->dsObserva."</dsobserva>";
                        $xml .= "   <array_benef><![CDATA[".$xml_benef."]]></array_benef>";
                        $xml .= " </Dados>";
                        $xml .= "</Root>";
						
						$xml = utf8_decode($xml);
						
						$sXmlResult = mensageria($xml, "SEGU0002", "SEGU0002_ADD_CONTRATO_SEGURO", 0, 0, 0, 5, 0, "</Root>");
						
						$oRetorno = simplexml_load_string($sXmlResult);
						
						// Vamos verificar se veio retorno
                        if ((!isset($oRetorno->idStatus)) || ($oRetorno->idStatus == 0) || ($oRetorno->idStatus == '')){
                            $this->enviaRetornoErro(500,'Ocorreu um erro interno no sistema.');
                            return false;
                        }
						
                        // Retorna a resposta para o servico
                        $this->enviaRetornoSucesso($oRetorno);
					break; //Fim CASE 2
				case 3: // Seguros - Endosso de Seguro
						// Processa a informacao do banco de dados
						
						// Cria XML de beneficiarios
						$xml_benef = $this->arrayToXml($oDados->Beneficiarios);
						
						$xml  = "<Root>";
                        $xml .= " <Dados>";
                        $xml .= "   <dsusuari>".$this->getUsuario()."</dsusuari>";
                        $xml .= "   <dsdsenha>".$this->getSenha()."</dsdsenha>";
                        $xml .= "   <idparcei>".$oDados->idParceiro."</idparcei>";
                        $xml .= "   <cdagecop>".$oDados->cdAgeCoop."</cdagecop>";
                        $xml .= "   <nrdconta>".$oDados->nrConta."</nrdconta>";
                        $xml .= "   <nrproposta>".$oDados->nrProposta."</nrproposta>";
                        $xml .= "   <nrapolice>".$oDados->nrApolice."</nrapolice>";
                        $xml .= "   <nrendosso>".$oDados->nrEndosso."</nrendosso>";
                        $xml .= "   <nmsegurado>".$oDados->nmSegurado."</nmsegurado>";
                        $xml .= "   <nrcpfcnpj_segurado>".$oDados->nrCpfCnpjSegurado."</nrcpfcnpj_segurado>";
                        $xml .= "   <tpseguro>".$oDados->tpSeguro."</tpseguro>";
                        $xml .= "   <dtinivigen>".$oDados->dtIniVigen."</dtinivigen>";
                        $xml .= "   <dtfimvigen>".$oDados->dtFimVigen."</dtfimvigen>";
                        $xml .= "   <vlcapital_franquia>".$oDados->vlCapitalFranquia."</vlcapital_franquia>";
                        $xml .= "   <dsplano>".$oDados->dsPlano."</dsplano>";
                        $xml .= "   <vltot_premio_liquid>".$oDados->vlTotPremioLiq."</vltot_premio_liquid>";
                        $xml .= "   <vltot_premio>".$oDados->vlTotPremio."</vltot_premio>";
                        $xml .= "   <qtparcelas>".$oDados->qtParcelas."</qtparcelas>";
                        $xml .= "   <vlparcelas>".$oDados->vlParcelas."</vlparcelas>";
                        $xml .= "   <dtdebito>".$oDados->dtDebito."</dtdebito>";
                        $xml .= "   <cdsitseguro>".$oDados->cdSitSeguro."</cdsitseguro>";
                        $xml .= "   <comissao>".$oDados->prComissao."</comissao>";
                        $xml .= "   <dsobserva>".$oDados->dsObserva."</dsobserva>";
                        $xml .= "   <array_benef><![CDATA[".$xml_benef."]]></array_benef>";
                        $xml .= " </Dados>";
                        $xml .= "</Root>";
						
						$xml = utf8_decode($xml);
						
						$sXmlResult = mensageria($xml, "SEGU0002", "SEGU0002_END_CONTRATO_SEGURO", 0, 0, 0, 5, 0, "</Root>");
						
						$oRetorno = simplexml_load_string($sXmlResult);
						
						// Vamos verificar se veio retorno
                        if ((!isset($oRetorno->idStatus)) || ($oRetorno->idStatus == 0) || ($oRetorno->idStatus == '')){
                            $this->enviaRetornoErro(500,'Ocorreu um erro interno no sistema.');
                            return false;
                        }
						
                        // Retorna a resposta para o servico
                        $this->enviaRetornoSucesso($oRetorno);
					break; //Fim CASE 3
				case 4: // Seguros - Cancelamento de Seguro
						// Processa a informacao do banco de dados
						$xml  = "<Root>";
                        $xml .= " <Dados>";
                        $xml .= "   <dsusuari>".$this->getUsuario()."</dsusuari>";
                        $xml .= "   <dsdsenha>".$this->getSenha()."</dsdsenha>";
                        $xml .= "   <idparcei>".$oDados->idParceiro."</idparcei>";
                        $xml .= "   <cdagecop>".$oDados->cdAgeCoop."</cdagecop>";
                        $xml .= "   <nrdconta>".$oDados->nrConta."</nrdconta>";
                        $xml .= "   <tpseguro>".$oDados->tpSeguro."</tpseguro>";
                        $xml .= "   <nrapolice>".$oDados->nrApolice."</nrapolice>";
                        $xml .= "   <nrendosso>".$oDados->nrEndosso."</nrendosso>";
                        $xml .= "   <dtfimvigen>".$oDados->dtFimVigen."</dtfimvigen>";
                        $xml .= "   <dsobserva>".$oDados->dsObserva."</dsobserva>";
                        $xml .= " </Dados>";
                        $xml .= "</Root>";
						
						$xml = utf8_decode($xml);
						
						$sXmlResult = mensageria($xml, "SEGU0002", "SEGU0002_CANC_CONTRATO_SEGURO", 0, 0, 0, 5, 0, "</Root>");
						
						$oRetorno = simplexml_load_string($sXmlResult);
						
						// Vamos verificar se veio retorno
                        if ((!isset($oRetorno->idStatus)) || ($oRetorno->idStatus == 0) || ($oRetorno->idStatus == '')){
                            $this->enviaRetornoErro(500,'Ocorreu um erro interno no sistema.');
                            return false;
                        }
						
                        // Retorna a resposta para o servico
                        $this->enviaRetornoSucesso($oRetorno);
					break; //Fim CASE 4
				case 5: // Seguros - Renovação de Seguro
						// Processa a informacao do banco de dados
						
						// Cria XML de beneficiarios
						$xml_benef = $this->arrayToXml($oDados->Beneficiarios);
						
						$xml  = "<Root>";
                        $xml .= " <Dados>";
                        $xml .= "   <dsusuari>".$this->getUsuario()."</dsusuari>";
                        $xml .= "   <dsdsenha>".$this->getSenha()."</dsdsenha>";
                        $xml .= "   <idparcei>".$oDados->idParceiro."</idparcei>";
                        $xml .= "   <cdagecop>".$oDados->cdAgeCoop."</cdagecop>";
                        $xml .= "   <nrdconta>".$oDados->nrConta."</nrdconta>";
                        $xml .= "   <nrproposta>".$oDados->nrProposta."</nrproposta>";
                        $xml .= "   <nrapolice>".$oDados->nrApolice."</nrapolice>";
                        $xml .= "   <nrapolice_anterior>".$oDados->nrApoliceAnterior."</nrapolice_anterior>";
                        $xml .= "   <nrendosso>".$oDados->nrEndosso."</nrendosso>";
                        $xml .= "   <nmsegurado>".$oDados->nmSegurado."</nmsegurado>";
                        $xml .= "   <nrcpfcnpj_segurado>".$oDados->nrCpfCnpjSegurado."</nrcpfcnpj_segurado>";
                        $xml .= "   <tpseguro>".$oDados->tpSeguro."</tpseguro>";
                        $xml .= "   <dtinivigen>".$oDados->dtIniVigen."</dtinivigen>";
                        $xml .= "   <dtfimvigen>".$oDados->dtFimVigen."</dtfimvigen>";
                        $xml .= "   <vlcapital_franquia>".$oDados->vlCapitalFranquia."</vlcapital_franquia>";
                        $xml .= "   <dsplano>".$oDados->dsPlano."</dsplano>";
                        $xml .= "   <vltot_premio_liquid>".$oDados->vlTotPremioLiq."</vltot_premio_liquid>";
                        $xml .= "   <vltot_premio>".$oDados->vlTotPremio."</vltot_premio>";
                        $xml .= "   <qtparcelas>".$oDados->qtParcelas."</qtparcelas>";
                        $xml .= "   <vlparcelas>".$oDados->vlParcelas."</vlparcelas>";
                        $xml .= "   <dtdebito>".$oDados->dtDebito."</dtdebito>";
                        $xml .= "   <cdsegura>".$oDados->cdSegura."</cdsegura>";
                        $xml .= "   <comissao>".$oDados->prComissao."</comissao>";
                        $xml .= "   <dsobserva>".$oDados->dsObserva."</dsobserva>";
                        $xml .= "   <array_benef><![CDATA[".$xml_benef."]]></array_benef>";
                        $xml .= " </Dados>";
                        $xml .= "</Root>";
						
						$xml = utf8_decode($xml);
						
						$sXmlResult = mensageria($xml, "SEGU0002", "SEGU0002_RENO_CONTRATO_SEGURO", 0, 0, 0, 5, 0, "</Root>");
						
						$oRetorno = simplexml_load_string($sXmlResult);
						
						// Vamos verificar se veio retorno
                        if ((!isset($oRetorno->idStatus)) || ($oRetorno->idStatus == 0) || ($oRetorno->idStatus == '')){
                            $this->enviaRetornoErro(500,'Ocorreu um erro interno no sistema.');
                            return false;
                        }
						
                        // Retorna a resposta para o servico
                        $this->enviaRetornoSucesso($oRetorno);
					break; //Fim CASE 5
				case 6: // Seguros: Registar que um seguro contratado expirou e não houve renovação.
                        // Processa a informacao do banco de dados
						
						$xml  = "<Root>";
                        $xml .= " <Dados>";
                        $xml .= "   <dsusuari>".$this->getUsuario()."</dsusuari>";
                        $xml .= "   <dsdsenha>".$this->getSenha()."</dsdsenha>";
                        $xml .= "   <idparcei>".$oDados->idParceiro."</idparcei>";
                        $xml .= "   <cdagecop>".$oDados->cdAgeCoop."</cdagecop>";
                        $xml .= "   <nrdconta>".$oDados->nrConta."</nrdconta>";
                        $xml .= "   <tpseguro>".$oDados->tpSeguro."</tpseguro>";
                        $xml .= "   <nrapolice>".$oDados->nrApolice."</nrapolice>";
                        $xml .= "   <dsobserva>".$oDados->dsObserva."</dsobserva>";
                        $xml .= " </Dados>";
                        $xml .= "</Root>";
						
						$xml = utf8_decode($xml);
						
						$sXmlResult = mensageria($xml, "SEGU0002", "SEGU0002_VENC_CONTRATO_SEGURO", 0, 0, 0, 5, 0, "</Root>");
						
						
						$oRetorno = simplexml_load_string($sXmlResult);
						// Vamos verificar se veio retorno
                        if ((!isset($oRetorno->idStatus)) || ($oRetorno->idStatus == 0) || ($oRetorno->idStatus == '')){
                            $this->enviaRetornoErro(500,'Ocorreu um erro interno no sistema.');
                            return false;
                        }
						
                        // Retorna a resposta para o servico
                        $this->enviaRetornoSucesso($oRetorno);
					break; //Fim CASE 6
				default: $this->enviaRetornoErro(402,'idServico inválido! Somente utilizar o range de 1 a 6.(Cod.Srv.:'.$oDados->servico .')',0,0);
                         return false;
				
            }


        } catch(RestException $oException){
            $this->enviaRetornoErro($oException->getCode(), $oException->getMessage());
            return false;
        } catch (Exception $oException){
            $this->enviaRetornoErro(500,'Ocorreu um erro interno no sistema.');
            return false;
        }
        return true;
    }
	
}
