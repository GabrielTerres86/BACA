<?
/*!
 * FONTE        : class_troca_senha_cabal.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : Junho/2014
 * OBJETIVO     : Classe de troca de senha com a CABAL
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
 require_once("class_webservice_cabal.php");
class TrocaSenhaCabal extends WebServiceCabal{

	public function getIdentificadorTransacao(){
		return substr($this->getRetorno(),0,10);
	}

	public function getCodigoRetorno(){
		return substr($this->getRetorno(),10,2);
	}

	public function getTamanhoRetorno(){
		return  hexdec(substr($this->getRetorno(),12,2));
	}

	public function getScriptTrocaDeSenha(){
		return substr($this->getRetorno(),14,$this->getTamanhoRetorno());		
	}
	
	public function gerarScriptTrocaDeSenha(Array $aParametros){
		$this->call('gerarScriptTrocaSenha','voScriptTrocaDeSenha',$aParametros);
	}
}
?>