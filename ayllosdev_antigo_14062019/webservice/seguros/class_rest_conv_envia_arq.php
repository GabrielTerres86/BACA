<?php
/* 
 * Classe Responsavel da requisicao REST de envio de arquivo de convênio
 * 
 *  @autor: Renato Darosci
 * Serviço: 7
 *
 * Para este fonte foram utilizadas adaptações vizando o uso da classe RestServerJson. O uso
 * como nos demais serviços não foi possivel, pois como é realizado um envio de arquivo, a 
 * solicitação deve utilizar um content MULTIPART e não pode fazer o encode como json.
 */
require_once('../class/class_rest_server_json.php');
class RestEnviaArq extends RestServerJson{
    
    private $aParamsRequired;
    
    public function __construct(){
        $this->aParamsRequired = array('idServico','idConvenio','tpArquiv');
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
    private function processaRetorno($status, $mensagemDetalhe){
        $aRetorno = array();
        $aRetorno['idStatus']   = $status;        
        $aRetorno['msgDetalhe'] = $mensagemDetalhe;
		
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
     * @return boolean
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
     * @return boolean
     */
    private function processaRetornoSucesso($status,$mensagemDetalhe){
        return $this->processaRetorno((string) $status,(string) $mensagemDetalhe);
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
		// Verifica se tipo do arquivo é válido
		if (!in_array(strtoupper($oDados->tpArquiv), array('E','G','B','F')) ) {
			$this->processaRetornoErro(402,'Campo tpArquiv invalido! Utilizar somente E, G, B ou F!');
            return false;
		}
		
		if ($_FILES['fileArquiv']['size'] == 0){
			$this->processaRetornoErro(402,'Arquivo nao enviado ou vazio!');
            return false;
		}
		
        return true;
    }
    
    /**
     * Processa os dados da Requisicao
     */
    public function processaRequisicao(){
        try{
            $this->setMetodoRequisitado('POST');
            
            // Busca os dados da requisicao
            $oDados = RestServerJson::getDados();

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
            $xml .= "   <tparquiv>" . $oDados->tpArquiv   . "</tparquiv>";
            $xml .= " </Dados>"; 
            $xml .= "</Root>";
            $sXmlResult = mensageria($xml, "CONV0002", "CONV0002_RECEBE_ARQUIVO_CONV", 0, 0, 0, 5, 0, "</Root>");
            $oRetorno   = simplexml_load_string($sXmlResult);
            
            // Vamos verificar se veio retorno 
            if ((!isset($oRetorno->idStatus)) || ($oRetorno->idStatus == 0) || ($oRetorno->idStatus == '')){
				$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.');
                return false;
            }
            
            // Retorna a resposta para o servico
            $this->processaRetornoSucesso($oRetorno->idStatus,
                                          $oRetorno->msgDetalhe);
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