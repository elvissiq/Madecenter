#INCLUDE 'Protheus.ch'
#INCLUDE 'PRTOPDEF.CH'

//---------------------------------------------------------------------------------------------------------------------
/*/{PROTHEUS.DOC} LJ7094
PE LJ7094 - Este Ponto de entrada é utilizado para permitir ao usuário alterar 
			a regra de utilização do valor do Vale Presente, na finalização da venda. 
			No modelo padrão, se o valor da venda for diferente do valor do Vale Presente, a venda não é finalizada..
@OWNER MADECENTER
@VERSION PROTHEUS 12
@SINCE 25/09/2024
/*/
//---------------------------------------------------------------------------------------------------------------------
User Function LJ7094()
	
	Local lRet 	   := .F.
	//Local aColsVP  := ParamIXB[1] // Acols com os itens de Vale presente
	Local nVlrPgto := ParamIXB[2] // Valor da compra
	Local nValorVP := ParamIXB[3] // Valor do Vale Presente

	If nVlrPgto <= nValorVP
		lRet := .T.
	EndIf

Return lRet
