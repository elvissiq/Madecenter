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
/*/
//---------------------------------------------------------------------------
User Function LJ7061()
	
	Local lRet := .T.
	Local nPosEnt := aScan(aHeader, {|x| Alltrim(x[2])=="LR_ENTREGA" })
	Local lProdSV := AllTrim(SB1->B1_TIPO) == 'SV'
	
	DeFault lNota := .F.

	If lRet
		If lProdSV
			aCOLS[N][nPosEnt] := '2'
		ElseIF lNota
			aCOLS[N][nPosEnt] := '3'
		EndIF 
	EndIF 

Return lRet
