#include 'protheus.ch'

//-------------------------------------------//
//    Função:SLAAGR14                        //
//    Utilização: Replica Campos do Doc.Ent. //
//    Data: 09/03/2016                       //
//    Autor: Leandro Spiller                 //
//    Obs: Rotina verificada por XAGLOGRT    //
//-------------------------------------------//
User Function SLAAGR14(xCampo)
                      
	Local nColuna := aScan(aHeader, {|arr| AllTrim(Upper(arr[2])) == xCampo })
	//Local nColCF  := aScan(aHeader, {|arr| AllTrim(Upper(arr[2])) == 'D1_CF' })
	Local cRet :=  M->&(xCampo) 
	Local _i   := 0 

	If Type('n') == 'N' .AND. (  alltrim(FUNNAME()) == 'MATA103' .or. FUNNAME()  == 'MATA140' .or. FUNNAME()  == 'SMS001') //.AND. ctipo == 'D' 
		If n == 1 .AND. LEN(Acols) > 1 //.AND. cFilant == '06'
		
			If MsgYesNo(OemToAnsi('Deseja Replicar Conteúdo do Campo para Todas as Linhas?'),'Replicar conteudo' )	

		        For _i := 1 to len(aCols)
		        	Acols[_i][nColuna] := M->&(xCampo) 
		        	/*IF alltrim(xCampo) == 'D1_TES'  
		        		Acols[i][nColCF] := SF4->F4_CF
		        	Endif*/	
		        Next _i                               	
		    Endif	
		Endif	 	
	Endif
	
Return cRet
