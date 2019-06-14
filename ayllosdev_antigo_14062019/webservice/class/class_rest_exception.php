<?php
/* 
 * Classe Responsavel pelas excecoes do PHP
 * 
 * @autor: James Prust Junior 
 */
class RestException extends Exception{
    
    public function __construct($code, $message = null, Exception $previous = null){
        parent::__construct($message, $code, $previous);
    }
}
?>