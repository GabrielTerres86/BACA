<?
/*!
 * FONTE        : class_confirma_troca_senha_cabal.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : Junho/2014
 * OBJETIVO     : Classe de troca de senha com a CABAL
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
 require_once("class_webservice_cabal.php");
class ConfirmaTrocaSenhaCabal extends WebServiceCabal{

	private $identificador;
	
	public function setIdentificador($identificador){
		$this->identificador = $identificador;	
	}
	
	private function getIdentificador(){
		return $this->identificador;
	}
	
	public function getCodigoRetorno(){
		return (int) substr($this->getRetorno(),strlen($this->getIdentificador()),2);
	}

	public function confirmarTrocaDeSenha(Array $aParametros){
		$this->call('confirmarTrocaSenha','voConfirmacaoTrocaDeSenha',$aParametros);
	}
}
?>