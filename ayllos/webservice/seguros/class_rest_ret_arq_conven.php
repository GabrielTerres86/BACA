<?php
/* 
 * Classe Responsavel da requisicao REST de retorno do arquivo de convenio
 * 
 *  @autor: Lucas Reinert
 * Serviço: 9
 */
require_once('../class/class_rest_server_json.php');
class RestRetArqConv extends RestServerJson{
    
    private $aParamsRequired;
    
    public function __construct(){
        $this->aParamsRequired = array('idServico','idConvenio','nmArquiv');
    }
    
    public function __destruct(){
        unset($this->aParamsRequired);
    }
    
    /**
     * M�todo responsavel por enviar a mensagem de resposta a requisicao
     * @param String $status
     * @param String $mensagemDetalhe
     * @return boolean
     */
    private function processaRetorno($status, $mensagemDetalhe, $arquivoConv){
        $aRetorno = array();
        $aRetorno['idStatus']   = $status;        
        $aRetorno['msgDetalhe'] = $mensagemDetalhe;
		$aRetorno['arquivoConv'] = $arquivoConv;		
        // Setando o codigo do status no Header da resposta		
        header("Cache-Control: no-cache, must-revalidate");
		header("Expires: 0");
		header('Content-Type: ' . RestFormat::$aRestFormat[$this->getTypeFormato()]);
        header('Status-Code: '.$status, true, $status);
        // Enviando a resposta para o servico
        return $this->processaRetornoFormato($aRetorno);
    }
    
    /**
     * M�todo responsavel por enviar a mensagem de Exception
     * @param String Status
     * @param String Mensagem de detalhe
     */
    private function processaRetornoErro($status, $dscritic){
        $aRetorno = array();
        $aRetorno['idStatus']   = $status;
        $aRetorno['msgDetalhe'] = $dscritic;

        // Setando o codigo do status no Header da resposta
        header("Cache-Control: no-cache, must-revalidate");
        header("Expires: 0");
        header('Content-Type: ' . RestFormat::$aRestFormat[$this->getTypeFormato()]);
        header('Status-Code: '.$status, true, $status);

        // Enviando a resposta para o servico
        return $this->processaRetornoFormato($aRetorno);
    }
    
    /**
     * Método responsavel por enviar de sucesso
     * @param String $status
     * @param String $mensagemDetalhe
     */
    private function processaRetornoArquivo($arquivoConv){
        		
        // Setando o codigo do status no Header da resposta		
        header("Cache-Control: no-cache, must-revalidate");
		header("Expires: 0");
		header('Content-Type: text/plain');
        // Enviando a resposta para o servico		
		echo $arquivoConv;
        return true;
    }

    /**
     * Valida se todos os parametros recebidos estão corretos
     * @param Object $oDados
     * @return boolean
     */
    private function validaParametrosRecebidos($oDados){
        // Condicao para verificar se eh um objeto
        if (!is_object($oDados)){
            $this->processaRetornoErro(402,'Parametros incorretos.');
            return false;
        }
        
        // Verifica se todos os parametros foram recebidos
        foreach ($this->aParamsRequired as $sPametro){
            if (!isset($oDados->$sPametro)){
                $this->processaRetorno(402,'Parametro [' . $sPametro . '] obrigatorio!');
                return false;
            }
        }
		
        return true;
    }
    
	// Classe sobrescrita
    protected function getDados() {
        return (object) $_GET;
    }
	
    /**
     * Processa os dados da Requisicao
     */
    public function processaRequisicao(){
        try{
            $this->setMetodoRequisitado('GET');
            
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
            
            // Processa a informacao do banco de dados        
            $xml  = "<Root>";
            $xml .= " <Dados>";
            $xml .= "   <dsusuari>" . $this->getUsuario() . "</dsusuari>";
            $xml .= "   <dsdsenha>" . $this->getSenha()   . "</dsdsenha>";
            $xml .= "   <cdconven>" . $oDados->idConvenio . "</cdconven>";       
            $xml .= "   <nmarquiv>" . $oDados->nmArquiv   . "</nmarquiv>";            
            $xml .= " </Dados>";
            $xml .= "</Root>";
            $sXmlResult = mensageria($xml, "CONV0002", "CONV0002_RET_ARQ_CONVEN", 0, 0, 0, 5, 0, "</Root>");
            $oRetorno   = simplexml_load_string($sXmlResult);
            
            // Vamos verificar se veio retorno 
            if ((!isset($oRetorno->idStatus)) || ($oRetorno->idStatus == 0) || ($oRetorno->idStatus == '')){
				$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.');
                return false;
            }
            
			// Verificar se veio retorno de erro
            if ($oRetorno->idStatus == 402){
				$this->processaRetornoErro((string) $oRetorno->idStatus,(string) $oRetorno->msgDetalhe);
                return false;
            }
			
            // Retorna a resposta para o servico
            $this->processaRetornoArquivo((string) $oRetorno->dsbytes);
										  
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