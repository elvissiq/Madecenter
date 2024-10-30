#Include "PROTHEUS.CH"

/*/{Protheus.doc} StMenEdt
Este Ponto de Entrada é executado na inicialização da rotina TOTVS PDV para adição de novos itens no menu e possui como parâmetro de entrada, 
o array referente ao menu padrão do TOTVS PDV e retorna os itens de menu específicos do usuário.
@author Elvis Siqueira
@since 	30/10/2024
@param 	
@return Array(array_of_record) Retorno do ponto de entrada, contendo a seguinte estrutura
@see 	(https://tdn.totvs.com/pages/releaseview.action?pageId=152802891)
@obs	Estrutura do Array de Retorno. 
		Array(array_of_record) Retorno do ponto de entrada, contendo a seguinte estrutura
		aRet[1][1] - Título do Menu do Tipo String (Texto) - Ex.: "Menu"
		aRet[1][2] - Função a ser executada do Tipo String ( Texto ) - "U_MeuPrograma"
/*/
User Function STMenu()
	Local aRetor 	:= {}
	
	aAdd(aRetor,{"Reimpressao de Comprovantes","U_MLJF07()"})

Return(aRetor)
