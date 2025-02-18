#INCLUDE 'Protheus.ch'
#INCLUDE 'PRTOPDEF.CH'

//---------------------------------------------------------------------------
/*/{PROTHEUS.DOC} LJ7061
PE LJ7061 - Ponto de Entrada chamado para validações na digitação do código 
			do produto na Venda Assitida e antes da impressão concomitante.
@OWNER MADECENTER
@VERSION PROTHEUS 12
@HIST 
	24/09/2024 - Desenvolvimento da Rotina (Elvis Siqueira)
	18/02/2025 - Atualiza preço na copia do orçamento (Elvis Siqueira)
/*/
//---------------------------------------------------------------------------
User Function LJ7061()
	
	Local lRet := .T.
	Local nPosEnt := aScan(aHeader, {|x| Alltrim(x[2])=="LR_ENTREGA" })
	Local lProdSV := AllTrim(SB1->B1_TIPO) == 'SV'
	Local cTabPad := SuperGetMV("MV_TABPAD")
	Local nPosPro := aScan(aHeader, {|x| Alltrim(x[2])=="LR_PRODUTO" })
	Local nPosQtd := aScan(aHeader, {|x| Alltrim(x[2])=="LR_QUANT" })
	Local nPosPrc := aScan(aHeader, {|x| Alltrim(x[2])=="LR_VRUNIT" })
	Local nPosVal := aScan(aHeader, {|x| Alltrim(x[2])=="LR_VLRITEM" })
	Local cCodPro := aCOLS[N][nPosPro]
	
	DeFault lNota := .F.

	IF IsInCallStack( 'Lj7CopOrc' )
		DBSelectArea("DA1")

		IF DA1->(MsSeek(xFilial("DA1") + cTabPad + cCodPro))
			aCOLS[N][nPosPrc] := Round(DA1->DA1_PRCVEN,2)
			aCOLS[N][nPosVal] := Round(( aCOLS[N][nPosQtd] * DA1->DA1_PRCVEN ),2)
		EndIF 
	EndIF 

	If lRet
		If lProdSV
			aCOLS[N][nPosEnt] := '2'
		ElseIF lNota
			aCOLS[N][nPosEnt] := '3'
		EndIF 
	EndIF 

Return lRet
