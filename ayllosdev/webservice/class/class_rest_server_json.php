<?php
/* 
 * Classe Responsavel pelo servico REST para o formato JSON
 * 
 * @autor: James Prust Junior 
 */
require_once('class_rest_server.php');
class RestServerJson extends RestServer{
    
    private $fileContents;
    
    /**
     * Carrega a requisicao enviada
     * @param String $fileContents
     */
    protected function setFileContents($fileContents){
        $this->fileContents = $fileContents;        
    }
    
    /**
     * Retorna o conteudo da requisicao enviada
     * @return String
     */
    protected function getFileContents(){
        if (!isset($this->fileContents)){
            $this->setFileContents(file_get_contents('php://input'));
        }
        return $this->fileContents;
    }
    
    /**
     * Retorna os dados
     * @return Object
     */
    protected function getDados() {
        return json_decode($this->getFileContents());	
    }
    
    protected function getTypeFormato(){
        return 'JSON';
    }
    
    protected function processaRetornoFormato(array $aRetorno){
        echo json_encode($aRetorno);
        return true;
    }
}
?>
