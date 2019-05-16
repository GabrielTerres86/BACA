<?php
/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 18/03/2019
 * Ultima alteração:
 */
include('Dados.php');
class Autentica extends Dados{

    private $arrParametrosObrigatorios = Array(
        "cdcooper",
        "cdagenci",
        "cdoperad",
        "nrcpfcgc",
        "dstoken",
        "nrdconta",
        "tpproduto",
        "nrproposta"/*,
        "tipoentrada"*/
    );


    /**
     * Retorna todos as variaveis da classe Dados
     *
     * @return Array Parametros
     */
    public function getParametros(){return get_object_vars($this);} //Não retorna variaveis privadas

    public function validaParametros(){
        $params = $this->getParametros();
        foreach($params['arrParametrosObrigatorios'] as $param){
            if($param !== 'tipoentrada'){
                if(preg_replace('/\s+/', '', $this->{$param}) === '')
                return false;
            }
        }
        return true;
    }

    public function getCooperativas(){
        return Array(
            "1" => "Viacredi",
            "2" => "Acredicoop",
            "3" => "Ailos",
            "5" => "Acentra",
            "6" => "Credifiesc",
            "7" => "Credcrea",
            "8" => "Credelesc",
            "9" => "Transpocred",
            "10" => "Credicomin",
            "11" => "Credifoz",
            "12" => "Crevisc",
            "13" => "ScrCred",
            "14" => "Evolua",
            "16" => "Viacredi Alto Vale"
        );
    }

}