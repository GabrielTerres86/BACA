<?php
/* 
 * Classe Responsavel pelo servico REST para o formato XML
 * 
 * @autor: James Prust Junior 
 */
require_once('class_rest_server.php');
class RestServerXml extends RestServer{
    
    protected function getDados() {
        
    }

    protected function getTypeFormato() {
        return 'XML';
    }

    protected function processaRetornoFormato(array $aRetorno) {
        
    }
}
?>