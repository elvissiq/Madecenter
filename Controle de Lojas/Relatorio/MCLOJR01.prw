#INCLUDE 'Protheus.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} MCLOJR01
Relat�rio de Comprovante de Retirada
@author Felipe Valen�a - Newsiga
@since 18/02/2025
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/

User Function MCLOJR01()
	Local nOrcam
	Local sTexto                      
	Local cQuant 		:= ""
	Local nMaxChar 		:= 47 // M�XIMO DE CARACTERES POR LINHA
	Local aFieldSM0     := { ;
							"M0_NOMECOM",;   //Posi��o [1]
							"M0_ENDENT",;    //Posi��o [2]
							"M0_BAIRENT",;   //Posi��o [3]
							"M0_CIDENT",;    //Posi��o [4]
							"M0_ESTENT",;    //Posi��o [5]
							"M0_CEPENT",;    //Posi��o [6]
							"M0_CGC",;       //Posi��o [7]
							"M0_INSC",;      //Posi��o [8]
							"M0_COMPENT",;   //Posi��o [9]
							"M0_TEL";		 //Posi��o [10]
							}        
	Local aSM0Data 		:= FWSM0Util():GetSM0Data(, SL1->L1_FILIAL, aFieldSM0)
	Local cNomCom       := aSM0Data[1,2] // Nome Comercial da Empresa
	Local cEndEnt       := aSM0Data[2,2] // Endere�o de Entrega
	Local cBaiEnt       := aSM0Data[3,2] // Bairro de Entrega
	Local cCidEnt       := aSM0Data[4,2] // Cidade de Entrega
	Local cEstEnt       := aSM0Data[5,2] // Estado de Entrega
	Local cCepEnt       := aSM0Data[6,2] // Cep de Entrega
	Local cCgcEnt       := aSM0Data[7,2] // CNPJ 
	Local cInsEnt       := aSM0Data[8,2] // Inscri��o Estadual

	sTexto:= '<ce>'+ alltrim(cNomCom) +'</ce>'+ Chr(13)+ Chr(10)
	sTexto:= sTexto+'<ce>'+ alltrim(cEndEnt) + ' - '+ alltrim(cBaiEnt) +'</ce>'+ Chr(13)+ Chr(10)
	sTexto:= sTexto+'<ce>'+ alltrim(cCidEnt) + ' - '+ alltrim(cEstEnt) + ' CEP:'+ alltrim(cCepEnt) +'</ce>'+ Chr(13)+ Chr(10)
	sTexto:= sTexto+'<ce> CNPJ: '+ alltrim(cCgcEnt) + ' IE: '+ alltrim(cInsEnt) +'</ce>'+ Chr(13)+ Chr(10)

	sTexto:= sTexto+ Replicate("-", nMaxChar)						   + Chr(13)+ Chr(10)
	sTexto:= sTexto+ '<b><ce>MAPA DE SEPARA��O</ce></b>' 	   + Chr(13)+ Chr(10)
	sTexto:= sTexto+ Replicate("-", nMaxChar)						   + Chr(13)+ Chr(10)
	
	sTexto:= sTexto+ 'Codigo         Descricao'+Chr(13)+Chr(10)
	sTexto:= sTexto+ 'Qtd                                           '+Chr(13)+Chr(10)
	sTexto:= sTexto+'-----------------------------------------------'+Chr(13)+Chr(10)
	dbSelectArea("SL1")                                                                  
	dbSetOrder(1)  
	nOrcam		:= SL1->L1_NUM
			
	dbSelectArea("SL2")
	dbSetOrder(1)  
	dbSeek(xFilial("SL2") + nOrcam)
		
	While !SL2->(Eof()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == cFilAnt + nOrcam
		cQuant 		:= StrZero(SL2->L2_QUANT, 8, 3)

		sTexto		:= sTexto + SL2->L2_PRODUTO + SL2->L2_DESCRI + Chr(13) + Chr(10)
		sTexto		:= sTexto + cQuant  + Chr(13) + Chr(10)
		
		sTexto		:= sTexto + "Endere�o: " + AllTrim(SL2->L2_LOCALIZ) + " | ________________" + Chr(13) + Chr(10)

		SL2->(DbSkip())
	Enddo                      

	sTexto		:= sTexto + " " + Chr(13) + Chr(10)
	sTexto		:= sTexto + " " + Chr(13) + Chr(10)
	sTexto		:= sTexto + " " + Chr(13) + Chr(10)
	sTexto		:= sTexto + "Ass. Conferente: ______________________" + Chr(13) + Chr(10)
	sTexto		:= sTexto + " " + Chr(13) + Chr(10)
	sTexto		:= sTexto + " " + Chr(13) + Chr(10)
	sTexto		:= sTexto + "Ass. Separador1: ______________________" + Chr(13) + Chr(10)
	sTexto		:= sTexto + " " + Chr(13) + Chr(10)
	sTexto		:= sTexto + " " + Chr(13) + Chr(10)
	sTexto		:= sTexto + "Ass. Separador2: ______________________" + Chr(13) + Chr(10)
    
    STWManagReportPrint(sTexto,1) //Envia comando para a Impressora
Return 
