#INCLUDE 'Protheus.ch'
#INCLUDE 'PRTOPDEF.CH'

//---------------------------------------------------------------------------
/*/{PROTHEUS.DOC} LJ7061
PE LJ7061 - Ponto de Entrada chamado para valida��es na digita��o do c�digo 
			do produto na Venda Assitida e antes da impress�o concomitante.
@OWNER MADECENTER
@VERSION PROTHEUS 12
@SINCE 24/09/2024
/*/
//---------------------------------------------------------------------------
User Function LJ7061()
	
	Local lRet := .T.
	Local nPosEnt := aScan(aHeader, {|x| Alltrim(x[2])=="LR_ENTREGA" })
	Local lProdSV := AllTrim(SB1->B1_TIPO) == 'SV'
	/*
	Local nPosPro := aScan(aHeader, {|x| Alltrim(x[2])=="LR_PRODUTO" })
	Local nPosDes := aScan(aHeader, {|x| Alltrim(x[2])=="LR_DESCRI" })
	Local cCodPro := aCOLS[N][nPosPro]
	Local cDescPr := AllTrim(aCOLS[N][nPosDes])
	Local nY 
	*/

	DeFault lNota := .F.

	/*
	For nY := 1 To Len(aCOLS)
		IF nY != N .And. (aCOLS[N][Len(aCOLS[N])])
			IF aCOLS[nY][nPosPro] == aCOLS[N][nPosPro]
				FWAlertWarning("O Produto " + AllTrim(cCodPro) + " - " + cDescPr +", j� foi inserido anteriormente.","Produto")
				lRet := .F.
			EndIF
		EndIF 
	Next 
	*/

	If lRet
		If lProdSV
			aCOLS[N][nPosEnt] := '2'
		ElseIF lNota
			aCOLS[N][nPosEnt] := '3'
		EndIF 
	EndIF 

Return lRet
