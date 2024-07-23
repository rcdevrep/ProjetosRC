#include 'protheus.ch'

//-------------------------------------------//
//    Função:SLAAGR14                        //
//    Utilização: Replica Campos do Doc.Ent. //
//    Data: 09/03/2016                       //
//    Autor: Leandro Spiller                 //                               
//-------------------------------------------//
User Function SLAAGR14(xCampo)
                      
	Local c := ""
	Local nColuna := aScan(aHeader, {|arr| AllTrim(Upper(arr[2])) == xCampo })
	Local nColCF  := aScan(aHeader, {|arr| AllTrim(Upper(arr[2])) == 'D1_CF' })
	Local cRet :=  M->&(xCampo) 
	

	If Type('n') == 'N' .AND. (  alltrim(FUNNAME()) == 'MATA103' .or. FUNNAME()  == 'MATA140') .AND. ctipo == 'D' 
		If n == 1 .AND. LEN(Acols) > 1 .AND. cFilant == '06'                                             
			If MsgYesNo(OemToAnsi('Deseja Replicar Conteúdo do Campo para Todas as Linhas?'),'Replicar conteudo' )	
		        For i := 1 to len(aCols)
		        	Acols[i][nColuna] := M->&(xCampo) 
		        	/*IF alltrim(xCampo) == 'D1_TES'  
		        		Acols[i][nColCF] := SF4->F4_CF
		        	Endif*/	
		        Next i                               	
		    Endif	
		Endif	 	
	Endif
	
Return cRet
