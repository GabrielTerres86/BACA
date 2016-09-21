<?php
/* 
 * Classe Responsavel da requisicao REST de listagem de retorno dos convênios
 * 
 *  @autor: Lucas Reinert
 * Serviço: 8
 */
require_once('../class/class_rest_server_json.php');
class RestListaConv extends RestServerJson{
    
    private $aParamsRequired;
    
    public function __construct(){
        $this->aParamsRequired = array('idServico','idConvenio');
    }
    
    public function __destruct(){
        unset($this->aParamsRequired);
    }
     
	// Recebe os parametros corretamente, e monta o retorno
	private function processaRetorno($status,$mensagemDetalhe, $arquivos, $qtArquivos){
		$aRetorno = array();
        $aRetorno['idStatus']   = $status;        
        $aRetorno['msgDetalhe'] = $mensagemDetalhe;
		
		// Se retornar arquivos, deve incluír os mesmos no retorno
		if ($qtArquivos > 0){
			for($i = 0; $i < $qtArquivos; $i++) {
				$aRetorno['Arquivos'][$i] = $arquivos[$i];
			}		
		}
		
		$aRetorno['qtArquivos'] = $qtArquivos;		
        // Setando o codigo do status no Header da resposta
        header("Cache-Control: no-cache, must-revalidate");
		header("Expires: 0");
		header('Content-Type: ' . RestFormat::$aRestFormat[$this->getTypeFormato()]);
        header('Status-Code: '.$status, true, $status);
        // Enviando a resposta para o servico
        return $this->processaRetornoFormato($aRetorno);
	}
	 
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
     * @return boolean
     */
    private function processaRetornoSucesso($status,$mensagemDetalhe, $arquivos, $qtArquivos){
        return $this->processaRetorno((string) $status,(string) $mensagemDetalhe, $arquivos, (string) $qtArquivos);
    }

    /**
     * Valida se todos os parametros recebidos estão corretos
     * @param Object $oDados
     * @return boolean
     */
    private function validaParametrosRecebidos($oDados){
        // Condicao para verificar se eh um objeto
        if (!is_object($oDados)){
            $this->processaRetorno(402,'Parametros incorretos.');
            return false;
        }
        
        // Verifica se todos os parametros foram recebidos
        foreach ($this->aParamsRequired as $sPametro){
            if (!isset($oDados->$sPametro)){
                $this->processaRetorno(402,'Parametro [' . $sPametro . '] obrigatorio!');
                return false;
            }
        }
		// Verifica se tipo do arquivo é válido
		if (strtoupper($oDados->flRetornados) == 'S' &&  $oDados->dtIniRetorno == ''){
			$this->processaRetorno(402,'Para o retorno de todos os arquivos, favor informar data inicial!');
            return false;
		}
		
		// Verifica se tipo do arquivo é válido
		if (isset($oDados->$flRetornados) && !in_array(strtoupper($oDados->flRetornados), array('S','N')) ){
			$this->processaRetorno(402,'Campo flRetornados invalido! Enviar somente S ou N!');
            return false;
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
            $xml .= "   <dsusuari>" . $this->getUsuario()  ."</dsusuari>";
            $xml .= "   <dsdsenha>" . $this->getSenha()    ."</dsdsenha>";
            $xml .= "   <cdconven>" . $oDados->idConvenio  ."</cdconven>";            
            $xml .= "   <flgretor>" . $oDados->flRetornados."</flgretor>";
            $xml .= "   <dtiniret>" . $oDados->dtIniRetorno."</dtiniret>";
            $xml .= " </Dados>";
            $xml .= "</Root>";
	
            $sXmlResult = mensageria($xml, "CONV0002", "CONV0002_LISTA_RETORNO_CONVEN", 0, 0, 0, 5, 0, "</Root>");
            $oRetorno   = simplexml_load_string($sXmlResult);
     
            // Vamos verificar se veio retorno 
            if ((!isset($oRetorno->idStatus)) || ($oRetorno->idStatus == 0) || ($oRetorno->idStatus == '')){
				$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.');
                return false;
            }
            
            // Retorna a resposta para o servico
            $this->processaRetornoSucesso($oRetorno->idStatus,
                                          $oRetorno->msgDetalhe,
										  $oRetorno->Arquivo,
										  $oRetorno->qtArquivos);
	        
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