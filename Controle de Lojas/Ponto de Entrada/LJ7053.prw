#Include "Protheus.ch"
 
/*-------------------------------------------------------------------------------------*
 | P.E.:  LJ7053                                                                       |
 | Desc:  LJ7053 - Adição de opções em "Outras Ações" do Venda Assistida.              |
 | Link:  https://tdn.totvs.com/pages/viewpage.action?pageId=6791039                   |
 *-------------------------------------------------------------------------------------*/

User Function LJ7053()
        Local aDados := {}
        Local aItem  := {}
        Local aSubI1 := {}
        Local aSubI2 := {}
        
        aSubI1 := {{ "Confirmar Entrega" , "U_MLJF03"	,0,1}} 
        

        aSubI2 := {{ "Liberar Quantidade", "MATA455"	,0,3},; 
        	   { "Gerar Nota Fiscal", "MATA460A"	,0,3},; 
            	   { "NF-e Sefaz", "SPEDNFE"	        ,0,3},; 
               	   { "Nota Fiscal Servico", "FISA022"	,0,3}}	
        
        
        aItem := {{ "Cupom Fiscal", aSubI1 ,0,3},; 
        	  { "Nota Fiscal" , aSubI2 ,0,3} } 

        aAdd(aDados, { "Expedição", aItem , 0 , 3 , , .T. })

        AAdd(aDados, { "Hist. Cliente","U_MLJF01", 0, 1, NIL, .F.})
        AAdd(aDados, { "Crédito Correntista","U_MLJF06", 0, 1, NIL, .F.})
        AAdd(aDados, { "Imp. Orc. Completo","U_zROrcComp", 0, 1, NIL, .F.})
        AAdd(aDados, { "Imp. Orc. Simples" ,"U_zROrcSimp", 0, 1, NIL, .F.})

Return aDados
