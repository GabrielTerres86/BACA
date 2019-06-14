<?php
/*
 * Classe Responsavel da requisicao REST da /webjud
 *
 * @autor: Guilherme/SUPERO
 */
require_once('../class/class_rest_server_json.php');
class RestSeguros extends RestServerJson{

    private $aParamsRequired;

    public function __construct(){
		$this->aParamsRequired = array('idServico','idParceiro','cdAgeCoop','nrConta');
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
     * @param String $cdcritic
     * @param String $dscritic
     * @return boolean
     */

    private function enviaRetornoSucesso($aRetorno){
        //echo '</br>enviaRetornoSucesso';
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
        //echo '</br>processaRetornoSucesso';
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

    /**
     * Processa os dados da Requisicao
     */
    public function processaRequisicao(){
        try{
			
            // Busca os dados da requisicao
            $oDados = $this->getDados();	
			
			$this->setMetodoRequisitado('GET');
			
			if(!is_numeric($oDados->idParceiro)){
				$this->enviaRetornoErro(402,'Parametro idParceiro nao e um numero valido!');
				return false;
			}
			
			if(!is_numeric($oDados->cdAgeCoop)){
				$this->enviaRetornoErro(402,'Parametro cdAgeCoop nao e um numero valido!');
				return false;
			}
			
			if(!is_numeric($oDados->nrConta)){
				$this->enviaRetornoErro(402,'Parametro nrConta nao e um numero valido!');
				return false;
			}
			
            // Valida os dados da requisicao
            if (!$this->validaRequisicao()){
                return false;
            }
			
            // Valida se veio todos os parametros obrigatorios
            if (!$this->validaParametrosRecebidos($oDados)){
                return false;
            }
			$xml  = "<Root>";
			$xml .= " <Dados>";
			$xml .= "   <dsusuari>".$this->getUsuario()."</dsusuari>";
			$xml .= "   <dsdsenha>".$this->getSenha()."</dsdsenha>";
			$xml .= "   <idparcei>".$oDados->idParceiro."</idparcei>";
			$xml .= "   <cdagecop>".$oDados->cdAgeCoop."</cdagecop>";
			$xml .= "   <nrdconta>".$oDados->nrConta."</nrdconta>";
			$xml .= " </Dados>";
			$xml .= "</Root>";
			$sXmlResult = mensageria($xml, "SEGU0002", "SEGU0002_BUSCA_DADOS", 0, 0, 0, 5, 0, "</Root>");
			
			$oRetorno   = simplexml_load_string($sXmlResult);
			
			//$this->enviaRetornoSucesso($oRetorno);return;
			// Vamos verificar se veio retorno
			if ((!isset($oRetorno->idStatus)) || ($oRetorno->idStatus == 0) || ($oRetorno->idStatus == '')){
				$this->enviaRetornoErro(500,'Ocorreu um erro interno no sistema.');
				return false;
			}		
			// Retorna a resposta para o servico
			$this->enviaRetornoSucesso($oRetorno);

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
?>