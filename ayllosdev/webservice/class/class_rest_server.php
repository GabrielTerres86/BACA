<?php
/* 
 * Classe Responsavel pelo servico REST
 * 
 * @autor: James Prust Junior 
 */
require_once('class_rest_format.php');
require_once('class_rest_exception.php');

abstract class RestServer{
    
    private $metodo;
	private $requisicaoAutenticada = true;
    
    /**
     * Retornar os dados da requisicao
     * @return Array
     */
    abstract protected function getDados();
    
    /**
     * Retorna o tipo do formato (XML, JSON)
     * @return String
     */
    abstract protected function getTypeFormato();
    
    /**
     * Retorna os dados para o WebService de acordo com o formato
     * @return (JSON, XML)
     */
    abstract protected function processaRetornoFormato(Array $aRetorno);  
    
    protected function setMetodoRequisitado($metodo){
        $this->metodo = $metodo;        
    }
    
    protected function getMetodoRequisitado(){
        return $this->metodo;
    }
    
    protected function setRequisicaoAutenticada($requisicaoAutenticada){
        $this->requisicaoAutenticada = $requisicaoAutenticada;        
    }
    
    protected function getRequisicaoAutenticada(){
        return $this->requisicaoAutenticada;
    }
    
    /**
     * Retorna o formato da requisicao
     * @return String
     */
    private function getFormatoRequisicao(){
        return $_SERVER['CONTENT_TYPE'];
    }
    
    /**
     * Retorna o metodo da requisicao
     * @return String
     */
    private function getMetodoRequisicao(){
        return $_SERVER['REQUEST_METHOD'];
    }
    
    /**
     * Retorna o usuario da autenticacao
     * @return String
     */
    protected function getUsuario(){
        if (!isset($_SERVER['PHP_AUTH_USER'])){
            return false;            
        }
        return $_SERVER['PHP_AUTH_USER'];
    }
    
    /**
     * Retorna a senha da autenticacao
     * @return String
     */
    protected function getSenha(){
        if (!isset($_SERVER['PHP_AUTH_PW'])){
            return false;
        }
        return $_SERVER['PHP_AUTH_PW'];
    }
    
    /**
     * Retorna o nome do Host
     * @return String
     */
    protected function getNameHost(){
        if (!isset($_SERVER['HTTP_HOST'])){
            return false;
        }
        return $_SERVER['HTTP_HOST'];        
    }
	
    /**
     * Retorna a URI completa
     * @return String
     */
    protected function getURI(){
        if (!isset($_SERVER['HTTP_HOST']) || !isset($_SERVER['REQUEST_URI'])){
            return false;
        }
        return $_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];        
    }
	
    
    /**
     * Valida os dados da Requisicao
     * @return boolean
     * @throws RestException
     */
    protected function validaRequisicao(){
        // Condicao para verificar se o formato eh valido
        if (!isset(RestFormat::$aRestFormat[$this->getTypeFormato()])){
            throw new RestException(405,'Formato ' . $this->getTypeFormato() . ' e requerido');
            return false;
        }
            
        // Condicao para verificar se o formato eh valido
        if (strtoupper(RestFormat::$aRestFormat[$this->getTypeFormato()]) != strtoupper($this->getFormatoRequisicao())){
            throw new RestException(406,'Formato invalido.');
            return false;
        }
            
        // Condicao para verificar se o metodo eh permitido
        if (strtoupper($this->getMetodoRequisitado()) != strtoupper($this->getMetodoRequisicao())){
            throw new RestException(405,'Metodo nao permitido.');
            return false;
        }
        
        // Somente para requisições privadas 
        if ($this->getRequisicaoAutenticada()) {        
        // Condicao para verificar se foi enviada as credenciais
        if (!$this->getUsuario()){
            throw new RestException(401,'Parecer nao foi atualizado, credencias nao foram informados.');
            return false;
        }
        
        // Condicao para verificar se foi enviada as credenciais
        if (!$this->getSenha()){
            throw new RestException(401,'Parecer nao foi atualizado, credencias nao foram informados.');
            return false;
        }
		}
        return true;
    }
}
?>
