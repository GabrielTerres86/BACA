<?php
/*
 * Classe Responsavel da requisicao REST da /convenios
 *
 * @autor: Lucas Reinert
 *
 *	Alterações:
 *		27/06/2016 - Renato(Supero) - Implementação da rotina
 */
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../class/class_rest_server_json.php');

require_once("class_rest_conv_envia_arq.php");
require_once("class_rest_lista_ret_conven.php");
require_once("class_rest_ret_arq_conven.php");

class RestConvenios extends RestServerJson{

    private $aParamsRequired;

    public function __construct(){
        $this->aParamsRequired = array('idServico','idConvenio');
    }

    public function __destruct(){
        unset($this->aParamsRequired);
    }

	/**
     * Metodo responsavel por enviar a mensagem de resposta a requisicao
     * @param String $status
     * @param String $mensagemDetalhe
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
     * Valida se todos os parametros recebidos estao corretos
     * @param Object $oDados
     * @return boolean
     */
    private function validaParametrosRecebidos($oDados){
        // Condicao para verificar se eh um objeto
        if (!is_object($oDados)){
            $this->processaRetorno(402,'Consulta nao foi efetuada, parametros incorretos.');
            return false;
        }

        // Verifica se todos os parametros foram recebidos
        foreach ($this->aParamsRequired as $sPametro){
            if (!isset($oDados->$sPametro)){
                $this->processaRetorno(402,'Parametro [' . $sPametro . '] obrigatorio!');
                return false;
            }
        }

		// Verifica se o convênio informado é numérico
		if (!is_numeric($oDados->idConvenio)) {
			$this->processaRetorno(402,'Parametro idConvenio nao e um numero valido!');
            return false;
		}

        return true;
    }

	// Possui a regra de validação para GET e POST conforme o serviço
	private function validaGetPost($idservico,$metodo) {
		// Verifica se a chamada foi realizada através de POST
		if ($this->getMetodoRequisitado() != $metodo) {
			$this->processaRetorno(402,'Para idServico = (' . $idservico . '), apenas o metodo ' . $metodo . ' sera aceito!');
			return false;   
		}
		return true;
	}

	// Classe sobrescrita, pois na requisição GET deve ser feita a leitura dos parametros desta forma
    protected function getDados() {
		return (object) $_GET;
    }
	
    /**
     * Processa os dados da Requisicao
     */
    public function processaRequisicao(){
        try{
			
			// Atribui o mesmo método para não gerar erro ao executar validaRequisicao
            $this->setMetodoRequisitado($_SERVER['REQUEST_METHOD']);
			
			// Tenta buscar por POST o valor
			$idservico = (isset($_POST['idServico']))  ? $_POST['idServico']  : '0';
			
			if ($idservico == 7) {
				// Quando o serviço for igual a 7, a requisição não sera com JSON, por isto
				// não será chamada a valida requisição e se fará o set dos parametros com 
				// encode neste momento, com o intuito de aproveitar a estrutura das classes
				$this->setFileContents(json_encode($_POST));
			} else {
				// Valida os dados da requisicao
				if (!$this->validaRequisicao()){
					return false;
				}
			}
			
			// Busca os dados da requisicao conforme o método da requisição
			if ($this->getMetodoRequisitado() == "GET") {
				$oDados = $this->getDados();
			} else if ($this->getMetodoRequisitado() == "POST") {
				$oDados = RestServerJson::getDados(); // Usar a leitura da classe superior
			}
			
            // Valida se todos os parametros obrigatorios foram recebidos e demais validações
            if (!$this->validaParametrosRecebidos($oDados)){
                return false;
            }            
            		
			// Conforme o serviço recebido, instancia a classe correspondente
            switch ($oDados->idServico) {
                
                case 7: // Envio de arquivo de empresa conveniada
					// Verifica se a chamada foi realizada através de POST
					if (!$this->validaGetPost($oDados->idServico, "POST")) {
						return false;   
					}

					$oRestEnviaArq = new RestEnviaArq();
					$oRestEnviaArq->setFileContents(json_encode($_POST)); // Enviar os dados recebidos por POST
					$oRestEnviaArq->processaRequisicao();
					
					break; //Fim CASE 7
				case 8: // Lista de arquivos de retorno de determnada data
					// Verifica se a chamada foi realizada através de GET
					if (!$this->validaGetPost($oDados->idServico, "GET")) {
						return false;   
					}
					
					$oRestListaConv = new RestListaConv();
					$oRestListaConv->processaRequisicao();
					
					break; //Fim CASE 8
				case 9: // Retorno de arquivo solicitado
					// Verifica se a chamada foi realizada através de GET
					if (!$this->validaGetPost($oDados->idServico, "GET")) {
						return false;   
					}

					$oRestRetArqConv = new RestRetArqConv();
					$oRestRetArqConv->processaRequisicao();
					
					break; //Fim CASE 9
                default: 
					$this->processaRetorno(402,'idServico invalido! Somente utilizar 7, 8 ou 9!');
                    return false;                        
            }


        } catch(RestException $oException){
            $this->processaRetorno($oException->getCode(), $oException->getMessage());
            return false;
        } catch (Exception $oException){
            $this->processaRetorno(500,'Ocorreu um erro interno no sistema.');
            return false;
        }
        return true;
    }
}
?>